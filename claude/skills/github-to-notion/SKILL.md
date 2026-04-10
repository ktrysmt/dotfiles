---
name: github-to-notion
description: "GitHub Issue/PRの情報をNotionの任意DBに起票する。「Notionに起票」「issueをNotionに転記」「PRをNotion登録」等のとき使用。Notion公式リモートMCP(notion-mcp-server)を利用する。"
argument-hint: "<issue/PR URL or number ...> [--db <database url|id|name>]"
allowed-tools: Bash(gh:*), mcp__notion__notion-search, mcp__notion__notion-fetch, mcp__notion__notion-create-pages, mcp__notion__notion-query-data-sources
disable-model-invocation: true
---

# GitHub to Notion 起票スキル (公式リモートMCP版)

GitHub Issue/PR の情報を、Notion 公式のリモート MCP サーバー経由で任意のデータベースに起票する。

## 前提: Notion 公式リモート MCP の登録

未登録の場合、ユーザーに以下のコマンドを案内する(自動実行はしない):

```bash
claude mcp add --transport http notion https://mcp.notion.com/mcp
```

その後 Claude Code 内で `/mcp` を実行し、OAuth フローで Notion ワークスペースを認証する。

確認:
- `/mcp` で `notion` サーバーが `connected` 状態であること
- 対象データベースが含まれるページ/チームスペースに対して MCP のアクセス許可が付与されていること

## 利用するMCPツール

公式 notion-mcp-server が提供するツールのうち本スキルで使うもの:

| ツール名 | 用途 |
|---|---|
| `mcp__notion__notion-search` | DB名から data source を検索 |
| `mcp__notion__notion-fetch` | DB のスキーマ/プロパティ取得 |
| `mcp__notion__notion-query-data-sources` | DB の既存ページ重複チェック(任意) |
| `mcp__notion__notion-create-pages` | DB に新規ページを作成 |

注: 新 MCP は Markdown ベースで動作する。ブロック構造を組み立てる必要はなく、本文は Markdown 文字列を渡すだけで良い。

## 入力パターン

ユーザーは以下のいずれかを指定する:

1. Issue URL: `https://github.com/owner/repo/issues/123`
2. PR URL: `https://github.com/owner/repo/pull/456`
3. Issue/PR 番号: `#123` (カレントリポジトリ)
4. 複数指定: `#123 #456 https://github.com/foo/bar/pull/7` (混在可)

オプション:
- `--db <database url|id|name>` -- 対象 DB。Notion の DB URL、data_source_id、または DB 名(部分一致検索)を受け付ける
- 省略時: 環境変数 `NOTION_DEFAULT_DB` (URL/ID/名前のいずれか) を参照。それも無ければユーザーに質問する

## 実行フロー

### Step 1: 入力パース

- ユーザー入力から `owner/repo`、番号、種別 (issue/PR) を特定
- カレントリポジトリ参照の場合: `gh repo view --json nameWithOwner -q .nameWithOwner`
- `--db` の値を取り出し、URL/ID/名前のいずれかを判定

### Step 2: GitHub 情報取得 (gh CLI)

並列実行可。複数指定があればまとめて取得する。

Issue:

```bash
gh issue view <number> --repo <owner/repo> \
  --json number,title,body,state,labels,assignees,url,createdAt,updatedAt,author,milestone
```

PR:

```bash
gh pr view <number> --repo <owner/repo> \
  --json number,title,body,state,labels,assignees,url,createdAt,updatedAt,author,baseRefName,headRefName,isDraft,reviewDecision,milestone,mergedAt
```

種別が不明な場合は先に `gh api repos/{owner}/{repo}/issues/{number}` を叩き、`pull_request` フィールドの有無で判定する。

### Step 3: Notion DB の解決

`--db` の値の種類で分岐:

(a) Notion DB URL の場合
- `mcp__notion__notion-fetch` に URL をそのまま渡す
- 戻り値からデータソース情報(data_source_id, properties)を取得

