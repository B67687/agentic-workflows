#!/usr/bin/env bash
# =============================================================================
# propagate.sh --- Unified propagation entry point
#
# Orchestrates sync operations from a single entry point:
#
#   bash ./scripts/propagate.sh               # Show sync status (default)
#   bash ./scripts/propagate.sh status         # Check propagation status
#   bash ./scripts/propagate.sh sync           # Sync commands/ -> .opencode/ + .pi/
#
# Replaces manual invocation of:
#   sync-commands.sh, check-sync-status.sh
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CMD="${1:-status}"
shift || true

usage() {
  cat <<'USAGE'
Usage: ./scripts/propagate.sh <command> [options]

Commands:
  status                   Check propagation status (default)
  sync                     Sync commands/ to .opencode/commands/ and .pi/prompts/

Options:
  -h, --help               Show this help

Examples:
  bash ./scripts/propagate.sh            # check status
  bash ./scripts/propagate.sh sync       # sync commands to local harnesses
USAGE
}

case "$CMD" in
  status)
    exec bash "$SCRIPT_DIR/check-sync-status.sh" "$@"
    ;;

  sync)
    echo "=== Sync: commands/ -> harness mirrors ==="
    bash "$SCRIPT_DIR/sync-commands.sh" "$@"
    ;;

  help|--help|-h)
    usage
    ;;

  *)
    echo "Unknown command: $CMD"
    usage
    exit 2
    ;;
esac
