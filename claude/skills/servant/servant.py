#!/usr/bin/env -S python3 -I
"""Deterministic half of the servant skill: scan, state, local worktrees and the canvas.

The model calls this script instead of parsing Jira or GitHub payloads itself. The
script reads Jira through light-jira's jira.sh (which alone handles the Atlassian
credentials) and GitHub through gh, and it writes only under the state directory,
with one exception: `apply` makes the two Jira writes the user allowed ([review]
prefix, REVIEW-OK). It derives each from Jira and GitHub as they are at that moment,
never from the model's arguments or the state files, and writes fixed values only.
It never writes to GitHub or Slack, and it never commits or pushes.

  servant.py lock | unlock | context | drain
  servant.py scan
  servant.py apply KEY add_review_prefix|transition_review_ok
  servant.py ticket KEY
  servant.py feedback KEY
  servant.py view GITHUB_URL
  servant.py note KEY [--summary TEXT --next TEXT]
                      [--handled ID --how fix|draft|none [--path P] [--draft F] [--memo TEXT]]
                      [--slack-seen URL TS] [--proposal TEXT [--evidence URL]]
                      [--clear-proposals]
  servant.py meta [--cron-job ID]
  servant.py worktree PR_URL
  servant.py render [--open]
  servant.py halted   (the session's StopFailure hook; reads the hook input on stdin)

State lives in $SERVANT_STATE_DIR, default ~/.local/state/servant.

Every network call ends on time (see run()), and exit status 5 means the network did
not answer: the Mac slept or the Wi-Fi dropped. Nothing is saved then; the next pass
retries. `lock` and `drain` stop servant.py commands that earlier passes left running.
When a turn of the session ends on an API error, such as a usage limit, `halted`
records it for the canvas; the next pass that gets through clears it.
"""
import argparse
import datetime as dt
import hashlib
import html
import json
import os
import re
import signal
import subprocess
import sys
import time
from pathlib import Path
from urllib.parse import parse_qs, urlparse

HOME = Path.home()
STATE = Path(os.environ.get("SERVANT_STATE_DIR") or HOME / ".local/state/servant")
JIRA_SH = HOME / ".claude/skills/light-jira/jira.sh"
SNAPSHOT = STATE / "snapshot.json"
NOTES = STATE / "notes.json"
LOCK = STATE / "lock.json"
HALT = STATE / "halt.json"
ACTIONS = STATE / "actions.jsonl"
CANVAS = STATE / "canvas.html"
DESC = STATE / "desc"
REPOS = STATE / "repos"
WORKTREES = STATE / "worktrees"

MINE_OPEN = "assignee = currentUser() AND statusCategory != Done"
JQL = MINE_OPEN + " ORDER BY updated DESC"
DONE = "REVIEW-OK"
REVIEW_TAG = "[review]"
ACTION_TYPES = ("add_review_prefix", "transition_review_ok")
ACTION_JA = {"add_review_prefix": "[review] の付与", "transition_review_ok": "REVIEW-OK への更新"}
KEY_RE = re.compile(r"^[A-Z][A-Z0-9_]*-\d+$")
MAX_AUTO = 5
MAX_FEEDBACK_TICKETS = 3
MAX_SUMMARIES = 10
# The session's job: every 20 minutes, off the hour. An evenly spaced job runs late by a
# fixed amount of up to half its gap, here 10 minutes (docs: scheduled-tasks, jitter).
CRON = "7,27,47 * * * *"
CRON_JA = "20 分ごと（毎時 7・27・47 分から最大 10 分遅れ）"
# Shorter than the 20-minute gap, so a lock left by a dead turn delays no pass.
LOCK_TTL = dt.timedelta(minutes=15)
FAIL_SUPPRESS = dt.timedelta(hours=24)
CRON_RENEW = dt.timedelta(days=6)

# Time limits, in seconds. gh, and curl inside jira.sh, wait forever on a connection that
# died while the Mac slept or the Wi-Fi dropped. The Bash tool does not kill a command
# that outlives its timeout (120 s by default): it moves it to the background, where such
# a scan used to wait for days. So each call, and each servant.py command, ends on time.
CALL_TIMEOUT = 45
DEFAULT_BUDGET = 90
WORKTREE_BUDGET = 240  # clone, fetch and checkout of a large repository
BUDGET = {"worktree": WORKTREE_BUDGET}
EXIT_NETWORK = 5
DRAIN_MIN_AGE = 10  # a younger servant.py belongs to the pass that is starting
VIEW_LIMIT = 4000
SERVANT_PROC_RE = re.compile(r"^\S*[Pp]ython[\d.]*(?:\s+-\S+)*\s+\S*/skills/servant/servant\.py(?:\s|$)")
_STARTED = (time.time(), time.monotonic())
_budget = DEFAULT_BUDGET

GH_RE = re.compile(r"^https?://github\.com/([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+)/(pull|issues)/(\d+)")
SLACK_RE = re.compile(r"^https?://([a-z0-9-]+)\.slack\.com/archives/([A-Z0-9]+)/p(\d{16})")
URL_RE = re.compile(r"https?://[^\s|\[\]<>\"'{}]+")
TRAIL = ".,;:)）」』、。!?"


# ---------------------------------------------------------------- basics

def now():
    return dt.datetime.now().astimezone()


def iso(t=None):
    return (t or now()).isoformat(timespec="seconds")


def parse_iso(s):
    try:
        return dt.datetime.fromisoformat(str(s).replace("Z", "+00:00"))
    except ValueError:
        return None


def die(msg, code=2):
    print(f"servant: {msg}", file=sys.stderr)
    sys.exit(code)


def load(path, default):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        return default
    except json.JSONDecodeError as e:
        die(f"{path} is not valid JSON: {e}")


def save(path, obj):
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(path.name + ".tmp")
    tmp.write_text(json.dumps(obj, ensure_ascii=False, indent=1), encoding="utf-8")
    os.replace(tmp, path)


def elapsed():
    """Seconds since this command started. Wall-clock time also counts the time the Mac
    slept, so a call that was in flight when the lid closed ends right after wake."""
    return max(time.time() - _STARTED[0], time.monotonic() - _STARTED[1])


def stop_group(p):
    """Stop a call and everything it started. TERM first, so that git clone removes its
    partial directory (git: builtin/clone.c, remove_junk_on_signal), then KILL the rest."""
    for sig in (signal.SIGTERM, signal.SIGKILL):
        try:
            os.killpg(p.pid, sig)
        except OSError:
            return  # the whole group is gone
        try:
            p.wait(timeout=3)
        except subprocess.TimeoutExpired:
            pass


def run(cmd, cwd=None, timeout=CALL_TIMEOUT):
    """Run cmd and return (exit code, stdout, stderr).

    The call runs in its own session, so stopping it also stops what it started (curl
    under jira.sh, git under gh). It ends after `timeout` seconds or when this command's
    budget is spent, whichever comes first; the command then exits EXIT_NETWORK without
    saving anything."""
    start = elapsed()
    p = subprocess.Popen(cmd, cwd=cwd, stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE, text=True, start_new_session=True)
    while True:
        left = min(start + timeout, _budget) - elapsed()
        if left <= 0:
            waited = round(elapsed() - start)
            stop_group(p)
            what = " ".join(Path(c).name for c in cmd[:3])
            die(f"`{what}` got no answer in {waited} s (the Mac slept or the "
                f"network dropped); stopped it with its child processes, nothing was saved",
                EXIT_NETWORK)
        try:
            # Retrying communicate() after TimeoutExpired loses no output (subprocess docs).
            out, err = p.communicate(timeout=min(left, 1))
            return p.returncode, out, err
        except subprocess.TimeoutExpired:
            pass


def first_line(s):
    s = (s or "").strip()
    return s.splitlines()[0][:300] if s else "(no output)"


