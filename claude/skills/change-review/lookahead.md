# change-review: lookahead (Step 6b)

change-review sends you here on every run except a nested review: Step 4 starts
Step L0 as soon as it has launched the axis workers, and Step 4b starts Step L1
for each candidate as it arrives. Every rule in SKILL.md still applies; the
rules below add to them. A fixer reads only the Rules and the Fixer section of
this file.

The lookahead fixes every surviving finding once, combines the fixes in one
worktree, and has reviewers who did not write the fixes review the fixed state
once, along the same axes. The final report merges the original review with
that review of the fixes.

Why: a reviewer that only reads code stops at the first link of the chain. It
proposes a fix without seeing what the fix breaks, the author applies it, and
the next review round finds what the fix broke. Applying the fixes and reviewing
the resulting state puts that next link in front of this review.

These choices are deliberate:

- Every surviving finding is fixed; there is no count limit. A candidate rated
  nits (SKILL.md Severity) is not a finding and is never fixed: its fixer is
  stopped as soon as the rating is known, like a refuted candidate's. On
  PR #3857, 7 of 21 fixed findings would have been nits.
- One pass, no loop. What the review of the fixes raises is reported as notes
  for the fix, never fixed again. On PR #3857, the per-finding rounds of an
  earlier design were projected at about 4 of the run's 5 hours.
- No reproduction on base. Step 5 already verifies every finding's facts. On
  PR #3857, a per-finding reproduction took 60 to 70 percent of each trial and
  changed the outcome of 1 finding in 17.
- One fixer per finding, all in parallel, each from base in its own worktree.
  The fixes are combined with a three-way merge per file (`git merge-file`),
  which combined 18 of PR #3857's 21 fixes where `git apply` in order combined
  15. A fix that still conflicts is redone by its own fixer on top of the
  combined state.
- No stage waits longer than it must. A candidate's fixer starts when the
  candidate arrives, in parallel with its verification, and a refuted
  candidate's fix is discarded; on PR #3857, 6 of 27 candidates were dropped.
  Fixes are combined as they finish. The reviewers of the fixes start reading
  the change while the fixes are being made.
- The reviewers of the fixes receive the state, the fix patches, the finding
  list and this review's evidence, never the fixers' notes, so that the fixers'
  reasoning does not anchor them. They still read the whole change, not only
  the fixes.

## Flow

| Step | Starts when | Who | What |
|---|---|---|---|
| L0 | Step 4 has launched the axis workers | Main session | Base, run directory, outer change, checks, baseline, the combined worktree |
| L1 | Step 4b dispatches a candidate | One fixer per candidate | Fix it from base in its own worktree |
| L1b | Step 4b dispatches the first candidate | Four new reviewers | Read the change ahead of the review of the fixes |
| L2 | A candidate is verified and its fixer is done | Main session, one candidate at a time | Merge its fix into the combined worktree; a conflicting fix is redone by its fixer |
| L2b | Every candidate is verified and merged or redone | Main session | Run the checks once on the combined state |
| L3 | L2b is done | Main session, as a nested review | Review the fixed state along the same axes, verified like any review |
| L4 | L3 is done | Main session | Integrate: a verdict per finding, and the misses of the original review |
| L5 | L4 is done | Main session | Leftovers |

While waiting for any of the above, draft the report (see Waiting).

## Rules

These bind the main session and every fixer.

- The user's working tree is never touched. Every edit happens inside a
  worktree the lookahead created. The main session records
  `git status --porcelain` of the user's working tree in Step L0 and again in
  Step L5, and reports any difference.
- Never commit, push, post, merge, or stash. Changes stay uncommitted; patches
  are captured with `git diff`. A private index file under the run directory
  (`GIT_INDEX_FILE=<file>`) is allowed; a worktree's own index is not changed.
- Never delete anything: no `rm`, `rmdir`, `unlink`, `git clean`,
  `git worktree remove`, or any other command whose purpose is deletion, even on
  byproducts or scratch files.
- Never install tools, packages or dependencies. A check that needs setup is
  recorded as 実行できず with the exact setup command, unless the user passed
  `--allow-setup` in this session. `--allow-setup` permits only the
  repository's own documented setup command, only inside worktrees the
  lookahead created. Pointing a check at a service already running locally,
  through environment variables, installs nothing and is allowed; record the
  variables.
