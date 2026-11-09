typeset -U path fpath

# homebrew
if [[ -d /opt/homebrew ]]; then
  # from eval "$(/opt/homebrew/bin/brew shellenv)"
  export HOMEBREW_PREFIX="/opt/homebrew"
  export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
  export HOMEBREW_REPOSITORY="/opt/homebrew"
  path=(/opt/homebrew/bin /opt/homebrew/sbin $path)
  export MANPATH="/opt/homebrew/share/man:$MANPATH"
  export INFOPATH="/opt/homebrew/share/info:$INFOPATH"
elif [[ -d /home/linuxbrew/.linuxbrew ]]; then
  # from eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
  export HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
  export HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"
  path=(/home/linuxbrew/.linuxbrew/bin /home/linuxbrew/.linuxbrew/sbin $path)
  export MANPATH="/home/linuxbrew/.linuxbrew/share/man:$MANPATH"
  export INFOPATH="/home/linuxbrew/.linuxbrew/share/info:$INFOPATH"
fi

# mise
path=("$HOME/.local/bin" "$HOME/.local/share/mise/shims" $path)

# rancher desktop
if [[ -d "$HOME/.rd/bin" ]]; then path=("$HOME/.rd/bin" $path)
fi


# zmodload zsh/zprof
# zsh -i -c 'zmodload zsh/zprof; source ~/.zshenv; source ~/.zshrc; zprof'

# tmux socket directory for devcontainer bind-mount
# TMUX_TMPDIR: where new tmux servers create sockets (macOS: real path to avoid /tmp symlink)
# TMUX_SOCK_DIR: actual socket directory of the running server (derived from $TMUX)
if [[ "$OSTYPE" == "darwin"* ]]; then
  export TMUX_TMPDIR=/private/tmp/tmux-1000
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
  unset TMUX_TMPDIR
fi
if [[ -n "$TMUX" ]]; then
  export TMUX_SOCK_DIR="${${TMUX%%,*}%/*}"
fi

# prevent compinit in /etc/zsh/zshrc (ubuntu)
skip_global_compinit=1
export MEMD_THEME=catppuccin-mocha

# uv: verify TLS via the OS trust store instead of bundled Mozilla roots, so the
# Netskope CA in the keychain is trusted even when SSL_CERT_FILE is not set.
export UV_SYSTEM_CERTS=1

# claude code
# Kept here rather than in claude/settings.json: Claude Code rewrites the whole
# user settings file from a stale in-process cache on any in-app settings change,
# which silently drops hand-added keys. Env vars survive that.
# Truthiness check is `||`, so any non-empty value enables -- unset to turn off.
# Note: these only reach sessions launched from a shell, not ClaudeCode.app.
export CLAUDE_CODE_DISABLE_BUNDLED_SKILLS=1
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=1
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
export CLAUDE_CODE_USE_POWERSHELL_TOOL=0
# Pin model and effort for every session, whatever /model or /effort saved into
# settings.json (a top-level effortLevel there does not count for Opus 5.5).
# ANTHROPIC_MODEL outranks the settings `model` key; /model and --model still
# switch the current session. `opus` is the alias for the latest Opus.
# CLAUDE_CODE_EFFORT_LEVEL outranks /effort, --effort and saved settings.
# https://code.claude.com/docs/en/model-config#setting-your-model
# https://code.claude.com/docs/en/model-config#adjust-effort-level
export ANTHROPIC_MODEL=opus
export CLAUDE_CODE_EFFORT_LEVEL=xhigh
