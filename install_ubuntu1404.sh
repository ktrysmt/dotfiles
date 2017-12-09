#!/bin/sh
set -e
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
# update
sudo apt-get -y update

# common tools
sudo apt-get -y install curl zsh make gcc dstat wget tmux

# ruby2.3
sudo apt-get -y install software-properties-common
sudo apt-add-repository ppa:brightbox/ruby-ng
sudo apt-get -y update
sudo apt-get -y install ruby2.3

# linuxbrew
yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
sudo apt-get install -y build-essential
echo 'export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"' >>~/.profile
echo 'export MANPATH="/home/linuxbrew/.linuxbrew/share/man:$MANPATH"' >>~/.profile
echo 'export INFOPATH="/home/linuxbrew/.linuxbrew/share/info:$INFOPATH"' >>~/.profile
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
brew install ripgrep exa fd direnv peco ghq git tig

# neovim
sudo apt-get -y install software-properties-common
sudo apt-get -y install python3.4-venv
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt-get -y update
sudo apt-get -y install neovim
sudo apt-get -y install python-dev python-pip python3-dev python3-pip

# fzy
cd /tmp
wget https://github.com/jhawthorn/fzy/releases/download/0.9/fzy_0.9-1_amd64.deb
sudo dpkg -i fzy_0.9-1_amd64.deb
cd ~/

# yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get -y update && sudo apt-get -y install yarn

# ctags
sudo apt-get -y install pkg-config autoconf
cd /tmp/
git clone --depth 1 https://github.com/universal-ctags/ctags.git
cd ctags;
./autogen.sh && ./configure && make && sudo make install;
cd ~/

echo "-----------------------------------------------------";
echo " Setup my env";
echo "-----------------------------------------------------";
git clone https://github.com/tarjoilija/zgen.git ~/.zgen
git clone https://github.com/ktrysmt/dotfiles  ~/dotfiles
mkdir -p ~/.config/peco/
ln -s ~/dotfiles/.config/peco/config.json ~/.config/peco/config.json
ln -s ~/dotfiles/.zshenv ~/.zshenv
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.tigrc ~/.tigrc
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/.tern-project ~/.tern-project
cp ~/dotfiles/.gitconfig ~/.gitconfig
echo "[credential]
  helper = gnomekeyring" >> ~/.gitconfig
echo "wget -O ~/.zgen/zsh-users/zsh-completions-master/src/_docker https://raw.githubusercontent.com/docker/docker/master/contrib/completion/zsh/_docker" | zsh
echo "wget -O ~/.zgen/zsh-users/zsh-completions-master/src/_docker-compose https://raw.githubusercontent.com/docker/compose/master/contrib/completion/zsh/_docker-compose" | zsh
cd ~/
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
yes | ~/.fzf/install

echo "-----------------------------------------------------";
echo "Install Goenv";
echo "-----------------------------------------------------";
git clone https://github.com/syndbg/goenv.git ~/.goenv
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
goenv install 1.9.2
goenv global 1.9.2
goenv rehash
eval "$(goenv init -)"

echo "-----------------------------------------------------";
echo "Install Rust";
echo "-----------------------------------------------------";
cd /tmp/dotfiles
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env

echo "-----------------------------------------------------";
echo "Setup Golang";
echo "-----------------------------------------------------";
mkdir -p ~/project/bin
export PATH=$HOME/project/bin:$PATH
export GOPATH=$HOME/project

echo "-----------------------------------------------------";
echo "Install NodeJS";
echo "-----------------------------------------------------";
cd ~/;
curl -L git.io/nodebrew | perl - setup
~/.nodebrew/nodebrew install-binary stable
~/.nodebrew/nodebrew use stable

echo "-----------------------------------------------------";
echo "Neovim";
echo "-----------------------------------------------------";
sudo easy_install3 pip
sudo easy_install-2.7 pip
sudo pip2 install neovim
sudo pip3 install neovim
sudo ln -sf $(which nvim) /usr/local/bin/vim
ln -s ~/.vim ~/.config/nvim
ln -s ~/.vimrc ~/.config/nvim/init.vim

echo "-----------------------------------------------------";
echo "Setup Other";
echo "-----------------------------------------------------";
curl https://glide.sh/get | sh
vim +":PlugInstall" +":setfiletype go" +":GoInstallBinaries" +":PythonSupportInitPython2" +":PythonSupportInitPython3" +qa
npm install -g npm-check-updates
echo $PASSWORD | chsh -s /bin/zsh
zsh


