#!/usr/bin/env bash
# =============================================================================
# finish-task.sh - Deterministic close-task + checkpoint composite
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -lt 2 ]]; then
  echo "Usage: ./scripts/finish-task.sh OUTCOME \"task\" [close-task options]" >&2
  exit 2
fi

CLOSE_OUTPUT="$(bash "$SCRIPT_DIR/close-task.sh" "$@")"
CHECKPOINT_OUTPUT="$(bash "$SCRIPT_DIR/checkpoint-review.sh" --phase review --verified --task-complete)"

printf '%s\n' "$CLOSE_OUTPUT"
printf '%s\n' "$CHECKPOINT_OUTPUT"
