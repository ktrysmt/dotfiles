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
    sha256: 469ce606577696f4f1c55d9c6a035775cc555edaad0fb47d48006586b5c79b69
    ingested: 2026-04-18
  - path: /Users/dew/dotfiles/claude/skills/teammate-parallel-review/SKILL.md
    source_type: primary
    sha256: 8b705c9c9e1c541111aabb52cfc3728725f529eee73ba0307ac4e114ed6ba97b
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/claude/skills/delegate/SKILL.md
    source_type: primary
    sha256: 451dc3a3ad6f19e6bf2d08412f1cac6531fc5d95b6dc7ef9eb9f87be0fc23469
    ingested: 2026-04-18
  - path: /Users/dew/dotfiles/claude/skills/github-to-notion/SKILL.md
    source_type: primary
    sha256: defb55d6480267c644bf336a52ef79722de3fb16d4df7b27990f04a99fbcb370
    ingested: 2026-04-18
related:
  - claude-code-config
  - agent-teams
  - bin-scripts
  - mcp-servers
created: 2026-04-06
updated: 2026-04-18
---

# Claude Code Skills

## Overview
Custom skill templates for Claude Code providing specialized workflows. Categories: browser automation (agent-browser standalone and CDP mode), Agent Teams workflows (fullstack feature development, parallel code review, parallel research, parallel refactoring, competing hypothesis debug), session delegation (delegate spawns independent tmux sessions via claude-skill-delegate), and external integrations (github-to-notion posts GitHub Issues/PRs into Notion databases via the official remote MCP). Agent Teams skills use TeamCreate to spawn parallel agents with distinct identities and file ownership.

## Key Facts
- agent-browser: standalone browser automation; new browser per session; commands: open, snapshot, click, fill, type, scroll, screenshot, pdf; reference-based targeting (@e1, @e2)
- agent-browser-9222: CDP mode connecting to existing Chrome on port 9222; preserves login sessions/cookies/auth
- teammate-fullstack-feature: Phase A (Lead: types), Phase B (parallel: Backend+Frontend), Phase C (sequential: Test)
- teammate-parallel-review: Read-only multi-perspective review; critic-security (OWASP), critic-performance, critic-coverage
- teammate-parallel-research: Multi-axis investigation via MCP (Arxiv, WebSearch, DeepWiki); fact-gathering only; no persona assignment for fact-gathering per Zheng et al. EMNLP 2024 [source: teammate-parallel-research/SKILL.md, primary, 2026-04-18]
- teammate-parallel-research: recommends /llm-research-paper or /evidence-review instead for academic paper analysis [source: teammate-parallel-research/SKILL.md, primary, 2026-04-18]
- teammate-parallel-refactor: Directory-partitioned refactoring; teammates assigned exclusive directories
- teammate-hypothesis-debug: Competing hypothesis analysis; Read-only Investigators; verdict: confirmed/denied/inconclusive
- delegate: spawns fully independent Claude Code session in tmux pane via `~/dotfiles/bin/claude-skill-delegate`; no `--continue`/`--fork-session`; one delegate at a time; no result reporting back to origin [source: delegate/SKILL.md, primary, 2026-04-18]
- github-to-notion: posts Issues/PRs into Notion via official remote MCP (https://mcp.notion.com/mcp); uses `gh` CLI for GitHub fetch and mcp__notion__{notion-search,notion-fetch,notion-create-pages,notion-query-data-sources}; OAuth auth; supports `--db <url|id|name>` or NOTION_DEFAULT_DB env [source: github-to-notion/SKILL.md, primary, 2026-04-18]

## Relations
- [[claude-code-config]] -- Skills registered in Claude Code settings
- [[agent-teams]] -- Agent Teams pattern used by teammate-* skills
- [[bin-scripts]] -- delegate skill invokes claude-skill-delegate from bin/
- [[mcp-servers]] -- github-to-notion skill depends on notion MCP server

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | claude/skills/agent-browser/SKILL.md | primary |
| 2026-04-06 | claude/skills/agent-browser-9222/SKILL.md | primary |
| 2026-04-06 | claude/skills/teammate-fullstack-feature/SKILL.md | primary |
| 2026-04-06 | claude/skills/teammate-hypothesis-debug/SKILL.md | primary |
| 2026-04-06 | claude/skills/teammate-parallel-refactor/SKILL.md | primary |
| 2026-04-18 | claude/skills/teammate-parallel-research/SKILL.md | primary |
| 2026-04-06 | claude/skills/teammate-parallel-review/SKILL.md | primary |
| 2026-04-18 | claude/skills/delegate/SKILL.md | primary |
| 2026-04-18 | claude/skills/github-to-notion/SKILL.md | primary |

## Changelog
- 2026-04-06: Initial creation from 7 skill template files
- 2026-04-18: Added delegate and github-to-notion skills (new); updated teammate-parallel-research with persona-restriction guidance and academic-paper redirection
