#!/bin/bash

# Usage: tmux-window-claude-status <action>
#   action: start | thinking | done | reset
#
# Called from Claude Code hooks to update tmux window tab
# with Claude's processing state.

action="$1"
pane="$TMUX_PANE"

if [ -z "$pane" ]; then
  exit 0
fi

dir=$(basename "$(tmux display-message -t "$pane" -p '#{pane_current_path}')")

case "$action" in
  start)
    tmux rename-window -t "$pane" "[--]${dir}"
    ;;
  thinking)
    tmux rename-window -t "$pane" "[**]${dir}"
    tmux set-option -w -t "$pane" window-status-style 'fg=blue,bold'
    ;;
  done)
    tmux rename-window -t "$pane" "[==]${dir}"
    tmux set-option -w -t "$pane" window-status-style 'fg=green,bold'
    ;;
  reset)
    tmux set-option -w -t "$pane" automatic-rename on
    tmux set-option -wu -t "$pane" window-status-style
    ;;
esac
