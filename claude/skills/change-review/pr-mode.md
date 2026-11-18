# change-review: PR mode

change-review's Step 0 sends you here when the target is a GitHub pull request.
Every rule in SKILL.md still applies. Steps 1 and 2 below replace SKILL.md's
Step 2; Steps 8 and 9 run after SKILL.md's Step 7.

## GitHub rules

- Every list-type `gh api` call carries `--paginate`. After any comment fetch,
  if the item count is an exact multiple of 30, treat it as a paginated
  truncation and refetch with `--paginate` before trusting it.
- Diffs and comment streams are long output: write them to files under the work
  directory, as SKILL.md's Hard rules require, and read only the items you need.

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
the table columns unchanged so later runs can parse it. A cache written before
the 修正の試行 section existed simply lacks it; add the section the first time a
trial row is written.

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
- nits — the facts hold and it belongs to this PR, but no harm occurs now, or
  the harm is negligible (SKILL.md Severity and Step 5c). It is not a finding:
  never fixed, and posted only on request (Step 8). Raise it again only when a
  later change makes the harm real, as a new finding. Put its nit line without
  `path:line`, `<指摘> / <否定理由>` (SKILL.md Step 7), in 要旨.
- accepted-tradeoff — the author deliberately chose this; never raise it again
- superseded — replaced by another finding; put the successor id in 要旨

提出 vocabulary (fixed): posted | pending

## 確定した設計判断

- <agreed decision, one line each, with the comment URL that settled it>

## 他レビュアの指摘

| reviewer | file:line | 要旨 | 我々の指摘との関係 | 統合結果 |
|---|---|---|---|---|
| @someone | path/to/file.go:88 | ... | F-003 と同旨 | F-003 を取り下げ |

## 修正の試行

| trial | finding | 回数 | 判定 | 連鎖(1行) | 記録 |
|---|---|---|---|---|---|
| T-001 | F-002 | 1 | 修正案を直す | 修正で X の前提が崩れる。修正のレビューが副作用として指摘 | <results.json のパス> |

判定 vocabulary (fixed): 残す | 修正案を直す | 人に返す (lookahead.md Step L4).
回数 is 1 for every new row. Rows written by the earlier, multi-round lookahead
may hold a larger 回数 and the 判定 取り下げ, 設計の問題 or 未確認; keep them as
they are. The 記録 path points into the scratchpad and may be gone later; the
連鎖 cell is the durable record, so write it so it stands on its own.

## 未解決の疑問

- <question, and who owes the answer>
```

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
     without `--fast`, if any `open` finding of 既出の指摘 has no row in
     修正の試行, write SKILL.md Step 4's context file and run SKILL.md Step 6b
     on exactly those findings, as with `trial:`; the lookahead's base is
     `headRefOid`. Otherwise, or with `--fast`, go to Step 9.
   - Different: fetch the PR head first, so the sha resolves locally even for a
     fork PR: `git fetch origin "pull/<number>/head"`. Then write only the
     incremental diff:
     `git diff <last_reviewed_head_sha>..<headRefOid> > <work dir>/diff.patch`.
     Use `gh pr diff <number> --repo <owner>/<repo> > <work dir>/diff.patch`
     (full diff) only on a first review or with `--fresh`.
   - `last_reviewed_head_sha` absent: first review, take the full diff.
   - History rewritten (force push). Check both conditions after the fetch
     above: the object is missing (`git cat-file -e <sha>^{commit}` fails), or
     it is no longer part of the branch's history
     (`git merge-base --is-ancestor <last_reviewed_head_sha> <headRefOid>` exits
     non-zero). Either one means the incremental diff would be wrong. Do not
     proceed silently: report
     "キャッシュの sha がリモートに存在しない（force push の可能性）" and fall
     back to a `--fresh` full fetch, keeping the 既出の指摘 table.
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
   that no longer exists) is reported to the user before the review continues.
6. Make the post-change state readable without touching the user's checkout:
   `git worktree add --detach <work dir>/tree <headRefOid>`. Workers read files
   there. List it in the report's closing with the removal command
   `git worktree remove <work dir>/tree` for the user to run.
7. On a first review there is no cache, so the dedup context is the comment
   streams from item 3. Combine them into `<work dir>/comments.json` and pass
   that path.

## Step 8: Posting (only on explicit instruction)

Do not post anything unless the user asked in this session. When asked:

- Summary comment: `gh pr comment <number> --repo <owner>/<repo> --body-file <file>`.
- Inline comments: `gh api` POST to `repos/<owner>/<repo>/pulls/<number>/comments`
  with path, line, side and the body.
- A candidate rated nits (status `nits`) is left out when the user asks to
  post the findings or the review. Post a nit only when the user names it or
  asks for the nits. Tell the user how many nits were left out.
- Post a nit as its nit line (SKILL.md Step 7) and nothing else. As an inline
  comment, the body is `nits: <指摘> / <否定理由>`; the comment's position
  carries the `path:line`. In a summary comment, list the nits after the
  findings under the heading `nits`, one nit line each. A posted nit carries
  no impact scenario, no evidence section and no fix.
- Show the user what will be posted before posting when the finding count
  exceeds 5.
- After posting, set 提出 to `posted` in the cache for each finding and each
  nit sent.

## Step 9: Write the cache back

Mandatory at the end of every PR-mode run except `--no-cache`. Read the existing
cache file, then Edit it. Do not Write over it — a full overwrite has destroyed
the accumulated 既出の指摘 history. For a brand-new cache, Write once, then Edit
from then on.

Update: `last_reviewed_head_sha` to the head sha just reviewed,
`last_reviewed_at`, the three `last_seen_*_id` values, the status of every
existing finding (fixed in this push becomes `resolved`, facts refuted becomes
`withdrawn`, scope-only rejection becomes `out-of-scope`, a rating of no
present harm becomes `nits`), the new findings and the new nits
appended with fresh ids, any new entries under 確定した設計判断 and
他レビュアの指摘, the 修正の試行 rows from Step 6b, and 未解決の疑問.
A `--fast` run writes no 修正の試行 row, so a later run without `--fast` on
the same head runs the lookahead on its `open` findings (Step 2).

Recording the rejections is the highest-value part of this step, not bookkeeping.
A `withdrawn` row with its refuting evidence is what stops the next run from
re-deriving the same wrong finding, and an `out-of-scope` row is what stops the
same true-but-broader point from being re-litigated on this PR every time.

Verify before and after: count the `| F-`, `| T-` and `| @` rows, and confirm
each after-count is greater than or equal to its before-count. If any row
disappeared, the write destroyed history — restore it before continuing.
