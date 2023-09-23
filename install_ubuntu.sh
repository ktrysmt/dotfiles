#!/bin/bash

set -o pipefail
set -e

read -p "password? > " PASSWORD

# base
sudo apt-get update -qq -y
sudo apt-get install -qq -y zsh
sudo bash -c "echo $(which zsh) >> /etc/shells"
echo $PASSWORD | chsh -s $(which zsh)
export SHELL=/usr/bin/zsh
exec $SHELL -l
setopt interactivecomments

# linuxbrew
sudo apt-get -qq -y install build-essential curl file git wget gcc make
export CI=true
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

export PATH=$PATH:/home/linuxbrew/.linuxbrew/bin
eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

# brew
brew install \
  asdf \
  bat \
  coreutils \
  curl \
  diff-so-fancy \
  eza \
  fd \
  fzf \
  fzy \
  ghq \
  ghq \
  git \
  git-delta \
  git-secrets \
  jq \
  jq \
  llvm \
  nkf \
  nodejs \
  peco \
  procs \
  ripgrep \
  rust-analyzer \
  sheldon \
  tig \
  tree \
  watch \
  wget \
  neovim
brew install --HEAD universal-ctags/universal-ctags/universal-ctags
brew install b4b4r07/tap/gomi

exec $SHELL -l
$(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc

# asdf
asdf plugin add nodejs
asdf plugin add python
asdf install nodejs latest
asdf install python latest
asdf global nodejs latest
asdf global python latest

# symlinks
cd ~/
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
mkdir -p ~/.config/sheldon
ln -s ~/dotfiles/zsh/sheldon.plugins.toml ~/.config/sheldon/plugins.toml
mkdir -p ~/.config/peco/
mkdir -p ~/.local/bin/
mkdir ~/.docker/
mkdir -p ~/.config/nvim/
mkdir -p ~/.cache/vim/
ln -s ~/dotfiles/.vimrc ~/.config/nvim/init.vim
ln -s ~/dotfiles/.snippet ~/.snippet
ln -s ~/dotfiles/.zshenv ~/.zshenv
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.tigrc ~/.tigrc
ln -s ~/dotfiles/.config/peco/config.json ~/.config/peco/config.json
ln -s ~/dotfiles/.gitignore_global ~/.gitignore_global
cp ~/dotfiles/.gitconfig ~/.gitconfig
cp ~/dotfiles/.docker/config.json ~/.docker/config.json

# git config
git secrets --register-aws --global
git secrets --install ~/.git-templates/git-secrets
git config --global init.templatedir '~/.git-templates/git-secrets'
git config --global credential.helper store

# ssh
mkdir ~/.ssh
touch ~/.ssh/config
echo "ServerAliveInterval 15" >> ~/.ssh/config
echo "ServerAliveCountMax 10" >> ~/.ssh/config

# editor
sudo ln -sf $(which nvim) /usr/local/bin/vim
python -m pip install --user --upgrade pynvim
python -m pip install --user --upgrade neovim
go install github.com/go-delve/delve/cmd/dlv@latest
npm i -g npm-check-updates neovim @fsouza/prettierd eslint_d

# go
mkdir -p ~/project/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$HOME/go/bin:$HOME/project/bin:$PATH
export GOPATH=$HOME/go:$HOME/project

# rust
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env

# ==============
# wsl or ubuntu
# ==============
if [[ "$(uname -r)" == *microsoft* ]]; then
  ln -s ~/dotfiles/.tmux.conf.wsl ~/.tmux.conf
  echo "alias pbcopy='clip.exe'" >> ~/.zshrc.private
  echo "alias pbpaste='powershell.exe Get-Clipboard'" >> ~/.zshrc.private
else
  ln -s ~/dotfiles/.tmux.conf.ubuntu ~/.tmux.conf
fi
