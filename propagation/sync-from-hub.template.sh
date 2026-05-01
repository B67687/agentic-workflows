#!/usr/bin/env bash
# Managed-By: AI-Prompting-Library
# =============================================================================
# sync-from-hub.sh - Refresh hub-owned managed-core files from ai-prompting
# =============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$SCRIPT_DIR"
MODE="apply"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --preview|-p)
      MODE="preview"
      ;;
    --apply|-a)
      MODE="apply"
      ;;
    --help|-h)
      cat <<'EOF'
Usage: ./sync-from-hub.sh [--preview|--apply]

Refreshes only hub-owned managed-core files.
Repo-owned files like session-state, topic-insights, and archive history are left untouched.
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done

HUB_DIR=""
for d in "$TARGET_DIR"/.. "$TARGET_DIR"/../.. "$TARGET_DIR"/../../..; do
  if [[ -d "$d/ai-prompting" ]] && [[ -f "$d/ai-prompting/scripts/propagation-contract.sh" ]]; then
    HUB_DIR="$d/ai-prompting"
    break
  fi
done

if [[ -z "$HUB_DIR" ]]; then
  echo "ERROR: Could not find ai-prompting hub"
  exit 1
fi

if [[ "$MODE" == "apply" ]]; then
  exec bash "$HUB_DIR/scripts/propagate-to-all.sh" --folder "$TARGET_DIR" --managed-only --apply
else
  exec bash "$HUB_DIR/scripts/propagate-to-all.sh" --folder "$TARGET_DIR" --managed-only --preview
fi
