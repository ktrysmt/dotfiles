---
entity: nvim-plugins-ft
category: components
sources:
  - path: /Users/dew/dotfiles/nvim/lua/plugins/ft.nvim-ansible.lua
    source_type: primary
    sha256: d4f1d5c2c56386fc92bafece511503516e06ad41f5ce8a58afe151a8bb262db4
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/ft.rainbow_csv.lua
    source_type: primary
    sha256: 6f179843059914da06ef08bf559e4810f0b201edede364c36734730b481a887a
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/ft.vim-astro.lua
    source_type: primary
    sha256: 8aa689b67889ebda092f6ef4fe84f7138c2b5257101ed93734cbfeba533d5405
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/ft.vim-qfreplace.lua
    source_type: primary
    sha256: 338b2538ad17bcb05055b96bba7f1db3b6add897e1b0d46e3a4cb1715f835bcb
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/ft.vim-svelte.lua
    source_type: primary
    sha256: 2af900aeb8ce5b6098f48709d683fd1912d8b811712d5fe3293dcd85f3f0a743
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/ft.vim-terraform.lua
    source_type: primary
    sha256: e8e81863cf319e1e36fee65b0099241865117694ca8c6c094ee82e124c32fe9e
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/ft.nvim-bqf.lua_bk
    source_type: secondary
    sha256: faef6a918aeded028d3c7012bac69ef439e876ee4efa4c1282f01d54e8c83cb6
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/nvim/lua/plugins/vim-goaddtags.lua_bk
    source_type: secondary
    sha256: 0fdf03089c7747afcf3402116a2edb397fb4136cf02c7250b2ff8bc4086d97be
    ingested: 2026-04-06
related:
  - neovim-editor
  - nvim-lsp-completion
created: 2026-04-06
updated: 2026-04-06
---

# Neovim Filetype Plugins

## Overview
Extended language and filetype support for development workflows. Active plugins provide syntax and tooling for Ansible YAML, CSV/TSV, Astro templates, Svelte, Terraform HCL, and quickfix manipulation. Disabled plugins include better quickfix (nvim-bqf) and Go struct tag generation (vim-goaddtags).

## Key Facts
- nvim-ansible: Ansible playbook support; auto-detects *.yaml.j2 and *.yml.j2
- rainbow-csv: color-coded CSV/TSV columns; loads for csv/tsv filetypes
- vim-astro: Astro framework syntax; VeryLazy loading
- vim-svelte: Svelte component syntax; depends on vim-javascript and html5.vim
- vim-terraform: Terraform HCL syntax; VeryLazy loading
- vim-qfreplace: quickfix list editing and in-place replacement
- nvim-bqf (DISABLED): better quickfix window
- vim-goaddtags (DISABLED): Go struct tag generation

## Relations
- [[neovim-editor]] -- Core editor providing filetype detection
- [[nvim-lsp-completion]] -- Language servers complement filetype plugins

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | nvim/lua/plugins/ft.nvim-ansible.lua | primary |
| 2026-04-06 | nvim/lua/plugins/ft.rainbow_csv.lua | primary |
| 2026-04-06 | nvim/lua/plugins/ft.vim-astro.lua | primary |
| 2026-04-06 | nvim/lua/plugins/ft.vim-qfreplace.lua | primary |
| 2026-04-06 | nvim/lua/plugins/ft.vim-svelte.lua | primary |
| 2026-04-06 | nvim/lua/plugins/ft.vim-terraform.lua | primary |
| 2026-04-06 | nvim/lua/plugins/ft.nvim-bqf.lua_bk | secondary |
| 2026-04-06 | nvim/lua/plugins/vim-goaddtags.lua_bk | secondary |

## Changelog
- 2026-04-06: Initial creation from 8 filetype plugin files (6 active, 2 disabled)
