# kubectl
if type kubectl > /dev/null 2>&1 ;then
  function kubectl() {
    if ! type __start_kubectl >/dev/null 2>&1; then
        source <(command kubectl completion zsh)
    fi
    command kubectl "$@"
  }
fi

# helm
if type helm > /dev/null 2>&1 ;then
  function helm() {
    if ! type __start_helm >/dev/null 2>&1; then
        source <(command helm completion zsh)
    fi
    command helm "$@"
  }
fi

# eksctl
if type eksctl > /dev/null 2>&1 ;then
  function eksctl() {
    if ! type __start_eksctl >/dev/null 2>&1; then
        source <(command eksctl completion zsh)
    fi
    command eksctl "$@"
  }
fi

# kind
if type kind > /dev/null 2>&1 ;then
  function kind() {
    if ! type __start_kind >/dev/null 2>&1; then
        source <(command kind completion zsh)
    fi
    command kind "$@"
  }
fi
