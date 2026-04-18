---
entity: mcp-servers
category: services
sources:
  - path: /Users/dew/dotfiles/claude/.mcp.json
    source_type: primary
    sha256: 186beb42c2b7fa82e88187b3f2315ff3ae26eb5dc64f3ba43073f984f7fe885c
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.mcp.json
    source_type: primary
    sha256: a960cac1d0435cd034f7456f66cd3452afa40215b0138c5c8e088f80b850979d
    ingested: 2026-04-18
related:
  - claude-code-config
  - claude-code-skills
created: 2026-04-06
updated: 2026-04-18
---

# MCP Servers

## Overview
Model Context Protocol (MCP) server registry configured in `.mcp.json`. Two scopes: `claude/.mcp.json` (HTTP + command servers including aws-docs, deepwiki, grep-github, arxiv, playwright, pdf-mcp, pdf-docling, gemini-cli, mcp-think-as, serena, o3-search, context7) and repo-root `.mcp.json` (project-scoped notion HTTP MCP). Servers provide specialized capabilities for documentation lookup, code search, PDF processing, browser automation, AI reasoning, and Notion database operations.

## Key Facts
- aws-docs (HTTP): AWS documentation, regional availability, SOP retrieval; URL: https://knowledge-mcp.global.api.aws
- deepwiki (HTTP): GitHub repository documentation AI; URL: https://mcp.deepwiki.com/mcp
- grep-github (HTTP): Code search across 1M+ public GitHub repos; URL: https://mcp.grep.app
- arxiv (command): Academic paper search via uvx arxiv-mcp-server; Docker-capable
- playwright (command): Browser automation via npx @anthropic-ai/mcp-playwright
- pdf-mcp (command): Fast PDF text extraction with SQLite caching via PyMuPDF
- pdf-docling (command): Rich PDF with OCR, table extraction, markdown export (fallback)
- gemini-cli (command): Google Gemini API via @anthropic-ai/gemini-cli; requires GEMINI_API_KEY
- mcp-think-as (command): Reasoning enhancement via Python subprocess
- serena (command): Web-based MCP from oraios/serena
- o3-search (command): Search functionality via o3
- context7 (command): Upstash Context7 MCP for contextual data
- notion (HTTP, project scope): Notion official remote MCP; URL: https://mcp.notion.com/mcp; OAuth-based auth [source: .mcp.json, primary, 2026-04-18]
- Project scope: root `.mcp.json` declares per-repo MCP (notion), separate from user-scope `claude/.mcp.json` [source: .mcp.json, primary, 2026-04-18]

## Relations
- [[claude-code-config]] -- MCP servers configured alongside Claude Code settings
- [[claude-code-skills]] -- github-to-notion skill depends on notion MCP

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | claude/.mcp.json | primary |
| 2026-04-18 | .mcp.json | primary |

## Changelog
- 2026-04-06: Initial creation from .mcp.json
- 2026-04-18: Added repo-root .mcp.json (project-scoped notion HTTP MCP) as new source
