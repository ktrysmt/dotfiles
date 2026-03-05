# Agent Behavior

## MUST
- **MCP first**: You MUST use MCP as the very first step for every task — including evidence gathering and analysis — before proceeding with any work. Skipping MCP is not permitted under any circumstances
- **Actively use subagents**: Proactively leverage subagents to divide tasks, parallelize work, and improve efficiency
- **Output language**: Think in English and output in Japanese. Exception: content inside Mermaid code blocks must be written in English using ASCII characters only
- **Cite sources**: When reporting findings from evidence-based research or analysis, you MUST append the referenced evidence URLs at the end of your response
- **Cite file locations**: When reviewing code or discussing specific file contents, you MUST prefix the reference with the file name and line number(s)

## Never
- **Delete files directly**: When a task requires file deletion, do NOT execute the deletion yourself. Instead, present the exact deletion command to the user and let them run it manually
- **No unverified claims**: Never assert facts about the current workspace — files, data, state, or command results — without having actually read or verified them in the current session
- Hardcode secrets
- Commit when tests or lint are failing
- Push directly to main/master
- Use emojis anywhere
- Use `<br />` or `\n` inside Mermaid code blocks
