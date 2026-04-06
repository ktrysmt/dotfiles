---
entity: credential-management
category: concepts
sources:
  - path: /Users/dew/dotfiles/zsh/gcm.zsh
    source_type: primary
    sha256: 771eee3c62371ccd424a81855b16de00937154a4409c57922e998b9dd7bea444
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/zsh/osx.zsh
    source_type: primary
    sha256: e51d809f9f2c4027d33b2a2d05ee4c05af5360c9917ad53638916146c50385a2
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/zsh/.keys.example
    source_type: secondary
    sha256: 6d51ce85b9354bd03c9ad728953a3940b990d4150a0f87489e881b991cf90867
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/zsh/btw.zsh_bk
    source_type: secondary
    sha256: 472cfb55ef68b9bb2ece11b2411cd768e6a53f50c87e224f77f202ddd177ad0c
    ingested: 2026-04-06
related:
  - zsh-shell
  - claude-code-config
created: 2026-04-06
updated: 2026-04-06
---

# Credential Management System

## Overview
Three-tier credential management system adapted per platform. WSL2 uses Git Credential Manager (gcm.zsh: gcm-get/set/rm/ls). macOS uses Keychain (osx.zsh: kc-get/set/rm/ls). Bitwarden CLI (btw.zsh_bk, currently disabled) provides a universal fallback. All systems manage the same set of keys defined in `.keys.example` (ANTHROPIC_API_KEY, GEMINI_API_KEY). Credentials are exported as environment variables and used by shell functions and external tools.

## Key Facts
- WSL2: Git Credential Manager (gcm-get, gcm-set, gcm-rm, gcm-ls) with confirmation prompts
- macOS: Keychain integration (kc-get, kc-set, kc-rm, kc-ls) via security framework
- Bitwarden (DISABLED): bw-unlock, bw-ls, bw-get, bwe (env export); auto-unlock on use
- Required keys: ANTHROPIC_API_KEY, GEMINI_API_KEY (defined in .keys.example)
- Keys stored in .keys file (gitignored) per platform helper
- Custom completion support for credential key names
- Credentials exported as environment variables for shell functions and tools

## Relations
- [[zsh-shell]] -- Credential helpers loaded as part of shell configuration
- [[claude-code-config]] -- ANTHROPIC_API_KEY used by Claude Code

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | zsh/gcm.zsh | primary |
| 2026-04-06 | zsh/osx.zsh | primary |
| 2026-04-06 | zsh/.keys.example | secondary |
| 2026-04-06 | zsh/btw.zsh_bk | secondary |

## Changelog
- 2026-04-06: Initial creation from 4 credential management files
