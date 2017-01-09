echo "-----------------------------------------------------";
echo "Install homebrew and libraries"
echo "-----------------------------------------------------";
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update
brew tap peco/peco
brew install ctags lua wget tmux peco git zsh nkf tree the_silver_searcher
brew install reattach-to-user-namespace
brew install vim --with-lua
brew install Caskroom/cask/iterm2
brew install Caskroom/cask/shiftit
brew cask install atom
brew tap jhawthorn/fzy
brew install fzy

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
echo "Install Go"
echo "-----------------------------------------------------";
GOLANG_VERSION=1.7.2
wget https://storage.googleapis.com/golang/go$GOLANG_VERSION.darwin-amd64.tar.gz --no-check-certificate
tar -C /usr/local -xzf go$GOLANG_VERSION.darwin-amd64.tar.gz
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
vim +":PlugInstall | :GoInstallBinaries" +:q

echo "-----------------------------------------------------";
echo "Rested tasks"
echo "-----------------------------------------------------";
echo "1. chsh -s /bin/zsh"
echo "2. source ~/.zshrc"
echo "3. After, should install coteditor atom hyperswitch karabiner diffmerge flux virtualbox vagrant firefox, and Ricty diminished Font."

