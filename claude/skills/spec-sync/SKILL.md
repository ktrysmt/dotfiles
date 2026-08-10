---
name: spec-sync
description: >-
  Cross-check an implementation PR against its specification documents
  (Confluence pages, a docs-repository PR, or spec files in a repo) and report
  ONLY what is out of sync: present in the code but missing from the spec,
  present in the spec but missing from the code, and outright contradictions.
  Items that already agree are never listed. Read-only by default; `--apply`
  appends the missing items to the spec. All Confluence I/O is delegated to the
  light-confluence skill, never to mcp__confluence__* directly. Triggers:
  "仕様書と整合してる?", "仕様は整合したのか", "仕様書とも整合してるか",
  "仕様書の修正箇所は?", "仕様書はfixできた?", "コンフルの仕様に追記して",
  "詳細仕様への追記もやっといて", "この PR は仕様書に反映済み?", "/spec-sync",
  "spec-sync", "is this PR reflected in the spec", "sync the spec with this PR",
  "diff the implementation against the design doc".
argument-hint: "<PR URL|番号> <仕様書URL...> [--apply]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Skill
  - Bash(gh:*)
  - Bash(mkdir:*)
  - Bash(wc:*)
---

You reconcile an implementation PR with its specification documents and report
the delta. Follow the procedure below literally, in order. Do not improvise a
shorter path: the value of this skill is that every reported item is backed by
a quotation from one side and a `file:line` from the other, and shortcuts turn
it into guesswork.

Evidence first, always. You may only classify an item as out of sync when you
have read both sides in this session. Anything you could not read is `要確認`,
never a finding.

## Input contract

`$ARGUMENTS` is: `<PR URL|number> <spec URL...> [--apply]`

- First positional: the implementation PR. A full `github.com/<owner>/<repo>/pull/<n>`
  URL, or a bare number (then resolve the repo from the current working
  directory with `gh repo view --json nameWithOwner`).
- Remaining positionals: one or more specification sources (see the three
  source kinds below). Multiple sources are normal — a feature is often
  described in a Confluence page and a docs-repo PR at the same time.
- `--apply`: enable the write phase. Absent → read-only.

If the PR is missing, stop and ask for it. If NO spec source is given, do not
guess: list the candidate sources you can see (Confluence links in the PR body
or description, `docs/` paths touched by the PR, linked docs-repo PRs) and ask
which to use.

## Workspace

Run `mkdir -p /tmp/spec-sync/<slug>/` first, where `<slug>` is
`<repo>-pr<n>`. Every fetched body — PR diff, Confluence page markdown, docs
PR diff — is written to a file under that directory and read back selectively.
Never let a full page body or a full diff flow through the conversation when a
file will do.

## Confluence rule (hard)

All Confluence reads and writes go through the `light-confluence` skill. Never
call `mcp__confluence__*` from here: a raw page body is tens of thousands of
characters and would flood the main conversation, which is exactly what
light-confluence exists to prevent.

light-confluence runs in a forked context with NO conversation history, so a
call must carry everything it needs in one argument string:

- Read: `read <page URL> --out /tmp/spec-sync/<slug>/spec-<n>.md`
- Update: `update <page URL> --in /tmp/spec-sync/<slug>/append-<n>.md` plus a
  one-sentence statement of WHERE the content goes (the exact target heading)
  and that it is an append, not a replacement.

Read the returned `--out` file yourself with Read, and pull only the sections
that matter. Do not re-ask light-confluence for content you already have on
disk.

## Step 1 — Resolve every source

Classify each spec argument into exactly one of three kinds and record the
classification in your notes:

1. Confluence page — host matches `*.atlassian.net/wiki/spaces/...`.
   Read via light-confluence per the rule above.
