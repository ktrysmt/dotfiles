GOLANG_VERSION=1.7.1

echo "#### Install homebrew, softwares and libraries"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update
brew tap peco/peco
brew install ctags lua wget tmux peco git zsh nkf tree the_silver_searcher
brew install reattach-to-user-namespace
brew install vim --with-lua
brew install Caskroom/cask/iterm2
brew install Caskroom/cask/shiftit

echo "#### Setup my env"
cd ~/
git clone https://github.com/tarjoilija/zgen.git ~/.zgen
git clone https://github.com/ktrysmt/dotfiles  ~/dotfiles
ln -s ~/dotfiles/.zshenv ~/.zshenv
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.vimrc.mac ~/.vimrc
ln -s ~/dotfiles/.tmux.conf.osx ~/.tmux.conf

echo "#### Install Node"
curl -L git.io/nodebrew | perl - setup
~/.nodebrew/nodebrew install-binary stable
~/.nodebrew/nodebrew use stable
curl -o- -L https://yarnpkg.com/install.sh | bash

echo "#### Install Go"
wget https://storage.googleapis.com/golang/go$GOLANG_VERSION.darwin-amd64.tar.gz --no-check-certificate
tar -C /usr/local -xzf go$GOLANG_VERSION.darwin-amd64.tar.gz
mkdir -p ~/project/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$HOME/project/bin:$PATH
export GOPATH=$HOME/project

echo "#### Setup Other"
go get github.com/motemen/ghq
mkdir -p ~/.config/peco/
cat ~/dotfiles/.config/peco/config.json > ~/.config/peco/config.json
vim +":PlugInstall | :GoInstallBinaries" +:q

echo "#### Rested tasks"
echo "1. chsh -s /bin/zsh"
echo "2. source ~/.zshrc"
echo "3. After, should install coteditor atom hyperswitch karabiner diffmerge flux virtualbox vagrant firefox, and Ricty diminished Font."
