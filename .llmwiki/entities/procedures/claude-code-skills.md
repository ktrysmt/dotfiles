---
entity: claude-code-skills
category: procedures
sources:
  - path: /Users/dew/dotfiles/claude/skills/agent-browser/SKILL.md
    source_type: primary
    sha256: e6a93d6dd0f2da7adc8c2f16281a43ac11439b2bc1671f770ed32cdf85bbff10
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/claude/skills/agent-browser-9222/SKILL.md
    source_type: primary
    sha256: e4c4e191262c06caee38f6d7a5ba7c0bee93e62b7f51a73aad5619cef544a3ba
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/claude/skills/teammate-fullstack-feature/SKILL.md
    source_type: primary
    sha256: 7159edf477de85ede27c33aec41c3ea3ed7e4ce6350df6b066594974cd971986
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/claude/skills/teammate-hypothesis-debug/SKILL.md
    source_type: primary
    sha256: 53c8fdc9a0bbe7e3d472cd8f0d06791a123ffcd9efdcc1adfabaf1f9b9199dfe
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/claude/skills/teammate-parallel-refactor/SKILL.md
    source_type: primary
    sha256: 505560240844d78b8af583d54bdb3c9615dfda2e1cebb9f5ccc31e24c5851070
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/claude/skills/teammate-parallel-research/SKILL.md
    source_type: primary
    sha256: 02f95d3b5079d40aa6babcff7c99f23a5a0fecbfa747cf81e990719f69cb1c28
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/claude/skills/teammate-parallel-review/SKILL.md
    source_type: primary
    sha256: 8b705c9c9e1c541111aabb52cfc3728725f529eee73ba0307ac4e114ed6ba97b
    ingested: 2026-04-06
related:
  - claude-code-config
  - agent-teams
created: 2026-04-06
updated: 2026-04-06
---

# Claude Code Skills

## Overview
Custom skill templates for Claude Code providing specialized workflows. Two categories: browser automation (agent-browser standalone and CDP mode) and Agent Teams workflows (fullstack feature development, parallel code review, parallel research, parallel refactoring, competing hypothesis debug). Agent Teams skills use TeamCreate to spawn parallel agents with distinct identities and file ownership.

## Key Facts
- agent-browser: standalone browser automation; new browser per session; commands: open, snapshot, click, fill, type, scroll, screenshot, pdf; reference-based targeting (@e1, @e2)
- agent-browser-9222: CDP mode connecting to existing Chrome on port 9222; preserves login sessions/cookies/auth
- teammate-fullstack-feature: Phase A (Lead: types), Phase B (parallel: Backend+Frontend), Phase C (sequential: Test)
- teammate-parallel-review: Read-only multi-perspective review; critic-security (OWASP), critic-performance, critic-coverage
- teammate-parallel-research: Multi-axis investigation via MCP (Arxiv, WebSearch, DeepWiki); fact-gathering only
- teammate-parallel-refactor: Directory-partitioned refactoring; teammates assigned exclusive directories
- teammate-hypothesis-debug: Competing hypothesis analysis; Read-only Investigators; verdict: confirmed/denied/inconclusive

## Relations
- [[claude-code-config]] -- Skills registered in Claude Code settings
- [[agent-teams]] -- Agent Teams pattern used by teammate-* skills

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | claude/skills/agent-browser/SKILL.md | primary |
| 2026-04-06 | claude/skills/agent-browser-9222/SKILL.md | primary |
| 2026-04-06 | claude/skills/teammate-fullstack-feature/SKILL.md | primary |
| 2026-04-06 | claude/skills/teammate-hypothesis-debug/SKILL.md | primary |
| 2026-04-06 | claude/skills/teammate-parallel-refactor/SKILL.md | primary |
| 2026-04-06 | claude/skills/teammate-parallel-research/SKILL.md | primary |
| 2026-04-06 | claude/skills/teammate-parallel-review/SKILL.md | primary |

## Changelog
- 2026-04-06: Initial creation from 7 skill template files
