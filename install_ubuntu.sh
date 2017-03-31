#!/bin/sh
set -e
GOLANG_VERSION=1.8;
if [ ! $PASSWORD ] && [ `who am i | awk '{print $1}'` = "vagrant" ]; then \
  PASSWORD="vagrant";
fi;

echo "-----------------------------------------------------";
echo " Set Swapfile";
echo "-----------------------------------------------------";
if [ `free -m | grep Swap | awk '{print $4}'` = 0 ];then \
  sudo dd if=/dev/zero of=/swapfile bs=1024K count=512;
  sudo mkswap /swapfile;
  sudo swapon /swapfile;
  sudo echo "/swapfile               swap                    swap    defaults        0 0" | sudo tee -a /etc/fstab
fi;

echo "-----------------------------------------------------";
echo " Update & install libraries";
echo "-----------------------------------------------------"; 
sudo apt-get -y update
sudo apt-get -y install git ctags curl zsh tig make gcc dstat 
sudo apt-get -y install libssl-dev libcurl4-openssl-dev
sudo apt-get -y install liblua5.2-dev lua5.2 python-dev ncurses-dev
sudo apt-get -y install mercurial gettext libncurses5-dev libxmu-dev libgtk2.0-dev libperl-dev python-dev python3-dev ruby-dev tcl-dev
sudo apt-get -y install luajit tmux

echo "-----------------------------------------------------";
echo " Setup my env";
echo "-----------------------------------------------------"; 
git clone https://github.com/tarjoilija/zgen.git ~/.zgen
git clone https://github.com/ktrysmt/dotfiles  ~/dotfiles
mkdir -p ~/.config/peco/
ln -s ~/dotfiles/.config/peco/config.json ~/.config/peco/config.json
ln -s ~/dotfiles/.zshenv ~/.zshenv
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/.tern-project ~/.tern-project
cp ~/dotfiles/.gitconfig ~/.gitconfig

echo "-----------------------------------------------------"; 
echo "Install Vim with lua";
echo "-----------------------------------------------------"; 
mkdir /tmp/dotfiles
cd /tmp/dotfiles
git clone https://github.com/vim/vim
cd vim;
./configure \
 --enable-multibyte \
 --with-features=huge \
 --enable-luainterp \
 --enable-multibyte \
 --disable-selinux \;
make && sudo make install

echo "-----------------------------------------------------"; 
echo "Install Rust";
echo "-----------------------------------------------------"; 
cd /tmp/dotfiles
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
cargo install ripgrep

echo "-----------------------------------------------------"; 
echo "Install Golang";
echo "-----------------------------------------------------"; 
cd /tmp/dotfiles
wget https://storage.googleapis.com/golang/go$GOLANG_VERSION.linux-amd64.tar.gz --no-check-certificate
sudo tar -C /usr/local -xzf go$GOLANG_VERSION.linux-amd64.tar.gz
mkdir -p ~/project/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$HOME/project/bin:$PATH
export GOPATH=$HOME/project

echo "-----------------------------------------------------"; 
echo "Install NodeJS";
echo "-----------------------------------------------------"; 
cd ~/;
curl -L git.io/nodebrew | perl - setup
~/.nodebrew/nodebrew install-binary stable
~/.nodebrew/nodebrew use stable
curl -o- -L https://yarnpkg.com/install.sh | bash

echo "-----------------------------------------------------"; 
echo " Setup Other";
echo "-----------------------------------------------------"; 
go get github.com/peco/peco/cmd/peco
go get github.com/motemen/ghq
curl https://glide.sh/get | sh
vim +":PlugInstall" +":setfiletype go" +":GoInstallBinaries" +qa
echo $PASSWORD | chsh -s /bin/zsh
