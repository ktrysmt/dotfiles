```sh
claude mcp add -s user aws-docs -- uvx awslabs.aws-documentation-mcp-server@latest
claude mcp add -s user gemini-cli -e GEMINI_API_KEY="" -- npx @choplin/mcp-gemini-cli --allow-npx
claude mcp add -s user deepwiki -- npx -y mcp-deepwiki@latest
claude mcp add -s user mcp-think-as -- uv --directory "" run main.py
claude mcp add -s user serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --enable-web-dashboard=false

claude mcp add -s user o3-search -- npx o3-search-mcp

claude mcp add -s project context7  -- npx -y @upstash/context7-mcp
claude mcp add -s project arxiv-mcp-server -- uvx arxiv-mcp-server
claude mcp add -s project playwright -- npx -y @playwright/mcp@latest
```
