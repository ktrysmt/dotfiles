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
  git sudo jq \
  iptables ipset iproute2 dnsutils aggregate cron \
  curl ca-certificates \
  libevent-core-2.1-7t64 libncurses6 libatomic1 \
  && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# tmux (built in separate stage to match host version for socket compatibility)
# ------------------------------------------------------------------------------
COPY --from=tmux-builder /usr/local/bin/tmux /usr/local/bin/tmux

# ------------------------------------------------------------------------------
# User setup (use default ubuntu user, UID/GID 1000)
# ------------------------------------------------------------------------------
RUN mkdir -p /workspace /home/ubuntu/.claude /home/ubuntu/.local/bin && \
  chown ubuntu:ubuntu /workspace /home/ubuntu/.claude && \
  chown -R ubuntu:ubuntu /home/ubuntu/.local

RUN echo "ubuntu ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/ubuntu-firewall && \
  chmod 0440 /etc/sudoers.d/ubuntu-firewall

WORKDIR /workspace

# ------------------------------------------------------------------------------
# Tools: each in its own layer so version bumps only re-pull that layer
# ------------------------------------------------------------------------------
ARG NODE_VERSION=25.8.1
RUN curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz" | \
  tar xz -C /usr/local --strip-components=1 --no-same-owner && \
  rm -rf /usr/local/include/node /usr/local/share/doc /usr/local/share/man \
  /usr/local/share/systemtap /usr/local/lib/node_modules/corepack \
  /usr/local/bin/corepack /usr/local/CHANGELOG.md /usr/local/README.md \
  /usr/local/LICENSE

ARG GH_VERSION=2.88.1
RUN curl -fsSL "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz" | \
  tar xz -C /usr/local --strip-components=1 --no-same-owner

RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh

# ------------------------------------------------------------------------------
# Local files: COPY layers last (before USER) to avoid busting tool layer cache
# ------------------------------------------------------------------------------
COPY --chmod=755 .devcontainer/init-firewall.sh .devcontainer/refresh-firewall.sh .devcontainer/setup-claude.sh /usr/local/bin/
COPY --chown=ubuntu:ubuntu claude/ /home/ubuntu/claude/
COPY --chown=ubuntu:ubuntu .gitignore_global /home/ubuntu/.gitignore_global

ENV PATH="/home/ubuntu/.local/bin:$PATH"

USER ubuntu
ENV SHELL=/bin/bash

# ------------------------------------------------------------------------------
# Claude Code (native installer as ubuntu user -> ~/.local/bin/claude)
# ------------------------------------------------------------------------------
ARG CLAUDE_CODE_VERSION=latest
RUN curl -fsSL https://claude.ai/install.sh | bash -s -- ${CLAUDE_CODE_VERSION} && \
  git config --global core.excludesfile ~/.gitignore_global && \
  echo 'alias l="ls -lha"' >> ~/.bashrc && \
  echo 'alias cl="claude --dangerously-skip-permissions"' >> ~/.bashrc
