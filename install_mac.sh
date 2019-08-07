#!/bin/bash
set -o pipefail
set -vxeu

echo "-----------------------------------------------------";
echo "Install homebrew and libraries"
echo "-----------------------------------------------------";
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update

# brew
brew install peco wget tmux zsh nkf tree ripgrep fd fzf tig fzy exa python jq git-secrets bat watch dep ghq git
brew install python@2
exec $SHELL -l

# k8s
brew install kubectl kubectx kubernetes-helm caskroom/cask/minikube

# neovim
brew install neovim/neovim/neovim
brew tap universal-ctags/universal-ctags
brew install --HEAD universal-ctags --with-libyaml

# anyenv
git clone https://github.com/riywo/anyenv ~/.anyenv
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"
exec $SHELL -l

# rbenv and nodenv
mkdir -p $(anyenv root)/plugins
git clone https://github.com/znz/anyenv-update.git $(anyenv root)/plugins/anyenv-update
anyenv install nodenv
anyenv install rbenv
nodenv install v10.15.1
nodenv rehash
nodenv global v10.15.1

# rust
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env

echo "-----------------------------------------------------";
echo "Setup my env"
echo "-----------------------------------------------------";
# general
cd ~/
git clone https://github.com/tarjoilija/zgen.git ~/.zgen
git clone https://github.com/ktrysmt/dotfiles  ~/dotfiles
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
mkdir -p ~/.config/peco/
mkdir -p ~/.hammerspoon/
mkdir ~/.cache
mkdir ~/.local
mkdir ~/.ctags.d
ln -s ~/dotfiles/.snippet ~/.snippet
ln -s ~/dotfiles/.zshenv ~/.zshenv
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.tigrc ~/.tigrc
ln -s ~/dotfiles/.tmux.conf.osx ~/.tmux.conf
ln -s ~/dotfiles/.tern-project ~/.tern-project
ln -s ~/dotfiles/.config/peco/config.json ~/.config/peco/config.json
ln -s ~/dotfiles/.hammerspoon/init.lua ~/.hammerspoon/init.lua
ln -s ~/dotfiles/.ctags ~/.ctags.d/config.ctags
cp ~/dotfiles/.switch-proxy.osx ~/.switch-proxy
cp ~/dotfiles/.gitconfig ~/.gitconfig
wget -O ~/Library/Fonts/RictyDiminished-Regular.ttf https://github.com/edihbrandon/RictyDiminished/raw/master/RictyDiminished-Regular.ttf
wget -O ~/dotfiles/.hammerspoon/hyperex.lua https://raw.githubusercontent.com/hetima/hammerspoon-hyperex/master/hyperex.lua
ln -s ~/dotfiles/.hammerspoon/hyperex.lua ~/.hammerspoon/hyperex.lua
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
go get -u github.com/golangci/golangci-lint/cmd/golangci-lint
go get -u golang.org/x/tools/gopls@latest
vim +":PlugInstall" +":setfiletype go" +":GoInstallBinaries" +qa
npm i -g npm-check-updates neovim

echo "-----------------------------------------------------";
echo "Extra applications by brew cask";
echo "-----------------------------------------------------";
export HOMEBREW_CASK_OPTS="--appdir=/Applications";
brew tap caskroom/cask
brew cask install appcleaner google-japanese-ime iterm2 shiftit hyperswitch clipy docker qblocker hammerspoon visual-studio-code google-chrome google-chrome-canary
brew cask install virtualbox
brew cask install vagrant
brew cask cleanup

#brew cask install flux alfred itsycal keybase

#or use 'https://s3.amazonaws.com/LACRM_blog/createGcApp.dmg'

echo "-----------------------------------------------------";
echo "Rested tasks"
echo "-----------------------------------------------------";
sudo sh -c "echo $(which zsh) >> /etc/shells";
chsh -s $(which zsh)

