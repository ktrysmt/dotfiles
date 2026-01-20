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

# zmodload zsh/zprof
# zsh -i -c 'zmodload zsh/zprof; source ~/.zshenv; source ~/.zshrc; zprof'