def load_notes():
    notes = load(NOTES, {})
    notes.setdefault("tickets", {})
    notes.setdefault("meta", {})
    return notes


def tnote(notes, key):
    t = notes["tickets"].setdefault(key, {})
    for k, v in (("handled", {}), ("slack_seen", {}), ("proposals", []), ("action_failures", {})):
        t.setdefault(k, v)
    return t


# ---------------------------------------------------------------- Jira

def jira(*args):
    return run(["bash", str(JIRA_SH), *args])


def jira_issues(jql=JQL):
    issues, token = [], None
    while True:
        cmd = ["bash", str(JIRA_SH), "raw", "GET", "/search/jql", "-G",
               "--data-urlencode", f"jql={jql}",
               "--data-urlencode", "fields=summary,status,updated,description",
               "--data-urlencode", "maxResults=100"]
        if token:
            cmd += ["--data-urlencode", f"nextPageToken={token}"]
        _, out, err = run(cmd)
        try:
            data = json.loads(out)
        except json.JSONDecodeError:
            die(f"Jira search failed: {first_line(out or err)}")
        issues += data.get("issues", [])
        token = data.get("nextPageToken")
        if not token or len(issues) >= 500:
            return issues


def site_of(issues):
    for it in issues:
        host = urlparse(it.get("self", "")).netloc
        if host:
            return host
    return ""


# ---------------------------------------------------------------- links

def urls_in(text):
    out = []
    for u in URL_RE.findall(text or ""):
        u = u.rstrip(TRAIL)
        if u and u not in out:
            out.append(u)
    return out


def classify(url, origin):
    m = GH_RE.match(url)
    if m:
        o, r, typ, n = m.groups()
        return {"kind": "github", "owner": o, "repo": r, "number": int(n),
                "url": f"https://github.com/{o}/{r}/{typ}/{n}", "origin": origin}
    m = SLACK_RE.match(url)
    if m:
        raw = m.group(3)
        ts = f"{raw[:10]}.{raw[10:]}"
        thread = parse_qs(urlparse(url).query).get("thread_ts", [ts])[0]
        return {"kind": "slack", "url": url, "channel": m.group(2), "thread_ts": thread, "origin": origin}
    host = urlparse(url).netloc.lower()
    if host.endswith(".atlassian.net"):
        kind = "confluence" if "/wiki/" in url else "jira"
    elif host == "docs.google.com":
        kind = "gdoc"
    else:
        kind = "other"
    return {"kind": kind, "url": url, "origin": origin}


def ref_of(link):
    return (link["owner"].lower(), link["repo"].lower(), link["number"])


def links_of(summary, desc):
    seen, out = set(), []
    for origin, text in (("summary", summary), ("description", desc)):
        for u in urls_in(text):
            link = classify(u, origin)
            ident = ref_of(link) if link["kind"] == "github" else link["url"]
            if ident not in seen:
                seen.add(ident)
                out.append(link)
    return out


# ---------------------------------------------------------------- GitHub

PAGE = "pageInfo { hasNextPage endCursor }"
ACTOR = "author { __typename login }"
COMMENT = f"url {ACTOR} body createdAt"
# The PR connections servant reads, each with its first page size and node selection.
# Every page after the first is fetched by complete(), so nothing is cut off silently.
CONNECTIONS = {
    "reviewRequests": (100, "requestedReviewer { __typename ... on User { login } ... on Team { slug } }"),
    "reviews": (100, f"url {ACTOR} body state submittedAt"),
    "comments": (100, COMMENT),
    "reviewThreads": (50, f"id isResolved isOutdated path line comments(first: 50) {{ {PAGE} nodes {{ {COMMENT} }} }}"),
}
# The connections each kind of PR is read for: the user's own PRs for open feedback
# (open_feedback), other people's for the review request and review state (enrich).
NEEDED = {True: ("reviews", "comments", "reviewThreads"), False: ("reviewRequests", "reviews")}

GH_NODE = ("__typename\n... on PullRequest { id url title state merged mergedAt closedAt updatedAt isDraft headRefName "
           + ACTOR + " commits(last: 1) { nodes { commit { committedDate } } }\n"
           + "\n".join(f"  {f}(first: {n}) {{ {PAGE} nodes {{ {sel} }} }}" for f, (n, sel) in CONNECTIONS.items())
           + " }\n... on Issue { url title state stateReason closedAt updatedAt " + ACTOR + " }")


def gh_graphql(query, **variables):
    """Run one GraphQL query. Returns (data, error line); data is None when gh printed no JSON."""
    cmd = ["gh", "api", "graphql", "-f", f"query={query}"]
    for k, v in variables.items():
        cmd += ["-f", f"{k}={v}"]
    # gh exits non-zero when one alias fails (e.g. a repo the user cannot read)
    # but still prints the partial data, so parse stdout regardless of the code.
    _, out, err = run(cmd)
    try:
        doc = json.loads(out)
    except json.JSONDecodeError:
        return None, first_line(err or out)
    return doc.get("data") or {}, first_line(err) if doc.get("errors") else ""


def more_pages(node_id, typename, field, selection, conn):
    """Append every page after the first to conn, the field connection of node node_id.

    Returns False when a page could not be fetched; conn then holds what was read."""
    query = (f"query($id: ID!, $after: String!) {{ node(id: $id) {{ ... on {typename} {{ "
             f"{field}(first: 100, after: $after) {{ {PAGE} nodes {{ {selection} }} }} }} }} }}")
    while (conn.get("pageInfo") or {}).get("hasNextPage"):
        data, _ = gh_graphql(query, id=node_id, after=conn["pageInfo"]["endCursor"])
        page = ((data or {}).get("node") or {}).get(field)
        if not page:
            return False
        conn["nodes"] = (conn.get("nodes") or []) + (page.get("nodes") or [])
        conn["pageInfo"] = page.get("pageInfo") or {}
    return True


def complete(pr, me):
    """Fetch the remaining pages of the connections this PR is read for. False when one failed."""
    mine = who(pr.get("author")) == me
    ok = True
    for field in NEEDED[mine]:
        ok = more_pages(pr["id"], "PullRequest", field, CONNECTIONS[field][1], pr.get(field) or {}) and ok
    if mine:
        for t in nodes_of(pr, "reviewThreads"):
            ok = more_pages(t["id"], "PullRequestReviewThread", "comments", COMMENT, t.get("comments") or {}) and ok
    return ok


def gh_fetch(refs):
    me, nodes = None, {}
    chunks = [refs[i:i + 15] for i in range(0, len(refs), 15)] or [[]]
    for chunk in chunks:
        parts = ["viewer { login }"]
        for j, (o, r, n) in enumerate(chunk):
            parts.append(f'l{j}: repository(owner: "{o}", name: "{r}") '
                         f'{{ issueOrPullRequest(number: {n}) {{ {GH_NODE} }} }}')
        data, err = gh_graphql("query { " + "\n".join(parts) + " }")
        if data is None:
            die(f"GitHub query failed: {err}")
        me = (data.get("viewer") or {}).get("login") or me
        for j, ref in enumerate(chunk):
            nodes[ref] = (data.get(f"l{j}") or {}).get("issueOrPullRequest")
    if not me:
        die("could not resolve the GitHub login: check `gh auth status`")
    for node in nodes.values():
        if node and node.get("__typename") == "PullRequest" and not complete(node, me):
            node["incomplete"] = True  # enrich() and build_ticket() treat it as unread
    return me, nodes


def who(actor):
    return (actor or {}).get("login") or "ghost"


def human(actor):
    return bool(actor) and actor.get("__typename") != "Bot"


def nodes_of(obj, field):
    return ((obj or {}).get(field) or {}).get("nodes") or []


