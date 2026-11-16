---
name: fix-trial
description: >-
  Follow review findings past their first observation by executing them
  instead of imagining them. For each finding, in its own git worktree: show
  the claimed consequence on the base revision, apply the proposed fix, check
  mechanically that the reproduction now passes, existing checks still pass and
  no existing test was weakened (repairing the fix first when they do not),
  then re-review the post-change state with the change-review skill in local
  mode. Every new issue is classified (caused by
  the fix, still present, pre-existing, rollout-only, outside the worktree,
  trial artifact, noise), and the loop repeats until no fix-caused issue
  remains, the fixes oscillate, or the iteration limit is reached. Returns a
  per-finding verdict (残す / 取り下げ / 修正案を直す / 人に返す / 設計の問題 /
  未確認) with the causal chain that produced it. Accepts findings from any
  source: change-review --deep, human review comments, other tools. Expensive:
  one trial usually costs several times a whole review, so trial few findings.
  Never commits, pushes, posts, installs, or deletes. Triggers: "/fix-trial",
  "指摘を実際に直して確かめて", "この指摘を深掘りして", "修正してから再レビューして",
  "指摘の実効性を確かめて", "このレビューコメントは直す価値があるか試して",
  "deepen these findings", "trial-fix these review comments".
argument-hint: "<findings: ファイル|本文> [--repo <path>] [--base <rev>|<PR URL|番号>] [--limit N] [--max-iter N] [--parallel N] [--allow-setup]"
---

You run fix trials. Each trial takes one review finding and follows its causal
chain by changing the code and observing what actually happens.

Why this exists: a reviewer that only reads code stops at the first link of the
chain. It reports a condition without the consequence, rates the condition as if
it were the consequence, and proposes a fix without seeing what the fix breaks.
Asking it to think harder does not help, because a model reviewing its own
reasoning without external feedback does not reliably improve it. What helps is
putting the next link in front of the reviewer: apply the fix, run it, and review
the state that results. The chain has four directions, and a trial covers each:

| Direction | Question | Where the trial answers it |
|---|---|---|
| Forward, unfixed | What does the condition lead to, and for whom? | Reproduction on base (round.md step 2) |
| Forward, fixed | What does the fix change, break, or move elsewhere? | Observation and re-review (round.md steps 4, 5) |
| Sideways | Does the same consequence arise through another path? | round.md step 2 path search, re-review question 1 |
| Backward | Why is the code the way it is; which constraint does it satisfy? | Re-review question 3 (round.md step 5) |

A trial runs as one agent that works through a sequence of rounds: round 0
reproduces the finding on base, and round k applies and reviews fix iteration
k. At the end of every round the agent writes a round record and a state file
to the run directory, so that an interrupted trial can be resumed from files.
This file is the main session's procedure. Each trial reads only
`~/.claude/skills/fix-trial/round.md`.

## Hard rules

These bind the main session. round.md repeats the ones that bind a trial; change
both files together.

- The user's working tree is never touched. Every edit happens inside a trial
  worktree. Record `git status --porcelain` of the user's working tree in Step 0
  and again in Step 4, and report any difference.
- Never commit, push, post, merge, or stash, in the user's working tree or in a
  trial worktree. A trial's changes stay uncommitted; diffs are captured with
  `git diff`.
- Never delete anything. Do not run `rm`, `rmdir`, `unlink`, `git clean`,
  `git worktree remove`, or any other command whose purpose is deletion, even
  on byproducts or in your own scratch directory. Step 4 gives the user the
  exact removal commands to run.
- Never install tools, packages or dependencies. If a check needs a setup step
  that installs something, record the check as 実行できず together with the
  exact setup command, unless the user passed `--allow-setup` in this session.
  `--allow-setup` permits only the repository's own documented setup command,
  only inside worktrees this run created. Pointing a check at a service that is
  already running locally, through environment variables, installs nothing and
  is allowed; record the variables.
- Trial worktrees are created by Step 0 inside the run directory, outside the
  repository, so the user's checkout gains no untracked directory. Do not use
  the `Agent` tool's `isolation: "worktree"` for trials: it always branches from
  the session's own repository, which may not be the target, and it puts the
  worktree inside that repository.
- A shell does not keep its directory between calls. Run every command in a
  worktree as `cd <worktree> && ...`.
- Everything this run writes outside a worktree goes under the run directory,
  in any format except `.md`. Helper scripts are allowed there.
