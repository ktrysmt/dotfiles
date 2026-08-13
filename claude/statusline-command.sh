#!/bin/bash
# Claude Code statusline script
# Line 1: Model | Context% | +added/-removed | git branch
# Line 2: usage limits -- 5h + 7d windows (subscription) or monthly credits (seat)

input=$(cat)

# ---------- ANSI Colors ----------
GREEN=$'\e[38;2;151;201;195m'
BLUE=$'\e[38;2;97;175;239m'
YELLOW=$'\e[38;2;229;192;123m'
RED=$'\e[38;2;224;108;117m'
GRAY=$'\e[38;2;74;88;92m'
GRAY_5H=$'\e[38;2;106;124;129m'
GRAY_7D=$'\e[38;2;106;124;129m'
RESET=$'\e[0m'
DIM=$'\e[2m'

# ---------- Color by percentage ----------
color_for_pct() {
  local pct="$1"
  if [ -z "$pct" ] || [ "$pct" = "null" ]; then
    printf '%s' "$GRAY"
    return
  fi
  local ipct
  ipct=$(printf "%.0f" "$pct" 2> /dev/null || echo "0")
  if [ "$ipct" -ge 80 ]; then
    printf '%s' "$RED"
  elif [ "$ipct" -ge 50 ]; then
    printf '%s' "$YELLOW"
  elif [ "$ipct" -ge 20 ]; then
    printf '%s' "$BLUE"
  else
    printf '%s' "$RESET"
  fi
}

# ---------- Progress bar (10 segments) ----------
progress_bar() {
  local pct="$1"
  local filled
  filled=$(awk "BEGIN{printf \"%d\", int($pct / 10 + 0.5)}" 2> /dev/null || echo 0)
  [ "$filled" -gt 10 ] 2> /dev/null && filled=10
  [ "$filled" -lt 0 ] 2> /dev/null && filled=0
  local bar=""
  for i in $(seq 1 10); do
    if [ "$i" -le "$filled" ]; then
      bar="${bar}▰"
    else
      bar="${bar}▱"
    fi
  done
  printf '%s' "$bar"
}

