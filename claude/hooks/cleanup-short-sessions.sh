#!/usr/bin/env bash
# SessionEnd hook: delete session transcript if it had no meaningful conversation.
# This prevents short/empty sessions from appearing in --resume.
#
# Input (stdin): JSON with session_id, transcript_path, cwd, etc.
set -euo pipefail

if ! command -v jq &>/dev/null; then
  exit 0
fi

INPUT=$(cat)
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')

if [[ -z "$TRANSCRIPT_PATH" || ! -f "$TRANSCRIPT_PATH" ]]; then
  exit 0
fi

# Count user messages (actual conversation turns) in the transcript
USER_TURNS=$(grep -c '"type"\s*:\s*"user"' "$TRANSCRIPT_PATH" 2>/dev/null || true)

# If the user sent fewer than 2 messages, delete the transcript
MIN_TURNS="${CLAUDE_CLEANUP_MIN_TURNS:-2}"
if [[ "$USER_TURNS" -lt "$MIN_TURNS" ]]; then
  rm -f "$TRANSCRIPT_PATH"
fi
