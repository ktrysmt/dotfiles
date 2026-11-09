# Writing procedure documents

Applies to runbooks, command-order issues, and any step-by-step procedure.

## Section axis
- Pick one axis for the top-level sections before writing, and use only that axis. Default to time order: 準備 / 作業前の確認 / 手順 / 作業後の確認 / 切り戻し.
- Put the executor, account and role on each step, not in section headings. Splitting sections by executor while naming them by time produces headings that mean the same thing (e.g. 事前作業 vs 作業前の確認, both "before the main steps").

## What each section may contain
- 準備: only steps that change state (create a channel, issue an address, write a file).
- 作業前の確認 / 作業後の確認: only read-only checks. A check never goes into 準備, even when the same person does it.
- 手順: the state changes the procedure exists for.
- 切り戻し: the reverse of 手順, with the approver and what is lost.

## Values the executor needs
- Write every value the executor must enter (names, IDs, emails, regions) in the step itself or in a table in the same document. Never point to a value that lives only in another document or in chat.
- For each check, state the expected value (e.g. `membershipStatus` is `Active`), not "matches the settings".
- Each command block must run on its own: re-derive any variable it uses (`ID=$(...)`) instead of relying on an earlier block.

## Self-review before publishing (in addition to fact checks)
- Compare the headings pairwise: if one item could belong to both, merge them or rename them.
- Resolve every cross-reference ("the table above", "手順 N", "row N"): the target must exist in the current text. Re-check after anyone, including the user, edits the document.
