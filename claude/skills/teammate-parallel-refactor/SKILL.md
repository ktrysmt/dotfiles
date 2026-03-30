---
name: teammate-parallel-refactor
description: "Agent Teamsでディレクトリ分割して並列リファクタリング。「並列リファクタリング」「ディレクトリ分割でリファクタ」「strict移行」「並列でリファクタ」等のとき使用。"
argument-hint: "<refactoring instruction>"
---

# 並列コードリファクタリング

## 起動条件
ユーザーが「並列リファクタリング」「parallel refactor」「ディレクトリ分割でリファクタ」「strict移行」「並列でリファクタ」等と言ったとき。

## Layer 1: チーム設計

### タスク適格性チェック（必須）

以下を全て満たす場合のみAgent Teamsを使用する。1つでも未チェックなら単一エージェントで実行。

- [ ] 対象コードが2つ以上のディレクトリに分かれている
- [ ] 各ディレクトリの変更が独立（共有ファイルの変更が少ない）
- [ ] 変更の検証コマンドが明確（tsc, lint, test等）

### チーム構成

```
チーム名: refactor-team
サイズ: Lead + N（対象ディレクトリ数、最大4名）
トポロジー: Star型（Lead←→各Teammate）
```

### ディレクトリ分割ルール

1. ユーザー指定の対象ディレクトリをリストアップ
2. 依存関係を分析し、独立して変更可能な単位に分割
3. 共有ファイル（types/, config/, utils/shared等）をLeadの管理対象として分離
4. 各Teammateに排他的なディレクトリを割り当て

### CLAUDE.md 動的追記

チーム起動前に以下をプロジェクトの CLAUDE.md に追記する:

```markdown
# Refactoring Team Rules

## File Ownership
- {teammate-name}: {担当ディレクトリリスト}
  （各Teammateの行をN行生成）
- Shared (Lead only): {共有ファイルリスト}

## Verification
- Each teammate runs: {検証コマンド}
- Full suite: Lead runs after all teammates complete

## Communication
- Report: changed file list + verification result + breaking changes only
- Shared file changes: message Lead with proposed diff
```

## Layer 2: ロール設計

各Teammateのロール定義テンプレート:

```
Identity: refactor-{dirname}
担当: {ディレクトリ}内の全{対象ファイル拡張子}のリファクタリング
Goal: {リファクタリング内容}を完了し、検証コマンドをパスさせる
```

### 禁止事項（全Teammate共通、根拠: Kim et al. 2024）

- 他Teammateの担当ディレクトリを編集しない
- 共有ファイルを編集しない（変更提案はLeadにメッセージ）
- 依存パッケージの追加/削除をしない
- リファクタリング対象外のコードを変更しない

## Layer 3: Spawnプロンプトテンプレート

各Teammate起動時に以下のテンプレートで生成:

```
あなたは refactor-{dirname} です。リファクタリングチームのチームメイトとして、
{ディレクトリ}のリファクタリングを実行してください。

## タスク
{リファクタリング内容の具体的記述}

## 対象範囲
- 対象: {ディレクトリ/**/*.拡張子}
- 対象外: {他Teammateの担当ディレクトリ}
- 共有ファイル {共有ディレクトリ} は読取のみ。変更が必要な場合はLeadにメッセージ。

## 手順
1. {検証コマンド} でエラー一覧を取得（対象ディレクトリのみフィルタ）
2. エラーを上から順に修正
3. 修正後 {検証コマンド} で再検証
4. テスト実行: {テストコマンド -- --related}

## 受入基準
- [ ] 対象ディレクトリで {検証コマンド} がエラーゼロ
- [ ] {テストコマンド} が全パス
- [ ] {リファクタリング固有の品質基準}

## 禁止事項
- {他Teammateディレクトリ} を編集しない
- {共有ディレクトリ} を編集しない
- npm/pip等で依存追加しない

完了後、TaskUpdate で完了マーク + SendMessage で
変更ファイル一覧 + 検証結果 + 共有ファイル変更提案（あれば）をLeadに返却。
```

## 実行フロー

1. ユーザーからリファクタリング指示を受ける
2. 対象ディレクトリを確認し、分割計画を策定（Layer 1）
3. CLAUDE.md にファイルオーナーシップルールを追記
4. TeamCreate でチーム作成
5. 共有ファイルの変更が必要ならLeadが先に実施
6. 各Teammate を Layer 3 テンプレートで並列起動
7. 全Teammate完了後、Leadが統合検証（フルテストスイート）
8. 共有ファイル変更提案があればLeadが実施し再検証
9. チームメイトをシャットダウン
