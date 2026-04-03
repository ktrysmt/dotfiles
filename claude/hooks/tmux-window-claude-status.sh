#!/bin/bash

# Usage: tmux-window-claude-status <action>
#   action: start | thinking | notification | done | reset
#
# Called from Claude Code hooks to update tmux window tab
# with Claude's processing state.
#
# Supports multiple panes per window: each pane stores its own
# @claude-status option, and the window name aggregates all panes.

command -v tmux &>/dev/null || exit 0

# Skip when running inside session_summarizer subprocess
[ "$CLAUDE_SUMMARIZER_RUNNING" = "1" ] && exit 0

action="$1"
pane="$TMUX_PANE"

if [ -z "$pane" ]; then
  exit 0
fi

# Devcontainer: if direct socket unreachable, relay to host via TCP
if ! tmux display-message -p '' 2>/dev/null; then
  [ "$DEVCONTAINER" = "true" ] && { echo "$action $pane" >/dev/tcp/host.docker.internal/2489; } 2>/dev/null
  exit 0
fi

# --- 0. Skip if pane already has the same status ---
current=$(tmux show-options -p -t "$pane" -v @claude-status 2>/dev/null)
if [ "$current" = "$action" ]; then
  exit 0
fi

# --- 1. Update per-pane status ---
case "$action" in
  start | thinking | done | notification)
    tmux set-option -p -t "$pane" @claude-status "$action"
    ;;
  reset)
    tmux set-option -pu -t "$pane" @claude-status
    ;;
  *)
    echo "tmux-window-claude-status: unknown action '$action'" >&2
    exit 1
    ;;
esac

# --- 2. Collect statuses from all panes in the same window ---
window=$(tmux display-message -t "$pane" -p '#{window_id}')

has_thinking=false
has_notification=false
has_active=false

while IFS= read -r pane_id; do
  status=$(tmux show-options -p -t "$pane_id" -v @claude-status 2> /dev/null)
  case "$status" in
    start | done)
      has_active=true
      ;;
    thinking)
      has_thinking=true
      has_active=true
      ;;
    notification)
      has_notification=true
      has_active=true
      ;;
  esac
done < <(tmux list-panes -t "$window" -F '#{pane_id}')

# --- 3. Ensure pane-border settings (teammate may override them) ---
tmux set-option -w -t "$window" pane-border-status bottom
tmux set-option -w -t "$window" pane-border-style 'fg=white,bg=black'

# --- 4. Update window style ---
if [ "$has_active" = true ]; then
  if [ "$has_notification" = true ]; then
    tmux set-option -w -t "$window" window-status-style 'fg=yellow,bold'
  elif [ "$has_thinking" = true ]; then
    tmux set-option -w -t "$window" window-status-style 'fg=blue,bold'
  else
    tmux set-option -w -t "$window" window-status-style 'fg=green,bold'
  fi
else
  tmux set-option -wu -t "$window" window-status-style
fi
