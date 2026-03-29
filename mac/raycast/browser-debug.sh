#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Browser Debug
# @raycast.mode silent

# Optional parameters:
# @raycast.packageName browser-debug

if [ -d "/Applications/Brave Browser.app" ]; then
  open -a "Brave Browser" --args --remote-debugging-port=9222
elif [ -d "/Applications/Google Chrome.app" ]; then
  open -a "Google Chrome" --args --remote-debugging-port=9222
else
  echo "Brave Browser or Google Chrome not found"
  exit 1
fi
