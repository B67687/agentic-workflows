#!/bin/bash
# =============================================================================
# agent-sandbox.sh — Run agent operations in an isolated environment
#
# Two modes:
#   docker  — requires Docker, uses .devcontainer/Dockerfile (strongest isolation)
#   bwrap   — uses bubblewrap (bwrap), works now on WSL2 (moderate isolation)
#
# The sandbox restricts:
#   - Network: only allowlisted hosts (prevents exfiltration)
#   - Filesystem: read-only system, writable only in /workspace
#   - Capabilities: drops all unnecessary privileges
#
# Usage:
#   bash ./scripts/agent-sandbox.sh docker <command>
#   bash ./scripts/agent-sandbox.sh bwrap  <command>
#
# Examples:
#   bash ./scripts/agent-sandbox.sh bwrap "bash ./scripts/search-index.sh 'query'"
#   bash ./scripts/agent-sandbox.sh bwrap "python3 -c 'print(1+1)'"
# =============================================================================
set -euo pipefail

MODE="${1:-help}"
shift 1 || true
CMD="${*:-bash}"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

case "$MODE" in
  docker)
    # Docker mode — requires docker installed
    if ! command -v docker &>/dev/null; then
      echo "Docker not found. Install Docker for WSL2, or use 'bwrap' mode."
      echo "  https://docs.docker.com/engine/install/ubuntu/"
      exit 1
    fi

    IMAGE_TAG="agent-sandbox:latest"

    # Build image if needed
    if ! docker image inspect "$IMAGE_TAG" &>/dev/null; then
      echo "[sandbox] Building Docker image..."
      docker build -t "$IMAGE_TAG" "$REPO_ROOT/.devcontainer" >/dev/null
    fi

    echo "[sandbox] Running in Docker container..."
    exec docker run --rm -it \
      --cap-drop=ALL \
      --cap-add=NET_ADMIN \
      --cap-add=NET_RAW \
      -v "$REPO_ROOT:/workspace:ro" \
      -w /workspace \
      "$IMAGE_TAG" \
      bash -c "init-firewall.sh && exec $CMD"
    ;;

  bwrap)
    # Bubblewrap mode — uses Linux namespaces
    if ! command -v bwrap &>/dev/null; then
      echo "bubblewrap (bwrap) not found. Install it:"
      echo "  sudo apt-get install bubblewrap"
      echo "Or use Docker mode if you have Docker."
      exit 1
    fi

    echo "[sandbox] Running in bubblewrap sandbox..."
    echo "[sandbox] Network: restricted (loopback + DNS only)"
    echo "[sandbox] Filesystem: read-only system libraries, writable /workspace"

    exec bwrap \
      --tmpfs / \
      --proc /proc \
      --dev /dev \
      --ro-bind /usr /usr \
      --ro-bind /lib /lib \
      --ro-bind /lib64 /lib64 \
      --ro-bind /bin /bin \
      --ro-bind /sbin /sbin \
      --ro-bind /etc /etc \
      --bind "$REPO_ROOT" /workspace \
      --tmpfs /tmp \
      --tmpfs /var \
      --tmpfs /run \
      --chdir /workspace \
      --unshare-net \
      --unshare-ipc \
      --unshare-pid \
      --unshare-uts \
      --die-with-parent \
      --setenv HOME /tmp \
      --setenv USER agent \
      --setenv PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
      bash -c "$CMD"
    ;;

  help|--help|-h)
    echo "Usage: bash ./scripts/agent-sandbox.sh <mode> [command]"
    echo ""
    echo "Modes:"
    echo "  docker   Docker container (strong isolation, requires Docker)"
    echo "  bwrap    Bubblewrap namespaces (moderate, works on WSL2)"
    echo ""
    echo "If no command given, starts an interactive shell."
    echo ""
    echo "Examples:"
    echo "  bash ./scripts/agent-sandbox.sh bwrap"
    echo "  bash ./scripts/agent-sandbox.sh bwrap 'python3 scripts/search-index.sh query'"
    ;;
esac
