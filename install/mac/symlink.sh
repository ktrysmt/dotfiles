#!/usr/bin/env bash
# macOS specific symlinks (idempotent)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib.sh"

log_info "Setting up macOS specific symlinks..."

# tmux config
link_file "${DOTFILES_DIR}/.tmux.conf.osx" ~/.tmux.conf

# gitconfig (copy, not symlink - may need local modifications)
copy_file "${DOTFILES_DIR}/.gitconfig_macos" ~/.gitconfig

# Karabiner
ensure_dir ~/.config/karabiner/assets/complex_modifications
link_file "${DOTFILES_DIR}/mac/karabiner-complex.json" ~/.config/karabiner/assets/complex_modifications/karabiner-complex.json

log_success "macOS symlinks complete"
