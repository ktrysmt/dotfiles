#!/bin/bash

set -o pipefail
set -e

sudo apt-get install xvfb xsel -qq -y

ln -sf ~/dotfiles/.tmux.conf.ubuntu_vagrant ~/.tmux.conf

cat << EOF > ~/.zshrc.private
if [ -x /usr/bin/Xvfb ] && [ -x /usr/bin/VBoxClient ] && [ ! -f /tmp/.X0-lock ] && ! pgrep -f Xvfb > /dev/null; then
  Xvfb -screen 0 320x240x8 > /dev/null 2>&1 &
  sleep 0.5
  export DISPLAY=":0"
  sudo VBoxClient --clipboard
fi
alias pbcopy='xsel --display :0 --input --clipboard'
alias pbpaste='xsel --display :0 --output --clipboard'
EOF
