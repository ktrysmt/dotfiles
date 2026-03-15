#!/bin/bash
# postCreateCommand: inject host Claude config into container
# Copies CLAUDE.md, rules, skills, hooks, .mcp.json, keybindings, statusline
# Creates a container-appropriate settings.json (permissions stripped for --dangerously-skip-permissions)

set -euo pipefail

HOST_DIR="$HOME/.claude-host"
WORKSPACE_CLAUDE="/workspace/.claude"
CLAUDE_DIR="$HOME/.claude"

mkdir -p "$CLAUDE_DIR"

# --------------------------------------------------------------------------
# Helper: copy file/dir from host mount, falling back to workspace .claude/
# Host mount may contain broken symlinks (pointing to host paths that don't
# exist inside the container), so we fall back to the workspace copy.
# --------------------------------------------------------------------------
copy_config() {
    local name="$1"
    local is_dir="${2:-false}"

    if [ "$is_dir" = "true" ]; then
        if [ -d "$HOST_DIR/$name" ] && cp -rL "$HOST_DIR/$name" "$CLAUDE_DIR/" 2>/dev/null; then
            return 0
        elif [ -d "$WORKSPACE_CLAUDE/$name" ]; then
            cp -r "$WORKSPACE_CLAUDE/$name" "$CLAUDE_DIR/"
            return 0
        fi
    else
        if [ -f "$HOST_DIR/$name" ] && cp -L "$HOST_DIR/$name" "$CLAUDE_DIR/$name" 2>/dev/null; then
            return 0
        elif [ -f "$WORKSPACE_CLAUDE/$name" ]; then
            cp "$WORKSPACE_CLAUDE/$name" "$CLAUDE_DIR/$name"
            return 0
        fi
    fi
    return 1
}

# --------------------------------------------------------------------------
# Copy config files from host (readonly bind mount)
# Follow symlinks with -L; fall back to /workspace/.claude/ if broken
# --------------------------------------------------------------------------
if [ -d "$HOST_DIR" ] || [ -d "$WORKSPACE_CLAUDE" ]; then
    copy_config "CLAUDE.md"
    copy_config "rules" true
    # Skills (only if non-empty)
    if [ -d "$HOST_DIR/skills" ] && [ "$(ls -A "$HOST_DIR/skills" 2>/dev/null)" ]; then
        copy_config "skills" true
    elif [ -d "$WORKSPACE_CLAUDE/skills" ] && [ "$(ls -A "$WORKSPACE_CLAUDE/skills" 2>/dev/null)" ]; then
        cp -r "$WORKSPACE_CLAUDE/skills" "$CLAUDE_DIR/"
    fi
    copy_config "hooks" true
    copy_config "statusline-command.sh"
    copy_config ".mcp.json"
    copy_config "keybindings.json"

    echo "Host Claude config injected."
else
    echo "WARNING: Host mount not found at $HOST_DIR. Skipping config injection."
fi

# --------------------------------------------------------------------------
# Create container-specific settings.json
# --------------------------------------------------------------------------
# - permissions: stripped (bypassed by --dangerously-skip-permissions)
# - settings.local.json: not copied (host-specific allow rules, also bypassed)
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
