#!/usr/bin/env bash
# Common symlinks for all platforms (idempotent)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

log_info "Setting up common symlinks..."

# Ensure directories exist
ensure_dir ~/.config/sheldon
ensure_dir ~/.config/peco
ensure_dir ~/.config/mise
ensure_dir ~/.local/bin
ensure_dir ~/.cache/vim
ensure_dir ~/.docker
ensure_dir ~/.claude
ensure_dir ~/.ssh

# Shell
link_file "${DOTFILES_DIR}/.zshenv" ~/.zshenv
link_file "${DOTFILES_DIR}/.zshrc" ~/.zshrc

# Editor
link_file "${DOTFILES_DIR}/nvim" ~/.config/nvim

# Tools
link_file "${DOTFILES_DIR}/.snippet" ~/.snippet
link_file "${DOTFILES_DIR}/.tigrc" ~/.tigrc
link_file "${DOTFILES_DIR}/.config/peco/config.json" ~/.config/peco/config.json
link_file "${DOTFILES_DIR}/zsh/sheldon.plugins.toml" ~/.config/sheldon/plugins.toml
link_file "${DOTFILES_DIR}/.gitignore_global" ~/.gitignore_global

# mise
link_file "${DOTFILES_DIR}/mise/config.toml" ~/.config/mise/config.toml

# Claude
link_file "${DOTFILES_DIR}/.claude/hooks" ~/.claude/hooks
link_file "${DOTFILES_DIR}/.claude/CLAUDE.md" ~/.claude/CLAUDE.md
link_file "${DOTFILES_DIR}/.claude/settings.json" ~/.claude/settings.json
link_file "${DOTFILES_DIR}/.claude/skills" ~/.claude/skills

# Copy files (not symlink - may contain secrets or machine-specific config)
[[ ! -e ~/.docker/config.json ]] && copy_file "${DOTFILES_DIR}/.docker/config.json" ~/.docker/config.json

# tmux plugin manager
git_clone "https://github.com/tmux-plugins/tpm" ~/.tmux/plugins/tpm

# SSH config (idempotent)
ensure_line ~/.ssh/config "ServerAliveInterval 15"
ensure_line ~/.ssh/config "ServerAliveCountMax 10"

log_success "Common symlinks complete"
