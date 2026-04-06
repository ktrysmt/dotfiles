---
entity: nvim-plugins-ui
category: components
sources:
  - path: /Users/dew/dotfiles/nvim/lua/plugins/appearance.lualine.lua
    source_type: primary
    sha256: bbce78f739268f006e3be2d0ca488c5960a6029cddf1ed99d79a4a6c6f769184
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/appearance.neo-tree.lua
    source_type: primary
    sha256: c354d5ee65782591c2d1cd6f4f457aadd35746a98d5e0aaf6f1b79bab4e2c9d9
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/appearance.hlchunk.lua
    source_type: primary
    sha256: aabd0a719a70eb541ef0f7094342e119adc2998566ae285791b49e5e10b7700a
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/appearance.outline.lua
    source_type: primary
    sha256: 6d46449b51b8746031dbcfa9c7f55b824aa72805be9ccaab847c6510fffca6c7
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/appearance.nvim-scrollbar.lua
    source_type: primary
    sha256: dd6dfe7241a09c6043d04bd068dd7c7006e00b4b12ec1f2bc4e0ea61e7b275c9
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/appearance.readablefold.lua
    source_type: primary
    sha256: 5c3d7a1cd2c69cb816d94b9e3c2c50e0dddd2f6a074877214e95655215d83dbb
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/appearance.guess-indent.lua
    source_type: primary
    sha256: f03892b7c95d33f9e31294b2af34d7aefc0ad725c133e72f25e3b73c6ca4501f
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/pinecone-vim.lua
    source_type: primary
    sha256: 6a3a5b648797441c2bbc69f1d7f6a8170148cd016a7bf04be7159542843642f6
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/appearance.which-key.lua_bk
    source_type: secondary
    sha256: 4187068ed99015537064d7bdac08e9b3be4887a3913624003464b61e4e0aa2c0
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/yazi.lua
    source_type: primary
    sha256: 5a0ae36f14d7f30ad37c4e2740c74bb231818a874144292480247648320c4305
    ingested: 2026-04-06
related:
  - neovim-editor
  - nvim-lsp-completion
created: 2026-04-06
updated: 2026-04-06
---

# Neovim UI Plugins

## Overview
Visual and UI enhancement plugins for Neovim. Lualine provides a customized status line with gruvbox-material theme showing branch, diff, diagnostics, filename with path, and search count. Neo-tree is the file tree explorer with git status integration. Yazi.nvim integrates the yazi terminal file manager with floating window support. Outline provides a sidebar for code structure via treesitter/LSP/ctags. Additional UI plugins handle code chunk highlighting, scrollbar with search results, fold visualization, and auto indent detection. Pinecone is the custom color scheme.

## Key Facts
- lualine: gruvbox-material theme, shows branch/diff/diagnostics/filename/search count
- neo-tree: file tree with git status, natural sorting, diagnostics, trash command; C-e toggle, C-w f reveal
- outline: code structure sidebar with treesitter/LSP/ctags providers; autofold depth 5
- hlchunk: code chunk highlighting with gray (#555555) styling
- nvim-scrollbar: visual scrollbar with search highlights via nvim-hlslens
- readablefold: improved fold display readability
- guess-indent: auto-detect file indentation style
- pinecone: custom color scheme with priority 1000
- yazi.nvim: terminal file manager integration (mikavilpas/yazi.nvim); leader+e opens at current file, leader+cw opens at cwd; floating window at 95% scaling; depends on plenary.nvim
- which-key (DISABLED): keybinding help menu replaced by key-menu

## Relations
- [[neovim-editor]] -- Core editor providing highlight groups and options
- [[nvim-lsp-completion]] -- Outline and diagnostics use LSP/treesitter data

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | nvim/lua/plugins/appearance.lualine.lua | primary |
| 2026-04-06 | nvim/lua/plugins/appearance.neo-tree.lua | primary |
| 2026-04-06 | nvim/lua/plugins/appearance.hlchunk.lua | primary |
| 2026-04-06 | nvim/lua/plugins/appearance.outline.lua | primary |
| 2026-04-06 | nvim/lua/plugins/appearance.nvim-scrollbar.lua | primary |
| 2026-04-06 | nvim/lua/plugins/appearance.readablefold.lua | primary |
| 2026-04-06 | nvim/lua/plugins/appearance.guess-indent.lua | primary |
| 2026-04-06 | nvim/lua/plugins/pinecone-vim.lua | primary |
| 2026-04-06 | nvim/lua/plugins/appearance.which-key.lua_bk | secondary |
| 2026-04-06 | nvim/lua/plugins/yazi.lua | primary |

## Changelog
- 2026-04-06: Initial creation from 9 UI/appearance plugin files
- 2026-04-06: Added yazi.nvim file manager plugin
