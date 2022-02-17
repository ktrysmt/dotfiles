function precmd() {
  if [ ! -z $TMUX ]; then
    tmux refresh-client -S
  fi
}
