# change-review: the rounds of one finding (lookahead)

You run the rounds for one review finding, inside the worktree your prompt
names. Round 0 reproduces the finding's consequence on the base revision. Round
k (k >= 1) applies fix iteration k and observes it; then the main session
reviews the round-k fixes of every finding in one batch, applies all of them
together in a combined worktree, and sends you what concerns your fix. You
classify that, decide, and go on to the next round.

| Round | Steps run, in order |
|---|---|
| 0 | 1, 2, then 8 if step 2 stops the trial, then 9; unless the trial stopped, go on to round 1 |
| k >= 1, first half | 1, 3, 4 (again after each repair), 5, then end your turn |
| k >= 1, second half | 6, 7, then 8 if step 7 stops the trial, then 9; on `continue`, go on to round k+1's first half |
| Reopened at round k | The second half of round k, as above |

Reopened: after your trial has ended, the main session may send you an
interactions file for a later round k. Your patch is the one that has to
change for another fix to be combined with it, and only you can change it.
Run round k's second half from your latest state file; your earlier result
file stands until step 9 writes a new one.

Your prompt gives the finding, the sibling context path, the context file, the
base sha, the run directory, the baseline file `<run dir>/baseline.json`,
`--max-iter`, whether `--allow-setup` was given, the hand-off file pattern, and
the result file path. Between the two halves of a round you wait: the main
session's message starts the second half and gives you two file paths.

You keep your own context from round to round. The round record and the state
file that step 9 writes are not your memory; they are where another agent
resumes your work if you are interrupted (see Resuming). If your context has
been compacted and no longer holds an earlier round's details, Read the latest
state file as Resuming describes.

## Rules

The Hard rules of change-review's SKILL.md and the Rules of lookahead.md bind
you. The ones that apply to you are repeated here, so you need not read those
files.

- Read the context file first. It holds what the change is meant to do, the
  design documents, the decisions already settled with the author, and the
  user's constraints. The constraints bind you like the rules below.
- Edit only inside your worktree; the user's checkout is never touched. Run
  every command as `cd <worktree> && ...`, because the shell does not keep its
  directory between calls.
- Never commit, push, post, merge, or stash. Your changes stay uncommitted;
  diffs are captured with `git diff`.
- Never delete anything. Do not run `rm`, `rmdir`, `unlink`, `git clean`,
  `git worktree remove`, or any other command whose purpose is deletion, even
  on byproducts or in your own scratch files.
- Never install tools, packages or dependencies. A check that needs setup is
  already recorded in the baseline file as 実行できず; leave it so. With
  `--allow-setup`, run only the repository's own documented setup command, and
  only inside your worktree. Pointing a check at a service that is already
  running locally, through environment variables, installs nothing and is
  allowed; record the variables.
- Everything you write outside the worktree goes under the run directory, in
  any format except `.md`. Helper scripts are allowed there.
- Mechanical results outrank judgement. A reproduction that does not fail on
  base, a fix that leaves a reproduction failing, or an existing test that the
  fix deleted or loosened decides the round, whatever any agent argues.
- Keep every fix minimal. Editor hooks in the user's environment may demand
  changes unrelated to the fix, such as reformatting content that was already
  in the file. Do not make them; record the hook's message in `hook_messages`.
- Long output goes to files. Redirect every command whose output can run long
  — check, test and build runs, `git diff`, `git status --ignored`,
  `git log -L`, `git blame`, repository-wide searches — to an artifact file
  (`cd <worktree> && <command> > <file> 2>&1; echo "exit=$?"`). Then read only
  the lines a decision needs with `grep -n`, `head`, `tail`, `sed -n` or
  `wc -l`: the exit code, the tool's summary, the failing items. Read further
  whenever those lines do not settle the question. Record the file path, not
  the output. This limits what you print, not what you examine: read the code
  the finding and the fix touch as fully as the step needs.
- Evidence: cite code as `path:line` and documents as `<full URL>`.

## Files

