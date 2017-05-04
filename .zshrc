#
# zgen
#
source "${HOME}/.zgen/zgen.zsh"

# check if there's no init script
if ! zgen saved; then
    echo "Creating a zgen save..."

    zgen oh-my-zsh

    # plugins
    zgen oh-my-zsh plugins/git
    zgen oh-my-zsh plugins/sudo
    zgen oh-my-zsh plugins/command-not-found
    zgen load zsh-users/zsh-syntax-highlighting

    # bulk load
    zgen loadall <<EOPLUGINS
        zsh-users/zsh-history-substring-search
EOPLUGINS

    # completions
    zgen load zsh-users/zsh-completions src

    # theme
    zgen oh-my-zsh themes/robbyrussell

    # save all to init script
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
export FZF_CTRL_R_OPTS="--reverse --height ${FZF_TMUX_HEIGHT:-80%}"

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
alias grebase='git rebase -i $(git log --date=short --pretty='format:%C(yellow)%h %C(green)%cd %C(blue)%ae %C(red)%d %C(reset)%s' |fzf| cut -d" " -f1)'

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