- Long output goes to files. Redirect every command whose output can run long
  — check, test and build runs, diffs, repository-wide searches — to a file
  under the run directory (`<command> > <file> 2>&1; echo "exit=$?"`), and read
  only the lines a decision needs with `grep -n`, `head`, `tail`, `sed -n` or
  `wc -l`. Read further whenever those lines do not settle the question.
- Evidence: cite code as `path:line` and documents as `<full URL>`. The report
  is Japanese. No emojis.

## Arguments

| Token | Meaning |
|---|---|
| findings | A JSON file in the input format below, or findings written in the prompt. |
| `--repo <path>` | The target repository root. Default: the root of the current directory's repository. |
| `--base <rev>` | The revision the findings are about. |
| PR URL or number | The findings are about that PR: the base is its head sha. |
| `--limit N` | Trial at most N findings (default 3). |
| `--max-iter N` | Fix rounds per finding before stopping (default 3). |
| `--parallel N` | Trials running at once (default 3). |
| `--allow-setup` | See Hard rules. |
| `siblings: <path>` | Set by change-review's deep trial: every surviving finding of the originating review, used as dedup context. |
| `context: <path>` | Set by change-review's deep trial: its context file. Otherwise Step 0 writes one. |
| `invoked-by: change-review` | Set by change-review's deep trial. Skip the Japanese report; change-review renders the results. |

Input format: a JSON array, one object per finding, with keys `id`, `location`
(`path:line`), `claim`, `impact`, `fix`, `axis`, `severity`, `evidence`,
`source`. Only `id`, `location` and `claim` are required. A finding with no
`fix` gets the most direct fix its claim implies, drafted inside the trial and
labelled 試行者の案.

## Step 0: Prepare (main session)

1. Run id: `trial-<UTC timestamp>`, unless change-review passed its own. Run
   directory: `<scratchpad>/fix-trial/<run id>/`.
2. Repository: `--repo`, or the root of the current directory's repository
   (`git rev-parse --show-toplevel`). Record `git -C <repo> status --porcelain`.
3. Findings: if they came in the prompt, normalize them into
   `<run dir>/input.json`. If they came from a PR's review comments, keep the
   commenter in `source`. The sibling context is `siblings:` when given,
   otherwise the input file itself.
4. Base: from `--base`, from the PR's `headRefOid`
   (`gh pr view <n> --json headRefOid`), or from change-review. Resolve it to a
   full sha with `git rev-parse <rev>^{commit}`; for a PR whose head is not
   local, run `git fetch origin "pull/<n>/head"` first. If none of the three is
   given, use `HEAD` and state that in the report's first line. Trial worktrees
   share the object store, so the sha must resolve here before any trial starts.
5. Context file: what every round and every nested review needs besides the
   finding, so that no hand-off drops it. With `context:`, use that file as is.
   Otherwise write `<run dir>/context.json` with one `Write` call, in the shape
   change-review's Step 4 defines:
   - `intent`: for a PR, `title` and `body_file`, with the body saved as
     `<run dir>/pr-body.txt` from `gh pr view <n> --json title,body`; otherwise
     `stated`, what the prompt says the change is for, verbatim
   - `design_docs`: every design-document URL in the prompt
   - `settled`: null
   - `user_constraints`: every constraint the user stated in this session,
     verbatim
   Write an empty value as null or `[]` rather than leaving a key out.
6. Checks: read the repository's CI definitions and task-runner files and list
   the commands the project itself runs to build, lint and test. Record each
   command with the `path:line` it came from, and any condition under which CI
   runs it (for example, only when certain paths change). Scope a command to the
   affected area the way CI scopes it, and say so. Do not invent commands. If
   none can be found, every check is 実行できず, and trials still run their own
   reproductions.
7. Gate: order findings by severity (high, medium, low), take the first
   `--limit`, and record the rest as 未深掘り. Never drop one silently.
8. Worktrees: for each gated finding, create a detached worktree at the base:
   `git -C <repo> worktree add --detach <run dir>/wt-<finding id> <base sha>`.
   Create one more the same way at `<run dir>/wt-base` for the baseline. Record
   each path. This only adds; nothing in the user's checkout changes.
