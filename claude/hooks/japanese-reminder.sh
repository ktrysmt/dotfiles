#!/usr/bin/env bash
# UserPromptSubmit hook: re-inject the self-check list from ~/.claude/rules/japanese.md
# right before each reply is generated. Stop hooks only run after the user has read
# the reply, so this is the only check that acts before chat text is shown.
set -euo pipefail

RULES_FILE="$HOME/.claude/rules/japanese.md"

if [[ ! -f "$RULES_FILE" ]]; then
  exit 0
fi

# Print the "## 送信前の確認" section, up to the next heading.
# perl, not awk: BSD awk compares multibyte headings by collation and matched the wrong section
perl -CSD -Mutf8 -ne '
  $in_section = /^##\s+送信前の確認\s*$/ if /^##\s/;
  print if $in_section;
' "$RULES_FILE"
