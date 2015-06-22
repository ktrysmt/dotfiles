
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

# alias
alias gdw="git diff --color-words"
alias ggpull="git pull origin $(current_branch)"
alias ggpush="git push origin $(current_branch)"

# go
export PATH=$PATH:/usr/local/go/bin
export PATH=$HOME/go-project/bin:$PATH
export GOPATH=$HOME/go-project

# node
export PATH=$HOME/.nodebrew/current/bin:$PATH
nodebrew use v0.10
