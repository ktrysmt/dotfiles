#!/bin/bash
# Firewall configuration for Claude Code devcontainer
# Based on: https://github.com/anthropics/claude-code/blob/main/.devcontainer/init-firewall.sh
#
# Allows traffic only to:
#   - GitHub (web, API, git)
#   - npm registry
#   - Anthropic API
#   - PyPI (for uvx)
#   - MCP server endpoints (AWS docs, grep.app, etc.)
#   - VS Code services
#   - Host network (Docker communication)
#
# Environment variables:
#   FIREWALL_EXTRA_DOMAINS  Comma-separated additional domains to allow
#                           e.g. "api.example.com,cdn.example.com"
#   FIREWALL_MODE           "permissive" (default) = log but allow all traffic
#                           "strict"               = block unlisted traffic

set -euo pipefail
IFS=$'\n\t'

FIREWALL_MODE="${FIREWALL_MODE:-permissive}"
echo "Firewall mode: $FIREWALL_MODE"

# --------------------------------------------------------------------------
# 1. Preserve Docker DNS rules
# --------------------------------------------------------------------------
DOCKER_DNS_RULES=$(iptables-save -t nat | grep "127\.0\.0\.11" || true)

iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
ipset destroy allowed-domains 2> /dev/null || true

if [ -n "$DOCKER_DNS_RULES" ]; then
  echo "Restoring Docker DNS rules..."
  iptables -t nat -N DOCKER_OUTPUT 2> /dev/null || true
  iptables -t nat -N DOCKER_POSTROUTING 2> /dev/null || true
  echo "$DOCKER_DNS_RULES" | xargs -L 1 iptables -t nat
else
  echo "No Docker DNS rules to restore"
fi

# --------------------------------------------------------------------------
# 2. Allow DNS, SSH, localhost before restrictions
# --------------------------------------------------------------------------
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# --------------------------------------------------------------------------
# 3. Build allowed IP set
# --------------------------------------------------------------------------
IPSET_TIMEOUT="${FIREWALL_IPSET_TIMEOUT:-3600}"
export FIREWALL_IPSET_TIMEOUT="$IPSET_TIMEOUT"

ipset create allowed-domains hash:net timeout "$IPSET_TIMEOUT"

# --- Resolve domains and populate ipset (shared with refresh-firewall.sh) ---
/usr/local/bin/refresh-firewall.sh

# --- Register cron to periodically refresh ipset ---
REFRESH_INTERVAL="${FIREWALL_REFRESH_INTERVAL:-30}"
CRON_LINE="*/${REFRESH_INTERVAL} * * * * FIREWALL_IPSET_TIMEOUT=${IPSET_TIMEOUT} FIREWALL_EXTRA_DOMAINS=${FIREWALL_EXTRA_DOMAINS:-} /usr/local/bin/refresh-firewall.sh --quiet 2>&1 | logger -t refresh-firewall"
{ crontab -l 2> /dev/null || true; } | { grep -v refresh-firewall || true; } | {
  cat
  echo "$CRON_LINE"
} | crontab -
service cron start > /dev/null 2>&1 || true
echo "Cron registered: refresh ipset every ${REFRESH_INTERVAL}m"

# --------------------------------------------------------------------------
# 4. Host network
# --------------------------------------------------------------------------
HOST_IP=$(ip route | grep default | cut -d" " -f3)
if [ -z "$HOST_IP" ]; then
  echo "ERROR: Failed to detect host IP"
  exit 1
fi

HOST_NETWORK=$(echo "$HOST_IP" | sed "s/\.[0-9]*$/.0\/24/")
echo "Host network detected as: $HOST_NETWORK"

iptables -A INPUT -s "$HOST_NETWORK" -j ACCEPT
iptables -A OUTPUT -d "$HOST_NETWORK" -j ACCEPT

# --------------------------------------------------------------------------
# 5. Apply policy
# --------------------------------------------------------------------------
iptables -P INPUT DROP
iptables -P FORWARD DROP

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m set --match-set allowed-domains dst -j ACCEPT

if [ "$FIREWALL_MODE" = "permissive" ]; then
  # Log unlisted traffic but allow it
  iptables -A OUTPUT -j LOG --log-prefix "[FIREWALL-UNLISTED] " --log-level 4
  iptables -P OUTPUT ACCEPT
  echo "WARNING: Permissive mode - unlisted traffic is logged but allowed"
else
  # Block unlisted traffic
  iptables -P OUTPUT DROP
  iptables -A OUTPUT -j REJECT --reject-with icmp-admin-prohibited
fi

# --------------------------------------------------------------------------
# 6. Verification
# --------------------------------------------------------------------------
echo "Firewall configuration complete. Verifying..."

if [ "$FIREWALL_MODE" = "permissive" ]; then
  echo "SKIP: Verification skipped in permissive mode"
else
  if curl --connect-timeout 5 https://example.com > /dev/null 2>&1; then
    echo "ERROR: Firewall verification failed - example.com is reachable"
    exit 1
  else
    echo "OK: example.com blocked"
  fi
fi

if ! curl --connect-timeout 5 https://api.github.com/zen > /dev/null 2>&1; then
  echo "ERROR: Firewall verification failed - api.github.com unreachable"
  exit 1
else
  echo "OK: api.github.com reachable"
fi

echo "Firewall ready."
