---
name: serena-refactor
description: **Use this skill first** for any refactoring tasks. Performs large-scale, symbol-aware refactoring using Serena's semantic code tools. Use for: renaming functions/classes/methods across codebase, updating signatures, extracting/moving symbols, and ensuring ALL references are updated consistently.
context: fork
---

# Serena Refactor Skill

**Your go-to skill for any refactoring task.** Always use this skill BEFORE manual editing for code modifications that affect multiple locations.

Perform large-scale, symbol-aware refactoring using Serena MCP's semantic code tools. This skill should be your **first choice** for:
- Renaming functions, classes, methods, or variables across the codebase
- Updating function signatures and all call sites
- Extracting code into new functions/classes
- Moving symbols between files/modules
- Any change where consistency across references matters

## Core Principles

1. **First resort**: Always use this skill for multi-location changes BEFORE manual editing
2. **Understand before changing**: Use `find_symbol` and `get_symbols_overview` to understand the current structure
3. **Track all references**: Use `find_referencing_symbols` to find all usages before making changes
4. **Atomic operations**: Use symbol-based editing for precise, structure-aware modifications
5. **Verify completeness**: Ensure all references are updated after refactoring

## Serena MCP Tools

### Analysis Tools
- `mcp__serena__get_symbols_overview`: Get top-level symbols in a file
- `mcp__serena__find_symbol`: Find symbol by name path with optional body
- `mcp__serena__find_referencing_symbols`: Find all references to a symbol

### Editing Tools
- `mcp__serena__replace_symbol_body`: Replace entire symbol body
- `mcp__serena__insert_after_symbol`: Insert code after a symbol
- `mcp__serena__insert_before_symbol`: Insert code before a symbol
- `mcp__serena__replace_regex`: Regex-based replacement for smaller edits

### Support Tools
- `mcp__serena__search_for_pattern`: Find patterns across codebase
- `mcp__serena__list_dir`: Explore directory structure
- `mcp__serena__read_file`: Read file contents when needed

## Refactoring Workflow

1. **Identify target**: Find the symbol to refactor using `find_symbol`
2. **Map dependencies**: Use `find_referencing_symbols` to find all usages
3. **Plan changes**: Determine all files and locations that need updates
4. **Execute refactoring**:
   - Use `replace_symbol_body` for the main symbol
   - Use `replace_regex` for reference updates
5. **Verify**: Confirm all references are updated

## Supported Refactoring Types

- **Rename**: Function, class, method, variable renaming with reference updates
- **Signature change**: Update parameters/return types and all call sites
- **Extract**: Pull code into new function/class
- **Move**: Relocate symbol to different file/module
- **Inline**: Replace function calls with function body

## Response Format

```
## Refactoring Plan

- Target: [symbol name and location]
- Type: [rename/signature/extract/move/inline]
- Affected files: [list of files]
- References found: [count]

## Changes Made

1. [Change 1]
2. [Change 2]
...

## Verification

- [Status of verification]
```

## Quick Start Examples

**User**: "Rename `authenticate` to `validate_credentials`"
**You**: `/serena-refactor Rename the authenticate function to validate_credentials. Find all references and update them consistently.`

**User**: "Add logging to all API handlers"
**You**: `/serena-refactor Add logging to all API handler functions. Find all handler symbols and insert logging at the start of each.`

**User**: "Move utils to shared package"
**You**: `/serena-refactor Move all utility functions from src/utils to shared/utils. Update all imports across the codebase.`
