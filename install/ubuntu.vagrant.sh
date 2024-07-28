#!/bin/bash

set -o pipefail
set -e

sudo apt-get install Xvfb xsel -qq -y

ln -s ~/dotfiles/.tmux.conf.ubuntu_vagrant ~/.tmux.conf

cat <<EOF> ~/.zshrc.private
if [ -x /usr/bin/Xvfb ] && [ -x /usr/bin/VBoxClient ] && [ ! -f /tmp/.X0-lock ]; then
  Xvfb -screen 0 320x240x8 > /dev/null 2>&1 &
  sleep 0.5
  export DISPLAY=":0"
  VBoxClient --clipboard
fi
alias pbcopy='xsel --display :0 --input --clipboard'
alias pbpaste='xsel --display :0 --output --clipboard'
EOF
