# dotfiles

## How to Install

### Ubuntu

```
PASSWORD=vagrant && sh -c "curl -fsSL https://raw.github.com/ktrysmt/dotfiles/master/install_ubuntu.sh"
```

### macOS

```
sh -c "curl -fsSL https://raw.github.com/ktrysmt/dotfiles/master/install_macos.sh"
```

### CentOS 6

```
sh -c "curl -fsSL https://raw.github.com/ktrysmt/dotfiles/master/install_centos6.sh"
```

### Windows

<details>
<summary>You have to install manually some settings.</summary>
1. Install [MSYS2](https://msys2.github.io/)
2. Install Packages via pacman.
  - `pacman -S git tig make zsh tmux make winpty`
  - `git clone https://github.com/tarjoilija/zgen.git ~/.zgen`
  - `git clone https://github.com/ktrysmt/dotfiles ~/dotfiles`
3. mklink
  - Open cmd.exe by Administrator.
  - `cd C:\mssy64\home\USERNAME`
  - `mklink .minttyrc dotfiles\.minttyrc`
  - `mklink .zshenv dotfiles\.zshenv.win`
  - `mklink .zshrc dotfiles\.zshrc.win`
  - `mklink .vimrc dotfiles\.vimrc`
  - `mklink .tmux.conf dotfiles\.tmux.conf.win`
  - `mklink .gitconfig dotfiles\.gitconfig`
  - `mklink .tern-project dotfiles\.tern-project`
  - `mklink /D .config dotfiles\.config`
4. Create starter batch file as ZSH
  - `cp $HOME/../../msys2_shell.cmd $HOME/../../msys2_zsh.cmd`
  - `sed -i -e "s/bash/zsh/g" $HOME/../../msys2_zsh.cmd`
  - Open `msys2_zsh.cmd` and Enjoy! :smile:
</details>
