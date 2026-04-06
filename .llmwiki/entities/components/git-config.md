---
entity: git-config
category: components
sources:
  - path: /Users/dew/dotfiles/.gitconfig_macos
    source_type: primary
    sha256: d7cbcc5a8747b2c7c96d5ff6266567f77ca89d063ee8d5eb47435035f9d28471
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.gitconfig_ubuntu
    source_type: primary
    sha256: 025ac9a0b4f270090716f4f0d579fd99679348e8ee911d7f94136224f77f3d6a
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.gitconfig_wsl
    source_type: primary
    sha256: ebc2e31b460380c7077c835ce9b662cc3382047131a83c37b5c7929c4351a653
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.gitignore
    source_type: secondary
    sha256: 75039d3dfe696ccb4e00b7ebbda376e127493776b7070494e69c2c794a1c9096
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.gitignore_global
    source_type: secondary
    sha256: d07dff9a7440c1df9c9b7df20a4cec9817b607b45ff1ddaee902bc6f0a261168
    ingested: 2026-04-06
related:
  - zsh-shell
  - nvim-plugins-git
  - bin-scripts
  - dotfiles-install
created: 2026-04-06
updated: 2026-04-06
---

# Git Configuration

## Overview
Platform-specific git configurations for macOS, Ubuntu, and WSL. All variants use SSH signing (id_ed25519.pub), delta for diff viewing (Dracula theme), ghq for multi-repository management (roots: ~/go/src, ~/project/src), and git-secrets for preventing credential leaks. Global gitignore patterns cover .claude/, __pycache__, node_modules, and other common exclusions.

## Key Facts
- SSH signing: uses id_ed25519.pub for commit signing
- Diff viewer: delta with Dracula theme, side-by-side, line numbers
- Repository management: ghq with roots ~/go/src and ~/project/src
- Secret scanning: git-secrets integrated via hooks (aws patterns)
- Platform variants: .gitconfig_macos, .gitconfig_ubuntu, .gitconfig_wsl
- Global ignore: .claude/, __pycache__/, node_modules/, .DS_Store, *.swp, etc.
- Merge: diff3 conflict style
- Pull: rebase by default
- Aliases defined at git level and shell level (.zshrc)

## Relations
- [[zsh-shell]] -- Git aliases (gd, gp, gl, gs, etc.) defined in .zshrc
- [[nvim-plugins-git]] -- Git integration in Neovim (fugitive, gitsigns, diffview)
- [[bin-scripts]] -- Git helper scripts (git-checkout-remote-branch, git-echo-*)
- [[dotfiles-install]] -- Git configs symlinked per platform by install/symlink.sh

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | .gitconfig_macos | primary |
| 2026-04-06 | .gitconfig_ubuntu | primary |
| 2026-04-06 | .gitconfig_wsl | primary |
| 2026-04-06 | .gitignore | secondary |
| 2026-04-06 | .gitignore_global | secondary |

## Changelog
- 2026-04-06: Initial creation from 3 platform-specific gitconfigs and 2 gitignore files
