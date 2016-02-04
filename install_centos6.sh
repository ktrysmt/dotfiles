echo "----------------------------------------------------\n";
echo "You should install zsh and do that 'chsh -s /bin/zsh'";
echo "  "
echo "sudo yum -y install zsh"
echo "chsh -s /bin/zsh"
echo 'exec $SHELL'
echo "----------------------------------------------------\n";
sleep 3

# install general tools and libraries
#sudo yum -y update
sudo yum -y install epel-release
sudo yum -y install ctags curl tig ncurses-devel make gcc wget
sudo yum -y install python-devel lua-devel dstat
sudo yum -y remove vim git

# switch zsh
#sudo yum -y install zsh
#chsh -s /bin/zsh

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

# put files to cache
mkdir ~/dotfiles
wget -O ~/dotfiles/.zshrc https://raw.githubusercontent.com/aqafiam/dotfiles/master/.zshrc
wget -O ~/dotfiles/.vimrc https://raw.githubusercontent.com/aqafiam/dotfiles/master/.vimrc

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
wget "http://coderepos.org/share/browser/lang/php/misc/dict.php?format=txt" -O /tmp/dict.php
mkdir -p ~/.vim/dictionaries/
php /tmp/dict.php | sort > ~/.vim/dictionaries/php.dict

# setup oh-my-zsh
cd ~/
touch ~/.zshrc
#curl -L http://install.ohmyz.sh | sh
#git clone https://github.com/tarjoilija/zgen ~/.zgen
git clone https://github.com/b4b4r07/zplug ~/.zplug
cat ~/dotfiles/.zshrc >> ~/.zshrc
source ~/.zshrc

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
touch ~/.gitconfig
echo "[ghq]
  root = ~/project/src" >> ~/.gitconfig

# ag
sudo rpm -ivh http://swiftsignal.com/packages/centos/6/x86_64/the-silver-searcher-0.13.1-1.el6.x86_64.rpm

# install vim-plugins
wget --no-check-certificate https://raw.github.com/taku-o/downloads/master/visualmark.vim
mkdir -p ~/.vim/plugin/
mv visualmark.vim ~/.vim/plugin/

# setup vim-plugins
vim +":NeoBundleInstall | :NeoBundleUpdate | :GoInstallBinaries" +:q

# tmxu 1.8
cd ~/dotfiles
wget https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz
tar xvzf libevent-2.0.21-stable.tar.gz
cd libevent-2.0.21-stable
./configure && make && make install
wget -O tmux-1.8.tar.gz "http://sourceforge.net/projects/tmux/files/tmux/tmux-1.8/tmux-1.8.tar.gz/download?use_mirror=jaist"
tar xvzf tmux-1.8.tar.gz
cd tmux-1.8
./configure && make && make install

# remove cache
rm -rf ~/dotfiles
