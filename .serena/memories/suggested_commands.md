# Suggested Commands for Dotfiles Project

## Installation Commands
```bash
# Ubuntu/Linux installation
git clone https://github.com/ktrysmt/dotfiles ~/dotfiles && bash ~/dotfiles/install/ubuntu.sh

# macOS installation  
git clone https://github.com/ktrysmt/dotfiles ~/dotfiles && bash ~/dotfiles/install/mac.sh
```

## Development Commands
```bash
# Navigate to project
cd ~/dotfiles

# Check git status
git status

# View file contents
cat [filename]
bat [filename]  # if bat is installed

# List directory contents
ls -la
eza -la  # if eza is installed

# Search for patterns
grep -r "pattern" .
rg "pattern"  # if ripgrep is installed

# Edit files
vim [filename]
nvim [filename]  # if neovim is installed
```

## Testing Changes
```bash
# Test shell configuration changes
source ~/.zshrc

# Test tmux configuration
tmux source-file ~/.tmux.conf

# Validate shell syntax
bash -n install/ubuntu.sh
bash -n install/mac.sh
```

## Git Operations
```bash
# Standard git workflow
git add .
git commit -m "description"
git push origin main

# View enhanced diff (if delta configured)
git diff
git show
```

## System-Specific Commands (Linux)
- `ls` - list directory contents
- `grep` - search text patterns
- `find` - search for files
- `cd` - change directory
- `cp` - copy files
- `mv` - move/rename files
- `chmod` - change file permissions
- `ln -s` - create symbolic links