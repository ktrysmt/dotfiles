---
entity: dotfiles-install
category: procedures
sources:
  - path: /Users/dew/dotfiles/install/symlink.sh
    source_type: primary
    sha256: 50086ebf54f8ed228ae8166e387a15649e40b4af2e3a6746990468991fcef81a
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/install/lib.sh
    source_type: primary
    sha256: f4efc692b31516e452aa351add59a111f54230dbbfb636dcfcba70b114588570
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/install/brew.sh
    source_type: primary
    sha256: 1944313597a8ce8b82752a964475802eedfdf0c568b55ed6a927aae0234f749f
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/install/mise.sh
    source_type: primary
    sha256: f691e6e9a85754da11a802785ec404b1d7f0b651f9b4ac942c3911c9d4f5f155
    ingested: 2026-04-18
  - path: /Users/dew/dotfiles/install/post-install.sh
    source_type: primary
    sha256: d761d54c7a4cf9e502369b2ea67d775e7072f538a8b0dfca1d726cb294c39231
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/install/update.sh
    source_type: primary
    sha256: 7ce38bff1ba486bb4d811cc4345258866cc80ce2f73c0a1945ff9d5e68c5070a
    ingested: 2026-04-18
  - path: /Users/dew/dotfiles/install/mac/common.sh
    source_type: primary
    sha256: b5b4917d037210f71f7f5bdc50468915f19f0b49b128591a16eb57b97ec3347c
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/install/mac/default.sh
    source_type: primary
    sha256: bd7d18021a9990fd4e15a043f03e159694c972221cbc22150280d968ec51ef1b
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/install/mac/symlink.sh
    source_type: primary
    sha256: beb8e924296049939a9431dc0d88284f41788a7db5dcf8bc62afe2bf21f7313c
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/install/ubuntu/common.sh
    source_type: primary
    sha256: 2fd84e36fa2d2fd4917a5d624412c3458aab45f96ad65c6d67ad58cf870d647a
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/install/ubuntu/vagrant.sh
    source_type: primary
    sha256: 056290ae3cffefd450ef0faec1c6552f96df1cc9fed91a6db0b459ed540a95b6
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/install/ubuntu/wsl.sh
    source_type: primary
    sha256: 0b64ed4f878099c233edc128d52d7ea51ade6b7a726693d9e27db0433dc41676
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/README.md
    source_type: secondary
    sha256: 605f8ec78525e497d55467f4a4055fefcb6e232edbac68533179714413b8a2b7
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.snippet
    source_type: secondary
    sha256: 52e92d783917545ca46216c36fc4507925d9edc8c142a574a64f3f91778058e7
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.ctags
    source_type: secondary
    sha256: 689eaee6abbd042735b9d3ab65a66858df9e62d2975e62863eb9b8de3cdc0e3e
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.tigrc
    source_type: secondary
    sha256: 6ae617530666b887124b1b89cc91dc6fee2cec5ee2937a62fada7e5ad3803f56
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.switch-proxy.osx
    source_type: secondary
    sha256: 1b1f46167950de099898baa863332edff79f0e1a9450d2ad5ee909837c1d0a18
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.codex/config.toml
    source_type: secondary
    sha256: ce7e3913c380c82e4da6c19bbe4f1f857102318e4efae38800109f32523175a3
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.gitignore
    source_type: secondary
    sha256: ff8c92152a70f624832b3e991a3687dc575aa438a439b3d01c20226b7ff31b47
    ingested: 2026-04-18
  - path: /Users/dew/dotfiles/docs/overview.md
    source_type: derived
    sha256: 58e36140583d5c71a35bb0c53edeb13e3aa2d687e933cb464b8f286aaac06573
    ingested: 2026-04-18
related:
  - homebrew
  - mise-runtime
  - git-config
  - zsh-shell
  - tmux-config
  - macos-apps
  - claude-code-config
created: 2026-04-06
updated: 2026-04-18
---

# Dotfiles Installation System

## Overview
Idempotent installation system orchestrated by `install/update.sh`. Execution chain: symlink.sh -> brew.sh -> mise.sh -> OS-specific scripts -> post-install.sh -> sheldon cache rebuild. `lib.sh` provides shared helpers (link_file, ensure_dir, log_*) with automatic OS detection (mac/wsl/vagrant/ubuntu via uname). All scripts are safe to run multiple times without side effects.

