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
    registered=$(claude mcp list -s user 2>/dev/null || true)
    echo "$registered" | grep -q "aws-docs" || claude mcp add -s user -t http aws-docs https://knowledge-mcp.global.api.aws || true
    echo "$registered" | grep -q "grep-github" || claude mcp add -s user -t http grep-github https://mcp.grep.app || true
    echo "MCP servers registered."
fi

# --------------------------------------------------------------------------
# Merge container-specific settings into settings.json
# --------------------------------------------------------------------------
# Read baked-in settings.json and strip permission-related keys
# (container uses --dangerously-skip-permissions, so permissions/sandbox are unnecessary).
# jq deep-merge preserves keys Claude Code writes at runtime.
DESIRED_SETTINGS=$(jq 'del(.permissions, .sandbox, .skipDangerousModePermissionPrompt)' "$DOTFILES_CLAUDE/settings.json")

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
