#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="$HOME/.claude/hooks/session_summarizer.log"

# stdinを一時ファイルに保存してからnohupで実行
tmpfile=$(mktemp)
cat > "$tmpfile"

# エラーもログに出力
nohup bash -c "python3 ~/.claude/hooks/session_summarizer.py < '$tmpfile' 2>> '$LOG_FILE'; rm -f '$tmpfile'" >> "$LOG_FILE" 2>&1 &