def my_last_activity(pr, me):
    times = [c["createdAt"] for c in nodes_of(pr, "comments") if who(c["author"]) == me]
    times += [r["submittedAt"] for r in nodes_of(pr, "reviews") if who(r["author"]) == me and r.get("submittedAt")]
    for t in nodes_of(pr, "reviewThreads"):
        times += [c["createdAt"] for c in nodes_of(t, "comments") if who(c["author"]) == me]
    return max(times) if times else ""


def open_feedback(pr, me):
    """Review feedback from people (not bots) that the user has not answered yet."""
    items = []
    for t in nodes_of(pr, "reviewThreads"):
        cs = nodes_of(t, "comments")
        if t.get("isResolved") or not cs or who(cs[-1]["author"]) == me:
            continue
        others = [c for c in cs if who(c["author"]) != me and human(c["author"])]
        if not others:
            continue
        c = others[-1]
        items.append({"id": cs[0]["url"], "kind": "thread", "url": c["url"], "author": who(c["author"]),
                      "at": c["createdAt"], "path": t.get("path"), "line": t.get("line"),
                      "outdated": bool(t.get("isOutdated")), "body": c.get("body") or ""})
    since = my_last_activity(pr, me)
    for c in nodes_of(pr, "comments"):
        if (human(c["author"]) and who(c["author"]) != me and (c.get("body") or "").strip()
                and c["createdAt"] > since):
            items.append({"id": c["url"], "kind": "comment", "url": c["url"], "author": who(c["author"]),
                          "at": c["createdAt"], "body": c["body"]})
    for r in nodes_of(pr, "reviews"):
        if (human(r["author"]) and who(r["author"]) != me and (r.get("body") or "").strip()
                and r.get("state") in ("CHANGES_REQUESTED", "COMMENTED") and (r.get("submittedAt") or "") > since):
            items.append({"id": r["url"], "kind": "review", "url": r["url"], "author": who(r["author"]),
                          "at": r["submittedAt"], "body": r["body"], "state": r["state"]})
    return items


REVIEW_STATE_JA = {"APPROVED": "承認済み", "CHANGES_REQUESTED": "修正依頼中",
                   "COMMENTED": "コメント済み", "DISMISSED": "取り消し"}


def my_review_status(pr, me):
    if pr.get("merged"):
        return "merge 済み"
    if pr.get("state") == "CLOSED":
        return "close 済み"
    mine = [r for r in nodes_of(pr, "reviews") if who(r["author"]) == me and r.get("submittedAt")]
    if not mine:
        return "未レビュー"
    last = max(mine, key=lambda r: r["submittedAt"])
    commits = nodes_of(pr, "commits")
    committed = commits[0]["commit"]["committedDate"] if commits else ""
    if committed and committed > last["submittedAt"]:
        return "更新あり"
    return REVIEW_STATE_JA.get(last["state"], last["state"])


def enrich(link, node, me):
    if node is None:
        link.update(type=None, state="inaccessible", title="")
        return
    link["type"] = node["__typename"]
    link["title"] = node.get("title") or ""
    link["state"] = node.get("state")
    link["author"] = who(node.get("author"))
    link["mine"] = link["author"] == me
    link["co"] = link["repo"].lower().endswith("command-order")
    if link["type"] == "PullRequest":
        link["incomplete"] = bool(node.get("incomplete"))
        link["merged"] = bool(node.get("merged"))
        link["requested_me"] = any(who(n.get("requestedReviewer")) == me for n in nodes_of(node, "reviewRequests"))
        link["reviewed_me"] = any(who(r["author"]) == me for r in nodes_of(node, "reviews"))
        link["head"] = node.get("headRefName")
        link["review_status"] = "" if link["mine"] else my_review_status(node, me)
        link["feedback"] = open_feedback(node, me) if link["mine"] else []
    else:
        link["state_reason"] = node.get("stateReason")


def finished(link):
    if link.get("type") == "PullRequest":
        return bool(link.get("merged"))
    if link.get("type") == "Issue":
        return link.get("state") == "CLOSED" and link.get("state_reason") in (None, "COMPLETED")
    return False


def abandoned(link):
    if link.get("type") == "PullRequest":
        return link.get("state") == "CLOSED" and not link.get("merged")
    if link.get("type") == "Issue":
        return link.get("state") == "CLOSED" and link.get("state_reason") not in (None, "COMPLETED")
    return False


def unread(link):
    """A GitHub link whose state this scan could not read in full."""
    return link["kind"] == "github" and (not link.get("type") or link.get("incomplete"))


def state_label(link):
    if link.get("state") == "inaccessible":
        return "取得不可"
    if link.get("type") == "PullRequest":
        label = "merged" if link.get("merged") else ("closed" if link.get("state") == "CLOSED" else "open")
        return label + (" (一部取得不可)" if link.get("incomplete") else "")
    if link.get("type") == "Issue":
        if link.get("state") == "CLOSED":
            reason = link.get("state_reason")
            return "closed" if reason in (None, "COMPLETED") else f"closed ({reason})"
        return "open"
    return ""


def short(link):
    return f"{link['repo']}#{link['number']} {state_label(link)}"


# ---------------------------------------------------------------- scan

def build_ticket(issue, me, gh_nodes, notes, site):
    f = issue.get("fields") or {}
    key = issue["key"]
    summary = f.get("summary") or ""
    desc = f.get("description") or ""
    status = (f.get("status") or {}).get("name") or "-"
    links = links_of(summary, desc)
    for link in links:
        if link["kind"] == "github":
            enrich(link, gh_nodes.get(ref_of(link)), me)
    gh = [l for l in links if l["kind"] == "github" and l.get("type")]
    prs = [l for l in gh if l["type"] == "PullRequest"]
    others_prs = [l for l in prs if not l["mine"]]  # includes command-order PRs the user reviews
    review_prs = [l for l in others_prs if l["requested_me"] or l["reviewed_me"]]
    impl_links = [l for l in gh if l["co"] or l["mine"]]
    tagged = summary.strip().lower().startswith(REVIEW_TAG)
    if tagged:
        role, targets = "review", review_prs or others_prs
    elif review_prs:
        role, targets = "review", review_prs
    elif impl_links:
        role, targets = "impl", impl_links
    else:
        role, targets = "other", []

    note = tnote(notes, key)
    t_now = now()

    def suppressed(kind):
        at = parse_iso(note["action_failures"].get(kind, ""))
        return at is not None and t_now - at < FAIL_SUPPRESS

    actions, proposals = [], []
    if role == "review" and not tagged:
        # Prefix on its own only when the reviewed PR is the ticket's headline link.
        if any(l["origin"] == "summary" for l in review_prs) or len(prs) == 1:
            if not suppressed("add_review_prefix"):
                actions.append({"type": "add_review_prefix", "before": summary,
                                "after": f"{REVIEW_TAG} {summary}",
                                "reason": f"レビュー依頼: {review_prs[0]['url']}"})
        else:
            proposals.append({"text": "説明文の PR でレビューを依頼されています。[review] を付けるか確認してください",
                              "evidence": review_prs[0]["url"]})
    if role == "other" and others_prs:
        proposals.append({"text": "他の人の PR を参照しています。レビュー作業なら [review] を付けてください",
                          "evidence": others_prs[0]["url"]})
    if status != DONE and targets:
        decisive = [l for l in targets if l["co"]] if role == "impl" and any(l["co"] for l in targets) else targets
        if all(finished(l) for l in decisive):
            if not suppressed("transition_review_ok"):
                actions.append({"type": "transition_review_ok", "before": status, "after": DONE,
                                "reason": "完了: " + ", ".join(short(l) for l in decisive)})
        elif any(abandoned(l) for l in decisive):
            proposals.append({"text": "merge されずに close された PR か issue があります。チケットの扱いを確認してください",
                              "evidence": next(l["url"] for l in decisive if abandoned(l))})
    held = [l for l in links if unread(l)]
    if held and actions:
        # A link this scan could not read may change the role or the verdict, so no Jira
        # write may rest on the links that were read: the user decides instead.
        proposals.append({"text": "読めない GitHub リンクがあるため、Jira の自動更新（"
                                  + "、".join(ACTION_JA[x["type"]] for x in actions)
                                  + "）を保留しました。リンク先を確認し、必要なら Jira を自分で更新してください",
                          "evidence": held[0]["url"]})
        actions = []

    feedback, handled_open = [], []
    for l in prs:
        for item in l.pop("feedback", []):
            item["pr"] = l["url"]
            (handled_open if item["id"] in note["handled"] else feedback).append(item)
    for l in links:
        l.pop("feedback", None)

    slack = []
    if status != DONE:
        slack = [{"url": l["url"], "channel": l["channel"], "thread_ts": l["thread_ts"],
                  "oldest": note["slack_seen"].get(l["url"], "-")} for l in links if l["kind"] == "slack"]

    sig_src = [summary, desc, [(l["url"], l.get("state"), l.get("merged"), l.get("title")) for l in gh]]
    sig = hashlib.sha1(json.dumps(sig_src, ensure_ascii=False).encode()).hexdigest()[:12]

    desc_file = ""
    if desc.strip():
        DESC.mkdir(parents=True, exist_ok=True)
        path = DESC / f"{key}.txt"
        path.write_text(desc, encoding="utf-8")
        desc_file = str(path)

    return {"key": key, "url": f"https://{site}/browse/{key}" if site else key, "status": status,
            "summary": summary, "desc_file": desc_file, "role": role, "links": links,
            "actions": actions, "proposals": proposals, "feedback": feedback,
            "handled_open": [{"id": i["id"], "url": i["url"], "pr": i["pr"], "author": i["author"]}
                             for i in handled_open],
            "slack": slack, "sig": sig, "needs_summary": note.get("summary_sig") != sig}


