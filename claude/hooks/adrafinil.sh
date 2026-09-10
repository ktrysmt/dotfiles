#!/usr/bin/env bash
# Hook shim for adrafinil (keeps the Mac awake while an agent is working).
#
# settings.json is shared across machines via dotfiles, but adrafinil is a
# macOS app that is not installed everywhere. Routing the hook entries through
# this shim makes them a silent no-op wherever the binary is absent, instead of
# failing with "command not found" on every hook fire.
#
# Usage (from settings.json):
#   bash ~/.claude/hooks/adrafinil.sh acquire $CLAUDE_CODE_SESSION_ID --tool claude-code
#   bash ~/.claude/hooks/adrafinil.sh release $CLAUDE_CODE_SESSION_ID --tool claude-code
set -euo pipefail

BIN="${ADRAFINIL_BIN:-/Applications/Adrafinil.app/Contents/Helpers/adrafinil}"

[ -x "$BIN" ] || exit 0

exec "$BIN" "$@"
