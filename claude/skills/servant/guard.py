#!/usr/bin/env -S python3 -I
"""PreToolUse guard of the servant background session (hooked in by settings.json here).

The session runs unattended, with the user's credentials, and reads text other people
wrote: Jira descriptions, review comments, Slack threads. Its tool calls are therefore
held to an allowlist that does not depend on the user's own permission rules, which
allow general-purpose commands such as python3 and curl. Every call this script does
not allow is blocked with exit code 2, and the hook is set to block when this script
fails or times out, so a broken guard blocks rather than allows.

Allowed:
  - reading tools, tool search, skills, and the session's own cron tools
  - mcp__slack__slack_read_thread
  - Bash: servant.py, run directly or as `python3 [-I] servant.py`, as one plain command
  - Edit, Write and MultiEdit on a file under the state directory's worktrees/ or drafts/

The two Jira writes the user allowed go through `servant.py apply`, which derives them
from Jira and GitHub itself, so no Jira command is allowed here. GitHub reads go through
servant.py too (`servant.py view`), because it stops a call that a sleep of the Mac or a
Wi-Fi drop left hanging, and a bare gh would wait forever.
"""
import json
import os
import shlex
import sys
from pathlib import Path

HOME = Path.home()
STATE = Path(os.path.realpath(os.environ.get("SERVANT_STATE_DIR") or HOME / ".local/state/servant"))
WRITABLE = (STATE / "worktrees", STATE / "drafts")
SERVANT_PY = HOME / ".claude/skills/servant/servant.py"

TOOLS = {"Read", "Glob", "Grep", "ToolSearch", "Skill", "CronCreate", "CronList", "CronDelete",
         "mcp__slack__slack_read_thread"}
FILE_TOOLS = {"Edit", "Write", "MultiEdit"}
SCRIPTS = (str(SERVANT_PY), "~/.claude/skills/servant/servant.py")
PYTHONS = (["python3"], ["python3", "-I"])
# Expansion, substitution and line continuation would let one allowed word run another
# command, so a command that contains any of these is blocked outright.
UNSAFE_CHARS = "$`\\\n\r"
OPERATOR_CHARS = set("();<>|&")


def bash_verdict(command):
    if any(ch in command for ch in UNSAFE_CHARS):
        return "it contains $, a backtick, a backslash or a line break"
    lexer = shlex.shlex(command, posix=True, punctuation_chars=True)
    lexer.whitespace_split = True
    try:
        words = list(lexer)
    except ValueError as e:
        return f"it does not parse: {e}"
    if any(w and set(w) <= OPERATOR_CHARS for w in words):
        return "it chains commands, redirects or opens a subshell"
    starts = [0] + [len(p) for p in PYTHONS if words[:len(p)] == p]
    if not any(words[i:i + 1] and words[i] in SCRIPTS for i in starts):
        return "only servant.py runs in a servant pass"
    return None


def path_verdict(file_path, cwd):
    if not file_path:
        return "it names no file"
    p = Path(os.path.expanduser(file_path))
    if not p.is_absolute():
        p = Path(cwd or os.getcwd()) / p
    real = Path(os.path.realpath(p))  # follows symlinks, so a link in a worktree cannot lead out
    if ".git" in real.parts:
        return "it writes inside a .git directory"
    if not any(real.is_relative_to(w) for w in WRITABLE):
        return f"servant writes only under {WRITABLE[0]}/ and {WRITABLE[1]}/"
    return None


def main():
    event = json.load(sys.stdin)
    tool = event.get("tool_name") or ""
    args = event.get("tool_input") or {}
    if tool in TOOLS:
        return
    if tool == "Bash":
        reason = bash_verdict(args.get("command") or "")
    elif tool in FILE_TOOLS:
        reason = path_verdict(args.get("file_path") or "", event.get("cwd"))
    else:
        reason = "the tool is not on the servant allowlist"
    if reason:
        print(f"servant guard blocked {tool}: {reason}. Note it and move on; do not look for "
              f"another way to do the same thing.", file=sys.stderr)
        sys.exit(2)


if __name__ == "__main__":
    main()
