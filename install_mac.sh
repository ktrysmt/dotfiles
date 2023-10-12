#!/bin/bash

set -o pipefail
set -e

# brew
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install \
  curl \
  openssl \
  reattach-to-user-namespace \
  lima \
  go \
  wget \
  tmux \
  zsh \
  nkf \
  tree \
  ripgrep \
  fd \
  procs \
  fzf \
  sheldon \
  tig \
  fzy \
  peco \
  eza \
  python3 \
  jq \
  git-secrets \
  bat \
  watch \
  ghq \
  git \
  git-delta \
  kind \
  kubectl \
  minikube \
  kubectx \
  kubernetes-helm \
  coreutils \
  rust-analyzer \
  llvm \
  gopls \
  neovim \
  asdf \
  raycast \
  golangci-lint
brew install --HEAD universal-ctags/universal-ctags/universal-ctags
$(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc

# asdf
asdf plugin add nodejs
asdf install nodejs latest
asdf install python latest
asdf global nodejs latest
asdf global python latest

# symlink
cd ~/
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
mkdir -p ~/.config/sheldon/
mkdir -p ~/.config/peco/
mkdir -p ~/.local/bin/
mkdir -p ~/.cache/vim/
mkdir ~/.docker
ln -s ~/dotfiles/.snippet ~/.snippet
ln -s ~/dotfiles/.zshenv ~/.zshenv
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/nvim/ ~/.config/nvim/
ln -s ~/dotfiles/.tigrc ~/.tigrc
ln -s ~/dotfiles/.tmux.conf.osx ~/.tmux.conf
ln -s ~/dotfiles/.config/peco/config.json ~/.config/peco/config.json
ln -s ~/dotfiles/zsh/sheldon.plugins.toml ~/.config/sheldon/plugins.toml
ln -s ~/dotfiles/.gitignore_global ~/.gitignore_global
cp ~/dotfiles/.ctags ~/.ctags
cp ~/dotfiles/.gitconfig ~/.gitconfig
cp ~/dotfiles/.docker/config.json ~/.docker/config.json

# cp ~/dotfiles/.switch-proxy.osx ~/.switch-proxy

# ssh
mkdir ~/.ssh
touch ~/.ssh/config
echo "ServerAliveInterval 15" >> ~/.ssh/config
echo "ServerAliveCountMax 10" >> ~/.ssh/config

# editor
sudo ln -sf $(which nvim) /usr/local/bin/vim
python -m pip install --user --upgrade pynvim
python -m pip install --user --upgrade neovim
go install github.com/go-delve/delve/cmd/dlv@latest
npm i -g npm-check-updates neovim @fsouza/prettierd eslint_d

# git config
git secrets --register-aws --global
git secrets --install ~/.git-templates/git-secrets
git config --global init.templatedir '~/.git-templates/git-secrets'
git config --global credential.helper osxkeychain
git config --global core.excludesfile ~/.gitignore_global

# go
mkdir -p ~/project/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$HOME/go/bin:$HOME/project/bin:$PATH
export GOPATH=$HOME/go:$HOME/project

# k8s
(
  set -x
  cd "$(mktemp -d)" \
    && curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.{tar.gz,yaml}" \
    && tar zxvf krew.tar.gz \
    && KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_amd64" \
    && "$KREW" install --manifest=krew.yaml --archive=krew.tar.gz \
    && "$KREW" update
)
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
kubectl krew install tree open-svc

# rust
# setting up of rust components is here: https://gist.github.com/ktrysmt/9601264b37f8e46cad1e7075850478fb
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env

# brew cask
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
brew tap homebrew/cask
brew install --cask appcleaner kindle iterm2 rectangle alt-tab clipy visual-studio-code mos macgesture flux gomi
brew install --cask karabiner-elements wordservice brave-browser itsycal raycast michaelvillar-timer tailscale virtualbox vagrant
mkdir -p ~/.config/karabiner/assets/complex_modifications
ln -sf ~/dotfiles/mac/karabiner.json ~/.config/karabiner/karabiner.json
ln -sf ~/dotfiles/mac/karabiner-complex.json ~/.config/karabiner/assets/complex_modifications/karabiner-complex.json
ln -sf ~/dotfiles/mac/karabiner-complex-naginata.json ~/.config/karabiner/assets/complex_modifications/karabiner-complex-naginata.json

# lock
cp -Rp /System/Library/CoreServices/ScreenSaverEngine.app /Applications/lock.app

# ------------
# mac
# ------------
# defaults write "Apple Global Domain" com.apple.mouse.scaling 16.0
# defaults write com.apple.finder AppleShowAllFiles TRUE && killall Finder

# ------------
# others
# ------------
# sudo bash -c "echo $(which zsh) >> /etc/shells";
# echo $PASSWORD | chsh -s $(which zsh)

# ------------
# spotlight
# ------------
# touch /Applications/Xcode.app; # and un-check `spotlight > developer`.
# rm /Applications/Xcode.app;    # then remove it.

# ------------
# downloads
# ---------------
# cica:    https://github.com/miiton/Cica/releases
# chrome:  https://www.google.com/intl/ja_jp/chrome/
# ime:     https://www.google.co.jp/ime/
# hackgen: brew tap homebrew/cask-fonts && brew install font-hackgen

# ------------
# naginata
# Automator.app > New > Application > "シェルスクリプトを実行" > /bin/bash > Paste it > Save to ~/Documents/bin/
# ------------
# * automator
# current=`'/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli' --show-current-profile-name`
# if [ $current = "Default" ]; then
#     prof="Nagi"
# else
#     prof="Default"
# fi
# '/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli' --select-profile $prof

# ------------
# raycast
# ------------
# * firefox
# open raycast > extension > + > Create Script Command
# 1. input title "firefox-global-hotkey"
# 2. click "Create Script"
# 3. cd ~/Library/Application\ Support/Raycast/commands
# 4. echo "#!/bin/bash\n open -a 'Firefox'" > firefox-global-hotkey.sh
