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

## 予備知識

```
読み込み順序（基本）

1.  /etc/zsh/zshenv      ← システム全体 (常に最初に読み込み)
2.  ~/.zshenv (または $ZDOTDIR/.zshenv)
3.  /etc/zsh/zprofile    ← ログインシェルのみ
4.  ~/.zprofile
5.  /etc/zsh/zshrc       ← インタラクティブシェルのみ
6.  ~/.zshrc
7.  /etc/zsh/zlogin      ← ログインシェルのみ
8.  ~/.zlogin
9.  /etc/zsh/zlogout     ← シェル終了時（ログインシェルのみ）
10. ~/.zlogout

各ファイルの読み込み条件
┌──────────┬─────────────────────────────────────────────────────────────┐
│ ファイル │                        読み込み条件                         │
├──────────┼─────────────────────────────────────────────────────────────┤
│ zshenv   │ 常に読み込まれる（-f オプションか NO_RCS でスキップ可能）   │
├──────────┼─────────────────────────────────────────────────────────────┤
│ zprofile │ ログインシェル時のみ（引数の最初に - または -l オプション） │
├──────────┼─────────────────────────────────────────────────────────────┤
│ zshrc    │ インタラクティブシェル時のみ                                │
├──────────┼─────────────────────────────────────────────────────────────┤
│ zlogin   │ ログインシェル時のみ（zprofile の後）                       │
├──────────┼─────────────────────────────────────────────────────────────┤
│ zlogout  │ シェル終了時、ログインシェルのみ                            │
└──────────┴─────────────────────────────────────────────────────────────┘

状況別の読み込み

インタラクティブ・ログインシェル（例: zsh -l）
/etc/zsh/zshenv → ~/.zshenv → /etc/zsh/zprofile → ~/.zprofile →
/etc/zsh/zshrc → ~/.zshrc → /etc/zsh/zlogin → ~/.zlogin

インタラクティブ・ノンログインシェル（例: zsh）
/etc/zsh/zshenv → ~/.zshenv → /etc/zsh/zshrc → ~/.zshrc

ノンインタラクティブ（スクリプト実行）
/etc/zsh/zshenv → ~/.zshenv
```


## Author

[ktrysmt](https://github.com/ktrysmt)
