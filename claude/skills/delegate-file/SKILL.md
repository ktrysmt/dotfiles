---
name: delegate:file
description: "Delegate a multi-line task via temp file to an independent Claude Code session in a tmux pane"
argument-hint: "<task description (multi-line safe)>"
disable-model-invocation: true
---

# Delegate (file-based)

Spawn an independent Claude Code session in a tmux right-vsplit pane, passing the task via `--append-system-prompt-file` to avoid all shell quoting issues.

## Workflow

### Step 1: Write task to temp file

```bash
TASK_FILE=$(mktemp /tmp/claude-delegate.XXXXXX)
cat <<'TASK_EOF' > "$TASK_FILE"
$ARGUMENTS
TASK_EOF
```

### Step 2: Run tmux command

Execute exactly:

```bash
tmux split-window -d -h "claude --continue --fork-session 'Execute the delegated task.' --append-system-prompt-file '$TASK_FILE'; rm -f '$TASK_FILE'"
```

- `--continue` picks the most recent session in CWD
- `--fork-session` clones history into a new session ID
- `--append-system-prompt-file` reads the task from file -- no shell expansion, no quoting issues
- The positional prompt `'Execute the delegated task.'` triggers Claude to act on the appended system prompt
- The temp file is cleaned up after claude exits

### Step 3: Report

Print:

```
Delegated (file): <1-line task summary>
```

## Constraints

- Always right vsplit (`split-window -d -h`), keeping focus on the parent pane
- One delegate at a time
- Never use `-p` (print mode) -- delegate runs interactively
- Never set up result reporting back to this session (no send-keys, no wait-for)
- The delegate is fully independent once spawned
- Do not add `--permission-mode` flags
