```sh
# user
claude mcp add -s user -t http aws-docs https://knowledge-mcp.global.api.aws
claude mcp add -s user -t http deepwiki https://mcp.deepwiki.com/mcp
claude mcp add -s user mcp-think-as -- uv --directory "" run main.py
claude mcp add -s user serena -- uvx --from git+https://github.com/oraios/serena@d5f90710676b6a7cacc450f59005b4934c49b6db serena start-mcp-server --enable-web-dashboard=false
claude mcp add -s user gemini-google-search -e GEMINI_API_KEY="" -e GEMINI_MODEL="gemini-2.5-flash" -- npx mcp-gemini-google-search@0.1.1
claude mcp add -s user context7  -- npx -y @upstash/context7-mcp@1.0.21

# project
claude mcp add -s project arxiv-mcp-server -- uvx --from git+https://github.com/blazickjp/arxiv-mcp-server.git@057e2000be7b56823239815b0fe7c7fc0dbced96 arxiv-mcp-server
claude mcp add -s project playwright -- npx -y @playwright/mcp@0.0.43

```

Or, add arxiv mcp with docker.
```json
{
  "mcpServers": {
    "arxiv-mcp-server": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "ARXIV_STORAGE_PATH",
        "-v",
        "/local-directory:/local-directory",
        "mcp/arxiv-mcp-server"
      ],
      "env": {
        "ARXIV_STORAGE_PATH": "/Users/local-test/papers"
      }
    }
  }
}
```

hooks
```json
  "hooks": {
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/session_summarizer_wrapper.sh",
            "timeout": 5
          }
        ]
      }
    ]
  },
```
