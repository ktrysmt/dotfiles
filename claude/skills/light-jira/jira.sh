#!/usr/bin/env bash
# Thin Jira Cloud client for the light-jira skill.
#
# REST v2 on purpose (not v3): v2 takes and returns issue descriptions and
# comment bodies as wiki-markup STRINGS, so no ADF document ever has to be
# built or parsed. Every response is jq-filtered here, so the caller only ever
# sees a few lines instead of a multi-KB issue blob.
#
# Auth: ATLASSIAN_API_KEY (required) + account email.
#   ATLASSIAN_EMAIL overrides the email, JIRA_SITE overrides the host.
set -euo pipefail

: "${ATLASSIAN_API_KEY:?ATLASSIAN_API_KEY is not set}"
EMAIL="${ATLASSIAN_EMAIL:-$(git config --global user.email || true)}"
[[ -n "$EMAIL" ]] || { echo "cannot resolve the Atlassian account email: export ATLASSIAN_EMAIL" >&2; exit 2; }
SITE="${JIRA_SITE:-}"
KEY=""
TMP="${TMPDIR:-/tmp}"; TMP="${TMP%/}/light-jira"
mkdir -p "$TMP"

die() { echo "light-jira: $*" >&2; exit 2; }

site() { # host fallback: <first label of the email domain>.atlassian.net
  if [[ -z "$SITE" ]]; then local dom="${EMAIL#*@}"; SITE="${dom%%.*}.atlassian.net"; fi
  echo "$SITE"
}

