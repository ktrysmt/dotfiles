# -----
# alias
# -----
# general
alias history='fc -il 1' # for HIST_STAMPS in oh-my-zsh
alias ghl='cd $(ghq list -p | peco)'
alias rg='rg -S'
alias rgn='rg -S --hidden --no-heading'
alias l="eza -lha"
alias ll="ls -lha"
alias lt="eza -lhTa --ignore-glob '.git|node_modules'"
alias ltt="eza -Ta --ignore-glob '.git|node_modules'"
alias nswitch="source ~/.switch-proxy"
alias tsync="tmux set-window-option synchronize-panes"
alias bat="bat -p"
alias batn="bat --number"
alias batd="bat -l diff"
alias f='fzf --preview "bat --color=always --style=header,grid --line-range :100 {}"'
alias cdg='cd $(git rev-parse --show-toplevel)'
alias sudo='sudo '

# git
alias g="git"
alias gf="git fetch --prune"
alias glog="git log"
alias gd="git diff"
alias gdd="git diff | delta"
alias gdc="git diff --cached"
alias gds="git diff --stat"
alias gdt="GIT_EXTERNAL_DIFF=difft git diff"
alias gp="git push"
alias gpf="git push --force-with-lease"
alias gl="git pull"
alias gs="git status"
alias gss="git status -s"
alias ga="git add"
alias gc="git commit"
alias gca="git commit -a"
alias gco="git checkout"
alias gcm="git checkout master"
alias gcn="git checkout main"
alias ggpush="git push origin"
alias ggpull="git pull origin"
alias gdw="git diff --color-words"
alias gdww="git diff --word-diff-regex=$'[^\x80-\xbf][\x80-\xbf]*' --word-diff=color"
alias glogg='git log --graph --name-status --pretty=format:"%C(red)%h %C(green)%an %Creset%s %C(yellow)%d%Creset"'
alias glogo='git log --oneline --pretty=format:"%C(red)%h %C(green)%an %Creset%s %C(yellow)%d%Creset"'
alias grebase='git rebase -i $(git log --date=short --pretty="format:%C(yellow)%h %C(green)%cd %C(blue)%ae %C(red)%d %C(reset)%s" |fzy| cut -d" " -f1)'
alias gb="git branch"
alias gbc="~/dotfiles/bin/git-checkout-remote-branch"

# k8s
alias k="kubectl"
alias kg="kubectl get"
alias kgp="kubectl get pods"
alias ka="kubectl apply -f"
alias kd="kubectl describe"
alias krm="kubectl delete"
alias klo="kubectl logs -f"
alias kex="kubectl exec -i -t"
alias kns="kubens"
alias kctx="kubectx"

# other
alias py="/usr/local/bin/python3.9"
alias vi="nvim"
alias vim="nvim"
alias vimf='nvim $(fzf)'
alias vimdiff='nvim -d'
alias typora='open -a typora'
alias rs='evcxr'
alias delta="delta --syntax-theme zenburn"
alias rm="trash"

# python
alias va="source .venv/bin/activate"
alias vd="deactivate"

# ---------
# bindkey
# ---------
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
function insert_and_execute_gss_fzf() {
  LBUFFER+="\$(gss | fzf | awk '{print \$2}')"
}
zle -N insert_and_execute_gss_fzf
bindkey '^v' insert_and_execute_gss_fzf

# -----
# env
# -----
# zsh
export EDITOR='nvim'
export HIST_STAMPS="yyyy/mm/dd"
export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=100000
export SAVEHIST=100000
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# go
export GOROOT=""
export GO111MODULE="auto"
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


# ----------------
# lazy completion
# ----------------
# kubectl
if type kubectl > /dev/null 2>&1 ;then
  function kubectl() {
    if ! type __start_kubectl >/dev/null 2>&1; then
        source <(command kubectl completion zsh)
    fi
    command kubectl "$@"
  }
fi
# helm
if type helm > /dev/null 2>&1 ;then
  function helm() {
    if ! type __start_helm >/dev/null 2>&1; then
        source <(command helm completion zsh)
    fi
    command helm "$@"
  }
fi
# eksctl
if type eksctl > /dev/null 2>&1 ;then
  function eksctl() {
    if ! type __start_eksctl >/dev/null 2>&1; then
        source <(command eksctl completion zsh)
    fi
    command eksctl "$@"
  }
