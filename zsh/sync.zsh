# cd, comment
setopt AUTO_CD
setopt interactivecomments

# color
export PROMPT='[%*]%{$fg_bold[green]%} %{$fg[cyan]%}%c %{$reset_color%}%(?.%{$fg[green]%}.%{$fg[red]%})%B%(!.#.$)%b '
setopt promptsubst
autoload -U colors
colors

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

bindkey '^X^M' peco-select-snippet
