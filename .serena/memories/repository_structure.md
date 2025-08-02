# Repository Structure

## Root Level Files
- **Configuration Files**: Core dotfiles (.zshrc, .gitconfig, .tmux.conf variants)
- **README.md**: Basic installation instructions
- **Global Files**: .gitignore_global, .zshenv, .tigrc, .ctags, .snippet

## Key Directories

### `/install/`
- **ubuntu.sh**: Ubuntu/Linux installation script with Homebrew setup
- **mac.sh**: macOS installation script
- **ubuntu/**: Ubuntu-specific configuration subdirectory

### `/bin/`
Custom utility scripts:
- **git-*** scripts: Git helper utilities
- **sh-*** scripts: Shell helper utilities  
- **tmux-*** scripts: Tmux integration utilities
- **tsk**: Task management utility

### `/tools/`
- **termcolor.pl**: Terminal color utilities (Perl)
- **256to24bit.py**: Color conversion utility (Python)

### `/.config/`
- **peco/**: Peco (interactive filtering tool) configuration

### `/nvim/`
- Neovim configuration files

### `/zsh/`
- Zsh-specific configuration files

### Platform-Specific Directories
- **mac/**: macOS-specific configurations
- **windows/**: Windows-specific configurations
- **.docker/**: Docker-related configurations

### Meta Directories
- **.serena/**: Serena tool configuration
- **.claude/**: Claude Code configuration
- **chrome-extensions/**: Browser extension configurations

## File Naming Patterns
- **Platform suffixes**: `.tmux.conf.osx`, `.tmux.conf.ubuntu`, `.tmux.conf.wsl`
- **Tool prefixes**: `git-*`, `sh-*`, `tmux-*` for utility scripts
- **Standard dotfiles**: Leading dot for configuration files