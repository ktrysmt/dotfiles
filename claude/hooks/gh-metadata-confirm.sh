#!/usr/bin/env bash
# PreToolUse hook: stop the agent from setting issue / PR metadata on its own.
#
# Labels, assignees, reviewers, milestones and projects on a shared tracker are
# signals to other people (for example a "ready to execute" label on a
# command-order issue tells the executor to start). The agent once added such a
# label that nobody asked for. This hook routes every gh call that would set one
# of these fields to a user confirmation prompt, so the agent cannot set them
# silently. Creating or editing the title / body alone is not affected.
#
# Scope (Bash only):
#   gh issue create|edit  and  gh pr create|edit  with a metadata flag
#   gh api calls that write labels / assignees / reviewers or pass labels= / assignees=
#
# Registered in settings.json under hooks.PreToolUse matcher "Bash".

set -uo pipefail

payload="$(cat)"
tool_name="$(printf '%s' "$payload" | jq -r '.tool_name // empty' 2>/dev/null)" || exit 0
[ "$tool_name" = "Bash" ] || exit 0

cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -n "$cmd" ] || exit 0

# Only gh invocations are in scope.
printf '%s' "$cmd" | grep -qE '(^|[|&;([:space:]])gh[[:space:]]' || exit 0

hit=""

# gh issue/pr create|edit with a metadata flag (long and short forms).
if printf '%s' "$cmd" | grep -qE '(^|[|&;([:space:]])gh[[:space:]]+(issue|pr)[[:space:]]+(create|edit)([[:space:]]|$)'; then
  if printf '%s' "$cmd" | grep -qE '(^|[[:space:]])(--(add-|remove-)?(label|assignee|reviewer|project)|--milestone|--remove-milestone|-[lampr])([[:space:]=]|$)'; then
    hit="gh issue/pr create|edit with a label / assignee / reviewer / milestone / project flag"
  fi
fi

# gh api writes to label / assignee / reviewer endpoints, or passes those fields.
if [ -z "$hit" ] && printf '%s' "$cmd" | grep -qE '(^|[|&;([:space:]])gh[[:space:]]+api([[:space:]]|$)'; then
  if printf '%s' "$cmd" | grep -qE '/(issues|pulls)/[0-9]+/(labels|assignees|requested_reviewers)' \
     || printf '%s' "$cmd" | grep -qE '(-f|-F|--field|--raw-field)[[:space:]]+(labels|assignees|reviewers|milestone)(\[\])?='; then
    hit="gh api call that writes labels / assignees / reviewers / milestone"
  fi
fi

[ -n "$hit" ] || exit 0

reason="Confirm before setting tracker metadata (${hit}). Labels, assignees, reviewers, milestones and projects signal workflow state to other people; set them only when the user explicitly asked for those exact values in this session. If they did not, cancel and rerun without the metadata flags. Hook: ~/.claude/hooks/gh-metadata-confirm.sh"
jq -cn --arg r "$reason" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"ask",permissionDecisionReason:$r}}'
exit 0
