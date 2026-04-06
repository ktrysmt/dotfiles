---
entity: macos-apps
category: environments
sources:
  - path: /Users/dew/dotfiles/mac/karabiner-complex.json
    source_type: primary
    sha256: fe1e135dcd352b022af82ec43a9f58a762f6e1b3d92c80135b3387f2b0416478
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/mac/karabiner-complex-naginata.json
    source_type: primary
    sha256: 9b2c700091e73cb3e9cab42ff68dfa0393911082670ba506b9843c8aca4a7108
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/mac/RectangleConfig.json
    source_type: primary
    sha256: 2e8a39cb30d4b9ba16832a684f4c49d476b7a215514dc50f5cb3b1bd926b0448
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/mac/com.googlecode.iterm2.plist
    source_type: primary
    sha256: aae7b847f39a6cd71f363d90491f7e2d7907c134c96b6acb803edd53eaa8946e
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/mac/customized.itermkeymap
    source_type: primary
    sha256: 06bf4d5567e2b6a39ada9f2fa454e358e0810f1fc8ab718cbeb79553389840e8
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/mac/google_imekey_map.txt
    source_type: secondary
    sha256: 3f50fc3902654f7b6394628588063af374d0b437b834651235154597787ad0b4
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/mac/linearmouse/linearmouse.json
    source_type: primary
    sha256: a632bc4ff6734fded0aa1040e3c6864345ede135c11034fe75e56a878d87b351
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/mac/macgesture.txt
    source_type: secondary
    sha256: 5586695e54adc936c0e528435a67473a277ac39ec92f75fb548df63e9b84e16b
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/mac/raycast/browser-debug.sh
    source_type: secondary
    sha256: 5a898b427647aa2509dc4c882ac64ea72e70b38f8f0d7ad7bc25d733af280853
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/mac/raycast/trans.sh
    source_type: secondary
    sha256: d45234b9ea0b90183c0b9d8dbda215acc934de2c0711e938bd8727066cff50c8
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/mac/wezterm.lua
    source_type: primary
    sha256: 53a27be813c77eaabd676f85a7aebfe8aa107ccaf7111a6a76b33e2aceecad26
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/mac/readme.md
    source_type: secondary
    sha256: 072da01d51165c46d1eba38bda2c7fc607029b3e2e29206fb88deb7f39a06ac5
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/mac/linearmouse/README.md
    source_type: secondary
    sha256: 301a58e18dbb34d35e3d5241d0d0b3cf4e3a21bb759b26cf4fbbdfa397a8f0e3
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/mac/raycast/README.md
    source_type: secondary
    sha256: ee8a1cb7be94ea2dd99fe45547c9be23f8e12b2ce8591b7d682fa3afba17e2e4
    ingested: 2026-04-06
related:
  - homebrew
  - tmux-config
  - chrome-extensions
  - windows-apps
created: 2026-04-06
updated: 2026-04-06
---

# macOS Application Configs

## Overview
macOS-specific application configurations. Karabiner-Elements for keyboard remapping (kana->Enter, eisu->Backspace, Apple keyboard cmd/opt swap, Naginata IME integration). Rectangle for window tiling. iTerm2 as terminal emulator with custom keymaps and Japanese input. LinearMouse for disabling mouse acceleration. Raycast as launcher with custom script commands (browser-debug, translation). WezTerm as GPU-accelerated terminal with Lua config. MacGesture for trackpad gestures.

## Key Facts
- Karabiner: kana->Enter, eisu->Backspace, Apple cmd/opt swap; Naginata IME rules
- Rectangle: window snapping/tiling with custom gap size and autoProp
- iTerm2: plist config, custom itermkeymap, Google IME key map
- LinearMouse: disable mouse acceleration; config at ~/.config/linearmouse/linearmouse.json
- Raycast: custom scripts (browser-debug.sh, trans.sh); stored in ~/Library/Application Support/com.raycast.macos/
- WezTerm: GPU-accelerated terminal; Lua configuration (mac/wezterm.lua)
- MacGesture: trackpad gesture recognition config

## Relations
- [[homebrew]] -- macOS casks installed via Brewfile.mac
- [[tmux-config]] -- macOS-specific tmux variant (.tmux.conf.osx)
- [[chrome-extensions]] -- Browser extensions used alongside macOS apps
- [[windows-apps]] -- Counterpart platform configs

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | mac/karabiner-complex.json | primary |
| 2026-04-06 | mac/karabiner-complex-naginata.json | primary |
| 2026-04-06 | mac/RectangleConfig.json | primary |
| 2026-04-06 | mac/com.googlecode.iterm2.plist | primary |
| 2026-04-06 | mac/customized.itermkeymap | primary |
| 2026-04-06 | mac/google_imekey_map.txt | secondary |
| 2026-04-06 | mac/linearmouse/linearmouse.json | primary |
| 2026-04-06 | mac/macgesture.txt | secondary |
| 2026-04-06 | mac/raycast/browser-debug.sh | secondary |
| 2026-04-06 | mac/raycast/trans.sh | secondary |
| 2026-04-06 | mac/wezterm.lua | primary |
| 2026-04-06 | mac/readme.md | secondary |
| 2026-04-06 | mac/linearmouse/README.md | secondary |
| 2026-04-06 | mac/raycast/README.md | secondary |

## Changelog
- 2026-04-06: Initial creation from 14 macOS application config files
- 2026-04-06: Updated macgesture.txt sha256 (SULastCheckTime and other app state changes)
