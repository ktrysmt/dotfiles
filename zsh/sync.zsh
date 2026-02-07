setopt nonomatch
setopt AUTO_CD
setopt AUTO_MENU
setopt AUTO_NAME_DIRS
setopt interactivecomments

# https://qiita.com/sho-t/items/d553dd694900cae0966d
setopt extended_history
setopt append_history
setopt hist_allow_clobber
setopt hist_ignore_all_dups
setopt hist_no_store
setopt hist_verify
setopt share_history


# zsh-syntax-highlighting performance
# Limit per-line length to highlight to reduce latency on long inputs
typeset -g ZSH_HIGHLIGHT_MAXLENGTH=${ZSH_HIGHLIGHT_MAXLENGTH:-300}

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
# bat
export BAT_THEME=gruvbox-dark
# fzf
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="--reverse --height ${FZF_TMUX_HEIGHT:-80%} --select-1 --exit-0"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"

# completion (oh-my-zsh style, zero-latency)
zmodload -i zsh/complist

: ${XDG_CACHE_HOME:=$HOME/.cache}
ZSH_COMPCACHE="${XDG_CACHE_HOME}/zsh/zcompcache"
ZSH_COMPDUMP="${XDG_CACHE_HOME}/zsh/.zcompdump-${HOST}"
[[ -d "${ZSH_COMPCACHE}" ]] || mkdir -p "${ZSH_COMPCACHE}" "${ZSH_COMPDUMP:h}"

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_COMPCACHE"
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages'     format '%d'
zstyle ':completion:*:warnings'     format 'no matches found: %d'
[[ -n ${LS_COLORS:-} ]] && zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=**' \
  'l:|=* r:|=*'

compinit -C -d "$ZSH_COMPDUMP"

