# general
yum -y install git ctags php curl zsh

# for vimrc
cd ~/
mkdir -p ~/.vim/bundle
git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
wget http://coderepos.org/share/export/39278/lang/php/misc/dict.php
mkdir -p ~/.vim/dictionaries/
php dict.php | sort > ~/.vim/dictionaries/php.dict
touch ~/.vimrc
cat dotfiles/dotfiles.vimrc >> ~/.vimrc

# for zshrc
cd ~/
git clone git://github.com/creationix/nvm.git ~/.nvm
source ~/.nvm/nvm.sh
nvm install v0.11
wget https://github.com/peco/peco/releases/download/v0.2.10/peco_linux_amd64.tar.gz
tar xzf peco_linux_amd64.tar.gz
\cp -f peco_linux_amd64/peco /usr/local/bin/
cat dotfiles/dotfiles.zshrc >> ~/.zshrc
source ~/.zshrc
