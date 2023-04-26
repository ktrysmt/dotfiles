# cd, comment
setopt AUTO_CD
setopt interactivecomments

# hist
setopt EXTENDED_HISTORY
setopt HIST_ALLOW_CLOBBER
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_NO_STORE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt appendhistory

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

