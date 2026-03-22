---
name: agent-browser
description: ブラウザ操作の第一選択肢。軽量でコンテキスト効率が高いCLIベースのブラウザ自動化ツール。Webページの閲覧、フォーム入力、ボタンクリック、スクリーンショット取得、データ抽出、Webアプリテストなどに使用する。トリガー例:「Webサイトを開いて」「フォームに入力して」「ボタンをクリックして」「スクリーンショットを撮って」「ページからデータを取得して」「サイトにログインして」「ブラウザ操作を自動化して」。デザイン・CSS・レイアウトのデバッグにはchrome-devtools MCPに委譲すること。
allowed-tools: Bash(agent-browser:*), Bash(curl -s http://localhost:9222/json/version)
---

# agent-browser

agent-browserは軽量CLIベースのブラウザ自動化ツール。CDP経由でChrome/Chromiumを直接操作する。

## ツール選択の指針

agent-browserはプロセス起動が軽く、出力がテキストベースでコンテキストウィンドウに優しいため、ブラウザ操作が必要な場合はまずこれを試す。

| やりたいこと | 使うツール |
| --- | --- |
| ページ閲覧、操作、データ抽出、スクリーンショット | agent-browser（このスキル） |
| CSS/レイアウト/デザインのデバッグ、DOM検査、コンソール操作 | chrome-devtools MCP |
| E2Eテスト、複雑なブラウザシナリオ | Playwright MCP |

## 起動手順

スキルが呼び出されたら、操作の前に必ずブラウザへの接続確認を行う:

```bash
curl -s http://localhost:9222/json/version
```

結果に応じた対応:

- JSON応答あり -> ブラウザは起動済み。`--cdp 9222`で接続して操作を開始
- 接続拒否/タイムアウト -> ブラウザが未起動。`agent-browser open <url>`で新規起動

```bash
# 既存ブラウザに接続する場合
agent-browser --cdp 9222 snapshot -i

# 新規にブラウザを起動する場合
agent-browser open https://example.com
```

## 基本ワークフロー

1. `agent-browser open <url>` でページを開く
2. `agent-browser snapshot -i` でインタラクティブ要素の参照（`@e1`, `@e2`...）を取得
3. 参照を使って操作（click, fill, select）
4. ナビゲーションやDOM変更後は必ず再度 `snapshot -i`

```bash
agent-browser open https://example.com/form
agent-browser snapshot -i
# @e1 [input type="email"], @e2 [input type="password"], @e3 [button] "Submit"

agent-browser fill @e1 "user@example.com"
agent-browser fill @e2 "password123"
agent-browser click @e3
agent-browser wait --load networkidle
agent-browser snapshot -i
```

## 主要コマンド

```bash
# ナビゲーション
agent-browser open <url>
agent-browser close

# スナップショット（要素参照の取得）
agent-browser snapshot -i                # インタラクティブ要素（推奨）
agent-browser snapshot -i -C             # cursor:pointer要素も含む

# 操作（@refを使用）
agent-browser click @e1
agent-browser fill @e2 "text"            # クリアして入力
agent-browser type @e2 "text"            # クリアせず入力
agent-browser select @e1 "option"
agent-browser check @e1
agent-browser press Enter
agent-browser scroll down 500

# 情報取得
agent-browser get text @e1
agent-browser get url
agent-browser get title

# 待機
agent-browser wait @e1                   # 要素の出現
agent-browser wait --load networkidle    # ネットワークアイドル
agent-browser wait --url "**/page"       # URLパターン
agent-browser wait --text "Welcome"      # テキスト出現
agent-browser wait 2000                  # ミリ秒

# キャプチャ
agent-browser screenshot
agent-browser screenshot --full          # フルページ
agent-browser screenshot --annotate      # 番号付きラベル
agent-browser pdf output.pdf
```

## コマンドチェーン

中間出力を読む必要がない場合は`&&`で連結して効率化:

```bash
agent-browser open https://example.com && agent-browser wait --load networkidle && agent-browser snapshot -i
```

出力をパースしてから次の操作が必要な場合（例: snapshotで参照取得 -> 操作）は個別に実行。

## 参照のライフサイクル

参照（`@e1`等）はページ変更時に無効化される。以下の後は必ず`snapshot -i`で再取得:

- リンク/ボタンクリックによるナビゲーション
- フォーム送信
- 動的コンテンツ読み込み（ドロップダウン、モーダル）

## 認証

```bash
# セッション名で状態を自動保存/復元（推奨）
agent-browser --session-name myapp open https://app.example.com/login
# ... ログインフロー ...
agent-browser close
# 次回: 状態が自動復元
agent-browser --session-name myapp open https://app.example.com/dashboard

# 既存Chromeから認証をインポート
agent-browser --auto-connect state save ./auth.json
agent-browser --state ./auth.json open https://app.example.com/dashboard

# 状態の手動保存/読み込み
agent-browser state save auth.json
agent-browser state load auth.json
```

## セッション管理

```bash
# 並列セッション
agent-browser --session site1 open https://site-a.com
agent-browser --session site2 open https://site-b.com

# 終了時は必ずcloseしてプロセスリークを防止
agent-browser close
agent-browser --session site1 close
```

## JavaScript実行

```bash
# シンプルな式
agent-browser eval 'document.title'

# 複雑なJS（シェルエスケープ回避）
agent-browser eval --stdin <<'EVALEOF'
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
