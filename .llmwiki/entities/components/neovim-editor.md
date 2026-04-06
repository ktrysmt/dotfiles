---
entity: neovim-editor
category: components
sources:
  - path: /Users/dew/dotfiles/nvim/init.lua
    source_type: primary
    sha256: d777e9d8774b01b977961d66b63f4ccd68fc69aa428b857631ddff8c94190fe8
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/options.lua
    source_type: primary
    sha256: d21bae20ea57717b582601395e10022ebcc7ddb9afdee68dca7aa39f4fb1472d
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/keys.lua
    source_type: primary
    sha256: 2c335aff3c189cfec6fffae8ae7acb400b9eef5c37fa53ee8165b90b520dd31b
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/lazynvim.lua
    source_type: primary
    sha256: 4b3355ce82adf024749c794bb4700685606de44c7a9e7402c6c560b7755f44ab
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/highlight.lua
    source_type: primary
    sha256: ee036e00d97e904ed8ef53ba827d759b19d60f2a509b3c2bd3084aac8499992f
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/init.lua
    source_type: primary
    sha256: 25328f3606cfb18f042778e617e4ca27c7af7fc013d349f5bceb7a3f20d1c85a
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/local.nvim/lua/local/init.lua
    source_type: primary
    sha256: 429a407896839f967c6b993e9c87b2869b3db2dfcae024c30a4cab1c332f7c14
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/local.nvim/lua/local/au.lua
    source_type: primary
    sha256: 25c94679f1dd392341a6744129147c0e47389cdc24b9733d97524aff0e9150b6
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/local.nvim/lua/local/checkhealth.lua
    source_type: secondary
    sha256: 39db61afd2b54d67b5b600be8b049203e5bcaca63518235c9bf36ec0d3291867
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/local.nvim/lua/local/clipboard.lua
    source_type: primary
    sha256: 537d491e06f1e30b161d6307b0bbf64843e607129203cd726df3c4936014a912
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/local.nvim/lua/local/command.lua
    source_type: primary
    sha256: 44edecd607b36bf3daa6977385c25e982ceb71ef150902723b9dfdc8b3534ad9
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lazy-lock.json
    source_type: secondary
    sha256: b50e421c5377ef0e83abfa0acc466ff21cdd0103958dd4f9007f4cbc4f4bb66e
    ingested: 2026-04-06
related:
  - nvim-lsp-completion
  - nvim-plugins-ui
  - nvim-plugins-editing
  - nvim-plugins-git
  - nvim-plugins-ai
  - nvim-plugins-ft
  - nvim-plugins-motion
  - fzf-integration
created: 2026-04-06
updated: 2026-04-06
---

# Neovim Editor Configuration

## Overview
Neovim configuration using lazy.nvim as plugin manager. Entry point is `init.lua` which requires options, keys, lazynvim, and highlight modules. Symlinked to `~/.config/nvim`. Plugin files follow naming convention: `ft.*` (filetype), `appearance.*` (UI), `move.*` (motion), `llm.*` (AI). Local machine-specific configuration is handled via `local.nvim` plugin providing autocommands, custom commands, clipboard integration, and health checks.

## Key Facts
- Plugin manager: lazy.nvim with cache enabled, packpath/RTP reset
- Leader key: Space
- Encoding: UTF-8
- Indentation: 2 spaces default
- Line numbers: relative
- Search: magic, ignorecase, smartcase
- Diff algorithm: histogram
- Extended match pairs: CJK brackets support
- Custom highlight groups: IdeographicSpace (full-width spaces), NormalNC (inactive windows)
- Color scheme: pinecone (priority 1000)
- Clipboard: platform-aware (WSL: win32yank.exe, Linux: xsel, macOS: default)
- Custom commands: Rg (ripgrep wrapper), Rv (reload vimrc), Ev (edit vimrc), cn (visual search)
- Autocommands: trailing whitespace trim, paste mode off, quickfix auto-window, terminal insert mode
- Undo: persistent undo stored in ~/.cache/nvim/undofile
- ~50 active plugins, 12 disabled (_bk suffix)

## Relations
- [[nvim-lsp-completion]] -- LSP, Treesitter, and completion system
- [[nvim-plugins-ui]] -- UI/appearance plugins (lualine, neo-tree, outline, etc.)
- [[nvim-plugins-editing]] -- Editing enhancement plugins (format, lint, comment, etc.)
- [[nvim-plugins-git]] -- Git integration plugins (fugitive, gitsigns, diffview)
- [[nvim-plugins-ai]] -- AI/LLM plugins (Claude Code, Copilot)
- [[nvim-plugins-ft]] -- Filetype support plugins
- [[nvim-plugins-motion]] -- Motion and text object plugins
- [[fzf-integration]] -- FZF fuzzy finder integration via fzf-vim

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | nvim/init.lua | primary |
| 2026-04-06 | nvim/lua/options.lua | primary |
| 2026-04-06 | nvim/lua/keys.lua | primary |
| 2026-04-06 | nvim/lua/lazynvim.lua | primary |
| 2026-04-06 | nvim/lua/highlight.lua | primary |
| 2026-04-06 | nvim/lua/plugins/init.lua | primary |
| 2026-04-06 | nvim/local.nvim/lua/local/init.lua | primary |
| 2026-04-06 | nvim/local.nvim/lua/local/au.lua | primary |
| 2026-04-06 | nvim/local.nvim/lua/local/checkhealth.lua | secondary |
| 2026-04-06 | nvim/local.nvim/lua/local/clipboard.lua | primary |
| 2026-04-06 | nvim/local.nvim/lua/local/command.lua | primary |
| 2026-04-06 | nvim/lazy-lock.json | secondary |

## Changelog
- 2026-04-06: Initial creation from 12 Neovim configuration files
