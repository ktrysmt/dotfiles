---
entity: nvim-plugins-git
category: components
sources:
  - path: /Users/dew/dotfiles/nvim/lua/plugins/git.lua
    source_type: primary
    sha256: 34998235bf117abf49fc429568471d782b3c886c7937404aca0963f14577f6d4
    ingested: 2026-04-18
  - path: /Users/dew/dotfiles/nvim/lua/plugins/diffview.lua
    source_type: primary
    sha256: 01f18e0557f86dc80fd29c69b712dfbaac651d27627c526fda727e318f517a02
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/tig-explorer.lua
    source_type: primary
    sha256: d9c667d6e6df5cda72b157ee2075c48aa582df1c22edd97225565d35723a1a99
    ingested: 2026-04-18
  - path: /Users/dew/dotfiles/nvim/lua/plugins/octo.lua
    source_type: primary
    sha256: 76c042c9e51605ab28d98e7da02cdbf6fc0b25c6009104c56bde0b3a751dfb71
    ingested: 2026-04-06
related:
  - neovim-editor
  - git-config
created: 2026-04-06
updated: 2026-04-18
---

# Neovim Git Plugins

## Overview
Git integration in Neovim combining vim-fugitive, gitsigns, git-conflict, diffview, tig-explorer, and octo (GitHub). Gitsigns shows diff signs with hunk navigation (gw/gb) and staging (g+/g-). Git-conflict handles merge conflict resolution. Diffview provides visual diff for commits and file history. Tig-explorer integrates the terminal git log browser. Octo enables GitHub PR review and issue management within Neovim.

## Key Facts
- vim-fugitive: :Git commands for git operations; removes deprecated stub commands (Gbrowse, Gdiff, Gblame, Gremove, Gdelete, Gmove, Grename, Gfetch, Gpush, Gpull) via pcall(vim.api.nvim_del_user_command); `<Leader>gb` triggers `!gh browse %` [source: git.lua, primary, 2026-04-18]
- gitsigns: diff signs in sign column; gw/gb (hunk nav), g+/g- (stage/unstage); signs_staged with `┃` character distinguishes staged hunks [source: git.lua, primary, 2026-04-18]
- git-conflict: disabled (commented out in git.lua; previously: cww to choose both sides) [source: git.lua, primary, 2026-04-18]
- diffview: DiffviewOpen, DiffviewClose, DiffviewFileHistory; left file panel
- tig-explorer: <Leader>gt (Tig cwd), <Leader>gT (TigOpenProjectRootDir), <Leader>gf (TigOpenCurrentFile); all opened in a right-vsplit via vsr_exec Lua helper that temporarily toggles splitright [source: tig-explorer.lua, primary, 2026-04-18]
- octo: GitHub PR review and issues via nvim-octo

## Relations
- [[neovim-editor]] -- Core editor providing keymaps
- [[git-config]] -- Git configuration used by fugitive and gitsigns

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-18 | nvim/lua/plugins/git.lua | primary |
| 2026-04-06 | nvim/lua/plugins/diffview.lua | primary |
| 2026-04-18 | nvim/lua/plugins/tig-explorer.lua | primary |
| 2026-04-06 | nvim/lua/plugins/octo.lua | primary |

## Changelog
- 2026-04-06: Initial creation from 4 git plugin files
- 2026-04-18: git.lua disabled git-conflict block (commented out), added fugitive deprecated-stub removal, added `<Leader>gb` to `gh browse %`, reworked gitsigns staged signs; tig-explorer.lua introduced vsr_exec Lua helper and explicit <Leader>gt/gT/gf bindings opening in right-vsplit
