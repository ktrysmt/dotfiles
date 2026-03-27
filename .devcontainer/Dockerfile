FROM ubuntu:24.04

ARG TZ=Asia/Tokyo
ENV TZ="$TZ"

# ------------------------------------------------------------------------------
# System packages
# ------------------------------------------------------------------------------
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  git sudo jq tzdata \
  iproute2 bpftrace \
  curl ca-certificates \
  libatomic1 \
  && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# User setup (use default ubuntu user, UID/GID 1000)
# ------------------------------------------------------------------------------
RUN mkdir -p /workspace /home/ubuntu/.claude /home/ubuntu/.local/bin /home/ubuntu/dotfiles && \
  chown ubuntu:ubuntu /workspace /home/ubuntu/.claude /home/ubuntu/dotfiles && \
  chown -R ubuntu:ubuntu /home/ubuntu/.local && \
  echo "ubuntu ALL=(root) NOPASSWD: /usr/local/bin/trace-network.sh" > /etc/sudoers.d/ubuntu-trace && \
  chmod 0440 /etc/sudoers.d/ubuntu-trace

WORKDIR /workspace

# ------------------------------------------------------------------------------
# Tools: each in its own layer so version bumps only re-pull that layer
# ------------------------------------------------------------------------------
ARG TARGETARCH

ARG TMUX_VERSION=3.6a
RUN TMUX_ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64" || echo "x86_64") && \
  curl -fsSL "https://github.com/tmux/tmux-builds/releases/download/v${TMUX_VERSION}/tmux-${TMUX_VERSION}-linux-${TMUX_ARCH}.tar.gz" | \
  tar xz -C /usr/local/bin --no-same-owner

ARG NODE_VERSION=25.8.1
RUN NODE_ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64" || echo "x64") && \
  curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.gz" | \
  tar xz -C /usr/local --strip-components=1 --no-same-owner && \
  rm -rf /usr/local/include/node /usr/local/share/doc /usr/local/share/man \
  /usr/local/share/systemtap /usr/local/lib/node_modules/corepack \
  /usr/local/bin/corepack /usr/local/CHANGELOG.md /usr/local/README.md \
  /usr/local/LICENSE

ARG GH_VERSION=2.88.1
RUN GH_ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64" || echo "amd64") && \
  curl -fsSL "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${GH_ARCH}.tar.gz" | \
  tar xz -C /usr/local --strip-components=1 --no-same-owner

RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh

ENV PATH="/home/ubuntu/.local/bin:$PATH"

USER ubuntu
ENV SHELL=/bin/bash

# ------------------------------------------------------------------------------
# Python (managed by uv)
# ------------------------------------------------------------------------------
ARG PYTHON_VERSION=3.13
RUN uv python install "$PYTHON_VERSION" && \
  uv python pin --global "$PYTHON_VERSION"

# ------------------------------------------------------------------------------
# Claude Code (native installer as ubuntu user -> ~/.local/bin/claude)
# ------------------------------------------------------------------------------
ARG CLAUDE_CODE_VERSION=latest
RUN curl -fsSL https://claude.ai/install.sh | bash -s -- ${CLAUDE_CODE_VERSION} && \
  git config --global core.excludesfile ~/dotfiles/.gitignore_global && \
  echo 'alias l="ls -lha"' >> ~/.bashrc && \
  echo 'alias cl="claude --dangerously-skip-permissions"' >> ~/.bashrc

# ------------------------------------------------------------------------------
# Local files & dotfiles (changes most frequently, avoids busting tool caches)
# ------------------------------------------------------------------------------
COPY --chmod=755 .devcontainer/trace-network.sh .devcontainer/setup-claude.sh /usr/local/bin/
COPY --chown=ubuntu:ubuntu claude/ /home/ubuntu/dotfiles/claude/
COPY --chown=ubuntu:ubuntu .gitignore_global /home/ubuntu/dotfiles/.gitignore_global
