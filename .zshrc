#prompt
PROMPT='[%*]%{$fg_bold[green]%} %{$fg[cyan]%}%c %{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%} % %{$reset_color%}%(?.%{$fg[green]%}.%{$fg[red]%})%B%(!.#.$)%b '

# using peco
function vig {
    STR="$1"
    vim $(grep -n ${STR} **/*.go | grep -v "[0-9]:\s*//" | peco | awk -F ":" '{print "-c "$2" "$1}')
}
#function peco-select-history() {
#    local tac
#    if which tac > /dev/null; then
#        tac="tac"
#    else
#        tac="tail -r"
#    fi
#    BUFFER=$(\history -n 1 | \
#        eval $tac | \
#        peco --query "$LBUFFER")
#    CURSOR=$#BUFFER
#    zle clear-screen
#}
#zle -N peco-select-history
#bindkey '^r' peco-select-history

# history
HIST_STAMPS="yyyy/mm/dd"

# go
export PATH=$PATH:/usr/local/go/bin
export PATH=$HOME/project/bin:$PATH
export GOPATH=$HOME/project

# node
export PATH=$HOME/.nodebrew/current/bin:$PATH
nodebrew use v0.10

# alias
alias gdw="git diff --color-words"
alias ggpull="git pull origin $(current_branch)"
alias ggpush="git push origin $(current_branch)"
alias gh='cd $(ghq list -p | peco)'
alias dstat='dstat -tlamp'



