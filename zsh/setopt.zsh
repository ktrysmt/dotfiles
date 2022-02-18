# operation
setopt AUTO_MENU
setopt AUTO_CD
setopt AUTO_NAME_DIRS
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt share_history
setopt hist_verify

# move completion list
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
