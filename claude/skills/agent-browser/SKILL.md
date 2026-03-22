---
name: agent-browser
description: AIエージェント向けブラウザ自動化CLI。ユーザーがWebサイトとのインタラクション（ページ遷移、フォーム入力、ボタンクリック、スクリーンショット取得、データ抽出、Webアプリのテスト、その他のブラウザタスクの自動化）を必要とする場合に使用する。トリガーとなるリクエスト例:「Webサイトを開いて」「フォームに入力して」「ボタンをクリックして」「スクリーンショットを撮って」「ページからデータを取得して」「このWebアプリをテストして」「サイトにログインして」「ブラウザ操作を自動化して」、またはプログラムによるWebインタラクションを必要とするあらゆるタスク。
allowed-tools: Bash(agent-browser:*)
---

# agent-browserによるブラウザ自動化

CLIはCDP経由でChrome/Chromiumを直接使用する。`npm i -g agent-browser`、`brew install agent-browser`、または`cargo install agent-browser`でインストール。`agent-browser install`でChromeをダウンロード。`agent-browser upgrade`で最新バージョンに更新。

## 基本ワークフロー

すべてのブラウザ自動化は以下のパターンに従う:

1. ナビゲート: `agent-browser open <url>`
2. スナップショット: `agent-browser snapshot -i`（`@e1`、`@e2`のような要素参照を取得）
3. インタラクト: 参照を使ってクリック、入力、選択
4. 再スナップショット: ナビゲーションやDOM変更後に新しい参照を取得

```bash
agent-browser open https://example.com/form
agent-browser snapshot -i
# 出力: @e1 [input type="email"], @e2 [input type="password"], @e3 [button] "Submit"

agent-browser fill @e1 "user@example.com"
agent-browser fill @e2 "password123"
agent-browser click @e3
agent-browser wait --load networkidle
agent-browser snapshot -i  # 結果を確認
```

## コマンドチェーン

コマンドは単一のシェル呼び出しで`&&`を使って連鎖できる。ブラウザはバックグラウンドデーモンを介してコマンド間で維持されるため、チェーンは安全かつ効率的。

```bash
# open + wait + snapshotを1回の呼び出しでチェーン
agent-browser open https://example.com && agent-browser wait --load networkidle && agent-browser snapshot -i

# 複数のインタラクションをチェーン
agent-browser fill @e1 "user@example.com" && agent-browser fill @e2 "password123" && agent-browser click @e3

# ナビゲートしてキャプチャ
agent-browser open https://example.com && agent-browser wait --load networkidle && agent-browser screenshot page.png
```

チェーンを使うタイミング: 中間コマンドの出力を読む必要がない場合に`&&`を使用（例: open + wait + screenshot）。出力を先にパースする必要がある場合は個別にコマンドを実行（例: snapshotで参照を取得してからインタラクト）。

## 認証の処理

ログインが必要なサイトを自動化する場合、状況に応じたアプローチを選択:

Option 1: ユーザーのブラウザから認証をインポート（単発タスクに最速）

```bash
# ユーザーの実行中のChromeに接続（既にログイン済み）
agent-browser --auto-connect state save ./auth.json
# その認証状態を使用
agent-browser --state ./auth.json open https://app.example.com/dashboard
```

状態ファイルにはセッショントークンが平文で含まれる -- `.gitignore`に追加し、不要になったら削除すること。暗号化には`AGENT_BROWSER_ENCRYPTION_KEY`を設定。

Option 2: 永続プロファイル（繰り返しタスクに最もシンプル）

```bash
# 初回: 手動またはオートメーションでログイン
agent-browser --profile ~/.myapp open https://app.example.com/login
# ... 認証情報を入力、送信 ...

# 以降のすべての実行: 既に認証済み
agent-browser --profile ~/.myapp open https://app.example.com/dashboard
```

Option 3: セッション名（Cookie + localStorageを自動保存/復元）

```bash
agent-browser --session-name myapp open https://app.example.com/login
# ... ログインフロー ...
agent-browser close  # 状態が自動保存

# 次回: 状態が自動復元
agent-browser --session-name myapp open https://app.example.com/dashboard
```