resolve() { # accepts SRE-1234, .../browse/SRE-1234[?...], ...?selectedIssue=SRE-1234
  local a="${1:-}"
  [[ -n "$a" ]] || die "issue key or URL is required"
  if [[ "$a" =~ ^https?://([^/]+)/ ]]; then
    SITE="${BASH_REMATCH[1]}"
    if [[ "$a" =~ selectedIssue=([A-Za-z][A-Za-z0-9_]*-[0-9]+) ]]; then a="${BASH_REMATCH[1]}"
    else a="${a##*/}"; a="${a%%\?*}"; fi
  fi
  KEY=$(printf '%s' "$a" | tr '[:lower:]' '[:upper:]')
  [[ "$KEY" =~ ^[A-Z][A-Z0-9_]*-[0-9]+$ ]] || die "not an issue key: $1"
  site >/dev/null
}

api() { # api <METHOD> <path> [curl args...] -- surfaces Jira error messages, not curl exit codes
  local m="$1" p="$2"; shift 2
  local out rc=0
  out=$(curl -s --fail-with-body -u "$EMAIL:$ATLASSIAN_API_KEY" \
    -H 'Accept: application/json' -X "$m" "https://$(site)/rest/api/2${p}" "$@") || rc=$?
  if [[ $rc -ne 0 ]]; then
    { printf '%s' "$out" | jq -r '((.errorMessages // []) + ((.errors // {}) | to_entries | map("\(.key): \(.value)")))[]' 2>/dev/null \
      || printf '%s\n' "$(printf '%s' "$out" | head -c 300)"; } >&2
    die "$m $p failed (curl rc=$rc)"
  fi
  printf '%s' "$out"
}

post_json() { # post_json <METHOD> <path> <payload.json> [min-bytes]
  local m="$1" p="$2" f="$3" min="${4:-2}"
  local n; n=$(wc -c <"$f" | tr -d ' ')
  [[ "$n" -lt "$min" ]] && die "payload $f is only $n bytes (expected >= $min): the body did not make it in"
  api "$m" "$p" -H 'Content-Type: application/json' --data-binary @"$f"
}

mkjson() { # mkjson <out.json> key.path=value | key.path=@file | key.path=json:<literal>
  local out="$1"; shift
  python3 - "$out" "$@" <<'PY'
import json, sys
out, args = sys.argv[1], sys.argv[2:]
doc = {}
for a in args:
    k, v = a.split('=', 1)
    if v.startswith('@'):
        v = open(v[1:], encoding='utf-8').read()
    elif v.startswith('json:'):
        v = json.loads(v[5:])
    node = doc
    parts = k.split('.')
    for p in parts[:-1]:
        node = node.setdefault(p, {})
    node[parts[-1]] = v
with open(out, 'w', encoding='utf-8') as fh:
    json.dump(doc, fh, ensure_ascii=False)
PY
}

account_id() { # me | <email or display-name> | none -- exact-ish match only, never a fuzzy guess
  case "$1" in
    me|self) api GET /myself | jq -r .accountId ;;
    none|unassign|-1) echo "-1" ;;
    *)
      local users id
      users=$(api GET /user/search -G --data-urlencode "query=$1")
      id=$(jq -r --arg q "$1" '[ .[] | select(.active)
            | select((((.emailAddress // "") | ascii_downcase) == ($q | ascii_downcase))
                  or (((.displayName  // "") | ascii_downcase) == ($q | ascii_downcase))) ]
            | if length == 1 then .[0].accountId else "" end' <<<"$users")
      if [[ -z "$id" ]]; then
        echo "no unique active user matches \"$1\". candidates from Jira:" >&2
        jq -r '.[] | "  \(.displayName)\t\(.emailAddress // "(hidden email)")\t\(.accountId)"' <<<"$users" >&2
        die "pass an exact email or display name (or an accountId via --json)"
      fi
      echo "$id" ;;
  esac
}

cmd_me() {
  api GET /myself | jq -r '"\(.displayName) <\(.emailAddress)> accountId=\(.accountId)"'
  echo "site: https://$(site)"
}

cmd_get() {
  resolve "${1:-}"; shift || true
  local out="$TMP/$KEY.txt" fields='summary,status,issuetype,priority,assignee,reporter,labels,parent,resolution,duedate,created,updated,description'
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --out) out="$2"; shift 2 ;;
      --fields) fields="$2,description"; shift 2 ;;
      *) die "unknown option for get: $1" ;;
    esac
  done
  local j; j=$(api GET "/issue/$KEY" -G --data-urlencode "fields=$fields")
  jq -r --arg key "$KEY" --arg site "$(site)" '.fields as $f |
    "\($key)  [\($f.status.name)]  type=\($f.issuetype.name // "-")  pri=\($f.priority.name // "-")",
    "summary : \($f.summary)",
    "people  : assignee=\($f.assignee.displayName // "-") reporter=\($f.reporter.displayName // "-")",
    "meta    : labels=\(($f.labels // []) | join(",") | if . == "" then "-" else . end) parent=\($f.parent.key // "-") due=\($f.duedate // "-") resolution=\($f.resolution.name // "-")",
    "dates   : created=\(($f.created // "-")[0:10]) updated=\(($f.updated // "-")[0:19])",
    "url     : https://\($site)/browse/\($key)"' <<<"$j"
  jq -rj '.fields.description // ""' <<<"$j" >"$out"   # -j: no trailing newline, so get -> edit round-trips byte-for-byte
  local n; n=$(wc -c <"$out" | tr -d ' ')
  if [[ "$n" -le 1 ]]; then echo "desc    : (empty)"; else echo "desc    : $out ($n bytes, wiki markup)"; fi
}

cmd_search() {
  local jql="${1:-}"; shift || true
  [[ -n "$jql" ]] || die "JQL is required"
  local max=20 fields='summary,status,assignee,updated'
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --max) max="$2"; shift 2 ;;
      --fields) fields="$2"; shift 2 ;;
      *) die "unknown option for search: $1" ;;
    esac
  done
  # /search/jql, never /search: api/2/search answers HTTP 410 Gone (CHANGE-2046).
  local j; j=$(api GET /search/jql -G \
    --data-urlencode "jql=$jql" --data-urlencode "fields=$fields" --data-urlencode "maxResults=$max")
  jq -r '.issues[] | "\(.key)\t[\(.fields.status.name // "-")]\t\(.fields.assignee.displayName // "-")\t\(.fields.summary)"' <<<"$j"
  jq -r 'if .nextPageToken then "(more results exist; raise --max to see them)" else empty end' <<<"$j"
}

cmd_comments() {
  resolve "${1:-}"; shift || true
  local out="$TMP/$KEY-comments.txt" max=20
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --out) out="$2"; shift 2 ;;
      --max) max="$2"; shift 2 ;;
      *) die "unknown option for comments: $1" ;;
    esac
  done
  local j; j=$(api GET "/issue/$KEY/comment" -G \
    --data-urlencode "maxResults=$max" --data-urlencode "orderBy=-created")
  jq -r '"total: \(.total)"' <<<"$j"
  jq -r '.comments[] | "- \((.created // "-")[0:16]) \(.author.displayName) (\(.body | length) chars): \(.body | gsub("\\s+"; " ") | .[0:80])"' <<<"$j"
  jq -r '.comments[] | "===== \(.id) \((.created // "-")[0:19]) \(.author.displayName)\n\(.body)\n"' <<<"$j" >"$out"
  echo "bodies  : $out"
}

