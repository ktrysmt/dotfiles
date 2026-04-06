---
entity: homebrew
category: services
sources:
  - path: /Users/dew/dotfiles/Brewfile.common
    source_type: primary
    sha256: 3758e80a61c591bd9982aeffe5c78c9307fe77b56e2fd02b2276a021a5bc8313
    ingested: 2026-04-06
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
updated: 2026-04-06
---

# Homebrew Package Manager

## Overview
Package manager for macOS and Linux managing system dependencies via Brewfile manifests. Three Brewfile variants: common (cross-platform formulae), mac (macOS-specific casks), and ubuntu (Linux formulae). Installation orchestrated by `install/brew.sh`. PATH configuration handled in `.zshenv` with Apple Silicon and Intel detection.

## Key Facts
- Brewfile.common: tig, csvlens, tree, watch, universal-ctags, hyperfine, dufs, git-secrets, and more
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
| 2026-04-06 | Brewfile.common | primary |
| 2026-04-06 | Brewfile.mac | primary |
| 2026-04-06 | Brewfile.ubuntu | primary |
| 2026-04-06 | install/brew.sh | primary |

## Changelog
- 2026-04-06: Initial creation from 3 Brewfiles and install/brew.sh