Option 4: 認証ボールト（認証情報を暗号化保存、名前でログイン）

```bash
echo "$PASSWORD" | agent-browser auth save myapp --url https://app.example.com/login --username user --password-stdin
agent-browser auth login myapp
```

`auth login`は`load`で遷移した後、ログインフォームのセレクターが表示されるまで待機してから入力/クリックするため、遅延するSPAログイン画面でもより確実に動作する。

Option 5: 状態ファイル（手動保存/読み込み）

```bash
# ログイン後:
agent-browser state save ./auth.json
# 将来のセッションで:
agent-browser state load ./auth.json
agent-browser open https://app.example.com/dashboard
```

OAuth、2FA、Cookie認証、トークンリフレッシュのパターンについては[references/authentication.md](references/authentication.md)を参照。

## 主要コマンド

```bash
# ナビゲーション
agent-browser open <url>              # 遷移（エイリアス: goto, navigate）
agent-browser close                   # ブラウザを閉じる

# スナップショット
agent-browser snapshot -i             # インタラクティブ要素と参照を取得（推奨）
agent-browser snapshot -i -C          # カーソルインタラクティブ要素も含む（onclick付きdiv、cursor:pointerなど）
agent-browser snapshot -s "#selector" # CSSセレクターでスコープを限定

# インタラクション（snapshotの@refを使用）
agent-browser click @e1               # 要素をクリック
agent-browser click @e1 --new-tab     # クリックして新しいタブで開く
agent-browser fill @e2 "text"         # クリアしてテキストを入力
agent-browser type @e2 "text"         # クリアせずにタイプ
agent-browser select @e1 "option"     # ドロップダウンの選択肢を選択
agent-browser check @e1               # チェックボックスをチェック
agent-browser press Enter             # キーを押す
agent-browser keyboard type "text"    # 現在のフォーカスにタイプ（セレクター不要）
agent-browser keyboard inserttext "text"  # キーイベントなしで挿入
agent-browser scroll down 500         # ページをスクロール
agent-browser scroll down 500 --selector "div.content"  # 特定のコンテナ内をスクロール

# 情報の取得
agent-browser get text @e1            # 要素のテキストを取得
agent-browser get url                 # 現在のURLを取得
agent-browser get title               # ページタイトルを取得
agent-browser get cdp-url             # CDP WebSocket URLを取得

# 待機
agent-browser wait @e1                # 要素を待機
agent-browser wait --load networkidle # ネットワークアイドルを待機
agent-browser wait --url "**/page"    # URLパターンを待機
agent-browser wait 2000               # ミリ秒待機
agent-browser wait --text "Welcome"    # テキストの表示を待機（部分一致）
agent-browser wait --fn "!document.body.innerText.includes('Loading...')"  # テキストの消滅を待機
agent-browser wait "#spinner" --state hidden  # 要素の非表示を待機

# ダウンロード
agent-browser download @e1 ./file.pdf          # 要素をクリックしてダウンロードを開始
agent-browser wait --download ./output.zip     # ダウンロード完了を待機
agent-browser --download-path ./downloads open <url>  # デフォルトのダウンロードディレクトリを設定

# ネットワーク
agent-browser network requests                 # 追跡中のリクエストを確認
agent-browser network route "**/api/*" --abort  # 一致するリクエストをブロック
agent-browser network har start                # HAR記録を開始
agent-browser network har stop ./capture.har   # HAR記録を停止して保存

# ビューポートとデバイスエミュレーション
agent-browser set viewport 1920 1080          # ビューポートサイズを設定（デフォルト: 1280x720）
agent-browser set viewport 1920 1080 2        # 2x Retina（同じCSSサイズ、高解像度スクリーンショット）
agent-browser set device "iPhone 14"          # デバイスをエミュレート（ビューポート + ユーザーエージェント）

# キャプチャ
agent-browser screenshot              # 一時ディレクトリにスクリーンショット
agent-browser screenshot --full       # フルページスクリーンショット
agent-browser screenshot --annotate   # 番号付きラベルで注釈付きスクリーンショット
agent-browser screenshot --screenshot-dir ./shots  # カスタムディレクトリに保存
agent-browser screenshot --screenshot-format jpeg --screenshot-quality 80
agent-browser pdf output.pdf          # PDFとして保存

# クリップボード
agent-browser clipboard read                      # クリップボードからテキストを読み取り
agent-browser clipboard write "Hello, World!"     # クリップボードにテキストを書き込み
agent-browser clipboard copy                      # 現在の選択をコピー
agent-browser clipboard paste                     # クリップボードから貼り付け

# 差分（ページ状態の比較）
agent-browser diff snapshot                          # 現在と最後のスナップショットを比較
agent-browser diff snapshot --baseline before.txt    # 現在と保存済みファイルを比較
agent-browser diff screenshot --baseline before.png  # ピクセル単位のビジュアル差分
agent-browser diff url <url1> <url2>                 # 2つのページを比較
agent-browser diff url <url1> <url2> --wait-until networkidle  # カスタム待機戦略
agent-browser diff url <url1> <url2> --selector "#main"  # 要素にスコープを限定
```

