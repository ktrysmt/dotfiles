# macOS Keychain credential helper (counterpart of gcm.zsh for WSL)
# Provides the same interface: kc-get, kc-set, kc-rm, kc-ls

if [[ "$(uname -s)" != Darwin ]]; then
  return 0 2>/dev/null || true
fi

KC_ENV_KEYS=("${(@f)$(< "${0:h}/.keys")}")
readonly _KC_ACCOUNT="$(whoami)"

kc-get() {
  security find-generic-password -s "$1" -a "$_KC_ACCOUNT" -w 2>/dev/null \
    || { echo "error: '$1' not found in Keychain" >&2; return 1; }
}

kc-set() {
  local key=${1:u}
  local val
  printf 'Enter value for %s: ' "$key"
  read -rs val
  echo
  [[ -z "$val" ]] && return 1
  security add-generic-password -s "$key" -a "$_KC_ACCOUNT" -w "$val" -U -T /usr/bin/security
}

kc-rm() {
  local key=${1:u}
  security delete-generic-password -s "$key" -a "$_KC_ACCOUNT" >/dev/null 2>&1 \
    || { echo "error: '$key' not found in Keychain" >&2; return 1; }
}

kc-ls() {
  local key val
  for key in "${KC_ENV_KEYS[@]}"; do
    val=$(security find-generic-password -s "$key" -a "$_KC_ACCOUNT" -w 2>/dev/null)
    if [[ -n "$val" ]]; then
      printf '%s\t%s\n' "$key" "${val[1,2]}****"
    else
      printf '%s\t(not set)\n' "$key"
    fi
  done
}

_kc-key-completion() { compadd -a KC_ENV_KEYS }
(( $+functions[compdef] )) && compdef _kc-key-completion kc-set kc-get kc-rm
