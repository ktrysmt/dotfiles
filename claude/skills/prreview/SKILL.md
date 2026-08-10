---
name: prreview
description: >-
  Run the standard 4-axis pull request review (security / technical
  inconsistency and docs alignment / robustness / operational cost) as one
  repeatable procedure instead of a hand-pasted prompt. Keeps a per-PR context
  cache under ~/.claude/pr-context so a re-review fetches only the incremental
  diff and the new comments, never the whole PR again, and never repeats a
  finding that was already raised, resolved, or accepted as a tradeoff. Fans
  the four axes out to four parallel agents, then verifies every candidate
  before reporting it: machine-checkable claims are reproduced with a command,
  interpretation-dependent ones go through a two-stage refutation that separates
  "the facts are wrong" from "true, but repo-wide rather than this PR's defect"
  so sound findings are not discarded for being out of scope. Never posts to
  GitHub unless explicitly told
  to. Triggers: "PRをレビューして", "これを以下の要領でレビューせよ",
  "/prreview", "レビュー観点4つで見て", "このPRの差分を見て指摘して",
  "前回の続きからレビューして", "review this PR", "re-review the PR".
argument-hint: "<PR URL|番号> [設計書URL...] [--fresh] [--no-cache]"
---

You execute a pull request review. `$ARGUMENTS` carries the PR (URL or number),
zero or more design-document URLs, and optional flags.

Follow the steps below literally and in order. Do not improvise a shorter path.
The expensive failure this skill exists to prevent is re-fetching a PR's entire
state from zero on every session and re-raising findings the author already
answered.

## Hard rules

- Read-only against GitHub by default. Allowed: `gh pr view`, `gh pr diff`,
  `gh api` GET, `git fetch`, `git diff`. Forbidden unless the user explicitly
  asks in this session: posting comments or reviews, approving, requesting
  changes, resolving threads, pushing, closing, merging, editing PR body or
  labels. Never run a destructive git or `gh` command.
- Evidence first. Every finding needs a primary source: the diff itself, a file
  in the repo cited as `path:line`, official documentation (use the aws-docs MCP
  for AWS behaviour), or a linked design document. Never fill a gap with
  inference and present it as fact. A finding you could not ground is not a
  finding.
- Every list-type `gh api` call carries `--paginate`. After any comment fetch,
  if the item count is an exact multiple of 30, treat it as a paginated
  truncation and refetch with `--paginate` before trusting it.
- Cite evidence URLs wrapped in `<...>` (full URL) and code locations as
  `path:line`.
- Repository-wide grep before any convention claim. The moment an argument rests
  on "this repo does / does not do X" — whether to support a finding or to refute
  one — the search must cover the whole repository, not the subtree you happen to
  be reading. Run it from the repository root (`git grep -n <pattern>` or
  `grep -rn <pattern> src/`) and report the hit count. A subtree-scoped search
  produces confidently wrong conventions: scanning only `src/polaris/*/README.md`
  found 1 file documenting deploy-order prerequisites and suggested "this repo
  does not document ordering", while the repository actually had 20 such files
  and the convention was the opposite. State the exact command and its count
  alongside the claim.
- The final report to the user is written in Japanese. No emojis anywhere, in
  this file's outputs or in anything posted.

## Arguments

| Token | Meaning |
|---|---|
| PR URL or number | Target PR. Optional; see Step 0. |
| Any other URL | Design document. Used for axis 2 (docs alignment). |
| `--fresh` | Ignore the existing cache, refetch everything, rebuild the cache. |
| `--no-cache` | Neither read nor write the cache for this run. |

## Step 0: Resolve the PR

1. If a PR URL or number is present in `$ARGUMENTS`, parse `owner`, `repo`,
   `number` from it.
2. Otherwise resolve from the current branch:
   `gh pr view --json number,url,state,headRefName`. Take `owner` and `repo`
   from the `url` field (`https://github.com/<owner>/<repo>/pull/<number>`),
   which is always the base repository. Never derive them from
   `headRepositoryOwner` / `headRepository`: on a fork PR those name the fork,
   and every `gh api repos/<owner>/<repo>/...` call below must target the base
   repository.