## バッチ実行

JSON配列の文字列配列を`batch`にパイプして、単一の呼び出しで複数のコマンドを実行。マルチステップワークフロー実行時のコマンドごとのプロセス起動オーバーヘッドを回避する。

```bash
echo '[
  ["open", "https://example.com"],
  ["snapshot", "-i"],
  ["click", "@e1"],
  ["screenshot", "result.png"]
]' | agent-browser batch --json

# 最初のエラーで停止
agent-browser batch --bail < commands.json
```

中間出力に依存しない既知のコマンドシーケンスがある場合に`batch`を使用。ステップ間で出力をパースする必要がある場合（例: snapshotで参照を取得してからインタラクト）は個別コマンドまたは`&&`チェーンを使用。

## 一般的なパターン

### フォーム送信

```bash
agent-browser open https://example.com/signup
agent-browser snapshot -i
agent-browser fill @e1 "Jane Doe"
agent-browser fill @e2 "jane@example.com"
agent-browser select @e3 "California"
agent-browser check @e4
agent-browser click @e5
agent-browser wait --load networkidle
```

### 認証ボールトによる認証（推奨）

```bash
# 認証情報を一度保存（AGENT_BROWSER_ENCRYPTION_KEYで暗号化）
# 推奨: シェル履歴への露出を避けるためstdinでパスワードをパイプ
echo "pass" | agent-browser auth save github --url https://github.com/login --username user --password-stdin

# 保存されたプロファイルでログイン（LLMにパスワードが見えない）
agent-browser auth login github

# プロファイルの一覧/表示/削除
agent-browser auth list
agent-browser auth show github
agent-browser auth delete github
```

`auth login`はusername/password/submitセレクターが表示されるまで待機し、タイムアウトはデフォルトのアクションタイムアウトに従う。

### 状態永続化による認証

```bash
# 一度ログインして状態を保存
agent-browser open https://app.example.com/login
agent-browser snapshot -i
agent-browser fill @e1 "$USERNAME"
agent-browser fill @e2 "$PASSWORD"
agent-browser click @e3
agent-browser wait --url "**/dashboard"
agent-browser state save auth.json

# 将来のセッションで再利用
agent-browser state load auth.json
agent-browser open https://app.example.com/dashboard
```

### セッション永続化

```bash
# ブラウザ再起動間でCookieとlocalStorageを自動保存/復元
agent-browser --session-name myapp open https://app.example.com/login
# ... ログインフロー ...
agent-browser close  # 状態が~/.agent-browser/sessions/に自動保存

# 次回、状態が自動ロード
agent-browser --session-name myapp open https://app.example.com/dashboard

# 保存状態を暗号化
export AGENT_BROWSER_ENCRYPTION_KEY=$(openssl rand -hex 32)
agent-browser --session-name secure open https://app.example.com

# 保存された状態を管理
agent-browser state list
agent-browser state show myapp-default.json
agent-browser state clear myapp
agent-browser state clean --older-than 7
```

### iframeの操作

iframeの内容はスナップショットで自動的にインライン化される。iframe内の参照はフレームコンテキストを保持しているため、直接操作できる。

