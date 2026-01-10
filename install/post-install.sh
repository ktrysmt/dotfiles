#!/usr/bin/env bash
# Post-installation tasks (idempotent)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

# ------------------------------------------------------------------------------
# Git Configuration
# ------------------------------------------------------------------------------
setup_git() {
  log_info "Setting up git..."

  # git-secrets
  if has_command git-secrets; then
    git secrets --register-aws --global 2>/dev/null || true

    if [[ ! -d ~/.git-templates/git-secrets ]]; then
      git secrets --install ~/.git-templates/git-secrets
    fi

    git config --global init.templatedir '~/.git-templates/git-secrets'
  fi

  git config --global core.excludesfile ~/.gitignore_global

  # OS-specific credential helper
  case "$OS_TYPE" in
    mac)
      git config --global credential.helper osxkeychain
      ;;
    wsl)
      # Use Windows Git Credential Manager
      if [[ -f "/mnt/c/Program Files (x86)/Git Credential Manager/git-credential-manager.exe" ]]; then
        git config --global credential.helper "/mnt/c/Program\\ Files\\ \\(x86\\)/Git\\ Credential\\ Manager/git-credential-manager.exe"
      elif [[ -f "/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe" ]]; then
        git config --global credential.helper "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe"
      else
        git config --global credential.helper store
      fi
      ;;
    *)
      git config --global credential.helper store
      ;;
  esac

  log_success "Git configuration complete"
}

# ------------------------------------------------------------------------------
# Rust
# ------------------------------------------------------------------------------
setup_rust() {
  log_info "Setting up Rust..."

  if [[ -f "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
  fi

  if has_command rustup; then
    log_success "Rust already installed"
    rustup update stable 2>/dev/null || true
  else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    source "$HOME/.cargo/env"
    log_success "Rust installed"
  fi
}

# ------------------------------------------------------------------------------
# Go
# ------------------------------------------------------------------------------
setup_go() {
  log_info "Setting up Go tools..."

  if ! has_command go; then
    log_warn "Go not installed, skipping Go tools"
    return 0
  fi

  # Ensure GOPATH
  ensure_dir ~/go/bin
  ensure_dir ~/project/bin
  export GOPATH="$HOME/go:$HOME/project"
  export PATH="$HOME/go/bin:$HOME/project/bin:$PATH"

  # Install delve debugger (idempotent)
  if ! has_command dlv; then
    go install github.com/go-delve/delve/cmd/dlv@latest
    log_success "Installed dlv"
  fi

  log_success "Go tools setup complete"
}

# ------------------------------------------------------------------------------
# Neovim
# ------------------------------------------------------------------------------
setup_neovim() {
  log_info "Setting up Neovim..."

  # Create vim symlink
  if has_command nvim; then
    if [[ "$OS_TYPE" == "mac" ]]; then
      sudo ln -sf "$(which nvim)" /usr/local/bin/vim 2>/dev/null || true
    else
      sudo ln -sf "$(which nvim)" /usr/local/bin/vim 2>/dev/null || true
    fi
  fi

  # Python providers for neovim (using uv)
  if has_command uv; then
    uv tool install pynvim 2>/dev/null || uv tool upgrade pynvim 2>/dev/null || true
  fi

  log_success "Neovim setup complete"
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
  setup_git
  setup_rust
  setup_go
  setup_neovim

  log_success "Post-installation complete"
}

main "$@"
