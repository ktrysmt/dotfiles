# zsh
export EDITOR='vim'
export HIST_STAMPS="yyyy/mm/dd"
export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=100000
export SAVEHIST=100000
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# go
export PATH=$PATH:/usr/local/go/bin
export PATH=$HOME/go/bin:$PATH
export PATH=$HOME/project/bin:$PATH
export GOPATH=$HOME/go:$HOME/project

# c/c++
export PATH="/usr/local/opt/llvm/bin:$PATH" # clangd, clangd-format

# rust
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# fzf
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="--reverse --height ${FZF_TMUX_HEIGHT:-80%} --select-1 --exit-0"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"

# k8s/docker
export DOCKER_BUILDKIT=1
export KREW_NO_UPGRADE_CHECK=1
export PATH="$PATH:${KREW_ROOT:-$HOME/.krew}/bin"

# bat
# export BAT_THEME="gruvbox-dark"
