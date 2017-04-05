echo "-----------------------------------------------------";
echo "Install homebrew and libraries"
echo "-----------------------------------------------------";
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update
sudo brew install peco
brew install ctags lua wget tmux peco git zsh nkf tree ripgrep
brew install reattach-to-user-namespace
brew install vim --with-lua
sudo brew install go

echo "-----------------------------------------------------";
echo "Setup my env"
echo "-----------------------------------------------------";
cd ~/
git clone https://github.com/tarjoilija/zgen.git ~/.zgen
git clone https://github.com/ktrysmt/dotfiles  ~/dotfiles
ln -s ~/dotfiles/.zshenv ~/.zshenv
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.tmux.conf.osx ~/.tmux.conf
ln -s ~/dotfiles/.tern-project ~/.tern-project
ln -s ~/dotfiles/.gitconfig ~/.gitconfig

echo "-----------------------------------------------------";
echo "Install Node"
echo "-----------------------------------------------------";
curl -L git.io/nodebrew | perl - setup
~/.nodebrew/nodebrew install-binary stable
~/.nodebrew/nodebrew use stable
curl -o- -L https://yarnpkg.com/install.sh | bash

echo "-----------------------------------------------------";
echo "Setup Go"
echo "-----------------------------------------------------";
mkdir -p ~/project/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$HOME/project/bin:$PATH
export GOPATH=$HOME/project

echo "-----------------------------------------------------";
echo "Setup Other";
echo "-----------------------------------------------------";
go get github.com/motemen/ghq
mkdir -p ~/.config/peco/
cat ~/dotfiles/.config/peco/config.json > ~/.config/peco/config.json
vim +":PlugInstall" +":GoInstallBinaries" +:q

echo "-----------------------------------------------------";
echo "Extra applications by brew cask";
echo "-----------------------------------------------------";
brew cask install iterm2
brew cask install shiftit
brew cask install atom
brew cask install hyperswitch
brew cask install karabiner
brew cask install diffmerge
brew cask install flux
brew cask install virtualbox
brew cask install vagrant
brew cask install alfred
brew cask install clipy
brew cask install google-japanese-ime
brew cask install firefox
brew cask install visual-studio-code
brew cask install google-chrome

echo "-----------------------------------------------------";
echo "Rested tasks"
echo "-----------------------------------------------------";
echo "1. chsh -s /bin/zsh"
echo "2. source ~/.zshrc"
echo "3. After; should install coteditor, Ricty diminished Font."
