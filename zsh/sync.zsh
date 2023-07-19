# cd, comment
setopt AUTO_CD
setopt interactivecomments

# hist
# https://qiita.com/sho-t/items/d553dd694900cae0966d
setopt append_history
setopt extended_history
setopt hist_allow_clobber
setopt hist_ignore_all_dups
setopt hist_no_store
setopt hist_verify
setopt share_history

# aws
# --------
# aws_is=""
# if type aws > /dev/null 2&>1 ; then
#   if [[ "$AWS_VAULT" != "" ]]; then
#     aws_is="$fg[black]($AWS_VAULT) "
#     aws_expire=$(aws sts get-caller-identity 2>&1| grep -c "refreshed credentials are still expired")
#     if [[ "$aws_expire" != "0" ]]; then
#       aws_is="$fg[black](!$AWS_VAULT) "
#     fi
#   fi
# fi
# export PROMPT='[%*]%{$fg_bold[green]%} %{$fg[cyan]%}%c '$aws_is'%{$reset_color%}%(?.%{$fg[green]%}.%{$fg[red]%})%B%(!.#.$)%b '
export PROMPT='[%*]%{$fg_bold[green]%} %{$fg[cyan]%}%c %{$reset_color%}%(?.%{$fg[green]%}.%{$fg[red]%})%B%(!.#.$)%b '

setopt promptsubst
autoload -U colors
colors

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# snip
bindkey '^X^M' peco-select-snippet

# pushd
DIRSTACKSIZE=100
setopt AUTO_PUSHD

