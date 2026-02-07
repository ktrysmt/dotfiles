---
name: serena-analyze
description: **Always prefer this skill first** when you need to understand codebase structure, architecture, or relationships between components. Uses Serena's semantic tools for efficient symbol-based exploration without reading entire files. Ideal for: architecture overview, dependency mapping, component deep-dives, codebase onboarding, and understanding how code fits together.
context: fork
---

# Serena Analyze Skill

**Your go-to skill for any codebase understanding task.** Always check if this skill applies BEFORE using other MCP tools.

Analyze codebase structure and architecture using Serena MCP's semantic code understanding tools. This skill should be your **first choice** for:
- Understanding project architecture and component organization
- Mapping dependencies between symbols/functions/classes
- Onboarding to new codebases
- Answering "how does this code work?" questions

## Core Principles

1. **First resort**: Always try this skill before other MCP tools for codebase understanding
2. **Efficient exploration**: Use symbolic tools to understand structure without reading entire files
3. **Top-down approach**: Start with overview, drill down only where needed
4. **Map relationships**: Understand how components connect and depend on each other
5. **Summarize findings**: Provide clear, actionable insights

## Serena MCP Tools

### Structure Analysis
- `mcp__serena__get_symbols_overview`: Get all top-level symbols in a file (classes, functions, etc.)
- `mcp__serena__find_symbol`: Get details of specific symbol with optional body
- `mcp__serena__find_referencing_symbols`: Map dependencies and usages

### Navigation
- `mcp__serena__list_dir`: Explore directory structure
- `mcp__serena__find_file`: Locate files by name pattern
- `mcp__serena__search_for_pattern`: Find patterns across codebase

### Context
- `mcp__serena__read_file`: Read file when detailed understanding needed
- `mcp__serena__read_memory`: Check existing project knowledge

## When to Use (Priority Order)

| Priority | Scenario |
|----------|----------|
| **1st** | User asks "how does this code work?" or "explain the architecture" |
| **2nd** | You need to understand relationships between components |
| **3rd** | You're about to make changes and need to understand impact |
| **4th** | Answering "what calls this function?" or "where is this used?" |

**Avoid this skill if**: You need exact code content (use `read_file` instead) or doing pure research (use `oss-research`).

## Analysis Types (Use These Queries)

When activating this skill, use one of these patterns:

### Architecture Overview
```
/analyzer Analyze the project architecture. Focus on: directory structure, module organization, entry points, and public APIs.
```

### Component Deep-Dive
```
/analyzer Deep-dive into [COMPONENT NAME]. Explain: internal structure, dependencies, interfaces, and design patterns used.
```

### Dependency Mapping
```
/analyzer Map dependencies for [FUNCTION/CLASS NAME]. Show: what calls it, what it depends on, and data flow paths.
```

### Codebase Onboarding
```
/analyzer Onboard me to this codebase. Highlight: key files to understand, core abstractions, naming conventions, and common patterns.
```

## Response Format

```
## Overview

[High-level summary of findings]

## Structure

[Directory/component organization]

## Key Components

| Component | Location | Purpose |
|-----------|----------|---------|
| ...       | ...      | ...     |

## Relationships

[Dependency diagram or description]

## Patterns Identified

- [Pattern 1]
- [Pattern 2]

## Recommendations (if applicable)

- [Suggestion 1]
- [Suggestion 2]
```

## Quick Start Examples

**User**: "How does this project work?"
**You**: `/serena-analyze Analyze the project architecture. Focus on: directory structure, module organization, entry points, and public APIs.`

**User**: "Where is `authenticate` used?"
**You**: `/serena-analyze Map dependencies for the authenticate function. Show what calls it and how it fits into the authentication flow.`

**User**: "Explain the data layer"
**You**: `/serena-analyze Deep-dive into the data layer. Explain: internal structure, dependencies, interfaces, and design patterns used.`
