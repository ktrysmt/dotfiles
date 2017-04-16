# dotfiles

## How to Install

### Ubuntu

```
curl -fsSL https://raw.github.com/ktrysmt/dotfiles/master/install_ubuntu.sh | sh
```

### Ubuntu (for Vagrant)

```
PASSWORD=vagrant && curl -fsSL https://raw.github.com/ktrysmt/dotfiles/master/install_ubuntu.sh | sh
```

### Ubuntu (for Desktop)

```
curl -fsSL https://raw.github.com/ktrysmt/dotfiles/master/install_ubuntu_desktop.sh | sh
```

### macOS (for Sierra)

```
curl -fsSL https://raw.github.com/ktrysmt/dotfiles/master/install_macos_sierra.sh | sh
```

### macOS (<= ElCapitan)

```
curl -fsSL https://raw.github.com/ktrysmt/dotfiles/master/install_macos.sh | sh
```

### CentOS 6

```
curl -fsSL https://raw.github.com/ktrysmt/dotfiles/master/install_centos6.sh | sh
```

### Windows

<details>
<summary>You have to install manually some settings.</summary>

1. Install the font [RictyDiminished](https://github.com/edihbrandon/RictyDiminished).
2. Install [MSYS2](https://msys2.github.io/).
3. Install Packages via pacman.
  - `pacman -S git tig make zsh tmux make winpty python`
  - `git clone https://github.com/tarjoilija/zgen.git ~/.zgen`
  - `git clone https://github.com/ktrysmt/dotfiles ~/dotfiles`
4. mklink
  - Open cmd.exe by Administrator.
  - `cd C:\msys64\home\USERNAME`
  - `mklink .minttyrc dotfiles\.minttyrc`
  - `mklink .zshenv dotfiles\.zshenv.win`
  - `mklink .zshrc dotfiles\.zshrc.win`
  - `mklink .vimrc dotfiles\.vimrc`
  - `mklink .tmux.conf dotfiles\.tmux.conf.win`
  - `mklink .gitconfig dotfiles\.gitconfig`
  - `mklink .tern-project dotfiles\.tern-project`
  - `mklink /D .config dotfiles\.config`
5. Create starter batch file as ZSH
  - `cp $HOME/../../msys2_shell.cmd $HOME/../../msys2_zsh.cmd`
  - `sed -i -e "s/bash/zsh/g" $HOME/../../msys2_zsh.cmd`
  - Open `msys2_zsh.cmd` and Enjoy! :smile:
  
</details>

## Author

[ktrysmt](https://github.com/ktrysmt)
