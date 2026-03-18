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

## Editor (nvim/)

Symlinked to `~/.config/nvim`. Uses lazy.nvim.

| Path | Role |
|------|------|
| `nvim/init.lua` | Entry point: requires options, keys, lazynvim, highlight |
| `nvim/lua/options.lua` | Neovim options |
| `nvim/lua/keys.lua` | Key mappings |
| `nvim/lua/lazynvim.lua` | lazy.nvim bootstrap |
| `nvim/lua/highlight.lua` | Highlight overrides |
| `nvim/lua/plugins/*.lua` | One file per plugin. Prefixes: `ft.*` (filetype), `appearance.*` (UI), `move.*` (motion), `llm.*` (AI) |

## Install (install/)

Idempotent setup scripts. `install/symlink.sh` is the source of truth for what links where.

| File | Role |
|------|------|
| `install/symlink.sh` | All symlinks (shell, nvim, claude, mise, tools) |
| `install/lib.sh` | Shared helpers (link_file, ensure_dir, log_*) |
| `install/brew.sh` | Homebrew formulae/casks |
| `install/mise.sh` | mise tool versions |
| `install/update.sh` | Update existing installation |
| `install/post-install.sh` | Post-install tasks |
| `install/ubuntu/` | `common.sh`, `wsl.sh`, `vagrant.sh` |
| `install/mac/` | `common.sh`, `symlink.sh` (mac-only links) |

## Other

| Path | Role |
|------|------|
| `bin/` | Custom scripts (git helpers, tmux helpers) |
| `mac/` | macOS app configs (iTerm2, Karabiner, Rectangle, Raycast) |
| `windows/` | Windows app configs (keyhac, WindowsTerminal, wezterm, XMBC) |
| `chrome-extensions/` | Browser extension configs: Vimium, uBlock Origin, Stylus, uBlacklist, SiteBlock |
| `.claude/` | Claude Code config: hooks, settings.json, keybindings.json, CLAUDE.md (global), statusline |
| `mise/config.toml` | Global mise tool config |
