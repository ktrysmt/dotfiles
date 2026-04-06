---
entity: mcp-servers
category: services
sources:
  - path: /Users/dew/dotfiles/claude/.mcp.json
    source_type: primary
    sha256: 186beb42c2b7fa82e88187b3f2315ff3ae26eb5dc64f3ba43073f984f7fe885c
    ingested: 2026-04-06
related:
  - claude-code-config
created: 2026-04-06
updated: 2026-04-06
---

# MCP Servers

## Overview
Model Context Protocol (MCP) server registry configured in `.mcp.json`. Includes both HTTP-based services (aws-docs, deepwiki, grep-github) and local command-based servers (arxiv, playwright, pdf-mcp, pdf-docling, gemini-cli, mcp-think-as, serena, o3-search, context7). Servers provide specialized capabilities for documentation lookup, code search, PDF processing, browser automation, and AI reasoning.

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

## Relations
- [[claude-code-config]] -- MCP servers configured alongside Claude Code settings

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | claude/.mcp.json | primary |

## Changelog
- 2026-04-06: Initial creation from .mcp.json
