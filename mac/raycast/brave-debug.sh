#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Brave Debug
# @raycast.mode silent

# Optional parameters:
# @raycast.icon /Applications/Brave Browser.app/Contents/Resources/app.icns
# @raycast.packageName brave-debug

# Documentation:
# @raycast.description Launch Brave Browser with remote debugging port 9222

open -a "Brave Browser" --args --remote-debugging-port=9222
