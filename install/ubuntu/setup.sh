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
  setup_zsh
  setup_symlinks

  log_success "Ubuntu common setup complete"
}

main "$@"
