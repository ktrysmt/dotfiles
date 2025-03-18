# wasmser
if [[ -r "$HOME/.wasmer" ]]; then
  . "$HOME"/.wasmer/wasmer.sh
fi
# wasmedge
if [[ -r "$HOME/.edge" ]]; then
  . "/home/ubuntu/.wasmedge/env"
fi
# cargo
if [[ -r "$HOME/.cargo" ]]; then
  . "$HOME/.cargo/env"
fi
# bun completions
[ -s "/home/ubuntu/.bun/_bun" ] && source "/home/ubuntu/.bun/_bun"
# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# mise
source <(mise activate zsh)
