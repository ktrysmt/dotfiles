#!/bin/bash

set -o pipefail
set -e

ln -s ~/dotfiles/.tmux.conf.wsl ~/.tmux.conf

cat << EOF >> ~/.zshrc.private
alias pbcopy='clip.exe'
alias pbpaste='powershell.exe Get-Clipboard'
export PATH=/home/linuxbrew/.linuxbrew/bin:\$PATH
export PATH=/home/linuxbrew/.linuxbrew/sbin:\$PATH
export SRC_ACCESS_TOKEN="" # login via github oauth in sourcegraph.com
EOF

WIN_USER=$(cmd.exe /c "echo %USERNAME%")
WIN_USER=${WIN_USER%$'\r'}
# https://github.com/equalsraf/win32yank/releases
ln -s /mnt/c/Users/$WIN_USER/home_scripts/win32yank.exe /usr/local/bin/win32yank.exe
# https://github.com/kaz399/spzenhan.vim/blob/master/zenhan/spzenhan.exe
ln -s /mnt/c/Users/$WIN_USER/home_scripts/spzenhan.exe /usr/local/bin/spzenhan.exe

# https://github.com/git-ecosystem/git-credential-manager/releases/tag/v2.6.1
git config --global credential.helper "/mnt/c/Program\ Files\ \(x86\)/Git\ Credential\ Manager/git-credential-manager.exe"
