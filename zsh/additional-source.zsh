if [[ -r "$HOME/.wasmer" ]]; then
  . "$HOME"/.wasmer/wasmer.sh
fi
if [[ -r "$HOME/.edge" ]]; then
  . "/home/ubuntu/.wasmedge/env"
fi
if [[ -r "$HOME/.cargo" ]]; then
  . "$HOME/.cargo/env"
fi
