#!/usr/bin/env bash
# macOS common setup (idempotent)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib.sh"

log_info "Running macOS specific setup..."

# ------------------------------------------------------------------------------
# macOS specific mise tools
# ------------------------------------------------------------------------------
setup_mise_tools() {
  if has_command mise; then
    log_info "Installing macOS specific mise tools..."
    local mac_config="${SCRIPT_DIR}/../../mise/mac.toml"
    local mise_local="${XDG_CONFIG_HOME:-$HOME/.config}/mise/config.local.toml"
    ln -sf "$(cd "$(dirname "${mac_config}")" && pwd)/$(basename "${mac_config}")" \
      "${mise_local}"
    mise trust "${mise_local}"
    mise install --yes
    log_success "mise tools configured"
  fi
}

# ------------------------------------------------------------------------------
# True color support for tmux
# ------------------------------------------------------------------------------
setup_truecolor() {
  if [[ ! -f ~/tmux-256color.info ]]; then
    local ncurses_path
    ncurses_path="$(brew --prefix)/opt/ncurses/bin/infocmp"
    if [[ -x "$ncurses_path" ]]; then
      "$ncurses_path" tmux-256color > ~/tmux-256color.info 2> /dev/null || true
      if [[ -f ~/tmux-256color.info ]]; then
        sudo tic -xe tmux-256color ~/tmux-256color.info 2> /dev/null || true
        log_success "True color support configured"
      fi
    fi
  fi
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
  setup_mise_tools
  setup_truecolor

  # Symlinks run last (apps need to be installed first)
  bash "${SCRIPT_DIR}/symlink.sh"

  log_success "macOS specific setup complete"
}

main "$@"
