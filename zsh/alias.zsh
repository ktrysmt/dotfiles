# general
alias history='fc -il 1' # for HIST_STAMPS in oh-my-zsh
alias gh='cd $(ghq list -p | peco)'
alias rg='rg -S'
alias rgn='rg -S --hidden --no-heading'
alias l="exa -lha"
alias ll=l
alias lt="exa -lhTa --ignore-glob '.git|node_modules'"
alias ltt="exa -Ta --ignore-glob '.git|node_modules'"
alias nswitch="source ~/.switch-proxy"
alias tsync="tmux set-window-option synchronize-panes"
alias batd="bat -l diff"
alias bats="bat -l sh"
alias batf='bat $(fzf)'
alias f='fzf --preview "bat --color=always --style=header,grid --line-range :100 {}"'
alias cdg='cd $(git rev-parse --show-toplevel)'
alias sudo='sudo '

# git
alias g="git"
alias gf="git fetch --prune"
alias glog="git log"
alias gd="git diff"
alias gdd="git diff | delta"
alias gdc="git diff --cached"
alias gds="git diff --stat"
alias gp="git push"
alias gl="git pull"
alias gs="git status"
alias gss="git status -s"
alias ga="git add"
alias gc="git commit"
alias gca="git commit -a"
alias gco="git checkout"
alias gcm="git checkout master"
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

# docker
alias d='lima nerdctl'

# dstat
alias dstat='dstat -tlamp'
alias dstat-full="dstat -Tclmdrn"  # full
alias dstat-memory="dstat -Tclm"   # memory
alias dstat-cpu="dstat -Tclr"      # cpu
alias dstat-network="dstat -Tclnd" # network
alias dstat-diskio="dstat -Tcldr"  # diskI/O