Artifacts are named `<run dir>/<finding id>.<step>.<round>[.<label>].<ext>`,
where `<step>` is one of `reproduce`, `fix`, `stack`, `observe`, `handoff`,
`classify`, `round`, `state`, and `<label>` tells apart several artifacts of
the same step.
Helper scripts are `<run dir>/<finding id>.helper.<name>.<ext>`. The main
session writes `<finding id>.review.<k>.json` and
`<finding id>.interactions.<k>.json`; you only read them.

Three kinds of file need care throughout:

- Byproducts: files a check run creates (build output, caches). Before and after
  every check run, write `git status --porcelain --ignored --untracked-files=all`
  to a file; the paths only in the second listing (`comm -13` of the two sorted
  files) are byproducts. Append them to
  `<run dir>/<finding id>.byproducts.txt`, one path per line, relative to the
  worktree root. Exclude them from every patch and every list below.
- Trial checks: the reproduction from step 2, and any check added later for a
  still-present path. Rules:
  - A trial check asserts only that the claimed consequence does not occur. It
    must not pin behaviour the finding does not claim, such as how invalid input
    is handled, which error a racing request receives, or exact wording. Where
    the correct behaviour is undecided, accept every outcome in which the
    consequence does not occur.
  - For a statement in a document or other non-code artifact, the check compares
    the statement with observed behaviour (for example, the outcomes a document
    lists against the outcomes the system produces), not words appearing
    together.
  - Place it where the repository keeps its tests, in the repository's own
    style, when the repository can run it here. Otherwise — the runner is
    unavailable without setup, the artifact has no test location, or the chain
    crosses components that no single test in the repository can drive — place
    it under the run directory as `<finding id>.trialcheck.<n>.<ext>`, written
    so that it takes a worktree root as its first argument and works from
    there.
  - Name an in-repository trial check after the consequence it asserts does
    not occur, in the repository's own naming style. Its file name, test name,
    description and comments carry no finding id, run id or other label that
    exists only in this run, such as `trial`. The check ships with
    `final_patch`, and once pushed, an id that neither the repository nor the
    PR holds cannot be traced. `trialchecks.txt` maps each check to your
    finding. Confirm the path does not exist at base before creating a file;
    two findings' checks that still share a path show up as a conflict in the
    combined worktree.
  - Record in `<run dir>/<finding id>.trialchecks.txt`, when written: each trial
    check's path, location kind, `git hash-object`, and the command that runs
    it with `<worktree>` standing for the worktree root. The main session runs
    that command against the combined worktree.
  - A trial check may be replaced only when the review or a later fix shows it
    pins something beyond the consequence. The replacement must still fail on
    base. Record the old hash, the new hash and the reason. A trial check is
    never loosened with respect to the consequence itself.
  - Failures of other checks (lint, formatting) inside trial check files are
    trial artifacts, not regressions.
- Hand-generated files: if the fix needs a generated file and the generator
  cannot run here, edit the generated file by hand and list it in the result as
  `hand_generated`. Differences it causes are trial artifacts.

The cumulative patch is always built the same way, in the worktree, into a file:
`git diff <base sha>`, followed by `git diff --no-index -- /dev/null <file>` for
each path from `git ls-files --others --exclude-standard` that is not a
byproduct. Exit code 1 from `--no-index` means "differences found". The main
session applies this file with `git apply` in the combined worktree, so it must
hold the whole fix and the in-repository trial checks, and nothing else.

### Stacking

Two fixes that rewrite the same lines cannot both be patches from base:
whichever the combined worktree applies second does not apply. When an
interaction issue you own is such a conflict, and no fix that leaves the
counterpart's lines alone keeps your finding's intent, build your fix on top of
the counterpart's current patch. Stack on as few counterparts and paths as the
conflict needs. Never edit a counterpart's patch.

1. Shared paths: the paths both patches change
   (`git apply --numstat` of each).
2. Stack index: record the state you build on in an index file under the run
   directory, never in the worktree's own index:
   `cd <worktree> && GIT_INDEX_FILE=<run dir>/<finding id>.stack.<k>.index git read-tree <base sha>`,
   then, with the same `GIT_INDEX_FILE`,
   `git apply --cached --include=<shared path> <counterpart patch>` for each
   counterpart and each of its shared paths.