## Key Facts
- update.sh: master orchestrator running all install steps in order; subcommands: all (default), symlink, brew, mise, os, post, claude [source: update.sh, primary, 2026-04-18]
- update.sh step order for `all`: symlink -> brew -> mise -> os_specific -> post_install -> sheldon -> claude [source: update.sh, primary, 2026-04-18]
- update.sh step_claude: reads `enabledPlugins` from claude/settings.json via jq, iterates entries where value==true, runs `claude plugin update <name>` for each; skipped when claude or jq unavailable [source: update.sh, primary, 2026-04-18]
- update.sh step_sheldon: removes ~/.cache/sheldon.zsh, runs `sheldon lock --update`, regenerates cache via `sheldon source > ~/.cache/sheldon.zsh` [source: update.sh, primary, 2026-04-18]
- update.sh step_os_specific: mac -> mac/common.sh; wsl -> ubuntu/common.sh + ubuntu/wsl.sh; vagrant -> ubuntu/common.sh + ubuntu/vagrant.sh; ubuntu -> ubuntu/common.sh + link .tmux.conf.ubuntu -> ~/.tmux.conf [source: update.sh, primary, 2026-04-18]
- lib.sh: shared helpers with platform detection (Darwin=mac, microsoft=wsl, vagrant_box_build_time=vagrant, fallback=ubuntu)
- symlink.sh: source of truth for all symlinks (shell, nvim, claude, mise, tools)
- brew.sh: Homebrew bundle install per platform (common + platform-specific)
- mise.sh: activate mise, trust ~/.config/mise/config.toml, run `mise install --yes` (non-fatal on npm failures due to ~/.npmrc minimumReleaseAge), `mise cache clear`, `mise up --yes`, `mise prune --yes`, fzf setup (when ~/.fzf.zsh missing), and Python 3.13 install/pin via `uv python install/pin --global` [source: mise.sh, primary, 2026-04-18]
- post-install.sh: rustup, go install delve, git-secrets, pynvim via uv
- mac/common.sh: macOS-specific common setup
- mac/default.sh: macOS defaults write commands
- mac/symlink.sh: macOS-only symlinks (Karabiner, Rectangle, iTerm2, tmux, linearmouse)
- ubuntu/common.sh: apt-get packages, zsh as default shell
- ubuntu/vagrant.sh: Vagrant-specific setup
- ubuntu/wsl.sh: WSL-specific setup (win32yank, wslu, sandbox-runtime)
- All operations are idempotent
- Also manages: .snippet, .ctags, .tigrc, .switch-proxy.osx, .codex/config.toml
- .gitignore excludes: *.zwc, .DS_Store, .claude/*.lock, .config/vim/, .ruff_cache, __pycache__/, claude/hooks/session_summarizer.log*, zsh/.keys; `!.claude/` re-includes the .claude directory [source: .gitignore, secondary, 2026-04-18]

## Relations
- [[homebrew]] -- brew.sh installs Homebrew packages
- [[mise-runtime]] -- mise.sh installs runtime tools
- [[git-config]] -- Git configs symlinked per platform
- [[zsh-shell]] -- Shell configs symlinked
- [[tmux-config]] -- Tmux configs symlinked per platform
- [[macos-apps]] -- macOS app configs symlinked
- [[claude-code-config]] -- update.sh step_claude keeps enabled Claude plugins current

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | install/symlink.sh | primary |
| 2026-04-06 | install/lib.sh | primary |
| 2026-04-06 | install/brew.sh | primary |
| 2026-04-18 | install/mise.sh | primary |
| 2026-04-06 | install/post-install.sh | primary |
| 2026-04-18 | install/update.sh | primary |
| 2026-04-06 | install/mac/common.sh | primary |
| 2026-04-06 | install/mac/default.sh | primary |
| 2026-04-06 | install/mac/symlink.sh | primary |
| 2026-04-06 | install/ubuntu/common.sh | primary |
| 2026-04-06 | install/ubuntu/vagrant.sh | primary |
| 2026-04-06 | install/ubuntu/wsl.sh | primary |
| 2026-04-06 | README.md | secondary |
| 2026-04-06 | .snippet | secondary |
| 2026-04-06 | .ctags | secondary |
| 2026-04-06 | .tigrc | secondary |
| 2026-04-06 | .switch-proxy.osx | secondary |
| 2026-04-06 | .codex/config.toml | secondary |
| 2026-04-18 | .gitignore | secondary |
| 2026-04-18 | docs/overview.md | derived |

## Changelog
- 2026-04-06: Initial creation from 18 installation and configuration files
- 2026-04-18: update.sh gained step_claude (plugin updater via jq), step_sheldon (cache regen), and `claude` subcommand; mise.sh gained `mise cache clear`, `mise up --yes`, `mise prune --yes`, and `uv python install 3.13` + `uv python pin --global 3.13`; added [[claude-code-config]] relation; registered .gitignore as secondary source and docs/overview.md as derived synthesis (generated 2026-04-06 from 27 llmwiki entities)