9. Baseline: run every check once on base, in `<run dir>/wt-base`, so that no
   round runs it on base again. When CI scopes a check to an affected area, run
   it once per distinct area among the gated findings.
   - Write each run's output to `<run dir>/baseline/<check>.<scope>.out`.
   - A check is usable as an oracle only if it runs to completion here. The
     failures it reports here are the baseline; only failures that are new after
     a fix count. Identify each failure the way the tool does (test name, rule
     and file), because paths differ between worktrees.
   - A check that cannot run (missing dependency, missing service, missing
     credential) is 実行できず: record the error and, for a missing dependency,
     the setup command. Run that setup only with `--allow-setup`.
   - A check that compares against the git index or `HEAD` fails in an
     uncommitted trial by construction. Replace its comparison with a direct
     comparison of the same files, run the replacement here, and record both
     commands.
   - A check with a condition (it applies only when certain paths change) runs
     here too. Record the condition; a round applies the check only when its
     fix meets it.
   Write `<run dir>/baseline.json`: per check and scope, the command to run
   (and the command it replaced, if any), its source `path:line`, its
   condition, the scope, the status (usable or 実行できず), the exit code, the
   output path, the baseline failures, and for 実行できず the error and the
   setup command.

## Step 1: Run the trials (main session)

Each gated finding runs as one trial, in the worktree Step 0 created for it.
Launch each trial as a named teammate with the `Agent` tool, without
`isolation`, named `trial-<finding id>`. If the name is already taken in this
session, append the run id. Keep at most `--parallel` trials running; when one
finishes, launch the next waiting finding. If Agent Teams is unavailable
(`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` unset), run the trials one at a time as
single `Agent` calls.

Each trial's prompt carries:

- "Read `~/.claude/skills/fix-trial/round.md` in full and run the trial below,
  from round 0 until a round decides anything other than `continue`. Your trial
  worktree is <path>. Run every command as `cd <path> && ...`, and never write
  outside it except under the run directory."
- The finding object, verbatim, and the sibling context path.
- The base sha, the baseline file `<run dir>/baseline.json`, `--max-iter`, and
  whether `--allow-setup` was given.
- The run directory, and the result file `<run dir>/<finding id>.json`,
  written with one `Write` call as the trial's final action.
- The context file path, with the instruction to read it first and to pass it
  to change-review in step 5.

Detect a trial's completion only by its result file existing and being
non-empty.

Interruptions: a trial can stop before writing its result file, for example
when a usage limit is reached. Resume it with `SendMessage` to its name: tell
it that the trial is resumed, to continue from the first unfinished step of its
current round, and to relaunch only workers whose output file is missing or
empty. A trial that cannot be resumed this way is relaunched as a new agent
with the same prompt plus the instruction that the trial is resumed and to
follow round.md's Resuming section. A finding whose trial never completes is
reported as 未確認 with the reason 試行が完了しなかった; never fill in its
result.

## Step 2: Collect (main session)

Read every result file. Write `<run dir>/results.json`: an array of the result
objects, plus one entry per 未深掘り finding with `verdict: "未深掘り"` and the
reason. With `invoked-by: change-review`, stop here; change-review renders the
report.

## Step 3: Report (main session, Japanese)

```
深掘り N件: 残す a / 取り下げ b / 修正案を直す c / 人に返す d / 設計の問題 e / 未確認 f / 未深掘り u
対象: <repo> <base 短縮> (<base の決め方: --base / PR #n の head / HEAD>)
```

Then one section per trialed finding, as its chain:

- 最初の観察
- 試した修正 — in order, each with its patch path
- 起きたこと — per round: the trial check results, the new check failures,
  the repairs made before the re-review, and the classified issues
- 改めた理解と推奨 — the verdict, the final severity and why. For 未確認, the
  deciding fact and who holds it, then the fix outcome. List 残課題, the
  adoption conditions and the adoption notes.

Closing sections:

- 元のレビューの見落とし — every pre-existing issue, with evidence. Mark each
  one that no refuter checked as 未検証.
- 未深掘り — the findings Step 0 did not trial, and why
- 実行できなかった確認 — each check marked 実行できず, with its error and the
  exact setup command for the user
- 後片付け — see Step 4

## Step 4: Leftovers (main session)

1. Record `git -C <repo> status --porcelain` again and report any difference
   from Step 0. There should be none.
2. List the trial worktrees with `git -C <repo> worktree list --porcelain`: the
   ones under this run's directory, `wt-base` included.
3. Give the user the exact command for each, with real paths, and do not run
   it: `git -C <repo> worktree remove --force <path>` (force, because a trial
   leaves uncommitted files and byproducts). Say first what each worktree
   holds: its trial checks and, if a fix was tried, the uncommitted fix, which
   is also saved as the `final_patch` file in the run directory. `wt-base`
   holds only the baseline's byproducts. Everything else the run wrote is under
   the run directory. If a reboot or cleanup has already removed the run
   directory, the command is `git -C <repo> worktree prune` instead.
