# change-review: lookahead (Step 6b)

change-review's Step 6b sends you here on every run except a nested review.
Every rule in SKILL.md still applies; the rules below add to them.

The lookahead takes every surviving finding, fixes each one in its own
worktree, and reviews all the fixed states in one batch, so that what the next
review round would raise is seen before the author pushes.

Why: a reviewer that only reads code stops at the first link of the chain. It
reports a condition without the consequence, rates the condition as if it were
the consequence, and proposes a fix without seeing what the fix breaks. The
author fixes, pushes, and the next review finds what the fixes broke, round
after round. Asking the reviewer to think harder does not help, because a model
reviewing its own reasoning without external feedback does not reliably improve
it. What helps is putting the next link in front of the reviewer: apply the fix,
run it, and review the state that results.

Two choices follow from that, and both are deliberate:

- Every finding is trialed. A finding left at its first observation is exactly
  what makes the next round necessary, so there is no count limit.
- Fixes are applied separately and reviewed together. One worktree per finding
  makes every new issue attributable to one fix without bisecting. One batched
  review per round, instead of one review per finding, keeps the cost of a
  round near that of a single review. One combined worktree per round applies
  every fix at once, because the author pushes them together.

The chain has five directions, and the lookahead covers each:

| Direction | Question | Where it is answered |
|---|---|---|
| Forward, unfixed | What does the condition lead to, and for whom? | Reproduction on base (round.md step 2) |
| Forward, fixed | What does the fix change, break, or move elsewhere? | Observation (round.md step 4), batched review questions 2 and 4 (Step L3) |
| Sideways | Does the same consequence arise through another path? | round.md step 2 path search, batched review question 1 |
| Backward | Why is the code the way it is; which constraint does it satisfy? | Batched review question 3 |
| Together | Do the fixes, applied together, conflict or break each other? | Combined worktree (Step L2), batched review question 6 |

## Flow

| Step | Who | What |
|---|---|---|
| L0 | Main session | Candidates, base, checks, one worktree per finding, baseline |
| L1 | One agent per finding | Round 0 (reproduce on base), then round 1 up to its hand-off (fix, observe) |
| L2 | Main session | The round's combined worktree: apply every fix together, run the checks |
| L3 | Main session | One nested review of every worktree whose fix changed this round |
| L4 | Main session, then each agent | Route the issues; each agent classifies, decides, and runs its next round up to the hand-off |
| L5 | Main session | Repeat Steps L2 to L4 while any finding continues, then collect |
| L6 | Main session | Fold the results into this review |
| L7 | Main session | Leftovers |

Each per-finding agent reads only `~/.claude/skills/change-review/round.md`.
At the end of every half-round it writes files to the run directory, so that an
interrupted agent can be resumed from files.

## Rules

These bind the main session during the lookahead. round.md repeats the ones
that bind an agent; change both files together.

- The user's working tree is never touched. Every edit happens inside a
  worktree the lookahead created. Record `git status --porcelain` of the
  user's working tree in Step L0 and again in Step L7, and report any
  difference.
- Changes in a worktree stay uncommitted; diffs are captured with `git diff`.
- Every worktree the lookahead creates is new and holds one state. Never reset
  or reuse a worktree for another state, because that would need a deleting
  command. Each round's combined worktree gets its own directory.
- If a check needs a setup step that installs something, record the check as
  実行できず together with the exact setup command, unless the user passed
  `--allow-setup` in this session. `--allow-setup` permits only the
  repository's own documented setup command, only inside worktrees the
  lookahead created. Pointing a check at a service that is already running
  locally, through environment variables, installs nothing and is allowed;
  record the variables.
- Worktrees are created inside the run directory, outside the repository, so
  the user's checkout gains no untracked directory. Do not use the `Agent`
  tool's `isolation: "worktree"`: it always branches from the session's own
  repository, which may not be the target, and it puts the worktree inside
  that repository.
- A shell does not keep its directory between calls. Run every command in a
  worktree as `cd <worktree> && ...`.

## Step L0: Prepare (main session)

