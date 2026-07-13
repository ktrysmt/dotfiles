#!/bin/bash
# PreToolUse(Bash) hook: keep role/credential acquisition a human-only action.
# Whether and when to assume a role or authenticate is strictly the user's
# decision (they use aws-vault), so this hook blocks:
#   - explicit auth commands (aws sso login/logout, aws-vault login/add/rotate)
#   - any aws CLI command when no session exists in the environment yet, because
#     resolving a role/SSO profile would silently perform sts:AssumeRole
#   - aws CLI commands whose active session is expired or has no credentials
# When a session is already active in the environment (aws-vault exec / static
# creds), the identity check reuses it and never triggers a new assume.
# Offline diagnostics (aws configure list/get, aws --version) are always allowed.
# Fails open on transient errors so it never gets in the way.

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty' 2> /dev/null)
[ -z "$cmd" ] && exit 0

# Authentication is user-only territory. Block login/credential-acquisition
# commands regardless of credential state. Checked first because 'aws-vault'
# does not match the aws-CLI detection pattern below.
if echo "$cmd" | grep -qE '(^|[|&;(]|\$\()[[:space:]]*(aws[[:space:]]+sso[[:space:]]+(login|logout)|aws-vault[[:space:]]+(login|add|rotate))'; then
  echo "Do not run authentication commands. Whether and how to authenticate is the user's decision (they use aws-vault). Report the credential state and wait for the user." >&2
  exit 2
fi

# Only commands that invoke the aws CLI at a command position
# (start of line, after |, &, ;, ( or $( ). 'grep aws file' does not match.
echo "$cmd" | grep -qE '(^|[|&;(]|\$\()[[:space:]]*aws[[:space:]]' || exit 0

# Offline diagnostics that never contact STS (and so never assume) are always
# allowed. Note: `aws sts get-caller-identity` is intentionally NOT here -- with
# no active session it would itself trigger an assume, so it goes through the
# session check below and is allowed only when a session already exists.
echo "$cmd" | grep -qE 'aws[[:space:]]+(configure[[:space:]]+(list|get)|--version)' && exit 0

HELPER="$(dirname "$0")/aws-identity.sh"
[ -f "$HELPER" ] || exit 0

json=$(bash "$HELPER" check 2> /dev/null)
status=$(echo "$json" | jq -r '.status // "unknown"' 2> /dev/null)
profile=$(echo "$json" | jq -r '.profile // "default"' 2> /dev/null)

case "$status" in
  expired)
    echo "AWS credentials for profile '${profile}' are expired. Do not retry AWS CLI commands and do not attempt to re-authenticate -- that is the user's decision (they use aws-vault). Report the credential state to the user and wait." >&2
    exit 2
    ;;
  unauthenticated)
    echo "No active AWS session in this environment. Running this AWS CLI command would assume a role / acquire credentials, which is strictly the user's decision (they use aws-vault) -- do not run it. Ask the user to start a session (e.g. 'aws-vault exec <profile> -- <command>') or wait for them to provide one." >&2
    exit 2
    ;;
  none)
    echo "No AWS credentials are configured for profile '${profile}'. Do not attempt to authenticate -- report this to the user and wait for them to provide a session (they use aws-vault)." >&2
    exit 2
    ;;
  *)
    # ok/error/unknown: fail open.
    exit 0
    ;;
esac
