#!/bin/bash

set -o pipefail
set -e

sudo apt-get install Xvfb xsel -qq -y

ln -s ~/dotfiles/.tmux.conf.ubuntu_vagrant ~/.tmux.conf

cat <<EOF> ~/.zshrc.private
if ! pgrep -f "Xvfb" > /dev/null; then
  Xvfb -screen 0 1280x720x24 &
  export DISPLAY=:0
  VBoxClient --clipboard
fi
EOF
