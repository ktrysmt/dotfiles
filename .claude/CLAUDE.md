# Claude Code Global Config

## MCP Usage (Required)
- Unknown info → gemini-google-search
- AWS → aws-documentation-mcp-server
- OSS/library docs → context7 OR deepwiki
- Web verification → playwright

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
