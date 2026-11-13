# Writing procedure documents

Applies to runbooks, command-order issues, and any step-by-step procedure.

## Section axis
- Pick one axis for the top-level sections before writing, and use only that axis. Default to time order: 準備 / 作業前の確認 / 手順 / 作業後の確認 / 切り戻し.
- Put the executor, account and role on each step, never in section headings.

## What each section may contain
- 準備: only steps that change state.
- 作業前の確認 / 作業後の確認: only read-only checks. Never put a check in 準備, even when the same person does it.
- 手順: the state changes the procedure exists for.
- 切り戻し: the reverse of 手順, with the approver and what is lost.

## Values the executor needs
- Write every value the executor must enter in the step itself or in a table in the same document. Never point to a value that lives only in another document or in chat.
- State the expected value of each check.
- Make each command block run on its own: re-derive every variable it uses instead of relying on an earlier block.

## Self-review before publishing
- Compare the headings pairwise. If one item could belong to both, merge or rename them.
- Resolve every cross-reference against the current text. Re-check after anyone, including the user, edits the document.
