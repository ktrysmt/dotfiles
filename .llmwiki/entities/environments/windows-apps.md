---
entity: windows-apps
category: environments
sources:
  - path: /Users/dew/dotfiles/windows/WindowsTerminal.json
    source_type: primary
    sha256: 11930fddee4a87a6831ecd882f1d015ffc7d76ba1a55212a95032db9b2ce04d6
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/windows/keyhac-config.py
    source_type: primary
    sha256: 4e1d304782e4f732d84d8a9a9001a6da5eedc5ebaff7da050270bba78104edb2
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/windows/wezterm.lua
    source_type: primary
    sha256: cfbddb627576bb3699079806ddd676d1cc9323f724a643250958b1b318fac29c
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/windows/XMBC_Settings.xmbcp
    source_type: secondary
    sha256: a6baaef329322e0d58931e21ab5ae28517444e0400fd05e514a756612daad215
    ingested: 2026-04-06
related:
  - macos-apps
  - chrome-extensions
created: 2026-04-06
updated: 2026-04-06
---

# Windows Application Configs

## Overview
Windows-specific application configurations. Windows Terminal with 30+ custom keybindings and PowerShell/Pwsh default profile. Keyhac (Python-based key remapper) providing Ctrl+HJKL vim-like navigation with per-app overrides for Windows Terminal, Brave, and MPC-HC. WezTerm GPU-accelerated terminal (Lua config). XMBC for mouse button customization.

## Key Facts
- WindowsTerminal.json: 30+ custom keybindings; actions for copy, paste, split, find, close; default profile PowerShell/Pwsh
- keyhac-config.py: global Ctrl+HJKL -> arrow keys, Ctrl+[Shift+]JK/L/Semicolon for line nav; per-app overrides (WindowsTerminal, Brave, MPC-HC); IME state handling
- wezterm.lua: GPU-accelerated terminal config (Windows variant)
- XMBC_Settings.xmbcp: mouse button customization settings

## Relations
- [[macos-apps]] -- Counterpart platform configs (Karabiner=keyhac, iTerm2=WezTerm)
- [[chrome-extensions]] -- Browser extensions used alongside Windows apps

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | windows/WindowsTerminal.json | primary |
| 2026-04-06 | windows/keyhac-config.py | primary |
| 2026-04-06 | windows/wezterm.lua | primary |
| 2026-04-06 | windows/XMBC_Settings.xmbcp | secondary |

## Changelog
- 2026-04-06: Initial creation from 4 Windows application config files
