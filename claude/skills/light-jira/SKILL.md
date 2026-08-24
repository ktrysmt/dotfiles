---
name: light-jira
description: >-
  Jira I/O through a bundled REST v2 helper script, so issue bodies, comment
  threads and JQL result sets stay out of the conversation: every response is
  filtered down to a few lines and long content is written to files. Use for
  ANY Jira operation (read, JQL search, comment, create, edit, transition,
  assign, link) instead of calling mcp__confluence__*Jira* tools, which return
  multi-KB payloads. Runs in the caller's own context on purpose — no fork —
  so the conversation so far can inform what gets written; the lightness comes
  from the helper, not from isolation. Needs $ATLASSIAN_API_KEY. Confluence is
  out of scope (use light-confluence). Triggers: "Jiraのチケットを読んで",
  "JQLで検索して", "チケットにコメントして", "課題を作って",
  "ステータスを進めて", "アサインして", "read this Jira ticket",
  "file a Jira issue".
argument-hint: "<operation> <issue key|URL|JQL> [--in <body-file>] [--out <save-file>]"
allowed-tools:
  - Read
  - Write
  - Bash(~/.claude/skills/light-jira/jira.sh:*)
  - Bash(mkdir:*)
  - Bash(wc:*)
  - Bash(jq:*)
  - Bash(python3:*)
  - Bash(grep:*)
---

Perform the Jira operation described in $ARGUMENTS, then report it in a few
lines. You keep the full conversation context, so use it to get the content
right — but that is exactly why the transport must stay narrow: nothing here
may pull an issue blob into the conversation. If a required piece of
information is missing and the conversation does not supply it (issue key,
project key, issue type, body text), do NOT guess — ask for that one thing.

All Jira access goes through the bundled helper:

    ~/.claude/skills/light-jira/jira.sh <command> [args]

Run it with no arguments for the exact usage. Never hand-roll curl against
`/rest/api/*`, and never call an `mcp__*` Jira tool: the helper already
resolves the site and credentials, filters every response down to a few lines,
and refuses the failure modes listed under Guardrails. Its only escape hatch is
`jira.sh raw <METHOD> <path>` for an endpoint it does not wrap — pipe that
through `jq` yourself and never paste its raw JSON into the conversation.

## Hard output rules

- Keep the report under 20 lines.
- NEVER echo a full issue description, a whole comment thread, or raw JSON
  into the conversation. Long content stays in files; the report carries keys,
  URLs, file paths and short digests only. When the caller needs a passage from
  a body, `Read` the saved file with an offset/limit or `grep` it — do not
  print the file wholesale.
- Report errors as the helper printed them (first line), not as a dump.

## Preconditions (resolve yourself; never ask the caller)

- Credentials: `$ATLASSIAN_API_KEY` from the environment. The account email
  falls back to `git config --global user.email`, the site to
  `<first label of the email domain>.atlassian.net`. Override with
  `$ATLASSIAN_EMAIL` / `$JIRA_SITE`. Never ask the caller for any of this, and
  never print the token.
- An issue is addressable by key (`ABC-123`) or by any browse / board URL —
  the helper extracts the key and the site from the URL, so pass the URL
  through as given.
- Bodies are **Jira wiki markup**, not Markdown, because the API v2 path keeps
  descriptions and comments as plain strings. Convert before writing:
  `## H` → `h2. H`, `**b**` → `*b*`, `` `x` `` → `{{x}}`,
  ```` ```lang ```` → `{code:lang}` … `{code}`, `[t](url)` → `[t|url]`,
  `- item` → `* item`, `1. item` → `# item`. Tables are
  `||head||head||` / `|cell|cell|`. Leave anything else as plain text.

## Operations

1. Read an issue — `jira.sh get <KEY|URL> [--out FILE]`.
   The description is written to the file (default
   `$TMPDIR/light-jira/<KEY>.txt`), never inlined.
   Report: the header block the helper printed, the file path, and a digest of
   at most 10 bullet lines.

2. Search — `jira.sh search '<JQL>' [--max N]`.
   Report at most 15 lines of `KEY [status] assignee — summary`. No
   descriptions unless explicitly requested. If the helper says more results
   exist, say so instead of silently truncating.

3. Comments — read with `jira.sh comments <KEY|URL> [--max N] [--out FILE]`;
   post with `jira.sh comment <KEY|URL> --in <body-file>`.
   Write the body to a file with `Write` first (wiki markup, per above); the
   helper refuses an inline body.
   Report: comment id, the focusedCommentId URL, one line of summary.

4. Create — `jira.sh create --project P --type T --summary S [--in DESC]
   [--parent K] [--labels a,b] [--assignee <exact email|display name>]`.
   Project key, issue type and summary are mandatory: ask rather than invent
   them. `jira.sh types <PROJECT>` lists the valid issue type names.
   Report: new key, URL, and at most 3 lines of summary.

5. Edit — `jira.sh edit <KEY|URL> [--summary S] [--in DESC] [--labels a,b]
   [--due YYYY-MM-DD] [--json <fields.json>]`.
   `--in` REPLACES the whole description. Before it, always run
   `jira.sh get <KEY> --out <old.txt>` so the previous body is on disk, edit
   that file, and report the old and new byte counts so a revert is possible.
   Never build the new body from memory.

6. Transition / assign / link — `jira.sh transitions <KEY>` then
   `jira.sh transition <KEY> <id|name>`; `jira.sh assign <KEY> <me|exact
   email|display name|none>`; `jira.sh linktypes` then
   `jira.sh link <KEY> <type> <KEY>`.
   `link A Blocks B` reads in the natural direction — A blocks B, and B shows
   "is blocked by A". A transition is matched by its id, its own name, or the
   name of the status it leads to, case-insensitively.
   Report: one line per action, with the resulting status for a transition.

## Guardrails

- Confluence is out of scope: hand any Confluence work to light-confluence
  instead of touching it here.
- Writes only on an explicit instruction. A read request never triggers a
  comment, an edit, a transition or an assignment as a side effect. When
  $ARGUMENTS is ambiguous about whether to write, do the read part and ask.
- Never delete an issue, comment or link. If asked, refuse and report back.
- Never write a body you did not read from a file this run, and never write a
  file path or a placeholder as a body.
- Every write is verified by re-reading: after `comment`, `edit`,
  `transition` or `assign`, run the matching read command and confirm the
  change is present. Report the verification outcome in one line. If it fails,
  say so loudly, name the pre-edit file or status so the caller can revert, and
  do not retry the write.
- One issue at a time for writes. For a bulk change, list the affected keys
  and ask for confirmation before touching more than 5 issues.
