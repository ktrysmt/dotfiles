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
  parallel, and every candidate is verified by a command or a two-stage
  refutation. Then the lookahead runs on every review: each finding is
  reproduced and fixed in its own worktree, all the fixes are reviewed in one
  batch and applied together, and the loop repeats until no fix-caused issue
  remains, so findings come with their consequences and a forecast of the next
  round. `trial:` runs only the lookahead, on findings from elsewhere such as
  another reviewer's comments. Never posts to GitHub unless told; never
  commits, pushes, installs, or deletes. Triggers: "PRをレビューして",
  "これを以下の要領でレビューせよ", "/change-review", "前回の続きからレビューして",
  "この差分をレビューして", "ローカルの変更をレビューして",
  "このコードの問題点を洗い出して", "PRなしでこのコードをレビューして",
  "指摘を実際に直して確かめて", "次のレビューを先読みして",
  "このレビューコメントは直す価値があるか試して", "review this PR",
  "review this diff", "review this code".
argument-hint: "<PR URL|番号> [設計書URL...] [--fresh] [--no-cache] [--max-iter N] [--parallel N] [--allow-setup]"
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

This file holds what every run needs. Three parts live beside it and are read
only when they apply:

| File | Read by, when | Holds |
|---|---|---|
| `~/.claude/skills/change-review/pr-mode.md` | The main session, when Step 0 resolves PR mode | The GitHub rules, the cache (Step 1 and its schema), the PR fetch (Step 2), posting (Step 8), the cache write-back (Step 9) |
| `~/.claude/skills/change-review/lookahead.md` | The main session, at Step 6b, on every run except a nested review | The lookahead: per-finding worktrees, the combined worktree, the batched review, the loop |
| `~/.claude/skills/change-review/round.md` | Each per-finding agent the lookahead starts; never the main session | The rounds of one finding |

A nested review is a run marked `invoked-by: lookahead`: the lookahead runs it
to review its own fixes. It is local mode, skips Step 6b, and reads none of the
three files.

Follow the steps below literally and in order. Do not improvise a shorter path.
This skill exists to prevent three expensive failures: re-fetching a PR's
entire state from zero on every session, re-raising findings the author already
answered, and reporting a first observation as if its consequences had been
followed. The third one is not solved by asking reviewers to think harder; a
reviewer that only reads code stops at the first link of the causal chain, the
author fixes what it saw, and the next round finds what the fixes broke. Step 6b
follows the chain on every run by executing every fix and reviewing what the
fixes actually changed, one by one and together. It costs one agent per
finding plus one batched review per round.

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
- The final report to the user is written in Japanese. No emojis anywhere, in
  this file's outputs or in anything posted.

## Arguments

