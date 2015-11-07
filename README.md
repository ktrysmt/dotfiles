# dotfiles

## how to use

### CentOS 6

```
sh -c "$(wget https://raw.github.com/aqafiam/dotfiles/master/install_centos6.sh -O -)"
```

### Ubuntu 15.04

```
sh -c "$(wget https://raw.github.com/aqafiam/dotfiles/master/install_ubuntu1504.sh -O -)"
```

## manual setup for windows

1) Download and install msys2. [(https://msys2.github.io/)](https://msys2.github.io/)

2) paste update codes

```
pacman --needed -Sy bash pacman pacman-mirrors msys2-runtime
pacman -Syu
```

3) add line to .bashrc

```
echo 'export LS_COLORS="${LS_COLORS}:di=01;36"' >> ~/.bashrc
```

and uncomment some aliases in `.bashrc`.
