#!/bin/bash
# Claude Code statusline script
# Line 1: Model | Context% | +added/-removed | git branch
# Line 2: 5h rate limit progress bar
# Line 3: 7d rate limit progress bar

input=$(cat)

# ---------- ANSI Colors ----------
GREEN=$'\e[38;2;151;201;195m'
YELLOW=$'\e[38;2;229;192;123m'
RED=$'\e[38;2;224;108;117m'
GRAY=$'\e[38;2;74;88;92m'
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
  "cc_version=" + (.version // "0.0.0" | @sh)
' 2> /dev/null)"

# ---------- cwd (shorten HOME to ~) ----------
cwd_display=""
if [ -n "$cwd" ]; then
  git_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
  if [ -n "$git_root" ]; then
    repo_name=$(basename "$git_root")
    rel=$(realpath --relative-to="$git_root" "$cwd" 2>/dev/null || echo "")
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

# ---------- Rate limit via Haiku probe (cached 360s) ----------
CACHE_FILE="/tmp/claude-usage-cache.json"
CACHE_TTL=360
FIVE_HOUR_UTIL=""
FIVE_HOUR_RESET=""
SEVEN_DAY_UTIL=""
SEVEN_DAY_RESET=""

fetch_usage() {
  local token
  token=$(security find-generic-password -s "Claude Code-credentials" -w 2> /dev/null || true)
  # Linux fallback: read from ~/.claude/.credentials.json
  if [ -z "$token" ]; then
    token=$(cat ~/.claude/.credentials.json 2> /dev/null || true)
  fi
  [ -z "$token" ] && return 1

  local access_token
  if echo "$token" | jq -e . > /dev/null 2>&1; then
    access_token=$(echo "$token" | jq -r '.claudeAiOauth.accessToken // empty' 2> /dev/null)
  else
    access_token="$token"
  fi
  [ -z "$access_token" ] && return 1

  # Tiny Haiku call (max_tokens=1) to get rate limit response headers
  # -si includes headers in output; -D- writes headers to stdout
  local full_response
  full_response=$(curl -sD- --max-time 8 -o /dev/null \
    -H "Authorization: Bearer ${access_token}" \
    -H "Content-Type: application/json" \
    -H "User-Agent: claude-code/${cc_version:-0.0.0}" \
    -H "anthropic-beta: oauth-2025-04-20" \
    -H "anthropic-version: 2023-06-01" \
    -d '{"model":"claude-haiku-4-5-20251001","max_tokens":1,"messages":[{"role":"user","content":"h"}]}' \
    "https://api.anthropic.com/v1/messages" 2> /dev/null || true)
  local headers="$full_response"
  [ -z "$headers" ] && return 1

  # Parse rate limit headers
  local h5_util h5_reset h7_util h7_reset
  h5_util=$(echo "$headers" | grep -i 'anthropic-ratelimit-unified-5h-utilization' | tr -d '\r' | awk '{print $2}')
  h5_reset=$(echo "$headers" | grep -i 'anthropic-ratelimit-unified-5h-reset' | tr -d '\r' | awk '{print $2}')
  h7_util=$(echo "$headers" | grep -i 'anthropic-ratelimit-unified-7d-utilization' | tr -d '\r' | awk '{print $2}')
  h7_reset=$(echo "$headers" | grep -i 'anthropic-ratelimit-unified-7d-reset' | tr -d '\r' | awk '{print $2}')

  [ -z "$h5_util" ] && return 1

  # Save to cache as JSON
  jq -n \
    --arg h5u "$h5_util" --arg h5r "$h5_reset" \
    --arg h7u "$h7_util" --arg h7r "$h7_reset" \
    '{five_hour_util: $h5u, five_hour_reset: $h5r, seven_day_util: $h7u, seven_day_reset: $h7r}' \
    > "$CACHE_FILE"
  return 0
}

load_usage() {
  local data="$1"
  eval "$(echo "$data" | jq -r '
    "FIVE_HOUR_UTIL=" + (.five_hour_util // empty),
    "FIVE_HOUR_RESET=" + (.five_hour_reset // empty),
    "SEVEN_DAY_UTIL=" + (.seven_day_util // empty),
    "SEVEN_DAY_RESET=" + (.seven_day_reset // empty)
  ' 2> /dev/null)"
}

# Check cache validity
USE_CACHE=false
if [ -f "$CACHE_FILE" ]; then
  cache_age=$(($(date +%s) - $(stat -c '%Y' "$CACHE_FILE" 2> /dev/null || stat -f '%m' "$CACHE_FILE" 2> /dev/null || echo 0)))
  if [ "$cache_age" -lt "$CACHE_TTL" ]; then
    USE_CACHE=true
  fi
fi

if $USE_CACHE; then
  load_usage "$(cat "$CACHE_FILE")"
else
  if fetch_usage; then
    load_usage "$(cat "$CACHE_FILE")"
  elif [ -f "$CACHE_FILE" ]; then
    load_usage "$(cat "$CACHE_FILE")"
  fi
fi

# Convert utilization (0.0-1.0) to percentage
to_pct() {
  local val="$1"
  if [ -z "$val" ] || [ "$val" = "null" ] || [ "$val" = "0" ]; then
    echo ""
    return
  fi
  awk "BEGIN{printf \"%.0f\", $val * 100}" 2> /dev/null || echo ""
}

FIVE_HOUR_PCT=$(to_pct "$FIVE_HOUR_UTIL")
SEVEN_DAY_PCT=$(to_pct "$SEVEN_DAY_UTIL")

# ---------- Format reset time (from epoch seconds) ----------
format_epoch_time() {
  local epoch="$1"
  local format="$2"
  [ -z "$epoch" ] || [ "$epoch" = "0" ] && echo "" && return
  local result
  result=$(TZ="Asia/Tokyo" date -j -f "%s" "$epoch" "$format" 2> /dev/null \
    || TZ="Asia/Tokyo" date -d "@${epoch}" "$format" 2> /dev/null || echo "")
  echo "$result" | sed 's/AM/am/;s/PM/pm/'
}

five_reset_display=""
if [ -n "$FIVE_HOUR_RESET" ] && [ "$FIVE_HOUR_RESET" != "0" ]; then
  five_reset_display="Resets $(format_epoch_time "$FIVE_HOUR_RESET" "+%-I%p") (Asia/Tokyo)"
fi

seven_reset_display=""
if [ -n "$SEVEN_DAY_RESET" ] && [ "$SEVEN_DAY_RESET" != "0" ]; then
  seven_reset_display="Resets $(format_epoch_time "$SEVEN_DAY_RESET" "+%b %-d at %-I%p") (Asia/Tokyo)"
fi

# ---------- Format context used% ----------
ctx_pct_int=0
if [ -n "$used_pct" ] && [ "$used_pct" != "null" ] && [ "$used_pct" != "0" ]; then
  ctx_pct_int=$(printf "%.0f" "$used_pct" 2> /dev/null || echo 0)
fi

# ---------- Line 1 ----------
SEP="${GRAY} │ ${RESET}"
line1="${cwd_display:+${cwd_display}${SEP}}${model_name}"

if [ -n "$cost_display" ]; then
  line1+="${SEP}${cost_display}"
fi

ctx_color=$(color_for_pct "$ctx_pct_int")
line1+="${SEP}${ctx_color}${ctx_pct_int}%${RESET}"

# ---------- Line 2 (5h + 7d side by side) ----------
part5=""
if [ -n "$FIVE_HOUR_PCT" ]; then
  bar5=$(progress_bar "$FIVE_HOUR_PCT")
  part5="${GRAY}5h ${bar5} ${FIVE_HOUR_PCT}%${RESET}"
else
  part5="${GRAY}5h ▱▱▱▱▱▱▱▱▱▱ --%${RESET}"
fi

part7=""
if [ -n "$SEVEN_DAY_PCT" ]; then
  bar7=$(progress_bar "$SEVEN_DAY_PCT")
  part7="${GRAY}7d ${bar7} ${SEVEN_DAY_PCT}%${RESET}"
else
  part7="${GRAY}7d ▱▱▱▱▱▱▱▱▱▱ --%${RESET}"
fi

line2="${part5}${SEP}${part7}"

# ---------- Output ----------
printf '%s\n' "$line1"
printf '%s' "$line2"
