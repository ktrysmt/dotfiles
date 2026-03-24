# Claude Code Devcontainer

`--dangerously-skip-permissions` を安全に使うためのサンドボックス環境。
dotfiles の Claude 設定 (`claude/`) と `.gitignore_global` は image の `~/dotfiles/` に焼き込まれており、どの環境でも同じツールチェインが使える。

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
| `Dockerfile` | ツール群のインストール (バイナリ直DL)。`claude/` と `.gitignore_global` を `~/dotfiles/` に焼き込む |
| `trace-network.sh` | eBPF ネットワークトレーサー (TCP 接続先をログ記録) |
| `setup-claude.sh` | `~/dotfiles/claude/` を `~/.claude/` にシンボリックリンク (skills は per-skill)。コンテナ用 `settings.json` を生成 |
| `devcontainer.json` | ランタイム設定 (GHCR イメージ参照、他リポジトリでも利用可) |

## セッションログの永続化

`~/.claude` はホスト側の `~/.claude-devcontainer/` にバインドマウントされる。
セッションログ (`projects/*/sessions/`) を含む全データがコンテナ破棄後も保持される。

`initializeCommand` でホスト側ディレクトリを自動作成するため、初回起動時の手動操作は不要。

Claude Code は `postStartCommand` でコンテナ起動のたびに最新版へ自動更新される。

## ネットワークトレーサー

eBPF (bpftrace kprobes on `tcp_v4_connect` / `tcp_v6_connect`) でコンテナからの TCP 接続を自動ログ記録する。
cgroup フィルタにより自コンテナのトラフィックのみ捕捉。ファイアウォール (ブロック) ではなく可観測性 (トレース) に特化した設計。

ログフォーマット: `timestamp|host|ip|port|protocol|pid|command`

```bash
# ログ確認 (最新50件)
sudo /usr/local/bin/trace-network.sh --log

# リアルタイム追跡
sudo /usr/local/bin/trace-network.sh --tail

# ステータス確認
sudo /usr/local/bin/trace-network.sh --status

# 停止
sudo /usr/local/bin/trace-network.sh --stop
```

### ログの永続化

ログは `~/.claude/networklogs/<folder>/<yyyymmdd-hhmm>-<docker-hash>.log` に保存される。
`~/.claude` はホスト側 `~/.claude-devcontainer/` にバインドマウントされており、
セッションログ (`projects/`) と同階層にネットワークログが蓄積される:

```bash
# ホスト側から一覧
ls ~/.claude-devcontainer/networklogs/my-app/

# 特定セッションのログ
cat ~/.claude-devcontainer/networklogs/my-app/20260322-1430-a1b2c3d4e5f6.log

# 全プロジェクトの接続先集計
cat ~/.claude-devcontainer/networklogs/*/*.log | grep -E '^[0-9]{4}-' | \
  cut -d'|' -f2,4 | sort | uniq -c | sort -rn
```

要件: `--cap-add=SYS_ADMIN` (eBPF kprobe アタッチに必要)。`devcontainer.json` で設定済み。

## GHCR イメージのビルド

`.devcontainer/**`, `claude/**`, `.gitignore_global` を変更して master に push すると自動ビルド。

## ローカルデバッグビルド

```bash
cd ~/dotfiles
docker build -t claude-devcontainer-debug -f .devcontainer/Dockerfile .
docker run --rm -it -v "$PWD:/workspace" -u ubuntu claude-devcontainer-debug bash -x /usr/local/bin/setup-claude.sh
docker run -it --env TMUX="$TMUX" --env TMUX_PANE="$TMUX_PANE" --env TERM=xterm-256color --env COLORTERM=truecolor claude-devcontainer-debug bash
```
