#!/bin/bash

set -o pipefail
set -e

sudo apt-get install xvfb xsel -qq -y

ln -sf ~/dotfiles/.tmux.conf.ubuntu_vagrant ~/.tmux.conf

cat << EOF > ~/.zshrc.private
if ! pgrep -f VBoxClient > /dev/null; then
  sudo VBoxClient --clipboard
fi
if [ -x /usr/bin/Xvfb ] && [ -x /usr/bin/VBoxClient ] && [ ! -f /tmp/.X0-lock ] && ! pgrep -f Xvfb > /dev/null; then
  Xvfb -screen 0 320x240x8 > /dev/null 2>&1 &
fi
export DISPLAY=":0"
alias pbcopy='xsel --display :0 --input --clipboard'
alias pbpaste='xsel --display :0 --output --clipboard'
export SRC_ACCESS_TOKEN=""                  # login via github oauth in sourcegraph.com
export GEMINI_API_KEY=""                    # get it from aistudio
export OLLAMA_HOST="192.168.33.1"           # host machine of vagrant
export OLLAMA_MODEL="deepseek-coder-v2:16b" #
EOF
