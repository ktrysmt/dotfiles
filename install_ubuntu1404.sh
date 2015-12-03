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
sudo apt-get -y install ctags curl zsh tig make gcc wget dstat silversearcher-ag
sudo apt-get -y install liblua5.2-dev lua5.2 python-dev ncurses-dev
sudo apt-get -y install mercurial gettext libncurses5-dev libxmu-dev libgtk2.0-dev libperl-dev python-dev python3-dev ruby-dev tcl-dev
sudo apt-get -y install luajit

# put files to cache
mkdir ~/dotfiles
wget -O ~/dotfiles/.zshrc https://raw.githubusercontent.com/keidrip/dotfiles/master/.zshrc
wget -O ~/dotfiles/.vimrc https://raw.githubusercontent.com/keidrip/dotfiles/master/.vimrc.ubuntu

# install git,tig
cd ~/
wget https://www.kernel.org/pub/software/scm/git/git-2.6.3.tar.gz && \
tar -zxf git-2.6.3.tar.gz && \
cd git-2.6.3 && \
make prefix=/usr/local all && \
make prefix=/usr/local install
cd ~/
git clone https://github.com/jonas/tig
cd tig
make
sudo make install

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
touch ~/.vimrc
cat ~/dotfiles/.vimrc >> ~/.vimrc
git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
wget --no-check-certificate https://raw.github.com/taku-o/downloads/master/visualmark.vim
mkdir -p ~/.vim/plugin/
mv visualmark.vim ~/.vim/plugin/

# setup oh-my-zsh
cd ~/
touch ~/.zshrc
curl -L http://install.ohmyz.sh | sh
cat ~/dotfiles/.zshrc >> ~/.zshrc

# setup nodebrew for node (use stable:0.10)
cd ~/
curl -L git.io/nodebrew | perl - setup
echo 'export PATH=$HOME/.nodebrew/current/bin:$PATH' >> ~/.zshrc
exec $SHELL
nodebrew install-binary v0.10
nodebrew use v0.10
exec $SHELL
npm install -g typescript typescript-tools

# install golang
wget https://storage.googleapis.com/golang/go1.5.linux-amd64.tar.gz --no-check-certificate
tar -C /usr/local -xzf go1.5.linux-amd64.tar.gz
exec $SHELL

# install utils
go get github.com/kr/godep
go get github.com/peco/peco/cmd/peco
go get github.com/motemen/ghq
echo "[ghq]
  root = ~/project/src" >> ~/.gitconfig
exec $SHELL

# setup vim
vim +":NeoBundleInstall | :NeoBundleUpdate | :GoInstallBinaries" +:q

# remove cache
rm -rf ~/dotfiles
