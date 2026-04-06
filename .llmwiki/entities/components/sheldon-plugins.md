---
entity: sheldon-plugins
category: components
sources:
  - path: /Users/dew/dotfiles/zsh/sheldon.plugins.toml
    source_type: primary
    sha256: e8fb921d3c5d0754b046d21027a5c09529d032daa1b0c2dd062fe9fbea686ad0
    ingested: 2026-04-06
related:
  - zsh-shell
  - fzf-integration
created: 2026-04-06
updated: 2026-04-06
---

# Sheldon Plugin Manager

## Overview
Sheldon is the zsh plugin manager used to orchestrate plugin loading. Configuration is defined in `sheldon.plugins.toml` (symlinked to `~/.config/sheldon/plugins.toml`). Uses a defer-loading template powered by `zsh-defer` for optimized startup. Manages both external GitHub plugins and local dotfiles modules.

## Key Facts
- Shell: zsh
- Defer template: uses romkatv/zsh-defer for async plugin sourcing
- External plugins: zsh-defer, zsh-syntax-highlighting (zsh-users), zsh-completions (zsh-users), ohmyzsh lib (async, completions, key-bindings, directories), zsh-better-npm-completion (lukechilds), aws_zsh_completer
- Local plugins: dotfiles-async (zsh/async.zsh), dotfiles-sync (zsh/sync.zsh)
- Load order: sync plugins first (blocking), then async plugins via defer template
- ZSH_HIGHLIGHT_MAXLENGTH configured in sync.zsh for performance

## Relations
- [[zsh-shell]] -- Manages loading of sync.zsh and async.zsh
- [[fzf-integration]] -- FZF keybindings loaded via ohmyzsh lib

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | zsh/sheldon.plugins.toml | primary |

## Changelog
- 2026-04-06: Initial creation from sheldon.plugins.toml
