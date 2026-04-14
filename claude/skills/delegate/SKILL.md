---
name: delegate
description: "Delegate a task to an independent Claude Code session in a tmux pane"
argument-hint: "<task description>"
disable-model-invocation: true
---

# Delegate

Spawn an independent Claude Code session in a tmux right-vsplit pane to work on a delegated task.

## Workflow

### Step 1: Escape task string

Set `ESCAPED_TASK` = `$ARGUMENTS` with all single quotes replaced: `'` -> `'\''`

### Step 2: Run tmux command

Execute exactly:

```bash
tmux split-window -h "claude --continue --fork-session '${ESCAPED_TASK}'"
```

- `--continue` picks the most recent session in CWD (= the running session, since it is actively being written to)
- `--fork-session` clones history into a new session ID, preventing interleave with the parent

### Step 3: Report

Print:

```
Delegated: <1-line task summary>
```

## Constraints

- Always right vsplit (`split-window -h`)
- One delegate at a time
- Never use `-p` (print mode) -- delegate runs interactively
- Never set up result reporting back to this session (no send-keys, no wait-for)
- The delegate is fully independent once spawned
- Do not add `--permission-mode` flags
