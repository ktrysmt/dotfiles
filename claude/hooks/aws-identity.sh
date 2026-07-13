#!/bin/bash
# Shared AWS identity cache helper for Claude Code statusline and hooks.
#
# Usage: aws-identity.sh <get|refresh|check>
#   get     Print cached identity JSON immediately and spawn a background
#           refresh when the cache is stale. Never blocks (statusline-safe).
#   refresh Query STS and rewrite the cache. Blocking, bounded by CLI timeouts.
#   check   Refresh synchronously when stale, then print the cache (hooks).
#
# Cache JSON: {"status": "ok|expired|none|unauthenticated|error|unknown",
#              "profile": "...", "account": "...", "arn": "...", "ts": 0}
#   ok             valid credentials
#   expired        credentials exist but the token/SSO session has expired
#   none           no credentials configured (callers should stay silent)
#   unauthenticated no session in the environment yet. This helper deliberately
#                   does NOT query STS in this state, because resolving a
#                   role/SSO profile would perform sts:AssumeRole -- and whether
#                   to assume is strictly the user's decision (they use
#                   aws-vault), never this tooling's.
#   error          transient failure (network etc.); callers should fail open

CACHE_DIR="/tmp/claude-aws-identity-$(id -u)"
# Profile resolution: aws-vault sessions export AWS_VAULT (with plain env
# credentials), so it takes precedence over AWS_PROFILE.
PROFILE="${AWS_VAULT:-${AWS_PROFILE:-default}}"
CACHE_FILE="${CACHE_DIR}/${PROFILE//[^a-zA-Z0-9_.-]/_}.json"
LOCK_DIR="${CACHE_FILE}.lock"
TTL_OK=300
TTL_FAIL=60

mkdir -p "$CACHE_DIR" 2> /dev/null

export AWS_PAGER=""

# ---------- Cache primitives ----------
write_cache() {
  local status="$1" account="$2" arn="$3"
  local tmp="${CACHE_FILE}.$$.tmp"
  if jq -n \
      --arg status "$status" --arg profile "$PROFILE" \
      --arg account "$account" --arg arn "$arn" \
      --arg ts "$(date +%s)" \
      '{status: $status, profile: $profile, account: $account, arn: $arn, ts: ($ts | tonumber)}' \
      > "$tmp" 2> /dev/null; then
    mv -f "$tmp" "$CACHE_FILE" 2> /dev/null
  else
    rm -f "$tmp" 2> /dev/null
  fi
}

print_cache() {
  if [ -s "$CACHE_FILE" ]; then
    cat "$CACHE_FILE"
  else
    printf '{"status":"unknown","profile":"%s"}' "$PROFILE"
  fi
}

# Cache freshness: ok entries live TTL_OK seconds, failures retry after TTL_FAIL.
cache_fresh() {
  [ -s "$CACHE_FILE" ] || return 1
  local status ts now ttl
  status=$(jq -r '.status // "unknown"' "$CACHE_FILE" 2> /dev/null)
  ts=$(jq -r '.ts // 0' "$CACHE_FILE" 2> /dev/null)
  now=$(date +%s)
  ttl=$TTL_FAIL
  [ "$status" = "ok" ] && ttl=$TTL_OK
  [ $((now - ts)) -lt "$ttl" ]
}

# ---------- Refresh (single-flight via lock dir) ----------
acquire_lock() {
  if mkdir "$LOCK_DIR" 2> /dev/null; then
    return 0
  fi
  local mtime now
  mtime=$(stat -f '%m' "$LOCK_DIR" 2> /dev/null || stat -c '%Y' "$LOCK_DIR" 2> /dev/null || echo 0)
  now=$(date +%s)
  if [ $((now - mtime)) -gt 30 ]; then
    rmdir "$LOCK_DIR" 2> /dev/null
    mkdir "$LOCK_DIR" 2> /dev/null && return 0
  fi
  return 1
}

do_refresh() {
  if ! command -v aws > /dev/null 2>&1; then
    write_cache "none" "" ""
    return 0
  fi
  # Only contact STS when a session already exists in the environment. For a
  # role/SSO profile without live credentials, `aws sts get-caller-identity`
  # forces credential resolution, which performs sts:AssumeRole -- an assume the
  # user never asked for. Whether to assume is strictly the user's decision
  # (they use aws-vault). When AWS_ACCESS_KEY_ID is already set (aws-vault exec
  # or static creds), the assume has already happened by the user's action and
  # get-caller-identity merely reads that existing session back; it does not
  # trigger a new assume.
  if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    write_cache "unauthenticated" "" ""
    return 0
  fi
  acquire_lock || return 0
  trap 'rmdir "$LOCK_DIR" 2> /dev/null' EXIT

  local out rc account arn
  out=$(aws sts get-caller-identity --output json \
    --cli-connect-timeout 2 --cli-read-timeout 3 2>&1)
  rc=$?
  if [ "$rc" -eq 0 ]; then
    account=$(echo "$out" | jq -r '.Account // empty' 2> /dev/null)
    arn=$(echo "$out" | jq -r '.Arn // empty' 2> /dev/null)
    write_cache "ok" "$account" "$arn"
  elif echo "$out" | grep -qiE 'expired|invalid.*token|sso session|sso.*login'; then
    write_cache "expired" "" ""
  elif echo "$out" | grep -qiE 'unable to locate credentials|could not be found|no credentials'; then
    write_cache "none" "" ""
  else
    write_cache "error" "" ""
  fi
}

# ---------- Commands ----------
case "$1" in
  refresh)
    do_refresh
    ;;
  get)
    if ! cache_fresh; then
      ("$BASH" "$0" refresh > /dev/null 2>&1 &)
    fi
    print_cache
    ;;
  check)
    if ! cache_fresh; then
      do_refresh
    fi
    print_cache
    ;;
  *)
    echo "usage: $(basename "$0") <get|refresh|check>" >&2
    exit 1
    ;;
esac
