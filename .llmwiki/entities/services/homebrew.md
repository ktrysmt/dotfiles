---
entity: homebrew
category: services
sources:
  - path: /Users/dew/dotfiles/Brewfile.common
    source_type: primary
    sha256: 0af0a2d5f33cb37640c434cb89d8b0094e0db02fb253fe84627f35d7a7641465
    ingested: 2026-04-18
  - path: /Users/dew/dotfiles/Brewfile.mac
    source_type: primary
    sha256: d3947bcb00d52f43eb29dfeff40ae57cf9b273dc0bff47d5c3b3474b5fc2e38e
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/Brewfile.ubuntu
    source_type: primary
    sha256: fef4c78df3cd73868badcfccf8e194a3b855f64396e496898d39f4cd1100791f
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/install/brew.sh
    source_type: primary
    sha256: 1944313597a8ce8b82752a964475802eedfdf0c568b55ed6a927aae0234f749f
    ingested: 2026-04-06
related:
  - dotfiles-install
  - mise-runtime
  - zsh-shell
  - macos-apps
created: 2026-04-06
updated: 2026-04-18
---

# Homebrew Package Manager

## Overview
Package manager for macOS and Linux managing system dependencies via Brewfile manifests. Three Brewfile variants: common (cross-platform formulae), mac (macOS-specific casks), and ubuntu (Linux formulae). Installation orchestrated by `install/brew.sh`. PATH configuration handled in `.zshenv` with Apple Silicon and Intel detection.

## Key Facts
- Brewfile.common: coreutils, curl, git, tree, watch, wget, csvlens, tmux, tree-sitter-cli (core system tools); fzy, git-secrets, llvm, nkf, tig, universal-ctags, hyperfine, dufs (development tools not in mise); mise itself [source: Brewfile.common, primary, 2026-04-18]
- Brewfile.mac: casks for karabiner-elements, rectangle, raycast, wezterm, linearmouse, alt-tab, clibor, macgesture, wordservice, iterm2
- Brewfile.ubuntu: Linux-specific formulae
- install/brew.sh: orchestrates brew bundle install per platform
- PATH: /opt/homebrew/bin (Apple Silicon) or /usr/local/bin (Intel) configured in .zshenv

## Relations
- [[dotfiles-install]] -- brew.sh called during installation
- [[mise-runtime]] -- Complementary tool management (Homebrew for system tools, mise for runtimes)
- [[zsh-shell]] -- Homebrew PATH configured in .zshenv
- [[macos-apps]] -- macOS casks installed via Brewfile.mac

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-18 | Brewfile.common | primary |
| 2026-04-06 | Brewfile.mac | primary |
| 2026-04-06 | Brewfile.ubuntu | primary |
| 2026-04-06 | install/brew.sh | primary |

## Changelog
- 2026-04-06: Initial creation from 3 Brewfiles and install/brew.sh
- 2026-04-18: Brewfile.common reorganized into "Core system tools", "Development tools (not available in mise)", and "mise itself" sections with explicit comments
