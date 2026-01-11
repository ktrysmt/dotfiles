#!/usr/bin/env bash
# macOS specific setup (idempotent)

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
    ln -sf "$(cd "$(dirname "${mac_config}")" && pwd)/$(basename "${mac_config}")" \
      "${XDG_CONFIG_HOME:-$HOME/.config}/mise/config.local.toml"
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
      "$ncurses_path" tmux-256color > ~/tmux-256color.info 2>/dev/null || true
      if [[ -f ~/tmux-256color.info ]]; then
        sudo tic -xe tmux-256color ~/tmux-256color.info 2>/dev/null || true
        log_success "True color support configured"
      fi
    fi
  fi
}

# ------------------------------------------------------------------------------
# Kubernetes krew plugin manager
# ------------------------------------------------------------------------------
setup_krew() {
  if has_command kubectl-krew || [[ -d "${KREW_ROOT:-$HOME/.krew}" ]]; then
    log_success "krew already installed"
    return 0
  fi

  log_info "Installing krew..."
  (
    set -x
    cd "$(mktemp -d)"
    OS="$(uname | tr '[:upper:]' '[:lower:]')"
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/arm64/arm64/')"
    KREW="krew-${OS}_${ARCH}"
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz"
    tar zxvf "${KREW}.tar.gz"
    ./"${KREW}" install krew
  )

  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

  # Install common plugins
  kubectl krew install tree 2>/dev/null || true
  kubectl krew install open-svc 2>/dev/null || true

  log_success "krew installed"
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
  setup_mise_tools
  setup_truecolor
  setup_krew

  log_success "macOS specific setup complete"
}

main "$@"
