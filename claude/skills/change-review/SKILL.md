---
name: change-review
description: >-
  Review a change or a body of code along fixed review axes, then execute
  every surviving finding to see where it leads. Targets: a GitHub PR, a local
  comparison range (repository, base, compare target) named explicitly, or
  named paths of code at a revision with no PR or diff (code mode). Default
  axes: security / technical inconsistency and docs alignment / robustness /
  operational cost; a prompt may supply its own. PR mode keeps a per-PR cache
  under ~/.claude/pr-context, so a re-review fetches only the incremental diff
  and new comments and never repeats a settled finding. Axis workers run in
  parallel, and every candidate, including one a worker already labelled a
  nit, is verified by a command or a staged refutation, then rated by its
  present harm: one whose facts hold but that does no harm now, or negligible
  harm, is a nit, not a finding: never fixed, posted only on request, listed
  with the evidence that its facts hold and the evidence that its harm is
  absent.
  Then the lookahead runs on every review unless `--fast` is given: every surviving finding
  is fixed once by its own fixer, all in parallel, the fixes are merged
  three-way into one worktree, and reviewers who did not write the fixes
  review the fixed state once along the same axes; the final report merges
  both reviews, so findings come with a tested fix, its side effects, and a
  forecast of the next round. No stage waits longer than it must: candidates
  are verified and fixed as each axis reports. A re-review of a PR fixes only
  high and medium findings, and runs light — one worker for all axes and
  batched refuters — when the cache passes its freshness checks and the PR's
  own change since the last full review is within a threshold computed from
  past runs; a light run turns full as soon as it raises a high finding or a
  second finding.
  `trial:` runs only the lookahead, on findings from elsewhere such as
  another reviewer's comments. Never posts to GitHub unless told; never
  commits, pushes, installs, or deletes. Triggers: "PRをレビューして",
  "これを以下の要領でレビューせよ", "/change-review", "前回の続きからレビューして",
  "この差分をレビューして", "ローカルの変更をレビューして",
  "このコードの問題点を洗い出して", "PRなしでこのコードをレビューして",
  "指摘を実際に直して確かめて", "次のレビューを先読みして",
  "このレビューコメントは直す価値があるか試して", "review this PR",
  "review this diff", "review this code".
argument-hint: "<PR URL|番号> [設計書URL...] [--fresh] [--no-cache] [--full] [--allow-setup] [--fast]"
---

You execute a change review. The invocation arguments are:

```
$ARGUMENTS
```

Below, "the arguments" means the block above. The arguments and the prompt carry
the target, zero or more design-document URLs, and optional flags. Step 0
resolves one of three entry modes:

| Mode | Target | Cache and GitHub fetch |
|---|---|---|
| PR mode | A GitHub pull request | Yes, per `pr-mode.md` |
| Local mode | A local comparison range named explicitly in the prompt | No |
| Code mode | Named paths of code at a revision, with no diff | No |

This file holds what the main session needs. The other parts live beside it
and are read only by whoever needs them, when they apply:

| File | Read by, when | Holds |
|---|---|---|
| `~/.claude/skills/change-review/pr-mode.md` | The main session, when Step 0 resolves PR mode | The GitHub rules, the cache (Step 1 and its schema), the PR fetch (Step 2), the review depth (Step 2b), posting (Step 8), the cache write-back (Step 9) |
| `~/.claude/skills/change-review/lookahead.md` | The main session, right after Step 4 launches the axis workers, on every run except a nested review or a `--fast` run; each fixer it starts reads its Rules and Fixer section | The lookahead: per-finding fixers, the three-way merge, the review of the fixes, the integration |
| `~/.claude/skills/change-review/worker.md` | Each axis worker, never the main session | The worker's rules, its rating, its output shape |
| `~/.claude/skills/change-review/refuter.md` | Each refuter, never the main session | The three stages, the refuter's output shape |
| `~/.claude/skills/change-review/scripts/` | Run by the main session | `cache_rows.py` (cache rows as JSON), `pr_interdiff.sh` (the PR's own change between two reviewed states), `threshold.py` (the light-depth threshold) |

A nested review is a run marked `invoked-by: lookahead`: the lookahead runs it
to review its own fixes. It is local mode, skips Step 6b, and reads neither
file. A run with `--fast` also skips Step 6b and never reads lookahead.md.

Follow the steps below literally and in order. Do not improvise a shorter path.
This skill exists to prevent three expensive failures: re-fetching a PR's
entire state from zero on every session, re-raising findings the author already
answered, and reporting a first observation as if its consequences had been
followed. The third one is not solved by asking reviewers to think harder; a
reviewer that only reads code stops at the first link of the causal chain, the
author fixes what it saw, and the next round finds what the fixes broke. Step 6b
follows the chain one link further on every run without `--fast`: it applies
every fix in one worktree and has reviewers who did not write the fixes review
what they actually changed. It costs one fixer per finding plus one review of
the fixes, in a single pass, overlapped with the review itself (Step 4b).
`--fast` gives this up for time: every finding is still verified and rated,
but its 修正案 stays untested and the report carries no forecast of the next
round.

## Hard rules

- Read-only against GitHub by default. Allowed: `gh pr view`, `gh pr diff`,
  `gh api` GET, `git fetch`, `git diff`. Forbidden unless the user explicitly
  asks in this session: posting comments or reviews, approving, requesting
  changes, resolving threads, pushing, closing, merging, editing PR body or
  labels. Never run a destructive git or `gh` command. Local mode and code mode
  make no GitHub calls at all.
- Evidence first. Every finding needs a primary source: the diff itself, a file
  in the repo cited as `path:line`, official documentation (use the aws-docs MCP
  for AWS behaviour), or a linked design document. Never fill a gap with
  inference and present it as fact. A finding you could not ground is not a
  finding.
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
- When the target repository is your current working directory, run git there
  without `-C`. A worktree-isolated agent has any `git -C` call refused when it
  points at another checkout, and the refusal discards the whole command.
- Intermediate files go under the run's work directory (Step 0), in any format
  except `.md`.
- Long command output goes to a file, never into the conversation. Redirect
  every command whose output can run long — diffs, test, lint and build runs,
  repository-wide greps, `git log -L`, `git blame`, API listings — to a file
  under the work directory (`<command> > <file> 2>&1; echo "exit=$?"`), then
  read only the lines a decision needs with `grep -n`, `head`, `tail`, `sed -n`
  or `wc -l`. Read further whenever those lines do not settle the question.
  This limits what is printed, not what is examined: the diff and the files
  under review are still read as fully as the review needs.
- Never delete anything. Do not run `rm`, `rmdir`, `unlink`, `git clean`,
  `git worktree remove`, or any other command whose purpose is deletion, even on
  byproducts or in your own scratch directory. The report gives the user the
  exact removal commands to run.
- Never commit, push, merge, or stash, in the user's working tree or in any
  worktree this run creates. Never install tools, packages or dependencies,
  except as `--allow-setup` permits (lookahead.md).
- Never point a worker at the user's checkout. Workers read the state under
  review from a detached worktree or an extract under the work directory.
- The main session's context is the scarce resource; agents read, the main
  session routes. The main session never reads a file under review or a design
  document whole: it reads only the lines a decision needs with `grep -n` or
  `sed -n`, for a Step 5a reproduction or a line of the report. It reads agent
  output files with `jq`, extracting only the fields a decision needs, and the
  full text only of the findings and nits that the report carries.
- Agent prompts carry only what differs per agent: names, paths, ids, the axis
  text and the `questions:`. The rules, the rating and the output shape live in
  worker.md, refuter.md and lookahead.md's Fixer section, which each agent
  reads itself; never paste their text, or the Severity section, into a
  prompt. Every agent ends with the one-line message `done <output path>`.
- Model: every agent this skill launches — axis workers, refuters, fixers, and
  the reviewers of the fixes, in every run including a nested review — is
  launched with `model: "sonnet"`, and so is every relaunch of one. The main
  session runs on the session's own model.
- The final report to the user is written in Japanese. No emojis anywhere, in
  this file's outputs or in anything posted.

## Arguments

| Token | Meaning |
|---|---|
| PR URL or number | Target PR. Optional; see Step 0. |
| Any other URL | Design document. Used for axis 2 (docs alignment). |
| `--fresh` | PR mode. Ignore the existing cache, refetch everything, rebuild the cache. |
| `--no-cache` | PR mode. Neither read nor write the cache for this run. |
| `--full` | PR mode. Run a re-review at full depth even when pr-mode.md Step 2b would choose light. |
| `--allow-setup` | Lets the lookahead run the repository's own documented setup command inside the worktrees it created (lookahead.md). |
| `--fast` | Any mode. Skips Step 6b, the lookahead: no fixer, no merge, no check run, no review of the fixes, and none of the lookahead's worktrees (`wt-base`, `wt-fix`, `wt-<id>`). The read-only `<work dir>/tree` of PR mode and code mode is still created. Steps 3 to 6 run unchanged. `--allow-setup` has nothing to act on. Not combinable with `trial:` (Step 0). |
| `trial:` | A JSON file of findings, or findings written in the prompt, from outside this review (another reviewer's comments, another tool). Steps 3 to 6 are skipped, and Step 6b runs the lookahead on these findings against the resolved target. Format: the candidate shape of lookahead.md Step L1, item 1. |

Local mode reads these fields from the prompt, one per line:

| Field | Meaning |
|---|---|
| `repo:` | Absolute path of the repository or worktree root. Required. |
| `base:` | Base revision. Required. |
| `target:` | `worktree` (the working tree of `repo`, untracked files included) or a revision. Required. |
| `fixes:` | Optional, set by the lookahead. Path of a JSON array; each entry `{"id", "location", "claim", "patch", "evidence"}` names a finding of the outer review, the patch of its fix alone, and the evidence the outer review established for it. The state under review holds every listed fix, applied together on top of `base` (lookahead.md Step L2). Requires `output:`. |
| `warm:` | Optional, set by the lookahead. Path of a JSON object mapping each axis number, or `all` at light depth, to the name or id of an axis worker that is already running and has read the change (lookahead.md Step L1b). Step 4 sends those workers their prompt instead of launching new ones. |
| `light:` | Optional, set by the lookahead. `true` runs this review at light depth: one worker for all axes (Step 4) and batched refuters (Step 5b). |
| `axes:` | Optional. Replaces the Step 3 観点 list verbatim. |
| `questions:` | Optional. Added verbatim to every worker prompt in Step 4. |
| `findings:` | Optional. Path of a JSON array of findings already raised; the dedup context. |
| `context:` | Optional. Path of a context file (Step 4) written by an outer run. Used as is; this run writes no new one. |
| `output:` | Optional. Path where Step 7 writes JSON instead of the Japanese report. |
| `workdir:` | Optional. The run's work directory, used instead of `<scratchpad>/<run id>/`. |
| `exclude:` | Optional. Path of a file listing paths, one per line, to leave out of the diff and the review (for example, files a check run generated). |
| `name-prefix:` | Optional. Prefix for worker names and scratch directories, so nested runs never reuse a name. |
| `invoked-by: lookahead` | Marks a nested review. Step 6b is skipped and `output:` is required. |

Code mode reads these fields from the prompt, one per line. `axes:`,
`questions:`, `findings:`, `context:`, `output:`, `workdir:` and
`name-prefix:` work as in local mode.

| Field | Meaning |
|---|---|
| `repo:` | Absolute path of the repository root. Required. |
| `rev:` | The revision whose code is reviewed. Required. |
| `paths:` | One or more files or directories, relative to the repository root, separated by spaces. Required. |

## Step 0: Resolve the target

1. Local mode: if the prompt names `repo:`, `base:` and `target:`, enter local
   mode. In `repo`, resolve `base` to a full sha with
   `git rev-parse <base>^{commit}`; resolve `target` the same way when it is a
   revision. Every field must be explicit. Never derive a range from the
   current branch, the reflog, or "recent changes". Then go to item 6.
2. Code mode: if the prompt names `repo:`, `rev:` and `paths:`, enter code
   mode. Resolve `rev` to a full sha with `git -C <repo> rev-parse <rev>^{commit}`,
   and confirm every path exists at it with
   `git -C <repo> cat-file -e <rev sha>:<path>`. All three must be explicit.
   Never derive the paths from recent changes or from the current directory.
   Then go to item 6.
3. PR mode: if a PR URL or number is present in the arguments, parse `owner`,
   `repo`, `number` from it.
4. Otherwise resolve from the current branch:
   `gh pr view --json number,url,state,headRefName`. Take `owner` and `repo`
   from the `url` field (`https://github.com/<owner>/<repo>/pull/<number>`),
   which is always the base repository. Never derive them from
   `headRepositoryOwner` / `headRepository`: on a fork PR those name the fork,
   and every `gh api repos/<owner>/<repo>/...` call below must target the base
   repository.
5. If that fails, stop. Ask the user for the PR number, for the three local
   mode fields, or for the three code mode fields, and do nothing else. Never
   guess a PR number, never review "the most recent PR".
6. Work directory: `workdir:` when given. Otherwise pick a run id — the PR
   number, `local-<short base sha>` or `code-<short rev sha>`, plus a UTC
   timestamp — and use `<scratchpad>/<run id>/`. Every file this run writes goes
   under the work directory, except the PR cache.
7. PR mode: Read `~/.claude/skills/change-review/pr-mode.md` in full now. Its
   Steps 1, 2 and 2b replace Step 2 below; Step 2b sets the review depth that
   Steps 4 and 5b use. Its Steps 8 and 9 run after Step 7. Local mode and code
   mode always run at full depth, except a nested review with `light: true`.
8. With both `trial:` and `--fast`, stop and ask the user which one to drop:
   `trial:` runs only the lookahead, and `--fast` skips it. With `trial:`
   alone, run Step 2 (or pr-mode.md's Steps 1 and 2) and Step 4's context
   file, then go to Step 6b.

## Step 2: Build what is reviewed (local mode, code mode)

Local mode. Run in `repo`, writing straight into `<work dir>/diff.patch` with
shell redirection; do not print the diff:

- `target` is a revision: `git diff <base> <target>`.
- `target` is `worktree`: `git diff <base>`, then append every untracked,
  non-ignored file listed by `git ls-files --others --exclude-standard`, each
  rendered with `git diff --no-index -- /dev/null <file>`. Exit code 1 from
  `--no-index` means "differences found", not failure. Without this step a
  newly created file is invisible to the review.
- Leave out every path listed in the `exclude:` file, if given.

The post-change state is the tree itself: workers read files under `repo`
directly, not only the diff.

Code mode. There is no diff: the code under review is every file under
`paths` at `rev`, read whole, together with what it calls and what calls it.

- Make the state readable without touching the user's checkout:
  `git -C <repo> worktree add --detach <work dir>/tree <rev sha>`. Workers read
  files there. List it in the report's closing with the removal command
  `git -C <repo> worktree remove <work dir>/tree` for the user to run.
- Write the file list:
  `git -C <repo> ls-tree -r --name-only <rev sha> -- <paths> > <work dir>/files.txt`.

## Step 3: The canonical review checklist

This is the contract. Do not paraphrase it away, do not drop axis 2's docs
alignment clause, do not renumber the axes.

```
観点
1. 安全性・情報漏洩・権限昇格・サプライチェーン・任意コード実行/リモートコード実行リスク
2. 技術的不整合・論理的矛盾・暗黙のトレードオフ・未決定トレードオフ、docsとの整合性
3. 堅牢性・可用性・レースコンディション
4. 運用工数・リソース効率

注意事項
* aws docs mcpなどエビデンスをフル活用し推論に頼らないファクトベースのレビューコメントとなるよう徹底すること
* 過去のコメントや差分遍歴を確認し、同じ指摘は行わないこと。
* 過去の指摘によりトレードオフとして任意の案をあえて選択している場合は改めてその点の指摘は行わない。ただし、わずかでも純粋技術的に指摘価値がある場合には指摘する。
* gh apiでリスト系エンドポイントを叩く際は必ず --paginate を付与せよ。コメント取得後、取得件数が30の倍数の場合はページネーション漏れを疑い、--paginate付きですべてのコメントを取得せよ。
```

Axes override: when the prompt supplies `axes:`, use those axes verbatim in
place of the 観点 list, in the given order, one worker per axis. The 注意事項
still apply; in local mode and code mode the `gh api` clause has nothing to act
on. Without `axes:`, the four axes above are used unchanged.

## Severity

Severity rates the present harm of a finding: what goes wrong, for whom, under
the code, configuration and operation as they stand now, including transient
errors that occur in normal operation. It never rates how wrong the code looks
or how many rules it breaks.

| Severity | Present harm |
|---|---|
| high, medium, low | Real harm that can occur now, rated by its size |
| nits | The facts are correct, but no harm occurs now, or the harm is negligible |

Typical nits:

- A failure that stops before any state change, says plainly what went wrong,
  and leaves the existing way of doing the work open. On PR #3857: an import
  Automation that fails at the bundle step for targets the tool cannot render.
- A deviation from a convention, or a wording error, with no functional effect:
  a style rule whose purpose the code does not touch, or a table that misnames
  a value while its conclusion holds.
- A path that only a future change could open, such as a procedure for adding
  types that would mislead someone adding an unsupported type.
- A window that the available production data never shows.

A nit is not a finding. Nothing raises it as a 指摘事項:

- It is verified like any candidate (Step 5), whoever first rated it nits. A
  worker's nits label is a claim about harm, and an unverified claim settles
  nothing: listed on a worker's word alone, a nit is noise the reader can
  trust neither way, and the PR cache would suppress it for good on that word.
  Only a candidate whose verification ends NITS is a nit. One whose facts are
  refuted is dropped like any refuted candidate; one whose harm the
  verification finds real is a finding.
- It is not fixed by the lookahead, not counted among the findings, and posted
  only when the user asks for it (pr-mode.md Step 8).
- The report lists it once, in the closing section nits (Step 7), as a nit
  line `<指摘> / <否定理由>` with two evidence lines: 論拠, the evidence that
  its facts hold, and 否定の根拠, the evidence that its harm is absent or
  negligible now. A candidate lacking either is not listed as a nit.
- PR mode caches it with status `nits`, so that no later run raises it again.
  A later change that makes the harm real makes it a new finding.

Never inflate a nit to low to keep it in the report, and never deflate real
harm to nits to shorten the report: either error defeats the rating.

## Step 4: Parallel fan-out — one agent per axis

Step 2 wrote what is under review to the work directory — `diff.patch` or
`files.txt` — so the agents read a path, not a pasted blob.

The context file holds what every worker needs besides the diff, so that no
hand-off drops it. With `context:`, use that file as is. Otherwise write
`<work dir>/context.json` with one `Write` call, a JSON object with:

- `intent`: what the change is meant to do. PR mode: `title`, and `body_file`,
  the path of the PR body that pr-mode.md Step 2 saved. Local mode and code
  mode: `stated`, what the prompt says the change or the code is for, or what
  the user suspects is wrong with it, verbatim.
- `design_docs`: every design-document URL in the arguments or the prompt.
- `settled`: the path of the decisions already agreed with the author. PR mode:
  the cache file, or `<work dir>/comments.json` on a first review. Local mode
  and code mode: null.
- `user_constraints`: every constraint the user stated in this session,
  verbatim.

Write an empty value as null or `[]` rather than leaving a key out, so a reader
can tell "none" from "not passed". Every worker, every refuter, every fixer
and every nested review receives the path.

The deduplication context:
- PR mode, re-review: the cache file
  (`~/.claude/pr-context/<owner>__<repo>__<number>.md`) and its history
  directory (`<owner>__<repo>__<number>.history/`, pr-mode.md Cache layout) —
  pass both paths. Do not copy their rows into a scratchpad file. On a first
  review, pass `<work dir>/comments.json` instead. With `--no-cache` and no
  comments, there is no dedup context, and the agents are told so explicitly.
- Local mode and code mode: the `findings:` file if given; otherwise there is
  none, and the agents are told so explicitly.

Fan the axes out to parallel workers, one per axis. At light depth (pr-mode.md
Step 2b, or `light: true`) there is one worker instead, `axis-all`, which owns
every axis of Step 3; it is a single `Agent` call. The four per-axis workers
join it if the run escalates (Step 4b). One named teammate per axis
is the default otherwise: two or more parallel tasks must go through Agent Teams, and
`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is exported from `.zshenv`. Spawn each
teammate with the `Agent` tool and a `name` that identifies its axis
(`axis1-security`, `axis2-consistency`, `axis3-robustness`, `axis4-ops`, or
`axis<N>-<slug>` for prompt-supplied axes) so it stays addressable through
`SendMessage`. There is no separate team-creation step: as of Claude Code
v2.1.178 the team is implicit and `TeamCreate` no longer exists. Only if Agent
Teams is unavailable — the env var is unset, or this session is itself a
teammate and cannot nest — fall back to plain `Agent`
(`subagent_type: general-purpose`) launches issued in a single message. Either
way, launch every worker with `model: "sonnet"` (Hard rules).

Worker names: with `name-prefix:`, every worker name is `<prefix>-<name>`. A
plain `Agent` call has no `name`, so state the name in the worker's prompt; it
names the worker's scratch directory. If a teammate name is already taken in
this session, append the run id.

With `warm:`, launch no new worker for an axis the file lists (`all` at light
depth): that axis already has a running worker that has read the change. Send
it the prompt below with `SendMessage`. An axis the file does not list, or a
worker that cannot be reached, gets a newly launched worker as above.

Each worker's deliverable is a file: `<work dir>/axis<N>.json`, or
`<work dir>/axis-all.json` at light depth, written with one `Write` call as its
final action. Detect completion only by that file existing and being non-empty,
never by a reply or a notification.

On a run that reaches Step 6b (every run except a nested review or a `--fast`
run), Read `~/.claude/skills/change-review/lookahead.md` in full as soon as
the workers are launched, and start its Step L0. Then go to Step 4b. Do not
wait for the workers.

Each worker's prompt is short, and carries only:

- "Read `~/.claude/skills/change-review/worker.md` in full and follow it. You
  are <worker name>."
- The target: `<owner>/<repo>#<number>` and the head sha,
  `local <repo> <base sha>..<target>`, or `code <repo> <rev sha> <paths>`.
- What to read:
  - PR mode and local mode: the diff file path; whether it is the full diff,
    an incremental diff or an interdiff (pr-mode.md Step 2), between which
    shas; and where the post-change files are read: `<work dir>/tree` in PR
    mode, `repo` in local mode.
  - With `fixes:`: the fixes file path.
  - Code mode: the file list `<work dir>/files.txt` and the tree
    `<work dir>/tree`.
- The dedup context paths, or "There is no dedup context."
- The axis or axes it owns, quoted from Step 3 or from `axes:`.
- The `questions:` text, if given.
- The context file path.
- In a nested review: "This is a nested review: fill `base_holds` and
  `original_consequence`."
- The output file path.

The worker's rules, its rating, the 根拠 it must quote and the JSON shape of
its findings are in worker.md. Its output is a JSON array of finding objects
with the keys `location`, `axes`, `severity`, `claim`, `evidence` (an array of
`{source, quote}`), `impact`, `harm`, `verification_kind`,
`verification_command`, `fix`, and, where they apply, `base_holds`,
`original_consequence` and `fix_ids`.

## Step 4b: Handle each axis as it reports

No step waits for every worker. Whenever you regain control (a notification, a
finished command, a finished agent), check which `axis*.json` files exist and
are non-empty, and handle each new one at once, while the other workers keep
running. Fit the lookahead's Step L0 and Step 5a reproductions in between.

A severity is fixable when the lookahead fixes findings of that severity: high,
medium or low, except on a PR-mode re-review (pr-mode.md Step 2b), where only
high and medium are fixable. A finding newly raised in a re-review is fixed
when it is rated high or medium, like any other.

For each new axis file:

1. Validate it with `jq empty <file>`. On failure, send the worker the error
   with `SendMessage` and ask it to rewrite the file; handle the file when it
   is valid. Give each finding an id, unique within this run (in PR mode,
   continue the cache's F-ids, so that Step 9 keeps them), and append the
   objects with their ids to `<work dir>/candidates.json` with `jq`, without
   printing them. Print only `{id, location, severity, claim,
   verification_kind}` per new candidate. A candidate that duplicates one
   already received from another axis (the same `location` and the same claim
   in substance) is merged into it, adding the axis, and is not dispatched
   again.
2. Run Step 6 on each new candidate against the dedup context. A candidate
   that Step 6 suppresses, or reports as a reminder of an `open` entry, stops
   here: nothing is spent verifying or fixing it.
3. Gate on 根拠 with `jq`; no agent. A candidate passes when its `evidence` is
   a non-empty array and every entry has a non-empty `source` (`path:line`,
   `<URL>` or a command) and a non-empty `quote`. A candidate that fails is
   dropped as 根拠不足: it is neither verified nor fixed nor reported, only
   counted in the summary line and recorded with its claim in
   `<work dir>/ungrounded.json`. PR mode does not cache it, so that a grounded
   raise of the same point in a later run is not suppressed. This gate is what
   keeps verifying every candidate cheap: a refuter starts from the quote
   (Step 5b), and an issue with nothing to start from would cost a refuter a
   search of its own.
4. Dispatch every candidate that passed, all in one message where agents are
   launched: its verification (Step 5a by you, or Step 5b), and, on a run that
   reaches Step 6b, its fixer (lookahead.md Step L1) when its worker's severity
   is fixable. On such a run, the first fixer started also starts lookahead.md
   Step L1b.
5. A candidate whose worker's severity is not fixable (nits always; low on a
   re-review) is dispatched like any other: it is verified (Severity), but gets
   no fixer at dispatch. When its verification rates it fixable, start its
   fixer then, on a run that reaches Step 6b. When it ends NITS, list it under
   nits. When it ends REFUTED or OUT-OF-SCOPE, handle it as Step 5b's verdict
   table says.

When a verification ends, record its verdict. On a run that reaches Step 6b,
the fixer of a candidate that ends REFUTED, OUT-OF-SCOPE or NITS, or whose
rating is not fixable, is stopped and discarded (lookahead.md Step L1), and
Step 6b's merge (lookahead.md Step L2) takes each candidate as soon as it is
verified and its fixer is done.

Escalation, at light depth only. Light depth rests on the statistic that a
small re-review raises at most one finding (pr-mode.md Step 2b); a run that
breaks it turns full at once. Whenever a verification ends, count this run's
findings so far: candidates of this review's axis workers that ended CONFIRMED
or SURVIVES and that Step 5c rated high, medium or low. As soon as one of them
is high, or there are two or more, escalate, once:

1. Rewrite `<work dir>/depth.json` with `depth` full, `escalated` true, and
   the reason, for example `軽量で開始し、high の指摘が出たためフルに昇格`.
2. Launch the four per-axis workers of Step 4 with their usual prompts, adding
   `<work dir>/candidates.json` to their dedup context as "the candidates this
   run already raised". Step 4b handles their axis files like any other, and
   Step 7 waits for them like any other.
3. Every candidate dispatched from now on gets its own refuter (Step 5b at full
   depth). Batch refuters already running finish their batches.
4. On a run that reaches Step 6b, the lookahead's review of the fixes turns full
   too (lookahead.md Step L1b).

A nested review and a `--fast` run both go through this step without fixers:
their candidates are verified as each axis reports. In a nested review, a
candidate whose `original_consequence` names a `findings:` entry is never
suppressed by item 2: it says that a fix left that finding's consequence in
place, and an earlier result about the base revision says nothing about the
fixed state. Every other nested candidate that items 2 and 3 keep is verified,
including one whose `base_holds` is はい; the lookahead reports it as a miss of
the original review.

Step 7 starts only when every axis file is handled and every dispatched
candidate is verified (and, on a run that reaches Step 6b, when the lookahead
is done).

## Step 5: Verification phase

No finding and no nit reaches the report unverified, and none reaches it
without a rating of its present harm (Step 5c). A worker's nits label is a
provisional severity like any other, and goes through this step like any
other. This phase is not optional; it is the
part of the review the user actually asks for. But do not spawn one refuter per
candidate blindly — twenty candidates would mean twenty agents, and for a large
share of them an agent is the weaker instrument. Route each candidate by the
機械検証可能 / 解釈依存 label it carried out of Step 4. Step 4b dispatches
candidates here per axis, as each axis reports; never hold one back to wait for
the other axes.

### Step 5a: Mechanical reproduction (for 機械検証可能 candidates)

Reproduce it yourself with a command. Do not delegate. A reproduction is stronger
evidence than any agent's reasoning, and it costs a fraction as much.

- Run the smallest command that settles the claim, with its output redirected to
  a file under the work directory. Quote in the report the lines of that output
  that settle the claim, and the exit code. Prefer an isolated reproduction over
  a full pipeline: a minimal synthetic template fed to the repo-pinned linter
  beats bundling the whole stack, and it cannot be confounded by unrelated
  errors.
- Never mutate the user's worktree to reproduce something. Extract the state
  under review into a scratch directory (`git archive <sha> <path> | tar -x -C
  <scratch>`) and work there. Never write into `dist/`, never check out a
  branch, never stash. In local mode with `target: worktree`, copy the needed
  files from `repo` into the scratch directory instead of archiving a sha.
- Reproduced: the candidate is CONFIRMED. Record the exact command in the report
  so the author can re-run it.
- Scope, for every CONFIRMED candidate: run the same command against the state
  before the change (PR mode: the merge-base of the base branch and the head;
  local mode: `base`). If it reproduces there too and the change did not touch
  the cited lines, the candidate is OUT-OF-SCOPE, exactly as Step 5b Stage 2
  would route it. Record both runs. Code mode has no state before a change: a
  CONFIRMED candidate is OUT-OF-SCOPE only when its cause lies entirely outside
  `paths`.
- Did not reproduce: the candidate is REFUTED. Record it as `withdrawn` with the
  command and its output as the refuting evidence.
- The command cannot be run here (needs deployed AWS resources, credentials the
  session lacks, a vendor console): do not guess and do not silently keep it.
  Re-label the candidate 解釈依存 and send it through Step 5b instead.

Candidates that belong here in practice: a linter or validator that rejects the
template, a template that will not render with the shipped params, two files that
must agree and do not, a grep whose count contradicts the claim, a value that can
be computed from the diff.

### Step 5b: Staged refutation (for 解釈依存 candidates)

A refuter is an independent worker that runs refuter.md's three stages — the
facts, the scope, the present harm — and reports them separately. Keeping them
separate is the point: a single blended verdict with "treat ambiguity as
refuted" folded in rejects sound findings for reasons that have nothing to do
with whether they are true. On a mature PR that bias silently eats almost
everything. The same holds for harm: whether a finding is true, whether it
belongs to this change, and whether it hurts anyone now are three questions.

Assigning candidates:

- Full depth: one refuter per candidate, named `refute-<finding id>`.
- Light depth (pr-mode.md Step 2b, or `light: true`): the 解釈依存 candidates
  of one axis file go out in batches of at most 8, one refuter per batch, named
  `refute-b<n>`, n counting the batches of this run. refuter.md has a refuter
  judge each candidate on its own evidence, one at a time.

Two or more refuters at once are named teammates, launched with the `Agent`
tool in one message, with `model: "sonnet"` (Hard rules); a single refuter may
be a single `Agent` call, with the same model. If this session is itself a
teammate, issue plain `Agent` calls in a single message instead.

Each refuter's prompt carries only: "Read
`~/.claude/skills/change-review/refuter.md` in full and follow it. You are
<name>."; the candidates file `<work dir>/candidates.json` and the ids it owns;
the target identifier; the diff path; the dedup context paths; the context file
path; with `fixes:`, the fixes file path; and its output file
`<work dir>/<refuter name>.json`, a JSON array with one verdict object per
candidate. Read a finished output file with
`jq -c '.[] | {id, verdict, stage3_harm}'`; read the reasons and the evidence
only of the candidates the report carries.

Verdicts and what to do with each:

| Stage 1 | Stage 2 | Stage 3 | Verdict | Action |
|---|---|---|---|---|
| refuted | not run | not run | REFUTED | Drop. Cache as `withdrawn` with the refuting evidence, so no future run raises it. |
| survived | PR-specific, or in the code under review | high, medium or low | SURVIVES | Report it with the Stage 3 severity. Attach the refutation attempt's evidence to strengthen the write-up. |
| survived | PR-specific, or in the code under review | nits | NITS | Not a finding. List it under nits with the Stage 3 reason, `stage1_evidence` as its 論拠 and `stage3_evidence` as its 否定の根拠; cache as `nits`. |
| survived | repo-wide, outside the code under review, or already settled | not run | OUT-OF-SCOPE | Do NOT drop. Cache as `out-of-scope` and report it under 別作業候補 with the evidence that put it there. |

A finding whose facts hold is never discarded merely for being broader than this
change. That is a routing decision, not a refutation, and throwing it away loses
real work — the refuter has already established it is true.

### Step 5c: Present harm (every candidate Step 5 keeps)

Every candidate that ends CONFIRMED (Step 5a) or survives Stage 2 (Step 5b) is
rated by its present harm before it can become a finding. The facts being true
is not enough: a true fact that hurts no one now is a nit (Severity).

- A Step 5b candidate: Stage 3 of its refuter gives the rating.
- A Step 5a candidate: rate it yourself, right after the scope run, with the
  Stage 3 question, and write the reason next to the reproduction in the
  report's evidence. The reproduction proves that the fact holds; it does not
  prove harm. Ask what the reproduced behaviour does to whom, now: a template
  that fails to render before any state change, for a target the tool was not
  meant to serve, is a reproduced fact and a nit.
- A rating of nits makes the candidate NITS: stop its fixer if it has one, list it under
  nits, and, in PR mode, cache it as `nits`. For a Step 5a candidate, its
  論拠 is the reproduction command with the output line that settles it, and
  its 否定の根拠 is the command, `path:line` or URL that shows the harm absent
  or negligible; a rating you cannot back with such evidence is not nits.
- A rating of high, medium or low replaces the worker's provisional severity.
  When the rating is fixable (Step 4b) and the worker's severity was not, start
  its fixer now, on a run that reaches Step 6b. When the rating is not fixable
  (low on a re-review), stop its fixer if it has one; the report lists it under
  未深掘り with that reason.

## Step 6: Deduplication

Step 4b runs this step on each candidate as it arrives, before Step 5, so that
nothing is spent verifying or fixing a known finding. Match every candidate
against the dedup context. In PR mode on a re-review that is the cache: the
sections of the cache file that pr-mode.md Step 1 read (the open rows of
既出の指摘, 確定した設計判断, 他レビュアの指摘), and the rows of the history
directory that concern the candidate's file. Look those up per candidate,
without reading the history whole:
`grep -nF '<path of the candidate>' <cache file> <history dir>/*.md`. On a first
review it is `<work dir>/comments.json`. In local mode and code mode it is the
`findings:` file. When the context file's `settled` is not null, also match
against the decisions it holds. Match on `file:line` plus semantic equivalence
of the 要旨, not string equality — the same defect moves lines between pushes;
when a candidate's file was renamed by this change, grep the old path too.

A PR-cache `nits` row whose 根拠URL cell lacks `否定の根拠:` was cached by an
earlier version of this skill on a worker's word, unverified. It suppresses
nothing: a candidate matching it goes on to Step 4b's gate and verification,
and Step 9 records the outcome under the same id (pr-mode.md Step 9).

- Matches an `open` entry: not new. Report it as a reminder in the 既出 section,
  do not restate it as a fresh finding.
- Matches `resolved` / `withdrawn` / `out-of-scope` / `nits` /
  `accepted-tradeoff` / a 確定した設計判断: suppress. A `nits` entry is raised
  again only when a later change has made its harm real; it is then a new
  finding. The one exception is the canonical clause — if there
  is a genuine purely technical point left, raise it and say explicitly that it is
  being raised despite the accepted tradeoff, and why.
- Matches another reviewer's finding: merge them into one entry, credit the
  other reviewer, and drop ours if theirs is equivalent or stronger.
- Local mode, matches an entry of the `findings:` file: not new. Mark it
  `still-present: <that id>` and keep the evidence that the listed problem still
  occurs in the post-change state. The lookahead uses this to see whether a fix
  actually removed the problem.
- With `fixes:`, a candidate is `still-present` only for an entry that has a
  fix in the fixes file. A match with any other entry is not new and is
  suppressed, because a finding with no applied fix is expected to hold.

## Step 6b: Lookahead (every run except a nested review or `--fast`)

Runs on every run except a nested review, because a nested review is the
lookahead reviewing its own fixes and a second lookahead inside it would loop,
and except a run with `--fast`, because the user traded the lookahead for time.
A `--fast` run starts no fixer, creates none of the lookahead's worktrees, and
goes from Step 6 straight to Step 7.
It is not a separate phase: Step 4 already read
`~/.claude/skills/change-review/lookahead.md` and started its Step L0, and
Step 4b started its fixers. Follow lookahead.md to its end. With `trial:`, or
after an unchanged PR (pr-mode.md Step 2), Steps 4 to 6 did not run: Read
lookahead.md in full here and start at its Step L0.
On a PR-mode re-review the lookahead fixes only fixable findings (Step 4b):
high and medium, whether newly raised in this run or still open from an
earlier one. A low finding is reported with its 修正案 untested.

## Step 7: Report

On a call with `output:`, write the surviving findings to that path as a JSON
array with one `Write` call, and stop. A finding raised by several axis workers
is one object. Each object has these keys:

| Key | Content |
|---|---|
| `id` | A fresh id, `R-<n>`, unique within this output file |
| `location` | file:line |
| `severity` | high, medium, low or nits, as Step 5c rated it |
| `claim` | 要旨 |
| `evidence` | 根拠: the worker's array of `{source, quote}` |
| `impact` | 影響シナリオ |
| `verification_kind` | 機械検証可能 or 解釈依存 |
| `fix` | 修正案 |
| `axes` | Array of the axis numbers whose workers raised it |
| `verdict` | CONFIRMED, SURVIVES, NITS or OUT-OF-SCOPE |
| `harm` | 実害: the Step 5c reason |
| `still_present` | The matched `findings:` id, or null |
| `base_holds` | 基点で成立: はい, いいえ or 不明, with its evidence |
| `original_consequence` | 元の帰結: the `findings:` entry id, or null |
| `verification` | The reproduction command, or `段階反証` |
| `nit_evidence` | For verdict NITS, `{"論拠": ..., "否定の根拠": ...}` as Step 5b's table or Step 5c defines them; otherwise null |
| `fix_ids` | 対象の修正: with `fixes:`, the array of finding ids whose fixes the issue concerns (several for an issue that arises from fixes together), or `[]` for 無し; otherwise null |

Do not write the Japanese report in that case.

Otherwise the report is Japanese. When the lookahead drafted it
(`<work dir>/report.draft.txt`, lookahead.md Waiting), complete that draft
instead of writing from the start. Open with the summary lines, then one
chapter per axis.

```
新規 N件 / nits X件 / 既出につき抑制 M件 / 根拠不足で不採用 G件 / 反証により却下 K件 / 別作業候補 S件 / 未深掘り U件
先読み T件: 残す a / 修正案を直す c / 人に返す d / 修正のレビューで見つかった見落とし m件
対象: <owner>/<repo>#<number> <head sha 短縮> (前回レビュー: <sha 短縮> / <日付>)
深さ: <フル | 軽量> (<pr-mode.md Step 2b の理由>)
```

新規 counts findings only; nits are counted apart and never appear in the
per-axis chapters.

In local mode the third line is `対象: <repo> <base 短縮>..<target>`. In code
mode it is `対象: <repo> <rev 短縮> <paths>`. The fourth line appears in PR
mode only; its reason is the one `<work dir>/depth.json` records, for example
`軽量 (前回のフル実行からの PR 自身の変更 23 行、基準 71 行以下)`,
`フル (base を取り込み、差分の差を計算できない)` or
`フル (軽量で開始し、high の指摘が出たためフルに昇格)`. With `trial:`, the first line
is omitted and the findings are grouped by source instead of by axis. With
`--fast`, the second line is `先読み: 省略 (--fast)`.

Then, per axis: each finding as `path:line`, severity, the point, the evidence
URL in `<...>`, the concrete impact scenario, and its 実害. State how each was verified —
the reproduction command for a 機械検証可能 finding, or that it survived
staged refutation for a 解釈依存 one. Axes with nothing to report say so in
one line.

A finding that the lookahead fixed is reported with what its fix showed:

- 指摘 — what the review found
- 試した修正 — the change and its patch path; say when it is 試行者の案
- 修正のレビュー — whether the consequence still occurs, the side effects, the
  conflicts and interactions with other fixes, and the check results against
  the base, each with its evidence
- 推奨 — the verdict and why. For 修正案を直す, the direction of the revision;
  for 人に返す, the reason or both sides. Then 修正するときの注意.

The misses of the original review that the review of the fixes found are
reported as new findings, with the source 修正のレビュー.

On a `--fast` run no finding was fixed: report each finding's 修正案 as its
worker wrote it, labelled 未試行, or 無し.

After the axes, the closing sections:

- 全修正後の見通し — the lookahead's outlook: whether the fixes apply
  together, the checks on the combined state against the base, the issues the
  review of the fixes left open, and what the next review round is expected
  to raise. In PR mode this is the forecast of the author's next push.
- 別作業候補 — every `out-of-scope` finding from this run: the point, why it is
  out of scope (with the grep command and count), and the suggested scope of
  the separate work. These are not noise; they are true findings deliberately
  not filed against this change or this code.
- nits — every candidate whose verification ended NITS, from this review and
  from the review of the fixes, as a nit line and its two evidence lines:

  ```
  - <path:line> <指摘> / <否定理由>
    論拠 — <the evidence that the facts hold>
    否定の根拠 — <the evidence that the harm is absent or negligible now>
  ```

  指摘 says what is off. 否定理由 says why it is a nit: why the harm is absent
  or negligible now, taken from the Stage 3 reason or the Step 5c reason,
  never from the worker's 実害 alone. Write each half as one short Japanese
  sentence. 論拠 and 否定の根拠 come from Step 5b's table or Step 5c; each
  quotes its source (`path:line` with the text, `<URL>` with the sentence, or
  a command with its output line). A nit needs no impact scenario and no fix.
  For the import Automation nit of PR #3857 (Severity), the halves read
  `描画できない対象では、import Automation が bundle 段階で失敗します / 失敗は状態を変える前に起きるため、実害はありません`.
  Append `(修正のレビュー)` to a nit the review of the fixes raised. Nits are
  not findings, and are posted only as pr-mode.md Step 8 allows.
- 未深掘り — every candidate the lookahead did not fix, and why. On a
  re-review this includes every low finding, with the reason
  `2 回目以降のレビューのため、修正を試すのは high と medium のみ`.
- 未解決の疑問 — including any candidate that could not be verified at all, named
  explicitly as 未検証 rather than folded in with the verified ones.
- 実行できなかった確認 — each check the lookahead marked 実行できず, with its
  error and the exact setup command for the user.
- 後片付け — every worktree this run created, what it holds, and the exact
  removal command for the user to run (lookahead.md Step L5).

On a `--fast` run, 全修正後の見通し, 未深掘り and 実行できなかった確認 are
replaced by the one line `先読みは --fast により省略しました。修正案は試していません。`,
and 後片付け lists only `<work dir>/tree` in PR mode and code mode; local mode
has nothing to list there.

Close with the design-document alignment result.

Never claim you checked something you did not check. If an axis could not be
covered — no access to a service, documentation unavailable — say so instead of
producing a filler finding.

## Steps 8 and 9 (PR mode only)

pr-mode.md holds them. Step 8 posts only on explicit instruction in this
session. Step 9 writes the cache back, and is mandatory at the end of every
PR-mode run except `--no-cache`.

## Design documents

- A design-doc URL in the arguments feeds axis 2's docs alignment judgement,
  through the context file (Step 4).
- Confluence URLs are read through the `light-confluence` skill. Never call
  `mcp__confluence__*` directly from this review.
- A design-doc PR (for example a coincheck-docs PR) is read with
  `gh pr diff` / `gh pr view` on that repository.
- When the alignment check needs to go deeper than "does the diff contradict the
  document", delegate it to the `spec-sync` skill and cite its result here.