3. If that fails, stop. Ask the user for the PR number and do nothing else.
   Never guess a PR number, never review "the most recent PR".

## Step 1: Load the cache

Cache path: `~/.claude/pr-context/<owner>__<repo>__<number>.md`

It lives under HOME on purpose. Review work often happens inside a throwaway
worktree (`tmp-*`) that gets deleted, and a repo-local `.claude/` cache would
vanish with it and would dirty the repository.

1. `mkdir -p ~/.claude/pr-context`
2. With `--no-cache`: skip this step and Step 9 entirely.
3. With `--fresh`: ignore any existing file's contents, do the full fetch below,
   and rebuild the file at Step 9.
4. Otherwise Read the cache file if it exists. If it does not exist, this is a
   first review: full fetch.

## Cache schema

The cache file is exactly this Markdown structure. Keep the section headings and
the table columns unchanged so later runs can parse it.

```markdown
---
pr: <owner>/<repo>#<number>
title: <PR title>
state: <open|closed|merged>
base: <baseRefName>
head: <headRefName>
last_reviewed_head_sha: <full sha reviewed last time>
last_reviewed_at: <ISO 8601>
last_seen_review_id: <max id from pulls/<n>/reviews>
last_seen_issue_comment_id: <max id from issues/<n>/comments>
last_seen_review_comment_id: <max id from pulls/<n>/comments>
design_docs:
  - <URL>
---

## 既出の指摘

| id | file:line | 要旨(1行) | 観点 | status | 根拠URL | 提出 |
|---|---|---|---|---|---|---|
| F-001 | path/to/file.tf:42 | 平文の資格情報が state に載る | 1 | open | <https://...> | posted |

status vocabulary (fixed, do not invent new values):
- open — raised, not yet addressed
- resolved — fixed in a later commit
- withdrawn — retracted by us: the facts did not hold (Step 5a did not reproduce
  it, or Step 5b Stage 1 refuted it). Put the refuting evidence in 要旨.
- out-of-scope — the facts hold, but it is a repository-wide gap rather than a
  defect of this PR (Step 5b Stage 2). Never raise it on this PR again; it stays
  as a follow-up candidate. Put the repo-wide grep count in 要旨.
- accepted-tradeoff — the author deliberately chose this; never raise it again
- superseded — replaced by another finding; put the successor id in 要旨

提出 vocabulary (fixed): posted | pending

## 確定した設計判断

- <agreed decision, one line each, with the comment URL that settled it>

## 他レビュアの指摘

| reviewer | file:line | 要旨 | 我々の指摘との関係 | 統合結果 |
|---|---|---|---|---|
| @someone | path/to/file.go:88 | ... | F-003 と同旨 | F-003 を取り下げ |

## 未解決の疑問

- <question, and who owes the answer>
```

## Step 2: Incremental fetch protocol

1. Fetch the head state once, and only once:
   `gh pr view <number> --repo <owner>/<repo> --json number,title,state,headRefOid,baseRefName,headRefName,updatedAt,url`
2. Compare `headRefOid` with the cache's `last_reviewed_head_sha`.
   - Equal, and no comment newer than the `last_seen_*_id` values: report
     "前回レビュー時点から差分なし" together with the cache's open findings, and
     skip the full diff fetch entirely. Do not re-read the PR diff.
   - Different: fetch the PR head first, so the sha resolves locally even for a
     fork PR: `git fetch origin "pull/<number>/head"`. Then read only the
     incremental diff: `git diff <last_reviewed_head_sha>..<headRefOid>`. Use
     `gh pr diff <number>` (full diff) only on a first review or with `--fresh`.
   - `last_reviewed_head_sha` absent: first review, take the full diff.
   - History rewritten (force push). Check both conditions after the fetch
     above: the object is missing (`git cat-file -e <sha>^{commit}` fails), or
     it is no longer part of the branch's history
     (`git merge-base --is-ancestor <last_reviewed_head_sha> <headRefOid>` exits
     non-zero). Either one means the incremental diff would be wrong. Do not
     proceed silently: report
     "キャッシュの sha がリモートに存在しない（force push の可能性）" and fall
     back to a `--fresh` full fetch, keeping the 既出の指摘 table.
