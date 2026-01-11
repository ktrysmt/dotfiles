#!/usr/bin/env bash
# Ubuntu common setup (idempotent)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib.sh"

log_info "Running Ubuntu common setup..."

export DEBIAN_FRONTEND=noninteractive

# ------------------------------------------------------------------------------
# System packages
# ------------------------------------------------------------------------------
setup_system() {
  log_info "Installing system packages..."

  sudo apt-get update -qq -y
  sudo apt-get install -qq -y \
    build-essential \
    curl \
    file \
    gcc \
    git \
    make \
    ncurses-term \
    wget \
    zsh

  log_success "System packages installed"
}

# ------------------------------------------------------------------------------
# Zsh as default shell
# ------------------------------------------------------------------------------
setup_zsh() {
  local zsh_path
  zsh_path="$(which zsh)"

  # Add zsh to /etc/shells if not present
  if ! grep -q "^${zsh_path}$" /etc/shells; then
    sudo bash -c "echo ${zsh_path} >> /etc/shells"
    log_success "Added zsh to /etc/shells"
  fi

  # Set zsh as default shell
  if [[ "$SHELL" != "$zsh_path" ]]; then
    sudo chsh -s "$zsh_path" "$(whoami)" 2>/dev/null || true
    log_success "Set zsh as default shell"
  fi
}

# ------------------------------------------------------------------------------
# Symlinks
# ------------------------------------------------------------------------------
setup_symlinks() {
  # gitconfig (copy, not symlink)
  copy_file "${DOTFILES_DIR}/.gitconfig_ubuntu" ~/.gitconfig

  # Create say command alias (used by some scripts)
  if [[ ! -L /usr/local/bin/say ]] && [[ ! -f /usr/local/bin/say ]]; then
    sudo ln -s "$(which echo)" /usr/local/bin/say 2>/dev/null || true
  fi
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
  setup_system
  setup_zsh
  setup_symlinks

  log_success "Ubuntu common setup complete"
}

main "$@"
