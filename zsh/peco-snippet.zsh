# function peco-select-snippet() {
#   emulate -L zsh
#   BUFFER=$(cat ~/.snippet | peco)
#   CURSOR=$#BUFFER
#   zle -Rc
#   zle reset-prompt
# }
# zle -N peco-select-snippet
# bindkey '^X^M' peco-select-snippet
