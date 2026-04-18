---
entity: nvim-plugins-motion
category: components
sources:
  - path: /Users/dew/dotfiles/nvim/lua/plugins/move.vim-easymotion.lua
    source_type: primary
    sha256: 90db9823fcc29f32a422f2f5660c5d72f812208c6daf25445f4b8332ffe2fb1f
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/move.camel-case-motion.lua
    source_type: primary
    sha256: 0ccb266e302779e2067b48660c6c9c1559260aadf72e03054218d0f66e67c844
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/move.edge-motion.lua
    source_type: primary
    sha256: 30671d7bb5d05992e77c0d762644e958640bf5c575a9b20e76d0c6ac15c4b10a
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/treesitter-unit.lua
    source_type: primary
    sha256: de1449dade8934d9537f7ed346ff491de5cf63efdcd3540c356cd39ca1461b15
    ingested: 2026-04-06
    status: missing
  - path: /Users/dew/dotfiles/nvim/lua/plugins/vim-expand-region.lua
    source_type: primary
    sha256: 0e263f5d3e8ea5e5e05feb4981e2c15fed966f30e38b5e3b8e3813173c614b7b
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/vim-asterisk.lua
    source_type: primary
    sha256: 9b4b67bc31cfca35230ad5f8b912cbe67737a57667a1155cf5fddec6aba5b4f4
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/vim-abolish.lua
    source_type: primary
    sha256: c65a81df2535cdee7b28e12c96964503eed6a16384158013499d93dc88a1ca33
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/vim-camelsnek.lua
    source_type: primary
    sha256: dc9440cd71dd2c7424d751d8264ad5af970e0fb94f716ccc3f3ea6f422b380b3
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/move.others.lua
    source_type: primary
    sha256: 61ee8cbdc38c1ce1b510c831ec41bf0c7840b226287a6a42d03b611fe56a77bd
    ingested: 2026-04-18
related:
  - neovim-editor
  - nvim-lsp-completion
created: 2026-04-06
updated: 2026-04-18
---

# Neovim Motion and Text Object Plugins

## Overview
Motion and text object plugins enabling fast navigation and smart text selection. EasyMotion provides label-based character jumping (leader: semicolon). CamelCase motion treats camelCase as multiple words. Edge motion jumps to line boundaries. Vim-expand-region provides incremental selection. Additional plugins: vim-asterisk (search stay-in-place), vim-abolish/vim-camelsnek (case coercion), plus move.others.lua which bundles vim-sandwich, vim-niceblock, leap.nvim (codeberg mirror), treemonkey, and vim-matchup.

## Key Facts
- vim-easymotion: leader ; (semicolon); labels: hjklasdfgyuiopqwertnmzxcvb
- camel-case-motion: w b e ge for CamelCase-aware word motion
- vim-edgemotion: gj (down edge), gk (up edge)
- treesitter-unit: file disappeared on 2026-04-18; historical keys io (inner), ao (outer) in visual/operator modes [source: treesitter-unit.lua, primary, 2026-04-06]
- vim-expand-region: v (expand), V (shrink) in visual mode
- vim-asterisk: * # g* g# with keeppos (cursor stays in place)
- vim-abolish: crs (snake_case), crc (camelCase), crk (kebab-case), cru (UPPER), crm (Mixed)
- vim-camelsnek: Pascal, Camel, Kebab, Snake, Snakecaps, Snek, Screm commands
- move.others.lua bundles: vim-sandwich (sa/sr/sd surround + ib/is visual text objects), vim-niceblock (ip/ap in x/o modes), leap.nvim from codeberg.org/andyg/leap.nvim with case_sensitive=false and custom labels 1-9+a-z plus `<space>` as prev_target, treemonkey.nvim (`m` in x/o modes, ignore_injections=false), vim-matchup (BufReadPost, matchparen_offscreen via popup) [source: move.others.lua, primary, 2026-04-18]

## Relations
- [[neovim-editor]] -- Core editor providing keymaps
- [[nvim-lsp-completion]] -- Treesitter integration for syntax-aware objects

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | nvim/lua/plugins/move.vim-easymotion.lua | primary |
| 2026-04-06 | nvim/lua/plugins/move.camel-case-motion.lua | primary |
| 2026-04-06 | nvim/lua/plugins/move.edge-motion.lua | primary |
| 2026-04-06 | nvim/lua/plugins/treesitter-unit.lua | primary (source disappeared 2026-04-18) |
| 2026-04-06 | nvim/lua/plugins/vim-expand-region.lua | primary |
| 2026-04-06 | nvim/lua/plugins/vim-asterisk.lua | primary |
| 2026-04-06 | nvim/lua/plugins/vim-abolish.lua | primary |
| 2026-04-06 | nvim/lua/plugins/vim-camelsnek.lua | primary |
| 2026-04-18 | nvim/lua/plugins/move.others.lua | primary |

## Changelog
- 2026-04-06: Initial creation from 8 motion/text object plugin files
- 2026-04-18: Added move.others.lua bundling vim-sandwich, vim-niceblock, leap.nvim (codeberg mirror), treemonkey, vim-matchup; treesitter-unit.lua source disappeared (retained as historical reference)
