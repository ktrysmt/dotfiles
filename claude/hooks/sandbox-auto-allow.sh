#!/bin/bash
# PostToolUse hook (matcher: Bash)
# Detect sandbox network errors, extract the blocked domain,
# and append it to sandbox.network.allowedDomains in settings.json.
# Takes effect from the next session.

set -euo pipefail

SETTINGS="$HOME/.claude/settings.json"
LOCKDIR="/tmp/claude-sandbox-auto-allow.lock"
INPUT=$(cat)

exit_code=$(printf '%s' "$INPUT" | jq -r '.tool_response.exitCode // 0')
[[ "$exit_code" != "0" ]] || exit 0

stdout=$(printf '%s' "$INPUT" | jq -r '.tool_response.stdout // empty')
stderr=$(printf '%s' "$INPUT" | jq -r '.tool_response.stderr // empty')

# Detect sandbox-specific network errors only
if ! printf '%s\n%s' "$stdout" "$stderr" \
  | grep -qE 'tls: failed to verify certificate|x509:.*OSStatus|dial tcp.*Operation not permitted'; then
  exit 0
fi

# Extract domains from URLs  e.g. Get "https://api.github.com/..."
# Also handle: dial tcp: lookup api.example.com: ...
combined=$(printf '%s\n%s' "$stdout" "$stderr")
domains=$(printf '%s' "$combined" | grep -oE 'https?://[^/"'"'"'[:space:]]+' | sed 's|https\{0,1\}://||' || true)
dial_domains=$(printf '%s' "$combined" | grep -oE 'dial tcp: lookup [^ :]+' | sed 's/^dial tcp: lookup //' || true)
domains=$(printf '%s\n%s' "$domains" "$dial_domains" | grep -v '^$' | sort -u || true)
[[ -n "$domains" ]] || exit 0

cleanup_lock() { rmdir "$LOCKDIR" 2>/dev/null; }
trap cleanup_lock EXIT
while ! mkdir "$LOCKDIR" 2>/dev/null; do sleep 0.1; done

for domain in $domains; do
  if jq -e --arg d "$domain" \
    '.sandbox.network.allowedDomains // [] | index($d)' \
    "$SETTINGS" >/dev/null 2>&1; then
    continue
  fi

  tmp="${SETTINGS}.tmp.$$"
  if jq --arg d "$domain" '
    .sandbox.network //= {} |
    .sandbox.network.allowedDomains //= [] |
    .sandbox.network.allowedDomains += [$d]
  ' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"; then
    echo "sandbox-auto-allow: added $domain" >&2
  else
    rm -f "$tmp"
  fi
done

cleanup_lock
trap - EXIT

exit 0