cmd_comment() {
  resolve "${1:-}"; shift || true
  local in=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --in) in="$2"; shift 2 ;;
      *) die "unknown option for comment: $1" ;;
    esac
  done
  [[ -n "$in" && -s "$in" ]] || die "--in <file> with the comment body is required (never inline a body)"
  local p="$TMP/$KEY-comment-payload.json"
  mkjson "$p" "body=@$in"
  post_json POST "/issue/$KEY/comment" "$p" "$(wc -c <"$in" | tr -d ' ')" \
    | jq -r --arg site "$(site)" --arg key "$KEY" '"posted comment \(.id) -> https://\($site)/browse/\($key)?focusedCommentId=\(.id)"'
}

cmd_edit() {
  resolve "${1:-}"; shift || true
  local -a kv=(); local min=2
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --in) [[ -s "$2" ]] || die "--in file is empty: $2"
            kv+=("fields.description=@$2"); min=$(wc -c <"$2" | tr -d ' '); shift 2 ;;
      --summary) kv+=("fields.summary=$2"); shift 2 ;;
      --labels) kv+=("fields.labels=json:$(printf '%s' "$2" | jq -R 'split(",")' -c)"); shift 2 ;;
      --due) kv+=("fields.duedate=$2"); shift 2 ;;
      --json) kv+=("fields=json:$(cat "$2")"); min=$(wc -c <"$2" | tr -d ' '); shift 2 ;;
      *) die "unknown option for edit: $1" ;;
    esac
  done
  [[ ${#kv[@]} -gt 0 ]] || die "nothing to edit"
  local p="$TMP/$KEY-edit-payload.json"
  mkjson "$p" "${kv[@]}"
  post_json PUT "/issue/$KEY" "$p" "$min" >/dev/null
  echo "edited $KEY -> https://$(site)/browse/$KEY"
}

cmd_create() {
  local project="" type="" summary="" in="" parent="" labels="" assignee=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --project) project="$2"; shift 2 ;;
      --type) type="$2"; shift 2 ;;
      --summary) summary="$2"; shift 2 ;;
      --in) in="$2"; shift 2 ;;
      --parent) parent="$2"; shift 2 ;;
      --labels) labels="$2"; shift 2 ;;
      --assignee) assignee="$2"; shift 2 ;;
      *) die "unknown option for create: $1" ;;
    esac
  done
  [[ -n "$project" && -n "$type" && -n "$summary" ]] || die "create needs --project, --type and --summary"
  local -a kv=("fields.project.key=$project" "fields.issuetype.name=$type" "fields.summary=$summary")
  local min=2
  [[ -n "$in" ]] && { [[ -s "$in" ]] || die "--in file is empty: $in"; kv+=("fields.description=@$in"); min=$(wc -c <"$in" | tr -d ' '); }
  [[ -n "$parent" ]] && kv+=("fields.parent.key=$parent")
  [[ -n "$labels" ]] && kv+=("fields.labels=json:$(printf '%s' "$labels" | jq -R 'split(",")' -c)")
  [[ -n "$assignee" ]] && kv+=("fields.assignee.accountId=$(account_id "$assignee")")
  local p="$TMP/create-payload.json"
  mkjson "$p" "${kv[@]}"
  post_json POST /issue "$p" "$min" \
    | jq -r --arg site "$(site)" '"created \(.key) -> https://\($site)/browse/\(.key)"'
}