3. Worktree: edit each shared path so that it holds the counterpart's change
   with yours on top. Merge by hand where your earlier change sits on the same
   lines; never restore a file with `checkout`, `restore` or `reset`.
4. Patch: build the cumulative patch as above, but run `git diff` without a
   sha and `git ls-files --others --exclude-standard` both with
   `GIT_INDEX_FILE=<stack index>`. Hunks in shared paths then start from the
   counterpart's text, and every other hunk from base. Confirm it with
   `GIT_INDEX_FILE=<stack index> git apply --cached --check <patch>`
   (exit 0).
5. Record `stacked_on`: per counterpart, its finding id, its patch path, that
   patch's `git hash-object`, and the shared paths.

The main session applies a stacked patch just after the patches it stacks on,
and only while their hashes match. When a counterpart's patch changes, yours is
stale and comes back to you as a conflict; restack on the new patch, in a new
stack index named for the current round. Your trial checks must not depend on
the counterpart's change.

## Steps

1. Start the round.
   - Round 0: confirm `git rev-parse HEAD` equals the base sha, and
     `git status --porcelain` is empty.
   - Round 1: Read the baseline file. It holds, per check and scope, the
     command to run, its condition, whether it is usable, and the failures it
     reports on base. Step L0 of the main session ran every check on base once;
     never run one on base again, except as step 4 allows.
   - Round k >= 1: the previous round's `next` says what this round must
     address.

2. Reproduce on base (round 0). Write the reproduction as a trial check that
   shows the claimed consequence. Reproduce the consequence, not the condition:
   "the value is X" is the condition; "the caller then does Y to Z" is the
   consequence. Push it as far along the chain as this environment allows. Run
   it with its output in `<finding id>.reproduce.0.out`, and record the command,
   the exit code and the output path.
   - Whatever the result, search the whole repository for every path to the
     consequence: the call sites of the affected code and the entry points that
     reach it. Record the commands, their output files, and the number of call
     sites and entry points found.
   - Where the consequence must be reached. Callers in tests do not count as
     callers here.
     - The affected code belongs to an interface the repository exposes to code
       outside it (a published package, an endpoint, a documented API), or it
       has no caller in the repository at all: reaching the consequence at the
       code's own boundary, called the way a caller would call it, counts as
       reaching it. Whether callers that would reach it exist goes to
       `unmaterialized_links` and affects only severity, never the verdict.
     - Otherwise the code is internal and has callers: the consequence must be
       reached through them, and the search inside the repository is complete.
       A consequence that every caller prevents is not reached.
   - It fails, showing the consequence: record the last link reached, and the
     first link that could not be materialized here, if any.
   - It passes on the claimed path: run the reproduction through every other
     path found. A path that shows the consequence becomes a trial check and the
     claimed path; say so. If none does, set `decision` to `withdrawn` and go to
     step 8, with these checks and the search as evidence.
   - The consequence cannot be materialized here at all: mark that link 未確認,
     state the fact that would settle it and who holds it, and continue with the
     furthest link that can be materialized.
   - Rate `severity` (high, medium or low) from the last link reached, as step
     8 rates it. The main session orders every finding's fix by it, since a
     finding from the PR cache or from `trial:` may arrive with none. For a
     withdrawn finding, it is null.
   Save the cumulative patch, which holds the trial check, to
   `<run dir>/<finding id>.reproduce.0.patch`. Unless step 2 stopped the trial,
   `decision` is `continue`.

3. Apply the fix. In round 1, implement `fix`, or 試行者の案 when there is none,
   with the smallest change that does it. In later rounds, first add a trial
   check for each still-present path in the previous round's `next`, and
   confirm that it fails on the current state; then revise the fix as `next`
   says. A revision for an interaction issue must stay compatible with the
   counterparts' current patches that `next` cites. When it must rewrite the
   same lines as one of them, or a stack has gone stale, stack it (see
   Stacking). Save the cumulative patch to
   `<run dir>/<finding id>.fix.<k>.patch`.

