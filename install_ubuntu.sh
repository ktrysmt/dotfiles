echo -e "\e[31m-----------------------------------------------------
 Set Swapfile
-----------------------------------------------------\e[m";
if [ `free -m | grep Swap | awk '{print $4}'` = 0 ];then \
  sudo dd if=/dev/zero of=/swapfile bs=1024K count=512;
  sudo mkswap /swapfile;
  sudo swapon /swapfile;
  sudo echo "/swapfile               swap                    swap    defaults        0 0" | sudo tee -a /etc/fstab
fi;

echo -e "\e[31m-----------------------------------------------------
 Update & install libraries
-----------------------------------------------------\e[m";
sudo apt-get -y update
sudo apt-get -y install git ctags curl zsh tig make gcc dstat silversearcher-ag
sudo apt-get -y install libssl-dev libcurl4-openssl-dev
sudo apt-get -y install liblua5.2-dev lua5.2 python-dev ncurses-dev
sudo apt-get -y install mercurial gettext libncurses5-dev libxmu-dev libgtk2.0-dev libperl-dev python-dev python3-dev ruby-dev tcl-dev
sudo apt-get -y install luajit tmux

echo -e "\e[31m-----------------------------------------------------
 Setup my env
-----------------------------------------------------\e[m";
git clone https://github.com/tarjoilija/zgen.git ~/.zgen
git clone https://github.com/ktrysmt/dotfiles  ~/dotfiles
ln -s ~/dotfiles/.zshenv ~/.zshenv
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/.tern-project ~/.tern-project
ln -s ~/dotfiles/.gitconfig ~/.gitconfig

echo -e "\e[31m-----------------------------------------------------
 Install Vim with lua
-----------------------------------------------------\e[m";
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

echo -e "\e[31m-----------------------------------------------------
 Install Go
-----------------------------------------------------\e[m";
cd /tmp/dotfiles
GOLANG_VERSION=1.7.4
wget https://storage.googleapis.com/golang/go$GOLANG_VERSION.linux-amd64.tar.gz --no-check-certificate
sudo tar -C /usr/local -xzf go$GOLANG_VERSION.linux-amd64.tar.gz
mkdir -p ~/project/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$HOME/project/bin:$PATH
export GOPATH=$HOME/project

echo -e "\e[31m-----------------------------------------------------
 Install Node
-----------------------------------------------------\e[m";
cd ~/;
curl -L git.io/nodebrew | perl - setup
~/.nodebrew/nodebrew install-binary stable
~/.nodebrew/nodebrew use stable
curl -o- -L https://yarnpkg.com/install.sh | bash

echo -e "\e[31m-----------------------------------------------------
 Setup Other
-----------------------------------------------------\e[m";
go get github.com/peco/peco/cmd/peco
go get github.com/motemen/ghq
mkdir -p ~/.config/peco/
cat ~/dotfiles/peco/config.json > ~/.config/peco/config.json
vim +":PlugInstall | :GoInstallBinaries" +:q

