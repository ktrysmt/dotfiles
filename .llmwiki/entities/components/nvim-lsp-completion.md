---
entity: nvim-lsp-completion
category: components
sources:
  - path: /Users/dew/dotfiles/nvim/lua/plugins/nvim-lspconfig.lua
    source_type: primary
    sha256: 3270d025464c036b6d0a47043b12b9cf93c014fad8dcd91d5df8ebe1c4eb6d5a
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/nvim-treesitter.lua
    source_type: primary
    sha256: 35c986b185b087096dccfbc1cc705f3e9c47e0ec21235ed709ec4af681e88dff
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/nvim-cmp.lua
    source_type: primary
    sha256: 20806b3b8b2ab4bac732328c2dd2252f92a16b1bcc1616572f24fa41e8748122
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/typescript-tools.lua
    source_type: primary
    sha256: cfe94a0b0e17bca84ab437428138da671ed562f368c69e97cc09ad30487fcb23
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/nvim-lsp-file-operations.lua
    source_type: secondary
    sha256: fd3b198695f7400dced61c7bf3e64a898205b7cd2d940df1f7018e50081c31f2
    ingested: 2026-04-06
related:
  - neovim-editor
  - nvim-plugins-editing
  - nvim-plugins-ai
created: 2026-04-06
updated: 2026-04-06
---

# Neovim LSP and Completion

## Overview
Language Server Protocol (LSP), Tree-sitter, and autocompletion configuration. nvim-lspconfig manages 13 language servers via mason-lspconfig. Tree-sitter provides incremental parsing with textobjects, textsubjects, and matchup support for 20+ languages. nvim-cmp is the completion engine with sources from LSP, snippets (vsnip), buffer, path, signature help, and calculator.

## Key Facts
- Language servers: bashls, clangd, cssls, dockerls, gopls, lua_ls, pylsp, rust_analyzer, svelte, typos_lsp, vimls, yamlls, jsonls
- Tree-sitter: installed for Go, Rust, Python, TypeScript, Lua, and 15+ other languages
- Tree-sitter features: textobjects (select), textsubjects (smart selection), matchup (bracket/tag matching)
- Completion sources: cmp-nvim-lsp, vsnip, cmp-buffer, cmp-path, cmp-calc, cmp-nvim-lsp-signature-help
- Completion trigger: insert mode, cmdline, cmdwin entry
- typescript-tools: enhanced TypeScript LSP with styled-components support
- nvim-lsp-file-operations: LSP-aware file rename/move
- Echo diagnostics: auto-display on cursor hold with source info

## Relations
- [[neovim-editor]] -- Core editor configuration
- [[nvim-plugins-editing]] -- Formatting and linting use LSP
- [[nvim-plugins-ai]] -- Cody completion source in nvim-cmp

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | nvim/lua/plugins/nvim-lspconfig.lua | primary |
| 2026-04-06 | nvim/lua/plugins/nvim-treesitter.lua | primary |
| 2026-04-06 | nvim/lua/plugins/nvim-cmp.lua | primary |
| 2026-04-06 | nvim/lua/plugins/typescript-tools.lua | primary |
| 2026-04-06 | nvim/lua/plugins/nvim-lsp-file-operations.lua | secondary |

## Changelog
- 2026-04-06: Initial creation from 5 LSP/completion plugin files
