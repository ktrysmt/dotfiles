---
entity: fzf-integration
category: components
sources:
  - path: /Users/dew/dotfiles/zsh/async.zsh
    source_type: primary
    sha256: 947c2c34e38d1c297a966a955b1f67fd3ffa667971c3648e94de6788c12dc010
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/zsh/sync.zsh
    source_type: primary
    sha256: ed669809314a9d096af795249eaca64ce2c3596409713767b5d4bede658e928b
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/fzf-vim.lua
    source_type: primary
    sha256: 90b1b75bd278efbdb0a5676c228555313da4ef8e89b6bd786f6297afcfe1c63b
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.config/peco/config.json
    source_type: secondary
    sha256: 1c9355abb7dd793e76011117cbb7e802ef5f5591e69e6c116eb583724e453bdf
    ingested: 2026-04-06
related:
  - zsh-shell
  - neovim-editor
  - sheldon-plugins
created: 2026-04-06
updated: 2026-04-06
---

# FZF Fuzzy Finder Integration

## Overview
FZF is integrated across shell (zsh) and editor (Neovim) environments for fuzzy searching. In the shell, FZF_DEFAULT_COMMAND uses `fd` with hidden files, FZF_DEFAULT_OPTS uses bat for preview. Custom keybindings include Ctrl-T (file preview) and Ctrl-V (snippet insertion via gss). In Neovim, fzf-vim provides Files, GFiles, Buffers, Commands, Ripgrep, History, and Windows commands. Peco is also configured as a lighter alternative fuzzy filter.

## Key Facts
- Shell: FZF_DEFAULT_COMMAND uses fd --type f --hidden --follow
- Shell: FZF_DEFAULT_OPTS configures bat preview, height 40%, reverse layout
- Shell: Ctrl-T for file preview, Ctrl-V for gss snippet insert
- Shell: powered_cd function uses fzf for directory history navigation
- Shell: peco-select-snippet for snippet selection from ~/.snippet
- Neovim: fzf-vim (junegunn/fzf) with fzf-mru for recent files
- Neovim: Custom actions for split/vsplit/tabnew via ctrl modifiers
- Peco: config at .config/peco/config.json with Ctrl+J/K selection, cyan style

## Relations
- [[zsh-shell]] -- FZF environment configured in sync.zsh/async.zsh
- [[neovim-editor]] -- fzf-vim plugin for file/buffer/command searching
- [[sheldon-plugins]] -- FZF keybindings loaded via ohmyzsh lib

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | zsh/async.zsh | primary |
| 2026-04-06 | zsh/sync.zsh | primary |
| 2026-04-06 | nvim/lua/plugins/fzf-vim.lua | primary |
| 2026-04-06 | .config/peco/config.json | secondary |

## Changelog
- 2026-04-06: Initial creation from shell and Neovim FZF configuration
