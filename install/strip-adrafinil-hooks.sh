#!/usr/bin/env bash
# git clean filter for claude/settings.json.
#
# Adrafinil.app writes its own hook entries (marked "_adrafinil": true) into
# ~/.claude/settings.json, which is a symlink into this repo. This filter drops
# those entries when the file is staged, so they stay local to the Mac that has
# the app and never reach other machines. It also normalizes the JSON (sorted
# keys, jq formatting) so whole-file rewrites by Adrafinil or Claude Code do not
# show up as diffs.
#
# Registered via [filter "strip-adrafinil"] in .gitconfig_macos and applied by
# .gitattributes. git runs it from the repo root with the file on stdin.
set -euo pipefail

exec jq -S '
  if .hooks then
    .hooks |= (
      with_entries(.value |= (
        map(.hooks |= map(select(._adrafinil != true)))
        | map(select(.hooks | length > 0))
      ))
      | with_entries(select(.value | length > 0))
    )
  else . end
'
