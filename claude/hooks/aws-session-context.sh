#!/bin/bash
# SessionStart hook: inject the current AWS identity into session context so
# Claude knows which account/role it is operating against without the user
# typing '!aws sts get-caller-identity'.
# stdout of a SessionStart hook is appended to the session context.

HELPER="$(dirname "$0")/aws-identity.sh"
[ -x "$HELPER" ] || [ -f "$HELPER" ] || exit 0

json=$(bash "$HELPER" check 2> /dev/null)
[ -z "$json" ] && exit 0

status=$(echo "$json" | jq -r '.status // "unknown"' 2> /dev/null)
profile=$(echo "$json" | jq -r '.profile // "default"' 2> /dev/null)
account=$(echo "$json" | jq -r '.account // empty' 2> /dev/null)
arn=$(echo "$json" | jq -r '.arn // empty' 2> /dev/null)

case "$status" in
  ok)
    echo "[aws-identity] Current AWS session: profile=${profile}, account=${account}, arn=${arn}. Re-verify with 'aws sts get-caller-identity' only if the user switches profiles mid-session."
    ;;
  expired)
    echo "[aws-identity] AWS credentials for profile '${profile}' are EXPIRED. Do NOT attempt to re-authenticate and do NOT suggest specific login commands -- whether and how to authenticate is strictly the user's decision (they use aws-vault). Report the credential state and wait for the user before running AWS CLI commands."
    ;;
  *)
    # none/error/unknown: stay silent to avoid noise in non-AWS projects.
    exit 0
    ;;
esac