```bash
agent-browser open https://example.com/checkout
agent-browser snapshot -i
# @e1 [heading] "Checkout"
# @e2 [Iframe] "payment-frame"
#   @e3 [input] "Card number"
#   @e4 [input] "Expiry"
#   @e5 [button] "Pay"

# 直接操作 -- フレーム切り替え不要
agent-browser fill @e3 "4111111111111111"
agent-browser fill @e4 "12/28"
agent-browser click @e5

# スナップショットを1つのiframeにスコープ:
agent-browser frame @e2
agent-browser snapshot -i         # iframeの内容のみ
agent-browser frame main          # メインフレームに戻る
```

### データ抽出

```bash
agent-browser open https://example.com/products
agent-browser snapshot -i
agent-browser get text @e5           # 特定の要素のテキストを取得
agent-browser get text body > page.txt  # ページ全体のテキストを取得

# パース用のJSON出力
agent-browser snapshot -i --json
agent-browser get text @e1 --json
```

### 並列セッション

```bash
agent-browser --session site1 open https://site-a.com
agent-browser --session site2 open https://site-b.com

agent-browser --session site1 snapshot -i
agent-browser --session site2 snapshot -i

agent-browser session list
```

### 既存のChromeに接続

```bash
# リモートデバッグが有効な実行中のChromeを自動検出
agent-browser --auto-connect open https://example.com
agent-browser --auto-connect snapshot

# 明示的なCDPポート指定
agent-browser --cdp 9222 snapshot
```

自動接続は`DevToolsActivePort`、一般的なデバッグポート（9222、9229）経由でChromeを検出し、HTTP経由のCDP検出が失敗した場合はWebSocket直接接続にフォールバックする。

### カラースキーム（ダークモード）

```bash
# フラグで永続的なダークモード（すべてのページと新しいタブに適用）
agent-browser --color-scheme dark open https://example.com

# または環境変数で
AGENT_BROWSER_COLOR_SCHEME=dark agent-browser open https://example.com

# またはセッション中に設定（以降のコマンドに持続）
agent-browser set media dark
```

### ビューポートとレスポンシブテスト

```bash
# カスタムビューポートサイズを設定（デフォルトは1280x720）
agent-browser set viewport 1920 1080
agent-browser screenshot desktop.png

# モバイル幅のレイアウトをテスト
agent-browser set viewport 375 812
agent-browser screenshot mobile.png

# Retina/HiDPI: 2倍ピクセル密度で同じCSSレイアウト
# スクリーンショットは論理ビューポートサイズのまま、コンテンツが高DPIでレンダリング
agent-browser set viewport 1920 1080 2
agent-browser screenshot retina.png

# デバイスエミュレーション（ビューポート + ユーザーエージェントを一括設定）
agent-browser set device "iPhone 14"
agent-browser screenshot device.png
```

`scale`パラメーター（第3引数）はCSSレイアウトを変えずに`window.devicePixelRatio`を設定する。Retinaレンダリングのテストや高解像度スクリーンショットの取得に使用。

### ビジュアルブラウザ（デバッグ）

```bash
agent-browser --headed open https://example.com
agent-browser highlight @e1          # 要素をハイライト
agent-browser inspect                # アクティブページのChrome DevToolsを開く
agent-browser record start demo.webm # セッションを録画
agent-browser profiler start         # Chrome DevToolsプロファイリングを開始
agent-browser profiler stop trace.json # プロファイリングを停止して保存（パスは省略可）
```

環境変数`AGENT_BROWSER_HEADED=1`でヘッド付きモードを有効化。ブラウザ拡張機能はヘッド付き/ヘッドレス両モードで動作する。

### ローカルファイル（PDF、HTML）

```bash
# file:// URLでローカルファイルを開く
agent-browser --allow-file-access open file:///path/to/document.pdf
agent-browser --allow-file-access open file:///path/to/page.html
agent-browser screenshot output.png
```

### iOSシミュレーター（モバイルSafari）

