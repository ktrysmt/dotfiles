# change-review: PR mode

change-review's Step 0 sends you here when the target is a GitHub pull request.
Every rule in SKILL.md still applies. Steps 1, 2 and 2b below replace SKILL.md's
Step 2; Steps 8 and 9 run after SKILL.md's Step 7.

`<skill>` below is `~/.claude/skills/change-review`.

## GitHub rules

- Every list-type `gh api` call carries `--paginate`. After any comment fetch,
  if the item count is an exact multiple of 30, treat it as a paginated
  truncation and refetch with `--paginate` before trusting it.
- Diffs and comment streams are long output: write them to files under the work
  directory, as SKILL.md's Hard rules require, and read only the items you need.

## Cache layout

Everything lives under `~/.claude/pr-context/`, under HOME on purpose: review
work often happens inside a throwaway worktree (`tmp-*`) that gets deleted, and
a repo-local `.claude/` cache would vanish with it and would dirty the
repository.

| Path | Holds | Read by the main session |
|---|---|---|
| `<owner>__<repo>__<number>.md`, the cache file | The frontmatter, the `open` findings, 確定した設計判断, 他レビュアの指摘, 未解決の疑問 | In full, in Step 1 |
| `<owner>__<repo>__<number>.history/<run id>.md`, the history directory | One file per run: the rows that run closed, and its 修正の試行 rows. Written once, never edited | Never whole: by `grep -nF` per candidate (SKILL.md Step 6) and through `<skill>/scripts/cache_rows.py` |
| `_stats/<owner>__<repo>__<number>__<run id>.json` | One record per run (Step 9), the input of the light-depth threshold | Never: `<skill>/scripts/threshold.py` reads it |

The cache file stays small however many rounds a PR goes through, because a
row leaves it the moment it is closed. The history keeps every closed row, so
nothing is ever lost.

A row id resolves to its latest row: a row in a later history file (by file
name; run ids embed a UTC timestamp) replaces an earlier one, and a row in the
cache file replaces any history row. `cache_rows.py` applies this rule; use it
rather than reading rows yourself:

- `python3 -I <skill>/scripts/cache_rows.py <cache file> --status open` — the
  open findings, one JSON object per line.
- `... --trials` — the 修正の試行 rows.
- `... --count` — the number of distinct finding ids, trial ids and other
  reviewers' rows, for Step 9's check.

## Step 1: Load the cache

1. `mkdir -p ~/.claude/pr-context/_stats`
2. With `--no-cache`: skip this step and Step 9 entirely. The run is a first
   review.
3. With `--fresh`: do not read the cache, do the full fetch in Step 2, and run
   at full depth. Step 9 still writes back without losing any existing row.
4. Otherwise Read the cache file in full if it exists; it is the dedup context
   with its history directory (SKILL.md Step 4). If it does not exist, this is
   a first review: full fetch. Never Read the history directory whole.
5. Schema: a cache file whose frontmatter has `schema_version: 2` follows the
   schema below. One without it was written by an earlier version of this
   skill (v1): the file holds every row, closed ones included, possibly in
   sections outside the schema, and it has no history directory. Read it in
   full as it is; this run is at full depth (Step 2b), and Step 9 migrates it.

A run that read a cache in item 4 is a re-review. Every other run is a first
review.

## Cache schema (v2)

The cache file is exactly this Markdown structure. Keep the section headings and
the table columns unchanged so later runs can parse it.

```markdown
---
schema_version: 2
pr: <owner>/<repo>#<number>
title: <PR title>
state: <open|closed|merged>
base: <baseRefName>
head: <headRefName>
last_reviewed_head_sha: <full sha reviewed last time>
last_reviewed_base_sha: <merge-base of origin/<baseRefName> and that sha>
last_reviewed_at: <ISO 8601>
last_full_review_head_sha: <full sha of the last review run at full depth>
last_full_review_base_sha: <merge-base of origin/<baseRefName> and that sha>
last_seen_review_id: <max id from pulls/<n>/reviews>
last_seen_issue_comment_id: <max id from issues/<n>/comments>
last_seen_review_comment_id: <max id from pulls/<n>/comments>
design_docs:
  - <URL> | <version, Step 2b item 4>
---

## 既出の指摘

| id | file:line | 要旨(1行) | 観点 | severity | status | 根拠URL | 提出 |
|---|---|---|---|---|---|---|---|
| F-001 | path/to/file.tf:42 | 平文の資格情報が state に載る | 1 | high | open | <https://...> | posted |

## 確定した設計判断

- <agreed decision, one line each, with the comment URL that settled it>

## 他レビュアの指摘

| reviewer | file:line | 要旨 | 我々の指摘との関係 | 統合結果 |
|---|---|---|---|---|
| @someone | path/to/file.go:88 | ... | F-003 と同旨 | F-003 を取り下げ |

## 未解決の疑問

- <question, and who owes the answer>
```

