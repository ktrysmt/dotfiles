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
```

## Start a job (default pattern)

Output stays visible in the pane (so a human can attach and watch), is mirrored to a
log file (so the agent can parse it even after the session ends), and the exit code is
written to a sentinel file on completion.

```bash
tmux new-session -d -s "job-$JOB" -x 220 -y 50 -c "$PWD" \
  "bash -lc 'npm run build; echo \$? > \"$DIR/$JOB.exit\"'"
tmux pipe-pane -t "job-$JOB" -o "cat >> \"$DIR/$JOB.log\""
```

Useful `new-session` flags:
- `-c DIR` — working directory.
- `-e KEY=VAL` — inject an environment variable (repeatable).
- `-x W -y H` — virtual terminal size for the detached session.

## Check status

By default tmux destroys the session when its command exits, so session presence is
the running/done signal; the exit file gives the exit code once finished.

```bash
tmux has-session -t "job-$JOB" 2>/dev/null && echo RUNNING || echo DONE
cat "$DIR/$JOB.exit" 2>/dev/null            # exit code, present only when done
tmux ls -F '#{session_name}' | grep '^job-' # list all agent jobs
```

## Read output

```bash
tail -n 50 "$DIR/$JOB.log"                  # log file: persists after the job ends
tmux capture-pane -pt "job-$JOB" -S -       # full scrollback; only while session alive
```

- The **log file** is authoritative after completion (the session and its pane are gone).
- `capture-pane -p` prints the live pane; `-S -` starts from the beginning of history,
  `-S -200` grabs the last 200 lines.

## Human monitoring

Tell the user they can watch or take over at any time:

```bash
tmux attach -t job-build          # attach (interactive)
tmux attach -r -t job-build       # attach read-only (cannot type)
# detach again with the prefix key then d (default: Ctrl-b d)
```

## Interact / stop

```bash
tmux send-keys -t "job-$JOB" 'some input' Enter   # type into the process
tmux send-keys -t "job-$JOB" C-c                  # send Ctrl-C (graceful stop)
tmux kill-session -t "job-$JOB"                    # force kill the job
```

## Block until done (when the agent must wait)

Non-blocking polling (`has-session` / `pane_dead`) is preferred so the agent stays
responsive. When a hard wait is genuinely needed, use the `wait-for` channel:

```bash
tmux new-session -d -s "job-$JOB" -x 220 -y 50 \
  "bash -lc 'CMD; tmux wait-for -S done-$JOB'"
tmux wait-for "done-$JOB"          # blocks until the job signals completion
```

## Variant: keep the pane after exit (max observability)

Use `remain-on-exit` so the final output and exit status stay on screen for a human
to attach and inspect after the job finishes. The session no longer auto-disappears,
so detect completion via `#{pane_dead}` and clean up manually.

```bash
tmux new-session -d -s "job-$JOB" -x 220 -y 50 "bash -lc 'CMD'"
tmux set-option -t "job-$JOB" remain-on-exit on

# done detection + exit code:
tmux list-panes -t "job-$JOB" -F '#{pane_dead} #{pane_dead_status}'  # "1 <code>" when done
tmux kill-session -t "job-$JOB"    # explicit cleanup once read
```

## Cleanup

```bash
tmux kill-session -t "job-$JOB"                       # one job
for s in $(tmux ls -F '#{session_name}' | grep '^job-'); do tmux kill-session -t "$s"; done
rm -f "$DIR/$JOB.log" "$DIR/$JOB.exit"                # state files
```

## Gotchas

- A detached session's default size is 80x24 — always pass `-x`/`-y`, or wide output
  is wrapped/truncated in `capture-pane`.
- `pipe-pane` started just after `new-session` can miss the first lines of a very fast
  command; for the complete history use `capture-pane -S -` while the session is alive,
  or rely on the log for long-running jobs.
- Quote/escape carefully: `\$?` and `\$JOB` must reach the inner `bash -lc`, not be
  expanded by the outer shell.
- `capture-pane` only works while the session exists; after a default (destroy-on-exit)
  job finishes, read the log file instead.