1. Candidates:
   - After a review: every finding new in this run whose verdict is CONFIRMED
     (Step 5a) or SURVIVES (Step 5b), with or without a 修正案. OUT-OF-SCOPE
     findings are not trialed; they stay under 別作業候補. Order them by
     provisional severity (high, medium, low), then by axis number.
   - With `trial:`: the given findings, normalized into the format below, with
     the commenter in `source` when they came from a PR's review comments.
     Order them by severity, keeping the input order within a severity.
   - After an unchanged PR (pr-mode.md Step 2): the cache's `open` findings
     that have no row in 修正の試行, normalized into the format below. The
     cache holds no severity, so order them by id.
   Every candidate is trialed. This order launches the agents. Step L2 orders
   the fixes again by the severity each round 0 measured, because a cache
   finding or a `trial:` finding may carry none.
2. Base, the state the findings are about:
   - PR mode: `headRefOid`. Confirm it resolves with
     `git cat-file -e <sha>^{commit}`; if not, run
     `git fetch origin "pull/<number>/head"` first.
   - Local mode with a revision `target`: that revision's sha.
   - Code mode: the `rev` sha.
   - Local mode with `target: worktree`: a worktree the lookahead creates
     starts from a commit and cannot hold the user's uncommitted changes, so
     no trial runs. List every candidate under 未深掘り with that reason, and
     go to Step 7 of SKILL.md.
3. Run directory: `<work dir>/lookahead/`. Repository: in PR mode, the local
   clone of the PR's base repository, whose `origin` is
   `https://github.com/<owner>/<repo>.git`: the current directory's repository
   when it is that clone, otherwise ask the user for its path. In local mode
   and code mode, `repo`. Record `git -C <repo> status --porcelain`.
4. Write the candidates to `<run dir>/input.json`: a JSON array, one object per
   finding, with keys `id`, `location` (`path:line`), `claim` (要旨), `impact`
   (影響シナリオ), `fix` (修正案, or null for 無し), `axis`, `severity`,
   `evidence` (根拠URL), `source` (`change-review`, or the origin of a `trial:`
   finding). Only `id`, `location` and `claim` are required. A finding with no
   `fix` gets the most direct fix its claim implies, drafted by its agent and
   labelled 試行者の案. Write every surviving finding of this review, trialed or
   not, in the same shape to `<run dir>/siblings.json`, so the nested reviews
   do not report them again as new. In PR mode, add every entry of the
   cache's 既出の指摘 to it as well, whatever its status.
5. Context file: the one SKILL.md Step 4 wrote, or the `context:` given.
6. Checks: read the repository's CI definitions and task-runner files and list
   the commands the project itself runs to build, lint and test. Record each
   command with the `path:line` it came from, and any condition under which CI
   runs it (for example, only when certain paths change). Scope a command to the
   affected area the way CI scopes it, and say so. Do not invent commands. If
   none can be found, every check is 実行できず, and the agents still run their
   own reproductions.
7. Worktrees: for each finding, create a detached worktree at the base:
   `git -C <repo> worktree add --detach <run dir>/wt-<finding id> <base sha>`.
   Create one more the same way at `<run dir>/wt-base` for the baseline. Record
   each path. This only adds; nothing in the user's checkout changes.
8. Baseline: run every check once on base, in `<run dir>/wt-base`, so that no
   round runs it on base again. When CI scopes a check to an affected area, run
   it once per distinct area among the findings.
   - Write each run's output to `<run dir>/baseline/<check>.<scope>.out`.
   - A check is usable as an oracle only if it runs to completion here. The
     failures it reports here are the baseline; only failures that are new after
     a fix count. Identify each failure the way the tool does (test name, rule
     and file), because paths differ between worktrees.
   - A check that cannot run (missing dependency, missing service, missing
     credential) is 実行できず: record the error and, for a missing dependency,
     the setup command. Run that setup only with `--allow-setup`.
   - A check that compares against the git index or `HEAD` fails in an
     uncommitted worktree by construction. Replace its comparison with a direct
     comparison of the same files, run the replacement here, and record both
     commands.
   - A check with a condition (it applies only when certain paths change) runs
     here too. Record the condition; a round applies the check only when its
     patch meets it.
   Write `<run dir>/baseline.json`: per check and scope, the command to run
   (and the command it replaced, if any), its source `path:line`, its
   condition, the scope, the status (usable or 実行できず), the exit code, the
   output path, the baseline failures, and for 実行できず the error and the
   setup command.