def cmd_scan(_):
    STATE.mkdir(parents=True, exist_ok=True)
    issues = jira_issues()
    refs = []
    for it in issues:
        f = it.get("fields") or {}
        for link in links_of(f.get("summary") or "", f.get("description") or ""):
            if link["kind"] == "github" and ref_of(link) not in refs:
                refs.append(ref_of(link))
    me, gh_nodes = gh_fetch(refs)
    notes = load_notes()
    site = site_of(issues)
    tickets = [build_ticket(it, me, gh_nodes, notes, site) for it in issues]
    snap = {"generated_at": iso(), "me": me, "site": site, "tickets": tickets}
    save(SNAPSHOT, snap)
    save(NOTES, notes)
    print_todo(snap)


def print_todo(snap):
    ts = snap["tickets"]
    roles = {r: sum(1 for t in ts if t["role"] == r) for r in ("review", "impl", "other")}
    print(f"scan {snap['generated_at']}  me={snap['me']}  tickets={len(ts)}  "
          f"review={roles['review']} impl={roles['impl']} other={roles['other']}")
    acts = [(t, a) for t in ts for a in t["actions"]]
    print(f"[1] auto actions: {len(acts)} (run each with: servant.py apply KEY TYPE; "
          f"at most {MAX_AUTO} this pass, in this order)")
    for t, a in acts:
        print(f"  {t['key']}  {a['type']}  ({a['reason']})")
    fb = [t for t in ts if t["feedback"]]
    print(f"[2] open review feedback on your PRs: {sum(len(t['feedback']) for t in fb)} items in "
          f"{len(fb)} tickets (handle at most {MAX_FEEDBACK_TICKETS} tickets; read with: servant.py feedback KEY)")
    for t in fb:
        prs = " ".join(sorted({i["pr"] for i in t["feedback"]}))
        print(f"  {t['key']}  {len(t['feedback'])} items  {prs}")
    sl = [(t, s) for t in ts for s in t["slack"]]
    print(f"[3] slack threads to read: {len(sl)}")
    for t, s in sl:
        print(f"  {t['key']}  channel_id={s['channel']}  message_ts={s['thread_ts']}  oldest={s['oldest']}  {s['url']}")
    ns = [t["key"] for t in ts if t["needs_summary"]]
    print(f"[4] tickets needing a work summary: {len(ns)} "
          f"(do at most {MAX_SUMMARIES}, in this order; details: servant.py ticket KEY)")
    if ns:
        print("  " + " ".join(ns))


# ---------------------------------------------------------------- per-ticket reads

def find_ticket(key):
    snap = load(SNAPSHOT, None)
    if not snap:
        die("no snapshot yet: run `servant.py scan` first")
    for t in snap["tickets"]:
        if t["key"] == key.upper():
            return snap, t
    die(f"{key} is not in the latest scan")


def describe(link):
    if link["kind"] == "github":
        extra = f"  my review: {link['review_status']}" if link.get("review_status") else ""
        role = "CO" if link.get("co") else ("mine" if link.get("mine") else f"author={link.get('author', '-')}")
        return (f"{link['url']}  {link.get('type') or '?'}  {state_label(link)}  {role}{extra}  "
                f"{link.get('title') or ''}")
    if link["kind"] == "slack":
        return f"{link['url']}  slack thread_ts={link['thread_ts']}"
    return f"{link['url']}  {link['kind']}"


def cmd_ticket(a):
    _, t = find_ticket(a.key)
    n = load_notes()["tickets"].get(t["key"], {})
    print(f"{t['key']}  [{t['status']}]  role={t['role']}  {t['url']}")
    print(f"summary : {t['summary']}")
    print(f"desc    : {t['desc_file'] or '(empty)'}")
    for link in t["links"]:
        print(f"link    : {describe(link)}")
    for act in t["actions"]:
        print(f"action  : {act['type']}  {act.get('reason', '')}")
    for p in t["proposals"] + n.get("proposals", []):
        print(f"proposal: {p['text']}  {p.get('evidence') or ''}")
    if n.get("summary"):
        print(f"noted   : {n['summary']} / next: {n.get('next', '-')}")


def cmd_view(a):
    """Title and body of a GitHub pull request or issue, read for a work summary."""
    m = GH_RE.match(a.url)
    if not m:
        die("view needs a GitHub pull request or issue URL")
    owner, repo, typ, number = m.groups()
    kind = "pr" if typ == "pull" else "issue"
    rc, out, err = run(["gh", kind, "view", f"https://github.com/{owner}/{repo}/{typ}/{number}",
                        "--json", "title,body"])
    if rc:
        die(f"gh {kind} view failed: {first_line(err or out)}")
    doc = json.loads(out)
    body = doc.get("body") or ""
    print(f"title: {doc.get('title') or ''}\n{body[:VIEW_LIMIT]}")
    if len(body) > VIEW_LIMIT:
        print(f"(body cut at {VIEW_LIMIT} of {len(body)} characters)")


def cmd_feedback(a):
    _, t = find_ticket(a.key)
    if not t["feedback"]:
        print("no open feedback")
        return
    for i in t["feedback"]:
        loc = ""
        if i["kind"] == "thread":
            loc = f"  {i['path']}:{i.get('line') or '-'}{' (outdated)' if i.get('outdated') else ''}"
        print(f"===== id={i['id']}\n{i['kind']} by {i['author']} at {i['at']}  pr={i['pr']}{loc}\n"
              f"url: {i['url']}\n{i['body']}\n")


# ---------------------------------------------------------------- state writes

def cmd_note(a):
    notes = load_notes()
    key = a.key.upper()
    n = tnote(notes, key)
    stamp = iso()
    did = []
    if a.summary is not None:
        _, t = find_ticket(key)
        n.update(summary=a.summary, next=a.next or "-", summary_sig=t["sig"], summary_at=stamp)
        did.append("summary")
    if a.handled:
        if not a.how:
            die("--handled needs --how")
        n["handled"][a.handled] = {"how": a.how, "path": a.path, "draft": a.draft, "memo": a.memo, "at": stamp}
        did.append("handled")
    if a.slack_seen:
        url, ts = a.slack_seen
        n["slack_seen"][url] = ts
        did.append("slack_seen")
    if a.clear_proposals:
        n["proposals"] = []
        did.append("clear_proposals")
    if a.proposal:
        if not any(p["text"] == a.proposal and p.get("evidence") == a.evidence for p in n["proposals"]):
            n["proposals"].append({"text": a.proposal, "evidence": a.evidence, "at": stamp})
        did.append("proposal")
    if not did:
        die("nothing to record")
    save(NOTES, notes)
    print(f"noted {key}: {', '.join(did)}")


