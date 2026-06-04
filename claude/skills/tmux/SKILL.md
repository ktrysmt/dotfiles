---
name: tmux
description: >-
  Run long-lived or background commands inside detached tmux sessions instead of
  the agent's own background shell, so that (1) a human can attach and watch the
  job live, and (2) the job's lifetime is decoupled from the parent shell / agent
  session and survives its death. Use when launching builds, servers, watchers,
  test runs, migrations, or any process that should keep running independently and
  be observable by the user. Triggers: "run in the background", "keep it running",
  "start a server", "I want to watch it", "バックグラウンドで動かして",
  "監視できるように", "tmuxで動かして".
user-invocable: true
---

# tmux as a Background Job Manager

## Why tmux instead of a plain background shell

A command launched with the agent's own background shell (`cmd &`, run-in-background) has two problems:

1. **Not observable by the human.** The user cannot easily inspect the live state
   of a process buried inside the agent's shell.
2. **Tied to the parent's lifetime.** If the agent session or parent shell dies,
   the process dies with it.

tmux fixes both: the tmux **server is a separate long-lived process**, so a detached
session keeps running even after the parent shell / agent exits, and a human can
`tmux attach` at any time to watch and interact with it.

Prefer this skill over the agent's background shell whenever a job is long-running,
needs to outlive the current session, or the user wants to monitor it.

## Conventions used below

- Session name: `job-<slug>` (so `tmux ls` clearly shows agent-managed jobs).
- State dir: `${TMPDIR:-/tmp}/claude-tmux-jobs`, holding `<slug>.log` and `<slug>.exit`.
- Always set a generous virtual size with `-x`/`-y`; detached sessions default to
  80x24 and `capture-pane` truncates wider output.

```bash
JOB=build                                    # slug
DIR="${TMPDIR:-/tmp}/claude-tmux-jobs"; mkdir -p "$DIR"
