# change-review: deep trial (Step 6b)

change-review's Step 6b sends you here when `--deep` is given. Every rule in
SKILL.md still applies.

1. Candidates: findings new in this run whose verdict is CONFIRMED (Step 5a) or
   SURVIVES (Step 5b) and whose 修正案 is not 無し. OUT-OF-SCOPE findings are not
   trialed.
2. Order by provisional severity (high, medium, low), then by axis number. Take
   the first N (default 3). Every candidate beyond N goes to the report's
   未深掘り section. Never drop one silently.
3. Trial base, the state the findings are about:
   - PR mode: `headRefOid`. Confirm it resolves with
     `git cat-file -e <sha>^{commit}`; if not, run
     `git fetch origin "pull/<number>/head"` first.
   - Local mode with a revision `target`: that revision's sha.
   - Local mode with `target: worktree`: a trial worktree starts from a commit
     and cannot hold uncommitted changes, so no trial runs. List every
     candidate under 未深掘り with that reason.
4. Write the candidates as a JSON array to
   `<scratchpad>/fix-trial/<run id>/input.json`, one object per finding with keys
   `id`, `location`, `claim` (要旨), `impact` (影響シナリオ), `fix` (修正案),
   `axis`, `severity`, `evidence` (根拠URL), `source` (`change-review`). Write
   every surviving finding of this review, trialed or not, in the same shape to
   `<scratchpad>/fix-trial/<run id>/siblings.json`, so the nested reviews do
   not report them again as new.
5. Invoke the `fix-trial` skill with the input path, `siblings:` with the
   siblings path, the repository root, the base sha, `invoked-by: change-review`,
   and `context:` with the context file path (SKILL.md Step 4).
6. fix-trial writes `<scratchpad>/fix-trial/<run id>/results.json`. Wait for
   that file; do not infer results from any reply. Then, per trialed finding,
   replace the provisional severity with fix-trial's and apply its verdict:

| fix-trial verdict | Cache status | What the report carries |
|---|---|---|
| 残す | open | The chain and the converged fix |
| 取り下げ | withdrawn | The reproduction that did not show the consequence, or the other path that already reaches it |
| 修正案を直す | open | The revised 修正案 |
| 人に返す | open, plus an entry in 未解決の疑問 | Both sides of the tradeoff |
| 設計の問題 | superseded, by a new finding that states the design-level problem | Every issue each iteration surfaced |
| 未確認 | open, plus an entry in 未解決の疑問 | The link that could not be materialized, who can settle it, and the fix outcome (`verdict_part_b`) |

   Issues fix-trial classified as pre-existing are misses of this review. Run
   Step 6 on them. Report the survivors as new findings with the source
   修正の試行; mark as 未検証 those the nested review did not verify. Report the
   adoption conditions (rollout, outside-worktree) with the finding they belong
   to.
7. In PR mode, add one 修正の試行 row per trialed finding in Step 9
   (pr-mode.md).
