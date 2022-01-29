: "zinit" && {
  source ~/.zinit/bin/zinit.zsh

  zinit wait lucid light-mode for \
    atinit"typeset -gA FAST_HIGHLIGHT; FAST_HIGHLIGHT[git-cmsg-len]=73; zicompinit; zicdreplay" \
      zdharma-continuum/fast-syntax-highlighting

  zinit wait lucid atload"zicompinit; zicdreplay" blockf for zsh-users/zsh-completions

  zinit wait lucid is-snippet as"completion" for \
    OMZP::docker/_docker \
    OMZP::docker-compose/_docker-compose \
    OMZP::rust/_rust \
    OMZP::cargo \
    OMZP::rustup

  zinit is-snippet for \
    OMZL::completion.zsh \
    OMZL::key-bindings.zsh \
    OMZL::directories.zsh \
    https://github.com/aws/aws-cli/blob/v2/bin/aws_zsh_completer.sh

  zinit light lukechilds/zsh-better-npm-completion
  zinit light asdf-vm/asdf
}

: "setopt" && {
  # operation
  setopt interactivecomments
  setopt AUTO_MENU
  setopt AUTO_CD
  setopt AUTO_NAME_DIRS
  setopt hist_ignore_dups
  setopt hist_ignore_all_dups
  setopt share_history
  setopt hist_verify

  # color
  setopt promptsubst
  autoload -U colors
  colors

  # move completion list
  bindkey -M menuselect 'h' vi-backward-char
  bindkey -M menuselect 'j' vi-down-line-or-history
  bindkey -M menuselect 'k' vi-up-line-or-history
  bindkey -M menuselect 'l' vi-forward-char
}

: "extra up and down key-binding" && {
  autoload -U up-line-or-beginning-search
  autoload -U down-line-or-beginning-search
  zle -N up-line-or-beginning-search
  zle -N down-line-or-beginning-search
  bindkey "^p" up-line-or-beginning-search
  bindkey "^n" down-line-or-beginning-search
}

: "env" && {
  # zsh
  export PROMPT='[%*]%{$fg_bold[green]%} %{$fg[cyan]%}%c %{$reset_color%}%(?.%{$fg[green]%}.%{$fg[red]%})%B%(!.#.$)%b '
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
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

  # k8s/docker
  export DOCKER_BUILDKIT=1
  export KREW_NO_UPGRADE_CHECK=1
  export PATH="$PATH:${KREW_ROOT:-$HOME/.krew}/bin"

  # deno
  export PATH=$HOME/.deno/bin:$PATH
}

: "alias" && {
  # general
  alias history='fc -il 1' # for HIST_STAMPS in oh-my-zsh
  alias gh='cd $(ghq list -p | peco)'
  alias rg='rg -S'
  alias rgn='rg -S --hidden --no-heading'
  alias l="exa -lha"
  alias ll=l
  alias lt="exa -lhTa --ignore-glob '.git|node_modules'"
  alias ltt="exa -Ta --ignore-glob '.git|node_modules'"
  alias nswitch="source ~/.switch-proxy"
  alias tsync="tmux set-window-option synchronize-panes"
  alias batd="bat -l diff"
  alias bats="bat -l sh"
  alias batf='bat $(fzf)'
  alias f='fzf --preview "bat --color=always --style=header,grid --line-range :100 {}"'
  alias cdg='cd $(git rev-parse --show-toplevel)'

  # git
  alias g="git"
  alias gf="git fetch --prune"
  alias glog="git log"
  alias gd="git diff"
  alias gdc="git diff --cached"
  alias gds="git diff --stat"
  alias gp="git push"
  alias gl="git pull"
  alias gs="git status"
  alias gss="git status -s"
  alias ga="git add"
  alias gc="git commit"
  alias gca="git commit -a"
  alias gco="git checkout"
  alias gcm="git checkout master"
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
  alias vi="vim"
  alias vimf='vim $(fzf)'
  alias vimdiff='nvim -d'
  alias typora='open -a typora'
  alias rs='evcxr'

  # docker
  alias d='lima nerdctl'

  # dstat
  alias dstat='dstat -tlamp'
  alias dstat-full="dstat -Tclmdrn"  # full
  alias dstat-memory="dstat -Tclm"   # memory
  alias dstat-cpu="dstat -Tclr"      # cpu
  alias dstat-network="dstat -Tclnd" # network
  alias dstat-diskio="dstat -Tcldr"  # diskI/O
}

: "open global alias" && {
  my-open-alias() {
    if [ -z "$RBUFFER" ] ; then
      my-open-alias-aux
    else
      zle end-of-line
    fi
  }
  my-open-alias-aux() {
    str=${LBUFFER%% }
    bp=$str
    str=${str##* }
    bp=${bp%%${str}}
    targets=`alias ${str}`
    if [ $targets ]; then
      cmd=`echo $targets|cut -d"=" -f2`
      LBUFFER=$bp${cmd//\'/}
    fi
  }
  zle -N my-open-alias
  bindkey "^ " my-open-alias
}

: "lazyload completions" && {

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
}

: "powered_cd" && {
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
}

# peco-snippet
: "peco-snippet" && {
  function peco-select-snippet() {
    emulate -L zsh
    BUFFER=$(cat ~/.snippet | peco)
    CURSOR=$#BUFFER
    zle -Rc
    zle reset-prompt
  }
  zle -N peco-select-snippet
  bindkey '^X^M' peco-select-snippet
}

: "tmux refresh" && {
  function precmd() {
    if [ ! -z $TMUX ]; then
      tmux refresh-client -S
    fi
  }
}

: "Switch ENVs by OSTYPE" && {
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
    export PATH=/home/linuxbrew/.linuxbrew/bin:$PATH
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    export MANPATH="/home/linuxbrew/.linuxbrew/share/man:$MANPATH"
    export INFOPATH="/home/linuxbrew/.linuxbrew/share/info:$INFOPATH"

    if [[ "$USERNAME" == "vagrant" ]]; then
      # linux on Vagrant
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
}

: "private source" && {
  if [ -e ~/.zshrc.private ]; then
    source ~/.zshrc.private
  fi
}

: "zprof" && {
  if type zprof > /dev/null 2>&1 ;then
    zprof | less
  fi
}

# rust with wasmtime
export WASMTIME_HOME="$HOME/.wasmtime"
export PATH="$PATH:$WASMTIME_HOME/bin"