## Step L1: Start the agents (main session)

Each finding runs as one agent, in the worktree Step L0 created for it. Launch
each as a named teammate with the `Agent` tool, without `isolation`, named
`lookahead-<finding id>`. If the name is already taken in this session, append
the run id. Keep at most `--parallel` agents working at once; when one reaches
its hand-off or finishes, launch the next waiting finding. If Agent Teams is
unavailable (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` unset), run the agents one
at a time as single `Agent` calls.

Each agent's prompt carries:

- "Read `~/.claude/skills/change-review/round.md` in full and run the rounds
  for the finding below. Start at round 0, and stop at your first hand-off
  (step 5) or when the trial ends. Your worktree is <path>. Run every command
  as `cd <path> && ...`, and never write outside it except under the run
  directory."
- The finding object, verbatim, and the sibling context path.
- The base sha, the baseline file `<run dir>/baseline.json`, `--max-iter`, and
  whether `--allow-setup` was given.
- The run directory, the hand-off file pattern
  `<run dir>/<finding id>.handoff.<k>.json`, and the result file
  `<run dir>/<finding id>.json`, each written with one `Write` call as the final
  action of its half-round.
- The context file path, with the instruction to read it first.

An agent's half-round is done when its hand-off file for that round, or its
result file, exists and is non-empty. Detect it only that way. Go to Step L2
only when every finding is done with round 1's first half; a finding that round
0 withdrew is done with a result file.

Interruptions: an agent can stop before writing its file, for example when a
usage limit is reached. Resume it with `SendMessage` to its name: tell it that
the work is resumed, to continue from the first unfinished step of its current
half-round, and to relaunch only workers whose output file is missing or empty.
An agent that cannot be resumed this way is relaunched as a new agent with the
same prompt plus the instruction that the work is resumed and to follow
round.md's Resuming section. A finding whose agent never completes is reported
as 未確認 with the reason 試行が完了しなかった; never fill in its result.

## Step L2: Combined worktree (main session, round k)

The author pushes every fix at once. This step builds that state and runs the
checks on it. It does not review it; Step L3 does.

1. Create `git -C <repo> worktree add --detach <run dir>/wt-all.<k> <base sha>`.
2. Patches: for each finding, take its latest patch whose observation was
   clean (every trial check passes, no new check failure, no weakened test):
   the patch of its round-k hand-off, or, for a finding that has already
   finished, the `final_patch` of its result file when
   `final_observation_clean` is true. Every other finding is excluded; record
   it with the reason (withdrawn, no clean patch).
3. The apply order: the findings by the `severity` in their
   `<finding id>.state.0.json` (high, medium, low), then by Step L0's order.
   Fix it in round 1 and keep it in later rounds, so that the owner of a
   conflict does not change between rounds only because the order did. A
   stacked patch (round.md, Stacking) moves to just after the last patch in its
   `stacked_on`.
4. Apply the patches in the apply order. For each: run
   `cd <run dir>/wt-all.<k> && git apply --check <patch> > <file> 2>&1; echo "exit=$?"`,
   and when it passes, `git apply <patch>`. A patch that does not apply is a
   conflict: record it, its output, and the patches applied before it that
   touch the same paths (`git apply --numstat`). Do not apply it; go on with
   the next one. A stacked patch applies only when every patch in its
   `stacked_on` was applied here and its `git hash-object` equals the one
   recorded in the stacked patch's hand-off or result file. Otherwise it is a
   conflict too, a stale stack, and is not applied.
5. Run every usable check whose condition the applied patches meet, and every
   trial check of the applied patches, with the command its agent recorded.
   Write the outputs to `<run dir>/combined.<k>.<check>.out`, and compare the
   failures with the baseline by the identity the tool reports.
6. Interaction issues: a conflict from item 4; a check failure that is neither
   in the baseline nor in the round-k observation of any single worktree (from
   the hand-off files); a trial check that fails here but passed in its own
   worktree.
7. Owner of each interaction issue: the finding whose patch has to change.
   - A conflict: the patch that did not apply. It owns the issue even when
     every counterpart has finished, because it can stack on their patches.
   - A failure: create `<run dir>/wt-bisect.<k>.<n>` the same way, one per
     distinct failing check, apply the same patches in the same order, and run
     only that check after each apply. The patch after which it first fails is
     the owner; the earlier patches touching the same paths are its
     counterparts.
   - An owner that has already finished keeps the issue. No other finding can
     change its patch, so never hand the issue to one. Step L4 reopens the
     owner, unless k equals `--max-iter`; then the issue stays open and goes to
     the outlook, naming the owner.
8. Write `<run dir>/combined.<k>.json`: the apply order, the applied patches,
   the excluded findings, the conflicts, each check's result against the
   baseline, and the interaction issues with their owner, counterparts and
   evidence paths.

## Step L3: Batched review (main session, round k)

1. Targets: every finding with a round-k hand-off, that is, every finding whose
   fix changed this round. Write `<run dir>/review.<k>.targets.json`: per
   target, `id` (the finding id), `repo` (its worktree), `exclude` (its
   byproducts file). For a hand-off with `stacked_on`, add `diff` (the
   hand-off's patch) and `stacked_on` (the counterparts' ids).
2. Known findings: write `<run dir>/review.<k>.known.json`: the sibling
   context, every candidate tagged with `target` set to its own id, and every
   ledger entry from each finding's latest state file tagged with that
   finding's id. Nothing in it may be raised again as new.
3. Run a nested review: follow SKILL.md from Step 0 to Step 7 again, as a
   separate run, with these local-mode fields. Do not invoke the `Skill` tool
   for it.
   - `base:` the base sha
   - `targets:` the targets file
   - `workdir:` `<run dir>/review.<k>/`
   - `name-prefix:` `la-r<k>`
   - `context:` the context file
   - `axes:` round 1 — omit, so all four canonical axes run, because the first
     round is the one most likely to surface what the original review missed.
     Later rounds — the union of the `axes` in this round's hand-offs.
   - `findings:` the known-findings file
   - `output:` `<run dir>/review.<k>.json`
   - `invoked-by: lookahead`
   - `questions:`, verbatim, with the path filled in:
     1. "Does the original consequence still occur after this change, through
        the same path or any other? Name any other path concretely, and say
        whether it also exists on the base revision."
     2. "Which assumption, invariant, caller, or operational practice did this
        change break or move? Trace it to its consequence, and to whom."
     3. "Why was the changed code written the way it was? Read the history of
        the changed lines (`git log -L`, `git blame`) and the commits, PRs or
        documents it points to. Does this change violate that reason?"
     4. "What new risk, cost, or behaviour change did this change introduce,
        and who carries it?"
     5. "Report every issue you observe. Whether it would prolong the fix loop
        is not your concern; leaving one out because of that is a defect of
        the review."
     6. "The author will push all of these targets together. Does any group of
        them conflict, duplicate each other, or break an assumption another one
        relies on? Tag such an issue with every target id involved. The
        mechanical result of applying them together is
        `<run dir>/combined.<k>.json`."
4. The nested review ends by writing the `output:` file. Detect it only by its
   existing and being non-empty.

## Step L4: Route the issues (main session, round k)

1. Split `<run dir>/review.<k>.json` by `target`. An issue with one target goes
   to that finding's `<run dir>/<finding id>.review.<k>.json`; write `[]` for a
   target with none.
2. An issue with several targets is an interaction issue. Its owner is the
   involved finding whose patch changed most recently; on a tie, the one later
   in Step L2's apply order. The other involved findings are its
   counterparts.
3. Reopened findings: every finished finding that Step L2 left as the owner of
   an interaction issue this round. Write `[]` as its
   `<run dir>/<finding id>.review.<k>.json`.
4. Write `<run dir>/<finding id>.interactions.<k>.json` for every target and
   every reopened finding: the interaction issues it owns from Step L2 and from
   item 2, each with its counterparts' current patch paths and their
   `git hash-object`, and the evidence. Write `[]` when there are none.
5. Send each target's agent, with `SendMessage` to its name, the two file paths
   and the instruction to continue at round.md step 6. Send each reopened
   finding's agent the same, and that it is reopened at round k. Keep at most
   `--parallel` agents working at once. An agent that cannot be reached is
   relaunched as Step L1's Interruptions describe.
6. Each agent then ends with either its round k+1 hand-off or its result file.
   A reopened finding's earlier result file is still there, so it is done only
   when its round k+1 hand-off exists or its result file's `round` equals k.
   Wait until every target and every reopened finding is done.

## Step L5: Loop and collect (main session)

While any finding has a round-k+1 hand-off, run Steps L2 to L4 for round k+1.
When every finding has a result file:

1. Read every result file. Write `<run dir>/results.json`, an array of the
   result objects.
2. Write `<run dir>/outlook.json` from the last round's combined file: the
   patches that apply together, the conflicts, each check's result on the
   combined state against the baseline, the interaction issues still open
   (including every `interactions_unresolved` entry of the results), the
   excluded findings with reasons, and every finding's `residual_issues`. This
   is the forecast of what the next review round will raise.

## Step L6: Fold the results into this review (main session)

Per trialed finding, replace the provisional severity with the result's and
apply its verdict:

| Verdict | Cache status | What the report carries |
|---|---|---|
| 残す | open | The chain and the converged fix |
| 取り下げ | withdrawn | The reproduction that did not show the consequence, or the other path that already reaches it |
| 修正案を直す | open | The revised 修正案 |
| 人に返す | open, plus an entry in 未解決の疑問 | Both sides of the tradeoff |
| 設計の問題 | superseded, by a new finding that states the design-level problem | Every issue each iteration surfaced |
| 未確認 | open, plus an entry in 未解決の疑問 | The link that could not be materialized, who can settle it, and the fix outcome (`verdict_part_b`) |

- Issues the agents classified as pre-existing are misses of this review. Run
  SKILL.md Step 6 on them. Report the survivors as new findings with the source
  修正の試行; mark as 未検証 those no refuter checked.
- Report the adoption conditions (rollout, outside-worktree) and the adoption
  notes (trial artifacts) with the finding they belong to. A result with
  `stacked_on` has the adoption condition that its `final_patch` applies only
  after the patches it stacks on.
- Report `outlook.json` in the closing section 全修正後の見通し, and every
  check marked 実行できず in 実行できなかった確認.
- In PR mode, add one 修正の試行 row per trialed finding in Step 9
  (pr-mode.md).

## Step L7: Leftovers (main session)

1. Record `git -C <repo> status --porcelain` again and report any difference
   from Step L0. There should be none.
2. List the worktrees with `git -C <repo> worktree list --porcelain`: the ones
   under the run directory, that is `wt-<finding id>`, `wt-base`,
   `wt-all.<k>` and `wt-bisect.<k>.<n>`.
3. For the report's 後片付け section, give the exact command for each, with
   real paths, and do not run it: `git -C <repo> worktree remove --force <path>`
   (force, because the worktrees hold uncommitted files and byproducts). Say
   first what each one holds. A finding's worktree holds its trial checks and,
   if a fix was tried, the uncommitted fix, which is also saved as the
   `final_patch` file in the run directory. `wt-base` holds only the
   baseline's byproducts. `wt-all.<k>` and `wt-bisect.<k>.<n>` hold patches
   that are already saved in the run directory. If a reboot or cleanup has
   already removed the run directory, the command is
   `git -C <repo> worktree prune` instead.
