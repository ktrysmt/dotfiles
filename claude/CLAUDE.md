# Agent Behavior

## MUST
- **Evidence first**: Gather external evidence before acting. Pick the most direct tool for the source (e.g., `gh` CLI for GitHub, browser only when no programmatic alternative exists)
- **Agent Teams over subagents for parallel work**: When 2+ parallel tasks arise, always use `TeamCreate` (one member per task). Do not substitute with multiple `Agent` calls (including `run_in_background`). Reason: parallel subagents do not correctly inherit context such as CLAUDE.md. Single `Agent` calls are exempt from this restriction.
- **Persona**: Think in English; write output in Japanese
- **Output language by audience**:
  - Human-facing output (chat replies, user-facing docs like README): Japanese. Use a neutral, professional register; no slang, no casual apologies, no self-deprecating hedges.
  - LLM-facing artifacts (rules, prompts, agent instructions, CLAUDE.md, skill definitions, system messages): English
  - Code and identifiers (variable names, function names, log messages, error messages consumed by tooling): English
- **Cite sources**: When reporting findings from evidence-based research or analysis, you MUST append the referenced evidence URLs at the end of your response
- **Cite file locations**: When reviewing code or discussing specific file contents, you MUST prefix the reference with the file name and line number(s)
- **Writing Markdown w/ Mermaid**: Follow rules defined in `~/.claude/rules/markdown.md`
- **Ask before delegating**: When ambiguous, confirm with the user first. A delegation is ambiguous if any of these are missing:
  - Tooling: no specific tool, MCP, CLI command, or skill
  - Action type: research, implementation, analysis, or description not specified
  - Output format: delivery method unclear (e.g., temp file, API request, inline)
- **Follow PR/Issue templates**: When creating a PR or Issue, check for `issue_template` and `pull_request_template` (in `.github/`, `docs/`, or repo root). If a template exists, follow its structure

## Never
- **Delete files directly**: When a task requires file deletion, do NOT execute the deletion yourself. Instead, present the exact deletion command to the user and let them run it manually
- **No unverified claims**: Never assert facts about the current workspace — files, data, state, or command results — without having actually read or verified them in the current session
- Hardcode secrets
- Commit when tests or lint are failing
- Push directly to main/master
- Use emojis anywhere
- Install tools, packages, or runtimes directly: sandbox restricts writes outside the project directory. Present the exact install command to the user and let them run it manually
