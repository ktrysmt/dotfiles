#!/bin/bash
# postStartCommand: symlink dotfiles Claude config into container
# Source: /home/node/.dotfiles-claude (baked into image)
# settings.json is merged (container-specific), not symlinked

set -euo pipefail

DOTFILES_CLAUDE="$HOME/.dotfiles-claude"
CLAUDE_DIR="$HOME/.claude"

mkdir -p "$CLAUDE_DIR"

# --------------------------------------------------------------------------
# Symlink config files from image-baked dotfiles
# --------------------------------------------------------------------------
for name in CLAUDE.md rules skills hooks keybindings.json statusline-command.sh; do
    src="$DOTFILES_CLAUDE/$name"
    dst="$CLAUDE_DIR/$name"
    if [ -e "$src" ]; then
        rm -rf "$dst"
        ln -sfn "$src" "$dst"
    fi
done
echo "Dotfiles Claude config symlinked."

# --------------------------------------------------------------------------
# Register MCP servers via CLI
# --------------------------------------------------------------------------
if command -v claude >/dev/null 2>&1; then
    echo "Registering MCP servers..."
    claude mcp add -s user -t http aws-docs https://knowledge-mcp.global.api.aws || true
    claude mcp add -s user -t http grep-github https://mcp.grep.app || true
    echo "MCP servers registered."
fi

# --------------------------------------------------------------------------
# Merge container-specific settings into settings.json
# --------------------------------------------------------------------------
# These settings are container-specific (hooks paths, statusLine, plugins).
# jq deep-merge preserves keys Claude Code writes (e.g. skipDangerousModePermissionPrompt).
DESIRED_SETTINGS=$(cat << 'SETTINGS_EOF'
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
)

if [ -f "$CLAUDE_DIR/settings.json" ]; then
    jq -s '.[0] * .[1]' "$CLAUDE_DIR/settings.json" <(echo "$DESIRED_SETTINGS") > "$CLAUDE_DIR/settings.json.tmp"
    mv "$CLAUDE_DIR/settings.json.tmp" "$CLAUDE_DIR/settings.json"
else
    echo "$DESIRED_SETTINGS" > "$CLAUDE_DIR/settings.json"
fi
echo "Container settings.json merged."

# --------------------------------------------------------------------------
# Create .claude.json (skip onboarding wizard)
# --------------------------------------------------------------------------
if [ ! -f "$HOME/.claude.json" ]; then
    echo '{"hasCompletedOnboarding": true}' > "$HOME/.claude.json"
    echo "Created .claude.json (skip onboarding)."
fi

echo "Claude setup complete."
