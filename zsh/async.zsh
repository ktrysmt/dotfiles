# completion
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
  { zcompile ~/.zcompdump } &!
else
  compinit -C
fi
# lazy load
function zmv() {
  unfunction zmv
  autoload -Uz zmv
  zmv "$@"
}

# -----
# alias
# -----
# global
alias -g gm='gca -m "`trans @@`"'
# alias -g ss="fd . -t f ~/.claude/session-summaries | sed 's#^.*session-summaries/##' | fzf | xargs -I{} bat ~/.claude/session-summaries/{}"
alias -g ss="fd . -t f ~/.claude/session-summaries | sed 's#^.*session-summaries/##' | fzf --preview 'bat --style=numbers --color=always ~/.claude/session-summaries/{}' | xargs -I{} bat ~/.claude/session-summaries/{}"

# general
alias history='fc -il 1' # for HIST_STAMPS in oh-my-zsh
alias ghl='cd $(ghq list -p | peco)'
alias rg='rg -S'
alias rgn='rg -S --hidden --no-heading'
alias l="eza -lha"
alias ll="ls -lha"
alias lt="eza -lhTa --ignore-glob '.git|node_modules'"
alias ltt="eza -Ta --ignore-glob '.git|node_modules'"
alias tsync="tmux set-window-option synchronize-panes"
tm() { tmux new-session -A -s "${1:-0}"; }
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
alias gcam="git commit -a -m"
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
alias gw="git worktree"

gd0() {
  git diff -U0 "$@"
}
compdef gd0=git-diff

alias delta='delta --syntax-theme zenburn'

# claude
alias cl='claude'


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
alias glow="glow -t -l"
alias csvlens="csvlens -S"

# memd
alias mm="memd"

mml() { local f=/tmp/index.html; memd --html "$@" > "$f" && open "$f"; }
mmh() {
  local f=/tmp/index.html
  memd --html "$@" > "$f" || return 1
  printf '<script>const b=new Blob(['"'"'setInterval(()=>fetch("/__hb",{method:"POST"}),2e3)'"'"'],{type:"text/javascript"});new Worker(URL.createObjectURL(b))</script>' >> "$f"
  local pf=$(mktemp)
  ~/dotfiles/bin/serve-until-close 0 /tmp/ "$pf" &
  local pid=$!
  while [ ! -s "$pf" ]; do sleep 0.05; done
  open "http://localhost:$(cat "$pf")"
  rm -f "$pf"
  trap "kill $pid 2>/dev/null; trap - INT" INT
  wait $pid
}
pmm() { printf '```mermaid\n%s\n```\n' "$(pbpaste)" | memd; }

# devcontainer
dc() {
  local dir="${1:-.}"
  dir="${dir:a}"
  local rel="${PWD#$dir}"
  rel="${rel#/}"
  docker pull "$(jq -r .image ~/dotfiles/.devcontainer/devcontainer.json)" || return
  local up_output
  up_output=$(devcontainer up --config ~/dotfiles/.devcontainer/devcontainer.json --remove-existing-container=true --workspace-folder "$dir") || return
  local cid
  cid=$(printf '%s\n' "$up_output" | grep 'containerId' | jq -r '.containerId')
  [[ -z "$cid" || "$cid" == "null" ]] && { echo "dcu: failed to get container ID"; return 1; }
  devcontainer exec --config ~/dotfiles/.devcontainer/devcontainer.json --workspace-folder "$dir" env TMUX="$TMUX" TMUX_PANE="$TMUX_PANE" bash -c "cd '$rel' && exec bash"
  docker stop "$cid" && docker rm "$cid"
}
alias -g dcls='docker ps --filter "label=devcontainer.local_folder" --format "table {{.Names}}\t{{.ID}}\t{{.Status}}\t{{.Label \"devcontainer.local_folder\"}}"'
alias -g dcrm='docker ps --filter "label=devcontainer.local_folder" --format "table {{.Names}}\t{{.ID}}\t{{.Status}}\t{{.Label \"devcontainer.local_folder\"}}" | fzf | cut -d " " -f1 | xargs docker stop | xargs docker rm'

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
export GOPATH=$HOME/go
export GOBIN="$HOME/go/bin" # avoid to call "mise reshim" w/ mise use -g go
# k8s/docker
export DOCKER_BUILDKIT=1
export KREW_NO_UPGRADE_CHECK=1
# PATH
path=(
  "$GOPATH/bin"
  /usr/local/opt/llvm/bin
  /usr/local/go/bin
  "$HOME/.cargo/bin"
  "${KREW_ROOT:-$HOME/.krew}/bin"
  $path
)

