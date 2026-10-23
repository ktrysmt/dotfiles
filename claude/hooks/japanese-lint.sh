#!/usr/bin/env bash
# Stop hook: block replies whose Japanese prose breaks ~/.claude/rules/japanese.md
# Lexical checks only (banned idioms + textlint). Context checks (omitted actor/object,
# proper noun vs. general word) run as the prompt hook next to this one in settings.json.
set -euo pipefail

if ! command -v jq &>/dev/null; then
  exit 0
fi

INPUT=$(cat)

# Block at most once per reply: the rewrite this hook triggers is not re-checked
if [[ "$(printf '%s\n' "$INPUT" | jq -r '.stop_hook_active // false')" == "true" ]]; then
  exit 0
fi

MESSAGE=$(printf '%s\n' "$INPUT" | jq -r '.last_assistant_message // empty')

# Only replies that contain Japanese prose
if ! printf '%s' "$MESSAGE" | perl -CSD -0777 -ne 'exit(/\p{Hiragana}/ ? 0 : 1)'; then
  exit 0
fi

RULES_FILE="$HOME/.claude/rules/japanese.md"
TEXTLINT_DIR="$HOME/.claude/hooks/textlint"

# Prose without fenced code, inline code and 「quoted」 mentions, keeping line numbers.
# Quoted words are mentions (e.g. discussing a banned word), not uses.
PROSE=$(printf '%s\n' "$MESSAGE" | perl -CSD -Mutf8 -ne '
  if (/^\s*```/) { $in_code = !$in_code; print "\n"; next }
  if ($in_code) { print "\n"; next }
  s/`[^`]*`//g;
  s/「[^」]*」//g;
  print;
')

ERRORS=""

# Rule: banned idioms. The list lives in japanese.md as "- Banned → replacement: a→b / c→d."
if [[ -f "$RULES_FILE" ]]; then
  BANNED_LINE=$(grep -m1 '^- Banned → replacement:' "$RULES_FILE" | sed 's/^- Banned → replacement:[[:space:]]*//; s/\.[[:space:]]*$//' || true)
  if [[ -n "$BANNED_LINE" ]]; then
    while IFS= read -r pair; do
      word="${pair%%→*}"
      replacement="${pair#*→}"
      [[ -z "$word" ]] && continue
      HITS=$(printf '%s\n' "$PROSE" | grep -n -F -- "$word" || true)
      if [[ -n "$HITS" ]]; then
        ERRORS+="[idiom] 「${word}」 is banned; use 「${replacement}」 or a literal verb:"$'\n'
        ERRORS+="$HITS"$'\n'
      fi
    done < <(printf '%s\n' "$BANNED_LINE" | sed 's| / |\n|g' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
  fi
fi

# Rule: textlint (です/ます consistency, comma count, sentence length, doubled particles)
# Skipped silently until `mise deps install npm` has populated node_modules
# mise exec does not put node_modules/.bin on PATH, so call the binary by path
TEXTLINT_BIN="$TEXTLINT_DIR/node_modules/.bin/textlint"
if [[ -x "$TEXTLINT_BIN" ]]; then
  LINT=$(printf '%s\n' "$MESSAGE" \
    | mise -C "$TEXTLINT_DIR" exec --no-deps -- "$TEXTLINT_BIN" \
        --config "$TEXTLINT_DIR/.textlintrc.json" \
        --stdin --stdin-filename reply.md --format unix 2>/dev/null || true)
  LINT_HITS=$(printf '%s\n' "$LINT" | grep '^reply\.md:' || true)
  if [[ -n "$LINT_HITS" ]]; then
    ERRORS+="[textlint]"$'\n'
    while IFS= read -r hit; do
      line_no=$(printf '%s' "$hit" | cut -d: -f2)
      detail=$(printf '%s' "$hit" | cut -d: -f4- | sed 's/^[[:space:]]*//')
      source_line=$(printf '%s\n' "$MESSAGE" | sed -n "${line_no}p")
      ERRORS+="${line_no}: ${detail}"$'\n'"    > ${source_line}"$'\n'
    done <<< "$LINT_HITS"
  fi
fi

if [[ -z "$ERRORS" ]]; then
  exit 0
fi

REASON="Japanese lint (~/.claude/rules/japanese.md) found problems in your last reply. The user has already read that reply, so do not repeat it. Send the corrected sentences now: rewrite each flagged sentence and show only the rewritten text, with no apology and no comment about this lint. Line numbers refer to your last reply."$'\n\n'"$ERRORS"

jq -n --arg reason "$REASON" '{decision: "block", reason: $reason}'
exit 0
