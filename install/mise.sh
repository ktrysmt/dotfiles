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

# Install all tools defined in config.toml
log_info "Installing mise tools..."
mise install --yes

# Remove tools not defined in any config
log_info "Pruning unused mise tools..."
mise prune --yes

# Setup Python via uv (not mise)
if has_command uv; then
  log_info "Setting up uv python..."
  uv python install 3.13
  uv python pin --global 3.13
fi

log_success "mise setup complete"