# ---------------------------------------------------------------- the two Jira writes

def jira_now(key):
    """The issue's summary and status as Jira has them now, or None."""
    _, out, _ = jira("raw", "GET", f"/issue/{key}", "-G", "--data-urlencode", "fields=summary,status")
    try:
        f = json.loads(out).get("fields") or {}
    except json.JSONDecodeError:
        return None
    return {"summary": f.get("summary") or "", "status": (f.get("status") or {}).get("name") or ""}


def write_review_prefix(key, act):
    # act["after"] always starts with "[review] ", so jira.sh never reads it as @file or json:.
    rc, out, err = jira("edit", key, "--summary", act["after"])
    if rc:
        return first_line(out or err)
    cur = jira_now(key)
    if not cur or cur["summary"] != act["after"]:
        return f"the summary reads {cur['summary']!r} after the edit" if cur else "could not re-read the issue"
    return None


def write_review_ok(key, act):
    _, out, err = jira("raw", "GET", f"/issue/{key}/transitions")
    try:
        ids = [t["id"] for t in json.loads(out).get("transitions") or []
               if ((t.get("to") or {}).get("name") or "") == DONE]
    except json.JSONDecodeError:
        return first_line(out or err)
    if not ids:
        return f"no transition leads from {act['before']} to {DONE}"
    rc, out, err = jira("transition", key, ids[0])
    if rc:
        return first_line(out or err)
    cur = jira_now(key)
    if not cur or cur["status"] != DONE:
        return f"the status reads {cur['status']!r} after the transition" if cur else "could not re-read the issue"
    return None


def cmd_apply(a):
    """Make one of the two Jira writes the user allowed, if Jira and GitHub call for it now.

    Exit 0: written and verified. 3: not called for now (nothing written). 4: this pass
    already made MAX_AUTO writes. 1: the write failed (retried after FAIL_SUPPRESS)."""
    key = a.key.upper()
    if not KEY_RE.match(key):
        die(f"not an issue key: {a.key}")
    notes = load_notes()
    if len((notes["meta"].get("run") or {}).get("actions", [])) >= MAX_AUTO:
        die(f"this pass already made {MAX_AUTO} Jira updates; the rest wait for the next pass", 4)
    # Re-derive the action from a fresh read: nothing in the state directory, and nothing
    # the model passes beyond the key and the type, decides whether or what to write.
    issues = jira_issues(f"key = {key} AND {MINE_OPEN}")
    if len(issues) != 1:
        die(f"{key} is not an open issue assigned to you", 3)
    f = issues[0].get("fields") or {}
    refs = [ref_of(l) for l in links_of(f.get("summary") or "", f.get("description") or "") if l["kind"] == "github"]
    me, gh_nodes = gh_fetch(list(dict.fromkeys(refs)))
    t = build_ticket(issues[0], me, gh_nodes, notes, site_of(issues))
    act = next((x for x in t["actions"] if x["type"] == a.type), None)
    if act is None:
        held = "; ".join(p["text"] for p in t["proposals"])
        die(f"{key} does not call for {a.type} now" + (f": {held}" if held else ""), 3)
    error = (write_review_prefix if a.type == "add_review_prefix" else write_review_ok)(key, act)
    if error:
        tnote(notes, key)["action_failures"][a.type] = iso()
        save(NOTES, notes)
        die(f"{a.type} on {key} failed: {error}", 1)
    rec = {"at": iso(), "key": key, "type": a.type, "before": act["before"], "after": act["after"]}
    STATE.mkdir(parents=True, exist_ok=True)
    with ACTIONS.open("a", encoding="utf-8") as fh:
        fh.write(json.dumps(rec, ensure_ascii=False) + "\n")
    notes["meta"].setdefault("run", {}).setdefault("actions", []).append(rec)
    tnote(notes, key)["action_failures"].pop(a.type, None)
    save(NOTES, notes)
    print(f"applied {key} {a.type}: {act['before']} -> {act['after']}")


def cmd_meta(a):
    notes = load_notes()
    meta = notes["meta"]
    if a.cron_job:
        meta["cron"] = {"job_id": a.cron_job, "created_at": iso(), "schedule": CRON}
        save(NOTES, notes)
        print(f"cron job {a.cron_job} recorded")
        return
    cron = meta.get("cron") or {}
    created = parse_iso(cron.get("created_at", ""))
    # A job made for another schedule is renewed too, so a change of CRON reaches a running session.
    renew = created is None or now() - created > CRON_RENEW or cron.get("schedule") != CRON
    print(f"cron job: {cron.get('job_id', '-')}  created_at: {cron.get('created_at', '-')}  "
          f"renew: {'yes' if renew else 'no'}  schedule: {CRON}")
    last = meta.get("run") or {}
    print(f"last pass: started {last.get('started', '-')}  finished {last.get('finished', '-')}")


def etime_seconds(s):
    """Seconds in a ps etime value, [[dd-]hh:]mm:ss."""
    days, _, rest = s.rpartition("-")
    parts = [int(x) for x in rest.split(":")]
    h, m, sec = [0] * (3 - len(parts)) + parts
    return int(days or 0) * 86400 + h * 3600 + m * 60 + sec


def drain():
    """Stop every servant.py command an earlier pass left running, with all its descendants.

    Before run() had time limits, the Bash tool moved scans stuck on a dead connection to
    the background, where they stayed for days. Returns (commands, processes) stopped."""
    _, out, _ = run(["ps", "-axo", "pid=,ppid=,etime=,command="])
    parent, age, command, children = {}, {}, {}, {}
    for line in out.splitlines():
        f = line.split(None, 3)
        if len(f) < 4 or not f[0].isdigit():
            continue
        pid = int(f[0])
        parent[pid], age[pid], command[pid] = int(f[1]), etime_seconds(f[2]), f[3]
        children.setdefault(int(f[1]), []).append(pid)
    spared, pid = set(), os.getpid()
    while pid > 1 and pid not in spared:  # this command and the shell and session above it
        spared.add(pid)
        pid = parent.get(pid, 0)
    roots = [p for p in command if p not in spared and age[p] >= DRAIN_MIN_AGE
             and SERVANT_PROC_RE.match(command[p])]
    victims, todo = set(), list(roots)
    while todo:
        p = todo.pop()
        if p not in victims and p not in spared:
            victims.add(p)
            todo += children.get(p, [])
    # Every pid is collected before the first signal: a parent killed first would orphan
    # its children to launchd, out of reach of this tree walk.
    for sig in (signal.SIGTERM, signal.SIGKILL):
        alive = []
        for p in victims:
            try:
                os.kill(p, sig)
                alive.append(p)
            except OSError:
                pass
        deadline = time.monotonic() + 3
        while alive and time.monotonic() < deadline:
            time.sleep(0.1)
            alive = [p for p in alive if pid_alive(p)]
        if not alive:
            break
    return len(roots), len(victims)


def pid_alive(pid):
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        return False
    except OSError:
        pass
    return True


def cmd_drain(_):
    commands, procs = drain()
    print(f"drained {commands} leftover servant.py commands ({procs} processes)")


