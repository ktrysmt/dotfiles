echo "----------------------------------------------------\n";
echo "You should install zsh and do that 'chsh -s /bin/zsh'";
echo "  "
echo "sudo apt-get -y install zsh"
echo "chsh -s /bin/zsh"
echo 'exec $SHELL'
echo "----------------------------------------------------\n";
sleep 3

# install general tools and libraries
#sudo apt-get -y dist-upgrade
sudo apt-get -y update
sudo apt-get -y install git ctags curl zsh tig make gcc wget dstat silversearcher-ag
sudo apt-get -y install liblua5.2-dev lua5.2 python-dev ncurses-dev

# put files to cache
mkdir ~/dotfiles
wget -O ~/dotfiles/.zshrc https://raw.githubusercontent.com/keidrip/dotfiles/master/.zshrc
wget -O ~/dotfiles/.vimrc https://raw.githubusercontent.com/keidrip/dotfiles/master/.vimrc

# install vim74
cd ~/
git clone https://github.com/vim/vim
cd vim;
./configure \
 --enable-multibyte \
 --with-features=huge \
 --enable-luainterp \
 --enable-multibyte \
 --disable-selinux \;
make && sudo make install

# setup vimrc
cd ~/
mkdir -p ~/.vim/bundle
git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
touch ~/.vimrc
cat ~/dotfiles/.vimrc >> ~/.vimrc

# setup dictionary for PHP
#wget "http://coderepos.org/share/browser/lang/php/misc/dict.php?format=txt" -O /tmp/dict.php
#mkdir -p ~/.vim/dictionaries/
#php /tmp/dict.php | sort > ~/.vim/dictionaries/php.dict

# setup oh-my-zsh
cd ~/
touch ~/.zshrc
curl -L http://install.ohmyz.sh | sh
cat ~/dotfiles/.zshrc >> ~/.zshrc

# setup nodebrew for node (use stable:0.10)
cd ~/
curl -L git.io/nodebrew | perl - setup
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
