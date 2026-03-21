# ==============================================================================
# Builder: tmux (separate stage to keep build deps out of final image)
# ==============================================================================
FROM ubuntu:24.04 AS tmux-builder

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential libevent-dev libncurses-dev bison pkg-config wget ca-certificates \
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
FROM ubuntu:24.04

ARG TZ=Asia/Tokyo
ENV TZ="$TZ"

# ------------------------------------------------------------------------------
# System packages
# ------------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
  less git procps sudo zsh man-db unzip gnupg2 \
  iptables ipset iproute2 dnsutils aggregate jq cron \
  curl wget tree watch ca-certificates \
  build-essential \
  libevent-core-2.1-7t64 libncurses6 \
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
# User setup (use default ubuntu user, UID/GID 1000)
# ------------------------------------------------------------------------------
RUN chsh -s /bin/zsh ubuntu

# Create workspace directory (/.claude is volume-mounted at runtime)
RUN mkdir -p /workspace && chown ubuntu:ubuntu /workspace
RUN mkdir -p /home/ubuntu/.claude && chown ubuntu:ubuntu /home/ubuntu/.claude
RUN mkdir -p /home/ubuntu/.local/bin && chown ubuntu:ubuntu -R /home/ubuntu/.local

# Dotfiles baked into image
COPY --chown=ubuntu:ubuntu claude/ /home/ubuntu/claude/
COPY --chown=ubuntu:ubuntu .gitignore_global /home/ubuntu/.gitignore_global

WORKDIR /workspace

# ------------------------------------------------------------------------------
# Firewall & setup scripts
# ------------------------------------------------------------------------------
COPY .devcontainer/init-firewall.sh .devcontainer/refresh-firewall.sh .devcontainer/setup-claude.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-firewall.sh /usr/local/bin/refresh-firewall.sh /usr/local/bin/setup-claude.sh && \
  echo "ubuntu ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/ubuntu-firewall && \
  chmod 0440 /etc/sudoers.d/ubuntu-firewall

ENV PATH="/home/ubuntu/.local/share/mise/shims:/home/ubuntu/.local/bin:$PATH"

USER ubuntu
ENV SHELL=/bin/zsh

# ------------------------------------------------------------------------------
# mise (tool version manager) -- replaces manual binary downloads
# ------------------------------------------------------------------------------
RUN curl https://mise.run | sh
COPY --chown=ubuntu:ubuntu .devcontainer/mise.toml /home/ubuntu/.config/mise/config.toml
ENV MISE_YES=1
RUN mise install && mise cache clear && rm -rf /home/ubuntu/.local/share/mise/downloads

# ------------------------------------------------------------------------------
# Claude Code (native installer as ubuntu user -> ~/.local/bin/claude)
# ------------------------------------------------------------------------------
ARG CLAUDE_CODE_VERSION=latest
RUN curl -fsSL https://claude.ai/install.sh | bash -s -- ${CLAUDE_CODE_VERSION}

RUN git config --global core.excludesfile ~/.gitignore_global && \
  echo 'alias l="eza -lha"' >> ~/.zshrc
