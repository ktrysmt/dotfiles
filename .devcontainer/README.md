# Claude Code Devcontainer

`--dangerously-skip-permissions` を安全に使う

## 前提

```bash
mise install  # npm:@devcontainers/cli
```

## 初回のみ認証

環境変数を設定しておけば認証ステップ不要で即実行できる:

```bash
claude setup-token  # ホストで実行 -> トークンが出力される
export CLAUDE_CODE_OAUTH_TOKEN="sk-ant-oat01-..."
```

環境変数を使わない場合は、コンテナ起動後に一度だけ対話ログインが必要:

```bash
devcontainer exec --workspace-folder <repo> claude login
```

OAuth トークンは named volume に永続化されるため、どちらの方法でも rebuild 後の再認証は不要。

## 使い方

```bash
CONFIG=~/dotfiles/.devcontainer/portable/devcontainer.json

cd ~/projects/target-repo

devcontainer up --workspace-folder . --config $CONFIG && \
devcontainer exec --workspace-folder . \
  env TMUX="$TMUX" TMUX_PANE="$TMUX_PANE" \
  claude --dangerously-skip-permissions

# 終了
devcontainer down --workspace-folder .
```

## 構成

| ファイル | 役割 |
|---------|------|
| `Dockerfile` | ツール群のインストール (brew/mise 不使用、バイナリ直DL) |
| `init-firewall.sh` | ネットワーク制限 (GitHub, npm, Anthropic API, PyPI, MCP endpoints のみ許可) |
| `setup-claude.sh` | ホストの `~/.claude/CLAUDE.md`, `rules/`, hooks, `.mcp.json` をコンテナに注入 |
| `devcontainer.portable.json` | 他リポジトリ用テンプレート (GHCR イメージ参照) |

## ファイアウォール許可ドメイン

GitHub, npm, Anthropic API, Sentry, VS Code services に加え以下を追加:

- `pypi.org` / `files.pythonhosted.org` -- uvx (MCP サーバー実行)
- `knowledge-mcp.global.api.aws` -- aws-docs MCP
- `mcp.grep.app` -- grep-github MCP
- `proxy.golang.org` / `sum.golang.org` -- Go modules
- `crates.io` / `static.crates.io` -- Rust crates

許可ドメインの追加は `init-firewall.sh` の `ALLOWED_DOMAINS` 配列を編集するか、環境変数で渡す:

```bash
# devcontainer.json の containerEnv に追加
"FIREWALL_EXTRA_DOMAINS": "api.example.com,cdn.example.com"
```

### Permissive モード

ブロックせずログだけ記録する緩いモード。まず permissive で動かし、必要なドメインを特定してから strict に切り替える運用。

```bash
# devcontainer.json の containerEnv に追加
"FIREWALL_MODE": "permissive"
```

許可リスト外へのアクセスを確認 (ホスト側のターミナルで実行):

```bash
# iptables LOG はホストのカーネルログに出る。コンテナ内からは見えない。
dmesg -T | grep 'FIREWALL-UNLISTED' | grep -oP 'DST=\K[0-9.]+' | sort -u | \
  while read -r ip; do
    domain=$(dig +short -x "$ip" 2>/dev/null | head -1)
    echo "$ip -> ${domain:-(unknown)}"
  done
```

## GHCR イメージのビルド

`.devcontainer/**` を変更して master に push すると自動ビルド。