def cmd_lock(_):
    STATE.mkdir(parents=True, exist_ok=True)
    cur = load(LOCK, {})
    since = parse_iso(cur.get("since", ""))
    if cur.get("state") == "running" and since and now() - since < LOCK_TTL:
        print(f"locked: a pass has been running since {cur['since']}")
        sys.exit(3)
    # This pass owns the state directory now, so any other servant.py is a leftover.
    commands, procs = drain()
    if commands:
        print(f"drained {commands} leftover servant.py commands ({procs} processes)")
    save(LOCK, {"state": "running", "since": iso()})
    notes = load_notes()
    notes["meta"]["run"] = {"started": iso(), "actions": []}
    save(NOTES, notes)
    halt = load(HALT, {})
    if halt.get("active"):  # the API answers again, so the stop is over
        save(HALT, {**halt, "active": False, "resumed_at": iso()})
        print(f"resumed: passes had stopped on {halt.get('error')} since {halt.get('since')}")
    print("locked")


def cmd_unlock(_):
    save(LOCK, {"state": "idle", "since": iso()})
    notes = load_notes()
    notes["meta"].setdefault("run", {})["finished"] = iso()
    save(NOTES, notes)
    print("unlocked")


def cmd_context(_):
    # Claude Code sets CLAUDE_JOB_DIR in every background session.
    print("background" if os.environ.get("CLAUDE_JOB_DIR") else "interactive")


def limit_reset(transcript_path, error):
    """When the usage limit behind this error lifts, as an ISO time, or "" when unknown.

    The StopFailure input has no reset time, but Claude Code writes the API error into the
    session transcript with quotaLimits.resetsAt. The transcript is not a documented
    format, so a missing or changed field only drops the time from the canvas."""
    try:
        with open(transcript_path, "rb") as fh:
            fh.seek(0, os.SEEK_END)
            fh.seek(max(0, fh.tell() - 262144))
            lines = fh.read().decode("utf-8", "replace").splitlines()
    except OSError:
        return ""
    recent = now() - dt.timedelta(minutes=10)
    for line in reversed(lines):
        try:
            entry = json.loads(line)
        except json.JSONDecodeError:
            continue
        if not isinstance(entry, dict) or not entry.get("isApiErrorMessage"):
            continue
        at = parse_iso(entry.get("timestamp", ""))
        if entry.get("error") != error or not at or at < recent:
            return ""  # the latest API error is another one, or an old one
        resets = (entry.get("quotaLimits") or {}).get("resetsAt")
        return iso(dt.datetime.fromtimestamp(resets).astimezone()) if isinstance(resets, (int, float)) else ""
    return ""


def cmd_halted(_):
    """StopFailure hook of the servant session (settings.json): a turn ended on an API error.

    Claude Code ignores this hook's output and exit code (docs: hooks, StopFailure). The
    hook records the error for the canvas and `servant status`, releases the lock the dead
    turn may hold, stops the servant.py commands it left, and re-renders the canvas.
    Nothing restarts a pass here: the session's scheduled job does, and the next `lock`
    clears the record. A usage limit thus costs nothing while it lasts."""
    try:
        event = json.loads(sys.stdin.read() or "{}")
    except json.JSONDecodeError:
        event = {}
    error = str(event.get("error") or "unknown")
    prev = load(HALT, {})
    ongoing = bool(prev.get("active"))
    stamp = iso()
    resets = limit_reset(event.get("transcript_path") or "", error) if error == "rate_limit" else ""
    if not resets and ongoing and prev.get("error") == error:
        resets = prev.get("resets_at") or ""
    save(HALT, {"active": True, "since": prev.get("since") if ongoing else stamp,
                "at": stamp, "error": error,
                "details": str(event.get("error_details") or "")[:300],
                "message": str(event.get("last_assistant_message") or "")[:300],
                "resets_at": resets})
    if load(LOCK, {}).get("state") == "running":  # the turn that held it has ended
        save(LOCK, {"state": "idle", "since": stamp})
    drain()
    if SNAPSHOT.exists():
        cmd_render(argparse.Namespace(open=False))


# ---------------------------------------------------------------- local worktree

def cmd_worktree(a):
    m = GH_RE.match(a.pr_url)
    if not m or m.group(3) != "pull":
        die("worktree needs a GitHub pull request URL")
    owner, repo, _, number = m.groups()
    rc, out, err = run(["gh", "pr", "view", a.pr_url, "--json", "headRefName,isCrossRepository,state"])
    if rc:
        die(f"gh pr view failed: {first_line(err)}")
    info = json.loads(out)
    if info.get("isCrossRepository"):
        die("the PR comes from a fork; servant does not check out forks")
    if info.get("state") != "OPEN":
        die(f"the PR is {info.get('state')}; there is nothing to fix")
    head = info["headRefName"]
    clone = REPOS / owner / repo
    if not (clone / ".git").exists():
        clone.parent.mkdir(parents=True, exist_ok=True)
        rc, _, err = run(["gh", "repo", "clone", f"{owner}/{repo}", str(clone), "--",
                          "--filter=blob:none", "--no-checkout"], timeout=WORKTREE_BUDGET)
        if rc:
            die(f"clone failed: {first_line(err)}")
    rc, _, err = run(["git", "-C", str(clone), "fetch", "origin", f"+refs/heads/{head}:refs/remotes/origin/{head}"],
                     timeout=WORKTREE_BUDGET)
    if rc:
        die(f"git fetch failed: {first_line(err)}")
    wt = WORKTREES / f"{owner}-{repo}-{number}"
    if not wt.exists():
        WORKTREES.mkdir(parents=True, exist_ok=True)
        has_branch = run(["git", "-C", str(clone), "rev-parse", "--verify", "--quiet", f"refs/heads/{head}"])[0] == 0
        cmd = (["git", "-C", str(clone), "worktree", "add", str(wt), head] if has_branch else
               ["git", "-C", str(clone), "worktree", "add", "--track", "-b", head, str(wt), f"origin/{head}"])
        rc, _, err = run(cmd, timeout=WORKTREE_BUDGET)  # a blob:none clone fetches blobs here
        if rc:
            die(f"git worktree add failed: {first_line(err)}")
        state = "created"
    elif run(["git", "-C", str(wt), "status", "--porcelain"])[1].strip():
        state = "dirty: uncommitted changes from an earlier pass are kept as they are"
    else:
        rc, _, err = run(["git", "-C", str(wt), "merge", "--ff-only", f"origin/{head}"])
        state = f"up to date with origin/{head}" if rc == 0 else f"diverged from origin/{head}: {first_line(err)}"
    print(f"path   : {wt}\nbranch : {head}\nstate  : {state}\n"
          f"push   : git -C {wt} push origin HEAD:{head}   (the user runs this, never servant)")


# ---------------------------------------------------------------- canvas