3. Fetch all three comment streams, always with `--paginate`:
   - `gh api --paginate repos/<owner>/<repo>/pulls/<number>/comments`
   - `gh api --paginate repos/<owner>/<repo>/issues/<number>/comments`
   - `gh api --paginate repos/<owner>/<repo>/pulls/<number>/reviews`
   Then apply the multiple-of-30 check from Hard rules.
4. Read only items whose `id` exceeds the matching `last_seen_*_id`. If the
   total across a stream is under 50, reading all of it is fine.
5. Any mismatch between the cache and reality other than the force-push case
   (PR retitled, state changed to merged, a cached finding pointing at a file
   that no longer exists) is reported to the user before the review continues.

## Step 3: The canonical review checklist

This is the contract. Do not paraphrase it away, do not drop axis 2's docs
alignment clause, do not renumber the axes.

```
観点
1. 安全性・情報漏洩・権限昇格・サプライチェーン・任意コード実行/リモートコード実行リスク
2. 技術的不整合・論理的矛盾・隠れた暗黙のトレードオフ・未決定トレードオフ、docsとの整合性
3. 堅牢性・可用性・レースコンディション
4. 運用工数・リソース効率

注意事項
* aws docs mcpなどエビデンスをフル活用し推論に頼らないファクトベースのレビューコメントとなるよう徹底すること
* 過去のコメントや差分遍歴を確認し、同じ指摘は行わないこと。
* 過去の指摘によりトレードオフとして任意の案をあえて選択している場合は改めてその点の指摘は行わない。ただし、わずかでも純粋技術的に指摘価値がある場合には指摘する。
* gh apiでリスト系エンドポイントを叩く際は必ず --paginate を付与せよ。コメント取得後、取得件数が30の倍数の場合はページネーション漏れを疑い、--paginate付きですべてのコメントを取得せよ。
```

## Step 4: Parallel fan-out — one agent per axis

Write the diff under review to a file first (for example
`<scratchpad>/pr-<number>-diff.patch`) so the agents read a path, not a pasted
blob. The deduplication context is the cache file itself
(`~/.claude/pr-context/<owner>__<repo>__<number>.md`) — pass that path. Do not
copy its 既出の指摘 / 確定した設計判断 / 他レビュアの指摘 sections into a second
scratchpad file. With `--no-cache` there is no dedup context, and the agents are
told so explicitly.

Fan the four axes out to four parallel workers, one per axis. `TeamCreate` with
one member per axis is the default: two or more parallel tasks must go through
Agent Teams, and `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is set in this
environment (`claude/settings.json`). Only if Agent Teams is unavailable, fall
back to four `Agent` (`subagent_type: general-purpose`) launches issued in a
single message.

Each worker's prompt carries, verbatim:

- PR identifier `<owner>/<repo>#<number>` and the head sha.
- The diff file path, and whether it is the full diff or an incremental diff
  between two shas.
- The cache file path as dedup context, plus this instruction: nothing listed
  under 既出の指摘 or 確定した設計判断 may be raised again; `accepted-tradeoff`
  entries are closed unless there is a purely technical residue worth stating,
  which must be labelled as such.
- The one axis it owns, quoted from Step 3.
- Design document URLs (axis 2 above all).
- "Ground every finding in a primary source — the aws-docs MCP for AWS
  behaviour, official documentation, or the repository's own code cited as
  path:line. Do not write anything you inferred. Read-only: never post to
  GitHub, never modify files."
- "If you argue from repository convention — that sibling stacks do or do not do
  something — grep the WHOLE repository from its root, not just the subtree under
  review, and report the command and the hit count. A subtree-scoped convention
  claim is treated as unsupported."
- "Mark each finding as 機械検証可能 or 解釈依存. 機械検証可能 means a command
  reproduces it deterministically (a linter that fails, a template that will not
  render, a value that differs between two files, a grep that returns zero) —
  state the exact command. 解釈依存 means it rests on reading documentation, a
  threat model, or a judgement about intent. Step 5 routes the two differently."

Each agent returns a list of findings in this shape, and nothing else:

```
- file:line — <path:line>
  severity — high|medium|low
  要旨 — <one line>
  根拠URL — <...>
  影響シナリオ — <concrete trigger or failure path>
```

