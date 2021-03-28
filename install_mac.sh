#!/bin/bash

set -o pipefail
set -e

read -p "password? > " PASSWORD

# brew
export CI=true
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew install \
  curl \
  openssl \
  reattach-to-user-namespace \
  go \
  peco \
  wget \
  tmux \
  zsh \
  nkf \
  tree \
  ripgrep \
  fd \
  procs \
  fzf \
  tig \
  fzy \
  exa \
  python3 \
  jq \
  git-secrets \
  bat \
  watch \
  ghq \
  git \
  diff-so-fancy \
  kind \
  kubectl \
  kubectx \
  kubernetes-helm \
  coreutils \
  llvm \
  neovim
brew install --HEAD universal-ctags/universal-ctags/universal-ctags
exec $SHELL -l

# symlink
cd ~/
mkdir ~/.zinit
git clone https://github.com/zdharma/zinit.git ~/.zinit/bin
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
mkdir -p ~/.config/peco/
mkdir -p ~/.hammerspoon/
mkdir -p ~/.local/bin/
mkdir ~/.cache
mkdir ~/.docker
ln -s ~/dotfiles/.snippet ~/.snippet
ln -s ~/dotfiles/.zshenv ~/.zshenv
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.tigrc ~/.tigrc
ln -s ~/dotfiles/.tmux.conf.osx ~/.tmux.conf
ln -s ~/dotfiles/.config/peco/config.json ~/.config/peco/config.json
ln -s ~/dotfiles/.hammerspoon/init.lua ~/.hammerspoon/init.lua
cp ~/dotfiles/.gitconfig ~/.gitconfig
cp ~/dotfiles/.docker/config.json ~/.docker/config.json
# cp ~/dotfiles/.switch-proxy.osx ~/.switch-proxy
mkdir -p ~/.ipython/profile_default/
echo "c.InteractiveShell.colors = 'Linux'" > ~/.ipython/profile_default/ipython_config.py

# git config
git secrets --register-aws --global
git secrets --install ~/.git-templates/git-secrets
git config --global init.templatedir '~/.git-templates/git-secrets'
git config --global credential.helper osxkeychain

# go
mkdir -p ~/project/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$HOME/go/bin:$HOME/project/bin:$PATH
export GOPATH=$HOME/go:$HOME/project

# nvim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
mkdir -p ~/.config/nvim/
ln -s ~/.vimrc ~/.config/nvim/init.vim
pip3 install neovim
ln -sf $(which nvim) /usr/local/bin/vim
pip3 install 'python-language-server[yapf]'
pip3 install ipdb   # python debugger
pip3 install flake8 # python linter

# k8s
(
  set -x; cd "$(mktemp -d)" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.{tar.gz,yaml}" &&
  tar zxvf krew.tar.gz &&
  KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_amd64" &&
  "$KREW" install --manifest=krew.yaml --archive=krew.tar.gz &&
  "$KREW" update
)
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
kubectl krew install tree open-svc

# rust
# setting up of rust components is here: https://gist.github.com/ktrysmt/9601264b37f8e46cad1e7075850478fb
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
curl -fsSL https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-mac.gz -o ~/.local/bin/rust-analyzer.gz && \
  gunzip ~/.local/bin/rust-analyzer.gz \
  chmod +x ~/.local/bin/rust-analyzer;


# sub tools
go get github.com/go-delve/delve/cmd/dlv
vim +":PlugInstall" +":setfiletype go" +":GoInstallBinaries" +qa
vim +":setfiletype go" +":LspInstallServer gopls" +":LspInstallServer golangci-lint-langserver" +qa
vim +":setfiletype rust" +":LspInstallServer rust-analyzer" +qa
npm i -g npm-check-updates neovim

# brew cask
export HOMEBREW_CASK_OPTS="--appdir=/Applications";
brew tap caskroom/cask
brew cask install appcleaner kindle hiddenbar google-japanese-ime iterm2 shiftit hyperswitch clipy docker qblocker hammerspoon visual-studio-code google-chrome typora minikube mos icdiff
brew cask install virtualbox
brew cask install vagrant
brew cask install karabiner-elements
brew cask install michaelvillar-timer
brew cask install homebrew/cask-fonts/font-hack-nerd-font

# the other
cp -Rp /System/Library/CoreServices/ScreenSaverEngine.app /Applications/lock.app

# the final task
sudo bash -c "echo $(which zsh) >> /etc/shells";
echo $PASSWORD | chsh -s $(which zsh)

# cica font: https://github.com/miiton/Cica/releases
# mouse: defaults write "Apple Global Domain" com.apple.mouse.scaling 11
