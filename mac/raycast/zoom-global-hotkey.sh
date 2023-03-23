#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title zoom global hotkey
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# open -a "zoom.us"
osascript -e '
tell application "System Events"
    tell application "zoom.us" to activate
end tell
'