2. Docs-repository PR — `github.com/<owner>/<repo>/pull/<n>` where the repo is
   a documentation repo (for this user, typically `coincheckjp/coincheck-docs`;
   PRs such as #477 / #751 / #754 / #758 there are design documents, not code).
   Read with `gh pr diff <n> --repo <owner>/<repo>` and
   `gh pr view <n> --repo <owner>/<repo> --json files,title,body,url`.
3. Repository file or blob URL — a path in the working tree, or a
   `github.com/<owner>/<repo>/blob/<ref>/<path>` URL.
   Read a local path with Read. Read a remote path as raw text in one step:
   `gh api -H "Accept: application/vnd.github.raw" "repos/<owner>/<repo>/contents/<path>?ref=<ref>" > /tmp/spec-sync/<slug>/spec-<n>.md`
   then Read that file. Do not fetch the base64 `.content` field — decoding it
   needs a tool this skill is not allowed to run.

Whenever you use `gh api` against a list endpoint (files, commits, comments,
search), pass `--paginate`. A truncated first page silently produces false
"未反映" findings.

## Step 2 — Read the implementation PR

1. `gh pr view <n> --json title,body,url,files,headRefName` — record the URL and
   the changed-file list.
2. `gh pr diff <n> > /tmp/spec-sync/<slug>/impl.diff`, then
   `wc -c /tmp/spec-sync/<slug>/impl.diff` to size it. Never paste the diff
   into the conversation to inspect it — Grep and Read the file.
3. If the diff is large (roughly over 150 KB, or over ~40 files), do not try to
   hold it all. Take the file list from step 1, order it by `additions +
   deletions` descending, and read the top files from the diff file with Grep /
   Read. Explicitly note in the final report which files you did NOT read —
   they cap the completeness of the audit.
4. Prioritise files that carry specification-visible behaviour: infrastructure
   definitions (Terraform, CloudFormation, CDK), API schemas and route
   definitions, DB migrations, configuration defaults, state machines,
   permission and retention settings, feature flags. Deprioritise test
   fixtures, lockfiles, generated code, formatting-only churn.

## Step 3 — Build the claim list

Convert the diff into a flat list of claims. Rules:

- One claim is exactly one factual statement about behaviour or configuration,
  written in one line. Example:
  `S3 バケットに Object Lock を COMPLIANCE モードで有効化（保持 7 年）`
- Every claim carries its evidence as `path:line` pointing at the PR's changed
  file. A claim without a `file:line` is not a claim — drop it or go read more.
- Refactors, renames of private symbols, dependency bumps with no behavioural
  change, and test-only edits are NOT claims. Skip them.
- Aim for a claim per meaningful behavioural change; a normal PR yields 5–30.

Write the claim list to `/tmp/spec-sync/<slug>/claims.md` before moving on, so
the later judging step works from a fixed list rather than from memory.

## Step 4 — Read the spec side

For each resolved spec source, build a section index (headings and their
content) from the file you saved in step 1. Keep the heading path for each
chunk — you will need it both to quote from and to name the insertion point for
`--apply`.

## Step 5 — Judge each claim (do not fill gaps by inference)

For every claim, search the spec sources for the corresponding statement and
assign exactly one verdict:

- 一致 — the spec states the same thing. Record it internally, then DROP it.
  Matching items are never printed.
- 齟齬 — the spec states something incompatible (different value, different
  mode, opposite behaviour). Requires a verbatim quotation from the spec plus
  the `file:line` from the implementation.
- 仕様書に未反映 — you read the relevant spec section and the statement is
  simply absent there.
- 要確認 — you could not read the relevant part, the wording is ambiguous, or
  you cannot point at the passage that would have carried it. If you cannot
  quote the spec location you checked, the verdict is `要確認`, not
  `仕様書に未反映`.

The line between `仕様書に未反映` and `要確認` is the integrity of this skill.
"I did not find it" is only a finding when you can name where you looked.

## Step 6 — Reverse direction

Walk the spec sources and collect statements that describe behaviour with no
counterpart in the PR diff. Each becomes an `実装に未反映` item, carrying the
spec heading or a quotation, plus the implementation-side file you would expect
to change. Where you have not read the whole repository (you usually have not),
state that the item may already exist outside this PR — say so instead of
asserting the code is missing.

## Step 7 — Report (Japanese)

Output in Japanese. No emoji. Start with a summary table of counts, then the
buckets in this fixed order. Wrap every URL in `<...>`. Reference implementation
locations as `path:line`.

```
## サマリ

| バケット | 件数 |
| --- | --- |
| 齟齬 | N |
| 仕様書に未反映 | N |
| 実装に未反映 | N |
| 要確認 | N |

対象PR: <https://github.com/.../pull/123>
仕様書: <https://....atlassian.net/wiki/spaces/...>, <https://github.com/.../pull/477>
読めなかった範囲: （あれば列挙。なければ「なし」）

## 齟齬（両方に記述があるが矛盾）

### 1. 要旨を1行で
- 実装: `path/to/file.tf:42` — 「実装側の記述を引用」
- 仕様: <ページURL> の「見出し名」 — 「仕様側の記述を引用」
- どちらが正かは判断しない。人が決める。

## 仕様書に未反映（実装が先行）

### 1. 要旨を1行で
- 実装: `path/to/file.tf:42`
- 追記先: <ページURL> の「見出し名」配下
- 追記文案:
  （2〜3行の日本語。そのまま貼れる文体で書く）

## 実装に未反映（仕様が先行）

### 1. 要旨を1行で
- 仕様: <ページURL> の「見出し名」 — 「該当箇所を引用」
- 想定変更箇所: `path/to/file.tf`（このPRの差分には見当たらない）

## 要確認

### 1. 要旨を1行で
- 判定できなかった理由（読めなかった / 記述が曖昧 / 該当セクション不明）
- 確認すべき場所: <URL> または `path`
```

Ordering rules:

- `齟齬` first — it is the only bucket where something is actively wrong.
- Within a bucket, order by blast radius: data retention, security, permissions,
  and external interfaces before internal details.
- Do not print a bucket's body when its count is 0; keep the row in the table.
- Never list matching items, and never pad the report with "問題ありません" lines.

## Write phase (`--apply` only)

Without `--apply`, you never modify a spec. Read and report, then stop.

With `--apply`:

1. Only the `仕様書に未反映` bucket is written. `齟齬` is NEVER auto-fixed —
   deciding which side is correct is a human call; report it and leave it.
   `実装に未反映` and `要確認` are also never written.
2. Confluence target: write the append body to
   `/tmp/spec-sync/<slug>/append-<n>.md` first, then invoke light-confluence
   with `update <page URL> --in <that path>` and the exact target heading.
   Never pass the body inline in the argument string — a large inline body has
   corrupted live pages before.
3. Docs-repository target: edit the file with Edit. Do NOT `git commit`, do NOT
   push, do NOT open a PR unless the user explicitly asks in this session.
4. After each write, report what changed as one line per item: target URL or
   `path:line`, and the heading the text landed under. If light-confluence
   reports a verification failure, surface it verbatim and stop writing.

## Guardrails

- Never state that the spec and the implementation agree on a point you did not
  read. Unread is `要確認`.
- Never rewrite or delete existing spec text under `--apply`; append only.
- Never invent a spec heading. If no suitable section exists, say so in the
  追記先 field and propose the new heading rather than creating it silently.
- If the PR is closed, merged, or has been force-pushed since you read it,
  re-run `gh pr view` before writing anything.

## Relation to prreview

Reviewing the implementation PR itself belongs to the `prreview` skill; this
skill only compares it against the spec, and prreview's "docs との整合性"
perspective may call it.

