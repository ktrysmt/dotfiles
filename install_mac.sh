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
  tig \
  fzy \
  peco \
  exa \
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
  kubectx \
  kubernetes-helm \
  coreutils \
  rust-analyzer \
  llvm \
  gopls \
  golangci-lint
brew install /usr/local/Homebrew/Library/Taps/neovim/homebrew-neovim/Formula/neovim@0.4.4.rb
brew install --HEAD universal-ctags/universal-ctags/universal-ctags
$(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc
exec $SHELL -l

# symlink
cd ~/
mkdir ~/.zinit

git clone https://github.com/zdharma-continuum/zinit ~/.zinit/bin
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
mkdir -p ~/.config/peco/
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

# python
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

# sub tools
go install github.com/go-delve/delve/cmd/dlv@latest
vim +":PlugInstall" +qa
vim +":setfiletype go" +":GoInstallBinaries" +qa
vim +":setfiletype rust" +":LspInstallServer rust-analyzer" +qa
vim +":setfiletype python" +":LspInstallServer pyls-all" +qa
npm i -g npm-check-updates neovim

# brew cask
export HOMEBREW_CASK_OPTS="--appdir=/Applications";
brew tap caskroom/cask
brew --cask install appcleaner kindle hiddenbar google-japanese-ime iterm2 rectangle alt-tab clipy visual-studio-code google-chrome minikube mos macgesture
brew --cask install virtualbox
brew --cask install vagrant
brew install --cask michaelvillar-timer
brew --cask install karabiner-elements
ln -sf ~/dotfiles/mac/karabiner.json ~/.config/karabiner.json
ln -sf ~/dotfiles/mac/karabiner-complex.json ~/.config/karabiner/assets/complex_modifications/karabiner-complex.json

# the other
cp -Rp /System/Library/CoreServices/ScreenSaverEngine.app /Applications/lock.app

# lima
limactl start

# the final task
sudo bash -c "echo $(which zsh) >> /etc/shells";
echo $PASSWORD | chsh -s $(which zsh)

# others...
# ------------
# cica font: https://github.com/miiton/Cica/releases
# mouse: defaults write "Apple Global Domain" com.apple.mouse.scaling 11