The cache file's 既出の指摘 holds only `open` rows. A history file holds the
same 既出の指摘 table for the rows its run closed, and a 修正の試行 table:

```markdown
## 既出の指摘

| id | file:line | 要旨(1行) | 観点 | severity | status | 根拠URL | 提出 |
|---|---|---|---|---|---|---|---|

## 修正の試行

| trial | finding | 回数 | 判定 | 連鎖(1行) | 記録 |
|---|---|---|---|---|---|
| T-001 | F-002 | 1 | 修正案を直す | 修正で X の前提が崩れる。修正のレビューが副作用として指摘 | <results.json のパス> |
```

status vocabulary (fixed, do not invent new values):
- open — raised, not yet addressed. The only status in the cache file.
- resolved — fixed in a later commit
- withdrawn — retracted by us: the facts did not hold (Step 5a did not reproduce
  it, or Step 5b Stage 1 refuted it). Put the refuting evidence in 要旨.
- out-of-scope — the facts hold, but it is a repository-wide gap rather than a
  defect of this PR (Step 5b Stage 2). Never raise it on this PR again; it stays
  as a follow-up candidate. Put the repo-wide grep count in 要旨.
- nits — the facts hold and it belongs to this PR, but no harm occurs now, or
  the harm is negligible (SKILL.md Severity and Step 5c). It is not a finding:
  never fixed, and posted only on request (Step 8). Raise it again only when a
  later change makes the harm real, as a new finding. Put its nit line without
  `path:line`, `<指摘> / <否定理由>` (SKILL.md Step 7), in 要旨, and
  `論拠: <...> / 否定の根拠: <...>` in 根拠URL. A `nits` row whose 根拠URL lacks
  `否定の根拠:` was cached unverified by an earlier version of the skill; it
  suppresses nothing (SKILL.md Step 6).
- accepted-tradeoff — the author deliberately chose this; never raise it again
- superseded — replaced by another finding; put the successor id in 要旨

severity vocabulary (fixed): high | medium | low | nits, as SKILL.md Step 5c
rated it, or `?` for a row carried over from a v1 cache, which had no severity.

提出 vocabulary (fixed): posted | pending

修正の試行 判定 vocabulary (fixed): 残す | 修正案を直す | 人に返す
(lookahead.md Step L4). 回数 is 1 for every new row. Rows written by the
earlier, multi-round lookahead may hold a larger 回数 and the 判定 取り下げ,
設計の問題 or 未確認; keep them as they are. The 記録 path points into the
scratchpad and may be gone later; the 連鎖 cell is the durable record, so
write it so it stands on its own.

## Step 2: Fetch the change (incremental fetch protocol)

1. Fetch the head state once, and only once, into a file:
   `gh pr view <number> --repo <owner>/<repo> --json number,title,body,state,headRefOid,baseRefName,headRefName,updatedAt,url > <work dir>/pr.json`
   Read the fields this step needs from it with a command, for example `jq`.
   Save the body on its own as `<work dir>/pr-body.txt`; the context file points
   workers to it (SKILL.md Step 4).
