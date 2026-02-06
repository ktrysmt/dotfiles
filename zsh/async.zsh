# -----
# alias
# -----
# global
alias -g gm='gca -m "`trans @@`"'

# general
alias history='fc -il 1' # for HIST_STAMPS in oh-my-zsh
alias ghl='cd $(ghq list -p | peco)'
alias rg='rg -S'
alias rgn='rg -S --hidden --no-heading'
alias l="eza -lha"
alias ll="ls -lha"
alias lt="eza -lhTa --ignore-glob '.git|node_modules'"
alias ltt="eza -Ta --ignore-glob '.git|node_modules'"
alias nswitch="source ~/.switch-proxy"
alias tsync="tmux set-window-option synchronize-panes"
alias bat="bat -p"
alias batn="bat --number"
alias batd="bat -l diff"
alias f='fzf --preview "bat --color=always --style=header,grid --line-range :100 {}"'
alias cdg='cd $(git rev-parse --show-toplevel)'

# git
alias g="git"
alias gf="git fetch --prune"
alias glog="git log"
alias gd="git diff"
alias gdd="git diff | delta"
alias gdc="git diff --cached"
alias gds="git diff --stat"
alias gdt="GIT_EXTERNAL_DIFF=difft git diff"
alias gp="git push"
alias gpf="git push --force-with-lease"
alias gl="git pull"
alias gs="git status"
alias gss="git status -s"
alias ga="git add"
alias gc="git commit"
alias gca="git commit -a"
alias gco="git checkout"
alias gcm="git checkout master"
alias gcn="git checkout main"
alias ggpush="git push origin"
alias ggpull="git pull origin"
alias gdw="git diff --color-words"
alias gdww="git diff --word-diff-regex=$'[^\x80-\xbf][\x80-\xbf]*' --word-diff=color"
alias glogg='git log --graph --name-status --pretty=format:"%C(red)%h %C(green)%an %Creset%s %C(yellow)%d%Creset"'
alias glogo='git log --oneline --pretty=format:"%C(red)%h %C(green)%an %Creset%s %C(yellow)%d%Creset"'
alias grebase='git rebase -i $(git log --date=short --pretty="format:%C(yellow)%h %C(green)%cd %C(blue)%ae %C(red)%d %C(reset)%s" |fzy| cut -d" " -f1)'
alias gb="git branch"
alias gbc="~/dotfiles/bin/git-checkout-remote-branch"

# k8s
alias k="kubectl"
alias kg="kubectl get"
alias kgp="kubectl get pods"
alias ka="kubectl apply -f"
alias kd="kubectl describe"
alias krm="kubectl delete"
alias klo="kubectl logs -f"
alias kex="kubectl exec -i -t"
alias kns="kubens"
alias kctx="kubectx"
# other
alias py="/usr/local/bin/python3.9"
alias vi="nvim"
alias vim="nvim"
alias vimf='nvim $(fzf)'
alias vimdiff='nvim -d'
alias typora='open -a typora'
alias rs='evcxr'
alias delta="delta --syntax-theme zenburn"
alias glow="glow -t -l"
alias csvlens="csvlens -S"
# python
alias va="source .venv/bin/activate"
alias vd="deactivate"