4. Observe, mechanically.
   - Every trial check passes, and its `git hash-object` matches the record.
   - Every usable check whose condition the cumulative patch meets: run it in
     the worktree with its output in `<finding id>.observe.<k>.<check>.out`, and
     compare its failures with the baseline. Compare by the identity the tool
     reports (test name, rule and file), not by raw text, because paths differ
     between worktrees. List the new failures; each one is an issue for step 6.
   - A scope or condition the fix reaches that the baseline file lacks: look in
     the `extra_baselines` of earlier rounds. If it is not there either, run the
     check once against a base extract
     (`git archive <base sha> | tar -x -C <run dir>/<finding id>.observe.<k>.base/`),
     and add the result to `extra_baselines`.
   - Weakening: list every pre-existing file the fix modified or deleted
     (`git diff --name-status <base sha>`, statuses M, D, R). For each one that is
     a test or check definition by the repository's own naming convention (state
     the command that shows the convention), show the hunk. A deleted test, a
     removed assertion, or a loosened expectation is a failure of the fix and
     is reported as such; it is never a way to make a check pass.
   - A changed expectation that the fix genuinely requires is a behaviour change.
     Record it as an issue caused by the fix, not as a passing check.
   - Repair before the hand-off. A failing trial check, a new check failure
     outside the trial check files, or a weakened test means the post-change
     state is already known to be broken, and a review of it is spent on a
     state the next change replaces. Then do not go to step 5 yet:
     - Change the fix with the smallest change that removes those failures and
       keeps the fix's intent. Never edit a trial check or loosen a
       pre-existing test to do it.
     - Save the cumulative patch to
       `<run dir>/<finding id>.fix.<k>.repair<n>.patch`, and run this step
       again, with `.repair<n>` appended to each output's label.
     - At most two repairs per round. A repair does not count toward
       `--max-iter`. Failures left after the second repair go on to step 5,
       and to step 6 as issues.
     - Each failure a repair removed still goes into the ledger as a
       caused-by-fix issue, closed in this round, because it shows what the fix
       as first written broke. Step 7 does not count it as open.

5. Hand off. Write `<run dir>/<finding id>.handoff.<k>.json` with one `Write`
   call, holding:
   - `patch`: the last cumulative patch saved in step 3 or 4
   - `observation_clean`: true when every trial check passes, no new check
     failure is left, and no test was weakened
   - `failures_left`: the new check failures left after the repairs, by the
     identity the tool reports
   - `axes`: for round 1, null; for later rounds, the `axes` of the previous
     round's `next`
   - `trial_checks`: the path of `<finding id>.trialchecks.txt`
   - `stacked_on`: as Stacking records it, or `[]`
   Then end your turn. The main session reviews every finding's round-k fix in
   one batch, applies all of them together, and sends you a message with two
   paths: `<run dir>/<finding id>.review.<k>.json`, the review's issues tagged
   with your finding, and `<run dir>/<finding id>.interactions.<k>.json`, the
   issues from combining fixes that you own. Continue at step 6.

6. Classify every issue: the review's issues, the interaction issues, and the
   new check failures that no repair in step 4 removed. Classify the issue, not
   the path it travels: whether this issue holds on base decides, whatever
   label change-review gave it. Check it on base by reading the cited lines
   with `git show <base sha>:<path>`, or by running its reproduction against a
   base extract.
   - still-present: the original consequence still occurs, through a path that
     also exists on base. Record the path.
   - caused-by-fix: the issue does not hold on base and holds after the fix.
     This includes the original consequence recurring through a path the fix
     opened, and a statement the fix wrote that is wrong.
   - interaction: an entry of the interactions file. It holds only when your
     fix and the counterparts' fixes are applied together. It drives the next
     round like caused-by-fix.
   - rollout: the issue exists only while the change is being rolled out, or
     depends on deployed state outside the repository (clients or pages from
     before the change, pinned versions of other components). It does not drive
     another round; it becomes an adoption condition.
   - outside-worktree: the issue can be closed only outside the worktree (the PR
     title or description, another repository, a team process). It does not
     drive another round; it becomes an adoption condition.
   - pre-existing: the issue holds on base too and is not the original
     consequence. It is a miss of the original review. Keep it for the report;
     it does not affect this finding's verdict.
   - trial-artifact: the issue is about a trial check or a hand-generated file.
     It does not affect the verdict, but it ships with `final_patch`, so keep it
     as an adoption note.
   - noise: change-review's own verification already refuted it, or it does
     not reproduce. Record it and drop it.
   Write the classification to `<run dir>/<finding id>.classify.<k>.json`, and
   add every issue to the ledger with its id prefixed `i<k>-`.

