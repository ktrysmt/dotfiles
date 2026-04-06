---
source_type: derived
generated: 2026-04-06
source_entities:
  - tmux-config
  - dotfiles-install
---

# tmux設定の共通化戦略

## 現状

4つのプラットフォーム別tmux設定ファイルが個別に存在し、70-80%が重複している。

- `.tmux.conf.osx` (149行)
- `.tmux.conf.ubuntu` (141行)
- `.tmux.conf.wsl` (152行)
- `.tmux.conf.ubuntu_vagrant` (137行)

## プラットフォーム間の差分

| 差分カテゴリ | osx | wsl | ubuntu | vagrant |
|---|---|---|---|---|
| クリップボード | pbcopy/pbpaste | win32yank.exe | なし | xsel -bi |
| ターミナルタイプ | xterm-256color + RGB | tmux-256color + Tc | screen-256color + Tc | screen-256color + Tc |
| passthrough/extkeys | あり | あり | なし | なし |
| ウィンドウ名 | 手動(rename off) | 手動(rename off) | 自動(basename) | 自動(basename) |
| fzf window switcher | あり | あり | なし | なし |

## 推奨案: source-file分割 + 既存シンボリンク方式

tmuxの `source-file` コマンドで共通設定と差分を分離する。

### ディレクトリ構成

```
tmux/
  common.conf           # 共通設定 (全プラットフォーム共有)
  clipboard-osx.conf    # pbcopy/pbpaste
  clipboard-wsl.conf    # win32yank.exe
  clipboard-vagrant.conf # xsel
  platform-osx.conf     # terminal, window, fzf switcher
  platform-wsl.conf     # terminal, window, fzf switcher
  platform-linux.conf   # terminal, window (ubuntu/vagrant共通)
```

各 `.tmux.conf.<platform>` は2-3行のsource-fileのみになる:

```tmux
source-file ~/dotfiles/tmux/common.conf
source-file ~/dotfiles/tmux/clipboard-osx.conf
source-file ~/dotfiles/tmux/platform-osx.conf
```

### 選定理由

- `install/lib.sh` に既存のプラットフォーム検出ロジック(Darwin/microsoft/vagrant)があり、シンボリンク方式との相性が良い
- if-shell単一ファイル案はubuntuフォールバック判定が複雑になる
- リポジトリ全体の設計思想(プラットフォーム別symlink)に合致