| Token | Meaning |
|---|---|
| PR URL or number | Target PR. Optional; see Step 0. |
| Any other URL | Design document. Used for axis 2 (docs alignment). |
| `--fresh` | PR mode. Ignore the existing cache, refetch everything, rebuild the cache. |
| `--no-cache` | PR mode. Neither read nor write the cache for this run. |
| `--max-iter N` | Lookahead fix rounds per finding before stopping (default 3). It also bounds the number of batched reviews. |
| `--parallel N` | Lookahead per-finding agents working at once (default 3). |
| `--allow-setup` | Lets the lookahead run the repository's own documented setup command inside the worktrees it created (lookahead.md). |
| `trial:` | A JSON file of findings, or findings written in the prompt, from outside this review (another reviewer's comments, another tool). Steps 3 to 6 are skipped, and Step 6b runs the lookahead on these findings against the resolved target. Format: lookahead.md Step L0. |

Local mode reads these fields from the prompt, one per line:

| Field | Meaning |
|---|---|
| `repo:` | Absolute path of the repository or worktree root. Required, unless `targets:` is given. |
| `base:` | Base revision. Required. |
| `target:` | `worktree` (the working tree of `repo`, untracked files included) or a revision. Required, unless `targets:` is given. |
| `targets:` | Optional, set by the lookahead. Path of a JSON array; each entry `{"id", "repo", "exclude"}` names one worktree that holds one fix on top of `base`, reviewed as `target: worktree`. An entry may add `diff`, the path of a prebuilt diff of its own fix, and `stacked_on`, the ids of other fixes whose changes its worktree also holds, whether or not they are targets (lookahead.md Step L3). Replaces `repo:`, `target:` and `exclude:`. Requires `output:`. |
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

1. Local mode: if the prompt names `repo:`, `base:` and `target:`, or `base:`
   and `targets:`, enter local mode. In `repo` (with `targets:`, in each
   entry's `repo`), resolve `base` to a full sha with
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
   Steps 1 and 2 replace Step 2 below, and its Steps 8 and 9 run after Step 7.
8. With `trial:`, run Step 2 (or pr-mode.md's Steps 1 and 2) and Step 4's
   context file, then go to Step 6b.

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

With `targets:`, build one diff per entry exactly as for `target: worktree`,
run in the entry's `repo` and leaving out the paths in the entry's `exclude`
file, into `<work dir>/diff.<id>.patch`. An entry with `diff` uses that file
instead: its worktree also holds the changes of the fixes in `stacked_on`,
which a diff against `base` would attribute to it. Then write
`<work dir>/targets.json`: per entry, its `id`, its `repo`, its diff path and
its `stacked_on`. Each entry's post-change state is the tree under its own
`repo`.

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

## Step 4: Parallel fan-out — one agent per axis

Step 2 wrote what is under review to the work directory — `diff.patch`,
`targets.json`, or `files.txt` — so the agents read a path, not a pasted blob.

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
can tell "none" from "not passed". Every worker, every refuter, every
per-finding agent and every nested review receives the path.

The deduplication context:
- PR mode: the cache file itself
  (`~/.claude/pr-context/<owner>__<repo>__<number>.md`) — pass that path. Do not
  copy its 既出の指摘 / 確定した設計判断 / 他レビュアの指摘 sections into a
  second scratchpad file. On a first review, pass `<work dir>/comments.json`
  instead. With `--no-cache` and no comments, there is no dedup context, and the
  agents are told so explicitly.
- Local mode and code mode: the `findings:` file if given; otherwise there is
  none, and the agents are told so explicitly.

Fan the axes out to parallel workers, one per axis. One named teammate per axis
is the default: two or more parallel tasks must go through Agent Teams, and
`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is exported from `.zshenv`. Spawn each
teammate with the `Agent` tool and a `name` that identifies its axis
(`axis1-security`, `axis2-consistency`, `axis3-robustness`, `axis4-ops`, or
`axis<N>-<slug>` for prompt-supplied axes) so it stays addressable through
`SendMessage`. There is no separate team-creation step: as of Claude Code
v2.1.178 the team is implicit and `TeamCreate` no longer exists. Only if Agent
Teams is unavailable — the env var is unset, or this session is itself a
teammate and cannot nest — fall back to plain `Agent`
(`subagent_type: general-purpose`) launches issued in a single message.

Worker names: with `name-prefix:`, every worker name is `<prefix>-<name>`. A
plain `Agent` call has no `name`, so state the name in the worker's prompt; it
names the worker's scratch directory. If a teammate name is already taken in
this session, append the run id.

Each worker's deliverable is a file: `<work dir>/axis<N>.txt`, written with one
`Write` call as its final action. Detect completion only by that file existing
and being non-empty, never by a reply or a notification.

Each worker's prompt carries, verbatim:

- The target: `<owner>/<repo>#<number>` and the head sha,
  `local <repo> <base sha>..<target>`, `local <base sha>, <N> targets`, or
  `code <repo> <rev sha> <paths>`.
- What to read:
  - PR mode and local mode: the diff file path, whether it is the full diff or
    an incremental diff between two shas, and where the post-change files are
    read: `<work dir>/tree` in PR mode, `repo` in local mode.
  - With `targets:`: the `targets.json` path, and: "Each target is `base` plus
    one separate fix, in its own worktree; the author will push all of them
    together. Review each target's diff against `base` on its own, reading the
    post-change files under that target's `repo`, and tag every finding with
    `target — <id>`. An issue that arises only from two or more targets
    together is tagged with every id involved. A target with `stacked_on` is
    built on the fixes it lists: its diff holds only its own change, and its
    tree holds theirs as well."
  - Code mode: the file list `<work dir>/files.txt` and the tree
    `<work dir>/tree`, and: "There is no diff. The whole of the listed code is
    under review, as it stands at this revision: read every listed file, what
    it calls, and what calls it."
- The dedup context path, plus this instruction: nothing listed under 既出の指摘
  or 確定した設計判断, or in the `findings:` file, may be raised again;
  `accepted-tradeoff` entries are closed unless there is a purely technical
  residue worth stating, which must be labelled as such.
- The one axis it owns, quoted from Step 3 or from `axes:`.
- The `questions:` text, if given.
- The context file path, and: "Read the context file first. Its design
  documents feed axis 2 above all. Its intent is what the change or the code is
  meant to do; judge it against that. Its settled decisions are closed like
  確定した設計判断. Its user constraints bind you."
- "Ground every finding in a primary source — the aws-docs MCP for AWS
  behaviour, official documentation, or the repository's own code cited as
  path:line. Do not write anything you inferred. Read-only: never post to
  GitHub, never modify files under review. If you need to run something, copy
  what you need into your own scratch directory `<work dir>/<your name>-scratch/`
  and work there. Write nothing outside that directory except your output
  file. Never run `rm`, `rmdir`, `unlink`, `git clean` or any other deleting
  command, not even in your scratch directory."
- "Redirect the output of every command that can run long — test, lint and
  build runs, repository-wide greps, `git log -L`, `git blame` — to a file in
  your scratch directory, and read only the lines you need from it with
  `grep -n`, `head`, `tail`, `sed -n` or `wc -l`. Read further whenever those
  lines do not settle the question. This limits what you print, not what you
  examine: read the diff and the files under review as fully as the review
  needs."
- "Report every issue you observe. Leaving one out because it would cost
  someone more work — the author, a later fix, another review round — is a
  defect of the review."
- "If you argue from repository convention — that sibling stacks do or do not do
  something — grep the WHOLE repository from its root, not just the subtree under
  review, and report the command and the hit count. A subtree-scoped convention
  claim is treated as unsupported."
- "Mark each finding as 機械検証可能 or 解釈依存. 機械検証可能 means a command
  reproduces it deterministically (a linter that fails, a template that will not
  render, a value that differs between two files, a grep that returns zero) —
  state the exact command. 解釈依存 means it rests on reading documentation, a
  threat model, or a judgement about intent. Step 5 routes the two differently."
- "Name the concrete change that would remove the problem in 修正案. If you
  cannot name one, write 無し; the lookahead then drafts the most direct fix
  the claim implies."
- In a nested review: "For each finding, state in 基点で成立 whether the same
  issue already holds at the base revision (はい, いいえ or 不明), with the
  command or `path:line` that shows it. State in 元の帰結 whether the finding
  says that the consequence of an entry of the `findings:` file whose `target`
  is this finding's target still occurs after the change, through the same
  path or another: that entry's id, or いいえ."
- The output file path, and the instruction to write it with one `Write` call as
  the final action.

Each worker writes a list of findings in this shape, and nothing else:

```
- file:line — <path:line>
  severity — high|medium|low
  要旨 — <one line>
  根拠URL — <...>
  影響シナリオ — <concrete trigger or failure path>
  検証区分 — 機械検証可能 (<command>) | 解釈依存
  修正案 — <the concrete change, or 無し>
  基点で成立 — はい | いいえ | 不明 (<evidence>)   (only in a nested review)
  元の帰結 — <findings: entry id> | いいえ   (only in a nested review)
  target — <id, or ids separated by commas>   (only with targets:)
```

Severity at this stage is provisional: it rates the first observation. Step 6b
replaces it with the severity of the last link of the chain the lookahead
actually materialized.

## Step 5: Verification phase

No candidate reaches the report unverified. This phase is not optional; it is the
part of the review the user actually asks for. But do not spawn one refuter per
candidate blindly — twenty candidates would mean twenty agents, and for a large
share of them an agent is the weaker instrument. Route each candidate by the
機械検証可能 / 解釈依存 label it carried out of Step 4.

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
  files from `repo` (with `targets:`, from the `repo` of the candidate's
  target) into the scratch directory instead of archiving a sha.
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

### Step 5b: Two-stage refutation (for 解釈依存 candidates)

In a nested review, two kinds of candidate skip this step, because they cannot
change the lookahead's verdict:
- a candidate whose 基点で成立 is はい: it goes to the output with
  `verification: 未検証(基点でも成立)`, and the lookahead reports it as an
  unverified miss of the original review;
- a candidate that matches an entry of the `findings:` file whose cited lines
  did not change: run Step 6 on it first and carry the entry's earlier result.

Neither applies to a candidate whose 元の帰結 names an entry. Such a candidate
says that a fix left its finding's consequence in place, often through another
path that also exists at the base revision, and it sends that finding into
another round (round.md step 6, still-present). An earlier result about the
base revision says nothing about the fixed state. Verify it like any other
candidate.

One independent worker per candidate. Two or more candidates means two or more
parallel tasks, so spawn one named teammate per candidate with the `Agent` tool,
named `refute-<finding id>`; a single candidate may go to a single `Agent` call.
If this session is itself a teammate, issue plain `Agent` calls in a single
message instead. Pass the candidate, the diff path, the target identifier, the
dedup context path, and the output file `<work dir>/refute-<id>.txt`, written
with one `Write` call as the worker's final action. The context file, scratch,
output-file and no-delete instructions of Step 4 go into each refuter's prompt
verbatim.

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

Stage 2 — runs only if the facts survived Stage 1. PR mode and local mode: "The
facts hold. Now judge scope only: is this a defect introduced or left by THIS
change, or is it a repository-wide gap and a hardening proposal that happens to
be visible here? Grep the whole repository (see Hard rules) to decide. Also
check whether the prior review already settled it." Code mode: "The facts hold.
Now judge scope only: does the defect lie in the code under review — the listed
paths, or how they use what they call — or entirely outside it? A defect that
also exists elsewhere in the repository is still in scope when it exists in the
code under review. Also check whether the `findings:` file already settled it."

Verdicts and what to do with each:

| Stage 1 | Stage 2 | Verdict | Action |
|---|---|---|---|
| refuted | not run | REFUTED | Drop. Cache as `withdrawn` with the refuting evidence, so no future run raises it. |
| survived | PR-specific, or in the code under review | SURVIVES | Report it. Attach the refutation attempt's evidence to strengthen the write-up. |
| survived | repo-wide, outside the code under review, or already settled | OUT-OF-SCOPE | Do NOT drop. Cache as `out-of-scope` and report it under 別作業候補 with the evidence that put it there. |

A finding whose facts hold is never discarded merely for being broader than this
change. That is a routing decision, not a refutation, and throwing it away loses
real work — the refuter has already established it is true.

Each worker writes exactly:

```
stage1_facts — REFUTED | SURVIVES
stage1_理由 — <2-4 lines, Japanese>
stage2_scope — PR固有 | 対象コード内 | リポジトリ横断 | 対象コード外 | 既決着 | 未実施
stage2_理由 — <2-4 lines, Japanese; include the repo-wide grep command and count>
verdict — REFUTED | SURVIVES | OUT-OF-SCOPE
決定的な証拠 — <path:line or <URL>, quoting the exact text relied on>
残余 — <narrower true point if any, else 無し>
```

Report honestly which attack angles failed. A refuter that confirms the quoted
documentation is verbatim real, or that the premise holds, has produced evidence
worth carrying into the write-up.

## Step 6: Deduplication

Match every surviving finding against the dedup context. In PR mode that is the
three cache sections: 既出の指摘, 確定した設計判断, 他レビュアの指摘. In local
mode and code mode it is the `findings:` file. When the context file's
`settled` is not null, also match against the decisions it holds. Match on
`file:line` plus semantic equivalence of the 要旨, not string equality — the
same defect moves lines between pushes.

- Matches an `open` entry: not new. Report it as a reminder in the 既出 section,
  do not restate it as a fresh finding.
- Matches `resolved` / `withdrawn` / `out-of-scope` / `accepted-tradeoff` / a
  確定した設計判断: suppress. The one exception is the canonical clause — if there
  is a genuine purely technical point left, raise it and say explicitly that it is
  being raised despite the accepted tradeoff, and why.
- Matches another reviewer's finding: merge them into one entry, credit the
  other reviewer, and drop ours if theirs is equivalent or stronger.
- Local mode, matches an entry of the `findings:` file: not new. Mark it
  `still-present: <that id>` and keep the evidence that the listed problem still
  occurs in the post-change state. The lookahead uses this to see whether a fix
  actually removed the problem.
- With `targets:`, an entry of the `findings:` file may carry `target`. A
  candidate is `still-present` only for an entry whose `target` equals the
  candidate's target. A match with any other entry is not new and is
  suppressed, because every other finding is expected to hold in a worktree
  that does not fix it.

## Step 6b: Lookahead (every run)

Runs on every run except a nested review, because a nested review is the
lookahead reviewing its own fixes and a second lookahead inside it would loop.
Read `~/.claude/skills/change-review/lookahead.md` in full and follow it.

## Step 7: Report

On a call with `output:`, write the surviving findings to that path as a JSON
array with one `Write` call, and stop. A finding raised by several axis workers
is one object. Each object has these keys:

| Key | Content |
|---|---|
| `id` | A fresh id, `R-<n>`, unique within this output file |
| `location` | file:line |
| `severity` | high, medium or low |
| `claim` | 要旨 |
| `evidence` | 根拠URL |
| `impact` | 影響シナリオ |
| `verification_kind` | 機械検証可能 or 解釈依存 |
| `fix` | 修正案 |
| `axes` | Array of the axis numbers whose workers raised it |
| `verdict` | CONFIRMED, SURVIVES or OUT-OF-SCOPE |
| `still_present` | The matched `findings:` id, or null |
| `base_holds` | 基点で成立: はい, いいえ or 不明, with its evidence |
| `original_consequence` | 元の帰結: the `findings:` entry id, or null |
| `verification` | The reproduction command, `2段反証`, or `未検証(基点でも成立)` |
| `target` | With `targets:`, the target id, or an array of ids for an issue that arises from several targets together; otherwise null |

Do not write the Japanese report in that case.

Otherwise the report is Japanese. Open with the summary lines, then one
chapter per axis.

```
新規 N件 / 既出につき抑制 M件 / 反証により却下 K件 / 別作業候補 S件 / 未深掘り U件
先読み T件: 残す a / 取り下げ b / 修正案を直す c / 人に返す d / 設計の問題 e / 未確認 f / まとめたレビュー r 回
対象: <owner>/<repo>#<number> <head sha 短縮> (前回レビュー: <sha 短縮> / <日付>)
```

In local mode the third line is `対象: <repo> <base 短縮>..<target>`. In code
mode it is `対象: <repo> <rev 短縮> <paths>`. With `trial:`, the first line is
omitted and the findings are grouped by source instead of by axis.

Then, per axis: each finding as `path:line`, severity, the point, the evidence
URL in `<...>`, and the concrete impact scenario. State how each was verified —
the reproduction command for a 機械検証可能 finding, or that it survived
two-stage refutation for a 解釈依存 one. Axes with nothing to report say so in
one line.

A finding that the lookahead trialed is reported as its chain, not as a point:

- 最初の観察 — what the review saw first
- 試した修正 — each fix applied, in order, each with its patch path
- 起きたこと — per round: the trial check results, the new check failures, the
  repairs made before the review, the interaction issues with other fixes, and
  the classified issues, with the commands and exit codes
- 改めた理解と推奨 — the verdict, the final severity and why. For 未確認, the
  deciding fact and who holds it, then the fix outcome. List 残課題, the
  adoption conditions and the adoption notes.

After the axes, the closing sections:

- 全修正後の見通し — the lookahead's outlook: whether the adoptable fixes apply
  together, the checks on the combined state against the base, the interaction
  issues still open, and what the next review round is expected to raise. In
  PR mode this is the forecast of the author's next push.
- 別作業候補 — every `out-of-scope` finding from this run: the point, why it is
  out of scope (with the grep command and count), and the suggested scope of
  the separate work. These are not noise; they are true findings deliberately
  not filed against this change or this code.
- 未深掘り — every candidate the lookahead did not trial, and why.
- 未解決の疑問 — including any candidate that could not be verified at all, named
  explicitly as 未検証 rather than folded in with the verified ones.
- 実行できなかった確認 — each check the lookahead marked 実行できず, with its
  error and the exact setup command for the user.
- 後片付け — every worktree this run created, what it holds, and the exact
  removal command for the user to run (lookahead.md Step L7).

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
