#
# zgen
#
source "${HOME}/.zgen/zgen.zsh"
if ! zgen saved; then
    echo "Creating a zgen save..."
    zgen oh-my-zsh
    zgen oh-my-zsh plugins/git
    zgen oh-my-zsh plugins/sudo
    zgen oh-my-zsh plugins/command-not-found
    zgen load zsh-users/zsh-syntax-highlighting
    zgen load zsh-users/zsh-history-substring-search 
    zgen load zsh-users/zsh-completions src
    zgen save
fi

#
# ENV
#
export PROMPT='[%*]%{$fg_bold[green]%} %{$fg[cyan]%}%c %{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%}%{$reset_color%}%(?.%{$fg[green]%}.%{$fg[red]%})%B%(!.#.$)%b '
export HIST_STAMPS="yyyy/mm/dd"
export EDITOR='vim'
# go
export PATH=$PATH:/usr/local/go/bin
export PATH=$HOME/project/bin:$PATH
export GOPATH=$HOME/project
# node
export PATH=$HOME/.nodebrew/current/bin:$PATH
nodebrew use stable
export PATH=$PATH:./node_modules/.bin
export PATH="$HOME/.yarn/bin:$PATH"
# fzf
export FZF_DEFAULT_COMMAND='rg ""'
export FZF_DEFAULT_OPTS="--reverse --height ${FZF_TMUX_HEIGHT:-80%} --select-1 --exit-0"

#
# source
#
[ -f ~/.cargo/env ] && source ~/.cargo/env
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#
# alias
# 
alias gdw="git diff --color-words"
alias gh='cd $(ghq list -p | peco)'
alias glogg='git log --graph --name-status --pretty=format:"%C(red)%h %C(green)%an %Creset%s %C(yellow)%d%Creset"'
alias dstat='dstat -tlamp'
alias rg='rg -S'
alias grebase='git rebase -i $(git log --date=short --pretty="format:%C(yellow)%h %C(green)%cd %C(blue)%ae %C(red)%d %C(reset)%s" |fzy| cut -d" " -f1)'
alias gbrc="~/dotfiles/bin/git-checkout-remote-branch"

#
# tmux func
#
PERIOD=5
if [ `who am i | awk '{print $1}'` != "vagrant" ];then \
  show-current-dir-as-window-name() {
    local PROMPT=$($HOME/dotfiles/bin/git-echo-prompt-is-clean)
    tmux set-window-option window-status-format " #I:${PWD:t}$PROMPT " > /dev/null
    tmux set-window-option window-status-current-format " #I:${PWD:t}$PROMPT " > /dev/null
  }
  show-current-dir-as-window-name
  add-zsh-hook precmd show-current-dir-as-window-name
fi;

#
# powered_cd
#
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
  if which tac > /dev/null; then
    tac="tac"
  else
    tac="tail -r"
  fi
  if [ $# = 0 ]; then
    cd $(eval $tac ~/.powered_cd.log | fzf)
  elif [ $# = 1 ]; then
    cd $1
  else
    echo "powered_cd: too many arguments"
  fi
}
_powered_cd() {
  _files -/
}
compdef _powered_cd powered_cd
[ -e ~/.powered_cd.log ] || touch ~/.powered_cd.log
alias c="powered_cd"

#
# peco func
#
function peco-select-history() {
    # historyを番号なし、逆順、最初から表示。
    # 順番を保持して重複を削除。
    # カーソルの左側の文字列をクエリにしてpecoを起動
    # \nを改行に変換
    BUFFER="$(\history -nr 1 | awk '!a[$0]++' | peco --query "$LBUFFER" | sed 's/\\n/\n/')"
    CURSOR=$#BUFFER # カーソルを文末に移動
    zle -R -c       # refresh
}
zle -N peco-select-history
bindkey '^r' peco-select-history

#
# Switch ENV by OSTYPE
#
if [[ "$OSTYPE" == "linux-gnu" ]]; then
        # ...
elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
        export HOMEBREW_CASK_OPTS="--appdir=/Applications";
elif [[ "$OSTYPE" == "cygwin" ]]; then
        # POSIX compatibility layer and Linux environment emulation for Windows
elif [[ "$OSTYPE" == "msys" ]]; then
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
elif [[ "$OSTYPE" == "win32" ]]; then
        # I'm not sure this can happen.
elif [[ "$OSTYPE" == "freebsd"* ]]; then
        # ...
else
        # Unknown.
fi

#
# private 
#
if [ -e ~/.zshrc.private ]; then
  source ~/.zshrc.private
fi
