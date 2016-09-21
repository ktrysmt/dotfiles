GOLANG_VERSION=1.6.2

echo "-----------------------------------------------------";
echo "You should install zsh and do that 'chsh -s /bin/zsh'";
echo " "
echo "sudo apt-get -y install zsh"
echo "chsh -s /bin/zsh"
echo 'su - <current_user>'
echo "-----------------------------------------------------\n";
sleep 3

echo "-----------------------------------------------------";
echo "Update & install libraries";
echo "-----------------------------------------------------\n";
sudo apt-get -y update
#sudo apt-get -y upgrade
sudo apt-get -y install ctags curl zsh tig make gcc dstat silversearcher-ag
sudo apt-get -y install libssl-dev libcurl4-openssl-dev
sudo apt-get -y install liblua5.2-dev lua5.2 python-dev ncurses-dev
sudo apt-get -y install mercurial gettext libncurses5-dev libxmu-dev libgtk2.0-dev libperl-dev python-dev python3-dev ruby-dev tcl-dev
sudo apt-get -y install luajit gccgo-go

echo "-----------------------------------------------------";
echo "Put files and dirs";
echo "-----------------------------------------------------\n";
# dotfiles
mkdir ~/dotfiles
wget -O ~/dotfiles/.zshrc https://raw.githubusercontent.com/keidrip/dotfiles/master/.zshrc
wget -O ~/dotfiles/.vimrc https://raw.githubusercontent.com/keidrip/dotfiles/master/.vimrc.ubuntu
# vim
mkdir -p ~/.vim/bundle
touch ~/.vimrc
mkdir -p ~/.vim/plugin/
# ghq
echo "[ghq]
  root = ~/project/src" > ~/.gitconfig
source ~/.zshrc


echo "-----------------------------------------------------";
echo "Install latest git & tig";
echo "-----------------------------------------------------\n";
cd ~/
wget https://www.kernel.org/pub/software/scm/git/git-2.6.3.tar.gz && \
tar -zxf git-2.6.3.tar.gz && \
cd git-2.6.3 && \
make prefix=/usr/local all && \
sudo make prefix=/usr/local install
cd ~/
git clone https://github.com/jonas/tig
cd tig
make
sudo make install

echo "-----------------------------------------------------";
echo "Install vim74";
echo "-----------------------------------------------------\n";
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

echo "-----------------------------------------------------";
echo "Install vim plugins";
echo "-----------------------------------------------------\n";
cd ~/
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cat ~/dotfiles/.vimrc > ~/.vimrc

echo "-----------------------------------------------------";
echo "Install zgen";
echo "-----------------------------------------------------\n";
cd ~/
touch ~/.zshrc
git clone https://github.com/tarjoilija/zgen.git ~/.zgen
cat ~/dotfiles/.zshrc > ~/.zshrc
cat ~/dotfiles/.zshenv > ~/.zshenv

echo "-----------------------------------------------------";
echo "Install golang";
echo "-----------------------------------------------------\n";
wget https://storage.googleapis.com/golang/go$GOLANG_VERSION.linux-amd64.tar.gz --no-check-certificate
tar -C /usr/local -xzf go$GOLANG_VERSION.linux-amd64.tar.gz
mkdir -p ~/project/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$HOME/project/bin:$PATH
export GOPATH=$HOME/project

echo "-----------------------------------------------------";
echo "Install node;
echo "-----------------------------------------------------\n";
curl -L git.io/nodebrew | perl - setup
~/.nodebrew/nodebrew install-binary stable
~/.nodebrew/nodebrew use stable

echo "-----------------------------------------------------";
echo "Run go get";
echo "-----------------------------------------------------\n";
go get github.com/peco/peco/cmd/peco
go get github.com/motemen/ghq

echo "-----------------------------------------------------";
echo "Setup peco";
echo "-----------------------------------------------------\n";
mkdir -p ~/.config/peco/
cat ~/dotfiles/peco/config.json > ~/.config/peco/config.json

echo "-----------------------------------------------------";
echo "Run NeoBundleInstall & GoInstallBinaries";
echo "-----------------------------------------------------\n";
vim +":PlugInstall | :GoInstallBinaries" +:q

echo "-----------------------------------------------------";
echo "Apply .zshrc";
echo "-----------------------------------------------------\n";
source ~/.zshrc

# remove cache
rm -rf ~/dotfiles
