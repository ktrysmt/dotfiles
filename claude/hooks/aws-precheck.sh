#!/bin/bash
# PreToolUse(Bash) hook: block AWS CLI invocations while credentials are
# expired or missing, instead of letting a chain of aws commands fail one by
# one. Also blocks any authentication-initiating command: whether and how to
# authenticate is strictly the user's decision (they use aws-vault).
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

# Read-only identity/diagnostic commands are always allowed.
echo "$cmd" | grep -qE 'aws[[:space:]]+(sts[[:space:]]+get-caller-identity|configure[[:space:]]+(list|get)|--version)' && exit 0

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
  none)
    echo "No AWS credentials are configured for profile '${profile}'. Do not attempt to authenticate -- report this to the user and wait for them to provide a session (they use aws-vault)." >&2
    exit 2
    ;;
  *)
    # ok/error/unknown: fail open.
    exit 0
    ;;
esac
