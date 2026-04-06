---
entity: bin-scripts
category: components
sources:
  - path: /Users/dew/dotfiles/bin/git-checkout-remote-branch
    source_type: primary
    sha256: a6f6b53f90213eaa44c297a69c83e80ff50de4b541053ce36cf7644b7bfbcfd4
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/bin/git-echo-branch-tmux-current-pane
    source_type: primary
    sha256: 85ad29efa7042c169e1c711a44628402d336d4e970a7668d9744780a0a665910
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/bin/git-echo-prompt-is-clean
    source_type: primary
    sha256: e232389874acf91b2f1bc6d116150f7f4a6cb6bea05a022717299c18a883369b
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/bin/git-echo-username-and-email
    source_type: primary
    sha256: dc63529663627fb56195f6e53dad556b7c62a1aec643ad2c0a9c411482c63394
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/bin/echo-k8s-info
    source_type: primary
    sha256: 69e69024961696e10452fb2bd16fcb66f7e77d193abbb2ef780ec2988f128098
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/bin/echo-kubectx
    source_type: primary
    sha256: d65eb043008989c134678de0b304fe21dcce07f60923f415e180582cd9398f0d
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/bin/echo-kubens
    source_type: primary
    sha256: 0dc11b7ba510031a019c68339e77d0742ba575f0c2fffb0395eeadd6500ad1e0
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/bin/tmux-pane-border
    source_type: primary
    sha256: d4a253f01dfdec913059ae972f2dcdbb0b66f011af8144492885a8be12a64e07
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/bin/tsk
    source_type: primary
    sha256: bc19b983d4165d34db466118caf21df2958880af4143944228593feb84af224c
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/bin/serve-until-close
    source_type: secondary
    sha256: 3bf4a761739f3aa86322064802ed44977c2169a20f3040ec03075496a16a8675
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/bin/sh-echo-current-dir
    source_type: secondary
    sha256: 1b5fc185abc22b2209793d71c831cf64f0982103c01fb3cca023f5558b2f84c5
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/bin/sh-echo-current-wifi-network
    source_type: secondary
    sha256: a3e2a80f4f6d5d5fcf2a0ca5315728d6aef2dbc1e7f3afa99df0497e9fb6e926
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/bin/256to24bit.py
    source_type: secondary
    sha256: b7d9e3c83db954d48e9b79ad1ad0fb955ead2983b1b510f86fdf7cc264c0678d
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/bin/termcolor.pl
    source_type: secondary
    sha256: a25a00a5a7482420a7578b80f989fe5713438bb4ba336635c6eaa194747ad631
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/bin/claude-review-loop.sh
    source_type: secondary
    sha256: deba6e1c6318881f3098bad44a4be438fe7b0fa65bb0810b61cf771603793453
    ingested: 2026-04-06
related:
  - git-config
  - tmux-config
  - claude-code-config
created: 2026-04-06
updated: 2026-04-06
---

# Custom Utility Scripts

## Overview
Collection of custom utility scripts in `bin/` directory covering git helpers, tmux integration, Kubernetes info display, and miscellaneous tools. Git helpers provide branch management, prompt info, and user display. Tmux helpers format pane borders and send keys. Kubernetes helpers display context and namespace info for prompts/status lines.

## Key Facts
- git-checkout-remote-branch: interactive fuzzy branch selection via fzy; -f (force), --sync (prune merged)
- git-echo-branch-tmux-current-pane: output current git branch for tmux status
- git-echo-prompt-is-clean: check if working tree is clean for prompt
- git-echo-username-and-email: output git user.name and user.email
- echo-k8s-info: display kubectl context + namespace; silent if no kubectl/context
- echo-kubectx: output current Kubernetes context
- echo-kubens: output current Kubernetes namespace
- tmux-pane-border: format pane border with git branch + directory
- tsk: wrapper for tmux send-keys; format: tsk <pane> <command>
- serve-until-close: simple HTTP server running until connection closes
- sh-echo-current-dir: output sanitized current directory
- sh-echo-current-wifi-network: output WiFi network name (macOS)
- 256to24bit.py: RGB color conversion (8-bit to 24-bit)
- termcolor.pl: terminal ANSI color code generator
- claude-review-loop.sh: iterative Claude Code review wrapper

## Relations
- [[git-config]] -- Git helper scripts complement git configuration
- [[tmux-config]] -- tmux-pane-border and tsk for tmux integration
- [[claude-code-config]] -- claude-review-loop.sh for Claude Code workflows

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | bin/git-checkout-remote-branch | primary |
| 2026-04-06 | bin/git-echo-branch-tmux-current-pane | primary |
| 2026-04-06 | bin/git-echo-prompt-is-clean | primary |
| 2026-04-06 | bin/git-echo-username-and-email | primary |
| 2026-04-06 | bin/echo-k8s-info | primary |
| 2026-04-06 | bin/echo-kubectx | primary |
| 2026-04-06 | bin/echo-kubens | primary |
| 2026-04-06 | bin/tmux-pane-border | primary |
| 2026-04-06 | bin/tsk | primary |
| 2026-04-06 | bin/serve-until-close | secondary |
| 2026-04-06 | bin/sh-echo-current-dir | secondary |
| 2026-04-06 | bin/sh-echo-current-wifi-network | secondary |
| 2026-04-06 | bin/256to24bit.py | secondary |
| 2026-04-06 | bin/termcolor.pl | secondary |
| 2026-04-06 | bin/claude-review-loop.sh | secondary |

## Changelog
- 2026-04-06: Initial creation from 15 utility scripts
