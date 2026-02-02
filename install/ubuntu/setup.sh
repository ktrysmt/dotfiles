#!/usr/bin/env bash
# Ubuntu common setup (idempotent)
# Note: Most tools are installed via brew/mise, not apt

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib.sh"

log_info "Running Ubuntu common setup..."

export DEBIAN_FRONTEND=noninteractive

# ------------------------------------------------------------------------------
# Zsh (system shell - install via apt, not brew)
# ------------------------------------------------------------------------------
setup_zsh() {
  if ! has_command zsh; then
    log_info "Installing zsh..."
    sudo apt-get update -qq -y
    sudo apt-get install -qq -y zsh
  fi

  local zsh_path
  zsh_path="$(which zsh)"

  # Add zsh to /etc/shells if not present
  if ! grep -q "^${zsh_path}$" /etc/shells; then
    sudo bash -c "echo ${zsh_path} >> /etc/shells"
    log_success "Added zsh to /etc/shells"
  fi

  # Set zsh as default shell
  if [[ "$SHELL" != "$zsh_path" ]]; then
    sudo chsh -s "$zsh_path" "$(whoami)" 2> /dev/null || true
    log_success "Set zsh as default shell"
  fi
}

# ------------------------------------------------------------------------------
# Imagemagick
# ------------------------------------------------------------------------------
setup_imagemagick() {
  if ! has_command convert; then
    log_info "Installing imagemagick..."
    sudo apt-get install -qq -y imagemagick libmagickwand-dev
  fi

  if ! dpkg -l | grep -q libreadline-dev; then
    log_info "Installing libreadline-dev..."
    sudo apt-get install -qq -y libreadline-dev
  fi
}

# ------------------------------------------------------------------------------
# Symlinks
# ------------------------------------------------------------------------------
setup_symlinks() {
  # gitconfig (copy, not symlink)
  [[ ! -e ~/.gitconfig ]] && copy_file "${DOTFILES_DIR}/.gitconfig_ubuntu" ~/.gitconfig

  # Create say command alias (used by some scripts)
  if [[ ! -L /usr/local/bin/say ]] && [[ ! -f /usr/local/bin/say ]]; then
    sudo ln -s "$(which echo)" /usr/local/bin/say 2> /dev/null || true
  fi
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
  setup_zsh
  setup_imagemagick
  setup_symlinks

  log_success "Ubuntu common setup complete"
}

main "$@"