```bash
# 利用可能なiOSシミュレーターを一覧表示
agent-browser device list

# 特定のデバイスでSafariを起動
agent-browser -p ios --device "iPhone 16 Pro" open https://example.com

# デスクトップと同じワークフロー - スナップショット、操作、再スナップショット
agent-browser -p ios snapshot -i
agent-browser -p ios tap @e1          # タップ（clickのエイリアス）
agent-browser -p ios fill @e2 "text"
agent-browser -p ios swipe up         # モバイル固有のジェスチャー

# スクリーンショットを取得
agent-browser -p ios screenshot mobile.png

# セッションを閉じる（シミュレーターをシャットダウン）
agent-browser -p ios close
```

要件: Xcode付きmacOS、Appium（`npm install -g appium && appium driver install xcuitest`）

実デバイス: 事前設定済みの物理iOSデバイスでも動作。`xcrun xctrace list devices`で取得したUDIDを`--device "<UDID>"`で指定。

## セキュリティ

すべてのセキュリティ機能はオプトイン。デフォルトでは、agent-browserはナビゲーション、アクション、出力に制限を設けない。

### コンテンツ境界（AIエージェントに推奨）

`--content-boundaries`を有効にすると、ページ由来の出力をマーカーで囲み、LLMがツール出力と信頼できないページコンテンツを区別しやすくする:

```bash
export AGENT_BROWSER_CONTENT_BOUNDARIES=1
agent-browser snapshot
# 出力:
# --- AGENT_BROWSER_PAGE_CONTENT nonce=<hex> origin=https://example.com ---
# [accessibility tree]
# --- END_AGENT_BROWSER_PAGE_CONTENT nonce=<hex> ---
```

### ドメイン許可リスト

ナビゲーションを信頼できるドメインに制限。`*.example.com`のようなワイルドカードはベアドメイン`example.com`にもマッチする。許可されていないドメインへのサブリソースリクエスト、WebSocket、EventSource接続もブロックされる。対象ページが依存するCDNドメインも含めること:

```bash
export AGENT_BROWSER_ALLOWED_DOMAINS="example.com,*.example.com"
agent-browser open https://example.com        # OK
agent-browser open https://malicious.com       # ブロック
```

### アクションポリシー

ポリシーファイルを使って破壊的アクションを制御:

```bash
export AGENT_BROWSER_ACTION_POLICY=./policy.json
```

`policy.json`の例:

```json
{ "default": "deny", "allow": ["navigate", "snapshot", "click", "scroll", "wait", "get"] }
```

認証ボールト操作（`auth login`など）はアクションポリシーをバイパスするが、ドメイン許可リストは引き続き適用される。

### 出力制限

大きなページからのコンテキスト溢れを防止:

```bash
export AGENT_BROWSER_MAX_OUTPUT=50000
```

## 差分（変更の検証）

アクション実行後に`diff snapshot`を使って意図した効果があったか検証する。セッション中に最後に取得したスナップショットと現在のアクセシビリティツリーを比較する。

```bash
# 典型的なワークフロー: スナップショット -> アクション -> 差分
agent-browser snapshot -i          # ベースラインのスナップショットを取得
agent-browser click @e2            # アクションを実行
agent-browser diff snapshot        # 変更点を確認（最後のスナップショットと自動比較）
```

ビジュアルリグレッションテストやモニタリング:

```bash
# ベースラインのスクリーンショットを保存し、後で比較
agent-browser screenshot baseline.png
# ... 時間経過または変更が行われる ...
agent-browser diff screenshot --baseline baseline.png

# ステージングとプロダクションの比較
agent-browser diff url https://staging.example.com https://prod.example.com --screenshot
```

`diff snapshot`の出力は追加に`+`、削除に`-`を使用し、git diffと同様の形式。`diff screenshot`は変更されたピクセルを赤でハイライトした差分画像と不一致パーセンテージを生成する。

## タイムアウトと遅いページ

デフォルトのタイムアウトは25秒。環境変数`AGENT_BROWSER_DEFAULT_TIMEOUT`で上書き可能（ミリ秒単位）。遅いWebサイトや大きなページでは、デフォルトタイムアウトに依存せず明示的な待機を使用:

```bash
# ネットワーク活動が落ち着くのを待機（遅いページに最適）
agent-browser wait --load networkidle

# 特定の要素の表示を待機
agent-browser wait "#content"
agent-browser wait @e1

# 特定のURLパターンを待機（リダイレクト後に有用）
agent-browser wait --url "**/dashboard"

# JavaScript条件を待機
agent-browser wait --fn "document.readyState === 'complete'"

# 最終手段として固定時間を待機（ミリ秒）
agent-browser wait 5000
```

一貫して遅いWebサイトでは、`open`の後に`wait --load networkidle`を使ってページが完全に読み込まれてからスナップショットを取得する。特定の要素のレンダリングが遅い場合は、`wait <selector>`または`wait @ref`で直接待機する。

## セッション管理とクリーンアップ

複数のエージェントやオートメーションを同時実行する場合は、競合を避けるために必ず名前付きセッションを使用:

```bash
# 各エージェントが独自の分離されたセッションを取得
agent-browser --session agent1 open site-a.com
agent-browser --session agent2 open site-b.com

# アクティブなセッションを確認
agent-browser session list
```

終了時は必ずブラウザセッションを閉じてプロセスリークを防止:

```bash
agent-browser close                    # デフォルトセッションを閉じる
agent-browser --session agent1 close   # 特定のセッションを閉じる
```

前回のセッションが正常に閉じられなかった場合、デーモンがまだ実行中の可能性がある。新しい作業を始める前に`agent-browser close`でクリーンアップ。

非アクティブ期間後にデーモンを自動シャットダウン（一時的/CI環境に有用）:

```bash
AGENT_BROWSER_IDLE_TIMEOUT_MS=60000 agent-browser open example.com
```

## 参照のライフサイクル（重要）

参照（`@e1`、`@e2`など）はページ変更時に無効化される。以下の後は必ず再スナップショット:

- リンクやボタンのクリックによるナビゲーション
- フォーム送信
- 動的コンテンツの読み込み（ドロップダウン、モーダル）

```bash
agent-browser click @e5              # 新しいページに遷移
agent-browser snapshot -i            # 必ず再スナップショット
agent-browser click @e1              # 新しい参照を使用
```

## 注釈付きスクリーンショット（ビジョンモード）

`--annotate`を使って、インタラクティブ要素に番号付きラベルをオーバーレイしたスクリーンショットを取得。各ラベル`[N]`は参照`@eN`に対応する。参照もキャッシュされるため、別途スナップショットを取らずにすぐ要素を操作できる。

```bash
agent-browser screenshot --annotate
# 出力には画像パスと凡例が含まれる:
#   [1] @e1 button "Submit"
#   [2] @e2 link "Home"
#   [3] @e3 textbox "Email"
agent-browser click @e2              # 注釈付きスクリーンショットの参照でクリック
```

注釈付きスクリーンショットを使うケース:

- ラベルなしのアイコンボタンやビジュアルのみの要素がある場合
- ビジュアルレイアウトやスタイリングの確認が必要な場合
- Canvas要素やチャート要素がある場合（テキストスナップショットでは見えない）
- 要素の位置についての空間的推論が必要な場合

## セマンティックロケーター（参照の代替）

参照が利用できない、または信頼できない場合にセマンティックロケーターを使用:

```bash
agent-browser find text "Sign In" click
agent-browser find label "Email" fill "user@test.com"
agent-browser find role button click --name "Submit"
agent-browser find placeholder "Search" type "query"
agent-browser find testid "submit-btn" click
```

## JavaScript実行（eval）

`eval`でブラウザコンテキストでJavaScriptを実行。シェルのクォートが複雑な式を壊す可能性があるため、`--stdin`または`-b`を使って回避。

```bash
# シンプルな式は通常のクォートで動作
agent-browser eval 'document.title'
agent-browser eval 'document.querySelectorAll("img").length'

# 複雑なJS: --stdinとヒアドキュメントを使用（推奨）
agent-browser eval --stdin <<'EVALEOF'
JSON.stringify(
  Array.from(document.querySelectorAll("img"))
    .filter(i => !i.alt)
    .map(i => ({ src: i.src.split("/").pop(), width: i.width }))
)
EVALEOF

# 代替: base64エンコード（すべてのシェルエスケープ問題を回避）
agent-browser eval -b "$(echo -n 'Array.from(document.querySelectorAll("a")).map(a => a.href)' | base64)"
```

