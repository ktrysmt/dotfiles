#!/usr/bin/env bash
# Vagrant specific setup (idempotent)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib.sh"

log_info "Running Vagrant specific setup..."

export DEBIAN_FRONTEND=noninteractive

# ------------------------------------------------------------------------------
# Clipboard support
# ------------------------------------------------------------------------------
setup_clipboard() {
  log_info "Setting up clipboard support..."

  sudo apt-get install -qq -y xvfb xsel

  log_success "Clipboard packages installed"
}

# ------------------------------------------------------------------------------
# Symlinks
# ------------------------------------------------------------------------------
setup_symlinks() {
  # tmux config
  link_file "${DOTFILES_DIR}/.tmux.conf.ubuntu_vagrant" ~/.tmux.conf
}

# ------------------------------------------------------------------------------
# Private zshrc (environment-specific settings)
# ------------------------------------------------------------------------------
setup_private_zshrc() {
  local private_file=~/.zshrc.private

  # Only create if doesn't exist
  if [[ -f "$private_file" ]]; then
    log_success "Private zshrc already exists"
    return 0
  fi

  cat > "$private_file" << 'EOF'
# Vagrant specific settings

# VirtualBox clipboard
if ! pgrep -f VBoxClient > /dev/null; then
  sudo VBoxClient --clipboard 2>/dev/null || true
fi

# Xvfb for headless clipboard
if [ -x /usr/bin/Xvfb ] && [ -x /usr/bin/VBoxClient ] && [ ! -f /tmp/.X0-lock ] && ! pgrep -f Xvfb > /dev/null; then
  Xvfb -screen 0 320x240x8 > /dev/null 2>&1 &
fi

export DISPLAY=":0"
alias pbcopy='xsel --display :0 --input --clipboard'
alias pbpaste='xsel --display :0 --output --clipboard'

# API tokens (fill in after setup)
export SRC_ACCESS_TOKEN=""
export GEMINI_API_KEY=""

# Ollama (host machine)
export OLLAMA_HOST="192.168.33.1"
export OLLAMA_MODEL="deepseek-coder-v2:16b"
EOF

  log_success "Created private zshrc"
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
  setup_clipboard
  setup_symlinks
  setup_private_zshrc

  log_success "Vagrant specific setup complete"
}

main "$@"
