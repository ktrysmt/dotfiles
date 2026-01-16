#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title trans
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🌐
# @raycast.argument1 { "type": "text", "placeholder": "Text to translate" }
# @raycast.packageName trans

# Documentation:
# @raycast.description Translate text between English and Japanese using Gemini AI

# PATHを設定（geminiコマンド用）
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

text="$1"

# ASCII（英語と記号）のみなら日本語へ、マルチバイトがあれば英語へ
if [[ "$text" =~ ^[[:ascii:]]+$ ]]; then
  target="Japanese"
else
  target="English"
fi

result=$(gemini -m gemini-2.5-flash-lite "Translate to ${target}. Output ONLY the translation, nothing else: ${text}" 2>&1)

# クリップボードにコピー
echo -n "$result" | pbcopy

# 結果を表示
echo "$result"
echo ""
echo "target: $target"
echo ""
echo "📋 Copied to clipboard"
