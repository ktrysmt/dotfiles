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

# Authenticate GitHub API calls to avoid the 60 req/h anonymous rate limit
if [[ -z "${MISE_GITHUB_TOKEN:-}${GITHUB_TOKEN:-}" ]] && has_command gh; then
  if MISE_GITHUB_TOKEN="$(gh auth token 2> /dev/null)"; then
    export MISE_GITHUB_TOKEN
  else
    unset MISE_GITHUB_TOKEN
    log_warn "gh is not authenticated; mise will use anonymous GitHub API (60 req/h)"
  fi
fi

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
if ! mise up --yes; then
  log_warn "Some mise tools failed to update"
fi

# Remove tools not defined in any config
log_info "Pruning unused mise tools..."
if ! mise prune --yes; then
  log_warn "Some mise tools failed to prune"
fi

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

  # Netskope workaround (see install/sitecustomize.py): relink after every
  # `uv python install/upgrade`, since each patch release lands in a new directory.
  # Self-cleaning: once the root CA marks Basic Constraints critical (or Netskope
  # is gone), our links are removed. After one such run, this block and
  # install/sitecustomize.py can be deleted.
  netskope_ca="/Library/Application Support/Netskope/STAgent/data/nscacert.pem"
  netskope_fix=false
  if [[ -f "$netskope_ca" ]] \
    && ! openssl x509 -in "$netskope_ca" -noout -ext basicConstraints 2> /dev/null | grep -q critical; then
    netskope_fix=true
  fi
  for stdlib in "$(uv python dir)"/cpython-*/lib/python3.*/; do
    # Skip minor-version aliases (cpython-3.13-...) that symlink to a patch dir
    [[ -L "${stdlib%/lib/python3.*/}" ]] && continue
    dst="${stdlib}sitecustomize.py"
    if [[ "$netskope_fix" == true ]]; then
      link_file "${DOTFILES_DIR}/install/sitecustomize.py" "$dst"
    elif [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "${DOTFILES_DIR}/install/sitecustomize.py" ]]; then
      rm "$dst"
      log_success "Unlinked (Netskope CA no longer needs workaround): $dst"
    fi
  done
  unset netskope_ca netskope_fix stdlib dst
fi

log_success "mise setup complete"
