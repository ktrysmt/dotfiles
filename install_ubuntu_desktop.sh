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
sudo apt-get install chromium-browser
