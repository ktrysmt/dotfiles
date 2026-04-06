---
entity: agent-teams
category: concepts
sources:
  - path: /Users/dew/dotfiles/claude/skills/teammate-fullstack-feature/SKILL.md
    source_type: primary
    sha256: 7159edf477de85ede27c33aec41c3ea3ed7e4ce6350df6b066594974cd971986
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/claude/skills/teammate-parallel-review/SKILL.md
    source_type: primary
    sha256: 8b705c9c9e1c541111aabb52cfc3728725f529eee73ba0307ac4e114ed6ba97b
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/claude/skills/teammate-parallel-research/SKILL.md
    source_type: primary
    sha256: 02f95d3b5079d40aa6babcff7c99f23a5a0fecbfa747cf81e990719f69cb1c28
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/claude/skills/teammate-parallel-refactor/SKILL.md
    source_type: primary
    sha256: 505560240844d78b8af583d54bdb3c9615dfda2e1cebb9f5ccc31e24c5851070
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/claude/skills/teammate-hypothesis-debug/SKILL.md
    source_type: primary
    sha256: 53c8fdc9a0bbe7e3d472cd8f0d06791a123ffcd9efdcc1adfabaf1f9b9199dfe
    ingested: 2026-04-06
related:
  - claude-code-config
  - claude-code-skills
created: 2026-04-06
updated: 2026-04-06
---

# Agent Teams Pattern

## Overview
Team-based parallel execution pattern using Claude Code's TeamCreate API. A Lead agent coordinates multiple Teammates with distinct identities, file ownership, and phases. Teammates can be Read-Only (investigation/review) or Read-Write (implementation/refactoring). Key principles: exclusive file ownership prevents conflicts, phased execution manages dependencies, and team CLAUDE.md annotations specify boundaries.

## Key Facts
- TeamCreate: spawns parallel agents with distinct identities
- Phases: A (Lead: shared interfaces), B (parallel: independent work), C (sequential: integration)
- File ownership: Lead manages shared types/config; Teammates own assigned directories
- Read-Only mode: used for review, research, hypothesis investigation
- Read-Write mode: used for implementation, refactoring
- Patterns: fullstack (backend+frontend+test), review (security/performance/coverage), research (multi-axis investigation), refactor (directory-partitioned), debug (competing hypotheses)
- Enabled via env var: EXPERIMENTAL_AGENT_TEAMS=1
- CLAUDE.md behavior rule: "Agent Teams over subagents" for 2+ parallel tasks

## Relations
- [[claude-code-config]] -- Agent Teams enabled via env var in settings.json
- [[claude-code-skills]] -- Teammate-* skills implement Agent Teams patterns

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | claude/skills/teammate-fullstack-feature/SKILL.md | primary |
| 2026-04-06 | claude/skills/teammate-parallel-review/SKILL.md | primary |
| 2026-04-06 | claude/skills/teammate-parallel-research/SKILL.md | primary |
| 2026-04-06 | claude/skills/teammate-parallel-refactor/SKILL.md | primary |
| 2026-04-06 | claude/skills/teammate-hypothesis-debug/SKILL.md | primary |

## Changelog
- 2026-04-06: Initial creation from 5 Agent Teams skill template files
