#!/bin/bash

set -o pipefail
set -e
# /etc/security/limits.conf
# -----------------------
# * soft nofile 65536
# * hard nofile 65536
ulimit -n 65536

export DEBIAN_FRONTEND=noninteractive

# prepare
sudo -E apt-get update -qq -y
sudo -E apt-get install -qq -y zsh ncurses-term
echo "setopt interactivecomments" > ~/.zshrc
sudo -E bash -c "echo $(which zsh) >> /etc/shells"
sudo -E chsh -s $(which zsh)

# brew
sudo -E apt-get -qq -y install build-essential curl file git wget gcc make
export CI=true
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
export PATH=$PATH:/home/linuxbrew/.linuxbrew/bin
eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

# brew tools
brew install \
  bat \
  coreutils \
  curl \
  diff-so-fancy \
  difftastic \
  eza \
  fd \
  fzf \
  fzy \
  gat \
  gh \
  ghq \
  git \
  git-delta \
  git-secrets \
  glow \
  golangci-lint \
  jq \
  llvm \
  mise \
  neovim \
  nkf \
  nodejs \
  peco \
  pnpm \
  procs \
  ripgrep \
  sheldon \
  tig \
  trash-cli \
  tree \
  uv \
  watch \
  wget \
  xh
brew install ynqa/tap/jnv
brew install universal-ctags
brew install b4b4r07/tap/gomi
$(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc

# mise
eval $(mise activate zsh)
eval $(mise activate --shims)
mise use -g python@3.11
mise use -g nodejs
mise use -g go
mise use -g bun

# symlinks
cd ~/
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
mkdir -p ~/.config/sheldon
ln -s ~/dotfiles/zsh/sheldon.plugins.toml ~/.config/sheldon/plugins.toml
mkdir -p ~/.config/peco/
mkdir -p ~/.local/bin/
mkdir ~/.docker/
mkdir -p ~/.cache/vim/
ln -s ~/dotfiles/nvim ~/.config/nvim
ln -s ~/dotfiles/.snippet ~/.snippet
ln -s ~/dotfiles/.zshenv ~/.zshenv
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.tigrc ~/.tigrc
ln -s ~/dotfiles/.config/peco/config.json ~/.config/peco/config.json
ln -s ~/dotfiles/.gitignore_global ~/.gitignore_global
ln -s ~/dotfiles/.claude/ ~/.claude
cp ~/dotfiles/.gitconfig ~/.gitconfig
cp ~/dotfiles/.docker/config.json ~/.docker/config.json

# git config
sudo -E ln -s "$(which echo)" /usr/local/bin/say
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
sudo -E ln -sf $(which nvim) /usr/local/bin/vim
python -m pip install --user --upgrade pynvim
python -m pip install --user --upgrade neovim
go install github.com/go-delve/delve/cmd/dlv@latest

# go
mkdir -p ~/project/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$HOME/go/bin:$HOME/project/bin:$PATH
export GOPATH=$HOME/go:$HOME/project

# rust
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env

# env
if [[ "$(uname -r)" == *microsoft* ]]; then
  source ~/dotfiles/install/ubuntu/wsl.sh
else
  source ~/dotfiles/install/ubuntu/vagrant.sh
fi
