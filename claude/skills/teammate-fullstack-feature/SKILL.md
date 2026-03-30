---
name: teammate-fullstack-feature
description: "Agent Teamsでバックエンド/フロントエンド/テストを並列実装するフルスタック機能開発ワークフロー。「フルスタックで実装」「API+UI並列で」「レイヤー分割で実装」等のとき使用。"
argument-hint: "<feature description>"
---

# フルスタック機能実装

## 起動条件
ユーザーが「フルスタックで実装」「API+UI」「バックエンドとフロントエンド並列で」「レイヤー分割で実装」等と言ったとき。API/UI/テストの並列実装に使用。

## Layer 1: チーム設計

### タスク適格性チェック（必須）

- [ ] 機能がバックエンド/フロントエンド/テスト等のレイヤーに分割可能
- [ ] 共有インターフェース（型定義、APIコントラクト）が事前に定義可能
- [ ] 各レイヤーの実装が独立（共有インターフェース以外の依存が少ない）

### チーム構成

```
チーム名: feature-team
サイズ: Lead + 2-3名（Backend / Frontend / Test）
トポロジー: Star型
```

### 実行Phase設計（cross-chunk依存の管理、根拠: Xu et al. 2025）

```
Phase A（Lead直接）: 共有インターフェースの定義
  → src/types/{feature}.ts, API仕様の策定
  → 全Teammateの実装の基盤

Phase B（並列）: Backend + Frontend を同時起動
  → 共有インターフェースを参照し、各レイヤーを独立実装

Phase C（逐次）: Test を起動（Phase B完了後）
  → Backend + Frontend の実装を前提としたE2E/統合テスト
```

Phase分割の理由: 型定義なしに並列実装すると、インターフェース不整合が発生し再実装コストが増大する。Leadが先にcontractを確定させることで、Phase B の並列性を保証する。

### CLAUDE.md 動的追記

```markdown
# {Feature} Team Rules

## File Ownership
- impl-backend: src/api/{feature}/, src/services/{feature}/, src/models/{feature}.ts
- impl-frontend: src/components/{feature}/, src/pages/{feature}/, src/hooks/use{Feature}.ts
- impl-test: tests/{feature}/
- Lead only: src/types/{feature}.ts, src/config/{feature}.ts

## Shared Contract
- src/types/{feature}.ts is the single source of truth
- All teammates: read this file FIRST before implementation
- Do NOT modify this file (Lead only)

## API Contract
（Leadが策定したAPIエンドポイント仕様をここに記載）
```

## Layer 2: ロール設計

### Backend

```
Identity: impl-backend
担当: APIエンドポイント + サービスロジック + DBモデル
Goal: src/types/{feature}.ts の型定義に準拠したバックエンド実装
制約: フロントエンド関連ファイルを編集しない
```

### Frontend

```
Identity: impl-frontend
担当: Reactコンポーネント + ページ + カスタムフック
Goal: src/types/{feature}.ts の型定義に準拠したフロントエンド実装
制約: バックエンド関連ファイルを編集しない
```

### Test（Phase C用）

```
Identity: impl-test
担当: E2Eテスト + 統合テスト
Goal: Backend + Frontend の実装を検証するテストを作成
制約: src/api/, src/components/ 等の実装コードを編集しない
```

## Layer 3: Spawnプロンプトテンプレート

### Backend用

```
あなたは impl-backend です。{Feature}のバックエンドAPIを実装してください。

## タスク
src/types/{feature}.ts で定義された型に基づき、
APIエンドポイントを実装する。

## 前提（Leadが作成済み）
- 型定義: src/types/{feature}.ts（必ず最初にReadすること）
- 設定: src/config/{feature}.ts
- API仕様:
  {APIエンドポイント一覧: メソッド、パス、リクエスト型、レスポンス型}

## 実装対象
{作成すべきファイル一覧}

## 手順
1. src/types/{feature}.ts を読み、型定義を確認
2. サービスロジックを実装
3. 各APIエンドポイントを実装
4. npx tsc --noEmit で型チェック

## 受入基準
- [ ] 全エンドポイントが src/types/{feature}.ts の型に準拠
- [ ] npx tsc --noEmit がエラーなし
- [ ] エラーハンドリング: 外部API失敗時に適切なHTTPステータスを返却
- [ ] 環境変数からの機密情報読取（ハードコードしない）

## 禁止事項
- src/components/, src/pages/, src/hooks/ を編集しない
- src/types/{feature}.ts を編集しない
- 依存パッケージを追加しない

完了後、SendMessage で実装ファイル一覧 + tsc結果をLeadに返却。
```

### Frontend用

```
あなたは impl-frontend です。{Feature}のフロントエンドUIを実装してください。

## タスク
src/types/{feature}.ts で定義された型に基づき、
{Feature}画面のReactコンポーネントを実装する。

## 前提
- 型定義: src/types/{feature}.ts（必ず最初にReadすること）
- UIライブラリ: 既存の src/components/ui/ を使用
- API呼び出し: src/lib/api.ts の既存fetchラッパーを使用

## 実装対象
{作成すべきファイル一覧}

## 受入基準
- [ ] 全コンポーネントが src/types/{feature}.ts の型に準拠
- [ ] npx tsc --noEmit がエラーなし
- [ ] ローディング/エラー/空状態の3ステートを処理
- [ ] 既存UIコンポーネントを再利用

## 禁止事項
- src/api/, src/services/, src/models/ を編集しない
- src/types/{feature}.ts を編集しない
- 新しいUIライブラリを導入しない

完了後、SendMessage で実装ファイル一覧 + tsc結果をLeadに返却。
```

## 実行フロー

1. ユーザーから機能実装指示を受ける
2. 機能要件を分析し、レイヤー分割計画を策定（Layer 1）
3. Phase A: Leadが共有インターフェース（型定義 + API仕様）を作成
4. CLAUDE.md にファイルオーナーシップ + API Contractを追記
5. TeamCreate でチーム作成
6. Phase B: Backend + Frontend を Layer 3 テンプレートで並列起動
7. Phase B 完了後、Leadが型整合性を確認
8. Phase C: Test Teammate を起動（必要な場合）
9. 全Teammate完了後、Leadが統合検証（tsc + フルテスト）
10. チームメイトをシャットダウン
