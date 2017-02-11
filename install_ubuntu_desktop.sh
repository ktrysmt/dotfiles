#!/bin/bash

# base
sudo apt-get update
sudo apt-get install lilyterm
cd /tmp
wget https://github.com/edihbrandon/RictyDiminished/raw/master/RictyDiminished-Regular.ttf
mv /tmp/RictyDiminished-Regular.ttf /usr/local/share/fonts/
sudo fc-cache -fv

# applications
sudo apt-get install launchy

## chrome(1)
sudo apt-get install libappindicator1
echo "1. access to https://www.google.co.jp/chrome/browser/desktop/index.html"
echo "2. install by dpkg: 'sudo dpkg -i ~/google-chrome-stable_current_amd64.deb'"
## chrome(2)
sudo wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
sudo apt-get install google-chrome-stable
