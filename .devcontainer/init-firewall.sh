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
#   FIREWALL_MODE           "strict" (default) = block unlisted traffic
#                           "permissive"       = log but allow all traffic

set -euo pipefail
IFS=$'\n\t'

FIREWALL_MODE="${FIREWALL_MODE:-strict}"
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
ipset destroy allowed-domains 2>/dev/null || true

if [ -n "$DOCKER_DNS_RULES" ]; then
    echo "Restoring Docker DNS rules..."
    iptables -t nat -N DOCKER_OUTPUT 2>/dev/null || true
    iptables -t nat -N DOCKER_POSTROUTING 2>/dev/null || true
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
ipset create allowed-domains hash:net

# --- GitHub IP ranges (dynamic) ---
echo "Fetching GitHub IP ranges..."
gh_ranges=$(curl -s https://api.github.com/meta)
if [ -z "$gh_ranges" ]; then
    echo "ERROR: Failed to fetch GitHub IP ranges"
    exit 1
fi

if ! echo "$gh_ranges" | jq -e '.web and .api and .git' >/dev/null; then
    echo "ERROR: GitHub API response missing required fields"
    exit 1
fi

echo "Processing GitHub IPs..."
while read -r cidr; do
    if [[ ! "$cidr" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then
        echo "ERROR: Invalid CIDR range from GitHub meta: $cidr"
        exit 1
    fi
    ipset add allowed-domains "$cidr"
done < <(echo "$gh_ranges" | jq -r '(.web + .api + .git)[]' | aggregate -q)

# --- Static domain whitelist ---
ALLOWED_DOMAINS=(
    # Core (official Anthropic devcontainer)
    "registry.npmjs.org"
    "api.anthropic.com"
    "sentry.io"
    "statsig.anthropic.com"
    "statsig.com"
    "marketplace.visualstudio.com"
    "vscode.blob.core.windows.net"
    "update.code.visualstudio.com"
    # PyPI (uvx MCP servers)
    "pypi.org"
    "files.pythonhosted.org"
    # MCP server endpoints
    "knowledge-mcp.global.api.aws"
    "mcp.grep.app"
    # Go module proxy
    "proxy.golang.org"
    "sum.golang.org"
    # Rust crates
    "crates.io"
    "static.crates.io"
)

# --- Extra domains from environment variable ---
if [ -n "${FIREWALL_EXTRA_DOMAINS:-}" ]; then
    IFS=',' read -ra EXTRA <<< "$FIREWALL_EXTRA_DOMAINS"
    for d in "${EXTRA[@]}"; do
        d=$(echo "$d" | xargs)  # trim whitespace
        [ -n "$d" ] && ALLOWED_DOMAINS+=("$d")
    done
    echo "Extra domains added: $FIREWALL_EXTRA_DOMAINS"
fi

for domain in "${ALLOWED_DOMAINS[@]}"; do
    echo "Resolving $domain..."
    ips=$(dig +noall +answer A "$domain" | awk '$4 == "A" {print $5}')
    if [ -z "$ips" ]; then
        echo "WARNING: Failed to resolve $domain (skipping)"
        continue
    fi

    while read -r ip; do
        if [[ ! "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            echo "WARNING: Invalid IP from DNS for $domain: $ip (skipping)"
            continue
        fi
        ipset add allowed-domains "$ip" 2>/dev/null || true
    done < <(echo "$ips")
done

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
    if curl --connect-timeout 5 https://example.com >/dev/null 2>&1; then
        echo "ERROR: Firewall verification failed - example.com is reachable"
        exit 1
    else
        echo "OK: example.com blocked"
    fi
fi

if ! curl --connect-timeout 5 https://api.github.com/zen >/dev/null 2>&1; then
    echo "ERROR: Firewall verification failed - api.github.com unreachable"
    exit 1
else
    echo "OK: api.github.com reachable"
fi

echo "Firewall ready."
