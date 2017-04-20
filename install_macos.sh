echo "-----------------------------------------------------";
echo "Install homebrew and libraries"
echo "-----------------------------------------------------";
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update
brew install peco ctags lua wget tmux peco git zsh nkf tree ripgrep reattach-to-user-namespace go
brew install vim --with-lua

echo "-----------------------------------------------------";
echo "Setup my env"
echo "-----------------------------------------------------";
cd ~/
git clone https://github.com/tarjoilija/zgen.git ~/.zgen
git clone https://github.com/ktrysmt/dotfiles  ~/dotfiles
mkdir -p ~/.config/peco/
ln -s ~/dotfiles/.zshenv ~/.zshenv
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.tmux.conf.osx ~/.tmux.conf
ln -s ~/dotfiles/.tern-project ~/.tern-project
ln -s ~/dotfiles/.config/peco/config.json ~/.config/peco/config.json
cp ~/dotfiles/.gitconfig ~/.gitconfig
wget -O ~/Library/Fonts/RictyDiminished-Regular.ttf https://github.com/edihbrandon/RictyDiminished/raw/master/RictyDiminished-Regular.ttf

echo "-----------------------------------------------------"; 
echo "Install Rust";
echo "-----------------------------------------------------"; 
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env

echo "-----------------------------------------------------";
echo "Install Node"
echo "-----------------------------------------------------";
curl -L git.io/nodebrew | perl - setup
export PATH=$HOME/.nodebrew/current/bin:$PATH
~/.nodebrew/nodebrew install-binary stable
~/.nodebrew/nodebrew use stable
curl -o- -L https://yarnpkg.com/install.sh | bash
export PATH="$HOME/.yarn/bin:$PATH"

echo "-----------------------------------------------------";
echo "Setup Go"
echo "-----------------------------------------------------";
mkdir -p ~/project/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$HOME/project/bin:$PATH
export GOPATH=$HOME/project

echo "-----------------------------------------------------";
echo "Extra applications by brew cask";
echo "-----------------------------------------------------";
export HOMEBREW_CASK_OPTS="--appdir=/Applications";
brew tap caskroom/cask
brew cask install slack
brew cask install google-japanese-ime
brew cask install iterm2
brew cask install visual-studio-code
brew cask install google-chrome
brew cask install shiftit
brew cask install hyperswitch
brew cask install flux
brew cask install virtualbox
brew cask install vagrant
brew cask install alfred
brew cask install clipy
brew cask install docker
brew cask install firefox
brew cask install karabiner
brew cask cleanup

echo "-----------------------------------------------------";
echo "Setup Other";
echo "-----------------------------------------------------";
go get github.com/motemen/ghq
go get github.com/golang/dep/...
vim +":PlugInstall" +":setfiletype go" +":GoInstallBinaries" +qa

echo "-----------------------------------------------------";
echo "Rested tasks"
echo "-----------------------------------------------------";
sudo sh -c "echo $(which zsh) >> /etc/shells";
chsh -s $(which zsh)

echo "-----------------------------------------------------";
echo "After the runner..."
echo "-----------------------------------------------------";
echo " "
echo "> Input below for zsh completion."
echo 'echo "wget -O ~/.zgen/zsh-users/zsh-completions-master/src/_docker https://raw.githubusercontent.com/docker/docker/master/contrib/completion/zsh/_docker" | zsh'
echo 'echo "wget -O ~/.zgen/zsh-users/zsh-completions-master/src/_docker-compose https://raw.githubusercontent.com/docker/compose/master/contrib/completion/zsh/_docker-compose" | zsh'
echo "> Get it."
echo "* https://www.dropbox.com/sh/mvtyuvjl8ht5tnz/AABe5m8YmCcKYhUFEiUT7v58a?dl=0"
echo "* https://s3.amazonaws.com/LACRM_blog/createGcApp.dmg"
