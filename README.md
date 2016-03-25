# dotfiles

## how to use

### CentOS 6

```
sh -c "$(wget https://raw.github.com/keidrip/dotfiles/master/install_centos6.sh -O -)"
```

### Ubuntu 14.04

```
sh -c "$(wget https://raw.github.com/keidrip/dotfiles/master/install_ubuntu1404.sh -O -)"
```

## about windows

- use msys2
- and add module {git, make, gcc, vim}
- add it to .bashrc that `alias ls='ls -hF --color=tty'`