- Every worktree is new, holds one state, and is never reset or reused. It is
  created inside the run directory, outside the repository. Do not use the
  `Agent` tool's `isolation: "worktree"`: it branches from the session's own
  repository, which may not be the target.
- The combined worktree `wt-fix` is changed by one actor at a time: the main
  session merging a fix, or one fixer redoing its fix. Never two at once.
- A shell does not keep its directory between calls. Run every command in a
  worktree as `cd <worktree> && ...`.
- The shell may be zsh. Never name a shell variable `path`: zsh ties it to
  `PATH`, and every later command in the loop then fails with "command not
  found". Use a name such as `fp`.
- Everything written outside a worktree goes under the run directory, in any
  format except `.md`.
- Long output goes to files: `<command> > <file> 2>&1; echo "exit=$?"`, then
  read only the lines a decision needs with `grep -n`, `head`, `tail`,
  `sed -n` or `wc -l`. Read further whenever those lines do not settle the
  question.
- Evidence: cite code as `path:line` and documents as `<full URL>`.

## Step L0: Prepare (main session, while the axis workers run)

Never wait for the axis workers here; Step 4b handles their outputs as they
arrive, in between the items below.

1. Base, the state the findings are about:
   - PR mode: `headRefOid`. Confirm it resolves with
     `git cat-file -e <sha>^{commit}`; if not, run
     `git fetch origin "pull/<number>/head"` first.
   - Local mode with a revision `target`: that revision's sha.
   - Code mode: the `rev` sha.
   - Local mode with `target: worktree`: a worktree starts from a commit and
     cannot hold the user's uncommitted changes, so nothing is fixed. Every
     candidate goes under 未深掘り with that reason; skip Steps L1 to L4.
2. Run directory: `<work dir>/lookahead/`. Repository: in PR mode, the local
   clone of the PR's base repository, whose `origin` is
   `https://github.com/<owner>/<repo>` with or without `.git`, or
   `git@github.com:<owner>/<repo>.git`: the current directory's repository
   when it is that clone, otherwise ask the user for its path. In local mode
   and code mode, `repo`. Record `git -C <repo> status --porcelain`.
3. Outer change, the whole change this review covers, for the reviewers of the
   fixes and for Step L4:
   - PR mode: the PR's full change, even on an incremental review:
     `git diff $(git merge-base origin/<baseRefName> <base sha>) <base sha> > <run dir>/outer.diff`.
   - Local mode: `<work dir>/diff.patch`.
   - Code mode: `<work dir>/files.txt`, the code under review.
4. Checks: read the repository's CI definitions and task-runner files and list
   the commands the project itself runs to build, lint and test. Record each
   with the `path:line` it came from, and any condition under which CI runs it
   (for example, only when certain paths change). Scope a command to the
   affected area the way CI scopes it, and say so. Do not invent commands. If
   none can be found, every check is 実行できず.
5. Baseline: create `git -C <repo> worktree add --detach <run dir>/wt-base <base sha>`
   and run every check once there. When CI scopes a check to an affected area,
   run it once per distinct area the outer change touches. A fix that reaches
   another area gets that area's baseline in Step L2b.
   - Output goes to `<run dir>/baseline/<check>.<scope>.out`.
   - A check is usable only if it runs to completion here. The failures it
     reports here are the baseline; only failures that are new in Step L2b
     count. Identify each failure the way the tool does (test name, rule and
     file), because paths differ between worktrees.
   - A check that cannot run (missing dependency, service or credential) is
     実行できず: record the error and, for a missing dependency, the setup
     command. Run that setup only with `--allow-setup`.
   - A check that compares against the git index or `HEAD` fails in an
     uncommitted worktree by construction. Replace its comparison with a direct
     comparison of the same files, run the replacement here, and record both
     commands.
   Write `<run dir>/baseline.json`: per check and scope, the command (and the
   command it replaced, if any), its source `path:line`, its condition, the
   scope, the status (usable or 実行できず), the exit code, the output path,
   the baseline failures, and for 実行できず the error and the setup command.
6. Combined worktree: `git -C <repo> worktree add --detach <run dir>/wt-fix <base sha>`,
   then its private index:
   `cd <run dir>/wt-fix && GIT_INDEX_FILE=<run dir>/fix.index git read-tree <base sha>`.
