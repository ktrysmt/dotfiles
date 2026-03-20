# ==============================================================================
# Builder: tmux (separate stage to keep build deps out of final image)
# ==============================================================================
FROM node:20 AS tmux-builder

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential libevent-dev ncurses-dev bison pkg-config wget \
  && rm -rf /var/lib/apt/lists/*

ARG TMUX_VERSION=3.6a
RUN wget -q "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz" && \
  tar xzf "tmux-${TMUX_VERSION}.tar.gz" && \
  cd "tmux-${TMUX_VERSION}" && \
  ./configure --prefix=/usr/local && \
  make -j"$(nproc)" && \
  make install && \
  cd .. && rm -rf "tmux-${TMUX_VERSION}" "tmux-${TMUX_VERSION}.tar.gz"

# ==============================================================================
# Final image
# ==============================================================================
FROM node:20

ARG TZ=Asia/Tokyo
ENV TZ="$TZ"

# ------------------------------------------------------------------------------
# System packages
# ------------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
  less git procps sudo zsh man-db unzip gnupg2 \
  iptables ipset iproute2 dnsutils aggregate jq cron \
  curl wget tree watch \
  build-essential \
  libevent-2.1-7 \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# tmux (built in separate stage to match host version for socket compatibility)
# ------------------------------------------------------------------------------
COPY --from=tmux-builder /usr/local/bin/tmux /usr/local/bin/tmux
RUN tmux -V;

# ------------------------------------------------------------------------------
# Rust (optional, not managed by mise)
# ------------------------------------------------------------------------------
ARG INSTALL_RUST=false

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
# User setup
# ------------------------------------------------------------------------------
ARG USERNAME=node

# node user already exists in node:20 base image; just set shell to zsh
RUN usermod -s /bin/zsh $USERNAME

# Create workspace directory (/.claude is volume-mounted at runtime)
RUN mkdir -p /workspace && chown node:node /workspace
RUN mkdir -p /home/node/.claude && chown node:node /home/node/.claude
RUN mkdir -p /home/node/.local/bin && chown node:node -R /home/node/.local

# Dotfiles baked into image
COPY --chown=node:node claude/ /home/node/claude/
COPY --chown=node:node .gitignore_global /home/node/.gitignore_global

WORKDIR /workspace

# ------------------------------------------------------------------------------
# Firewall & setup scripts
# ------------------------------------------------------------------------------
COPY .devcontainer/init-firewall.sh .devcontainer/refresh-firewall.sh .devcontainer/setup-claude.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-firewall.sh /usr/local/bin/refresh-firewall.sh /usr/local/bin/setup-claude.sh && \
  echo "node ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/node-firewall && \
  chmod 0440 /etc/sudoers.d/node-firewall

ENV PATH="/home/node/.local/share/mise/shims:/home/node/.local/bin:$PATH"

USER node
ENV SHELL=/bin/zsh

# ------------------------------------------------------------------------------
# mise (tool version manager) -- replaces manual binary downloads
# ------------------------------------------------------------------------------
RUN curl https://mise.run | sh
COPY --chown=node:node mise/config.toml /home/node/.config/mise/config.toml
ENV MISE_YES=1
RUN mise install

# ------------------------------------------------------------------------------
# Claude Code (native installer as node user -> ~/.local/bin/claude)
# ------------------------------------------------------------------------------
ARG CLAUDE_CODE_VERSION=latest
RUN curl -fsSL https://claude.ai/install.sh | bash -s -- ${CLAUDE_CODE_VERSION}

RUN git config --global core.excludesfile ~/.gitignore_global
