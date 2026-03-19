FROM node:20

ARG TZ
ENV TZ="$TZ"

# ------------------------------------------------------------------------------
# System packages
# ------------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
  less git procps sudo zsh man-db unzip gnupg2 gh \
  iptables ipset iproute2 dnsutils aggregate jq \
  curl wget tree watch \
  build-essential python3 python3-venv \
  libevent-dev ncurses-dev bison pkg-config \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# tmux (built from source to match host version for socket compatibility)
# ------------------------------------------------------------------------------
ARG TMUX_VERSION=3.6a

RUN wget -q "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz" && \
  tar xzf "tmux-${TMUX_VERSION}.tar.gz" && \
  cd "tmux-${TMUX_VERSION}" && \
  ./configure --prefix=/usr/local && \
  make -j"$(nproc)" && \
  make install && \
  cd .. && rm -rf "tmux-${TMUX_VERSION}" "tmux-${TMUX_VERSION}.tar.gz"

# ------------------------------------------------------------------------------
# CLI tools from GitHub Releases (pinned versions, no API calls)
# ------------------------------------------------------------------------------
ARG GIT_DELTA_VERSION=0.18.2
ARG RIPGREP_VERSION=15.1.0
ARG FD_VERSION=v10.4.2
ARG BAT_VERSION=v0.26.1
ARG EZA_VERSION=v0.23.4
ARG FZF_VERSION=v0.70.0

RUN ARCH=$(dpkg --print-architecture) && \
  if [ "$ARCH" = "amd64" ]; then MUSL_ARCH="x86_64"; else MUSL_ARCH="aarch64"; fi && \
  # delta
  wget -q "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  dpkg -i "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  rm "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  # ripgrep (tag has no v prefix)
  wget -q "https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep-${RIPGREP_VERSION}-${MUSL_ARCH}-unknown-linux-musl.tar.gz" && \
  tar xzf ripgrep-*.tar.gz && cp ripgrep-*/rg /usr/local/bin/ && rm -rf ripgrep-* && \
  # fd
  wget -q "https://github.com/sharkdp/fd/releases/download/${FD_VERSION}/fd-${FD_VERSION}-${MUSL_ARCH}-unknown-linux-musl.tar.gz" && \
  tar xzf fd-*.tar.gz && cp fd-*/fd /usr/local/bin/ && rm -rf fd-* && \
  # bat
  wget -q "https://github.com/sharkdp/bat/releases/download/${BAT_VERSION}/bat-${BAT_VERSION}-${MUSL_ARCH}-unknown-linux-musl.tar.gz" && \
  tar xzf bat-*.tar.gz && cp bat-*/bat /usr/local/bin/ && rm -rf bat-* && \
  # eza
  wget -q "https://github.com/eza-community/eza/releases/download/${EZA_VERSION}/eza_${MUSL_ARCH}-unknown-linux-musl.tar.gz" && \
  tar xzf eza_*.tar.gz && mv eza /usr/local/bin/ && rm -f eza_*.tar.gz && \
  # fzf (filename strips v prefix)
  FZF_VER_NOPFX=$(echo "$FZF_VERSION" | sed 's/^v//') && \
  if [ "$ARCH" = "amd64" ]; then FZF_ARCH="amd64"; else FZF_ARCH="arm64"; fi && \
  wget -q "https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/fzf-${FZF_VER_NOPFX}-linux_${FZF_ARCH}.tar.gz" && \
  tar xzf fzf-*.tar.gz && mv fzf /usr/local/bin/ && rm -f fzf-*.tar.gz

# ------------------------------------------------------------------------------
# uv (Python toolchain manager) + bun
# ------------------------------------------------------------------------------
RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh && \
  uv python install 3.13 && \
  curl -fsSL https://bun.sh/install | BUN_INSTALL=/usr/local bash

# ------------------------------------------------------------------------------
# Go (optional)
# ------------------------------------------------------------------------------
ARG INSTALL_GO=true
ARG GO_VERSION=1.25.3

RUN if [ "$INSTALL_GO" = "true" ]; then \
  ARCH=$(dpkg --print-architecture) && \
  wget -q "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz" && \
  tar -C /usr/local -xzf "go${GO_VERSION}.linux-${ARCH}.tar.gz" && \
  rm "go${GO_VERSION}.linux-${ARCH}.tar.gz"; \
  fi

ENV PATH="/usr/local/go/bin:$PATH"

# ------------------------------------------------------------------------------
# Rust (optional)
# ------------------------------------------------------------------------------
ARG INSTALL_RUST=true

RUN if [ "$INSTALL_RUST" = "true" ]; then \
  export RUSTUP_HOME=/usr/local/rustup && \
  export CARGO_HOME=/usr/local/cargo && \
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
  sh -s -- -y --no-modify-path --default-toolchain stable && \
  chmod -R a+r /usr/local/rustup /usr/local/cargo && \
  find /usr/local/cargo/bin -type f -exec chmod a+x {} +; \
  fi

ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV PATH="/usr/local/cargo/bin:$PATH"

# ------------------------------------------------------------------------------
# Claude Code (native installer, not npm)
# ------------------------------------------------------------------------------
ARG CLAUDE_CODE_VERSION=latest
RUN curl -fsSL https://claude.ai/install.sh | bash -s -- ${CLAUDE_CODE_VERSION} && \
    cp "$(readlink -f /root/.local/bin/claude)" /usr/local/bin/claude

# ------------------------------------------------------------------------------
# User setup
# ------------------------------------------------------------------------------
ARG USERNAME=node

# node user already exists in node:20 base image; just set shell to zsh
RUN usermod -s /bin/zsh $USERNAME

# Persist bash history
RUN mkdir -p /commandhistory && \
  touch /commandhistory/.bash_history && \
  chown -R $USERNAME /commandhistory

# Create workspace and config directories
RUN mkdir -p /workspace /home/node/.claude && \
  chown -R node:node /workspace /home/node/.claude

# Dotfiles baked into image
COPY --chown=node:node claude/ /home/node/.dotfiles-claude/
COPY --chown=node:node .gitignore_global /home/node/.gitignore_global

WORKDIR /workspace

# ------------------------------------------------------------------------------
# Firewall & setup scripts
# ------------------------------------------------------------------------------
COPY .devcontainer/init-firewall.sh .devcontainer/setup-claude.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-firewall.sh /usr/local/bin/setup-claude.sh && \
  echo "node ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/node-firewall && \
  chmod 0440 /etc/sudoers.d/node-firewall

ENV TERM=xterm-256color
ENV COLORTERM=truecolor

# Force TERM/COLORTERM in zsh (pty may override Docker ENV)
RUN echo 'export TERM=xterm-256color' >> /etc/zsh/zshenv && \
  echo 'export COLORTERM=truecolor' >> /etc/zsh/zshenv

USER node
ENV SHELL=/bin/zsh

RUN git config --global core.excludesfile ~/.gitignore_global
