# Dotfiles Project Overview

## Purpose
This is a personal dotfiles repository for managing development environment configurations across macOS and Ubuntu/Linux systems. It provides automated setup scripts and configuration files for shell environments, development tools, and system utilities.

## Key Features
- Cross-platform support (macOS and Ubuntu/Linux)
- Automated installation scripts for both platforms
- Shell configuration (zsh with advanced caching)
- Git configuration with delta integration
- Custom utility scripts in `bin/` directory
- Development tool configurations (tmux, nvim, etc.)
- Browser extensions and platform-specific configurations

## Repository Structure
- `install/` - Platform-specific installation scripts
- `bin/` - Custom utility scripts and commands
- `tools/` - Helper tools and utilities
- `.config/` - Application configurations
- Root level - Main configuration files (.zshrc, .gitconfig, .tmux.conf variants)
- Platform directories (`mac/`, `windows/`) for OS-specific files

## Author
Created and maintained by ktrysmt (kotaro.yoshimatsu@gmail.com)