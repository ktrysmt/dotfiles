## extensions

```
# save
code --list-extensions > vscode/list-extensions

# restore
cat vscode/list-extensions | xargs -I % code --install-extension %
```

## apply markdown preview enhanced

1. ctrl + p
2. input `Markdown Preview Enhanced: Customize CSS`
3. opened style.less
4. paste [it](./style.less).

## keybindings

copy and paste [it](./keybindings.json).

## other environment settings (but it is elderly)

<https://gist.github.com/ktrysmt/6892e72c162f83280d586e8e959168f1>
