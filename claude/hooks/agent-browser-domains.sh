#!/usr/bin/env bash
# PreToolUse hook: route bot-walled hosts to the /agent-browser skill.
#
# Some hosts reject programmatic fetches (HTTP 403 / 429) or hand back payloads
# that WebFetch's markdown conversion mangles (JSON APIs). Retrying curl or
# WebFetch against them burns turns and, worse, can yield silently wrong data.
# This hook denies those calls up front and names /agent-browser as the path.
#
# Scope: Bash fetch verbs (curl/wget/httpie/xh) and the WebFetch tool.
# agent-browser itself is never blocked -- it is the prescribed escape hatch.
#
# Registered in settings.json under hooks.PreToolUse matcher "Bash|WebFetch".

set -uo pipefail

# Extend as new bot-walled hosts turn up. Bare registrable domain; subdomains
# are matched automatically (query1.finance.yahoo.com matches yahoo.com).
BLOCKED_DOMAINS=(
  "yahoo.com"
  "yahoo.co.jp"
)

payload="$(cat)"
tool_name="$(printf '%s' "$payload" | jq -r '.tool_name // empty' 2>/dev/null)" || exit 0

case "$tool_name" in
  WebFetch)
    target="$(printf '%s' "$payload" | jq -r '.tool_input.url // empty' 2>/dev/null)"
    ;;
  Bash)
    cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null)"
    # Never block the prescribed tool.
    if printf '%s' "$cmd" | grep -qE '(^|[|&;([:space:]])agent-browser([[:space:]]|$)'; then
      exit 0
    fi
    # Only fetch verbs are in scope; other commands may mention a URL harmlessly.
    if ! printf '%s' "$cmd" | grep -qE '(^|[|&;([:space:]])(curl|wget|httpie|http|xh)([[:space:]]|$)'; then
      exit 0
    fi
    target="$cmd"
    ;;
  *)
    exit 0
    ;;
esac

[ -n "${target:-}" ] || exit 0

for domain in "${BLOCKED_DOMAINS[@]}"; do
  escaped="${domain//./\\.}"
  if printf '%s' "$target" | grep -qiE "(^|[^A-Za-z0-9.-])([A-Za-z0-9-]+\.)*${escaped}([^A-Za-z0-9-]|$)"; then
    reason="${domain} blocks curl/WebFetch (HTTP 403/429, and WebFetch garbles its JSON). Use the /agent-browser skill instead: agent-browser open '<URL>' && agent-browser eval 'JSON.parse(document.body.innerText)', then agent-browser close. Parse the payload yourself -- do not let a summarizer read the JSON. Rule: CLAUDE.md 'Yahoo and bot-walled hosts go through /agent-browser'. Hook: ~/.claude/hooks/agent-browser-domains.sh (extend BLOCKED_DOMAINS there)."
    jq -cn --arg r "$reason" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
    exit 0
  fi
done

exit 0
