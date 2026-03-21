#!/bin/bash
# postStartCommand: inject dotfiles Claude config into container
#
# Source resolution (first match wins):
#   1. $HOME/claude             -- baked into self-built image (Dockerfile COPY)
#   2. /workspace/claude        -- portable image with repo bind-mounted
#
# settings.json is regenerated for the container (permissions stripped),
# not copied from the source.

set -euo pipefail
trap 'echo "ERROR: setup-claude.sh failed at line $LINENO (exit $?): $BASH_COMMAND" >&2' ERR

CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR"

# --------------------------------------------------------------------------
# Resolve source directory
# --------------------------------------------------------------------------
if [ -d "$HOME/claude" ]; then
    SRC_DIR="$HOME/claude"
elif [ -d "/workspace/claude" ]; then
    SRC_DIR="/workspace/claude"
else
    echo "ERROR: No claude config source found." >&2
    echo "  Checked: \$HOME/claude, /workspace/claude" >&2
    exit 1
fi
echo "Using config source: $SRC_DIR"

# --------------------------------------------------------------------------
# Symlink / copy config files from source
# --------------------------------------------------------------------------
for name in CLAUDE.md rules skills hooks keybindings.json statusline-command.sh .mcp.json; do
    src="$SRC_DIR/$name"
    dst="$CLAUDE_DIR/$name"
    if [ -e "$src" ]; then
        rm -rf "$dst"
        ln -sfn "$src" "$dst"
        echo "  Linked: $name"
    else
        echo "  Skip (not found): $name"
    fi
done
echo "Config files linked."

# --------------------------------------------------------------------------
# Register MCP servers via CLI
# --------------------------------------------------------------------------
if command -v claude >/dev/null 2>&1; then
    echo "Registering MCP servers..."
    claude mcp get aws-docs   >/dev/null 2>&1 || claude mcp add -s user -t http aws-docs https://knowledge-mcp.global.api.aws
    claude mcp get grep-github >/dev/null 2>&1 || claude mcp add -s user -t http grep-github https://mcp.grep.app
    echo "MCP servers registered."
fi

# --------------------------------------------------------------------------
# Merge container-specific settings into settings.json
# --------------------------------------------------------------------------
# Strip permission-related keys (container uses --dangerously-skip-permissions).
# jq deep-merge preserves keys Claude Code writes at runtime.
DESIRED_SETTINGS=$(jq 'del(.permissions, .sandbox, .skipDangerousModePermissionPrompt)' "$SRC_DIR/settings.json")

if [ -f "$CLAUDE_DIR/settings.json" ]; then
    jq -s '.[0] * .[1]' "$CLAUDE_DIR/settings.json" <(echo "$DESIRED_SETTINGS") > "$CLAUDE_DIR/settings.json.tmp"
    mv "$CLAUDE_DIR/settings.json.tmp" "$CLAUDE_DIR/settings.json"
else
    echo "$DESIRED_SETTINGS" > "$CLAUDE_DIR/settings.json"
fi
echo "Container settings.json merged."

# --------------------------------------------------------------------------
# Persist .claude.json inside bind-mounted $CLAUDE_DIR so it survives
# container recreation (--remove-existing-container).
# --------------------------------------------------------------------------
CLAUDE_JSON="$CLAUDE_DIR/.claude.json"
if [ -f "$HOME/.claude.json" ] && [ ! -L "$HOME/.claude.json" ]; then
    # claude mcp add may have created ~/.claude.json before us; merge it
    if [ -f "$CLAUDE_JSON" ]; then
        jq -s '.[0] * .[1] | .hasCompletedOnboarding = true' "$CLAUDE_JSON" "$HOME/.claude.json" > "$CLAUDE_JSON.tmp" && mv "$CLAUDE_JSON.tmp" "$CLAUDE_JSON"
    else
        jq '.hasCompletedOnboarding = true' "$HOME/.claude.json" > "$CLAUDE_JSON"
    fi
    rm -f "$HOME/.claude.json"
elif [ ! -f "$CLAUDE_JSON" ]; then
    echo '{"hasCompletedOnboarding": true}' > "$CLAUDE_JSON"
fi
ln -sfn "$CLAUDE_JSON" "$HOME/.claude.json"
echo "Persisted .claude.json in bind mount."

echo "Claude setup complete."
