# install general tools and libraries
#sudo apt-get -y dist-upgrade
sudo apt-get -y update
sudo apt-get -y install git ctags curl zsh tig make gcc wget dstat silversearcher-ag

sudo chsh -s /usr/bin/zsh

# put files to cache
mkdir ~/dotfiles
wget -O https://raw.github.com/aqafiam/dotfiles/master/.zshrc ~/dotfiles/.zshrc
wget -O https://raw.github.com/aqafiam/dotfiles/master/.vimrc ~/dotfiles/.vimrc

# setup vimrc
cd ~/
mkdir -p ~/.vim/bundle
git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
touch ~/.vimrc
cat ~/dotfiles/.vimrc >> ~/.vimrc

# setup dictionary for PHP
wget "http://coderepos.org/share/browser/lang/php/misc/dict.php?format=txt" -O /tmp/dict.php
mkdir -p ~/.vim/dictionaries/
php /tmp/dict.php | sort > ~/.vim/dictionaries/php.dict

# setup oh-my-zsh
cd ~/
touch ~/.zshrc
curl -L http://install.ohmyz.sh | sh
cat ~/dotfiles/.zshrc >> ~/.zshrc

# setup nodebrew for node (use stable:0.10)
cd ~/
wget git.io/nodebrew --no-check-certificate
perl nodebrew setup
echo 'export PATH=$HOME/.nodebrew/current/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
nodebrew install-binary v0.10
nodebrew use v0.10
source ~/.zshrc
npm install -g typescript typescript-tools

# install golang
wget https://storage.googleapis.com/golang/go1.5.linux-amd64.tar.gz --no-check-certificate
tar -C /usr/local -xzf go1.5.linux-amd64.tar.gz
source ~/.zshrc

# install utils
go get github.com/kr/godep
go get github.com/peco/peco/cmd/peco
go get github.com/motemen/ghq
echo "[ghq]
  root = ~/project/src" >> ~/.gitconfig

# install vim-plugins
wget --no-check-certificate https://raw.github.com/taku-o/downloads/master/visualmark.vim
mkdir -p ~/.vim/plugin/
mv visualmark.vim ~/.vim/plugin/

# setup vim
vim +":NeoBundleInstall | :NeoBundleUpdate | :GoInstallBinaries" +:q

# remove cache
rm -rf ~/dotfiles