CSS = """
:root{--bg:#0f1115;--surface:#171a21;--surface-2:#1e222b;--border:#2a2f3a;--text:#e6e8ee;--muted:#9aa3b2;
--accent:#6ea8fe;--good:#5fb487;--warn:#d6a85f;--bad:#d97a7a;
--mono:ui-monospace,SFMono-Regular,Menlo,monospace;--sans:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--text);font-family:var(--sans);font-size:15px;line-height:1.6}
a{color:var(--accent);text-decoration:none}a:hover{text-decoration:underline}
.wrap{max-width:1440px;margin:0 auto;padding:28px 24px 64px}
header h1{margin:0 0 4px;font-size:26px;font-weight:600}
header .meta{color:var(--muted);font-size:13px}
.grid{display:grid;gap:14px;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));margin:22px 0}
.card{background:var(--surface);border:1px solid var(--border);border-radius:12px;padding:16px;overflow-x:auto}
.stat .label{color:var(--muted);font-size:12px;letter-spacing:.04em}
.stat .value{font-size:30px;font-weight:600;margin-top:4px}
section{margin:26px 0}
section h2{font-size:15px;font-weight:600;color:var(--muted);letter-spacing:.05em;margin:0 0 10px}
table{width:100%;border-collapse:collapse;font-size:14px}
th,td{text-align:left;padding:8px 10px;border-bottom:1px solid var(--border);vertical-align:top;overflow-wrap:anywhere}
td ul{margin:0;padding-left:18px}
td li{margin:3px 0}
td hr{border:0;border-top:1px solid var(--border);margin:8px 0}
td .kind{color:var(--muted);font-size:12px}
details.body summary{cursor:pointer}
details.body div{white-space:pre-wrap;margin:6px 0 0;padding:8px;background:var(--bg);border-radius:6px}
th{color:var(--muted);font-weight:500;font-size:12px}
tbody tr:nth-child(odd){background:var(--surface-2)}
code,.mono{font-family:var(--mono);font-size:13px}
.muted{color:var(--muted)}
.badge{display:inline-block;padding:2px 9px;border-radius:999px;font-size:12px;border:1px solid var(--border);white-space:nowrap}
.badge.good{color:var(--good);border-color:var(--good)}
.badge.warn{color:var(--warn);border-color:var(--warn)}
.badge.bad{color:var(--bad);border-color:var(--bad)}
.badge.accent{color:var(--accent);border-color:var(--accent)}
.banner{margin:16px 0 0;padding:10px 14px;border:1px solid var(--bad);border-radius:8px;color:var(--bad)}
details.guide{margin:16px 0 0;color:var(--muted);font-size:13px}
details.guide summary{cursor:pointer}
details.guide li{margin:2px 0}
"""

GUIDE = """<details class="guide"><summary>見方</summary><ul>
<li>見るのは「要確認」だけで足ります。ほかの表は全体の一覧です。</li>
<li>完了の提案: 根拠の Slack を確認し、合っていれば Jira を自分で REVIEW-OK にします。</li>
<li>確認: 書かれている内容を判断し、必要なら Jira を自分で直します。</li>
<li>未処理の指摘: 次回以降の実行で servant が修正か返信案を作ります。何もしなくて構いません。</li>
<li>ローカル修正: 指摘ごとに servant が直した内容を 1 行で書いています。修正は <code>~/.local/state/servant/worktrees/</code> の PR ごとのディレクトリにあり、commit も push もしていません。確認して、よければ自分で commit と push をします。</li>
<li>返信案: 指摘の行にある「返信案」を開くと、その指摘への返信として servant が書いた文面が出ます。確認してから GitHub に貼ります。</li>
<li>自動更新待ち: 1 回の実行で Jira を更新するのは 5 件までです。残りは次回に servant が更新します。</li>
<li>自動更新の履歴: servant が Jira に加えた変更です。誤りがあれば Jira で戻してください。</li>
</ul></details>"""

STALE_SCRIPT = """<script>
(function(){var g=Date.parse(document.body.dataset.generated);
if(!isNaN(g)&&Date.now()-g>60*60*1000){document.getElementById('stale').hidden=false;}})();
</script>"""

STATUS_CLASS = {DONE: "good", "レビュー中": "accent", "進行中": "warn"}
# StopFailure error types that only the user can clear (docs: hooks, StopFailure matcher).
USER_ACTION_ERRORS = {"authentication_failed", "oauth_org_not_allowed", "account_on_hold", "billing_error"}
KIND_CLASS = {"完了の提案": "good", "確認": "warn", "未処理の指摘": "bad", "ローカル修正": "accent",
              "返信案": "accent", "自動更新待ち": "warn"}


def esc(s):
    return html.escape(str(s if s is not None else ""))


def anchor(url, text):
    return f'<a href="{esc(url)}" target="_blank" rel="noopener">{esc(text)}</a>' if url else esc(text)


def badge(text, cls=""):
    return f'<span class="badge {cls}">{esc(text)}</span>'


def link_cell(t):
    parts = []
    for link in t["links"]:
        if link["kind"] == "github":
            label = f"{'CO ' if link.get('co') else ''}{link['repo']}#{link['number']}"
            parts.append(f"{anchor(link['url'], label)} <span class=\"muted\">{esc(state_label(link))}</span>")
        else:
            label = {"slack": "Slack", "confluence": "Confluence", "jira": "Jira", "gdoc": "Google Docs"}.get(
                link["kind"], urlparse(link["url"]).netloc)
            parts.append(anchor(link["url"], label))
    return "<br>".join(parts) or '<span class="muted">なし</span>'


def when(s):
    t = parse_iso(s or "")
    return t.astimezone().strftime("%m/%d %H:%M") if t else "-"


def halt_banner(h):
    """Why passes stop and when they resume, from halt.json, which `halted` writes."""
    err = h.get("error") or "unknown"
    if err == "rate_limit":
        text = f"利用上限のため、{when(h.get('since'))} から巡回が止まっています。"
        resets = parse_iso(h.get("resets_at") or "")
        if resets and resets > now():  # a past time means another limit holds now
            text += f"上限は {when(h['resets_at'])} に戻る見込みです。"
        text += "戻ったあとの最初の定期実行で、自動的に再開します。"
    elif err in USER_ACTION_ERRORS:
        text = (f"API エラー（{err}）のため、{when(h.get('since'))} から巡回が止まっています。"
                "Claude Code のログインか契約の状態を確認してください。解消すれば、次の定期実行で再開します。")
    else:
        text = f"API エラー（{err}）のため、{when(h.get('at'))} の巡回が途中で止まりました。次の定期実行で再開します。"
    detail = f'<br><span class="muted">{esc(h["message"])}</span>' if h.get("message") else ""
    return f'<div class="banner">{esc(text)}{detail}</div>'


def table(headers, rows):
    if not rows:
        return '<p class="muted">該当なし</p>'
    head = "".join(f"<th>{esc(h)}</th>" for h in headers)
    body = "".join("<tr>" + "".join(f"<td>{c}</td>" for c in r) + "</tr>" for r in rows)
    return f"<table><thead><tr>{head}</tr></thead><tbody>{body}</tbody></table>"