# ---------
# bindkey
# ---------
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
function insert_and_execute_gss_fzf() {
  emulate -L zsh
  LBUFFER+="\$(gss | fzf | awk '{print \$2}')"
}
zle -N insert_and_execute_gss_fzf
bindkey '^v' insert_and_execute_gss_fzf
# # expand global alias with space
function expand-alias() {
    emulate -L zsh
    local word="${LBUFFER##* }"
    # global alias の場合のみ展開
    if (( ${+galiases[$word]} )); then
        zle _expand_alias
        local placeholder='@@'
        local pos=${BUFFER[(i)$placeholder]}
        if (( pos <= $#BUFFER )); then
            BUFFER="${BUFFER[1,pos-1]}${BUFFER[pos+$#placeholder,-1]}"
            CURSOR=$((pos - 1))
        fi
    fi
    zle self-insert
}
zle -N expand-alias
bindkey -M main ' ' expand-alias

# -----
# env
# -----
# zsh
export EDITOR='nvim'
export HIST_STAMPS="yyyy/mm/dd"
export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=100000
export SAVEHIST=100000
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# go
export GOROOT=""
export GO111MODULE="auto"
export GOPATH=$HOME/go:$HOME/project
# k8s/docker
export DOCKER_BUILDKIT=1
export KREW_NO_UPGRADE_CHECK=1
# PATH
path=(
  "$HOME/go/bin"
  "$HOME/project/bin"
  /usr/local/opt/llvm/bin
  /usr/local/go/bin
  "$HOME/.cargo/bin"
  "${KREW_ROOT:-$HOME/.krew}/bin"
  $path
)

# ----------------
# lazy completion
# ----------------
# Helper function for lazy completion loading (DRY)
_lazy_load_completion() {
  local cmd=$1 starter_fn=$2 completion_cmd=$3
  if type "$cmd" > /dev/null 2>&1; then
    eval "function $cmd() {
      if ! type $starter_fn >/dev/null 2>&1; then
        source <($completion_cmd)
      fi
      command $cmd \"\$@\"
    }"
  fi
}

_lazy_load_completion kubectl __start_kubectl "command kubectl completion zsh"
_lazy_load_completion helm __start_helm "command helm completion zsh"
_lazy_load_completion eksctl __start_eksctl "command eksctl completion zsh"
_lazy_load_completion kind __start_kind "command kind completion zsh"
_lazy_load_completion gh __start_gh "command gh completion -s zsh"
_lazy_load_completion pnpm _pnpm "command pnpm completion zsh"
unset -f _lazy_load_completion

# Cache tac command (tail -r on BSD, tac on GNU)
if (( $+commands[tac] )); then
  ZSH_TAC_CMD=(tac)
else
  ZSH_TAC_CMD=(tail -r)
fi

# --------
# os type
# --------
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  if [[ "$USERNAME" == "vagrant" ]]; then
    # linux on Vagrant
  fi
  if [[ -n "$WSL_DISTRO_NAME" ]]; then
    # WSL2
    function open() {
      emulate -L zsh
      if [[ $# != 1 ]]; then
        explorer.exe .
      else
        if [[ -e "$1" ]]; then
          explorer.exe "$(wslpath -w "$1")" 2> /dev/null
        else
          echo "open: $1 : No such file or directory"
        fi
      fi
    }
  fi
  alias rm="trash"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  #
elif [[ "$OSTYPE" == "cygwin" ]]; then
  #
elif [[ "$OSTYPE" == "msys" ]]; then
  #
elif [[ "$OSTYPE" == "win32" ]]; then
  #
elif [[ "$OSTYPE" == "freebsd"* ]]; then
  #
else
  # Unknown.
fi

# -----------
# custom fzf: peco
# -----------
function peco-select-snippet() {
  emulate -L zsh
  BUFFER=$(cat ~/.snippet | peco)
  CURSOR=$#BUFFER
  zle -Rc
  zle reset-prompt
}
zle -N peco-select-snippet
function chpwd() {
  emulate -L zsh
  powered_cd_add_log
}

# -----------
# custom fzf: powered_cd
# -----------
function powered_cd_add_log() {
  emulate -L zsh
  local log_file="$HOME/.powered_cd.log"
  local temp_file="${log_file}.tmp"
  local current_pwd="$PWD"

  [[ -f "$log_file" ]] || touch "$log_file"

  {
    grep -Fvx "$current_pwd" "$log_file" 2>/dev/null | head -n 9999
    echo "$current_pwd"
  } > "$temp_file"

mv "$temp_file" "$log_file"
}
# OLD powered_cd_add_log
# function powered_cd_add_log() {
#   emulate -L zsh
#   local log_file="$HOME/.powered_cd.log"
#   local temp_file="${log_file}.tmp"
#   local current_pwd="$PWD"
#   typeset -i i=0
#
#   # Create log file if it doesn't exist
#   [[ -f "$log_file" ]] || touch "$log_file"
#
#   {
#     while IFS= read -r line; do
#       (( i++ ))
#       # Skip if we've hit 10000 lines or this is a duplicate
#       if (( i >= 10000 )) || [[ "$line" == "$current_pwd" ]]; then
#         continue
#       fi
#       echo "$line"
#     done < "$log_file"
#     echo "$current_pwd"
#   } > "$temp_file"
#
#   mv "$temp_file" "$log_file"
# }
function powered_cd() {
  emulate -L zsh
  local log_file="$HOME/.powered_cd.log"
  [[ -f "$log_file" ]] || : >| "$log_file"

  if [[ $# -eq 0 ]]; then
    local dir
    dir=$("${ZSH_TAC_CMD[@]}" "$log_file" | fzf)
    if [[ -z "$dir" ]]; then
      return 1
    elif [[ -d "$dir" ]]; then
      builtin cd -- "$dir"
    else
      # remove stale entry using builtin read loop
      local tmp="${log_file}.tmp"
      : >| "$tmp"
      local line
      while IFS= read -r line; do
        [[ "$line" == "$dir" ]] || print -r -- "$line" >> "$tmp"
      done < "$log_file"
      mv -f -- "$tmp" "$log_file"
      print -r -- "powerd_cd: deleted old path: ${dir}"
    fi
  elif [[ $# -eq 1 ]]; then
    builtin cd -- "$1"
  else
    print -r -- "powered_cd: too many arguments"
  fi
}
_powered_cd() {
  _files -/
}
alias c="powered_cd"

# -------
# private
# -------
if [[ -e ~/.zshrc.private ]]; then
  source ~/.zshrc.private
fi

# tmux (throttle refresh to at most once/5sec)
zmodload zsh/datetime
typeset -gi _tmux_last_refresh=0
function _tmux_refresh_status() {
  emulate -L zsh
  if [[ -n "$TMUX" ]]; then
    local now=${EPOCHREALTIME%.*}
    if (( now - _tmux_last_refresh >= 3 )); then
      tmux refresh-client -S
      _tmux_last_refresh=$now
    fi
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _tmux_refresh_status

# fzf
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

setopt AUTO_MENU
setopt AUTO_NAME_DIRS

# --------
# AI tools
# --------
function trans() {
  local text="${*:-$(cat)}"
  local target result prompt

  # ASCII（英語と記号）のみなら日本語へ、マルチバイトがあれば英語へ
  # zshネイティブでASCII判定（0x00-0x7F以外があるか）
  if [[ "$text" == *[^$'\x00'-$'\x7f']* ]]; then
    target="English"
  else
    target="Japanese"
  fi

  prompt="Translate to ${target}. Output ONLY the translation, nothing else:"
  result=$(echo "$text" | gemini -m gemini-2.5-flash-lite "$prompt" 2>&1)
  printf '%s' "$result" | pbcopy
  printf '%s\n' "$result"
}

# --------------
# git worktree
# --------------
function gw() {
  if [ "$1" = "add" ]; then
    git worktree "$@" && {
      cd "$2" && {
        if [[ -e uv.lock ]]; then
          uv sync
          source .venv/bin/activate
        fi
      }
    };
  else
    git worktree "$@"
  fi
}
