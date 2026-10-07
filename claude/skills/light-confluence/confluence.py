#!/usr/bin/env -S python3 -I
"""Confluence REST client for the light-confluence skill.

The only place where the Atlassian API key is handled. The caller never needs
to read, test or print the key: this script resolves the credentials itself,
sends request bodies from files only, writes response bodies to files only,
and prints one short status line. Anything it prints passes through redact(),
so neither the key nor the Basic auth value can reach the conversation even
when Confluence echoes a request back in an error.

  confluence.py check
  confluence.py get  <path> --out FILE
  confluence.py put  <path> --data-file FILE [--out FILE]
  confluence.py post <path> --data-file FILE [--out FILE]

<path> is an API path on the Confluence site, for example
/wiki/api/v2/pages/123?body-format=storage.

Credentials: ATLASSIAN_API_KEY (required). The account email is
ATLASSIAN_EMAIL, else `git config --global user.email`. The site is
CONFLUENCE_SITE, else <first label of the email domain>.atlassian.net.
"""
import base64
import json
import os
import re
import subprocess
import sys
import urllib.error
import urllib.request

PATH_RE = re.compile(r"^/wiki/(?:api/v2|rest/api)/[A-Za-z0-9/_\-.~?=&%,:+]*$")
TOKEN_RE = re.compile(r"ATATT[A-Za-z0-9_\-=]{8,}")


def _secrets():
    key = os.environ.get("ATLASSIAN_API_KEY", "")
    out = [key] if key else []
    email = _email(quiet=True)
    if key and email:
        out.append(base64.b64encode(f"{email}:{key}".encode()).decode())
    return out


def redact(text):
    text = str(text)
    for s in _secrets():
        text = text.replace(s, "<redacted>")
    return TOKEN_RE.sub("<redacted>", text)


def say(msg, err=False):
    print(redact(msg), file=sys.stderr if err else sys.stdout)


def die(msg):
    say(f"confluence.py: {msg}", err=True)
    sys.exit(2)


def _email(quiet=False):
    email = os.environ.get("ATLASSIAN_EMAIL", "")
    if not email:
        try:
            email = subprocess.run(["git", "config", "--global", "user.email"],
                                   capture_output=True, text=True).stdout.strip()
        except OSError:
            email = ""
    if not email and not quiet:
        die("cannot resolve the account email: set ATLASSIAN_EMAIL")
    return email


def _site():
    site = os.environ.get("CONFLUENCE_SITE", "")
    if not site:
        dom = _email().split("@", 1)[1]
        site = dom.split(".", 1)[0] + ".atlassian.net"
    return site


def request(method, path, data=None):
    if not PATH_RE.match(path):
        die(f"refusing path (must be /wiki/api/v2/... or /wiki/rest/api/...): {path}")
    key = os.environ.get("ATLASSIAN_API_KEY", "")
    if not key:
        die("ATLASSIAN_API_KEY is not set")
    auth = base64.b64encode(f"{_email()}:{key}".encode()).decode()
    req = urllib.request.Request(f"https://{_site()}{path}", data=data, method=method)
    req.add_header("Authorization", f"Basic {auth}")
    req.add_header("Accept", "application/json")
    if data is not None:
        req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            return r.status, r.read()
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", "replace")
        try:
            j = json.loads(body)
            msg = "; ".join(x.get("title") or x.get("detail") or str(x) for x in j.get("errors", [])) \
                or j.get("message") or body
        except ValueError:
            msg = body
        die(f"{method} {path} -> HTTP {e.code}: {msg[:300]}")
    except urllib.error.URLError as e:
        die(f"{method} {path} -> {e.reason}")


def opts(args, allowed):
    out = {}
    while args:
        a = args.pop(0)
        if a not in allowed or not args:
            die(f"unknown or incomplete option: {a}")
        out[a] = args.pop(0)
    return out


def main(argv):
    if not argv or argv[0] in ("-h", "--help", "help"):
        print(__doc__.split("\n\n")[2])
        return
    cmd, rest = argv[0], argv[1:]
    if cmd == "check":
        status, body = request("GET", "/wiki/rest/api/user/current")
        name = json.loads(body).get("displayName", "?")
        say(f"ok: authenticated as {name} on https://{_site()}")
        return
    if cmd not in ("get", "put", "post") or not rest:
        die(f"usage: {cmd} <path> ...  (run with --help)")
    path, o = rest[0], opts(rest[1:], {"--out", "--data-file"})
    data = None
    if cmd in ("put", "post"):
        f = o.get("--data-file") or die(f"{cmd} needs --data-file FILE (bodies are never inline)")
        data = open(f, "rb").read()
        if len(data) < 2:
            die(f"payload {f} is only {len(data)} bytes: the body did not make it in")
    elif "--out" not in o:
        die("get needs --out FILE (responses are never printed)")
    status, body = request(cmd.upper(), path, data)
    if "--out" in o:
        with open(o["--out"], "wb") as fh:
            fh.write(body)
        say(f"{status} {cmd.upper()} {path} -> {o['--out']} ({len(body)} bytes)")
    else:
        say(f"{status} {cmd.upper()} {path} ({len(body)} bytes, body not saved)")


if __name__ == "__main__":
    main(sys.argv[1:])
