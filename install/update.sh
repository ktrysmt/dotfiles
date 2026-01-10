#!/usr/bin/env bash
# Main entry point for dotfiles installation
# This script is idempotent - safe to run multiple times
#
# Usage:
#   ./update.sh          # Full installation
#   ./update.sh symlink  # Only update symlinks
#   ./update.sh brew     # Only update brew packages
#   ./update.sh mise     # Only update mise tools

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

# ------------------------------------------------------------------------------
# Installation Steps
# ------------------------------------------------------------------------------

step_symlink() {
  log_info "=== Step: Symlinks ==="
  bash "${SCRIPT_DIR}/symlink.sh"

  case "$OS_TYPE" in
    mac)
      bash "${SCRIPT_DIR}/mac/symlink.sh"
      ;;
    wsl|vagrant|ubuntu)
      # Ubuntu symlinks handled in OS-specific scripts
      ;;
  esac
}

step_brew() {
  log_info "=== Step: Homebrew ==="
  bash "${SCRIPT_DIR}/brew.sh"
}

step_mise() {
  log_info "=== Step: mise ==="
  bash "${SCRIPT_DIR}/mise.sh"
}

step_os_specific() {
  log_info "=== Step: OS Specific ==="

  case "$OS_TYPE" in
    mac)
      bash "${SCRIPT_DIR}/mac/setup.sh"
      ;;
    wsl)
      bash "${SCRIPT_DIR}/ubuntu/setup.sh"
      bash "${SCRIPT_DIR}/ubuntu/wsl.sh"
      ;;
    vagrant)
      bash "${SCRIPT_DIR}/ubuntu/setup.sh"
      bash "${SCRIPT_DIR}/ubuntu/vagrant.sh"
      ;;
    ubuntu)
      bash "${SCRIPT_DIR}/ubuntu/setup.sh"
      # Plain ubuntu - use wsl tmux config as default
      link_file "${DOTFILES_DIR}/.tmux.conf.ubuntu" ~/.tmux.conf
      ;;
  esac
}

step_post_install() {
  log_info "=== Step: Post Install ==="
  bash "${SCRIPT_DIR}/post-install.sh"
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

main() {
  local cmd="${1:-all}"

  log_info "Detected OS: ${OS_TYPE}"
  log_info "Dotfiles dir: ${DOTFILES_DIR}"
  echo

  case "$cmd" in
    all)
      step_symlink
      step_brew
      step_mise
      step_os_specific
      step_post_install
      ;;
    symlink)
      step_symlink
      ;;
    brew)
      step_brew
      ;;
    mise)
      step_mise
      ;;
    os)
      step_os_specific
      ;;
    post)
      step_post_install
      ;;
    *)
      echo "Usage: $0 [all|symlink|brew|mise|os|post]"
      exit 1
      ;;
  esac

  echo
  log_success "=== Installation complete! ==="
  echo
  echo "Next steps:"
  echo "  1. Restart your shell or run: exec zsh"
  echo "  2. Run :PlugInstall in neovim"
  echo "  3. Press prefix + I in tmux to install plugins"
}

main "$@"
