# Claude Code Global Config

- **IMPORTANT: Always use MCP and Skills/Agents for any analysis and any tasks as much as possible.**
- **ALWAYS check for a matching skill BEFORE calling MCP directly.**

## NEVER
- Delete prod data without confirmation
- Hardcode secrets
- Commit with failing tests/lint
- Push directly to main

## MUST
- Write tests for new features/fixes
- Run CI before completion
- Document breaking changes
- Use feature branches
