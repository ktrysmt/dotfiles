#!/bin/bash

# base
sudo apt-get update
sudo apt-get install lilyterm
cd /tmp
wget https://github.com/edihbrandon/RictyDiminished/raw/master/RictyDiminished-Regular.ttf
mv /tmp/RictyDiminished-Regular.ttf /usr/local/share/fonts/
sudo fc-cache -fv

# applications
sudo add-apt-repository ppa:nilarimogard/webupd8
sudo apt-get update
sudo apt-get install albert
#sudo apt-get install launchy
sudo apt-get install chromium-browser

# xkb
echo 'partial hidden modifier_keys
xkb_symbols "keymap" {
    key <HENK> { [ Return ] };              // 変換をEnterに変更
    key <MUHE> { [ BackSpace ] };           // 無変換をバックスペースに変更
};' > ~/.xkb-user;
sudo ln -s ~/.xkb-user /usr/share/X11/xkb/symbols/user
echo '   user:keymap       =   +user(keymap)' >> /usr/share/X11/xkb/rules/evdev
setxkbmap -option user:keymap
