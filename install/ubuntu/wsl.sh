#!/usr/bin/env bash
# WSL specific setup (idempotent)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib.sh"

log_info "Running WSL specific setup..."

# ------------------------------------------------------------------------------
# Symlinks
# ------------------------------------------------------------------------------
setup_symlinks() {
  # tmux config
  link_file "${DOTFILES_DIR}/.tmux.conf.wsl" ~/.tmux.conf

  if [[ ! -e ~/.gitconfig ]]; then
    # gitconfig (copy, not symlink - may need local modifications)
    copy_file "${DOTFILES_DIR}/.gitconfig_wsl" ~/.gitconfig
  fi

  # Windows tools symlinks
  WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2> /dev/null | tr -d '\r' || echo "")

  if [[ -n "$WIN_USER" ]]; then
    local win_scripts="/mnt/c/Users/${WIN_USER}/home_scripts"

    # win32yank for clipboard
    if [[ -f "${win_scripts}/win32yank.exe" ]] && [[ ! -L /usr/local/bin/win32yank.exe ]]; then
      sudo ln -sf "${win_scripts}/win32yank.exe" /usr/local/bin/win32yank.exe 2> /dev/null || true
      log_success "Linked win32yank.exe"
    fi

    # spzenhan for IME control
    if [[ -f "${win_scripts}/spzenhan.exe" ]] && [[ ! -L /usr/local/bin/spzenhan.exe ]]; then
      sudo ln -sf "${win_scripts}/spzenhan.exe" /usr/local/bin/spzenhan.exe 2> /dev/null || true
      log_success "Linked spzenhan.exe"
    fi
  fi
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
# WSL specific settings
alias pbcopy='clip.exe'
alias pbpaste='powershell.exe Get-Clipboard'

export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
export PATH="/home/linuxbrew/.linuxbrew/sbin:$PATH"
export PATH="/home/linuxbrew/.linuxbrew/opt/libpq/bin:$PATH"

# Browser for opening URLs
export MY_BROWSER="/mnt/c/Users/${USER}/AppData/Local/BraveSoftware/Brave-Browser/Application/brave.exe"

# API tokens (fill in after setup)
export SRC_ACCESS_TOKEN=""
EOF

  log_success "Created private zshrc"
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
  setup_symlinks
  setup_private_zshrc

  log_success "WSL specific setup complete"
}

main "$@"
