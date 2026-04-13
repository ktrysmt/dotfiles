#!/usr/bin/env bash
# PostToolUse hook: lint .md files after creation/edit
# Enforces rules defined in ~/.claude/rules/markdown.md
set -euo pipefail

if ! command -v jq &>/dev/null; then
  exit 0
fi

INPUT=$(cat)

TOOL_NAME=$(printf '%s\n' "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(printf '%s\n' "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only process file-writing tools
case "$TOOL_NAME" in
  Write|Edit|MultiEdit) ;;
  *) exit 0 ;;
esac

# Only lint .md files
if [[ -z "$FILE_PATH" || "$FILE_PATH" != *.md ]]; then
  exit 0
fi

if [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

ERRORS=""

# Rule: No bold (**...**) -- use headings or plain text
# Skip fenced code blocks to avoid false positives
BOLD_HITS=$(awk '
  /^```/ { in_code = !in_code; next }
  !in_code && /\*\*[^*]+\*\*/ { print NR": "$0 }
' "$FILE_PATH" 2>/dev/null || true)

if [[ -n "$BOLD_HITS" ]]; then
  ERRORS+="[bold] Bold (**...**) is prohibited. Use headings or plain text instead:"$'\n'
  ERRORS+="$BOLD_HITS"$'\n'
fi

# Rule: Mermaid diagrams must use vertical top-to-bottom (TB/TD) layout
HORIZ_HITS=$(awk '
  /^```mermaid/ { in_mermaid=1; next }
  /^```/ { in_mermaid=0; next }
  in_mermaid && /^[[:space:]]*(graph|flowchart)[[:space:]]+(LR|RL|BT)/ {
    print NR": "$0
  }
' "$FILE_PATH" 2>/dev/null || true)

if [[ -n "$HORIZ_HITS" ]]; then
  ERRORS+="[mermaid-layout] Mermaid diagrams must use vertical (TB/TD) layout:"$'\n'
  ERRORS+="$HORIZ_HITS"$'\n'
fi

# Rule: Mermaid node definitions must stay on a single source line
# Detect lines with more opening than closing delimiters (unclosed labels)
MULTILINE_HITS=$(awk '
  /^```mermaid/ { in_mermaid=1; next }
  /^```/ { in_mermaid=0; next }
  in_mermaid {
    # Skip blanks, comments, directives, and known keywords
    if ($0 ~ /^[[:space:]]*$/) next
    if ($0 ~ /^[[:space:]]*%%/) next
    if ($0 ~ /^[[:space:]]*---/) next
    if ($0 ~ /^[[:space:]]*(subgraph|end|style|classDef|class|click|linkStyle|direction)[[:space:]]/) next

    tmp = $0
    gsub(/\\[[\](){}]/, "", tmp)
    opens  = gsub(/[[({]/, "&", tmp)
    closes = gsub(/[])}]/, "&", tmp)
    if (opens > closes) {
      print NR": "$0
    }
  }
' "$FILE_PATH" 2>/dev/null || true)

if [[ -n "$MULTILINE_HITS" ]]; then
  ERRORS+="[mermaid-multiline] Node definitions must stay on a single source line:"$'\n'
  ERRORS+="$MULTILINE_HITS"$'\n'
fi

# Rule: Use <br> instead of \n for line breaks within mermaid node labels
BACKSLASH_N_HITS=$(awk '
  /^```mermaid/ { in_mermaid=1; next }
  /^```/ { in_mermaid=0; next }
  in_mermaid && /[[\("{}].*\\n/ {
    print NR": "$0
  }
' "$FILE_PATH" 2>/dev/null || true)

if [[ -n "$BACKSLASH_N_HITS" ]]; then
  ERRORS+="[mermaid-newline] Use <br> instead of \\\\n for line breaks in node labels:"$'\n'
  ERRORS+="$BACKSLASH_N_HITS"$'\n'
fi

if [[ -n "$ERRORS" ]]; then
  echo "BLOCKING: You MUST fix the following markdown lint errors in $FILE_PATH before continuing." >&2
  echo "Re-read the file, fix ALL reported lines, then retry." >&2
  echo "" >&2
  echo "$ERRORS" >&2
  exit 1
fi

exit 0
