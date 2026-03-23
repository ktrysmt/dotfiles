# Claude Code Channels - Discord セットアップ手順

## 概要

Channels は Claude Code セッションに外部イベント(チャット、Webhook、アラート等)をプッシュする MCP サーバーの仕組み。
Discord Bot 経由でスマホから Claude Code を操作できる。

- 公式ドキュメント: https://code.claude.com/docs/en/channels
- リファレンス: https://code.claude.com/docs/en/channels-reference
- プラグインソース: https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins/discord

## 前提条件

- Claude Code v2.1.80 以上
- Bun ランタイム
- claude.ai OAuth ログイン (API キー認証は不可)
- Research preview のため段階的ロールアウト中 (2026-03 時点)

## 手順

### 1. Discord Bot 作成

1. https://discord.com/developers/applications で **New Application**
2. **Bot** セクションでユーザー名設定 → **Reset Token** → トークンをコピー
3. **Privileged Gateway Intents** で **Message Content Intent** を有効化
4. **OAuth2 > URL Generator** で `bot` スコープを選択、以下の権限を付与:
   - View Channels
   - Send Messages
   - Send Messages in Threads
   - Read Message History
   - Attach Files
   - Add Reactions
5. 生成された URL で Bot をサーバーに招待

### 2. プラグインインストール

```
/plugin marketplace add anthropics/claude-plugins-official
/plugin marketplace update claude-plugins-official
/plugin install discord@claude-plugins-official
/reload-plugins
```

### 3. トークン設定

```
/discord:configure <Bot トークン>
```

`~/.claude/channels/discord/.env` に保存される。

### 4. チャネル有効で起動

```bash
claude --channels plugin:discord@claude-plugins-official
```

### 5. ペアリング

1. Discord で Bot に DM を送信 → Bot がペアリングコードを返す
2. Claude Code で承認:

```
/discord:access pair <コード>
```

3. allowlist にロックダウン:

```
/discord:access policy allowlist
```

## 現状 (2026-03-23)

- 手順 1-3 まで完了
- 手順 4 で **"Channels are not currently available"** となり停止
- `--dangerously-load-development-channels` でも同様
- Research preview の段階的ロールアウトがアカウントに到達していないのが原因
- クライアント側での回避手段はない
- ロールアウトを待って再試行する

## 再試行時の手順

Claude Code アップデート後に以下を実行するだけ:

```bash
claude --channels plugin:discord@claude-plugins-official
```

起動時に "Channels are not currently available" が出なくなれば、手順 5 (ペアリング) へ進む。
