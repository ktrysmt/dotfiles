---
entity: mise-runtime
category: services
sources:
  - path: /Users/dew/dotfiles/mise/config.toml
    source_type: primary
    sha256: b85f890b412e7ff4c12ee506603839025421e994079a3fd9799c83e1675c0b9a
    ingested: 2026-04-18
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
    sha256: f691e6e9a85754da11a802785ec404b1d7f0b651f9b4ac942c3911c9d4f5f155
    ingested: 2026-04-18
related:
  - dotfiles-install
  - homebrew
  - zsh-shell
created: 2026-04-06
updated: 2026-04-18
---

# Mise Runtime Manager

## Overview
Runtime version manager handling language runtimes, CLI tools, and development utilities. Replaces asdf. Global config at `mise/config.toml` with platform overlays for macOS (`mac.toml`) and WSL (`wsl.toml`). Manages Go, Node.js, Python (via uv), fzf, ripgrep, bat, eza, delta, jq, gh, ghq, peco, yazi, bun, buf, ruff, sheldon, and aqua-based packages. Shims activated in `.zshenv`.

## Key Facts
- Global config: mise/config.toml (symlinked to ~/.config/mise/config.toml)
- Platform overlays: mac.toml (kubectl, kind, helm, eksctl, ruby), wsl.toml (ruby)
- Languages: Go 1.25, Node.js (latest), bun (latest); Python 3.13 pinned globally via `uv python install 3.13` + `uv python pin --global 3.13` (not via mise); Ruby via platform overlays only [source: config.toml, primary, 2026-04-18]
- CLI tools (version switchable): fzf, ripgrep, bat, eza, delta, jq, gh, ghq, peco, bun, buf, ruff, uv, xh, glow, fd 10.3, pinact [source: config.toml, primary, 2026-04-18]
- Aqua backend: Wilfred/difftastic, ynqa/jnv, sxyazi/yazi, rossmacarthur/sheldon [source: config.toml, primary, 2026-04-18]
- GitHub backend: dalance/procs, sudorandom/fauxrpc (grpc mock) [source: config.toml, primary, 2026-04-18]
- npm backend: diff-so-fancy, pnpm, memd-cli, @devcontainers/cli, @anthropic-ai/sandbox-runtime, agent-browser [source: config.toml, primary, 2026-04-18]
- Editor: neovim 0.12 [source: config.toml, primary, 2026-04-18]
- install/mise.sh: activate mise, trust config, `mise install --yes` (non-fatal on npm minimumReleaseAge failures), `mise cache clear`, `mise up --yes`, `mise prune --yes`, fzf keybinding setup (when ~/.fzf.zsh missing), Python 3.13 install/pin via uv [source: mise.sh, primary, 2026-04-18]
- FZF keybindings setup: source $(mise where fzf)/shell/key-bindings.zsh
- Shims: activated in .zshenv via eval "$(mise activate zsh --shims)"

## Relations
- [[dotfiles-install]] -- mise.sh called during installation
- [[homebrew]] -- Complementary: Homebrew for system tools, mise for runtimes
- [[zsh-shell]] -- Mise shims activated in .zshenv

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-18 | mise/config.toml | primary |
| 2026-04-06 | mise/mac.toml | primary |
| 2026-04-06 | mise/wsl.toml | primary |
| 2026-04-18 | install/mise.sh | primary |

## Changelog
- 2026-04-06: Initial creation from 3 mise config files and install/mise.sh
- 2026-04-18: config.toml added npm:agent-browser, npm:@anthropic-ai/sandbox-runtime, npm:memd-cli, aqua:ynqa/jnv, xh, pinact, glow; pinned Go to 1.25 and fd to 10.3; mise.sh added cache-clear, mise up, mise prune, and Python 3.13 pin via uv
