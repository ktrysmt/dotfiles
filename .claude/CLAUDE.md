# Dotfiles Repository

## Shell (zsh/)

Configuration is split into sync (blocking) and async (deferred) phases.
**Never edit `~/.zshrc` or `~/.zshenv` directly** -- they are symlinks to this repo.

| File | Symlinked to | Role |
|------|-------------|------|
| `.zshenv` | `~/.zshenv` | Earliest load: PATH, homebrew, mise shims. Minimal. |
| `.zshrc` | `~/.zshrc` | Bootstrap only: sheldon plugin cache. Do not add functions or aliases here. |
| `zsh/sync.zsh` | (loaded by sheldon) | Synchronous: setopt, bindkey, PROMPT, exports (BAT_THEME, FZF_*). |
| `zsh/async.zsh` | (loaded by sheldon) | **All functions, aliases, and heavy logic go here.** |
| `zsh/sheldon.plugins.toml` | `~/.config/sheldon/plugins.toml` | Plugin manager config. Controls load order. |

**Rule: new shell functions and aliases always go in `zsh/async.zsh`.**

## Install (install/)

Idempotent setup scripts. `install/symlink.sh` is the source of truth for what links where.
