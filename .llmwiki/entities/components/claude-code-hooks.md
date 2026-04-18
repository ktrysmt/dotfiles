---
entity: claude-code-hooks
category: components
sources:
  - path: /Users/dew/dotfiles/claude/hooks/cleanup-short-sessions.sh
    source_type: primary
    sha256: 8bcc75d5859d7327a2e58c63a8eec37f7c2f6b564a2ff4e3213a5df20cb59377
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/claude/hooks/session_summarizer.py
    source_type: primary
    sha256: d769e84c45d1697eee548d8d351f10870c45cc5a21c0c2eaf17926c27b4fafbc
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/claude/hooks/session_summarizer_wrapper.sh
    source_type: primary
    sha256: 4fd45389c4363067afdebf783770b17b05870eb44903862d5a4be04ce4ce9149
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/claude/hooks/markdown-lint.sh
    source_type: primary
    sha256: 0b04987bc1c1c0681dd31bb8627636688d3acb68edb6634faf61c1cdca564c88
    ingested: 2026-04-18
  - path: /Users/dew/dotfiles/claude/hooks/sandbox-auto-allow.sh
    source_type: primary
    sha256: 3eaef95fc4d95e2f5e05e813ff9f7d9901b882dd06d349faf5fb6aebf5d0e8c9
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/claude/hooks/tmux-window-claude-status.sh
    source_type: primary
    sha256: 6346260836bf1a867f34bf4574e9df5bf25334acacc0becc548059ce2edefd6f
    ingested: 2026-04-18
related:
  - claude-code-config
  - tmux-config
  - devcontainer
created: 2026-04-06
updated: 2026-04-18
---

# Claude Code Hooks

## Overview
Hook system for Claude Code lifecycle events executing bash/python scripts. Hooks trigger on SessionStart, SessionEnd, PostToolUse, UserPromptSubmit, Notification, and Stop events. Key hooks: cleanup-short-sessions (delete transcripts with <2 user messages), session-summarizer (AI-generated session summaries), markdown-lint (enforce formatting rules), sandbox-auto-allow (auto-detect and whitelist blocked domains), and tmux-window-claude-status (update tmux window state).

## Key Facts
- cleanup-short-sessions.sh (SessionEnd): deletes session transcript if <2 user messages; MIN_TURNS configurable
- session_summarizer.py (SessionEnd): generates markdown summaries saved to ~/.claude/session-summaries/{repo}/{worktree}/; uses claude -p subprocess
- session_summarizer_wrapper.sh: shell wrapper for session_summarizer.py
- markdown-lint.sh (PostToolUse): enforces no bold `**...**`, vertical mermaid (TB/TD) layout, single-line mermaid node defs (balanced `[]/()/{}`), `<br>` over `\n` for line breaks; blocks file writes on violation [source: markdown-lint.sh, primary, 2026-04-18]
- sandbox-auto-allow.sh (PostToolUse Bash matcher): auto-detects network errors (SSL/DNS/conn), extracts blocked domain, appends to settings.json allowedDomains
- tmux-window-claude-status.sh (SessionStart/UserPromptSubmit/PostToolUse/Stop/SessionEnd): updates per-pane `@claude-status` (start/thinking/notification/done/reset); aggregates statuses across all panes in the window; pane colors yellow=notification, blue=thinking, green=active; devcontainer fallback relays via TCP to host.docker.internal:2489 when direct tmux socket unreachable; skips when CLAUDE_SUMMARIZER_RUNNING=1 [source: tmux-window-claude-status.sh, primary, 2026-04-18]

## Relations
- [[claude-code-config]] -- Hooks configured in settings.json
- [[tmux-config]] -- tmux-window-claude-status.sh integrates with tmux
- [[devcontainer]] -- tmux status hook falls back to TCP relay inside devcontainer

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | claude/hooks/cleanup-short-sessions.sh | primary |
| 2026-04-06 | claude/hooks/session_summarizer.py | primary |
| 2026-04-06 | claude/hooks/session_summarizer_wrapper.sh | primary |
| 2026-04-18 | claude/hooks/markdown-lint.sh | primary |
| 2026-04-06 | claude/hooks/sandbox-auto-allow.sh | primary |
| 2026-04-18 | claude/hooks/tmux-window-claude-status.sh | primary |

## Changelog
- 2026-04-06: Initial creation from 6 hook files
- 2026-04-18: markdown-lint.sh extended to enforce mermaid layout/multiline/newline rules (was bold-only); tmux-window-claude-status.sh added devcontainer TCP relay to host:2489 and per-pane status aggregation; added [[devcontainer]] relation