重要な理由: シェルがコマンドを処理する際、内側のダブルクォート、`!`文字（ヒストリ展開）、バッククォート、`$()`がJavaScriptをagent-browserに渡す前に壊す可能性がある。`--stdin`と`-b`フラグはシェルの解釈を完全にバイパスする。

経験則:

- 1行、ネストされたクォートなし -> シングルクォートの通常の`eval 'expression'`で問題なし
- ネストされたクォート、アロー関数、テンプレートリテラル、または複数行 -> `eval --stdin <<'EVALEOF'`を使用
- プログラム生成/自動生成スクリプト -> `eval -b`でbase64を使用

## 設定ファイル

プロジェクトルートに`agent-browser.json`を作成して永続設定:

```json
{
  "headed": true,
  "proxy": "http://localhost:8080",
  "profile": "./browser-data"
}
```

優先順位（低い順）: `~/.agent-browser/config.json` < `./agent-browser.json` < 環境変数 < CLIフラグ。`--config <path>`または`AGENT_BROWSER_CONFIG`環境変数でカスタム設定ファイルを指定（存在しないまたは無効な場合はエラーで終了）。すべてのCLIオプションはキャメルケースのキーに対応（例: `--executable-path` -> `"executablePath"`）。ブールフラグは`true`/`false`値を受け付ける（例: `--headed false`で設定を上書き）。ユーザー設定とプロジェクト設定の拡張機能はマージされ、置き換えられない。

## 詳細ドキュメント

| リファレンス | 使用場面 |
| --- | --- |
| [references/commands.md](references/commands.md) | すべてのオプション付き完全コマンドリファレンス |
| [references/snapshot-refs.md](references/snapshot-refs.md) | 参照のライフサイクル、無効化ルール、トラブルシューティング |
| [references/session-management.md](references/session-management.md) | 並列セッション、状態永続化、同時スクレイピング |
| [references/authentication.md](references/authentication.md) | ログインフロー、OAuth、2FA処理、状態の再利用 |
| [references/video-recording.md](references/video-recording.md) | デバッグとドキュメント用のワークフロー録画 |
| [references/profiling.md](references/profiling.md) | パフォーマンス分析のためのChrome DevToolsプロファイリング |
| [references/proxy-support.md](references/proxy-support.md) | プロキシ設定、地域テスト、ローテーションプロキシ |

## ブラウザエンジンの選択

`--engine`でローカルブラウザエンジンを選択。デフォルトは`chrome`。

```bash
# Lightpandaを使用（高速ヘッドレスブラウザ、別途インストールが必要）
agent-browser --engine lightpanda open example.com

# 環境変数で指定
export AGENT_BROWSER_ENGINE=lightpanda
agent-browser open example.com

# カスタムバイナリパスを指定
agent-browser --engine lightpanda --executable-path /path/to/lightpanda open example.com
```

サポートされているエンジン:
- `chrome`（デフォルト）-- CDP経由のChrome/Chromium
- `lightpanda` -- CDP経由のLightpandaヘッドレスブラウザ（Chromeの10倍高速、メモリ10分の1）

Lightpandaは`--extension`、`--profile`、`--state`、`--allow-file-access`をサポートしない。Lightpandaのインストールはhttps://lightpanda.io/docs/open-source/installationを参照。

## すぐに使えるテンプレート

| テンプレート | 説明 |
| --- | --- |
| [templates/form-automation.sh](templates/form-automation.sh) | バリデーション付きフォーム入力 |
| [templates/authenticated-session.sh](templates/authenticated-session.sh) | 一度ログインして状態を再利用 |
| [templates/capture-workflow.sh](templates/capture-workflow.sh) | スクリーンショット付きコンテンツ抽出 |

```bash
./templates/form-automation.sh https://example.com/form
./templates/authenticated-session.sh https://app.example.com/login
./templates/capture-workflow.sh https://example.com ./output
```
