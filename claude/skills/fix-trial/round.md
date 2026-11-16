# fix-trial: one round of a trial

You run one round of a fix trial for one review finding, inside the trial
worktree your prompt names. Round 0 reproduces the finding's consequence on the
base revision. Round k (k >= 1) applies fix iteration k, observes it and
re-reviews it. Other agents ran the earlier rounds of this trial; everything you
need from them is in the worktree and in the previous round's state file. Do
not look for their transcripts.

| Round | Steps run, in order |
|---|---|
| 0 | 1, 2, then 8 if step 2 stops the trial, then 9 |
| k >= 1 | 1, 3, 4, 5, 6, 7, then 8 if step 7 stops the trial, then 9 |

Your prompt gives the finding, the sibling context path, the context file, the
base sha, the run directory, the baseline file `<run dir>/baseline.json`,
`--max-iter`, whether `--allow-setup` was given, the previous round's state file
(round k >= 1 only), this round's state file path, and the trial's result file
path.

## Rules

The Hard rules of fix-trial's SKILL.md bind you. The ones that apply to a round
are repeated here, so you need not read that file.

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
where `<step>` is one of `reproduce`, `fix`, `observe`, `review`, `classify`,
`round`, `state`, and `<label>` tells apart several artifacts of the same step.
Helper scripts are `<run dir>/<finding id>.helper.<name>.<ext>`.

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
    style, with `trial` in its name, when the repository can run it here.
    Otherwise — the runner is unavailable without setup, the artifact has no
    test location, or the chain crosses components that no single test in the
    repository can drive — place it under the run directory as
    `<finding id>.trialcheck.<n>.<ext>`.
  - Record each trial check's path, location kind and `git hash-object` in
    `<run dir>/<finding id>.trialchecks.txt` when written.
  - A trial check may be replaced only when the re-review or a later fix shows
    it pins something beyond the consequence. The replacement must still fail
    on base. Record the old hash, the new hash and the reason. A trial check is
    never loosened with respect to the consequence itself.
  - Failures of other checks (lint, formatting) inside trial check files are
    trial artifacts, not regressions.
- Hand-generated files: if the fix needs a generated file and the generator
  cannot run here, edit the generated file by hand and list it in the result as
  `hand_generated`. Differences it causes are trial artifacts.

The cumulative patch is always built the same way, in the worktree, into a file:
`git diff <base sha>`, followed by `git diff --no-index -- /dev/null <file>` for
each path from `git ls-files --others --exclude-standard` that is not a
byproduct. Exit code 1 from `--no-index` means "differences found".

## Steps

1. Start the round.
   - Confirm `git rev-parse HEAD` equals the base sha.
   - Round 0: confirm `git status --porcelain` is empty.
   - Round k >= 1: Read the previous state file. It holds the chain so far, the
     issue ledger, and, in `next`, what this round must address. Read an
     earlier round record only when the state does not settle a question you
     face.
   - Round k >= 1: build the cumulative patch into
     `<run dir>/<finding id>.fix.<k>.start.patch` and compare it with the
     previous state's `patch` using `cmp`. A difference means the worktree
     changed between rounds. If your prompt says this round is resumed, the
     difference is your own unfinished work: continue from the first unfinished
     step. Otherwise record the difference, set `decision` to
     `worktree-changed`, and go to step 8.
   - Round k >= 1: Read the baseline file. It holds, per check and scope, the
     command to run, its condition, whether it is usable, and the failures it
     reports on base. Step 0 of the main session ran every check on base once;
     never run one on base again, except as step 4 allows.

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
   Save the cumulative patch, which holds the trial check, to
   `<run dir>/<finding id>.reproduce.0.patch`. Unless step 2 stopped the trial,
   `decision` is `continue`.

3. Apply the fix. In round 1, implement `fix`, or 試行者の案 when there is none,
   with the smallest change that does it. In later rounds, first add a trial
   check for each still-present path in the previous state's `next`, and
   confirm that it fails on the current state; then revise the fix as `next`
   says. Save the cumulative patch to `<run dir>/<finding id>.fix.<k>.patch`.

4. Observe, mechanically.
   - Every trial check passes, and its `git hash-object` matches the record.
   - Every usable check whose condition the cumulative patch meets: run it in
     the worktree with its output in `<finding id>.observe.<k>.<check>.out`, and
     compare its failures with the baseline. Compare by the identity the tool
     reports (test name, rule and file), not by raw text, because paths differ
     between worktrees. List the new failures; each one is an issue for step 6.
   - A scope or condition the fix reaches that the baseline file lacks: look in
     the previous state's `extra_baselines`. If it is not there either, run the
     check once against a base extract
     (`git archive <base sha> | tar -x -C <run dir>/<finding id>.observe.<k>.base/`),
     and add the result to `extra_baselines`.
   - Weakening: list every pre-existing file the trial modified or deleted
     (`git diff --name-status <base sha>`, statuses M, D, R). For each one that is
     a test or check definition by the repository's own naming convention (state
     the command that shows the convention), show the hunk. A deleted test, a
     removed assertion, or a loosened expectation fails the round and is
     reported as such; it is never a way to make a check pass.
   - A changed expectation that the fix genuinely requires is a behaviour change.
     Record it as an issue caused by the fix, not as a passing check.

