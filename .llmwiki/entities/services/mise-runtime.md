---
entity: mise-runtime
category: services
sources:
  - path: /Users/dew/dotfiles/mise/config.toml
    source_type: primary
    sha256: 0f54aa1b9ad274dd973d7f19aa52b265b347357ce70ac9726d4c9d534af3a761
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/mise/mac.toml
    source_type: primary
    sha256: cbc95741ba03edd7d96f333703fc9de31e8d4d49cb827e4f9df30f9332a2df36
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/mise/wsl.toml
    source_type: primary
    sha256: 3511fb9323ce655d6da34260489f8ed63dbd95af269e5b76096d38f5913c4b37
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/install/mise.sh
    source_type: primary
    sha256: e52c614c4f6064137c9e230b0acce31333ef31760625e31e1b64041db10216d8
    ingested: 2026-04-06
related:
  - dotfiles-install
  - homebrew
  - zsh-shell
created: 2026-04-06
updated: 2026-04-06
---

# Mise Runtime Manager

## Overview
Runtime version manager handling language runtimes, CLI tools, and development utilities. Replaces asdf. Global config at `mise/config.toml` with platform overlays for macOS (`mac.toml`) and WSL (`wsl.toml`). Manages Go, Node.js, Python (via uv), fzf, ripgrep, bat, eza, delta, jq, gh, ghq, peco, yazi, bun, buf, ruff, sheldon, and aqua-based packages. Shims activated in `.zshenv`.

## Key Facts
- Global config: mise/config.toml (symlinked to ~/.config/mise/config.toml)
- Platform overlays: mac.toml (kubectl, kind, helm, eksctl, ruby), wsl.toml (ruby)
- Languages: Go, Node.js, Python 3.13 (via uv), Ruby 3.3
- CLI tools: fzf, ripgrep, bat, eza, delta, jq, gh, ghq, peco, yazi, bun, buf, ruff, sheldon
- Aqua backend: difftastic, yazi, sheldon
- install/mise.sh: activates mise, sets up fzf keybindings, installs uv/Python globally
- FZF keybindings setup: source $(mise where fzf)/shell/key-bindings.zsh
- Shims: activated in .zshenv via eval "$(mise activate zsh --shims)"

## Relations
- [[dotfiles-install]] -- mise.sh called during installation
- [[homebrew]] -- Complementary: Homebrew for system tools, mise for runtimes
- [[zsh-shell]] -- Mise shims activated in .zshenv

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | mise/config.toml | primary |
| 2026-04-06 | mise/mac.toml | primary |
| 2026-04-06 | mise/wsl.toml | primary |
| 2026-04-06 | install/mise.sh | primary |

## Changelog
- 2026-04-06: Initial creation from 3 mise config files and install/mise.sh
