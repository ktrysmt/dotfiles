# ---------
# start zwc
# ---------
# function source {
#   ensure_zcompiled $1
#   builtin source $1
# }
# function ensure_zcompiled {
#   local compiled="$1.zwc"
#   if [[ ! -r "$compiled" || "$1" -nt "$compiled" ]]; then
#     zcompile $1
#   fi
# }
# ensure_zcompiled ~/.zshenv
# ensure_zcompiled ~/.zshrc

# cache
cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}
sheldon_cache="$cache_dir/sheldon.zsh"
sheldon_toml="$HOME/.config/sheldon/plugins.toml"
if [[ ! -r "$sheldon_cache" || "$sheldon_toml" -nt "$sheldon_cache" ]]; then
  mkdir -p $cache_dir
  sheldon source > $sheldon_cache
fi
source "$sheldon_cache"
unset cache_dir sheldon_cache sheldon_toml

# ---------
# end zwc
# ---------
# zsh-defer unfunction source

# zprof
