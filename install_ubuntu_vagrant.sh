#!/bin/bash
set -o pipefail
set -vxeu

echo "-----------------------------------------------------";
echo "for Vagrant";
echo "-----------------------------------------------------";
if [ `who am i | awk '{print $1}'` = "vagrant" ]; then \
  PASSWORD="vagrant";
  sudo chown -R vagrant:vagrant /usr/local;
fi;

echo "-----------------------------------------------------";
echo "Install homebrew and libraries"
echo "-----------------------------------------------------";
# linuxbrew
sudo apt-get -qq -y update
sudo apt-get -qq -y install build-essential curl file git
sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

# brew
brew install peco wget zsh ripgrep fd fzf tig fzy exa python jq bat git-secrets

# brew neovim
brew install neovim/neovim/neovim

# anyenv
git clone https://github.com/riywo/anyenv ~/.anyenv
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"
anyenv install --force-init
exec $SHELL -l

# goenv nodenv
mkdir -p $(anyenv root)/plugins
git clone https://github.com/znz/anyenv-update.git $(anyenv root)/plugins/anyenv-update
anyenv install goenv
eval "$(anyenv init -)"
goenv install 1.12.5
goenv rehash
goenv global 1.12.5
anyenv install nodenv
eval "$(anyenv init -)"
nodenv install 12.3.1
nodenv rehash
nodenv global 12.3.1

echo "-----------------------------------------------------";
echo "Setup my env"
echo "-----------------------------------------------------";
# general
cd ~/
git clone https://github.com/tarjoilija/zgen.git ~/.zgen
#git clone https://github.com/ktrysmt/dotfiles  ~/dotfiles
mkdir -p ~/.config/peco/
mkdir ~/.cache
mkdir ~/.local
ln -s ~/dotfiles/.snippet ~/.snippet
ln -s ~/dotfiles/.zshenv ~/.zshenv
ln -s ~/dotfiles/.zshrc ~/.zshrc.vagrant
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.tigrc ~/.tigrc
ln -s ~/dotfiles/.tern-project ~/.tern-project
ln -s ~/dotfiles/.config/peco/config.json ~/.config/peco/config.json
cp ~/dotfiles/.gitconfig ~/.gitconfig
# git secrets
git secrets --register-aws --global
git secrets --install ~/.git-templates/git-secrets
git config --global init.templatedir '~/.git-templates/git-secrets'

echo "-----------------------------------------------------";
echo "Setup Go"
echo "-----------------------------------------------------";
mkdir -p ~/project/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$HOME/go/bin:$HOME/project/bin:$PATH
export GOPATH=$HOME/go:$HOME/project

echo "-----------------------------------------------------";
echo "Setup Neovim";
echo "-----------------------------------------------------";
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
mkdir -p ~/.config/nvim/
ln -s ~/.vimrc ~/.config/nvim/init.vim
pip2 install neovim
pip3 install neovim
ln -sf $(which nvim) /usr/local/bin/vim

echo "-----------------------------------------------------";
echo "Setup Other";
echo "-----------------------------------------------------";
go get github.com/motemen/ghq
go get github.com/golang/dep/...
go get golang.org/x/tools/cmd/golsp
nvim +":PlugInstall" +":setfiletype go" +":GoInstallBinaries" +qa
npm i -g npm-check-updates neovim

echo "-----------------------------------------------------";
echo "Rested tasks"
echo "-----------------------------------------------------";
sudo sh -c "echo $(which zsh) >> /etc/shells";
chsh -s $(which zsh)
