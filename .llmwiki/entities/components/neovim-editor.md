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
    sha256: b191e2eddbec10e6d1405b068e1681accf66e3bf8fa9b098f00be8a719be4d28
    ingested: 2026-04-18
  - path: /Users/dew/dotfiles/nvim/lua/plugins/dap.lua_bk
    source_type: secondary
    sha256: 246dbcac9ca3b1d4141efc733c2fad76307977528d5cb232845154247f387f49
    ingested: 2026-04-18
  - path: /Users/dew/dotfiles/nvim/lua/plugins/dropbar.lua_bk
    source_type: secondary
    sha256: 68e645e50664d8c52a92c3172ab058c1fc7b74956bee447409fe50f79609dde2
    ingested: 2026-04-18
  - path: /Users/dew/dotfiles/nvim/lua/plugins/mason.lua_bk
    source_type: secondary
    sha256: f6bf90d10f5e6f902c4b7dd5ab688f3a62820cf488911e4decd887bfa1485e85
    ingested: 2026-04-18
  - path: /Users/dew/dotfiles/nvim/lua/plugins/mini-files.lua_bk
    source_type: secondary
    sha256: efa893bc3c489190841f08dd3e12527d964036f46d6c8d14c8dcb3715bed7c20
    ingested: 2026-04-18
  - path: /Users/dew/dotfiles/nvim/lua/plugins/oil.lua_bk
    source_type: secondary
    sha256: c6051a1ad234cf0e5e64225adc9b28590801c0e8bce513830411c5f3e61a1917
    ingested: 2026-04-18
  - path: /Users/dew/dotfiles/nvim/lua/plugins/smart-splits.lua_bk
    source_type: secondary
    sha256: 9da95a72330862f8f2252334e4e2f8895c7106aac5c9e4afebdf0dd7afe0718e
    ingested: 2026-04-18
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
updated: 2026-04-18
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
- Tracked disabled backups (_bk): dap (debugging), dropbar (winbar), mason (superseded by lazy-loaded mason in nvim-lspconfig.lua), mini-files, oil (file manager alternatives), smart-splits [source: dap.lua_bk/dropbar.lua_bk/mason.lua_bk/mini-files.lua_bk/oil.lua_bk/smart-splits.lua_bk, secondary, 2026-04-18]

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
| 2026-04-18 | nvim/lazy-lock.json | secondary |
| 2026-04-18 | nvim/lua/plugins/dap.lua_bk | secondary |
| 2026-04-18 | nvim/lua/plugins/dropbar.lua_bk | secondary |
| 2026-04-18 | nvim/lua/plugins/mason.lua_bk | secondary |
| 2026-04-18 | nvim/lua/plugins/mini-files.lua_bk | secondary |
| 2026-04-18 | nvim/lua/plugins/oil.lua_bk | secondary |
| 2026-04-18 | nvim/lua/plugins/smart-splits.lua_bk | secondary |

## Changelog
- 2026-04-06: Initial creation from 12 Neovim configuration files
- 2026-04-18: lazy-lock.json updated (plugin versions); registered 6 disabled `_bk` backup files as secondary sources (dap, dropbar, mason, mini-files, oil, smart-splits) to eliminate orphan-file lint
