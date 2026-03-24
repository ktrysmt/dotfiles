---
name: agent-browser
description: シンプルなブラウジング用。ログインセッション不要で、Webページの閲覧・データ抽出・スクリーンショット取得などを即座に実行できる。CDPポート接続なしで新規ブラウザを起動する。トリガー例:「このURLの内容を見て」「ページからデータを取得して」「スクリーンショットを撮って」「サイトの情報を調べて」。
allowed-tools: Bash(agent-browser:*)
---

# agent-browser (スタンドアロンモード)

agent-browserは軽量CLIベースのブラウザ自動化ツール。このスキルはCDP接続なしで新規ブラウザを起動する。
ログインセッションや既存ブラウザの状態が不要な、シンプルなブラウジングに使う。

## 基本ワークフロー

CDPポート指定なしで直接起動する。`--cdp`オプションは使わない。

```bash
# ページを開く（新規ブラウザが起動）
agent-browser open https://example.com

# インタラクティブ要素の参照を取得
agent-browser snapshot -i

# 参照を使って操作
agent-browser click @e1
agent-browser fill @e2 "text"

# ナビゲーション後は再度snapshot
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

## JavaScript実行

```bash
# シンプルな式
agent-browser eval 'document.title'

# 複雑なJS（シェルエスケープ回避）
agent-browser eval --stdin <<'EVALEOF'
JSON.stringify(Array.from(document.querySelectorAll("a")).map(a => a.href))
EVALEOF
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
