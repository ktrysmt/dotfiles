#!/bin/bash
# Refresh ipset entries by re-resolving DNS for allowed domains.
# Called by init-firewall.sh on setup and periodically via cron.
#
# Usage:
#   refresh-firewall.sh          # resolve domains + GitHub meta
#   refresh-firewall.sh --quiet  # suppress per-domain output (for cron)

set -uo pipefail
IFS=$'\n\t'

QUIET=false
[[ "${1:-}" == "--quiet" ]] && QUIET=true

log() { "$QUIET" || echo "$@"; }

IPSET_TIMEOUT="${FIREWALL_IPSET_TIMEOUT:-3600}"

# --------------------------------------------------------------------------
# GitHub IP ranges
# --------------------------------------------------------------------------
log "Fetching GitHub IP ranges..."
gh_ranges=$(curl -sf https://api.github.com/meta || true)
if [ -n "$gh_ranges" ] && echo "$gh_ranges" | jq -e '.web and .api and .git' >/dev/null 2>&1; then
    while read -r cidr; do
        [[ "$cidr" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]] || continue
        ipset -exist add allowed-domains "$cidr" timeout "$IPSET_TIMEOUT"
    done < <(echo "$gh_ranges" | jq -r '(.web + .api + .git)[]' | aggregate -q)
    log "GitHub IPs refreshed."
else
    echo "WARNING: Failed to fetch GitHub IP ranges (skipping)" >&2
fi

# --------------------------------------------------------------------------
# Static domain whitelist
# --------------------------------------------------------------------------
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
    # Claude Code installer
    "claude.ai"
    "storage.googleapis.com"
)

# Extra domains from environment variable
if [ -n "${FIREWALL_EXTRA_DOMAINS:-}" ]; then
    IFS=',' read -ra EXTRA <<< "$FIREWALL_EXTRA_DOMAINS"
    for d in "${EXTRA[@]}"; do
        d=$(echo "$d" | xargs)
        [ -n "$d" ] && ALLOWED_DOMAINS+=("$d")
    done
fi

for domain in "${ALLOWED_DOMAINS[@]}"; do
    log "Resolving $domain..."
    ips=$(dig +noall +answer A "$domain" | awk '$4 == "A" {print $5}')
    if [ -z "$ips" ]; then
        log "WARNING: Failed to resolve $domain (skipping)"
        continue
    fi
    while read -r ip; do
        [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] || continue
        ipset -exist add allowed-domains "$ip" timeout "$IPSET_TIMEOUT"
    done < <(echo "$ips")
done

log "ipset refresh complete."