## Step 5: Verification phase

No candidate reaches the report unverified. This phase is not optional; it is the
part of the review the user actually asks for. But do not spawn one refuter per
candidate blindly — twenty candidates would mean twenty agents, and for a large
share of them an agent is the weaker instrument. Route each candidate by the
機械検証可能 / 解釈依存 label it carried out of Step 4.

### Step 5a: Mechanical reproduction (for 機械検証可能 candidates)

Reproduce it yourself with a command. Do not delegate. A reproduction is stronger
evidence than any agent's reasoning, and it costs a fraction as much.

- Run the smallest command that settles the claim, and quote its real output and
  exit code in the report. Prefer an isolated reproduction over a full pipeline:
  a minimal synthetic template fed to the repo-pinned linter beats bundling the
  whole stack, and it cannot be confounded by unrelated errors.
- Never mutate the user's worktree to reproduce something. Extract the PR head
  into a scratch directory (`git archive <sha> <path> | tar -x -C <scratch>`) and
  work there. Never write into `dist/`, never check out a branch, never stash.
- Reproduced: the candidate is CONFIRMED. Record the exact command in the report
  so the author can re-run it.
- Did not reproduce: the candidate is REFUTED. Record it as `withdrawn` with the
  command and its output as the refuting evidence.
- The command cannot be run here (needs deployed AWS resources, credentials the
  session lacks, a vendor console): do not guess and do not silently keep it.
  Re-label the candidate 解釈依存 and send it through Step 5b instead.

Candidates that belong here in practice: a linter or validator that rejects the
template, a template that will not render with the shipped params, two files that
must agree and do not, a grep whose count contradicts the claim, a value that can
be computed from the diff.

### Step 5b: Two-stage refutation (for 解釈依存 candidates)

One independent worker per candidate. Two or more candidates means two or more
parallel tasks, so use `TeamCreate` with one member per candidate; a single
candidate may go to a single `Agent` call. Pass the candidate, the diff path, the
PR identifier, and the cache path.

The worker runs two stages in this order and reports them separately. Keeping
them separate is the point: a single blended verdict with "treat ambiguity as
refuted" folded in rejects sound findings for reasons that have nothing to do
with whether they are true. On a mature PR that bias silently eats almost
everything.

Stage 1 — refute the facts. "Attack the claim itself. Is the quoted
documentation real and does it say what the finding claims? Are the cited
`path:line` locations what the finding says they are? Does the causal chain hold,
or does some property in the template break it? Is the premise proven, or assumed?
If the evidence is ambiguous, or you cannot confirm the finding from a primary
source, the facts are REFUTED."

Stage 2 — runs only if the facts survived Stage 1. "The facts hold. Now judge
scope only: is this a defect introduced or left by THIS PR, or is it a
repository-wide gap and a hardening proposal that happens to be visible here?
Grep the whole repository (see Hard rules) to decide. Also check whether the
prior review already settled it."

Verdicts and what to do with each:

| Stage 1 | Stage 2 | Verdict | Action |
|---|---|---|---|
| refuted | not run | REFUTED | Drop. Cache as `withdrawn` with the refuting evidence, so no future run raises it. |
| survived | PR-specific | SURVIVES | Report it. Attach the refutation attempt's evidence to strengthen the write-up. |
| survived | repo-wide / already settled | OUT-OF-SCOPE | Do NOT drop. Cache as `out-of-scope` and report it under 別タスク候補 with the repo-wide count that put it there. |

A finding whose facts hold is never discarded merely for being broader than this
PR. That is a routing decision, not a refutation, and throwing it away loses real
work — the refuter has already established it is true.

Each worker returns exactly:

```
stage1_facts — REFUTED | SURVIVES
stage1_理由 — <2-4 lines, Japanese>
stage2_scope — PR固有 | リポジトリ横断 | 既決着 | 未実施
stage2_理由 — <2-4 lines, Japanese; include the repo-wide grep command and count>
verdict — REFUTED | SURVIVES | OUT-OF-SCOPE
決定的な証拠 — <path:line or <URL>, quoting the exact text relied on>
残余 — <narrower true point if any, else 無し>
```