7. Decide. An interaction issue that no change to your fix can resolve while
   keeping the finding's intent is set to status `handed-back`: it stays in the
   ledger, goes to the result's `interactions_unresolved` with the
   counterparts, and does not count as open. Then the first match wins.
   - No open caused-by-fix or interaction issue, no still-present path,
     observation clean: `converged`.
   - An issue that the ledger shows closed in an earlier round has reopened by
     the same mechanism: `oscillation`. An issue that an earlier round narrowed
     but did not close is still open, not an oscillation.
   - k equals `--max-iter`: `max-iter`.
   - A still-present path that no change inside the worktree can close while
     keeping the finding's intent: `not-closable`.
   - Otherwise `continue`. Write `next`: the caused-by-fix and interaction
     issues and the still-present paths the next round must address, by ledger
     id, each still-present path stated concretely (entry point, location, and
     the artifact that shows it), and each interaction issue with the
     counterparts' current patch paths; the direction of the revision; and
     `axes`, the union of the axes of every worker that reported a
     caused-by-fix, interaction or still-present issue in this round.
   When every rewrite in the same approach produces a new error of the same
   kind (each rewording of a rule misstates a different part of it), the
   approach does not converge. Say so in `revised_understanding`, and name the
   different approach that the evidence points to.
   Any decision other than `continue` goes to step 8; `continue` goes to step 9.

8. Set the verdict, in two parts.

   Part A, does the consequence matter? Evaluated first; the first match wins.

| State | Verdict |
|---|---|
| Step 2 found no path to the consequence | 取り下げ |
| The consequence is reachable on base through a path no fix in scope can close, and no single named fix closes every path | 取り下げ |
| Whether the consequence occurs at all depends on a link that could not be materialized | 未確認 |

   A missing caller recorded under step 2's boundary rule is not such a link;
   it affects only severity.

   Part B, only when Part A matched nothing: what did the fix do?

| State | Verdict |
|---|---|
| A still-present path can be closed only by a different, named fix or approach | 修正案を直す |
| The fixes oscillate | 人に返す |
| Stopped at `--max-iter` with a trial check failing or a check regressed (trial artifacts excluded) | 設計の問題 |
| Converged, or stopped at `--max-iter` with every trial check passing and no check regressed, and the final fix differs materially from the original `fix` | 修正案を直す |
| The same, with the original `fix` or a minor refinement of it | 残す |

   When the loop stopped at `--max-iter` with every check passing, the issues
   left unresolved are listed as 残課題; they do not make it a design problem.
   A 未確認 verdict still reports the fix outcome Part B would have given.

   Severity comes from the last link of the chain that was actually
   materialized, not from the first observation. When that link is 未確認, say
   which severity each possible answer would imply. For 取り下げ, severity is
   null; any narrower true point left over goes to `residual`.

