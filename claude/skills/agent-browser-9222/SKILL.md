---
name: agent-browser-9222
description: ユーザーの既存Chromeブラウザ（デバッグポート9222）に接続して操作する。ログイン済みセッション・Cookie・認証状態を引き継いだブラウザ操作が必要な場合に使う。トリガー例:「ログインした状態で操作して」「認証が必要なページを開いて」「今開いているブラウザで操作して」「セッションを使って」。
allowed-tools: Bash(agent-browser:*), Bash(curl -s http://localhost:9222/json/version)
---

# agent-browser-9222 (CDP接続モード)

agent-browserは軽量CLIベースのブラウザ自動化ツール。このスキルはCDPポート9222で起動済みのChromeに接続する。
ユーザーのログインセッション・Cookie・認証状態を引き継いで操作したい場合に使う。

## 起動手順

操作の前に必ずブラウザへの接続確認を行う:

```bash
curl -s http://localhost:9222/json/version
```

結果に応じた対応:

- JSON応答あり -> ブラウザは起動済み。`--cdp 9222`で接続して操作を開始
- 接続拒否/タイムアウト -> ブラウザがデバッグモードで起動していない。ユーザーに`--remote-debugging-port=9222`付きでChromeを起動するよう案内する

```bash
# 既存ブラウザに接続してスナップショット取得
agent-browser --cdp 9222 snapshot -i
```

## 基本ワークフロー

全てのコマンドに`--cdp 9222`を付与する。

```bash
# 接続確認
curl -s http://localhost:9222/json/version

# 現在のページ状態を確認
agent-browser --cdp 9222 snapshot -i

# ナビゲーション
agent-browser --cdp 9222 open https://example.com/dashboard

# 操作
agent-browser --cdp 9222 click @e1
agent-browser --cdp 9222 fill @e2 "text"

# ナビゲーション後は再度snapshot
agent-browser --cdp 9222 snapshot -i
```

## 主要コマンド

全てのコマンドに`--cdp 9222`を付与すること。

```bash
# ナビゲーション
agent-browser --cdp 9222 open <url>

# スナップショット（要素参照の取得）
agent-browser --cdp 9222 snapshot -i                # インタラクティブ要素（推奨）
agent-browser --cdp 9222 snapshot -i -C             # cursor:pointer要素も含む

# 操作（@refを使用）
agent-browser --cdp 9222 click @e1
agent-browser --cdp 9222 fill @e2 "text"            # クリアして入力
agent-browser --cdp 9222 type @e2 "text"            # クリアせず入力
agent-browser --cdp 9222 select @e1 "option"
agent-browser --cdp 9222 check @e1
agent-browser --cdp 9222 press Enter
agent-browser --cdp 9222 scroll down 500

# 情報取得
agent-browser --cdp 9222 get text @e1
agent-browser --cdp 9222 get url
agent-browser --cdp 9222 get title

# 待機
agent-browser --cdp 9222 wait @e1                   # 要素の出現
agent-browser --cdp 9222 wait --load networkidle    # ネットワークアイドル
agent-browser --cdp 9222 wait --url "**/page"       # URLパターン
agent-browser --cdp 9222 wait --text "Welcome"      # テキスト出現
agent-browser --cdp 9222 wait 2000                  # ミリ秒

# キャプチャ
agent-browser --cdp 9222 screenshot
agent-browser --cdp 9222 screenshot --full          # フルページ
agent-browser --cdp 9222 screenshot --annotate      # 番号付きラベル
agent-browser --cdp 9222 pdf output.pdf
```

## コマンドチェーン

```bash
agent-browser --cdp 9222 open https://example.com && agent-browser --cdp 9222 wait --load networkidle && agent-browser --cdp 9222 snapshot -i
```

## 参照のライフサイクル

参照（`@e1`等）はページ変更時に無効化される。以下の後は必ず`snapshot -i`で再取得:

- リンク/ボタンクリックによるナビゲーション
- フォーム送信
- 動的コンテンツ読み込み（ドロップダウン、モーダル）

## 認証状態の保存/復元

```bash
# 既存Chromeから認証をインポート
agent-browser --cdp 9222 state save ./auth.json

# 保存した状態を読み込み
agent-browser --state ./auth.json open https://app.example.com/dashboard
```

## JavaScript実行

```bash
# シンプルな式
agent-browser --cdp 9222 eval 'document.title'

# 複雑なJS（シェルエスケープ回避）
agent-browser --cdp 9222 eval --stdin <<'EVALEOF'
JSON.stringify(Array.from(document.querySelectorAll("a")).map(a => a.href))
EVALEOF
```

## セキュリティ

```bash
# コンテンツ境界（AIエージェント向け推奨）
export AGENT_BROWSER_CONTENT_BOUNDARIES=1

# ドメイン制限
export AGENT_BROWSER_ALLOWED_DOMAINS="example.com,*.example.com"

# 出力サイズ制限
export AGENT_BROWSER_MAX_OUTPUT=50000
```
