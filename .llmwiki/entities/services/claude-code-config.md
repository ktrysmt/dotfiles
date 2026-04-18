---
entity: claude-code-config
category: services
sources:
  - path: /Users/dew/dotfiles/claude/CLAUDE.md
    source_type: primary
    sha256: fecd6155e672c42135cc370e566e96b74a1965ec3a582d193852a78c04bac80c
    ingested: 2026-04-18
  - path: /Users/dew/dotfiles/claude/settings.json
    source_type: primary
    sha256: 04ed7a7cf44919215872240b03c7f0eb590ca04bb7ea43974940ec31f82e291c
    ingested: 2026-04-18
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
    sha256: 0a5df5b054c8ebec8d5a7b2e4ece6cf09f37c78408466f9b5ba98a50f1c1da27
    ingested: 2026-04-18
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
    sha256: 2b5295cac73aefa31ba64d8ea58468be0d7c8f104e9fb47e4250928c61abc7ec
    ingested: 2026-04-18
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
  - dotfiles-install
created: 2026-04-06
updated: 2026-04-18
---

# Claude Code Configuration

## Overview
Comprehensive Claude Code CLI configuration managed across multiple files. `claude/CLAUDE.md` defines agent behavior rules (evidence-first, output language by audience with human-facing Japanese and LLM-facing English, cite sources and file locations, no direct file deletion, no emojis, ask before delegating, follow PR/Issue templates). `settings.json` configures env vars (CLAUDE_CODE_DISABLE_AUTO_MEMORY=1, EXPERIMENTAL_AGENT_TEAMS=1), granular permissions (allow/deny lists for bash/file/MCP tools), hooks, statusline, and plugins. `rules/` directory provides enforcement rules for markdown formatting and PDF MCP tool selection. Statusline shows model/context/cost and rate limits.

## Key Facts
- Env vars: CLAUDE_CODE_DISABLE_AUTO_MEMORY=1, CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 [source: settings.json, primary, 2026-04-18]
- Permissions: 200+ allowed bash patterns, deny-list for rm -rf, chmod 777, publish, system edits
- Rules: markdown.md (no bold, vertical mermaid, single-line nodes, <br> breaks), pdf-mcp.md (tool selection decision tree)
- markdown.md applies to paths matching `**/*.md` via frontmatter; bans bold `**...**` in favor of headings or plain text [source: markdown.md, primary, 2026-04-18]
- Statusline: 3-line display with model/context/cost, 5h/7d rate limits; TZ: Asia/Tokyo
- Keybindings: Ctrl+B (left pane), Ctrl+Shift+B (task background)
- CLAUDE.md behavior: evidence-first, Agent Teams over subagents, thinking in English regardless of output, cite sources and file locations, ask before delegating when tool/action/output ambiguous, follow PR/Issue templates [source: CLAUDE.md, primary, 2026-04-18]
- Output language policy: human-facing output in Japanese; LLM-facing artifacts (rules, prompts, agent instructions, CLAUDE.md, skill definitions) in English; code and identifiers in English [source: CLAUDE.md, primary, 2026-04-18]
- Japanese style: 体言止め + 敬語を排した簡潔な文体 [source: CLAUDE.md, primary, 2026-04-18]
- Never: delete files directly (present command to user), assert unverified facts, hardcode secrets, commit when tests/lint failing, push directly to main/master, use emojis, install tools/packages/runtimes directly (present command to user) [source: CLAUDE.md, primary, 2026-04-18]
- Sandbox: disabled but allowedDomains configurable (mise.jdx.dev, github.com, api.github.com, *.github.com, *.githubusercontent.com) [source: settings.json, primary, 2026-04-18]
- Plugins: clangd-lsp, gopls-lsp, lua-lsp, typescript-lsp (enabled); slack (disabled); llmwiki (ktrysmt, enabled) [source: settings.json, primary, 2026-04-18]
- Extra knownMarketplaces: claude-plugins-official (github anthropics/claude-plugins-official), ktrysmt (git https://github.com/ktrysmt/claude-plugins.git) [source: settings.json, primary, 2026-04-18]
- Global flags: alwaysThinkingEnabled=true, effortLevel=high, skipDangerousModePermissionPrompt=true, defaultMode=bypassPermissions [source: settings.json, primary, 2026-04-18]
- settings.local.json: environment-specific overrides (devcontainer HOST_DIR)

## Relations
- [[claude-code-hooks]] -- Hook system for session lifecycle events
- [[claude-code-skills]] -- Custom skill templates for agent workflows
- [[mcp-servers]] -- MCP server registry (.mcp.json)
- [[nvim-plugins-ai]] -- Claude Code integration in Neovim
- [[agent-teams]] -- Agent Teams enabled via env var
- [[dotfiles-install]] -- update.sh step_claude keeps enabled Claude plugins current

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-18 | claude/CLAUDE.md | primary |
| 2026-04-18 | claude/settings.json | primary |
| 2026-04-06 | claude/settings.local.json | secondary |
| 2026-04-06 | claude/keybindings.json | primary |
| 2026-04-18 | claude/rules/markdown.md | primary |
| 2026-04-06 | claude/rules/pdf-mcp.md | primary |
| 2026-04-06 | claude/statusline-command.sh | primary |
| 2026-04-18 | claude/README.md | secondary |
| 2026-04-06 | .claude/CLAUDE.md | primary |
| 2026-04-06 | .claude/settings.json | secondary |

## Changelog
- 2026-04-06: Initial creation from 10 Claude Code configuration files
- 2026-04-18: Updated CLAUDE.md (expanded output-language-by-audience rule, Japanese style rule, delegation checklist, PR/Issue template rule, unverified-claim prohibition, direct-install prohibition); settings.json dropped explicit `model` field and added llmwiki@ktrysmt plugin plus extraKnownMarketplaces; markdown.md added mermaid-node single-line constraint and bold ban; README.md revised (temporal update)
