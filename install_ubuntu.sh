echo "-----------------------------------------------------";
echo "Update & install libraries";
echo "-----------------------------------------------------\n";
sudo apt-get -y update
sudo apt-get -y install git ctags curl zsh tig make gcc dstat silversearcher-ag
sudo apt-get -y install libssl-dev libcurl4-openssl-dev
sudo apt-get -y install liblua5.2-dev lua5.2 python-dev ncurses-dev
sudo apt-get -y install mercurial gettext libncurses5-dev libxmu-dev libgtk2.0-dev libperl-dev python-dev python3-dev ruby-dev tcl-dev
sudo apt-get -y install luajit tmux

echo "-----------------------------------------------------";
echo "Setup my env"
echo "-----------------------------------------------------\n";
git clone https://github.com/tarjoilija/zgen.git ~/.zgen
git clone https://github.com/ktrysmt/dotfiles  ~/dotfiles
ln -s ~/dotfiles/.zshenv ~/.zshenv
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/.tern-project ~/.tern-project
ln -s ~/dotfiles/.gitconfig ~/.gitconfig

echo "-----------------------------------------------------";
echo "Install Vim with lua";
echo "-----------------------------------------------------\n";
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
echo "Install Go";
echo "-----------------------------------------------------\n";
GOLANG_VERSION=1.7.4
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
go get github.com/peco/peco/cmd/peco
go get github.com/motemen/ghq
mkdir -p ~/.config/peco/
cat ~/dotfiles/peco/config.json > ~/.config/peco/config.json
vim +":PlugInstall | :GoInstallBinaries" +:q

