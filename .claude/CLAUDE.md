# Claude Code Global Config

## MCP Usage (Required)

**IMPORTANT: MCP tools are lazy-loaded. Use `ToolSearch` to load them BEFORE use.**

### MCP Call Strategy: Skills First

**Heavy MCPs (aws-docs, deepwiki, etc.) produce large responses that bloat context.**

**ALWAYS check for a matching skill BEFORE calling MCP directly:**

| Task | Skill (preferred) | Direct MCP (small-scale only) |
|------|-------------------|-------------------------------|
| AWS research/development | `/aws-expert` | Only for single quick lookup |
| OSS/library research | `/oss-research` | Only for single quick lookup |
| Large-scale refactoring | `/serena-refactor` | - |
| Codebase analysis | `/serena-analyze` | - |
| Quick symbol lookup | `/serena-quick` | `get_symbols_overview`, `find_symbol` |
| Memory management | `/serena-memory` | `read_memory`, `write_memory` |

### Why Skills First?

1. **Context isolation**: Skills with `context: fork` run in subagent
2. **No bloat**: MCP responses stay in subagent, only summary returns
3. **Long tasks**: Research tasks take time; subagent handles autonomously

### Direct MCP: When Acceptable

- Single, quick lookup (1-2 tool calls)
- Small response expected
- Need conversation context for follow-up

### MCP Reference

| Task | MCP | ToolSearch Query |
|------|-----|------------------|
| General search | gemini-google-search | `select:mcp__gemini-google-search__google_search` |
| AWS docs | aws-docs | `aws-docs` |
| OSS/library docs | deepwiki | `deepwiki` |
| Code symbols | serena | `serena` |

**Never guess without MCP verification.**

## Language Rules

### Rust
- Package: `cargo` only
- Error: `Result<T,E>` + `?`, no `.unwrap()` in prod
- Quality: `cargo fmt && cargo clippy -- -D warnings && cargo test`

### Go
- Package: `go mod`
- Error: Always check, use `errors.Is/As`
- Quality: `go fmt ./... && golangci-lint run && go test -race ./...`

### TypeScript
- Package: `pnpm` > `npm` > `yarn`
- Type: `strict: true`, no `any` in prod
- Quality: `prettier --write . && eslint . --fix && tsc --noEmit`

### Python
- Package: **ONLY `uv`**, NEVER `pip`
- Type hints required
- Quality: `uv run --frozen ruff format . && ruff check . --fix && pytest`

### Bash
- Shebang: `#!/usr/bin/env bash`
- Options: `set -euo pipefail`
- Quote all variables: `"${var}"`

## NEVER
- Delete prod data without confirmation
- Hardcode secrets
- Commit with failing tests/lint
- Push directly to main
- `.unwrap()` in Rust prod
- Ignore Go errors
- `any` in TS prod
- `pip install`

## MUST
- Write tests for new features/fixes
- Run CI before completion
- Document breaking changes
- Use feature branches

## Git
- Conventional commits: `feat(scope): message`
