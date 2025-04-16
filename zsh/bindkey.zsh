autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey "^p" up-line-or-beginning-search
bindkey "^n" down-line-or-beginning-search

bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

function insert_and_execute_gss_fzf() {
  LBUFFER+="\$(gss | fzf | awk '{print \$2}')"
}
zle -N insert_and_execute_gss_fzf
bindkey '^v' insert_and_execute_gss_fzf