fi
# kind
if type kind > /dev/null 2>&1 ;then
  function kind() {
    if ! type __start_kind >/dev/null 2>&1; then
        source <(command kind completion zsh)
    fi
    command kind "$@"
  }
fi

if type mise > /dev/null 2>&1 ;then
  source <(mise activate zsh)
fi

if type gh > /dev/null 2>&1 ;then
  source <(gh completion -s zsh)
fi

if type pnpm > /dev/null 2>&1 ;then
  source <(pnpm completion zsh)
fi


# --------
# os type
# --------
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  export PATH=/home/linuxbrew/.linuxbrew/bin:$PATH
  eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
  export MANPATH="/home/linuxbrew/.linuxbrew/share/man:$MANPATH"
  export INFOPATH="/home/linuxbrew/.linuxbrew/share/info:$INFOPATH"

  if [[ "$USERNAME" == "vagrant" ]]; then
    # linux on Vagrant
  fi
  if [ -n "$WSL_DISTRO_NAME" ]; then
    # WSL2
    function open() {
      if [ $# != 1 ]; then
        explorer.exe .
      else
        if [ -e $1 ]; then
          explorer.exe $(wslpath -w $1) 2> /dev/null
        else
          echo "open: $1 : No such file or directory"
        fi
      fi
    }
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  export HOMEBREW_CASK_OPTS="--appdir=/Applications";
  # curl
  export PATH="/usr/local/opt/curl/bin:$PATH"
  export LDFLAGS="-L/usr/local/opt/curl/lib"
  export CPPFLAGS="-I/usr/local/opt/curl/include"
  export PKG_CONFIG_PATH="/usr/local/opt/curl/lib/pkgconfig"
  # openssl
  export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
  export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib"
  export CPPFLAGS="-I/usr/local/opt/openssl@1.1/include"
  export PKG_CONFIG_PATH="/usr/local/opt/openssl@1.1/lib/pkgconfig"
elif [[ "$OSTYPE" == "cygwin" ]]; then
  #
elif [[ "$OSTYPE" == "msys" ]]; then
  #
elif [[ "$OSTYPE" == "win32" ]]; then
  #
elif [[ "$OSTYPE" == "freebsd"* ]]; then
  #
else
  # Unknown.
fi

# -----------
# custom fzf
# -----------
function peco-select-snippet() {
  emulate -L zsh
  BUFFER=$(cat ~/.snippet | peco)
  CURSOR=$#BUFFER
  zle -Rc
  zle reset-prompt
}
zle -N peco-select-snippet
function chpwd() {
  powered_cd_add_log
}
function powered_cd_add_log() {
  local i=0
  cat ~/.powered_cd.log | while read line; do
  (( i++ ))
  if [ i = 30 ]; then
    sed -i -e "30,30d" ~/.powered_cd.log
  elif [ "$line" = "$PWD" ]; then
    sed -i -e "${i},${i}d" ~/.powered_cd.log
  fi
done
echo "$PWD" >> ~/.powered_cd.log
}
function powered_cd() {
  if type tac > /dev/null 2>&1 ;then
    tac="tac"
  else
    tac="tail -r"
  fi
  if [ $# = 0 ]; then
    local dir=$(eval $tac ~/.powered_cd.log | fzf)
    if [ "$dir" = "" ]; then
      return 1
    elif [ -d "$dir" ]; then
      cd "$dir"
    else
      local res=$(grep -v -E "^${dir}" ~/.powered_cd.log)
      echo $res > ~/.powered_cd.log
      echo "powerd_cd: deleted old path: ${dir}"
    fi
  elif [ $# = 1 ]; then
    cd $1
  else
    echo "powered_cd: too many arguments"
  fi
}
_powered_cd() {
  _files -/
}
# compdef _powered_cd powered_cd
[ -e ~/.powered_cd.log ] || touch ~/.powered_cd.log
alias c="powered_cd"

# -------
# private
# -------
if [ -e ~/.zshrc.private ]; then
  source ~/.zshrc.private
fi

# tmux
function precmd() {
  if [ ! -z $TMUX ]; then
    tmux refresh-client -S
  fi
}

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

setopt AUTO_MENU
setopt AUTO_NAME_DIRS
