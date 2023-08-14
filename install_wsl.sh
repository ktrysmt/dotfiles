#!/bin/bash

set -o pipefail
set -e

read -p "password? > " PASSWORD

# base
sudo apt-get install -qq -y update
sudo apt-get install -qq -y zsh
sudo bash -c "echo $(which zsh) >> /etc/shells";
echo $PASSWORD | chsh -s $(which zsh)
export SHELL=/usr/bin/zsh
exec $SHELL -l
setopt interactivecomments

# linuxbrew
sudo apt-get -qq -y install build-essential curl file git wget
export CI=true
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

export PATH=$PATH:/home/linuxbrew/.linuxbrew/bin
eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

# brew
brew install \
  peco \
  zsh \
  nkf \
  tree \
  ripgrep \
  fd \
  procs
brew install \
  fzf \
  sheldon \
  tig \
  fzy \
  exa \
  python3
brew install \
  jq \
  git-secrets \
  nodejs \
  bat \
  ghq \
  diff-so-fancy
brew install \
  git-delta \
  coreutils \
  neovim
brew install llvm
brew install --HEAD universal-ctags/universal-ctags/universal-ctags

brew install b4b4r07/tap/gomi

$(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc
exec $SHELL -l

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
ln -s ~/dotfiles/.zshrc.ubuntu ~/.zshrc
ln -s ~/dotfiles/.tigrc ~/.tigrc
ln -s ~/dotfiles/.tmux.conf.ubuntu ~/.tmux.conf
ln -s ~/dotfiles/.config/peco/config.json ~/.config/peco/config.json
ln -s ~/dotfiles/.gitignore_global ~/.gitignore_global
cp ~/dotfiles/.gitconfig ~/.gitconfig
cp ~/dotfiles/.docker/config.json ~/.docker/config.json

# git config
git secrets --register-aws --global
git secrets --install ~/.git-templates/git-secrets
git config --global init.templatedir '~/.git-templates/git-secrets'
git config --global credential.helper store

# nvim
mkdir -p ~/.config/nvim/
curl -fLo ~/.config/nvim/autoload/jetpack.vim --create-dirs https://raw.githubusercontent.com/tani/vim-jetpack/master/autoload/jetpack.vim
pip3 install neovim
ln -sf $(which nvim) /usr/local/bin/vim
python2 -m pip install --user --upgrade pynvim
python3 -m pip install --user --upgrade pynvim
vim +":JetpackSync" +qa
vim +":TSUpdate" +qa

# rust
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
