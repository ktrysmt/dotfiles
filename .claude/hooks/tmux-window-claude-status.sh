#!/bin/bash

# Usage: tmux-window-claude-status <action>
#   action: start | thinking | done | reset
#
# Called from Claude Code hooks to update tmux window tab
# with Claude's processing state.
#
# Supports multiple panes per window: each pane stores its own
# @claude-status option, and the window name aggregates all panes.

action="$1"
pane="$TMUX_PANE"

if [ -z "$pane" ]; then
  exit 0
fi

# --- 1. Update per-pane status ---
case "$action" in
  start|thinking|done)
    tmux set-option -p -t "$pane" @claude-status "$action"
    ;;
  reset)
    tmux set-option -pu -t "$pane" @claude-status
    ;;
esac

# --- 2. Collect statuses from all panes in the same window ---
window=$(tmux display-message -t "$pane" -p '#{window_id}')
dir=$(basename "$(tmux display-message -t "$pane" -p '#{pane_current_path}')")

symbols=()
has_thinking=false
has_active=false

while IFS= read -r pane_id; do
  status=$(tmux show-options -p -t "$pane_id" -v @claude-status 2>/dev/null)
  case "$status" in
    start)
      symbols+=("--")
      has_active=true
      ;;
    thinking)
      symbols+=("**")
      has_thinking=true
      has_active=true
      ;;
    done)
      symbols+=("==")
      has_active=true
      ;;
  esac
done < <(tmux list-panes -t "$window" -F '#{pane_id}')

# --- 3. Update window name and style ---
if [ "$has_active" = true ]; then
  joined=$(IFS='|'; echo "${symbols[*]}")
  tmux rename-window -t "$window" "[${joined}]${dir}"

  if [ "$has_thinking" = true ]; then
    tmux set-option -w -t "$window" window-status-style 'fg=blue,bold'
  else
    tmux set-option -w -t "$window" window-status-style 'fg=green,bold'
  fi
else
  # All panes inactive: restore automatic rename
  tmux set-option -w -t "$window" automatic-rename on
  tmux set-option -wu -t "$window" window-status-style
fi
