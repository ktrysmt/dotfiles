#!/usr/bin/env bash
# mise runtime version manager setup (idempotent)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

log_info "Setting up mise..."

if ! has_command mise; then
  log_error "mise is not installed. Run brew.sh first."
  exit 1
fi

# Activate mise for current session
eval "$(mise activate bash)"

# Trust config file (required on first run; idempotent)
mise trust ~/.config/mise/config.toml

# Install all tools defined in config.toml
# NOTE: npm tools may fail due to ~/.npmrc minimumReleaseAge; non-fatal to avoid blocking other tools
log_info "Installing mise tools..."
if ! mise install --yes; then
  log_warn "Some mise tools failed to install (npm tools may fail due to minimumReleaseAge)"
fi

log_info "Clearing mise cache..."
mise cache clear

log_info "Updating mise tools..."
mise up --yes

# Remove tools not defined in any config
log_info "Pruning unused mise tools..."
mise prune --yes

# Setup fzf key bindings (idempotent - checks if already installed)
if [[ ! -f ~/.fzf.zsh ]]; then
  log_info "Setting up fzf..."
  fzf_dir="$(mise where fzf 2> /dev/null || true)"
  if [[ -n "$fzf_dir" ]] && [[ -f "$fzf_dir/install" ]]; then
    "$fzf_dir/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
  fi
  unset fzf_dir
fi

# Setup Python via uv (not mise)
if has_command uv; then
  log_info "Setting up uv python..."
  uv python install 3.13
  uv python pin --global 3.13
fi

log_success "mise setup complete"
