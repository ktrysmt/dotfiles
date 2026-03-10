_GCM_RAW=$(git config --global --get credential.helper 2>/dev/null)
if [[ "$_GCM_RAW" == *credential-manager* ]]; then
  _GCM_EXE=(${(Q)${(z)_GCM_RAW}})
  if ! whence "$_GCM_EXE[1]" &>/dev/null; then
    unset _GCM_RAW _GCM_EXE
    return 0 2>/dev/null || true
  fi
  unset _GCM_RAW
  readonly _GCM_EXE
  GCM_ENV_KEYS=("${(@f)$(< "${0:h}/.keys")}")

  _gcm-call() {
    local action=$1; shift
    printf '%s\n' "$@" "" | timeout 1 "${_GCM_EXE[@]}" "$action" 2>/dev/null
  }

  _gcm-confirm() {
    local reply
    read -q "reply?$1 [y/N] " || { echo; return 1 }
    echo
  }

  gcm-get() {
    _gcm-confirm "Access credential: $1" || return 1
    _gcm-call get "protocol=custom" "host=env" "username=$1" | sed -n 's/^password=//p'
  }

  gcm-set() {
    local key=${1:u}
    _gcm-confirm "Store credential: $key" || return 1
    local val
    printf 'Enter value for %s: ' "$key"
    read -rs val
    echo
    [[ -z "$val" ]] && return 1
    _gcm-call store "protocol=custom" "host=env" "username=$key" "password=$val"
  }

  gcm-rm() {
    _gcm-confirm "Remove credential: ${1:u}" || return 1
    _gcm-call erase "protocol=custom" "host=env" "username=${1:u}"
  }

  gcm-ls() {
    _gcm-confirm "List all credentials" || return 1
    local key val
    for key in "${GCM_ENV_KEYS[@]}"; do
      val=$(_gcm-call get "protocol=custom" "host=env" "username=$key" | sed -n 's/^password=//p')
      if [[ -n "$val" ]]; then
        printf '%s\t%s\n' "$key" "${val[1,2]}****"
      else
        printf '%s\t(not set)\n' "$key"
      fi
    done
  }

  _gcm-key-completion() { compadd -a GCM_ENV_KEYS }
  (( $+functions[compdef] )) && compdef _gcm-key-completion gcm-set gcm-get gcm-rm
fi