5. Re-review the post-change state. Invoke the `change-review` skill. If the
   `Skill` tool is unavailable, Read `~/.claude/skills/change-review/SKILL.md`
   and follow it. Pass these local-mode fields:
   - `repo:` this worktree's root
   - `base:` the base sha
   - `target: worktree`
   - `workdir:` `<run dir>/<finding id>.review.<k>/`
   - `name-prefix:` `<finding id>-fix<k>`
   - `exclude:` `<run dir>/<finding id>.byproducts.txt`
   - `context:` the context file path from your prompt
   - `axes:` round 1 — omit, so all four canonical axes run, because the first
     round is the one most likely to surface what the original review missed.
     Later rounds — the `axes` in the previous state's `next`.
   - `findings:` `<run dir>/<finding id>.review.<k>.known.json`, which you write
     first: the sibling context, the original finding, and every entry of the
     issue ledger, so none is raised again as new
   - `output:` `<run dir>/<finding id>.review.<k>.json`
   - `invoked-by: fix-trial`
   - `questions:`, verbatim:
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
   change-review fans out from inside this round with plain `Agent` calls,
   because a teammate cannot spawn teammates. Wait for the `output:` file.

6. Classify every issue: the re-review's findings and the new check failures
   from step 4. Classify the issue, not the path it travels: whether this
   issue holds on base decides, whatever label change-review gave it. Check it
   on base by reading the cited lines with `git show <base sha>:<path>`, or by
   running its reproduction against a base extract.
   - still-present: the original consequence still occurs, through a path that
     also exists on base. Record the path.
   - caused-by-fix: the issue does not hold on base and holds after the fix.
     This includes the original consequence recurring through a path the fix
     opened, and a statement the fix wrote that is wrong.
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

7. Decide. The first match wins.
   - No caused-by-fix issue, no still-present path, observation clean:
     `converged`.
   - An issue that the ledger shows closed in an earlier round has reopened by
     the same mechanism: `oscillation`. An issue that an earlier round narrowed
     but did not close is still open, not an oscillation.
   - k equals `--max-iter`: `max-iter`.
   - A still-present path that no change inside the worktree can close while
     keeping the finding's intent: `not-closable`.
   - Otherwise `continue`. Write `next`: the caused-by-fix issues and
     still-present paths the next round must address, by ledger id, each
     still-present path stated concretely (entry point, location, and the
     artifact that shows it); the direction of the revision; and `axes`, the
     union of the axes of every worker that reported a caused-by-fix or
     still-present issue in this round.
   When every rewrite in the same approach produces a new error of the same
   kind (each rewording of a rule misstates a different part of it), the
   approach does not converge. Say so in `revised_understanding`, and name the
   different approach that the evidence points to.
   Any decision other than `continue` goes to step 8; `continue` goes to step 9.

8. Set the verdict. A trial stopped by `worktree-changed` is 未確認: the
   deciding fact is what changed the worktree between rounds, and the user
   holds it; skip Parts A and B. Otherwise set it in two parts.

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
   written once and never copied; the state file carries only what the next
   round needs and cites the records by path.
   - The round record `<run dir>/<finding id>.round.<k>.json`: what this round
     did and saw.
     - Round 0: the reproduction (command, exit code, output path, last link
       reached, first link not materialized) and `path_search` (the commands,
       their output files, the number of call sites and entry points).
     - Round k >= 1: the patch path, the trial check results, the check
       results against the baseline, the weakening findings, the review path,
       the classification path, and this round's hook messages and
       hand-generated files.
   - When `decision` is anything other than `continue`, the result file. Build
     it from the state and this round's record; do not read earlier round
     records for it. A JSON object with:
     - `id`, `base`, `worktree` (path), `verdict`, `verdict_part_b` (for
       未確認), `severity`, `severity_reason`, `residual`
     - `reproduction`: the step 2 command, exit code, last link reached, and
       the number of call sites and entry points
     - `trial_checks`: path, location kind and hash of each, with any
       replacement
     - `chain`: `first_observation`, `fixes_tried` (array, empty when stopped at
       step 2), `what_happened` (array, round 0 first), `revised_understanding`
     - `unmaterialized_links`: each with the deciding fact and who holds it
     - `iterations`: the paths of the round records, round 0 first
     - `residual_issues` (残課題), `adoption_conditions` (rollout and
       outside-worktree issues), `adoption_notes` (trial-artifact issues),
       `pre_existing`: from the ledger, each with its location, one-line claim
       and evidence path
     - `checks_not_run`: each 実行できず check from the baseline file, with the
       error and setup command
     - `hand_generated`, `hook_messages`, `byproducts` (the file path)
     - `final_patch`: the path of the last cumulative patch, or null
   - Last, as your final action, this round's state file. The next round starts
     from it with no other memory of this round. Copy the previous state
     forward, extend it, and never drop an entry an earlier round wrote. It
     holds these keys and no others:
     - `round`: k
     - `decision`: `continue`, `withdrawn`, `converged`, `oscillation`,
       `max-iter`, `not-closable` or `worktree-changed`
     - `patch`: the cumulative patch saved in step 2 or step 3
     - `rounds`: the round record paths so far
     - `reproduction`: one line with the command, exit code, last link reached,
       and the call-site and entry-point counts
     - `trial_checks`: path, location kind and hash of each, with any
       replacement
     - `issues`: the ledger. Per issue: its id, class, location, one-line
       claim, the axes of the workers that raised it, its status (open,
       narrowed in round j, closed in round j), and the path of the artifact
       that shows it
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