Report honestly which attack angles failed. A refuter that confirms the quoted
documentation is verbatim real, or that the premise holds, has produced evidence
worth carrying into the write-up.

## Step 6: Deduplication

Match every surviving finding against the three cache sections: 既出の指摘,
確定した設計判断, 他レビュアの指摘. Match on `file:line` plus semantic
equivalence of the 要旨, not string equality — the same defect moves lines
between pushes.

- Matches an `open` entry: not new. Report it as a reminder in the 既出 section,
  do not restate it as a fresh finding.
- Matches `resolved` / `withdrawn` / `out-of-scope` / `accepted-tradeoff` / a
  確定した設計判断: suppress. The one exception is the canonical clause — if there
  is a genuine purely technical point left, raise it and say explicitly that it is
  being raised despite the accepted tradeoff, and why.
- Matches another reviewer's finding: merge them into one entry, credit the
  other reviewer, and drop ours if theirs is equivalent or stronger.

## Step 7: Report

Japanese. Open with the summary line, then one chapter per axis.

```
新規 N件 / 既出につき抑制 M件 / 反証により却下 K件 / 別タスク候補 S件
対象: <owner>/<repo>#<number> <head sha 短縮> (前回レビュー: <sha 短縮> / <日付>)
```

Then, per axis 1..4: each finding as `path:line`, severity, the point, the
evidence URL in `<...>`, and the concrete impact scenario. State how each was
verified — the reproduction command for a 機械検証可能 finding, or that it
survived two-stage refutation for a 解釈依存 one. Axes with nothing to report say
so in one line.

After the axes, two closing sections:

- 別タスク候補 — every `out-of-scope` finding from this run: the point, why it is
  repo-wide (with the grep command and count), and the suggested scope of the
  separate task. These are not noise; they are true findings deliberately not
  filed against this PR.
- 未解決の疑問 — including any candidate that could not be verified at all, named
  explicitly as 未検証 rather than folded in with the verified ones.

Close with the design-document alignment result.

Never claim you checked something you did not check. If an axis could not be
covered — no access to a service, documentation unavailable — say so instead of
producing a filler finding.

## Step 8: Posting (only on explicit instruction)

Do not post anything unless the user asked in this session. When asked:

- Summary comment: `gh pr comment <number> --repo <owner>/<repo> --body-file <file>`.
- Inline comments: `gh api` POST to `repos/<owner>/<repo>/pulls/<number>/comments`
  with path, line, side and the body.
- Show the user what will be posted before posting when the finding count
  exceeds 5.
- After posting, set 提出 to `posted` in the cache for each finding sent.

## Step 9: Write the cache back

Mandatory at the end of every run except `--no-cache`. Read the existing cache
file, then Edit it. Do not Write over it — a full overwrite has destroyed the
accumulated 既出の指摘 history. For a brand-new cache, Write once, then Edit
from then on.

Update: `last_reviewed_head_sha` to the head sha just reviewed,
`last_reviewed_at`, the three `last_seen_*_id` values, the status of every
existing finding (fixed in this push becomes `resolved`, facts refuted becomes
`withdrawn`, scope-only rejection becomes `out-of-scope`), the new findings
appended with fresh ids, any new entries under 確定した設計判断 and
他レビュアの指摘, and 未解決の疑問.

Recording the rejections is the highest-value part of this step, not bookkeeping.
A `withdrawn` row with its refuting evidence is what stops the next run from
re-deriving the same wrong finding, and an `out-of-scope` row is what stops the
same true-but-broader point from being re-litigated on this PR every time.

Verify before and after: count the `| F-` rows and the `| @` rows, and confirm the
after-count is greater than or equal to the before-count. If any row disappeared,
the write destroyed history — restore it before continuing.

## Design documents

- A design-doc URL in `$ARGUMENTS` feeds axis 2's docs alignment judgement.
- Confluence URLs are read through the `light-confluence` skill. Never call
  `mcp__confluence__*` directly from this review.
- A design-doc PR (for example a coincheck-docs PR) is read with
  `gh pr diff` / `gh pr view` on that repository.
- When the alignment check needs to go deeper than "does the diff contradict the
  document", delegate it to the `spec-sync` skill and cite its result here.

