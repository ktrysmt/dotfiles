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
      bash "${SCRIPT_DIR}/mac/common.sh"
      ;;
    wsl)
      bash "${SCRIPT_DIR}/ubuntu/common.sh"
      bash "${SCRIPT_DIR}/ubuntu/wsl.sh"
      ;;
    vagrant)
      bash "${SCRIPT_DIR}/ubuntu/common.sh"
      bash "${SCRIPT_DIR}/ubuntu/vagrant.sh"
      ;;
    ubuntu)
      bash "${SCRIPT_DIR}/ubuntu/common.sh"
      # Plain ubuntu - use wsl tmux config as default
      link_file "${DOTFILES_DIR}/.tmux.conf.ubuntu" ~/.tmux.conf
      ;;
  esac
}

step_post_install() {
  log_info "=== Step: Post Install ==="
  bash "${SCRIPT_DIR}/post-install.sh"
}

step_sheldon() {
  log_info "=== Step: Sheldon Plugin Update ==="
  if command -v sheldon &> /dev/null; then
    rm ~/.cache/sheldon.zsh || true
    sheldon lock --update
    sheldon source > ~/.cache/sheldon.zsh
  else
    log_warn "Sheldon not found; skipping plugin update."
  fi
}

step_claude() {
  log_info "=== Step: Claude Plugin Update ==="
  if ! command -v claude &> /dev/null; then
    log_warn "Claude CLI not found; skipping plugin update."
    return 0
  fi
  if ! command -v jq &> /dev/null; then
    log_warn "jq not found; skipping Claude plugin update."
    return 0
  fi

  local settings="${DOTFILES_DIR}/claude/settings.json"
  if [[ ! -f "$settings" ]]; then
    log_warn "Claude settings.json not found; skipping."
    return 0
  fi

  local plugins
  plugins=$(jq -r '.enabledPlugins // {} | to_entries[] | select(.value == true) | .key' "$settings")

  if [[ -z "$plugins" ]]; then
    log_info "No enabled Claude plugins found."
    return 0
  fi

  while IFS= read -r plugin; do
    log_info "Updating Claude plugin: $plugin"
    claude plugin update "$plugin" || log_warn "Failed to update: $plugin"
  done <<< "$plugins"

  log_success "Claude plugin update complete"
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
      step_sheldon
      step_claude
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
    claude)
      step_claude
      ;;
    *)
      echo "Usage: $0 [all|symlink|brew|mise|os|post|claude]"
      exit 1
      ;;
  esac

  echo
  log_success "=== Installation/Update complete! ==="
}

main "$@"
