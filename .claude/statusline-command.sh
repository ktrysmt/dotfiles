#!/bin/sh
input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd')
printf "\033[01;32m%s@%s\033[00m:\033[01;34m%s\033[00m" "$(whoami)" "$(hostname -s)" "$cwd"
