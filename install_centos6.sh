echo "-----------------------------------------------------";
echo "Update & install libraries";
echo "-----------------------------------------------------\n";
sudo yum -y update
sudo yum -y remove vim git
sudo yum -y install epel-release
sudo yum -y install ctags curl tig ncurses-devel make gcc wget php-cli openssl-devel perl-ExtUtils-MakeMaker gettext
sudo yum -y install python-devel lua-devel dstat curl-devel zlib-devel

echo "-----------------------------------------------------";
echo "Install Zsh, Git and tig"
echo "-----------------------------------------------------\n";
DOTFILES_TEMP_DIR=/tmp/dotfiles
mkdir $DOTFILES_TEMP_DIR
cd $DOTFILES_TEMP_DIR
wget http://downloads.sourceforge.net/project/zsh/zsh-dev/4.3.17/zsh-4.3.17.tar.gz
tar xvzf zsh-4.3.17.tar.gz
cd zsh-4.3.17 && ./configure --enable-multibyte && make && sudo make install

cd $DOTFILES_TEMP_DIR
wget https://www.kernel.org/pub/software/scm/git/git-2.6.3.tar.gz && \
tar -zxf git-2.6.3.tar.gz && \
cd git-2.6.3 && \
./configure && \
make && \
sudo make install

cd $DOTFILES_TEMP_DIR
git clone https://github.com/jonas/tig
cd tig
make
sudo make install

echo "-----------------------------------------------------";
echo "Setup my env"
echo "-----------------------------------------------------\n";
cd ~/
git clone https://github.com/tarjoilija/zgen.git ~/.zgen
git clone https://github.com/ktrysmt/dotfiles  ~/dotfiles
ln -s ~/dotfiles/.zshenv ~/.zshenv
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
echo "[ghq]
  root = ~/project/src" > ~/.gitconfig

echo "-----------------------------------------------------";
echo "Install Vim with lua";
echo "-----------------------------------------------------\n";
cd $DOTFILES_TEMP_DIR
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
echo "Install Go";
echo "-----------------------------------------------------\n";
GOLANG_VERSION=1.7.2
wget https://storage.googleapis.com/golang/go$GOLANG_VERSION.linux-amd64.tar.gz --no-check-certificate
tar -C /usr/local -xzf go$GOLANG_VERSION.linux-amd64.tar.gz
mkdir -p ~/project/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$HOME/project/bin:$PATH
export GOPATH=$HOME/project

echo "-----------------------------------------------------";
echo "Install Node"
echo "-----------------------------------------------------";
curl -L git.io/nodebrew | perl - setup
~/.nodebrew/nodebrew install-binary stable
~/.nodebrew/nodebrew use stable
curl -o- -L https://yarnpkg.com/install.sh | bash

echo "-----------------------------------------------------";
echo "Setup Other";
echo "-----------------------------------------------------\n";
sudo rpm -ivh http://swiftsignal.com/packages/centos/6/x86_64/the-silver-searcher-0.13.1-1.el6.x86_64.rpm
go get github.com/peco/peco/cmd/peco
go get github.com/motemen/ghq
mkdir -p ~/.config/peco/
cat ~/dotfiles/peco/config.json > ~/.config/peco/config.json
vim +":PlugInstall | :GoInstallBinaries" +:q
