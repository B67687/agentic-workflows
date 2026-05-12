# Agent sandbox container — safe YOLO-mode environment
# Based on Anthropic's reference devcontainer pattern
# https://github.com/anthropics/claude-code/tree/main/.devcontainer
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    git \
    jq \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    ca-certificates \
    iptables \
    iproute2 \
    netbase \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash agent
WORKDIR /workspace

# Copy firewall init script
COPY init-firewall.sh /usr/local/bin/init-firewall.sh
RUN chmod +x /usr/local/bin/init-firewall.sh

# Default: no network (override at runtime for specific hosts)
# The init script can be called at container start to allowlist specific hosts
ENTRYPOINT ["/usr/local/bin/init-firewall.sh"]
CMD ["sleep", "infinity"]