2. Compare `headRefOid` with the cache's `last_reviewed_head_sha`.
   - Equal, and no comment newer than the `last_seen_*_id` values: report
     "前回レビュー時点から差分なし" together with the cache's open findings, and
     skip the full diff fetch entirely. Do not re-read the PR diff. Then,
     without `--fast`, take the open findings that are fixable on a re-review
     (severity high, medium or `?`) and have no 修正の試行 row
     (`cache_rows.py --status open` against `cache_rows.py --trials`). If
     there are any, write SKILL.md Step 4's context file and run SKILL.md
     Step 6b on exactly those, as with `trial:`; the lookahead's base is
     `headRefOid`, and its review of the fixes runs at full depth. Otherwise,
     or with `--fast`, go to Step 9. A `?` severity counts as fixable so that
     no high or medium finding from a v1 cache is skipped.
   - Different: fetch the PR head and the base branch first, so the shas
     resolve locally even for a fork PR:
     `git fetch origin "pull/<number>/head"` and
     `git fetch origin <baseRefName>`. Compute the new base,
     `git merge-base origin/<baseRefName> <headRefOid>`. Then check for a
     history rewrite (below), and write the diff under review to
     `<work dir>/diff.patch`:
     - A v2 cache:
       `sh <skill>/scripts/pr_interdiff.sh <last_reviewed_base_sha> <last_reviewed_head_sha> <new base> <headRefOid> <work dir>/diff.patch > <work dir>/diff.stat 2>&1; echo "exit=$?"`.
       Exit 0: the `mode=` value in `diff.stat` says whether it is an
       incremental diff (the base did not move) or an interdiff (the author
       took in the base branch, and the diff holds only the PR's own change).
       Exit 3: the PR's earlier change conflicts with the new base, so no
       PR-only diff exists; take the full diff below, and Step 2b runs at full
       depth. Exit 2: a commit is missing; treat it as a history rewrite.
     - A v1 cache, which has no `last_reviewed_base_sha`:
       `git diff <last_reviewed_head_sha>..<headRefOid> > <work dir>/diff.patch`.
       If the author took in the base branch, this diff carries the base
       branch's changes too; Step 2b runs at full depth anyway.
     - The full diff, on a first review, with `--fresh`, or after exit 3:
       `gh pr diff <number> --repo <owner>/<repo> > <work dir>/diff.patch`.
   - `last_reviewed_head_sha` absent: first review, take the full diff.
   - History rewritten (force push). Check both conditions after the fetch
     above: the object is missing (`git cat-file -e <sha>^{commit}` fails), or
     it is no longer part of the branch's history
     (`git merge-base --is-ancestor <last_reviewed_head_sha> <headRefOid>` exits
     non-zero). Either one means the incremental diff would be wrong. Do not
     proceed silently: report
     "キャッシュの sha がリモートに存在しない（force push の可能性）" and fall
     back to a `--fresh` full fetch, keeping every cached row.
3. Fetch all three comment streams, always with `--paginate`, each into its own
   file:
   - `gh api --paginate repos/<owner>/<repo>/pulls/<number>/comments > <work dir>/stream.review-comments.json`
   - `gh api --paginate repos/<owner>/<repo>/issues/<number>/comments > <work dir>/stream.issue-comments.json`
   - `gh api --paginate repos/<owner>/<repo>/pulls/<number>/reviews > <work dir>/stream.reviews.json`
   Then apply the multiple-of-30 check from the GitHub rules.
4. Read only items whose `id` exceeds the matching `last_seen_*_id`; select them
   from the stream files with a command rather than reading the files whole. If
   the total across a stream is under 50, reading all of it is fine.
5. Any mismatch between the cache and reality other than the force-push case
   (PR retitled, state changed to merged, a cached finding pointing at a file
   that no longer exists) is reported to the user before the review continues,
   and Step 2b runs at full depth.
6. Make the post-change state readable without touching the user's checkout:
   `git worktree add --detach <work dir>/tree <headRefOid>`. Workers read files
   there. List it in the report's closing with the removal command
   `git worktree remove <work dir>/tree` for the user to run.
7. On a first review there is no cache, so the dedup context is the comment
   streams from item 3. Combine them into `<work dir>/comments.json` and pass
   that path.

## Step 2b: Choose the depth

A re-review runs light when the cache can be trusted and the PR's own change
since the last full review is small; otherwise it runs at full depth. Light
depth means one axis worker for all four axes (SKILL.md Step 4), refuters in
batches (SKILL.md Step 5b), and the same for the lookahead's review of the fixes
(lookahead.md Steps L1b and L3). Whatever the depth, a re-review fixes only
high and medium findings (SKILL.md Step 4b).

Run the checks in this order; the first that fails makes the run full depth,
with that check as the reason. Light depth needs all of them.

1. Re-review: Step 1 read a cache, and neither `--fresh`, `--no-cache` nor
   `--full` was given.
2. Schema: the cache has `schema_version: 2`. A v1 cache records neither the
   base nor the last full review, so nothing below could be checked.
3. Continuity: no history rewrite and no mismatch in Step 2, and
   `pr_interdiff.sh` did not exit 3.
4. Design documents unchanged. Get the current version of every design
   document of this run — the URLs in the arguments, and those the cache
   lists — the way this table says, and compare each with the version the
   cache records. A URL the cache does not list, a changed version, and a
   version that cannot be determined all fail this check, because axis 2
   judged the last full review against the documents as they were then.

   | Design document | Version | Command |
   |---|---|---|
   | Confluence page | The page's version number | The `light-confluence` skill, asked for the page's version number only |
   | GitHub pull request | Its head sha | `gh pr view <URL> --json headRefOid -q .headRefOid` |
   | GitHub file (`/blob/<ref>/<path>`) | The file's blob sha | `gh api 'repos/<owner>/<repo>/contents/<path>?ref=<ref>' -q .sha` |
   | Anything else | `unknown` | None |

   Get the versions on a first review too, so that Step 9 records them.
5. Small change since the last full review:
   - The threshold:
     `python3 -I <skill>/scripts/threshold.py ~/.claude/pr-context/_stats`.
     A threshold of -1 fails this check.
   - The PR's own change since the last full review:
     `sh <skill>/scripts/pr_interdiff.sh <last_full_review_base_sha> <last_full_review_head_sha> <new base> <headRefOid> <work dir>/cumulative.patch > <work dir>/cumulative.stat 2>&1; echo "exit=$?"`.
     It passes when the exit is 0 and its `lines` is at most the threshold.
   The change is measured from the last full review, not the last review, so
   that light runs never chain: a series of small pushes adds up, and the first
   run whose accumulated change exceeds the threshold is a full one.

Write `<work dir>/depth.json` with one `Write` call:
`{"depth": "light" | "full", "escalated": false, "reason": "<Japanese, one line>", "threshold": <T or null>, "cumulative_lines": <n or null>, "design_docs": [{"url", "version"}]}`.
The report's fourth line quotes the reason (SKILL.md Step 7).

A light run can still turn full. When its own findings break the statistic
behind the threshold — a high finding, or two or more findings — SKILL.md
Step 4b escalates it: the four per-axis workers join, and `depth.json` is
rewritten with `depth` full and `escalated` true. From then on the run is a
full run in every respect, Step 9 included.

## Step 8: Posting (only on explicit instruction)

Do not post anything unless the user asked in this session. When asked:

- Summary comment: `gh pr comment <number> --repo <owner>/<repo> --body-file <file>`.
- Inline comments: `gh api` POST to `repos/<owner>/<repo>/pulls/<number>/comments`
  with path, line, side and the body.
- A candidate rated nits (status `nits`) is left out when the user asks to
  post the findings or the review. Post a nit only when the user names it or
  asks for the nits. Tell the user how many nits were left out.
- Post a nit as its nit line and its two evidence lines (SKILL.md Step 7),
  and nothing else. As an inline comment, the body is
  `nits: <指摘> / <否定理由>` followed by the 論拠 and 否定の根拠 lines; the
  comment's position carries the `path:line`. In a summary comment, list the
  nits after the findings under the heading `nits`, each with its two
  evidence lines. A posted nit carries no impact scenario and no fix.
- Show the user what will be posted before posting when the finding count
  exceeds 5.
- After posting, set 提出 to `posted` for each finding and each nit sent: in the
  cache file for an open row; for a closed row, Step 9 writes the row again,
  with `posted`, into this run's history file.

## Step 9: Write the cache back

Mandatory at the end of every PR-mode run except `--no-cache`. Never overwrite
a history file, and never drop a row: a full overwrite of the cache once
destroyed the accumulated 既出の指摘 history.

1. Count before:
   `python3 -I <skill>/scripts/cache_rows.py <cache file> --count > <work dir>/count.before.json`.
   On a first review there is nothing to count.
2. Migration, only for a v1 cache:
   - Copy it first: `cp <cache file> <cache file without .md>.v1-<run id>.bak`.
   - Write `<history dir>/<run id>-migrated.md`: every row of the v1
     既出の指摘 table whose status is not `open`, under the v1 table header
     exactly as it was; every 修正の試行 row; and every section outside the
     schema (for example `## 提出状況`, `## 検証で棄却した候補 (再提起しないこと)`),
     verbatim, each under its own heading.
   - Then rewrite the cache file with one `Write` call (Step 1 read it in full)
     in the v2 schema: its open rows with the severity column (`?` unless this
     run rated the finding), 確定した設計判断, 他レビュアの指摘, 未解決の疑問.
3. This run's history file, `<history dir>/<run id>.md`, written once with one
   `Write` call, holding:
   - every row this run closes: an open row that this push fixed (`resolved`),
     and every new candidate that ended `withdrawn`, `out-of-scope` or `nits`;
   - every row whose latest version changes without leaving history: an
     unverified `nits` row that a candidate of this run matched (SKILL.md
     Step 6), with that candidate's outcome; a closed row posted in Step 8;
   - the 修正の試行 rows of this run's lookahead, one per candidate
     (lookahead.md Step L4).
   Leave out a section that would be empty, and the file when both are. A
   `--fast` run writes no 修正の試行 row, so a later run without `--fast` on the
   same head runs the lookahead on its fixable open findings (Step 2).
4. The cache file (v2), with `Edit`: set `last_reviewed_head_sha`,
   `last_reviewed_base_sha` (the new base of Step 2), `last_reviewed_at` and
   the three `last_seen_*_id` values; on a run at full depth, escalated runs
   included, also `last_full_review_head_sha` and `last_full_review_base_sha`; set
   `design_docs` to the versions of Step 2b item 4. Remove the rows that item 3
   moved to history, update the remaining open rows, append the new open
   findings with fresh ids and their severity, and add any new entries under
   確定した設計判断, 他レビュアの指摘 and 未解決の疑問. A brand-new cache is
   written once with `Write`, already in v2. A candidate dropped as 根拠不足
   (SKILL.md Step 4b) gets no row.
5. Count after, the same way, and compare with item 1 (on a migration, count
   the `.bak` copy as before). Each after-count must be greater than or equal
   to its before-count. If any is lower, the write lost rows: restore them from
   the history file, the `.bak` copy or the before-count's source before
   continuing.
6. Statistics, on every run that reached SKILL.md Step 4: write
   `~/.claude/pr-context/_stats/<owner>__<repo>__<number>__<run id>.json` with
   one `Write` call:

   ```json
   {"pr": "<owner>/<repo>#<number>", "run_id": "<run id>", "at": "<ISO 8601>",
    "review": "first | re-review", "depth": "full | light", "escalated": false,
    "workers": 4,
    "fast": false, "diff": "full | incremental | interdiff",
    "lines": 0, "files": 0, "cumulative_lines": null,
    "candidates": 0, "findings_total": 0,
    "findings": {"high": 0, "medium": 0, "low": 0},
    "nits": 0, "refuted": 0, "out_of_scope": 0, "suppressed": 0,
    "ungrounded": 0, "source": "run"}
   ```

   `depth` and `escalated` are the final values of `depth.json`. `workers` is
   1 at light depth, and 5 for an escalated run. An escalated run counts as
   full in `threshold.py`, so an escalation for two or more findings lowers the
   threshold. `lines` and `files` are the size of
   `diff.patch` (the `lines=` and `files=` values in `diff.stat`, or
   `git apply --numstat` on a full diff); `cumulative_lines` is Step 2b's measure, when it ran; `candidates` counts
   what the axis workers raised, before deduplication; `findings_total` and
   the counts after it are this run's summary line (SKILL.md Step 7), for the
   original review only, not the review of the fixes. `threshold.py` learns
   only from re-reviews at full depth, so every run's record matters: a full
   run above the threshold is what lets the threshold grow, and a full run at
   or below it that raised two or more findings lowers it.

Recording the rejections is the highest-value part of this step, not
bookkeeping. A `withdrawn` row with its refuting evidence is what stops the next
run from re-deriving the same wrong finding, and an `out-of-scope` row is what
stops the same true-but-broader point from being re-litigated on this PR every
time.
