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
sheldon_cache_path="$cache_dir/sheldon.zsh"
if [[ ! -r "$sheldon_cache_path" ]]; then
  mkdir -p $cache_dir
  sheldon source > $sheldon_cache_path
fi
source "$sheldon_cache_path"
unset cache_dir sheldon_cache_path

# ---------
# end zwc
# ---------
# zsh-defer unfunction source


# Ensure Homebrew is at the front of PATH (after path_helper in /etc/zprofile)
path=(/opt/homebrew/bin /opt/homebrew/sbin $path)
path=("$HOME/.local/bin" "$HOME/.local/share/mise/shims" $path)

# Ensure mise shims are at the front of PATH (after path_helper in /etc/zprofile)
# path=("$HOME/.local/bin" "$HOME/.local/share/mise/shims" $path)

# zprof
