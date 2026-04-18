---
entity: nvim-lsp-completion
category: components
sources:
  - path: /Users/dew/dotfiles/nvim/lua/plugins/nvim-lspconfig.lua
    source_type: primary
    sha256: 0ab0de4f5c133ed1d068dbc8ea904d2ac34a3c478459e67f2b3a3c5a407db813
    ingested: 2026-04-18
  - path: /Users/dew/dotfiles/nvim/lua/plugins/nvim-treesitter.lua
    source_type: primary
    sha256: c08f464944888c13cad25434cc86f36eb4e720d8666410e2f14de8daedd93798
    ingested: 2026-04-18
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
updated: 2026-04-18
---

# Neovim LSP and Completion

## Overview
Language Server Protocol (LSP), Tree-sitter, and autocompletion configuration. nvim-lspconfig manages 13 language servers via mason-lspconfig. Tree-sitter provides incremental parsing with textobjects, textsubjects, and matchup support for 20+ languages. nvim-cmp is the completion engine with sources from LSP, snippets (vsnip), buffer, path, signature help, and calculator.

## Key Facts
- Language servers: bashls, clangd, cssls, dockerls, gopls, lua_ls, pylsp, rust_analyzer, svelte, typos_lsp, vimls, yamlls, jsonls
- LSP config API: migrated to `vim.lsp.config('<name>', {...})` + `vim.lsp.enable('<name>')` for per-server settings; `vim.lsp.enable(all_servers)` enables the rest [source: nvim-lspconfig.lua, primary, 2026-04-18]
- pylsp settings: pycodestyle ignore={E501, E241, E704}, maxLineLength=200 [source: nvim-lspconfig.lua, primary, 2026-04-18]
- gopls settings: staticcheck=true, analyses.ST1000=false [source: nvim-lspconfig.lua, primary, 2026-04-18]
- lua_ls settings: diagnostics.globals=['vim'] [source: nvim-lspconfig.lua, primary, 2026-04-18]
- Diagnostic config: virtual_text=false, float=false, severity_sort=true; `gn`/`gp` (next/prev), `I` (open float), `gD` (declaration -> hover), `gv` (vsplit definition via custom on_list + cfirst), `gd` (definition), `gi` (implementation), `grn` (rename), `gca` (code action), `gr` (references) [source: nvim-lspconfig.lua, primary, 2026-04-18]
- Float preview: `vim.lsp.util.open_floating_preview` monkey-patched to default `border='rounded'` [source: nvim-lspconfig.lua, primary, 2026-04-18]
- LSP highlight groups (@lsp.*) cleared at LspAttach to keep custom colorscheme [source: nvim-lspconfig.lua, primary, 2026-04-18]
- mason.nvim: cmd-lazy-loaded; build=":MasonUpdate"; UI check_outdated_packages_on_open=true; package status icons: ✓/✗/⟳ [source: nvim-lspconfig.lua, primary, 2026-04-18]
- Tree-sitter: branch `main`; installed explicitly for astro, bash, css, dockerfile, git_rebase, gitcommit, gitignore, go, gomod, gosum, gowork, hcl, html, javascript, json, json5, kotlin, lua, markdown, markdown_inline, mermaid, python, query, rust, sql, svelte, terraform, tsx, typescript, vim, vimdoc [source: nvim-treesitter.lua, primary, 2026-04-18]
- Tree-sitter FileType autocmds: `vim.treesitter.start()` for markdown/lua/vim/vimdoc/query (ftplugin disabled via did_load_ftplugin=1); `vim.treesitter.stop()` for astro/yaml/yaml.ansible [source: nvim-treesitter.lua, primary, 2026-04-18]
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
| 2026-04-18 | nvim/lua/plugins/nvim-lspconfig.lua | primary |
| 2026-04-18 | nvim/lua/plugins/nvim-treesitter.lua | primary |
| 2026-04-06 | nvim/lua/plugins/nvim-cmp.lua | primary |
| 2026-04-06 | nvim/lua/plugins/typescript-tools.lua | primary |
| 2026-04-06 | nvim/lua/plugins/nvim-lsp-file-operations.lua | secondary |

## Changelog
- 2026-04-06: Initial creation from 5 LSP/completion plugin files
- 2026-04-18: nvim-lspconfig.lua migrated to `vim.lsp.config()` + `vim.lsp.enable()` API, added monkey-patch for rounded float preview borders, switched mason dependency to lazy cmd-loading with :MasonUpdate build step; nvim-treesitter.lua pinned to `main` branch with explicit ts.install() list and FileType start/stop autocmds to work around disabled ftplugin
