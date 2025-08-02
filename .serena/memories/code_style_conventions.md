# Code Style and Conventions

## Shell Script Standards
- **Shebang**: Use `#!/bin/bash` for bash scripts
- **Error Handling**: Use `set -o pipefail` and `set -e` for strict error handling
- **Variables**: Use clear, descriptive variable names
- **Comments**: Include purpose and usage comments for complex sections

## File Naming Conventions
- **Dotfiles**: Standard dot-prefix format (e.g., `.zshrc`, `.gitconfig`)
- **Scripts**: Use descriptive names with hyphens (e.g., `git-echo-username-and-email`)
- **Platform-specific**: Use platform suffix where needed (e.g., `.tmux.conf.osx`, `.tmux.conf.ubuntu`)

## Directory Structure
- **Configuration files**: Root level for main dotfiles
- **Platform-specific**: Separate directories (`mac/`, `windows/`)
- **Utilities**: `bin/` for executable scripts, `tools/` for helper utilities
- **Installation**: `install/` directory with platform-specific scripts

## Git Configuration Style
- **Email**: Use personal email (kotaro.yoshimatsu@gmail.com)
- **Name**: Use GitHub username (ktrysmt)
- **Merge Strategy**: No fast-forward merges (`ff = false`)
- **Pull Strategy**: Fast-forward only (`ff = only`)

## Shell Configuration Patterns
- **Performance**: Use caching for plugin loading (sheldon cache)
- **Modularity**: Separate concerns (e.g., separate .zshenv from .zshrc)
- **Comments**: Clear section dividers and explanatory comments
- **Conditional Logic**: Platform-specific configurations where needed