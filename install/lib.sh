#!/usr/bin/env bash
# Common library functions for dotfiles installation
# All functions are designed to be idempotent

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# ------------------------------------------------------------------------------
# OS Detection
# ------------------------------------------------------------------------------
detect_os() {
  case "$(uname -s)" in
    Darwin) echo "mac" ;;
    Linux)
      if [[ "$(uname -r)" == *microsoft* ]]; then
        echo "wsl"
      elif [[ -f /etc/vagrant_box_build_time ]] || grep -q "vagrant" /etc/passwd 2>/dev/null; then
        echo "vagrant"
      else
        echo "ubuntu"
      fi
      ;;
    *) echo "unknown" ;;
  esac
}

OS_TYPE="${OS_TYPE:-$(detect_os)}"

# ------------------------------------------------------------------------------
# Logging
# ------------------------------------------------------------------------------
log_info() {
  echo -e "\033[0;34m[INFO]\033[0m $*"
}

log_success() {
  echo -e "\033[0;32m[OK]\033[0m $*"
}

log_warn() {
  echo -e "\033[0;33m[WARN]\033[0m $*"
}

log_error() {
  echo -e "\033[0;31m[ERROR]\033[0m $*" >&2
}

# ------------------------------------------------------------------------------
# Idempotent Symlink
# ------------------------------------------------------------------------------
# Creates a symlink, backing up existing files if necessary
# Usage: link_file <source> <destination>
link_file() {
  local src="$1"
  local dst="$2"

  if [[ ! -e "$src" ]]; then
    log_error "Source does not exist: $src"
    return 1
  fi

  # Already correct symlink
  if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
    log_success "Already linked: $dst -> $src"
    return 0
  fi

  # Remove existing symlink (pointing elsewhere)
  if [[ -L "$dst" ]]; then
    log_warn "Removing old symlink: $dst -> $(readlink "$dst")"
    rm "$dst"
  # Backup existing file/directory
  elif [[ -e "$dst" ]]; then
    local backup="${dst}.backup.$(date +%Y%m%d%H%M%S)"
    log_warn "Backing up existing: $dst -> $backup"
    mv "$dst" "$backup"
  fi

  # Create parent directory if needed
  mkdir -p "$(dirname "$dst")"

  ln -s "$src" "$dst"
  log_success "Linked: $dst -> $src"
}

# ------------------------------------------------------------------------------
# Idempotent Directory Creation
# ------------------------------------------------------------------------------
ensure_dir() {
  local dir="$1"
  if [[ -d "$dir" ]]; then
    return 0
  fi
  mkdir -p "$dir"
  log_success "Created directory: $dir"
}

# ------------------------------------------------------------------------------
# Idempotent File Copy (only if different)
# ------------------------------------------------------------------------------
copy_file() {
  local src="$1"
  local dst="$2"

  if [[ ! -e "$src" ]]; then
    log_error "Source does not exist: $src"
    return 1
  fi

  if [[ -e "$dst" ]] && diff -q "$src" "$dst" >/dev/null 2>&1; then
    log_success "Already up to date: $dst"
    return 0
  fi

  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  log_success "Copied: $src -> $dst"
}

# ------------------------------------------------------------------------------
# Idempotent Git Clone
# ------------------------------------------------------------------------------
git_clone() {
  local repo="$1"
  local dest="$2"

  if [[ -d "$dest/.git" ]]; then
    log_success "Already cloned: $dest"
    return 0
  fi

  if [[ -e "$dest" ]]; then
    log_warn "Removing non-git directory: $dest"
    rm -rf "$dest"
  fi

  git clone "$repo" "$dest"
  log_success "Cloned: $repo -> $dest"
}

# ------------------------------------------------------------------------------
# Idempotent Line Append (only if not present)
# ------------------------------------------------------------------------------
ensure_line() {
  local file="$1"
  local line="$2"

  if [[ -f "$file" ]] && grep -qF "$line" "$file"; then
    return 0
  fi

  mkdir -p "$(dirname "$file")"
  echo "$line" >> "$file"
  log_success "Added line to $file"
}

# ------------------------------------------------------------------------------
# Command Existence Check
# ------------------------------------------------------------------------------
has_command() {
  command -v "$1" >/dev/null 2>&1
}

# ------------------------------------------------------------------------------
# Brew Setup (idempotent)
# ------------------------------------------------------------------------------
ensure_brew() {
  if has_command brew; then
    log_success "Homebrew already installed"
    return 0
  fi

  log_info "Installing Homebrew..."
  NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add to path for current session
  if [[ "$OS_TYPE" == "mac" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
  log_success "Homebrew installed"
}
