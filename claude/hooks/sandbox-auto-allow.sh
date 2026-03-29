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

# --- Detection patterns ---
# Categorized by: TLS/SSL, Connection/Proxy, DNS
SSL_PATTERNS='tls: failed to verify certificate'   # Go
SSL_PATTERNS+='|x509:'                              # Go (macOS OSStatus / Linux unknown authority)
SSL_PATTERNS+='|SSL certificate problem'            # curl
SSL_PATTERNS+='|certificate verify failed'          # OpenSSL (Ruby, Python, Rust, C)
SSL_PATTERNS+='|SSL_connect returned=1'             # Ruby OpenSSL
SSL_PATTERNS+='|OpenSSL::SSL::SSLError'             # Ruby
SSL_PATTERNS+='|ssl\.SSLError'                      # Python
SSL_PATTERNS+='|UNABLE_TO_VERIFY_LEAF_SIGNATURE'    # Node.js
SSL_PATTERNS+='|SELF_SIGNED_CERT_IN_CHAIN'          # Node.js
SSL_PATTERNS+='|CERT_HAS_EXPIRED'                   # Node.js
SSL_PATTERNS+='|DEPTH_ZERO_SELF_SIGNED_CERT'        # Node.js
SSL_PATTERNS+='|ERR_TLS_CERT_ALTNAME_INVALID'       # Node.js
SSL_PATTERNS+='|InvalidCertificate'                 # Rust rustls
SSL_PATTERNS+='|gnutls.*certificate'                # GnuTLS (C/C++)
SSL_PATTERNS+='|UNABLE_TO_GET_ISSUER_CERT'           # Node.js
SSL_PATTERNS+='|ERR_CERT_AUTHORITY_INVALID'           # Node.js (Chromium)
SSL_PATTERNS+='|CERT_UNTRUSTED'                       # Node.js
SSL_PATTERNS+='|PKIX path building failed'            # Java
SSL_PATTERNS+='|unable to get local issuer certificate' # curl/OpenSSL

CONN_PATTERNS='dial tcp.*(Operation not permitted|connection refused)'  # Go
CONN_PATTERNS+='|proxyconnect tcp:'                 # Go proxy
CONN_PATTERNS+='|ECONNREFUSED'                      # Node.js
CONN_PATTERNS+='|ECONNRESET'                        # Node.js
CONN_PATTERNS+='|ETIMEDOUT'                         # Node.js
CONN_PATTERNS+='|ConnectionRefusedError'            # Python
CONN_PATTERNS+='|ConnectionResetError'              # Python
CONN_PATTERNS+='|ProxyError'                        # Python requests
CONN_PATTERNS+='|Proxy CONNECT aborted'             # curl proxy
CONN_PATTERNS+='|tunnel connection failed'          # curl proxy
CONN_PATTERNS+='|Received HTTP code [0-9]+ from proxy'  # curl proxy
CONN_PATTERNS+='|Failed to connect to'              # curl
CONN_PATTERNS+='|i/o timeout'                        # Go
CONN_PATTERNS+='|Connection timed out'               # curl / POSIX
CONN_PATTERNS+='|Connection reset by peer'           # curl / POSIX
CONN_PATTERNS+='|Network is unreachable'             # Linux
CONN_PATTERNS+='|No route to host'                   # Linux

DNS_PATTERNS='Could not resolve host'               # curl
DNS_PATTERNS+='|ENOTFOUND'                          # Node.js
DNS_PATTERNS+='|no such host'                       # Go
DNS_PATTERNS+='|Name or service not known'           # Linux glibc
DNS_PATTERNS+='|nodename nor servname provided'      # macOS
DNS_PATTERNS+='|Temporary failure in name resolution' # Linux
DNS_PATTERNS+='|getaddrinfo.*failed'                 # C/C++
DNS_PATTERNS+='|dns.*failed to lookup'               # Rust
DNS_PATTERNS+='|NXDOMAIN'                           # DNS response
DNS_PATTERNS+='|SERVFAIL'                           # DNS response
DNS_PATTERNS+='|socket\.gaierror'                     # Python
DNS_PATTERNS+='|UnknownHostException'                 # Java
DNS_PATTERNS+='|unable to resolve host address'       # wget
DNS_PATTERNS+='|SocketError.*getaddrinfo'             # Ruby

if ! printf '%s\n%s' "$stdout" "$stderr" \
  | grep -qE "${SSL_PATTERNS}|${CONN_PATTERNS}|${DNS_PATTERNS}"; then
  exit 0
fi

# --- Domain extraction ---
combined=$(printf '%s\n%s' "$stdout" "$stderr")
# URL: http(s)://domain/...
url_domains=$(printf '%s' "$combined" | grep -oE 'https?://[^/"'"'"'[:space:]]+' | sed 's|https\{0,1\}://||' || true)
# Go: dial tcp: lookup domain:
dial_domains=$(printf '%s' "$combined" | grep -oE 'dial tcp: lookup [^ :]+' | sed 's/^dial tcp: lookup //' || true)
# curl: Could not resolve host: domain
resolve_domains=$(printf '%s' "$combined" | grep -oE 'Could not resolve host: [^ ]+' | sed 's/^Could not resolve host: //' || true)
# Node.js: getaddrinfo ENOTFOUND domain
notfound_domains=$(printf '%s' "$combined" | grep -oE 'ENOTFOUND [^ ]+' | sed 's/^ENOTFOUND //' || true)
# curl: Failed to connect to domain port NNN
failed_domains=$(printf '%s' "$combined" | grep -oE 'Failed to connect to [^ ]+ port' | sed 's/^Failed to connect to //;s/ port$//' || true)
# Go: no such host "domain"
nohost_domains=$(printf '%s' "$combined" | grep -oE 'no such host "[^"]+"' | sed 's/^no such host "//;s/"$//' || true)
# General: connect to domain port NNN failed
connect_domains=$(printf '%s' "$combined" | grep -oE 'connect to [^ ]+ port [0-9]+ failed' | sed 's/^connect to //;s/ port [0-9]* failed$//' || true)
# Java: UnknownHostException: domain
unknownhost_domains=$(printf '%s' "$combined" | grep -oE 'UnknownHostException: [^ ]+' | sed 's/^UnknownHostException: //' || true)
# wget: unable to resolve host address 'domain'
wget_domains=$(printf '%s' "$combined" | grep -oE "unable to resolve host address '[^']+'" | sed "s/^unable to resolve host address '//;s/'$//" || true)
# Linux/macOS DNS: getaddrinfo ... Name or service not known / nodename nor servname
# These don't reliably embed the domain, so we fall back to URL extraction above
domains=$(printf '%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s' \
  "$url_domains" "$dial_domains" "$resolve_domains" "$notfound_domains" \
  "$failed_domains" "$nohost_domains" "$connect_domains" \
  "$unknownhost_domains" "$wget_domains" \
  | grep -v '^$' | sort -u || true)
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
