#!/bin/bash

set -o pipefail
set -e

ln -s ~/dotfiles/.tmux.conf.wsl ~/.tmux.conf
echo "alias pbcopy='clip.exe'" >> ~/.zshrc.private
echo "alias pbpaste='powershell.exe Get-Clipboard'" >> ~/.zshrc.private
echo 'export PATH=/home/linuxbrew/.linuxbrew/bin:$PATH' >> ~/.zshrc.private
echo 'export PATH=/home/linuxbrew/.linuxbrew/sbin:$PATH' >> ~/.zshrc.private

WIN_USER=$(cmd.exe /c "echo %USERNAME%")
WIN_USER=${WIN_USER%$'\r'}
# https://github.com/equalsraf/win32yank/releases
ln -s /mnt/c/Users/$WIN_USER/home_scripts/win32yank.exe /usr/local/bin/win32yank.exe
# https://github.com/kaz399/spzenhan.vim/blob/master/zenhan/spzenhan.exe
ln -s /mnt/c/Users/$WIN_USER/home_scripts/spzenhan.exe /usr/local/bin/spzenhan.exe