cmd_assign() {
  resolve "${1:-}"; local who="${2:-}"
  [[ -n "$who" ]] || die "assign needs a target (me | <email|name> | none)"
  local id; id=$(account_id "$who")
  [[ -n "$id" ]] || die "no Atlassian user matched: $who"
  local p="$TMP/$KEY-assign.json"
  if [[ "$id" == "-1" ]]; then mkjson "$p" "accountId=json:null"; else mkjson "$p" "accountId=$id"; fi
  post_json PUT "/issue/$KEY/assignee" "$p" >/dev/null
  echo "assigned $KEY -> $who"
}

cmd_transitions() {
  resolve "${1:-}"
  api GET "/issue/$KEY/transitions" | jq -r '.transitions[] | "\(.id)\t\(.name) -> \(.to.name)"'
}

cmd_transition() {
  resolve "${1:-}"; local to="${2:-}"
  [[ -n "$to" ]] || die "transition needs a transition id or name"
  local id
  id=$(api GET "/issue/$KEY/transitions" | jq -r --arg t "$to" '
    (.transitions[] | select(.id == $t or (.name | ascii_downcase) == ($t | ascii_downcase) or (.to.name | ascii_downcase) == ($t | ascii_downcase)) | .id) // empty' | head -1)
  if [[ -z "$id" ]]; then
    echo "no transition matched \"$to\". available:" >&2
    api GET "/issue/$KEY/transitions" | jq -r '.transitions[] | "  \(.id)\t\(.name) -> \(.to.name)"' >&2
    exit 2
  fi
  local p="$TMP/$KEY-transition.json"
  mkjson "$p" "transition.id=$id"
  post_json POST "/issue/$KEY/transitions" "$p" >/dev/null
  echo "transitioned $KEY via $id -> $(api GET "/issue/$KEY" -G --data-urlencode 'fields=status' | jq -r '.fields.status.name')"
}

cmd_link() {
  local a="${1:-}" type="${2:-}" b="${3:-}"
  [[ -n "$a" && -n "$type" && -n "$b" ]] || die "link needs <KEY> <type> <KEY>  (see: linktypes)"
  resolve "$a"; local ka="$KEY"; resolve "$b"; local kb="$KEY"
  local p="$TMP/link.json"
  mkjson "$p" "type.name=$type" "inwardIssue.key=$ka" "outwardIssue.key=$kb"
  post_json POST /issueLink "$p" >/dev/null
  echo "linked $ka -[$type]-> $kb"
}

cmd_linktypes() { api GET /issueLinkType | jq -r '.issueLinkTypes[] | "\(.name)\t(inward: \(.inward) / outward: \(.outward))"'; }

cmd_types() {
  local project="${1:-}"; [[ -n "$project" ]] || die "types needs a project key"
  api GET /issue/createmeta -G --data-urlencode "projectKeys=$project" \
    | jq -r '.projects[0].issuetypes[] | "\(.name)\tsubtask=\(.subtask)"'
}

cmd_raw() { # escape hatch: raw <METHOD> <path> [curl args...]
  local m="${1:-GET}" p="${2:-}"; shift 2 || true
  [[ -n "$p" ]] || die "raw needs a path, e.g. /issue/ABC-1/worklog"
  api "$m" "$p" "$@"
}

usage() {
  cat <<'USAGE'
jira.sh <command> [args]

  me
  get         <KEY|URL> [--fields a,b] [--out FILE]
  search      '<JQL>' [--max N] [--fields a,b]
  comments    <KEY|URL> [--max N] [--out FILE]
  comment     <KEY|URL> --in <body-file>
  edit        <KEY|URL> [--summary S] [--in <desc-file>] [--labels a,b] [--due YYYY-MM-DD] [--json <fields.json>]
  create      --project P --type T --summary S [--in <desc-file>] [--parent K] [--labels a,b] [--assignee X]
  assign      <KEY|URL> <me|email|name|none>
  transitions <KEY|URL>
  transition  <KEY|URL> <id|name>
  link        <KEY> <type> <KEY>
  linktypes
  types       <PROJECT>
  raw         <METHOD> <path> [curl args...]

Bodies (description, comment) are Jira wiki markup, passed in via a file only.
USAGE
}

case "${1:-}" in
  me|get|search|comments|comment|edit|create|assign|transitions|transition|link|linktypes|types|raw)
    c="$1"; shift; "cmd_$c" "$@" ;;
  ""|-h|--help|help) usage ;;
  *) usage >&2; exit 2 ;;
esac
