#!/usr/bin/env bash
# WSL specific setup (idempotent)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib.sh"

log_info "Running WSL specific setup..."

# ------------------------------------------------------------------------------
# WSL specific mise tools
# ------------------------------------------------------------------------------
setup_mise_tools() {
  if has_command mise; then
    log_info "Installing WSL specific mise tools..."
    local wsl_config="${SCRIPT_DIR}/../../mise/wsl.toml"
    local mise_local="${XDG_CONFIG_HOME:-$HOME/.config}/mise/config.local.toml"
    ln -sf "$(cd "$(dirname "${wsl_config}")" && pwd)/$(basename "${wsl_config}")" \
      "${mise_local}"
    mise trust "${mise_local}"
    mise install --yes
    log_success "mise tools configured"
  fi
}

# ------------------------------------------------------------------------------
# wslu (wslview for opening URLs in Windows default browser)
# ------------------------------------------------------------------------------
setup_wslu() {
  if ! has_command wslview; then
    log_info "Installing wslu (wslview)..."
    sudo apt-get install -y wslu
    log_success "wslu installed"
  else
    log_success "wslu already installed"
  fi
}
setup_sandbox() {
  log_info "Installing sandbox dependencies (for Claude sandbox)..."
  npm install -g @anthropic-ai/sandbox-runtime
  sudo apt-get install -y bubblewrap socat
  log_success "sandbox dependencies installed"
}

# ------------------------------------------------------------------------------
# im-select.exe (IME switcher on Windows, called from Neovim/WSL)
# ------------------------------------------------------------------------------
setup_im_select() {
  local target_dir="/mnt/c/tools"
  local target="${target_dir}/im-select.exe"
  local url="https://github.com/daipeihust/im-select/raw/master/im-select-win/out/x64/im-select.exe"

  if [[ -f "$target" ]]; then
    log_success "im-select.exe already installed: $target"
    return 0
  fi

  log_info "Installing im-select.exe to ${target}..."
  mkdir -p "$target_dir"
  if curl -fsSL -o "$target" "$url"; then
    log_success "Installed im-select.exe"
  else
    log_error "Failed to download im-select.exe from ${url}"
    return 1
  fi
}

# ------------------------------------------------------------------------------
# Symlinks
# ------------------------------------------------------------------------------
setup_symlinks() {
  # tmux config
  link_file "${DOTFILES_DIR}/.tmux.conf.wsl" ~/.tmux.conf

  # gitconfig (copy, not symlink - may need local modifications)
  [[ ! -e ~/.gitconfig ]] && copy_file "${DOTFILES_DIR}/.gitconfig_wsl" ~/.gitconfig

  # Windows tools symlinks
  WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2> /dev/null | tr -d '\r' || echo "")

  if [[ -n "$WIN_USER" ]]; then
    local win_scripts="/mnt/c/Users/${WIN_USER}/home_scripts"

    # win32yank for clipboard
    if [[ -f "${win_scripts}/win32yank.exe" ]] && [[ ! -L /usr/local/bin/win32yank.exe ]]; then
      sudo ln -sf "${win_scripts}/win32yank.exe" /usr/local/bin/win32yank.exe 2> /dev/null || true
      log_success "Linked win32yank.exe"
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
alias open='wslview'

export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
export PATH="/home/linuxbrew/.linuxbrew/sbin:$PATH"
export PATH="/home/linuxbrew/.linuxbrew/opt/libpq/bin:$PATH"

# Browser for opening URLs (wslview uses Windows default browser)
export BROWSER=wslview
export MY_BROWSER="/mnt/c/Users/${USER}/AppData/Local/BraveSoftware/Brave-Browser/Application/brave.exe"

# API tokens (fill in after setup)
export SRC_ACCESS_TOKEN=""

# https://zenn.dev/momonga/articles/ee5b114e038938
export CLAUDE_CODE_SKIP_WINDOWS_PROFILE=1
export USERPROFILE="/mnt/c/Users/<your_windows_username>"
EOF

  log_success "Created private zshrc"
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
  setup_sandbox
  setup_wslu
  setup_mise_tools
  setup_symlinks
  setup_im_select
  setup_private_zshrc

  log_success "WSL specific setup complete"
}

main "$@"
