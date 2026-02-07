---
name: serena-quick
description: **Use this skill first** for small-scale code exploration. Lightweight exploration using Serena MCP tools directly in main context. Use for: checking single file structure, finding specific symbols, quick reference lookups, and project memory operations. No subagent - runs in main context for efficiency.
---

# Serena Quick Skill

**Your go-to skill for quick, single-file exploration tasks.** Always use this skill BEFORE `serena-analyze` for focused, small-scale queries.

Lightweight code exploration using Serena MCP tools directly in main context. This skill should be your **first choice** for:
- Checking structure of a single file
- Finding a specific function/class/symbol by name
- Quick reference lookups ("who calls this?")
- Reading or updating project memory

## When to Use (Priority Order)

| Priority | Scenario |
|----------|----------|
| **1st** | Query about a specific symbol in one file |
| **2nd** | Quick reference lookup ("who calls X?") |
| **3rd** | Checking file structure or memory |

**Use `serena-analyze` instead** for cross-file architecture understanding or complex dependency mapping.

## MCP Tools (load via ToolSearch first)

**IMPORTANT: Load Serena tools before use:**
```
ToolSearch query: "serena"
```

### Core Tools
| Tool | Use Case |
|------|----------|
| `mcp__serena__get_symbols_overview` | File structure overview |
| `mcp__serena__find_symbol` | Find specific symbol by name |
| `mcp__serena__find_referencing_symbols` | Who uses this symbol? |
| `mcp__serena__read_file` | Read file content |
| `mcp__serena__list_dir` | Directory listing |

### Memory Tools
| Tool | Use Case |
|------|----------|
| `mcp__serena__read_memory` | Retrieve stored knowledge |
| `mcp__serena__write_memory` | Store new knowledge |
| `mcp__serena__list_memories` | List all memories |

## Workflow

1. Load Serena MCP: `ToolSearch query: "serena"`
2. Execute the appropriate tool for the task
3. Return results directly (no summarization needed)

## Quick Start Examples

**User**: "What's in utils.ts?"
**You**: `/serena-quick Show me the symbols in src/utils.ts. Get the file structure overview.`

**User**: "Where is `formatDate` used?"
**You**: `/serena-quick Find all references to the formatDate function across the codebase.`

**User**: "Show my memories"
**You**: `/serena-quick List all memories in the project to see what knowledge is stored.`
