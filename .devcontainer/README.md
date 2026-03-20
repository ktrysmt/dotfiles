# Claude Code Devcontainer

`--dangerously-skip-permissions` を安全に使うためのサンドボックス環境。
dotfiles の Claude 設定 (`claude/`) と `.gitignore_global` は image の `~/claude/` に焼き込まれており、どの環境でも同じツールチェインが使える。

## 前提

```bash
mise install  # npm:@devcontainers/cli
```

## 認証

```bash
claude setup-token
export CLAUDE_CODE_OAUTH_TOKEN="sk-ant-oat01-..."
```

or

```bash
devcontainer exec --workspace-folder <repo> claude login
```

## 使い方

```sh
cd ~/projects/target-repo

devcontainer up --workspace-folder . \
  --config ~/dotfiles/.devcontainer/devcontainer.json
devcontainer exec --workspace-folder . \
  env TMUX="$TMUX" TMUX_PANE="$TMUX_PANE" \
  claude --dangerously-skip-permissions
```

## 構成

| ファイル | 役割 |
|---------|------|
| `Dockerfile` | ツール群のインストール (バイナリ直DL)。`claude/` と `.gitignore_global` を `~/claude/` に焼き込む |
| `init-firewall.sh` | ネットワーク制限 (許可ドメインのみ通信可) |
| `setup-claude.sh` | `~/claude/` の dotfiles を `~/.claude/` にシンボリックリンク。コンテナ用 `settings.json` を生成 |
| `devcontainer.json` | ランタイム設定 (GHCR イメージ参照、他リポジトリでも利用可) |

## セッションログの永続化

`~/.claude` はホスト側の `~/.claude-devcontainer/` にバインドマウントされる。
セッションログ (`projects/*/sessions/`) を含む全データがコンテナ破棄後も保持される。

`initializeCommand` でホスト側ディレクトリを自動作成するため、初回起動時の手動操作は不要。

Claude Code は `postStartCommand` でコンテナ起動のたびに最新版へ自動更新される。

## ファイアウォール

許可ドメインの追加は `init-firewall.sh` の `ALLOWED_DOMAINS` を編集するか、環境変数で渡す:

```jsonc
// devcontainer.json の containerEnv に追加
"FIREWALL_EXTRA_DOMAINS": "api.example.com,cdn.example.com"
```

### Permissive モード

ブロックせずログだけ記録する。必要なドメインを特定してから strict に切り替える運用向け。

```jsonc
// devcontainer.json の containerEnv に追加
"FIREWALL_MODE": "permissive"
```

許可リスト外へのアクセスを確認 (ホスト側で実行):

```bash
dmesg -T | grep 'FIREWALL-UNLISTED' | grep -oP 'DST=\K[0-9.]+' | sort -u | \
  while read -r ip; do
    domain=$(dig +short -x "$ip" 2>/dev/null | head -1)
    echo "$ip -> ${domain:-(unknown)}"
  done
```

## GHCR イメージのビルド

`.devcontainer/**`, `claude/**`, `.gitignore_global` を変更して master に push すると自動ビルド。

## ローカルデバッグビルド

```bash
cd ~/dotfiles
docker build -t claude-devcontainer-debug -f .devcontainer/Dockerfile .
docker run --rm -it -v "$PWD:/workspace" -u node claude-devcontainer-debug bash -x /usr/local/bin/setup-claude.sh
```
