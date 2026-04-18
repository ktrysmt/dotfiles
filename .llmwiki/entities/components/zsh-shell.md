---
entity: zsh-shell
category: components
sources:
  - path: /Users/dew/dotfiles/.zshenv
    source_type: primary
    sha256: 14affc54ed41ed6dbe6bb25d53b05675a4df93dc8e38c0869095ffc84d7670c3
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.zshrc
    source_type: primary
    sha256: c70083e1bcf927cd0c89eb3da3f692abf6b0bf09515e9fd865d1a286069657b7
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/zsh/sync.zsh
    source_type: primary
    sha256: ed669809314a9d096af795249eaca64ce2c3596409713767b5d4bede658e928b
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/zsh/async.zsh
    source_type: primary
    sha256: e38579a8cbcfccc45eedb155500cb6c1382d288e952fe02634dff8b9d1bec0c3
    ingested: 2026-04-18
  - path: /Users/dew/dotfiles/zsh/gcm.zsh
    source_type: secondary
    sha256: 771eee3c62371ccd424a81855b16de00937154a4409c57922e998b9dd7bea444
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/zsh/osx.zsh
    source_type: secondary
    sha256: e51d809f9f2c4027d33b2a2d05ee4c05af5360c9917ad53638916146c50385a2
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/zsh/btw.zsh_bk
    source_type: secondary
    sha256: 472cfb55ef68b9bb2ece11b2411cd768e6a53f50c87e224f77f202ddd177ad0c
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/zsh/.keys.example
    source_type: secondary
    sha256: 6d51ce85b9354bd03c9ad728953a3940b990d4150a0f87489e881b991cf90867
    ingested: 2026-04-06
related:
  - sheldon-plugins
  - fzf-integration
  - tmux-config
  - git-config
  - credential-management
  - mise-runtime
  - homebrew
created: 2026-04-06
updated: 2026-04-18
---

# Zsh Shell Configuration

## Overview
Zsh shell configuration system split into synchronous (blocking) and asynchronous (deferred) phases for optimized startup. `.zshenv` handles earliest PATH/environment setup (Homebrew, mise shims, TMUX socket), while `.zshrc` bootstraps sheldon plugin cache. `sync.zsh` configures history options, completions, and shell options. `async.zsh` handles all functions, aliases, keybindings, and heavy logic via deferred loading. Platform-specific credential helpers exist for WSL (gcm.zsh) and macOS (osx.zsh).

## Key Facts
- `.zshenv` symlinked to `~/.zshenv`: earliest load for PATH, Homebrew, mise shims, TMUX socket dir
- `.zshrc` symlinked to `~/.zshrc`: bootstrap only via sheldon plugin cache
- `sync.zsh` loaded by sheldon (synchronous): setopt, bindkey, PROMPT, exports (BAT_THEME, FZF_*)
- `async.zsh` loaded by sheldon (deferred): all functions, aliases, lazy completions
- History: 100K entries, extended timestamps, multi-session sharing, duplicate suppression
- Git aliases: gd, gp, gl, gs, gca, gc, gdd, gds, gdt, gdw, glogg, glogo, grebase
- Kubernetes aliases: k, kg, kgp, kd, krm, klo, kex, kns, kctx
- Custom functions: powered_cd (directory history with stale-entry cleanup via `$ZSH_TAC_CMD` fallback), peco-select-snippet, gwa/gwflush (git worktree; gwflush prunes merged feature-* branches), trans (translates via `claude -p --model haiku --no-session-persistence`; ASCII->Japanese, multi-byte->English), howto (one-liner generation via claude/codex/gemini backends), dc (devcontainer up + exec with TMUX/TMUX_PANE env propagation), _tmux_auto_rename + _tmux_initial_rename (rename window to `basename $PWD`, skips when @manual-rename=1 or @saved-window-name set), sheldon wrapper (clears ~/.cache/sheldon.zsh on lock/add/remove), mml/mmh/pmm (memd markdown preview helpers) [source: async.zsh, primary, 2026-04-18]
- bindkey: `^v` inserts `$(gss | fzf | awk '{print $2}')`; ` ` (space) triggers expand-alias ZLE widget that expands global aliases with a `@@` placeholder cursor-position marker [source: async.zsh, primary, 2026-04-18]
- Lazy completions: kubectl, helm, eksctl, kind, gh, pnpm
- Theme: catppuccin-mocha (MEMD_THEME)
- Global aliases for pipeline: G (grep), L (less), H (head), T (tail), S (sort), W (wc)
- `gcm.zsh`: WSL2 Git Credential Manager helper (gcm-get/set/rm/ls)
- `osx.zsh`: macOS Keychain credential helper (kc-get/set/rm/ls)
- `btw.zsh_bk`: disabled Bitwarden CLI helper (bw-unlock, bw-ls, bw-get, bwe)
- `.keys.example`: template for required API keys (ANTHROPIC_API_KEY, GEMINI_API_KEY)

## Relations
- [[sheldon-plugins]] -- Plugin manager loading sync.zsh and async.zsh
- [[fzf-integration]] -- FZF configured via FZF_DEFAULT_COMMAND/FZF_DEFAULT_OPTS in sync/async
- [[tmux-config]] -- TMUX socket dir set in .zshenv; auto-rename function in .zshrc
- [[git-config]] -- Git aliases defined in .zshrc; worktree utilities (gwa, gwflush)
- [[credential-management]] -- GCM (WSL), Keychain (macOS), Bitwarden (backup) credential helpers
- [[mise-runtime]] -- Mise shims activated in .zshenv
- [[homebrew]] -- Homebrew PATH configured in .zshenv (Apple Silicon and Intel detection)

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | .zshenv | primary |
| 2026-04-06 | .zshrc | primary |
| 2026-04-06 | zsh/sync.zsh | primary |
| 2026-04-18 | zsh/async.zsh | primary |
| 2026-04-06 | zsh/gcm.zsh | secondary |
| 2026-04-06 | zsh/osx.zsh | secondary |
| 2026-04-06 | zsh/btw.zsh_bk | secondary |
| 2026-04-06 | zsh/.keys.example | secondary |

## Changelog
- 2026-04-06: Initial creation from 8 shell configuration files
- 2026-04-18: async.zsh gained howto function (claude/codex/gemini backends), sheldon wrapper that invalidates cache on lock/add/remove, dc devcontainer function, refactored powered_cd stale-entry cleanup, global-alias space-expand widget with `@@` cursor placeholder, and explicit @manual-rename / @saved-window-name skip logic in _tmux_auto_rename
