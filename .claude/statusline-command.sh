#!/bin/sh
input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd' | sed "s|^$HOME|~|")
printf "\033[01;34m%s\033[00m" "$cwd"
