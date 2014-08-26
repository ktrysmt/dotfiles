# for vimrc
cd ~/
yum -y install git ctags php
mkdir -p ~/.vim/bundle
git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
wget http://coderepos.org/share/export/39278/lang/php/misc/dict.php
mkdir -p ~/.vim/dictionaries/
php dict.php | sort > ~/.vim/dictionaries/php.dict
touch ~/.vimrc


