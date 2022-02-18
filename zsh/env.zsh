# zsh
export HIST_STAMPS="yyyy/mm/dd"
export EDITOR='vim'
export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=5000000
export SAVEHIST=5000000
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# go
export PATH=$PATH:/usr/local/go/bin
export PATH=$HOME/go/bin:$PATH
export PATH=$HOME/project/bin:$PATH
export GOPATH=$HOME/go:$HOME/project

# c/c++
export PATH="/usr/local/opt/llvm/bin:$PATH" # clangd, clangd-format

# rust
export PATH="$HOME/.cargo/bin:$PATH"
[ -f ~/.cargo/env ] && source ~/.cargo/env

# fzf
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!{node_modules/*,vendor/*,.git/*}"'
export FZF_DEFAULT_OPTS="--reverse --height ${FZF_TMUX_HEIGHT:-80%} --select-1 --exit-0"
export FZF_CTRL_T_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_CTRL_T_OPTS='--select-1 --exit-0 --preview "bat --color=always --style=header,grid --line-range :100 {}"'
export FZF_COMPLETION_TRIGGER=','

# k8s/docker
export DOCKER_BUILDKIT=1
export KREW_NO_UPGRADE_CHECK=1
export PATH="$PATH:${KREW_ROOT:-$HOME/.krew}/bin"

