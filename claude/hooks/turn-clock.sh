#!/bin/bash

# Usage: turn-clock.sh <action>
#   action: start | stop | reset
#
# Called from Claude Code hooks to record when the current turn started and
# ended, per session; statusline-command.sh reads the record to show the
# request time and the elapsed time.
#   UserPromptSubmit       -> start
#   Stop, StopFailure      -> stop
#   SessionStart           -> reset
#
# Record: $CLAUDE_TURN_CLOCK_DIR/<session_id> (default /tmp/claude-turn-clock),
# one line: "<start epoch> <end epoch, 0 while running> <transcript bytes at start>"

# Skip when running inside session_summarizer subprocess
[ "$CLAUDE_SUMMARIZER_RUNNING" = "1" ] && exit 0

action="$1"
input=$(cat)

eval "$(jq -r '
  "session_id=" + (.session_id // "" | @sh),
  "source=" + (.source // "" | @sh),
  "transcript=" + (.transcript_path // "" | @sh)
' <<< "$input" 2> /dev/null)"

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
    # Only a prompt the person typed starts a turn. `source` is absent on
    # builds that do not send it yet; treat that as typed.
    case "$source" in
      "" | user) ;;
      *) exit 0 ;;
    esac
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
    # Keep the first end: a turn the person did not start (a background
    # task's report) must not stretch the duration of the one they did.
    [ "$start" -gt 0 ] && [ "$end" -eq 0 ] || exit 0
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
