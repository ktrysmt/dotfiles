# My dotfiles

## Install

```bash
git clone https://github.com/ktrysmt/dotfiles ~/dotfiles
cd ~/dotfiles/install
./update.sh
```

The install script is **idempotent** - safe to run multiple times.

## Partial Updates

```bash
./install/update.sh symlink  # Symlinks only
./install/update.sh brew     # Homebrew packages only
./install/update.sh mise     # mise tools only
./install/update.sh os       # OS-specific setup only
./install/update.sh post     # Post-install (git, rust, go) only
```

## Structure

```
dotfiles/
├── Brewfile.common      # Packages for all platforms
├── Brewfile.mac         # macOS specific (including casks)
├── Brewfile.ubuntu      # Ubuntu/WSL specific
├── mise/config.toml     # Global mise configuration
└── install/
    ├── update.sh        # Main entry point
    ├── lib.sh           # Idempotent helper functions
    ├── symlink.sh       # Common symlinks
    ├── brew.sh          # Homebrew setup
    ├── mise.sh          # mise setup
    ├── post-install.sh  # git, rust, go, neovim
    ├── mac/             # macOS specific
    └── ubuntu/          # Ubuntu/WSL/Vagrant specific
```

## Supported Platforms

| Platform | Auto-detected                        |
|----------|---------------                       |
| macOS    | `uname -s` = Darwin                  |
| WSL      | `uname -r` contains "microsoft"      |
| Vagrant  | `/etc/vagrant_box_build_time` exists |
| Ubuntu   | Fallback if none of the above match  |

## Author

[ktrysmt](https://github.com/ktrysmt)
