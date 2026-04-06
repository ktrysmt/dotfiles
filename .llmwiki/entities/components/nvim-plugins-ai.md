---
entity: nvim-plugins-ai
category: components
sources:
  - path: /Users/dew/dotfiles/nvim/lua/plugins/llm.claudecode.lua
    source_type: primary
    sha256: 4f7207a9055a2d404e9e51ec4b51a06504546d7be0e598d09bd3a81c39974f5f
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/llm.copilot.lua
    source_type: primary
    sha256: c85a9130201f9fe6c916806d49c09b1ce6216935534d2857b54753a008444c6e
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/llm.avante.lua_bk
    source_type: secondary
    sha256: db08b29a5bb72c3df3e0e19fa5c74dd192ec7b3781e1bd13dd7340d7b92ba9dd
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/llm.gemini.lua_bk
    source_type: secondary
    sha256: 800cc733c5e6a50bbe09612d55286e3c3c69d7e036e28129a3d60f1c68379a0b
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/llm.sg.lua_bk
    source_type: secondary
    sha256: 725d535e30afc4b37722f1151089450d259ef66f7ceef9ef4873d4cfd1c95e1b
    ingested: 2026-04-06
related:
  - neovim-editor
  - nvim-lsp-completion
  - claude-code-config
created: 2026-04-06
updated: 2026-04-06
---

# Neovim AI/LLM Plugins

## Overview
AI-powered code assistance in Neovim. Active plugins: Claude Code integration (claudecode.nvim) and GitHub Copilot. Disabled plugins: Avante, Gemini, and Sourcegraph Cody. Claude Code runs via Coder with port range 10000-65535, supporting fallback to Ollama or OpenRouter. Copilot provides auto-triggered suggestions with S-Tab to accept.

## Key Facts
- claudecode: port 10000-65535; auto-start; right terminal split (33% width); diff accept on Tab
- claudecode keybindings: <leader>cc (toggle), <leader>ca (add/send), <leader>cf (focus), <leader>cda (accept diff), <leader>cdd (deny diff)
- copilot: auto-trigger; S-Tab (accept), S-M-n (accept word); enabled for all filetypes except text/markdown
- avante (DISABLED): alternative AI assistant
- gemini (DISABLED): Google Gemini API integration
- sourcegraph/cody (DISABLED): Sourcegraph code intelligence

## Relations
- [[neovim-editor]] -- Core editor providing keymaps and UI
- [[nvim-lsp-completion]] -- Cody completion source integrated in nvim-cmp
- [[claude-code-config]] -- Claude Code service configuration

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | nvim/lua/plugins/llm.claudecode.lua | primary |
| 2026-04-06 | nvim/lua/plugins/llm.copilot.lua | primary |
| 2026-04-06 | nvim/lua/plugins/llm.avante.lua_bk | secondary |
| 2026-04-06 | nvim/lua/plugins/llm.gemini.lua_bk | secondary |
| 2026-04-06 | nvim/lua/plugins/llm.sg.lua_bk | secondary |

## Changelog
- 2026-04-06: Initial creation from 5 AI/LLM plugin files (2 active, 3 disabled)
