#!/bin/bash
# postCreateCommand: symlink dotfiles Claude config into container
# Source: /home/node/.dotfiles-claude (baked into image)
# settings.json is generated (container-specific), not symlinked

set -euo pipefail

DOTFILES_CLAUDE="$HOME/.dotfiles-claude"
CLAUDE_DIR="$HOME/.claude"

mkdir -p "$CLAUDE_DIR"

# --------------------------------------------------------------------------
# Symlink config files from image-baked dotfiles
# --------------------------------------------------------------------------
for name in CLAUDE.md rules skills hooks keybindings.json statusline-command.sh .mcp.json; do
    if [ -e "$DOTFILES_CLAUDE/$name" ]; then
        ln -sf "$DOTFILES_CLAUDE/$name" "$CLAUDE_DIR/$name"
    fi
done
echo "Dotfiles Claude config symlinked."

# --------------------------------------------------------------------------
# Create container-specific settings.json
# --------------------------------------------------------------------------
# - permissions: stripped (bypassed by --dangerously-skip-permissions)
# - settings.local.json: not needed (host-specific allow rules, also bypassed)
# - hooks: included (tmux hooks are guarded, others work as-is)
# - statusLine: included (uses jq/curl/git, all available in container)
# - enabledPlugins, env, effortLevel, alwaysThinkingEnabled: preserved
cat > "$CLAUDE_DIR/settings.json" << 'SETTINGS_EOF'
{
  "env": {
    "CLAUDE_CODE_DISABLE_AUTO_MEMORY": "1",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  },
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/tmux-window-claude-status.sh start"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/tmux-window-claude-status.sh thinking"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/tmux-window-claude-status.sh thinking"
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/tmux-window-claude-status.sh notification"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/tmux-window-claude-status.sh done"
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/tmux-window-claude-status.sh reset"
          },
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/cleanup-short-sessions.sh"
          },
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/session_summarizer_wrapper.sh"
          }
        ]
      }
    ]
  },
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline-command.sh"
  },
  "enabledPlugins": {
    "clangd-lsp@claude-plugins-official": true,
    "gopls-lsp@claude-plugins-official": true,
    "lua-lsp@claude-plugins-official": true,
    "typescript-lsp@claude-plugins-official": true
  },
  "alwaysThinkingEnabled": true,
  "effortLevel": "high"
}
SETTINGS_EOF

echo "Container settings.json created."

# --------------------------------------------------------------------------
# Create .claude.json (skip onboarding wizard)
# --------------------------------------------------------------------------
if [ ! -f "$HOME/.claude.json" ]; then
    echo '{"hasCompletedOnboarding": true}' > "$HOME/.claude.json"
    echo "Created .claude.json (skip onboarding)."
fi

echo "Claude setup complete."
