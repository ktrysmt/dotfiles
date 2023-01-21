if [ -f /opt/homebrew/bin/brew ]; then
  export PATH=/opt/homebrew/bin:$PATH
fi
eval "$(sheldon source)"
