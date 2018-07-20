#!/bin/bash
set -o pipefail 
set -vxeu

echo "-----------------------------------------------------";
echo "for Vagrant";
echo "-----------------------------------------------------";
if [ ! $PASSWORD ] && [ `who am i | awk '{print $1}'` = "vagrant" ]; then \
  PASSWORD="vagrant";
  sudo chown -R vagrant:vagrant /usr/local;
fi;

echo "-----------------------------------------------------";
echo "Set Swapfile";
echo "-----------------------------------------------------";
if [ `free -m | grep Swap | awk '{print $4}'` = 0 ];then \
  sudo dd if=/dev/zero of=/swapfile bs=1024K count=512;
  sudo mkswap /swapfile;
  sudo swapon /swapfile;
  sudo echo "/swapfile               swap                    swap    defaults        0 0" | sudo tee -a /etc/fstab
fi;

echo "-----------------------------------------------------";
echo "Update & install libraries";
echo "-----------------------------------------------------";
# update
sudo apt-get -y update

# common tools
sudo apt-get -y install build-essential zsh make gcc wget xsel Xvfb

# ruby2.3 (for linuxbrew)
sudo apt-get -y install software-properties-common
yes | sudo apt-add-repository ppa:brightbox/ruby-ng
sudo apt-get -y update
sudo apt-get -y install ruby2.3

# linuxbrew
yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
echo 'export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"' >>~/.profile
echo 'export MANPATH="/home/linuxbrew/.linuxbrew/share/man:$MANPATH"' >>~/.profile
echo 'export INFOPATH="/home/linuxbrew/.linuxbrew/share/info:$INFOPATH"' >>~/.profile
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
brew install git python python@2 ripgrep exa fd direnv peco ghq tig tmux neovim fzy fzf jq

# anyenv
git clone https://github.com/riywo/anyenv ~/.anyenv
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"
exec $SHELL -l
# rbenv and ndenv
mkdir -p $(anyenv root)/plugins
git clone https://github.com/znz/anyenv-update.git $(anyenv root)/plugins/anyenv-update
anyenv install ndenv
anyenv install rbenv
anyenv install goenv
eval "$(anyenv init -)"
exec $SHELL -l
ndenv install v8.11.3
ndenv rehash
ndenv global v8.11.3
goenv install 1.10.3
goenv rehash
goenv global 1.10.3

# neovim
sudo ln -sf $(which nvim) /usr/local/bin/vim

# yarn
brew install yarn --without-node

# ctags
sudo apt-get -y install pkg-config autoconf
cd /tmp/
git clone --depth 1 https://github.com/universal-ctags/ctags.git
cd ctags;
./autogen.sh && ./configure && make && make install;
cd ~/

echo "-----------------------------------------------------";
echo " Setup my env";
echo "-----------------------------------------------------";
git clone https://github.com/tarjoilija/zgen.git ~/.zgen
git clone https://github.com/ktrysmt/dotfiles  ~/dotfiles
mkdir -p ~/.config/peco/
mkdir ~/.cache
mkdir ~/.local
ln -s ~/dotfiles/.config/peco/config.json ~/.config/peco/config.json
ln -s ~/dotfiles/.snippet ~/.snippet
ln -s ~/dotfiles/.zshenv ~/.zshenv
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.tigrc ~/.tigrc
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.tmux.conf.linux ~/.tmux.conf
ln -s ~/dotfiles/.tern-project ~/.tern-project
cp ~/dotfiles/.gitconfig ~/.gitconfig
echo "[credential]
  helper = gnomekeyring" >> ~/.gitconfig
cd ~/
if [ `who am i | awk '{print $1}'` = "vagrant" ]; then \
  ln -s ~/dotfiles/.zshrc.ubuntu1404.vagrant ~/.zshrc.private
fi;

echo "-----------------------------------------------------";
echo "Setup Go"
echo "-----------------------------------------------------";
mkdir -p ~/project/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$HOME/go/bin:$HOME/project/bin:$PATH
export GOPATH=$HOME/go:$HOME/project

echo "-----------------------------------------------------";
echo "Install Rust";
echo "-----------------------------------------------------";
cd /tmp/dotfiles
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env

echo "-----------------------------------------------------";
echo "Setup Neovim";
echo "-----------------------------------------------------";
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
mkdir -p ~/.config/nvim/
ln -s ~/.vimrc ~/.config/nvim/init.vim
pip2 install neovim
pip3 install neovim
ln -sf $(which nvim) /usr/local/bin/vim

echo "-----------------------------------------------------";
echo "Setup Other";
echo "-----------------------------------------------------";
go get github.com/motemen/ghq
go get github.com/golang/dep/...
vim +":PlugInstall" +":setfiletype go" +":GoInstallBinaries" +qa
yarn global add npm-check-updates neovim

echo "-----------------------------------------------------";
echo "Rested tasks"
echo "-----------------------------------------------------";
echo $PASSWORD | chsh -s /bin/zsh
zsh


