```sh
claude mcp add -s user -t http aws-docs https://knowledge-mcp.global.api.aws
claude mcp add -s user codex codex mcp
claude mcp add -s user deepwiki -- npx -y mcp-deepwiki@latest
claude mcp add -s user mcp-think-as -- uv --directory "" run main.py
claude mcp add -s user serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --enable-web-dashboard=false
claude mcp add -s user gemini-google-search -e GEMINI_API_KEY="" -e GEMINI_MODEL="gemini-2.5-flash" -- npx mcp-gemini-google-search

claude mcp add -s project context7  -- npx -y @upstash/context7-mcp
claude mcp add -s project arxiv-mcp-server -- uvx arxiv-mcp-server
claude mcp add -s project playwright -- npx -y @playwright/mcp@latest

```