def cmd_render(a):
    snap = load(SNAPSHOT, None)
    if not snap:
        die("no snapshot yet: run `servant.py scan` first")
    notes = load_notes()
    nt, meta = notes["tickets"], notes["meta"]
    last = meta.get("run") or {}
    done_now = {(x["key"], x["type"]): x for x in last.get("actions", [])}
    tickets = snap["tickets"]
    for t in tickets:  # show the state after this pass's own writes
        if (t["key"], "transition_review_ok") in done_now:
            t["status"] = DONE
        if (t["key"], "add_review_prefix") in done_now:
            t["summary"] = done_now[(t["key"], "add_review_prefix")]["after"]

    def ticket_cell(t):
        return f'{anchor(t["url"], t["key"])}<br><span class="muted">{esc(t["summary"])}</span>'

    def work(t):
        n = nt.get(t["key"], {})
        return esc(n.get("summary")) if n.get("summary") else '<span class="muted">未要約</span>'

    def cite(text, url=None):
        # Each item carries its own evidence link, so the row needs no separate reference column.
        return f"{text} {anchor(url, '根拠')}" if url else text

    def reply_link(path):
        p = Path(path or "")
        return f" ・ {anchor(p.as_uri(), '返信案')}" if p.is_absolute() else ""

    # Every item is (ticket, kind, html). Items of one ticket end up in one row.
    attention = []
    for t in tickets:
        if t["status"] == DONE:
            continue
        n = nt.get(t["key"], {})
        for p in t["proposals"]:
            attention.append((t, "確認", cite(esc(p["text"]), p.get("evidence"))))
        for p in n.get("proposals", []):
            text = f"{esc(p['text'])} <span class=\"muted\">({esc(p['at'][:16])})</span>"
            attention.append((t, "完了の提案", cite(text, p.get("evidence"))))
        for i in t["feedback"]:
            # The whole review body, folded: reviews can run to pages of tables.
            text = (f'<details class="body"><summary>{esc(i["author"])} の指摘（{len(i["body"])} 字）</summary>'
                    f'<div>{esc(i["body"])}</div></details>')
            attention.append((t, "未処理の指摘", cite(text, i["url"])))
        for pr in dict.fromkeys(i["pr"] for i in t["handled_open"]):
            done = [(i, n.get("handled", {}).get(i["id"], {})) for i in t["handled_open"] if i["pr"] == pr]
            done = [(i, h) for i, h in done if h.get("how") in ("fix", "draft")]
            kind = "ローカル修正" if any(h.get("how") == "fix" for _, h in done) else "返信案"
            for i, h in done:
                text = cite(f"{esc(i.get('author') or '')}: {esc(h.get('memo') or '')}", i["url"])
                attention.append((t, kind, text + reply_link(h.get("draft"))))
        for act in t["actions"]:
            if (t["key"], act["type"]) not in done_now:
                attention.append((t, "自動更新待ち", esc(f"{act['type']}: {act.get('reason', '')}")))
    order = list(KIND_CLASS)
    grouped = {}
    for t, kind, line in attention:
        grouped.setdefault(t["key"], (t, []))[1].append((kind, line))
    att_rows = []
    for t, entries in sorted(grouped.values(), key=lambda g: min(order.index(k) for k, _ in g[1])):
        entries.sort(key=lambda e: order.index(e[0]))
        kinds = list(dict.fromkeys(k for k, _ in entries))
        # One bullet list per kind; kinds are separated by a rule and labelled only when there are several.
        blocks = []
        for k in kinds:
            items = "".join(f"<li>{line}</li>" for kk, line in entries if kk == k)
            label = f'<div class="kind">{esc(k)}</div>' if len(kinds) > 1 else ""
            blocks.append(f"{label}<ul>{items}</ul>")
        att_rows.append([ticket_cell(t), " ".join(badge(k, KIND_CLASS[k]) for k in kinds), "<hr>".join(blocks)])

    def rows_for(role, cols):
        sel = sorted((t for t in tickets if t["role"] == role), key=lambda t: t["status"] == DONE)
        return [cols(t) for t in sel]

    review_rows = rows_for("review", lambda t: [
        ticket_cell(t), badge(t["status"], STATUS_CLASS.get(t["status"], "")), link_cell(t),
        "<br>".join(esc(l.get("review_status")) for l in t["links"] if l.get("review_status")) or "-", work(t)])
    impl_rows = rows_for("impl", lambda t: [
        ticket_cell(t), badge(t["status"], STATUS_CLASS.get(t["status"], "")), link_cell(t),
        str(len(t["feedback"])) if t["feedback"] else "-", work(t), esc(nt.get(t["key"], {}).get("next", ""))])
    other_rows = rows_for("other", lambda t: [
        ticket_cell(t), badge(t["status"], STATUS_CLASS.get(t["status"], "")), link_cell(t), work(t),
        esc(nt.get(t["key"], {}).get("next", ""))])

    history = []
    if ACTIONS.exists():
        lines = ACTIONS.read_text(encoding="utf-8").splitlines()[-15:]
        for line in reversed(lines):
            try:
                x = json.loads(line)
            except json.JSONDecodeError:
                continue
            history.append([esc(x["at"][:16].replace("T", " ")), esc(x["key"]), esc(x["type"]),
                            f"{esc(x['before'])} → {esc(x['after'])}"])

    cron = meta.get("cron") or {}
    halt = load(HALT, {})
    halted = halt_banner(halt) if halt.get("active") else ""
    done_count = sum(1 for t in tickets if t["status"] == DONE)
    cards = [("担当チケット", len(tickets)), ("要確認", len(att_rows)),
             ("今回の自動更新", len(last.get("actions", []))), ("完了待ち (REVIEW-OK)", done_count)]
    updated = iso()
    page = f"""<!DOCTYPE html>
<html lang="ja"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="refresh" content="300">
<title>servant</title><style>{CSS}</style></head>
<body data-generated="{esc(updated)}"><div class="wrap">
<header><h1>servant: 担当チケットの状況</h1>
<div class="meta">最終更新 {esc(updated[:16].replace('T', ' '))} ・ データ取得 {esc(when(snap.get('generated_at')))} ・ 巡回は {esc(CRON_JA)} ・ 定期実行{esc(cron.get('job_id', '未登録'))} ({esc((cron.get('created_at') or '-')[:10])} 登録) ・ このページは 5 分ごとに再読み込み</div>
{halted}
<div id="stale" class="banner" hidden>1 時間以上更新されていません。ターミナルで <code>servant status</code> を実行し、止まっていれば <code>servant restart</code> を実行してください。</div>
{GUIDE}</header>
<div class="grid">{''.join(f'<div class="card stat"><div class="label">{esc(l)}</div><div class="value">{v}</div></div>' for l, v in cards)}</div>
<section><h2>要確認</h2><div class="card">{table(["チケット", "種類", "内容"], att_rows)}</div></section>
<section><h2>レビュー</h2><div class="card">{table(["チケット", "ステータス", "PR", "自分のレビュー", "仕事内容"], review_rows)}</div></section>
<section><h2>実装</h2><div class="card">{table(["チケット", "ステータス", "CO / PR", "未処理の指摘", "仕事内容", "次の作業"], impl_rows)}</div></section>
<section><h2>その他（完了の合図なし。手動で更新）</h2><div class="card">{table(["チケット", "ステータス", "参照", "仕事内容", "次の作業"], other_rows)}</div></section>
<section><h2>自動更新の履歴（新しい順に 15 件）</h2><div class="card">{table(["時刻", "チケット", "操作", "変更"], history)}</div></section>
</div>{STALE_SCRIPT}</body></html>
"""
    STATE.mkdir(parents=True, exist_ok=True)
    tmp = CANVAS.with_name(CANVAS.name + ".tmp")
    tmp.write_text(page, encoding="utf-8")
    os.replace(tmp, CANVAS)
    print(f"canvas: {CANVAS}")
    if a.open:
        run(["open", str(CANVAS)])


# ---------------------------------------------------------------- main

def main():
    global _budget
    p = argparse.ArgumentParser(prog="servant.py")
    sub = p.add_subparsers(dest="cmd", required=True)
    for name in ("lock", "unlock", "context", "scan", "drain", "halted"):
        sub.add_parser(name)
    for name in ("ticket", "feedback"):
        sub.add_parser(name).add_argument("key")
    sub.add_parser("view").add_argument("url")
    n = sub.add_parser("note")
    n.add_argument("key")
    n.add_argument("--summary")
    n.add_argument("--next")
    n.add_argument("--handled")
    n.add_argument("--how", choices=("fix", "draft", "none"))
    n.add_argument("--path")
    n.add_argument("--draft")
    n.add_argument("--memo")
    n.add_argument("--slack-seen", nargs=2, metavar=("URL", "TS"))
    n.add_argument("--proposal")
    n.add_argument("--evidence")
    n.add_argument("--clear-proposals", action="store_true")
    ap = sub.add_parser("apply")
    ap.add_argument("key")
    ap.add_argument("type", choices=ACTION_TYPES)
    sub.add_parser("meta").add_argument("--cron-job")
    sub.add_parser("worktree").add_argument("pr_url")
    sub.add_parser("render").add_argument("--open", action="store_true")
    a = p.parse_args()
    _budget = BUDGET.get(a.cmd, DEFAULT_BUDGET)
    {"lock": cmd_lock, "unlock": cmd_unlock, "context": cmd_context, "drain": cmd_drain,
     "scan": cmd_scan, "apply": cmd_apply, "ticket": cmd_ticket, "feedback": cmd_feedback,
     "view": cmd_view, "note": cmd_note, "meta": cmd_meta, "worktree": cmd_worktree,
     "render": cmd_render, "halted": cmd_halted}[a.cmd](a)


if __name__ == "__main__":
    main()
