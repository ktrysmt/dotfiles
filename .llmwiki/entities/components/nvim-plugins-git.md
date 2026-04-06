---
entity: nvim-plugins-git
category: components
sources:
  - path: /Users/dew/dotfiles/nvim/lua/plugins/git.lua
    source_type: primary
    sha256: c27c2bddd9d20e8f7cd4959e4ec97fd875a3b8831da80bb0dbb6c684f41f9d17
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/diffview.lua
    source_type: primary
    sha256: 01f18e0557f86dc80fd29c69b712dfbaac651d27627c526fda727e318f517a02
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/tig-explorer.lua
    source_type: primary
    sha256: a464efc83443b7c13b0035f18348500c9f8dd5287eec8dc4523dd902ac304d69
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/octo.lua
    source_type: primary
    sha256: 76c042c9e51605ab28d98e7da02cdbf6fc0b25c6009104c56bde0b3a751dfb71
    ingested: 2026-04-06
related:
  - neovim-editor
  - git-config
created: 2026-04-06
updated: 2026-04-06
---

# Neovim Git Plugins

## Overview
Git integration in Neovim combining vim-fugitive, gitsigns, git-conflict, diffview, tig-explorer, and octo (GitHub). Gitsigns shows diff signs with hunk navigation (gw/gb) and staging (g+/g-). Git-conflict handles merge conflict resolution. Diffview provides visual diff for commits and file history. Tig-explorer integrates the terminal git log browser. Octo enables GitHub PR review and issue management within Neovim.

## Key Facts
- vim-fugitive: :Git commands for git operations
- gitsigns: diff signs in sign column; gw/gb (hunk nav), g+/g- (stage/unstage)
- git-conflict: merge conflict resolution; cww (choose both sides)
- diffview: DiffviewOpen, DiffviewClose, DiffviewFileHistory; left file panel
- tig-explorer: TigOpenCurrentFile, TigOpenProjectRootDir
- octo: GitHub PR review and issues via nvim-octo

## Relations
- [[neovim-editor]] -- Core editor providing keymaps
- [[git-config]] -- Git configuration used by fugitive and gitsigns

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | nvim/lua/plugins/git.lua | primary |
| 2026-04-06 | nvim/lua/plugins/diffview.lua | primary |
| 2026-04-06 | nvim/lua/plugins/tig-explorer.lua | primary |
| 2026-04-06 | nvim/lua/plugins/octo.lua | primary |

## Changelog
- 2026-04-06: Initial creation from 4 git plugin files
