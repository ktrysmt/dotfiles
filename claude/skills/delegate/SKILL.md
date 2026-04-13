---
name: delegate
description: "tmux paneで独立タスクを委譲。「これを別paneでやって」「delegateして」「paneで並行してやって」等のとき使用。"
argument-hint: "<task description>"
disable-model-invocation: true
---

# Delegate

Spawn an independent Claude Code session in a tmux right-vsplit pane to work on a delegated task.

## Workflow

### Step 1: Compose system prompt file

Summarize the current session's relevant context and write to `/tmp/claude-delegate-sys.md`:

```markdown
## Context from parent session

- Project: {project name and purpose}
- Key decisions: {relevant decisions made so far}
- Relevant files: {file paths and their roles, if applicable}
- Constraints: {any requirements or limitations}

## Final output requirement

When your task is complete, output the following summary as a fenced codeblock in chat:

- What was accomplished
- Files changed (with paths)
- Unfinished items (if any)
```

Guidelines for context:
- Keep it concise (under 30 lines)
- Only include context relevant to the delegated task
- Omit information the delegate does not need

### Step 2: Launch tmux pane

Build and execute a tmux command:

```bash
tmux split-window -h "claude --append-system-prompt-file /tmp/claude-delegate-sys.md '<TASK>'"
```

Where `<TASK>` is `$ARGUMENTS` with single quotes escaped (`'` -> `'\''`).

If `$ARGUMENTS` is very long (over 200 chars), write it to `/tmp/claude-delegate-task.md` and launch with:

```bash
tmux split-window -h -l 50% "claude --append-system-prompt-file /tmp/claude-delegate-sys.md \"\$(cat /tmp/claude-delegate-task.md)\""
```

### Step 3: Confirm launch

After launching, report to the user:
- The delegated task summary (1 line)
- How to access the pane (`Ctrl-b + arrow key` or `tmux select-pane`)

## Constraints

- Always right vsplit (`split-window -h`)
- One delegate at a time
- Never use `-p` (print mode) -- delegate runs interactively
- Never set up result reporting back to this session (no send-keys, no wait-for)
- The delegate is fully independent once spawned
- Do not add `--dangerously-skip-permissions` or `--permission-mode` flags
