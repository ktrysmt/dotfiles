---
entity: nvim-plugins-editing
category: components
sources:
  - path: /Users/dew/dotfiles/nvim/lua/plugins/format-on-save.lua
    source_type: primary
    sha256: ea1081f55562791f039787db686ecbf469c9343fcd33ab5bce38d5fa2bcd7cce
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/nvim-lint.lua
    source_type: primary
    sha256: db6e2fbfb68ac20607347386a9b956e9df181d7b82be8ab6f4c7cc2a55dea7a8
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/comment.lua
    source_type: primary
    sha256: f59f05c87eeabac8faaf28f49e17b137f4b6c49a7ae9d86a3094699bb48b47d2
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/dial.lua
    source_type: primary
    sha256: 1794886d6f4b3d8790282e4b32f0a695afe0dddb1377a467f84c47f7ad2ed7ca
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/lexima.lua
    source_type: primary
    sha256: c9b35512675ed121a1cecdce9d2515bcf1600b94496002c45093f934fcd68ca0
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/sort.lua
    source_type: primary
    sha256: 5cb18463c1bc9f0b1e16b5340335a3b2535ccc05397c66732ef8d0431189cd4e
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/colorizer.lua
    source_type: primary
    sha256: 49f989b231ccd13d037c3a42e6077668bb53b5d20afd9f14a79b04076bbba539
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/stickybuf.lua
    source_type: primary
    sha256: 3868c2aef736f6be685386dbd865339c02fad5582d8da88c169a4d9a4c644170
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/linediff-vim.lua
    source_type: primary
    sha256: 1654f0fb28d54d5167944a1b352a0f747e123d2f73842cfa0a1280bb8aac66d3
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/mini-align.lua
    source_type: primary
    sha256: 0b257bb4ff9e6e1980c6b3db8ec11ed57e4113aa93d7d3442e9a692f4e67e5b5
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/mini-splitjoin.lua
    source_type: primary
    sha256: cf08c18b7abd1aa33f92c41aa18dafdb14ee20618ea2eef2a46351e82f4fc1e9
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/undotree.lua
    source_type: primary
    sha256: e1e46b9c34841781b441df69052143646014c2de7c411fc1eb10cef8f1479ddc
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/undo-glow.lua
    source_type: primary
    sha256: 36537bf819a06d64ff6ee3ae0a5c4a96642aed9414c93b6afd8232d4caccd27b
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/yanky.lua
    source_type: primary
    sha256: 9286d1b5fbfab60036f4756ffce205ce6af03ef5aa854cf988b5a748514e747e
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/vim-illuminate.lua
    source_type: primary
    sha256: fa78f2492d8fc4dc642b5cef0e0d223ea267a821987e734aa0f3c89a5c49c621
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/history-ignore.lua
    source_type: secondary
    sha256: 134460d84829b2f8a273076b0218e9a973c24d22e1550bf256923b922d8cd53b
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/key-menu.lua
    source_type: secondary
    sha256: d9e00875cebab952d43c94f308e5bdd774108eb0d50c580801adde5c22d18c16
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/memd.lua
    source_type: secondary
    sha256: db57b96b1c1fb98e9ea98aaa50b961031fb1fe21d21b2e81abd994ce01d3d8eb
    ingested: 2026-04-06
related:
  - neovim-editor
  - nvim-lsp-completion
  - nvim-plugins-ui
created: 2026-04-06
updated: 2026-04-06
---

# Neovim Editing Plugins

## Overview
Editing enhancement plugins covering formatting, linting, commenting, smart bracket insertion, text alignment, sorting, undo management, and yank ring. format-on-save uses prettier for JS/TS and LSP for other languages. nvim-lint integrates eslint. Lexima provides smart brackets with a LeximaAlterCommand system for command aliases.

## Key Facts
- format-on-save: prettier for JS/TS, eslint_d_fix, LSP for others; excludes node_modules
- nvim-lint: eslint when node_modules/.bin/eslint exists; triggers BufWritePre
- comment: gcc (normal), gb (visual) for comment toggling
- dial: C-a/C-x for numbers, dates, booleans, logical operators, case conversion
- lexima: smart brackets + LeximaAlterCommand (rg->Rg, lz->Lazy, dv->DiffviewOpen)
- sort: :Sort command for line sorting
- colorizer: inline color preview for hex/rgb
- stickybuf: terminal buffer pinning; <leader>t (new), <leader>vt (vsplit), <leader>T (tab)
- linediff-vim: visual line diff with <Leader>li
- mini-align: text alignment with live preview
- mini-splitjoin: gS for intelligent line join/split
- undotree: visual undo tree; <leader>un; persistent in ~/.cache/nvim/undofile
- undo-glow: color feedback on undo/redo (red/green/yellow/cyan)
- yanky: 500-entry yank ring in sqlite; C-n/C-p cycle; <leader>y preview
- vim-illuminate: highlight word under cursor
- key-menu: interactive Space leader keybinding explorer
- memd: markdown preview toggle with mermaid support

## Relations
- [[neovim-editor]] -- Core editor providing keymaps and autocommands
- [[nvim-lsp-completion]] -- Formatting and linting use LSP
- [[nvim-plugins-ui]] -- Visual feedback integrates with UI plugins

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | nvim/lua/plugins/format-on-save.lua | primary |
| 2026-04-06 | nvim/lua/plugins/nvim-lint.lua | primary |
| 2026-04-06 | nvim/lua/plugins/comment.lua | primary |
| 2026-04-06 | nvim/lua/plugins/dial.lua | primary |
| 2026-04-06 | nvim/lua/plugins/lexima.lua | primary |
| 2026-04-06 | nvim/lua/plugins/sort.lua | primary |
| 2026-04-06 | nvim/lua/plugins/colorizer.lua | primary |
| 2026-04-06 | nvim/lua/plugins/stickybuf.lua | primary |
| 2026-04-06 | nvim/lua/plugins/linediff-vim.lua | primary |
| 2026-04-06 | nvim/lua/plugins/mini-align.lua | primary |
| 2026-04-06 | nvim/lua/plugins/mini-splitjoin.lua | primary |
| 2026-04-06 | nvim/lua/plugins/undotree.lua | primary |
| 2026-04-06 | nvim/lua/plugins/undo-glow.lua | primary |
| 2026-04-06 | nvim/lua/plugins/yanky.lua | primary |
| 2026-04-06 | nvim/lua/plugins/vim-illuminate.lua | primary |
| 2026-04-06 | nvim/lua/plugins/history-ignore.lua | secondary |
| 2026-04-06 | nvim/lua/plugins/key-menu.lua | secondary |
| 2026-04-06 | nvim/lua/plugins/memd.lua | secondary |

## Changelog
- 2026-04-06: Initial creation from 18 editing plugin files
