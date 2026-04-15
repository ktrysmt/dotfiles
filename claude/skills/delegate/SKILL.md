---
name: delegate
description: "Delegate a task to an independent Claude Code session in a tmux pane"
argument-hint: "<task description>"
disable-model-invocation: true
---

# Delegate

Generate a self-contained task prompt from `$ARGUMENTS` and conversation history, then spawn a new independent Claude Code session in a tmux pane.

## Workflow

### Step 1: Generate a self-contained task prompt

Synthesize a prompt from `$ARGUMENTS` and the conversation so far. The delegate session has NO prior context, so the prompt must be fully self-contained:

- Goal: what to accomplish
- Relevant file paths and line numbers
- Key constraints, decisions, or context from the conversation that the delegate needs
- Expected output or deliverable

Keep it concise but sufficient -- include only what the delegate actually needs to act.

### Step 2: Pipe task to claude-skill-delegate

Execute exactly:

```bash
cat <<'EOF' | ~/dotfiles/bin/claude-skill-delegate
${GENERATED_PROMPT}
EOF
```

`claude-skill-delegate` starts a brand-new session (no `--continue`/`--fork-session`).

## Constraints

- One delegate at a time
- The delegate is fully independent once spawned -- never set up result reporting back to this session
