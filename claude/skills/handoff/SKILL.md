---
name: handoff
description: >-
  Distill the CURRENT session into a restart brief that a fresh session can
  execute from: state and URLs, settled decisions, open tasks with a
  definition of done, touched files, the next concrete command, known dead
  ends, unverified assumptions, and a resume command. Saves to
  ~/.claude/handoffs/<date>-<slug>.md and ALSO prints the same body as a code
  block so it can be pasted straight into the next session. Every line must
  trace back to a tool result observed in this session; anything else is
  labelled unverified. Use when context is running low, when work moves to
  another session, machine, or person, or when a task is parked for later.
  Triggers: "申し送りを書いて", "引き継ぎを作って", "引き継ぎ資料をまとめて",
  "別セッションに委譲したい", "コンテキストが逼迫してきた",
  "続きは新しいセッションでやりたい", "HANDOVER", "BACKOFF", "handoff",
  "write a handover", "hand this off to a fresh session",
  "context is running out, summarize what the next session needs".
argument-hint: "[追加メモ] [--out <path>] [--stdout-only]"
---

<!-- NOTE: Do NOT add `context: fork` here. The input to this skill IS the current
     conversation history — what was decided, what was tried and failed, what is
     still open. A forked subagent has NO access to that history (per Claude Code
     docs), so it would produce an empty or hallucinated handoff and start hunting
     the filesystem for unrelated notes. Keep this skill running inline.
     Same reason the `canvas` skill carries this note. -->

Produce a restart brief: an instruction sheet the NEXT session reads to resume work
immediately. This is not a session log.

Distinct from the SessionEnd hook `~/.claude/hooks/session_summarizer.py`, which writes
a retrospective summary to `~/.claude/session-summaries/<repo>/<worktree>/` — that is a
record to read back later. A handoff is a forward-looking work order, written on
demand, optimized for a session that knows nothing.

## Input

`$ARGUMENTS`:

- Free text → an extra note from the user (a focus, a caveat, a task to emphasize).
  Fold it in; it does not replace what you observed in the conversation.
- `--out <path>` → write there instead of the default path.
- `--stdout-only` → write NO file; emit the code block only.
- Empty → cover the whole current session.

## Step 1 — Collect ground truth (run these; never recall from memory)

Run every command below in the session's working directory and use the literal
output. Do not reconstruct git or PR state from what you believe you did earlier.

```bash
date '+%Y-%m-%d'
pwd
git rev-parse --abbrev-ref HEAD
git rev-parse --show-toplevel
git status --porcelain
git diff --stat
git log --oneline -5
ls -1 ~/.claude/handoffs/ 2>/dev/null | tail -20
```

If a PR or Issue is in scope, re-fetch its state immediately before writing — PR
state is mutable and a stale `merged`/`open` misleads the next session:

```bash
gh pr view <number-or-branch> --json number,title,state,isDraft,updatedAt,url
```

Use `--paginate` on any `gh api` list endpoint you call.

## Step 2 — Slug and generation chain

Pick a short kebab-case `<slug>` naming the topic (`layered-arch-diagram`,
`pr-2812-followup`), not the date and not the repo alone.

Check the `ls ~/.claude/handoffs/` output for an existing handoff on the SAME topic.
If one exists, keep its slug and append the next generation number: `<slug>-2`,
`<slug>-3`. Record the previous file's absolute path in `## 状況`. A topic that ran
for four generations must read as one chain, not four unrelated files.

Default path: `~/.claude/handoffs/<YYYY-MM-DD>-<slug>.md`, using the date from
`date '+%Y-%m-%d'`. Run `mkdir -p ~/.claude/handoffs` before writing.

## Step 3 — Factuality gate (apply per line, before writing it)

- Every fact must trace to a tool result observed in THIS session. If it cannot,
  either move it to `## 未確認事項` or prefix it inline with `(未確認)`.
- Write "完了" only for items whose success output (test run, command exit, gh
  response) you actually saw this session. Otherwise it is an open task.
- Never infer file contents, branch names, PR numbers, or command results.
- Cite code as `path:line`. Wrap every URL in `<...>`, full URL, never shortened.
- The dead ends in `## 落とし穴・既知の失敗` are the highest-value section: they are
  the only part the next session cannot rediscover cheaply. Record what was tried,
  how it failed, and why — not just that it failed.

## Template — reproduce these headings, in this order

Delete any line whose value you do not have; do not emit empty placeholders. Keep the
headings exactly as written and write the prose in Japanese; paths, branch names,
commands, and command output stay verbatim.

````markdown
# Handoff: <topic> (gen <N>)
生成日: <date の実出力> / 対象: <一行の要約>

## 状況
- repo: <リポジトリ名> / worktree: <絶対パス>
- branch: <git rev-parse --abbrev-ref HEAD の実出力>
- HEAD: <git log --oneline -1 の実出力>
- PR: #<番号> <タイトル> state=<gh pr view の state> <URL>
- Issue / Confluence: <URL>
- 環境: <AWS アカウント / スタック / クラスタなど>
- 前世代: <前 handoff の絶対パス>

## 確定済みの決定
蒸し返し禁止。各項目に決めた理由を1行。
1. <決定> — 理由: <なぜそう決めたか>

## 未完タスク
優先度順。
1. <タスク> — 完了の定義: <観測可能な条件。「テストが通る」ではなく実行するコマンドと期待出力>

## 触ったファイル
- <path:line> — <何をどう変えたか1行>
- 未コミットの変更: <git status --porcelain の件数と代表パス、または「なし」>
- 警告: 未コミットの変更が残っている。次セッションは commit / stash / 破棄のどれを取るか先に決めること。
  <未コミットが無ければこの警告行ごと削除>

## 次の一手
1. <次セッションが最初に打つコマンドまたは操作>

## 落とし穴・既知の失敗
- <試した方法> → <どう失敗したか> → <理由 / 回避策>

## 未確認事項
検証していない仮説。確定事項と混ぜない。
- (未確認) <仮説> — 確かめ方: <コマンドまたは参照先>

## 再開コマンド
```bash
cd <worktree の絶対パス>
gh pr checkout <番号>   # または git checkout <branch>
<次の一手の1本目>
```
````

## Step 4 — Deliver

1. Unless `--stdout-only`, write the body to the resolved path with Write.
2. Print the SAME body to chat inside a fenced code block, so it can be copied into
   the next session in one action. The body itself contains a bash code fence, so the
   chat output must be wrapped in a four-backtick fence.
3. Close with a Japanese report of at most 3 lines: the absolute saved path, the
   generation number, and the count of open tasks plus unverified items. No emoji.

## Size limits

- The handoff body stays at or under 150 lines. It becomes the next session's
  initial context; a bloated one defeats the purpose. Verify with `wc -l`.
- No verbatim conversation quotes, no large code blocks. Point at `path:line`.
- Compress `## 触ったファイル` to the files that matter for resuming, not every file
  `git status` lists — but never drop the uncommitted-changes warning.

## Guardrails

- If the session produced nothing resumable (no decisions, no open tasks), say so in
  Japanese and write no file.
- Do not commit, push, stash, or clean anything while writing a handoff. Report the
  dirty state; the next session decides.
- Never invent a PR number, ticket ID, or URL to make a section look complete. A
  missing line is correct; a fabricated one costs the next session an hour.

