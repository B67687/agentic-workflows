#!/usr/bin/env bash
# =============================================================================
# propagate.sh --- Unified propagation entry point
#
# Orchestrates all sync and propagation operations from a single entry point:
#
#   bash ./scripts/propagate.sh               # Show sync status (default)
#   bash ./scripts/propagate.sh status         # Check propagation status
#   bash ./scripts/propagate.sh sync           # Sync commands/ -> .opencode/ + .pi/
#   bash ./scripts/propagate.sh propagate      # Preview propagation to topic folders
#   bash ./scripts/propagate.sh propagate --apply  # Apply propagation
#   bash ./scripts/propagate.sh all            # Sync + propagate (preview)
#   bash ./scripts/propagate.sh all --apply    # Full sync + propagate
#
# Replaces manual invocation of:
#   sync-commands.sh, propagate-to-all.sh, check-sync-status.sh
#
# These individual scripts are preserved for direct use. propagate.sh is the
# recommended entry point for all sync and propagation operations.
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
  propagate [--apply]      Propagate templates to topic folders (preview unless --apply)
  all [--apply]            Run sync + propagate (--apply applies propagation)

Options:
  --apply                  Actually apply propagation changes (preview without)
  -h, --help               Show this help

Examples:
  bash ./scripts/propagate.sh            # check status
  bash ./scripts/propagate.sh sync       # sync commands to local harnesses
  bash ./scripts/propagate.sh propagate  # preview propagation
  bash ./scripts/propagate.sh all --apply  # full pipeline
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

  propagate)
    echo "=== Propagate: templates -> topic folders ==="
    bash "$SCRIPT_DIR/propagate-to-all.sh" "$@"
    ;;

  all)
    echo "=== Full Propagation Pipeline ==="
    echo ""
    bash "$SCRIPT_DIR/sync-commands.sh" "$@"
    echo ""
    bash "$SCRIPT_DIR/propagate-to-all.sh" "$@"
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
