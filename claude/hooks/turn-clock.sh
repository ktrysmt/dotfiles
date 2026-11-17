#!/bin/bash

# Usage: turn-clock.sh <action>
#   action: start | stop | reset
#
# Called from Claude Code hooks to record when the person's current request
# started and ended, per session; statusline-command.sh reads the record to
# show the request time and the elapsed time.
#   UserPromptSubmit       -> start
#   Stop, StopFailure      -> stop
#   SessionStart           -> reset
#
# A request runs from a prompt the person typed to the parent session's last
# Stop. Turns that a background task's or a teammate's report starts in the
# parent session belong to the request in progress, and hooks that fire inside
# a subagent or an in-process teammate never touch the record.
#
# Record: $CLAUDE_TURN_CLOCK_DIR/<session_id> (default /tmp/claude-turn-clock),
# one line: "<start epoch> <end epoch, 0 while running> <transcript bytes at start>"

# Skip when running inside session_summarizer subprocess
[ "$CLAUDE_SUMMARIZER_RUNNING" = "1" ] && exit 0

action="$1"
input=$(cat)

eval "$(jq -r '
  "session_id=" + (.session_id // "" | @sh),
  "agent_id=" + (.agent_id // "" | @sh),
  "source=" + (.source // "" | @sh),
  "prompt_head=" + (.prompt // "" | .[0:32] | @sh),
  "transcript=" + (.transcript_path // "" | @sh)
' <<< "$input" 2> /dev/null)"

# agent_id is set only when the hook fires inside a subagent or an in-process
# teammate, which share the parent's session_id.
# https://code.claude.com/docs/en/hooks (common input fields)
[ -n "$agent_id" ] && exit 0

# session_id becomes a file name: accept a plain id only.
case "$session_id" in
  "" | *[!A-Za-z0-9_-]*) exit 0 ;;
esac

dir="${CLAUDE_TURN_CLOCK_DIR:-/tmp/claude-turn-clock}"
file="${dir}/${session_id}"
mkdir -p "$dir" || exit 0

start=0
end=0
offset=0
[ -s "$file" ] && read -r start end offset < "$file"
[[ "$start" =~ ^[0-9]+$ ]] || start=0
[[ "$end" =~ ^[0-9]+$ ]] || end=0
[[ "$offset" =~ ^[0-9]+$ ]] || offset=0

# Atomic write, so the status line never reads a half-written record.
write_record() {
  local tmp="${file}.$$.tmp"
  printf '%s %s %s\n' "$1" "$2" "$3" > "$tmp" && mv -f "$tmp" "$file"
}

transcript_size() {
  if [ -f "$transcript" ]; then
    wc -c < "$transcript" | tr -d ' '
  else
    echo 0
  fi
}

case "$action" in
  start)
    # A turn Claude Code starts on its own continues the request in progress.
    # `source` names who wrote the prompt, but builds up to at least 2.1.326
    # leave it out, so a background task's report is also recognized by the
    # <task-notification> envelope it arrives in.
    machine=0
    case "$source" in
      "" | user) ;;
      *) machine=1 ;;
    esac
    case "$prompt_head" in
      "<task-notification>"*) machine=1 ;;
    esac
    if [ "$machine" -eq 1 ]; then
      # Reopen the request so the status line counts on from its start.
      [ "$start" -gt 0 ] && [ "$end" -gt 0 ] && write_record "$start" 0 "$offset"
      exit 0
    fi
    if [ "$start" -gt 0 ] && [ "$end" -eq 0 ]; then
      # A turn is running, so this is a message typed mid-turn: keep the
      # turn's start. An interrupted turn fires no Stop hook and leaves a
      # "[Request interrupted by user...]" row in the transcript instead;
      # finding one written since the start means this prompt is a new turn.
      if [ ! -f "$transcript" ] \
        || ! tail -c +"$((offset + 1))" "$transcript" \
          | grep -qF '"text":"[Request interrupted by user'; then
        exit 0
      fi
    fi
    write_record "$(date +%s)" 0 "$(transcript_size)"
    ;;
  stop)
    # The latest Stop ends the request: a turn that a report reopened ran
    # for the same request.
    [ "$start" -gt 0 ] || exit 0
    write_record "$start" "$(date +%s)" "$offset"
    ;;
  reset)
    # A session that starts or resumes has no turn running. Compaction
    # (`source` compact) keeps the record as it is.
    [ "$source" = "compact" ] && exit 0
    [ "$start" -gt 0 ] && [ "$end" -eq 0 ] || exit 0
    write_record 0 0 0
    ;;
  *)
    echo "turn-clock: unknown action '$action'" >&2
    exit 1
    ;;
esac
