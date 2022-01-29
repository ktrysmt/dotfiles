#!/bin/bash

set -o pipefail
set -e

# brew
brew install \
  go \
  tmux \
  kind \
  kubectl \
  kubectx \
  helm \
  nodenv

cd ~/
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
ln -s ~/dotfiles/.tmux.conf.ubuntu ~/.tmux.conf

# rust
# setting up of rust components is here: https://gist.github.com/ktrysmt/9601264b37f8e46cad1e7075850478fb
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
curl -fsSL https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-linux.gz -o ~/.local/bin/rust-analyzer.gz && \
  gunzip ~/.local/bin/rust-analyzer.gz \
  chmod +x ~/.local/bin/rust-analyzer;
vim +"set ft=rust" +":LspInstallServer rust-analyzer" +qa

# node
sudo curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
sudo npm i -g npm-check-updates neovim

# go
mkdir -p ~/project/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$HOME/go/bin:$HOME/project/bin:$PATH
export GOPATH=$HOME/go:$HOME/project
go get github.com/go-delve/delve/cmd/dlv
vim +":setfiletype go" +":GoInstallBinaries" +qa
vim +"set ft=go" +":LspInstallServer gopls" +qa
vim +"set ft=go" +":LspInstallServer golangci-lint-langserver" +qa
