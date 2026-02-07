---
name: serena-memory
description: **Use this skill first** for managing project knowledge. Stores design decisions, coding conventions, learned patterns, and project-specific context that persists across sessions. Use for: storing knowledge, retrieving memories, listing all memories, and cleaning up outdated content.
---

# Serena Memory Skill

**Your go-to skill for persisting project knowledge.** Always use this skill to store information that should persist across sessions.

Manage persistent project knowledge using Serena MCP's memory system. This skill should be your **first choice** for:
- Storing design decisions (ADRs) and architecture context
- Recording coding conventions and patterns
- Saving project-specific terminology and business context
- Tracking technical debt and future improvements
- Any knowledge that future Claude sessions should know

## Core Principles

1. **First resort**: Always use this skill to persist knowledge across sessions
2. **Structured storage**: Organize memories by category for easy retrieval
3. **Actionable content**: Store information that helps future development
4. **Keep current**: Update memories when decisions change
5. **Clean regularly**: Remove outdated or redundant memories

## Serena MCP Tools

### Memory Operations
- `mcp__serena__write_memory`: Create or update a memory
- `mcp__serena__read_memory`: Retrieve specific memory content
- `mcp__serena__list_memories`: List all available memories
- `mcp__serena__delete_memory`: Remove outdated memories

### Context Tools
- `mcp__serena__read_file`: Read code for context when needed
- `mcp__serena__get_symbols_overview`: Understand code structure
- `mcp__serena__search_for_pattern`: Find relevant code patterns

## Memory Categories

### Architecture Decisions (ADR)
- Technology choices and rationale
- Pattern selections
- Trade-off analyses
- Rejected alternatives

### Coding Conventions
- Naming patterns
- File organization rules
- Error handling patterns
- Testing conventions

### Project Context
- Business domain concepts
- Key terminology
- Stakeholder requirements
- Known constraints

### Learned Patterns
- Common code patterns in this project
- Gotchas and pitfalls
- Performance considerations
- Security requirements

### Task History
- Completed refactorings
- Migration status
- Technical debt items
- Future improvement ideas

## Memory Naming Convention

Use structured names for easy discovery:

```
adr/[topic]           - Architecture decisions
conventions/[area]    - Coding standards
context/[domain]      - Business context
patterns/[name]       - Code patterns
tasks/[status]/[name] - Task tracking
```

## Operations

### Store New Knowledge
```
1. Determine category
2. Choose descriptive name
3. Write structured content
4. Verify with list_memories
```

### Retrieve Knowledge
```
1. list_memories to find relevant items
2. read_memory for specific content
3. Apply to current task
```

### Update Knowledge
```
1. read_memory current content
2. Modify as needed
3. write_memory with updated content
```

### Cleanup
```
1. list_memories to review all
2. Identify outdated items
3. delete_memory for each
```

## Response Format

```
## Operation: [store/retrieve/update/cleanup]

### Action Taken

[Description of what was done]

### Memory Content

[Content stored/retrieved if applicable]

### Current Memories

| Name | Category | Summary |
|------|----------|---------|
| ...  | ...      | ...     |
```

## Quick Start Examples

**User**: "Record that we use Pydantic for validation"
**You**: `/serena-memory Store the following in conventions/validation: "Pydantic is the primary validation library for this project. Use Pydantic models for data validation at API boundaries and for configuration schemas."`

**User**: "What do we know about the auth system?"
**You**: `/serena-memory List all memories in context/auth and adr/auth categories to understand the authentication architecture and decisions.`

**User**: "Clean up old memories"
**You**: `/serena-memory Review all memories and identify outdated items for cleanup. List memories by category first.`