# ----------------
# lazy completion
# ----------------
_lazy_load_completion() {
  local cmd=$1; shift
  if (( $+commands[$cmd] )); then
    eval "function $cmd() {
      unfunction $cmd
      source <($*)
      $cmd \"\$@\"
    }"
  fi
}
_lazy_load_completion kubectl kubectl completion zsh
_lazy_load_completion helm helm completion zsh
_lazy_load_completion eksctl eksctl completion zsh
_lazy_load_completion kind kind completion zsh
_lazy_load_completion gh gh completion -s zsh
_lazy_load_completion pnpm pnpm completion zsh
unset -f _lazy_load_completion

# Cache tac command (tail -r on BSD, tac on GNU)
if (( $+commands[tac] )); then
  ZSH_TAC_CMD=(tac)
else
  ZSH_TAC_CMD=(tail -r)
fi


# -----------
# custom fzf: peco
# -----------
# bat -l=sh --color=always .snippet| fzf --ansi で代替できる
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
  _tmux_auto_rename
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

# -----------
# tmux window auto-rename
# -----------
# Rename window to basename of $PWD on cd / shell init.
# Skips when: (1) @manual-rename is set, (2) Claude status is active,
# (3) this pane is not the active pane of the window.
function _tmux_auto_rename() {
  [[ -n "$TMUX" && -n "$TMUX_PANE" ]] || return

  local info
  info=$(tmux display-message -t "$TMUX_PANE" -p '#{pane_active}|#{window_id}')
  local is_active="${info%%|*}"
  local window="${info#*|}"
  [[ "$is_active" == "1" ]] || return

  # manual rename flag
  local manual
  manual=$(tmux show-options -wv -t "$window" @manual-rename 2>/dev/null)
  [[ "$manual" == "1" ]] && return

  # Claude status active (saved-window-name exists while Claude owns the title)
  local saved
  saved=$(tmux show-options -wv -t "$window" @saved-window-name 2>/dev/null)
  [[ -n "$saved" ]] && return

  tmux rename-window -t "$window" "$(basename "$PWD")"
}

# One-shot: rename window on first prompt (new window / shell startup)
typeset -g _tmux_initial_rename_done=0
function _tmux_initial_rename() {
  if (( _tmux_initial_rename_done == 0 )) && [[ -n "$TMUX" ]]; then
    _tmux_initial_rename_done=1
    _tmux_auto_rename
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _tmux_initial_rename

# fzf
eval "$(fzf --zsh)"

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
function gwa() {
  git worktree add "$@" && {
    cd "$1" && {
      if [[ -e uv.lock ]]; then
        uv sync
        source .venv/bin/activate
      fi
    }
  };
}
function gwflush() {
  local dry_run=false
  [[ "$1" == "-n" || "$1" == "--dry-run" ]] && dry_run=true

  local branch wt count=0

  git branch --merged master | sed 's/^[+* ]*//' | grep '^feature-' | while read branch; do
  wt=$(git worktree list --porcelain \
    | grep -B2 "branch refs/heads/$branch" \
    | grep '^worktree ' \
    | sed 's/^worktree //')

  [[ -z "$wt" ]] && continue

  if [[ -n "$(git -C "$wt" status --porcelain)" ]]; then
    echo "SKIP  $branch  (未コミットの変更あり)"
    continue
  fi

  if $dry_run; then
    echo "DELETE (dry-run)  $branch  ($wt)"
  else
    git worktree remove "$wt" && git branch -d "$branch" \
      && echo "DELETED  $branch  ($wt)"
  fi
  (( count++ ))
done

echo "\n${count} worktree(s) ${dry_run:+would be }removed."
}


# ------
# sheldon wrapper: clear cache on lock/add/remove
# ------
sheldon() {
  command sheldon "$@"
  local ret=$?
  case "$1" in
    lock|add|remove) rm -f "${XDG_CACHE_HOME:-$HOME/.cache}/sheldon.zsh" ;;
  esac
  return $ret
}


# --------
# os type
# --------
if [[ "$OSTYPE" == "linux-gnu" ]]; then # ubuntu(common)
  # common linux
  alias rm="trash"
  if [[ "$USERNAME" == "vagrant" ]]; then # vagrant
    alias vagrant="vagrant.exe"
  fi
  if [[ -n "$WSL_DISTRO_NAME" ]]; then # WSL2
    function open() { wslview "$@"; }
    alias sshon='sudo systemctl start ssh'
    alias sshoff='sudo systemctl stop ssh'
    alias sshst='systemctl is-active ssh'
    alias pbcopy='clip.exe'
    alias pbpaste='powershell.exe Get-Clipboard'
  fi
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
alias nvim12='NVIM_APPNAME=nvim-012 mise x neovim@0.12 -- nvim'
