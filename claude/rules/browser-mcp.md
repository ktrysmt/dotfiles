# Browser MCP Tool Usage

Do NOT use claude-in-chrome MCP tools (`mcp__claude-in-chrome__*`) on your own initiative.

These tools may only be used when:
- The user's message explicitly contains a URL (https:// or http://)
- The user explicitly asks to interact with a browser or web page
- The agent-browser skill is invoked

Never speculatively open browser tabs, navigate to pages, or read page content without one of the above conditions being met.
