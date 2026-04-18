---
entity: tmux-config
category: components
sources:
  - path: /Users/dew/dotfiles/.tmux.conf.osx
    source_type: primary
    sha256: 5b0d63a63a5068226f6db3f0404fa2cef2928afc16fb2afa6138d447d47bbdc8
    ingested: 2026-04-18
  - path: /Users/dew/dotfiles/.tmux.conf.ubuntu
    source_type: primary
    sha256: 3394952eaecdd554172269c3425562dcf590f8d5f2cd41d0338f9ce24251991c
    ingested: 2026-04-18
  - path: /Users/dew/dotfiles/.tmux.conf.ubuntu_vagrant
    source_type: primary
    sha256: f21e15f7fa62a81a2968b36eb3c97a1fcb96abfdf0684c322b52d40edd22dcdf
    ingested: 2026-04-18
  - path: /Users/dew/dotfiles/.tmux.conf.wsl
    source_type: primary
    sha256: cf7e65cb186dfb4865508f4608247e0237d0d2812a9097e05cd22f8a52065927
    ingested: 2026-04-18
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
  - claude-code-skills
created: 2026-04-06
updated: 2026-04-18
---

# Tmux Configuration

## Overview
Platform-specific tmux configurations for macOS, Ubuntu, WSL, and Vagrant. Prefix key is Ctrl+S. Uses vi-copy mode, custom pane border with git branch and directory info, and status line with timestamp. History limit is 10 million lines. Pane border info rendered by `bin/tmux-pane-border` script. `bin/tsk` provides a convenience wrapper for `tmux send-keys`. All variants bind `prefix f` to a `display-popup` invoking `~/dotfiles/bin/claude-tmux-delegate` for Claude task delegation, `prefix F` to split-window forking a Claude session via `claude --continue --fork-session`, and `prefix ,` to `tmux-rename-window` popup.

## Key Facts
- Prefix: Ctrl+S
- Copy mode: vi bindings; osx/wsl include MouseDragEnd1Pane copy-pipe-no-clear via pbcopy/win32yank [source: .tmux.conf.osx, primary, 2026-04-18]
- History limit: 10,000,000 lines
- Pane border: shows git branch + directory via tmux-pane-border script; bottom status; after-split-window and after-new-window hooks reapply pane-border-style
- Status line: top position, bg colour235; shows session name, timestamp; ubuntu_vagrant also shows echo-k8s-info
- Platform variants: .tmux.conf.osx, .tmux.conf.ubuntu, .tmux.conf.wsl, .tmux.conf.ubuntu_vagrant
- Socket directory: configured per-platform in .zshenv for devcontainer compatibility
- osx/wsl: automatic-rename off, allow-rename off; ubuntu/ubuntu_vagrant: automatic-rename on with zsh basename fallback in window-status-format [source: .tmux.conf.osx, primary, 2026-04-18]
- Claude delegation bindings: `prefix f` popup -> claude-tmux-delegate; `prefix F` right-vsplit 33% -> claude --continue --fork-session [source: .tmux.conf.osx, primary, 2026-04-18]
- Window rename: `prefix ,` popup -> bin/tmux-rename-window [source: .tmux.conf.osx, primary, 2026-04-18]
- Window switcher (osx/wsl): `prefix w` popup with fzf over list-windows [source: .tmux.conf.osx, primary, 2026-04-18]
- TPM plugins: tpm, tmux-sensible, tmux-resurrect, tmux-open; resurrect save/restore on M-w/M-r (osx/wsl/ubuntu) or w/r (ubuntu_vagrant)
- Terminal settings: osx/wsl set `allow-passthrough on`, `extended-keys on`, `terminal-features 'xterm*:extkeys'`; default-terminal varies (xterm-256color on osx, screen-256color on ubuntu, tmux-256color on wsl) [source: .tmux.conf.osx, primary, 2026-04-18]
- Claude status integration: hook updates tmux window status during Claude sessions

## Relations
- [[zsh-shell]] -- TMUX socket dir configured in .zshenv; auto-rename function
- [[bin-scripts]] -- tmux-pane-border, tsk, tmux-rename-window, claude-tmux-delegate helpers
- [[claude-code-hooks]] -- tmux-window-claude-status.sh updates window state
- [[macos-apps]] -- macOS-specific tmux config variant
- [[claude-code-skills]] -- tmux bindings invoke claude-tmux-delegate used by skills

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-18 | .tmux.conf.osx | primary |
| 2026-04-18 | .tmux.conf.ubuntu | primary |
| 2026-04-18 | .tmux.conf.ubuntu_vagrant | primary |
| 2026-04-18 | .tmux.conf.wsl | primary |
| 2026-04-06 | bin/tmux-pane-border | secondary |
| 2026-04-06 | bin/tsk | secondary |

## Changelog
- 2026-04-06: Initial creation from 4 platform-specific tmux configs and 2 helper scripts
- 2026-04-18: All 4 platform variants gained Claude delegation bindings (`prefix f`/`prefix F`) and `prefix ,` tmux-rename-window popup; osx/wsl added window switcher popup (`prefix w`) and extended-keys/passthrough settings; added [[claude-code-skills]] relation
