#!/bin/bash

set -o pipefail
set -e

read -p "password? > " PASSWORD

# linuxbrew
sudo apt-get -qq -y update
sudo apt-get -qq -y install build-essential curl file git zsh wget
export CI=true
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

export PATH=$PATH:/home/linuxbrew/.linuxbrew/bin
eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

# brew
brew install \
  peco \
  nkf \
  tree \
  ripgrep \
  fd \
  procs \
  fzf \
  tig \
  fzy \
  exa \
  python \
  jq \
  git-secrets \
  bat \
  ghq \
  diff-so-fancy \
  coreutils \
  llvm \
  neovim \
  ctags
exec $SHELL -l

# symlinks
cd ~/
mkdir ~/.zinit
git clone https://github.com/zdharma/zinit.git ~/.zinit/bin
mkdir -p ~/.config/peco/
mkdir ~/.cache
mkdir ~/.local
mkdir ~/.docker
ln -s ~/dotfiles/.snippet ~/.snippet
ln -s ~/dotfiles/.zshenv ~/.zshenv
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.tigrc ~/.tigrc
ln -s ~/dotfiles/.config/peco/config.json ~/.config/peco/config.json
cp ~/dotfiles/.gitconfig ~/.gitconfig
cp ~/dotfiles/.docker/config.json ~/.docker/config.json

# git config
git secrets --register-aws --global
git secrets --install ~/.git-templates/git-secrets
git config --global init.templatedir '~/.git-templates/git-secrets'
git config --global credential.helper store

# nvim
vim +":PlugInstall" +qa
mkdir -p ~/.config/nvim/
ln -s ~/.vimrc ~/.config/nvim/init.vim
pip3 install neovim
sudo ln -sf $(which nvim) $(which vim)
pip3 install 'python-language-server[yapf]'
pip3 install ipdb # python debugger

# the final task
sudo bash -c "echo $(which zsh) >> /etc/shells";
echo $PASSWORD | chsh -s $(which zsh)
