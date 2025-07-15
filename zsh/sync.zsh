setopt nonomatch
setopt AUTO_CD
setopt interactivecomments

# https://qiita.com/sho-t/items/d553dd694900cae0966d
setopt extended_history
setopt append_history
setopt hist_allow_clobber
setopt hist_ignore_all_dups
setopt hist_no_store
setopt hist_verify
setopt share_history

# export PROMPT='[%*]%{$fg_bold[green]%} %{$fg[cyan]%}%c '$aws_is'%{$reset_color%}%(?.%{$fg[green]%}.%{$fg[red]%})%B%(!.#.$)%b '
export PROMPT='[%*]%{$fg_bold[green]%} %{$fg[cyan]%}%c %{$reset_color%}%(?.%{$fg[green]%}.%{$fg[red]%})%B%(!.#.$)%b '

setopt promptsubst

# general
bindkey -e

# snip
bindkey '^X^M' peco-select-snippet

# pushd
export DIRSTACKSIZE=100
setopt AUTO_PUSHD

export BAT_THEME=gruvbox-dark
