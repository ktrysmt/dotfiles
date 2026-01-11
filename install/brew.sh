#!/usr/bin/env bash
# Homebrew installation and package management (idempotent)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

log_info "Setting up Homebrew..."

# Install Homebrew if not present
ensure_brew

# Install common packages
log_info "Installing common packages..."
brew bundle --file="${DOTFILES_DIR}/Brewfile.common"

# Install OS-specific packages
case "$OS_TYPE" in
  mac)
    log_info "Installing macOS packages..."
    brew bundle --file="${DOTFILES_DIR}/Brewfile.mac"
    ;;
  wsl | vagrant | ubuntu)
    log_info "Installing Ubuntu packages..."
    brew bundle --file="${DOTFILES_DIR}/Brewfile.ubuntu"
    ;;
esac

# Setup fzf key bindings (idempotent - checks if already installed)
if [[ ! -f ~/.fzf.zsh ]]; then
  log_info "Setting up fzf..."
  "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
fi

log_success "Homebrew setup complete"