# ---------- Parse stdin (single jq call) ----------
eval "$(echo "$input" | jq -r '
  "model_name=" + (.model.display_name // "Unknown" | @sh),
  "used_pct=" + (.context_window.used_percentage // 0 | tostring),
  "cwd=" + (.cwd // "" | @sh),
  "lines_added=" + (.cost.total_lines_added // 0 | tostring),
  "lines_removed=" + (.cost.total_lines_removed // 0 | tostring),
  "total_cost=" + (.cost.total_cost_usd // 0 | tostring),
  "cc_version=" + (.version // "0.0.0" | @sh),
  "rl_5h_pct=" + (.rate_limits.five_hour.used_percentage // empty | tostring),
  "rl_5h_reset=" + (.rate_limits.five_hour.resets_at // empty | tostring),
  "rl_7d_pct=" + (.rate_limits.seven_day.used_percentage // empty | tostring),
  "rl_7d_reset=" + (.rate_limits.seven_day.resets_at // empty | tostring)
' 2> /dev/null)"

# ---------- cwd (shorten HOME to ~) ----------
cwd_display=""
if [ -n "$cwd" ]; then
  git_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
  if [ -n "$git_root" ]; then
    repo_name=$(basename "$git_root")
    rel="${cwd#"$git_root"}"
    rel="${rel#/}"
    if [ -z "$rel" ] || [ "$rel" = "." ]; then
      cwd_display="$repo_name"
    else
      cwd_display="${repo_name}/${rel}"
    fi
  else
    base=$(basename "$cwd")
    parent=$(dirname "$cwd")
    if [ "$parent" = "/" ]; then
      cwd_display="/${base}"
    else
      cwd_display="$base"
    fi
  fi
fi

# ---------- Cost ----------
cost_display=""
if [ -n "$total_cost" ] && [ "$total_cost" != "0" ]; then
  cost_display=$(printf '$%.2f' "$total_cost")
fi

# ---------- Line stats from stdin ----------
git_stats=""
if [ "$lines_added" -gt 0 ] 2> /dev/null || [ "$lines_removed" -gt 0 ] 2> /dev/null; then
  git_stats="+${lines_added}/-${lines_removed}"
fi

# ---------- Usage limits ----------
# Line 2 has two slots. What fills them depends on the account:
#   Claude.ai subscription -> A = 5h session window, B = 7d window
#   Enterprise/Team seat   -> A = monthly usage credits, B = used/limit in dollars
# A seat has no 5h/7d windows at all, so the subscription-only sources below stay
# empty for it -- that is what produced the "--%" placeholder on both slots.
#
# Sources, in order of preference:
#   1. stdin .rate_limits.{five_hour,seven_day} -- subscribers only, and only after
#      the session's first API response
#   2. cache file, while younger than CACHE_TTL
#   3. GET /api/oauth/usage -- free (no inference); the only source that reports a
#      seat's monthly credit spend
#   4. Haiku header probe -- anthropic-ratelimit-unified-{5h,7d}-* for subscribers
#      whose session has not populated stdin yet
CACHE_FILE="/tmp/claude-usage-cache.json"
CACHE_TTL=360
A_KIND=""; A_PCT=""; A_RESET=""
B_KIND=""; B_PCT=""; B_RESET=""; B_TEXT=""

# Atomic write: write to a temp file then rename, so an interrupted run never
# leaves a truncated/0-byte cache behind (the root cause of the "--%" bug).
write_cache() {
  local tmp="${CACHE_FILE}.$$.tmp"
  if jq -n \
      --arg ak "$A_KIND" --arg ap "$A_PCT" --arg ar "$A_RESET" \
      --arg bk "$B_KIND" --arg bp "$B_PCT" --arg br "$B_RESET" --arg bt "$B_TEXT" \
      '{a_kind: $ak, a_pct: $ap, a_reset: $ar,
        b_kind: $bk, b_pct: $bp, b_reset: $br, b_text: $bt}' \
      > "$tmp" 2> /dev/null; then
    mv -f "$tmp" "$CACHE_FILE" 2> /dev/null
  else
    rm -f "$tmp" 2> /dev/null
  fi
}

# Load cached values; returns non-zero (so callers can fall through) if empty or
# written by an older schema.
load_cache() {
  [ -s "$CACHE_FILE" ] || return 1
  eval "$(jq -r '
    "A_KIND="  + ((.a_kind  // "") | @sh),
    "A_PCT="   + ((.a_pct   // "") | @sh),
    "A_RESET=" + ((.a_reset // "") | @sh),
    "B_KIND="  + ((.b_kind  // "") | @sh),
    "B_PCT="   + ((.b_pct   // "") | @sh),
    "B_RESET=" + ((.b_reset // "") | @sh),
    "B_TEXT="  + ((.b_text  // "") | @sh)
  ' "$CACHE_FILE" 2> /dev/null)"
  [ -n "$A_PCT" ]
}

access_token() {
  local token
  token=$(security find-generic-password -s "Claude Code-credentials" -w 2> /dev/null || true)
  # Linux fallback: read from ~/.claude/.credentials.json
  if [ -z "$token" ]; then
    token=$(cat ~/.claude/.credentials.json 2> /dev/null || true)
  fi
  [ -z "$token" ] && return 1
  if echo "$token" | jq -e . > /dev/null 2>&1; then
    echo "$token" | jq -r '.claudeAiOauth.accessToken // empty' 2> /dev/null
  else
    printf '%s' "$token"
  fi
}

# Credit allowances roll over on the 1st at 00:00 UTC. /api/oauth/usage does not
# carry that timestamp -- only the anthropic-ratelimit-unified-overage-reset
# response header does -- so derive the boundary instead of paying for a request.
next_month_epoch() {
  date -u -v1d -v+1m -v0H -v0M -v0S +%s 2> /dev/null \
    || date -u -d "$(date -u +%Y-%m-01) +1 month" +%s 2> /dev/null \
    || echo ""
}

# Monthly credit spend for accounts with no session windows (Enterprise/Team).
# Bails out when .five_hour exists so a subscriber keeps the 5h/7d display.
fetch_usage_api() {
  local token body
  token=$(access_token) || return 1
  [ -z "$token" ] && return 1

  body=$(curl -s --max-time 5 \
    -H "Authorization: Bearer ${token}" \
    -H "User-Agent: claude-code/${cc_version:-0.0.0}" \
    -H "anthropic-beta: oauth-2025-04-20" \
    "https://api.anthropic.com/api/oauth/usage" 2> /dev/null || true)
  [ -z "$body" ] && return 1

  echo "$body" | jq -e '
    .five_hour == null and .spend.enabled == true and .spend.percent != null
  ' > /dev/null 2>&1 || return 1

  local spend_pct="" spend_used="" spend_limit=""
  eval "$(echo "$body" | jq -r '
    "spend_pct="   + (.spend.percent | tostring),
    "spend_used="  + (((.spend.used.amount_minor  // 0) / pow(10; .spend.used.exponent  // 0)) | floor | tostring),
    "spend_limit=" + (((.spend.limit.amount_minor // 0) / pow(10; .spend.limit.exponent // 0)) | floor | tostring)
  ' 2> /dev/null)"
  [ -z "$spend_pct" ] && return 1

  A_KIND="mo"; A_PCT="$spend_pct"; A_RESET=$(next_month_epoch)
  B_KIND="spend"; B_PCT=""; B_RESET=""; B_TEXT="\$${spend_used}/\$${spend_limit}"
  return 0
}

# 5h/7d windows straight off the response headers of a tiny Haiku call.
fetch_usage_headers() {
  local token headers
  token=$(access_token) || return 1
  [ -z "$token" ] && return 1

  # max_tokens=1 keeps the call trivial; -D- writes response headers to stdout.
  headers=$(curl -sD- --max-time 5 -o /dev/null \
    -H "Authorization: Bearer ${token}" \
    -H "Content-Type: application/json" \
    -H "User-Agent: claude-code/${cc_version:-0.0.0}" \
    -H "anthropic-beta: oauth-2025-04-20" \
    -H "anthropic-version: 2023-06-01" \
    -d '{"model":"claude-haiku-4-5-20251001","max_tokens":1,"messages":[{"role":"user","content":"h"}]}' \
    "https://api.anthropic.com/v1/messages" 2> /dev/null || true)
  [ -z "$headers" ] && return 1

  local h5_util h5_reset h7_util h7_reset
  h5_util=$(echo "$headers" | grep -i 'anthropic-ratelimit-unified-5h-utilization' | tr -d '\r' | awk '{print $2}')
  h5_reset=$(echo "$headers" | grep -i 'anthropic-ratelimit-unified-5h-reset' | tr -d '\r' | awk '{print $2}')
  h7_util=$(echo "$headers" | grep -i 'anthropic-ratelimit-unified-7d-utilization' | tr -d '\r' | awk '{print $2}')
  h7_reset=$(echo "$headers" | grep -i 'anthropic-ratelimit-unified-7d-reset' | tr -d '\r' | awk '{print $2}')
  [ -z "$h5_util" ] && return 1

  # Headers report utilization as 0.0-1.0; store as 0-100 to match stdin.
  A_KIND="5h"
  A_PCT=$(awk "BEGIN{printf \"%.0f\", $h5_util * 100}" 2> /dev/null || echo "")
  A_RESET="$h5_reset"
  B_KIND="7d"
  B_PCT=$(awk "BEGIN{printf \"%.0f\", ${h7_util:-0} * 100}" 2> /dev/null || echo "")
  B_RESET="$h7_reset"
  B_TEXT=""
  return 0
}

if [ -n "$rl_5h_pct" ]; then
  # Native stdin data is authoritative; refresh cache for early-session renders.
  A_KIND="5h"; A_PCT="$rl_5h_pct"; A_RESET="$rl_5h_reset"
  B_KIND="7d"; B_PCT="$rl_7d_pct"; B_RESET="$rl_7d_reset"
  write_cache
else
  # No stdin rate_limits yet: use a fresh cache, else probe the API.
  cache_fresh=false
  if [ -s "$CACHE_FILE" ]; then
    cache_age=$(($(date +%s) - $(stat -f '%m' "$CACHE_FILE" 2> /dev/null || stat -c '%Y' "$CACHE_FILE" 2> /dev/null || echo 0)))
    [ "$cache_age" -lt "$CACHE_TTL" ] && cache_fresh=true
  fi
  if $cache_fresh; then
    load_cache || true
  elif fetch_usage_api || fetch_usage_headers; then
    write_cache
  else
    load_cache || true
  fi
fi

# Nothing resolved: keep the 5h/7d placeholder rather than an empty line.
if [ -z "$A_KIND" ] && [ -z "$B_KIND" ]; then
  A_KIND="5h"
  B_KIND="7d"
fi

# Round to integer for display (stdin may carry fractional percentages).
[ -n "$A_PCT" ] && A_PCT=$(printf '%.0f' "$A_PCT" 2> /dev/null || echo "$A_PCT")
[ -n "$B_PCT" ] && B_PCT=$(printf '%.0f' "$B_PCT" 2> /dev/null || echo "$B_PCT")

# ---------- Remaining time until reset ----------
remaining_label() {
  local reset_epoch="$1"
  [ -z "$reset_epoch" ] || [ "$reset_epoch" = "0" ] && return
  local now remaining_secs
  now=$(date +%s)
  remaining_secs=$((reset_epoch - now))
  [ "$remaining_secs" -le 0 ] && return
  local days hours
  days=$((remaining_secs / 86400))
  hours=$(( (remaining_secs % 86400) / 3600 ))
  if [ "$days" -gt 0 ]; then
    if [ "$hours" -gt 0 ]; then
      echo "${days}d${hours}h"
    else
      echo "${days}d"
    fi
  else
    if [ "$hours" -gt 0 ]; then
      echo "${hours}h"
    else
      echo "$(( (remaining_secs % 3600) / 60 ))m"
    fi
  fi
}

# Render one slot: "<label> <bar> <pct>%", or the raw text for the spend slot.
slot_text() {
  local kind="$1" pct="$2" reset="$3" text="$4"
  case "$kind" in
    "") return ;;
    spend)
      printf '%s' "$text"
      return
      ;;
  esac
  local rem label
  rem=$(remaining_label "$reset")
  if [ "$kind" = "mo" ]; then
    label="mo${rem:+ $rem}"
  else
    label="${rem:-$kind}"
  fi
  if [ -n "$pct" ]; then
    printf '%s %s %s%%' "$label" "$(progress_bar "$pct")" "$pct"
  else
    printf '%s ▱▱▱▱▱▱▱▱▱▱ --%%' "$label"
  fi
}

# ---------- Format context used% ----------
ctx_pct_int=0
if [ -n "$used_pct" ] && [ "$used_pct" != "null" ] && [ "$used_pct" != "0" ]; then
  ctx_pct_int=$(printf "%.0f" "$used_pct" 2> /dev/null || echo 0)
fi

# ---------- Devcontainer: override cwd ----------
if [ "$DEVCONTAINER" = "true" ] && [ -n "$DEVCONTAINER_HOST_PATH" ]; then
  host_repo=$(basename "$DEVCONTAINER_HOST_PATH")
  container_name="$HOSTNAME"
  cwd_display="*${host_repo}:${cwd_display}(${container_name})"
fi

# ---------- Timestamp (last interaction time) ----------
timestamp=$(TZ="Asia/Tokyo" date "+%-m/%-d %-H:%M")

# ---------- Line 1 ----------
SEP="${GRAY} │ ${RESET}"
model_color=""
case "$model_name" in
  *[Ss]onnet*) model_color="$GREEN" ;;
esac
line1="${DIM}${timestamp}${RESET}${SEP}${cwd_display:+${cwd_display}${SEP}}${model_color}${model_name}${model_color:+${RESET}}"

if [ -n "$cost_display" ]; then
  line1+="${SEP}${cost_display}"
fi

ctx_color=$(color_for_pct "$ctx_pct_int")
line1+="${SEP}${ctx_color}${ctx_pct_int}%${RESET}"

# ---------- Line 2 (two usage slots side by side) ----------
part_a=$(slot_text "$A_KIND" "$A_PCT" "$A_RESET" "")
part_b=$(slot_text "$B_KIND" "$B_PCT" "$B_RESET" "$B_TEXT")

line2=""
[ -n "$part_a" ] && line2="${GRAY_5H}${part_a}${RESET}"
if [ -n "$part_b" ]; then
  line2+="${line2:+${SEP}}${GRAY_7D}${part_b}${RESET}"
fi

# ---------- Output ----------
printf '%s\n' "$line1"
printf '%s' "$line2"