7. With `trial:`, or after an unchanged PR (pr-mode.md Step 2), the candidates
   are known now, and none is verified again: the given findings, or the
   cache's `open` findings that have no row in 修正の試行, normalized into the
   candidate shape of Step L1. Start Steps L1 and L1b for all of them at once.

## Step L1: Start a fixer (main session, per candidate)

Step 4b dispatches each candidate that survives deduplication; dispatch starts
its verification and, at the same moment, its fixer. All candidates of one
axis output are started in a single message.

1. Record the candidate in `<run dir>/input.json`, a JSON array rewritten with
   every candidate so far: `id`, `location` (`path:line`), `claim` (要旨),
   `impact` (影響シナリオ), `fix` (修正案, or null for 無し), `axes`,
   `severity`, `evidence` (根拠URL), `source` (`change-review`, or the origin
   of a `trial:` finding, with the commenter for a PR review comment). Only
   `id`, `location` and `claim` are required.
2. Create `git -C <repo> worktree add --detach <run dir>/wt-<id> <base sha>`.
3. Launch its fixer with the `Agent` tool, without `isolation`, with
   `model: "sonnet"` (SKILL.md Hard rules), as a named teammate `fix-<id>`
   (append the run id if the name is taken); every relaunch of a fixer uses
   the same model. If Agent
   Teams is unavailable (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` unset) or this
   session is itself a teammate, use plain `Agent` calls and keep each agent's
   id for `SendMessage`. The prompt carries:
   - "Read `~/.claude/skills/change-review/lookahead.md`: its Rules and its
     Fixer section. You are the fixer for finding <id>. Your worktree is
     <path>. Run every command as `cd <path> && ...`, and never write outside
     it except under the run directory."
   - The candidate object, verbatim.
   - The base sha, the run directory, the context file path with the
     instruction to read it first, and whether `--allow-setup` was given.
   - The output file `<run dir>/<id>.fix.json`, written with one `Write` call
     as the final action.
4. When Step 5 ends the candidate as REFUTED, OUT-OF-SCOPE or NITS, tell its
   fixer to stop with `SendMessage`, record the candidate in
   `<run dir>/discarded.json` with the verdict, and ignore whatever its fixer
   writes.

A fixer is done when its output file exists and is non-empty. Detect it only
that way. Interruptions (a usage limit, for example): resume the fixer with
`SendMessage`, saying that the work is resumed. A fixer that cannot be resumed
is relaunched as a new agent with the same prompt plus that instruction. A
fixer that never completes: its candidate gets status `not-fixed` with the
reason 修正が完了しなかった; never fill in a fix.

## Step L1b: Start the reviewers of the fixes early (main session, once)

When Step 4b dispatches the first candidate of this run, or Step L0 item 7
starts the first one, launch the nested review's four axis workers, all in a
single message, with `model: "sonnet"` (SKILL.md Hard rules), as named
teammates `la-axis1-security`, `la-axis2-consistency`,
`la-axis3-robustness` and `la-axis4-ops` (append the run id if a name is
taken; with plain `Agent` calls, keep their ids). They are new agents: never
the workers of this review, never a fixer. Each prompt carries:

- "You will review, along the axis below, a set of fixes that will be applied
  on top of <target identifier>. The fixes are not ready yet. Until they are,
  prepare: read the context file <path> first, then the whole change under
  review — <outer change path> — and the files it touches under <post-change
  tree>, as fully as your axis needs. Write no findings yet. Write nothing
  except notes in your scratch directory `<run dir>/review/<your name>-scratch/`.
  Never run `rm`, `rmdir`, `unlink`, `git clean` or any other deleting
  command. Then end your turn: a message will give you the fixes and the rest
  of your instructions."
- The one axis it owns, quoted from SKILL.md Step 3.

The post-change tree is `<work dir>/tree` in PR mode and code mode, and `repo`
in local mode. Write `<run dir>/warm.json`: per axis number, the worker's name
or id. Step L3 passes this file to the nested review as `warm:`.

## Fixer

You fix one finding, from base, in your own worktree. Fix only: do not review,
do not reproduce the finding on base, and do not run the repository's checks.
The main session combines every fix and runs the checks once on the combined
state.

1. Confirm `git rev-parse HEAD` equals the base sha.
2. Read the cited lines, the code they call and the code that calls them, as
   far as the fix needs. Implement `fix`; when it is null, implement the most
   direct fix the claim implies and label it 試行者の案.
3. Make the smallest change that does it. Do not reformat or touch anything the
   fix does not need, even when an editor hook asks for it; record the hook's
   message instead. Never delete a test, remove an assertion, or loosen an
   expectation.
4. When the fix needs a change outside the worktree (another repository, the PR
   description, a team process), make no edit. Record status `not-fixed` and
   the reason.
5. Save your patch to `<run dir>/<id>.patch`: `git diff <base sha>`, followed by
   `git diff --no-index -- /dev/null <file>` for each path from
   `git ls-files --others --exclude-standard`. Exit code 1 from `--no-index`
   means "differences found". Record `git diff --name-only <base sha>` plus
   those paths as your files.
6. Write `<run dir>/<id>.notes.json`: a one-line description of the change, the
   reasoning, and the alternatives you rejected. The notes are never shown to
   the reviewers of the fixes.
7. As the final action, write `<run dir>/<id>.fix.json` with one `Write` call:
   the id, the worktree, status (`fixed` or `not-fixed`), the patch path or
   null, the files, `trial_proposal` (true when the fix is 試行者の案), the
   reason for `not-fixed`, the notes path, and `hook_messages`. Then end your
   turn.

The main session may message you afterwards:

- Stop: your finding was refuted, judged out of scope, or rated nits. Stop at
  once and write nothing more.
- Redo: your fix conflicted with the fixes already combined. Re-apply the same
  fix, keeping its intent, in the combined worktree the message names, on top
  of its current state; leave every other change there as it is. Then, with
  `GIT_INDEX_FILE=<run dir>/fix.index`, run `git add --intent-to-add <path>`
  for each path from `git ls-files --others --exclude-standard`, and write
  `git diff > <run dir>/<id>.redo.patch`; the private index holds the state
  before your redo, so this patch holds only your change. As the final action,
  write `<run dir>/<id>.redo.json` with one `Write` call: status (`fixed` or
  `not-fixed`), the patch path or null, the files, the reason for `not-fixed`,
  and `hook_messages`. When the intent cannot be kept on top of the other
  fixes, make no edit and report `not-fixed` with the counterpart's id.

## Step L2: Merge each fix as it is ready (main session, one at a time)

A candidate is ready when its verification ended CONFIRMED or SURVIVES and its
fixer's output file exists. Merge ready candidates one at a time, in the order
they became ready; while a redo runs, hold further merges.

1. `not-fixed`: nothing to merge; record it.
2. Try the patch as is:
   `cd <run dir>/wt-fix && git apply --check <patch> > <file> 2>&1; echo "exit=$?"`,
   and when it passes, `git apply <patch>`. Done.
3. Otherwise merge per file. For each path in the patch
   (`git apply --numstat --summary <patch>`; `--summary` marks added, deleted
   and renamed paths):
   - A path that exists at base:
     `git show <base sha>:<path> > <run dir>/merge/<id>/<n>.base`, then
     `git merge-file -p <run dir>/wt-fix/<path> <run dir>/merge/<id>/<n>.base <run dir>/wt-<id>/<path> > <run dir>/merge/<id>/<n>.out; echo "exit=$?"`.
     Exit 0 is a clean merge; a positive exit is the number of conflicts
     (`man git-merge-file`); a negative exit is an error.
   - A path the patch adds: clean when `wt-fix` does not have it yet;
     otherwise a conflict.
   - A path the patch deletes or renames: a conflict, since `git apply`
     already failed.
   When every path is clean, copy each `.out` file over its path in `wt-fix`
   and each added file from `wt-<id>`. Otherwise change nothing in `wt-fix`:
   record a conflict with the paths, the conflict counts, and the candidates
   already merged that touch the same paths.
4. Redo a conflict at once, before the next merge:
   - Snapshot the current state into the private index:
     `cd <run dir>/wt-fix && GIT_INDEX_FILE=<run dir>/fix.index git add -A`.
   - Send the fixer, with `SendMessage`, the Redo instruction of the Fixer
     section, the path of `wt-fix`, and the conflict record. A fixer that
     cannot be reached is relaunched as a new agent with its Step L1 prompt
     plus the Redo instruction; its patch file shows what it did.
   - Wait for `<run dir>/<id>.redo.json`. `not-fixed` leaves the conflict
     open, with its counterparts.
5. Record each candidate's merge in `<run dir>/merges.json`: the order, how it
   was merged (`apply`, `merge-file` or `redo`), the patch that represents it
   (its own patch, or its redo patch), and any open conflict.

## Step L2b: Run the checks once (main session)

Starts when every axis output is processed, every candidate is verified, and
every surviving candidate is merged, redone, or `not-fixed`.

1. Before and after the runs, write
   `git status --porcelain --ignored --untracked-files=all` of `wt-fix` to a
   file; the paths only in the second listing are byproducts. Write them to
   `<run dir>/byproducts.txt`, one path per line.
2. Run every usable check whose condition the merged fixes meet, once, with
   the output in `<run dir>/combined.<check>.<scope>.out`. A scope with no
   baseline gets one first, run in `wt-base`.
3. Compare each check's failures with the baseline by the identity the tool
   reports. Attribute each new failure to the candidates whose patch touches
   the file the tool names; with no file named, it is unattributed.
4. Weakening: list every pre-existing file the fixes modified or deleted
   (`git diff --name-status <base sha>` in `wt-fix`, statuses M, D, R). For
   each that is a test or check definition by the repository's naming
   convention (state the command that shows the convention), show the hunk. A
   deleted test, a removed assertion or a loosened expectation is attributed
   to its candidate as an issue caused by the fix.
5. Write `<run dir>/combined.json`: the merges, the open conflicts with their
   counterparts, each check's result against the baseline, the new failures
   with their candidates, the weakening, and the byproducts path.
6. Write `<run dir>/known.json`, the nested review's `findings:` file: every
   surviving finding of this review, merged or not, and every candidate rated
   nits, with its rating, in the candidate shape. In PR mode, add every entry
   of the cache's 既出の指摘, whatever its status.
7. Write `<run dir>/fixes.json`, the nested review's `fixes:` file: per merged
   candidate, its `id`, `location`, `claim`, `patch` (from `merges.json`), and
   `evidence`: what this review already established for it — its 根拠URL, its
   Step 5a command and output path, or its refuter's output file. Nothing from
   the notes files goes into it.

## Step L3: Review the fixes (main session, nested review)

Run a nested review: follow SKILL.md from Step 0 to Step 7 again, as a separate
run, with these local-mode fields. Do not invoke the `Skill` tool for it. Do
not pass the notes files, or anything taken from them, to its workers or
refuters.

- `repo:` `<run dir>/wt-fix`
- `base:` the base sha
- `target:` `worktree`
- `exclude:` `<run dir>/byproducts.txt`
- `fixes:` `<run dir>/fixes.json`
- `findings:` `<run dir>/known.json`
- `context:` the context file
- `warm:` `<run dir>/warm.json`
- `workdir:` `<run dir>/review/`
- `name-prefix:` `la`
- `axes:` omitted, so all four canonical axes run
- `output:` `<run dir>/review.json`
- `invoked-by: lookahead`
- `questions:`, verbatim:
  1. "For each entry of the fixes file: does the finding's consequence still
     occur after its fix, through the same path or any other? Name any other
     path concretely."
  2. "What new issue, risk, cost or behaviour change did each fix introduce,
     and who carries it? Trace it to its consequence."
  3. "Do any of the fixes conflict, duplicate each other, or break an
     assumption another one relies on? Tag such an issue with every fix id
     involved. The mechanical result of combining them, with the merges, the
     open conflicts and the check results, is `<run dir>/combined.json`."
  4. "Read the whole outer change, <outer change path>, in its fixed state
     under `repo`, not only the fixes, and report every issue you observe
     there, including any the original review missed. Leaving one out because
     it would cost someone more work is a defect of the review."
  5. "Each entry of the fixes file carries the evidence the original review
     already established. Reuse it; look up only what a fix newly relies on."

The nested review verifies its candidates with SKILL.md Steps 4b and 5, as any
review does. It ends by writing the `output:` file; detect it only by its
existing and being non-empty.

## Step L4: Integrate (main session)

1. Per candidate, the verdict from `<run dir>/review.json`, `combined.json`,
   `merges.json` and the fixers' output files; the first matching row wins. A
   review issue "names" a candidate when its `fix_ids` holds the candidate's
   id. A review issue whose verdict is NITS names nothing: it drives no
   verdict, is no 修正するときの注意, and goes to the report's nits section with
   the source 修正のレビュー.

| State | Verdict | What the report carries |
|---|---|---|
| `not-fixed`, or a conflict left open in Step L2, or a review issue names it together with another candidate | 人に返す | The reason, or both sides of the conflict with the counterpart |
| A review issue has `still_present` equal to its id | 修正案を直す | The path through which the consequence still occurs |
| A review issue names it and `base_holds` is いいえ or 不明, or a new check failure or a weakening is attributed to it | 修正案を直す | The side effect, with its evidence |
| None of the above | 残す | The tested fix as the recommended 修正案, with its patch path |

   An issue with `base_holds` 不明 is treated as a side effect; say that it is
   不明.
2. Misses of the original review: every review issue that is not NITS and
   whose `fix_ids` is empty, or whose `base_holds` is はい and whose
   `still_present` is null. The nested
   review judged their scope against the fixes, not against this review's
   target, so judge it again yourself against the outer change, ignoring the
   nested `verdict`:
   - PR mode and local mode: in scope when its cited lines fall inside a hunk
     of the outer change, or its cause is a line the outer change added or
     changed.
   - Code mode: in scope when its cause lies in `paths`.
   In scope: run SKILL.md Step 6 on it against this review's findings and the
   dedup context, and report the survivors as new findings with the source
   修正のレビュー. Otherwise: report it under 別作業候補 as `out-of-scope`,
   with the nested refuter's grep command and count.
3. 修正するときの注意: for each candidate, every side effect, conflict and
   interaction issue from item 1. They are reported, not fixed again.
4. Severity stays as Step 5 left it.
5. Write `<run dir>/results.json`: per candidate, its id, verdict, severity,
   status, how it was merged, its patch path, the review issue ids that drove
   the verdict, the still-present paths, the side effects, the conflicts, the
   attributed check failures, and whether the fix was 試行者の案.
6. Write `<run dir>/outlook.json`: the fixes that combined, the open conflicts,
   each check's result on the combined state against the baseline, and every
   issue the review of the fixes left open. This is the forecast of what the
   next review round will raise.
7. Complete the report draft (see Waiting): report `outlook.json` in the
   closing section 全修正後の見通し, and every check marked 実行できず in
   実行できなかった確認.
8. In PR mode, add one 修正の試行 row per candidate in Step 9 (pr-mode.md).

## Waiting

The main session spends most of the lookahead waiting for agents. Use that time
for the parts of the final report that no later step changes:

- Once every candidate is verified, write the parts of SKILL.md Step 7's report
  that depend only on this review to `<work dir>/report.draft.txt`: the
  per-axis chapters with each finding's point, evidence, 実害 and
  verification, 別作業候補, nits, 未解決の疑問, and the design-document
  alignment.
- In PR mode, prepare the Step 9 rows for the findings of this review in
  `<work dir>/cache-rows.txt`.
- Step L4 and Step 7 then add the lookahead's results to the draft instead of
  writing the report from the start. Re-read every drafted claim against the
  final results before the report goes out.

## Step L5: Leftovers (main session)

1. Record `git -C <repo> status --porcelain` again and report any difference
   from Step L0. There should be none.
2. List the worktrees with `git -C <repo> worktree list --porcelain`: the ones
   under the run directory, that is `wt-base`, `wt-fix` and every `wt-<id>`,
   discarded candidates included.
3. For the report's 後片付け section, give the exact command for each, with
   real paths, and do not run it:
   `git -C <repo> worktree remove --force <path>` (force, because the worktrees
   hold uncommitted files and byproducts). Say first what each one holds:
   `wt-base` holds only the baseline's byproducts; `wt-<id>` holds its
   candidate's uncommitted fix, also saved as `<run dir>/<id>.patch`; `wt-fix`
   holds every merged fix and the checks' byproducts. If a reboot or cleanup
   has already removed the run directory, the command is
   `git -C <repo> worktree prune` instead.
