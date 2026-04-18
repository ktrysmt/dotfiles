---
entity: devcontainer
category: environments
sources:
  - path: /Users/dew/dotfiles/.devcontainer/Dockerfile
    source_type: primary
    sha256: 62964f1429038595ed31a6c75c78807b300919fd749c579820c476e964960535
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.devcontainer/devcontainer.json
    source_type: primary
    sha256: f887a4a10383b33dc9865f748b2cb2135958ed9853bf86b50129022ba9209ebc
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.devcontainer/README.md
    source_type: secondary
    sha256: 7186dabf9a3f8aec4875f0fcdcdb64196456375658881293db1a2f162295ab27
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.devcontainer/init-firewall.sh
    source_type: primary
    sha256: efcc7c0b68db2c699b601a41957a9b4dc0dabb91fbf69f93a2f4151b91f1e9cc
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.devcontainer/refresh-firewall.sh
    source_type: primary
    sha256: 79f41abc78a5c71a541ca524927f82e06924025cc7aab95f577415bf4ebf4209
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.devcontainer/setup-claude.sh
    source_type: primary
    sha256: 0b36733a77618f2b4ed2a10da6088c1b0349ba4bcd1283a15264df9ebfce8537
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.devcontainer/trace-network.sh
    source_type: primary
    sha256: e8d85a540da70550dd4f649aa7214f4a694092651fed4b36b6d0caa4f4007376
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.github/workflows/devcontainer.yml
    source_type: primary
    sha256: 2f055aca8149ac1bfae59507de32f765f784c862450ad2daaef156d087218983
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.dockerignore
    source_type: secondary
    sha256: 2d6beb057201fd151ab658483e6d07c0b6dca82d33e1120833657e5625fbb1a6
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.docker/config.json
    source_type: secondary
    sha256: df79cefeb82d4276f180491c0edeb195ebec2c7d0216ffab3de2cab8b362ea64
    ingested: 2026-04-06
  - path: /Users/dew/dotfiles/.github/claude.yml.example
    source_type: secondary
    sha256: 00d4d0d1abd454b8f53cc938c978245c9e529ac242539431d8651223b591337e
    ingested: 2026-04-06
related:
  - claude-code-config
  - dotfiles-install
  - mcp-servers
  - claude-code-hooks
created: 2026-04-06
updated: 2026-04-18
---

# DevContainer Environment

## Overview
Docker-based isolated development environment (sandbox) for Claude Code. Multi-architecture (amd64, arm64) image built via GitHub Actions and published to GHCR. Features eBPF-based TCP network tracing, iptables-based firewall with whitelist domain filtering, and Claude Code setup with MCP servers. Persists config via bind mounts to ~/.claude-devcontainer.

## Key Facts
- Dockerfile: multi-arch (amd64, arm64) with full toolchain and Claude Code
- devcontainer.json: container settings, mounts, and features
- init-firewall.sh: iptables firewall with whitelist-based domain filtering
- refresh-firewall.sh: cron-based firewall rule refresh
- setup-claude.sh: Claude Code configuration and MCP server setup
- trace-network.sh: eBPF-based TCP connection tracer; logs to ~/.claude/networklogs
- GitHub Actions: multi-arch build and push to GHCR on .devcontainer/*/claude/* changes
- Docker config: detachKeys customization, experimental features enabled
- Bind mount: ~/.claude-devcontainer for persistent config
- claude.yml.example: GitHub Actions Claude Code integration example

## Relations
- [[claude-code-config]] -- Claude Code configured inside devcontainer
- [[dotfiles-install]] -- Devcontainer as alternative deployment target
- [[mcp-servers]] -- MCP servers set up via setup-claude.sh
- [[claude-code-hooks]] -- tmux-window-claude-status.sh falls back to TCP relay inside devcontainer

## Source Files
| Date | File | Type |
|---|---|---|
| 2026-04-06 | .devcontainer/Dockerfile | primary |
| 2026-04-06 | .devcontainer/devcontainer.json | primary |
| 2026-04-06 | .devcontainer/README.md | secondary |
| 2026-04-06 | .devcontainer/init-firewall.sh | primary |
| 2026-04-06 | .devcontainer/refresh-firewall.sh | primary |
| 2026-04-06 | .devcontainer/setup-claude.sh | primary |
| 2026-04-06 | .devcontainer/trace-network.sh | primary |
| 2026-04-06 | .github/workflows/devcontainer.yml | primary |
| 2026-04-06 | .dockerignore | secondary |
| 2026-04-06 | .docker/config.json | secondary |
| 2026-04-06 | .github/claude.yml.example | secondary |

## Changelog
- 2026-04-06: Initial creation from 11 devcontainer and Docker files
- 2026-04-18: Added bidirectional relation to claude-code-hooks (tmux status hook has devcontainer TCP relay)
