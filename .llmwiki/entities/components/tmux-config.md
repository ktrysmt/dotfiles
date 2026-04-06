---
entity: tmux-config
category: components
sources:
  - path: /Users/dew/dotfiles/.tmux.conf.osx
    source_type: primary
    sha256: e5df9d970777ec68561368a28b4206910877525da7b045906013cd8529067137
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.tmux.conf.ubuntu
    source_type: primary
    sha256: a3c034a7ff3b10880bbd8f4a847de91bab19a8fa88bfc26c5be902ce83146bb2
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.tmux.conf.ubuntu_vagrant
    source_type: primary
    sha256: 0e3e29418db1fefd5c80d7735640140558d0afd58e79b7207c92b4037b652457
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.tmux.conf.wsl
    source_type: primary
    sha256: b5f32c4d2b80956338efded471b1918f72605eef3d93319b02faf91f7477bbae
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/bin/tmux-pane-border
    source_type: secondary
    sha256: d4a253f01dfdec913059ae972f2dcdbb0b66f011af8144492885a8be12a64e07
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/bin/tsk
    source_type: secondary
    sha256: bc19b983d4165d34db466118caf21df2958880af4143944228593feb84af224c
    ingested: 2026-04-06
related:
  - zsh-shell
  - bin-scripts
  - claude-code-hooks
  - macos-apps
created: 2026-04-06
updated: 2026-04-06
---

# Tmux Configuration

## Overview
Platform-specific tmux configurations for macOS, Ubuntu, WSL, and Vagrant. Prefix key is Ctrl+S. Uses vi-copy mode, custom pane border with git branch and directory info, and status line with timestamp. History limit is 10 million lines. Pane border info rendered by `bin/tmux-pane-border` script. `bin/tsk` provides a convenience wrapper for `tmux send-keys`. Auto-rename function in zsh updates window name based on current directory.

## Key Facts
- Prefix: Ctrl+S
- Copy mode: vi bindings
- History limit: 10,000,000 lines
- Pane border: shows git branch + directory via tmux-pane-border script
- Status line: shows timestamp
- Platform variants: .tmux.conf.osx, .tmux.conf.ubuntu, .tmux.conf.wsl, .tmux.conf.ubuntu_vagrant
- Socket directory: configured per-platform in .zshenv for devcontainer compatibility
- Auto-rename: tmux window renamed to current directory basename
- Claude status integration: hook updates tmux window status during Claude sessions

## Relations
- [[zsh-shell]] -- TMUX socket dir configured in .zshenv; auto-rename function
- [[bin-scripts]] -- tmux-pane-border and tsk helper scripts
- [[claude-code-hooks]] -- tmux-window-claude-status.sh updates window state
- [[macos-apps]] -- macOS-specific tmux config variant

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | .tmux.conf.osx | primary |
| 2026-04-06 | .tmux.conf.ubuntu | primary |
| 2026-04-06 | .tmux.conf.ubuntu_vagrant | primary |
| 2026-04-06 | .tmux.conf.wsl | primary |
| 2026-04-06 | bin/tmux-pane-border | secondary |
| 2026-04-06 | bin/tsk | secondary |

## Changelog
- 2026-04-06: Initial creation from 4 platform-specific tmux configs and 2 helper scripts