(b) data_source_id / database_id の場合
- `mcp__notion__notion-fetch` に ID を渡す

(c) DB 名(文字列)の場合
- `mcp__notion__notion-search` で `query: "<DB名>"`、`filter: { property: "object", value: "data_source" }` を指定して検索
- 候補が複数ある場合はユーザーに選択させる
- 確定したら `mcp__notion__notion-fetch` でスキーマを取得

### Step 4: プロパティマッピング

取得した DB スキーマ(`properties`)を読み、GitHub データを存在するプロパティのみにマッピングする。
ハードコードせず、毎回スキーマを参照すること。

典型的なマッピング:

| Notion Property Type | マッピング元 GitHub フィールド |
|---|---|
| title | `title` |
| url | `url` |
| select / status | `state` (OPEN/CLOSED/MERGED 等) |
| multi_select | `labels[].name` |
| people / multi_select | `assignees[].login` |
| date | `createdAt` (or `updatedAt`, `mergedAt`) |
| rich_text | `author.login`, `number`, `baseRefName -> headRefName` 等 |
| number | `number` |
| checkbox | `isDraft` (PRのみ) |

スキーマに存在しないプロパティはスキップする。
名前マッチが曖昧 (例: "Status" と "State" のどちらに state を入れるか) な場合はユーザーに確認する。

### Step 5: 重複チェック (任意)

同じ Issue/PR が既に起票されていないかを `mcp__notion__notion-query-data-sources` で確認する:
- フィルタ: URL プロパティ == GitHub URL、または title 部分一致
- 既存ページがあればユーザーに「上書き更新するか、新規作成するか、スキップするか」を確認

### Step 6: ページ作成

`mcp__notion__notion-create-pages` を呼び出す。
親には Step 3 で取得した data source / database の参照を指定する。

各ページの中身:
- `properties`: Step 4 でマッピングしたプロパティ
- `content`: 以下の Markdown 本文を渡す

```markdown
## 概要

{GitHub body の内容をそのまま Markdown として埋め込む}

## メタ情報

- 種別: Issue / Pull Request
- 状態: {state}
- 作成者: @{author.login}
- 作成日: {createdAt}
- ラベル: {labels join ", "}
- アサイニー: {assignees join ", "}
- マイルストーン: {milestone.title}
- (PR のみ) ブランチ: {headRefName} -> {baseRefName}
- (PR のみ) Draft: {isDraft}
- (PR のみ) レビュー: {reviewDecision}

## リンク

- [GitHub で開く]({url})
```

複数の Issue/PR が指定された場合、`notion-create-pages` は複数ページを一括作成できるので 1 リクエストにまとめる。

### Step 7: 結果報告

作成された各ページの Notion URL を一覧でユーザーに返す。重複チェックでスキップしたものがあれば併記する。

## エラーハンドリング

- `mcp__notion__*` ツールが未提供 -> Notion MCP が未登録/未認証。Step "前提" のセットアップ手順を案内
- `notion-fetch` で 401/403 -> Notion 側で対象ページへのアクセス許可がない。ワークスペース管理者に確認するよう案内
- `notion-create-pages` で validation エラー -> プロパティ名/型ミスマッチ。Step 4 のマッピングを再確認しリトライ
- `gh` 認証エラー -> `gh auth login` を案内
- レート制限 (180 req/min, search は 30 req/min) -> 並列処理を抑制してリトライ

## 注意事項

- 公式リモート MCP は OAuth でユーザーレベル認証されているため、Internal Integration Token を環境変数で扱う必要はない
- 本文は Markdown のままで良い。旧ローカル MCP のようにブロック JSON を組み立てる必要はない
- search ツールを使う場合は Notion AI プランが必要(無い場合はワークスペース内のみ検索可能)
- DB のスキーマや既存ページの内容を AI がそのまま読み取れるため、機密情報を含む DB を指定する際は注意
