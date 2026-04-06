---
entity: claude-code-config
category: services
sources:
  - path: /Users/dew/dotfiles/claude/CLAUDE.md
    source_type: primary
    sha256: 442eb7dcc5b2cedf804da17fadc9fb6074a7ff42da5ebe395a9e4df7617ca7fe
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/claude/settings.json
    source_type: primary
    sha256: c8ec3e4fe467eff494965b25a771baba7a90d9a21d018c410c4ea48b66f74a9c
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/claude/settings.local.json
    source_type: secondary
    sha256: 4e3615e45371190f08ff8200e3e0bc9607f739ebc00f08d78c7c4cdb11857347
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/claude/keybindings.json
    source_type: primary
    sha256: 882e9dd1365015b5d935e334f022f71ff1de16536551ff8a7d7b3d9785a9db96
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/claude/rules/markdown.md
    source_type: primary
    sha256: 16a76644f29eaa6e70400f9393d3f109a6459de372e770b994223089831ae96f
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/claude/rules/pdf-mcp.md
    source_type: primary
    sha256: 85668d9bd1482aece5ae36c1a1bd1ebeaaae3821d52557aa7f5dc8bbc385706d
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/claude/statusline-command.sh
    source_type: primary
    sha256: f2430099b48c1395c23f1e960239c550065bde8183fe5d2fd2d0ba8cd2fca7ae
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/claude/README.md
    source_type: secondary
    sha256: 9ca7d1f5127a2b736c5a9aaf52b143e918c9d6bff77a57808cba8fc44716074d
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.claude/CLAUDE.md
    source_type: primary
    sha256: efc9ffa8c736d0f97ced2e30749f7a1c0ce6afbe55a296a3eaa1902a91d3352e
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.claude/settings.json
    source_type: secondary
    sha256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
    ingested: 2026-04-06
related:
  - claude-code-hooks
  - claude-code-skills
  - mcp-servers
  - nvim-plugins-ai
  - agent-teams
created: 2026-04-06
updated: 2026-04-06
---

# Claude Code Configuration

## Overview
Comprehensive Claude Code CLI configuration managed across multiple files. `claude/CLAUDE.md` defines agent behavior rules (evidence-first, output in Japanese, cite sources, no direct file deletion, no emojis). `settings.json` configures env vars (CLAUDE_CODE_DISABLE_AUTO_MEMORY=1, EXPERIMENTAL_AGENT_TEAMS=1), granular permissions (allow/deny lists for bash/file/MCP tools), hooks, statusline, and plugins. `rules/` directory provides enforcement rules for markdown formatting and PDF MCP tool selection. Statusline shows model/context/cost and rate limits.

## Key Facts
- Model: claude-haiku-4-5-20251001 (primary)
- Env vars: CLAUDE_CODE_DISABLE_AUTO_MEMORY=1, EXPERIMENTAL_AGENT_TEAMS=1
- Permissions: 200+ allowed bash patterns, deny-list for rm -rf, chmod 777, publish, system edits
- Rules: markdown.md (no bold, vertical mermaid, single-line nodes, <br> breaks), pdf-mcp.md (tool selection decision tree)
- Statusline: 3-line display with model/context/cost, 5h/7d rate limits; TZ: Asia/Tokyo
- Keybindings: Ctrl+B (left pane), Ctrl+Shift+B (task background)
- CLAUDE.md behavior: evidence-first, Agent Teams over subagents, output in Japanese, cite sources/file locations
- Sandbox: disabled but allowedDomains configurable
- Plugins: clangd-lsp, gopls-lsp, lua-lsp, typescript-lsp, slack, llmwiki (ktrysmt)
- settings.local.json: environment-specific overrides (devcontainer HOST_DIR)

## Relations
- [[claude-code-hooks]] -- Hook system for session lifecycle events
- [[claude-code-skills]] -- Custom skill templates for agent workflows
- [[mcp-servers]] -- MCP server registry (.mcp.json)
- [[nvim-plugins-ai]] -- Claude Code integration in Neovim
- [[agent-teams]] -- Agent Teams enabled via env var

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | claude/CLAUDE.md | primary |
| 2026-04-06 | claude/settings.json | primary |
| 2026-04-06 | claude/settings.local.json | secondary |
| 2026-04-06 | claude/keybindings.json | primary |
| 2026-04-06 | claude/rules/markdown.md | primary |
| 2026-04-06 | claude/rules/pdf-mcp.md | primary |
| 2026-04-06 | claude/statusline-command.sh | primary |
| 2026-04-06 | claude/README.md | secondary |
| 2026-04-06 | .claude/CLAUDE.md | primary |
| 2026-04-06 | .claude/settings.json | secondary |

## Changelog
- 2026-04-06: Initial creation from 10 Claude Code configuration files
