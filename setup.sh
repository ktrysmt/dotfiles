# general
yum -y install git ctags php curl

# for vimrc
cd ~/
mkdir -p ~/.vim/bundle
git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
wget http://coderepos.org/share/export/39278/lang/php/misc/dict.php
mkdir -p ~/.vim/dictionaries/
php dict.php | sort > ~/.vim/dictionaries/php.dict
touch ~/.vimrc
cat dotfiles.vimrc >> ~/.vimrc

# for bashrc
cd ~/
git clone git://github.com/creationix/nvm.git ~/.nvm
source ~/.nvm/nvm.sh
nvm install v0.11
wget https://storage.googleapis.com/golang/go1.3.1.linux-amd64.tar.gz
tar xzf go1.3.1.linux-amd64.tar.gz
cat dotfiles.bashrc >> ~/.bashrc
source ~/.bashrc
go get github.com/peco/peco/cmd/peco/