9. Write the round's files in this order, each with one `Write` call. Write no
   drafts or intermediate copies. Details go into the round record, which is
   written once and never copied; the state file carries only what a resuming
   agent needs and cites the records by path.
   - The round record `<run dir>/<finding id>.round.<k>.json`: what this round
     did and saw.
     - Round 0: the reproduction (command, exit code, output path, last link
       reached, first link not materialized) and `path_search` (the commands,
       their output files, the number of call sites and entry points).
     - Round k >= 1: the patch path, the trial check results, the check
       results against the baseline, the weakening findings, the repairs (per
       repair: the failures it addressed, its patch path and its observation
       outputs), the hand-off path, the review and interactions paths, the
       classification path, and this round's hook messages and hand-generated
       files.
   - This round's state file `<run dir>/<finding id>.state.<k>.json`. A
     resuming agent starts from it with no other memory of the trial. Copy the
     previous state forward, extend it, and never drop an entry an earlier
     round wrote. It holds these keys and no others:
     - `round`: k
     - `decision`: `continue`, `withdrawn`, `converged`, `oscillation`,
       `max-iter` or `not-closable`
     - `patch`: the last cumulative patch saved in step 2, 3 or 4
     - `stacked_on`: that patch's, as Stacking records it, or `[]`
     - `severity`: from the last link materialized so far; round 0 sets it,
       and a later round updates it when it materializes a further link
     - `rounds`: the round record paths so far
     - `handoffs`: the hand-off paths so far
     - `reproduction`: one line with the command, exit code, last link reached,
       and the call-site and entry-point counts
     - `trial_checks`: path, location kind, run command and hash of each, with
       any replacement
     - `issues`: the ledger. Per issue: its id, class, location, one-line
       claim, the axes of the workers that raised it, its counterparts for an
       interaction issue, its status (open, narrowed in round j, closed in
       round j, handed-back), and the path of the artifact that shows it
     - `chain`: `first_observation`, `fixes_tried` (one line and the patch path
       each), `what_happened` (one entry per round, at most three lines),
       `revised_understanding` (a few lines)
     - `unmaterialized_links`: one line each, with the deciding fact and who
       holds it
     - `extra_baselines`, `hand_generated`, `hook_messages`: one line and a
       path each
     - `next`, for `continue` only
     A state file past about 15 KB is carrying details that belong in a round
     record.
   - When `decision` is anything other than `continue`, the result file, as the
     final action of this half-round. Build it from the state and this round's
     record; do not read earlier round records for it. A JSON object with:
     - `id`, `round` (k, the round this file was written in), `base`,
       `worktree` (path), `verdict`, `verdict_part_b` (for 未確認),
       `severity`, `severity_reason`, `residual`
     - `reproduction`: the step 2 command, exit code, last link reached, and
       the number of call sites and entry points
     - `trial_checks`: path, location kind, run command and hash of each, with
       any replacement
     - `chain`: `first_observation`, `fixes_tried` (array, empty when stopped at
       step 2), `what_happened` (array, round 0 first), `revised_understanding`
     - `unmaterialized_links`: each with the deciding fact and who holds it
     - `iterations`: the paths of the round records, round 0 first
     - `residual_issues` (残課題), `adoption_conditions` (rollout and
       outside-worktree issues), `adoption_notes` (trial-artifact issues),
       `pre_existing`, `interactions_unresolved` (with the counterparts): from
       the ledger, each with its location, one-line claim and evidence path
     - `checks_not_run`: each 実行できず check from the baseline file, with the
       error and setup command
     - `hand_generated`, `hook_messages`, `byproducts` (the file path)
     - `final_patch`: the path of the last cumulative patch, or null
     - `stacked_on`: the `final_patch`'s, as Stacking records it, or `[]`
     - `final_observation_clean`: the `observation_clean` of the last hand-off,
       or false when there was none
   When `decision` is `continue`, start round k+1 at step 1, and run its first
   half up to the hand-off.

## Resuming

Your prompt says the work is resumed when you take over from an agent that
stopped. Then do the following in place of step 1 of the round you resume at,
because that round's work may already have changed the worktree:

- Confirm `git rev-parse HEAD` equals the base sha.
- Read the latest state file, `<run dir>/<finding id>.state.<j>.json` with the
  highest j present. It holds the chain so far, the issue ledger, and, in
  `next`, what round j+1 must address. Read an earlier round record only when
  the state does not settle a question you face. With no state file, resume at
  round 0.
- Resuming at round 1 or later: Read the baseline file, as step 1 says for
  round 1.
- Resume at round j+1. Artifacts of that round that already exist are the
  stopped agent's unfinished work: continue from the first step whose artifact
  is missing.
- When the hand-off of round j+1 exists but its classification does not, the
  first half is done. If your prompt gives the review and interactions paths
  for that round, continue at step 6; otherwise end your turn and wait for
  them.
- When the latest state's `decision` is not `continue`, the trial had ended.
  If your prompt says the finding is reopened at round k and gives the two
  paths, run round k's second half; otherwise there is nothing to resume.
