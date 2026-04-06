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
    sha256: 7c03e0fbbb39043cbf75455582cb8656e52fe9e07a7d426ab7920dc661a61380
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/claude/hooks/sandbox-auto-allow.sh
    source_type: primary
    sha256: 3eaef95fc4d95e2f5e05e813ff9f7d9901b882dd06d349faf5fb6aebf5d0e8c9
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/claude/hooks/tmux-window-claude-status.sh
    source_type: primary
    sha256: c4567f4003f1bc207b25383387bfbc2b065812b31ea6c16364e124183de42a54
    ingested: 2026-04-06
related:
  - claude-code-config
  - tmux-config
created: 2026-04-06
updated: 2026-04-06
---

# Claude Code Hooks

## Overview
Hook system for Claude Code lifecycle events executing bash/python scripts. Hooks trigger on SessionStart, SessionEnd, PostToolUse, UserPromptSubmit, Notification, and Stop events. Key hooks: cleanup-short-sessions (delete transcripts with <2 user messages), session-summarizer (AI-generated session summaries), markdown-lint (enforce formatting rules), sandbox-auto-allow (auto-detect and whitelist blocked domains), and tmux-window-claude-status (update tmux window state).

## Key Facts
- cleanup-short-sessions.sh (SessionEnd): deletes session transcript if <2 user messages; MIN_TURNS configurable
- session_summarizer.py (SessionEnd): generates markdown summaries saved to ~/.claude/session-summaries/{repo}/{worktree}/; uses claude -p subprocess
- session_summarizer_wrapper.sh: shell wrapper for session_summarizer.py
- markdown-lint.sh (PostToolUse): enforces no bold, vertical mermaid, single-line node defs, <br> for line breaks; blocks file writes on violation
- sandbox-auto-allow.sh (PostToolUse Bash matcher): auto-detects network errors (SSL/DNS/conn), extracts blocked domain, appends to settings.json allowedDomains
- tmux-window-claude-status.sh (SessionStart/UserPromptSubmit/PostToolUse/Stop/SessionEnd): updates tmux window status (start/thinking/notification/done/reset) and pane colors

## Relations
- [[claude-code-config]] -- Hooks configured in settings.json
- [[tmux-config]] -- tmux-window-claude-status.sh integrates with tmux

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | claude/hooks/cleanup-short-sessions.sh | primary |
| 2026-04-06 | claude/hooks/session_summarizer.py | primary |
| 2026-04-06 | claude/hooks/session_summarizer_wrapper.sh | primary |
| 2026-04-06 | claude/hooks/markdown-lint.sh | primary |
| 2026-04-06 | claude/hooks/sandbox-auto-allow.sh | primary |
| 2026-04-06 | claude/hooks/tmux-window-claude-status.sh | primary |

## Changelog
- 2026-04-06: Initial creation from 6 hook files
