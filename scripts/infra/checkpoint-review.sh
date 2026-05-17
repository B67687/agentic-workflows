#!/usr/bin/env bash
# =============================================================================
# checkpoint-review.sh - Deterministic checkpoint and restart review
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BOUNDARY_ARGS=()

usage() {
  cat <<'EOF'
Usage: ./scripts/checkpoint-review.sh [options]

Pass-through options:
  --phase research|plan|implement|review
  --turns N
  --verified
  --phase-change
  --topic-shift
  --quality-drop
  --task-complete
  --meter-over-50
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --phase|--turns)
      if [[ $# -lt 2 ]]; then
        echo "ERROR: missing value for $1" >&2
        usage >&2
        exit 2
      fi
      BOUNDARY_ARGS+=("$1" "$2")
      shift 2
      ;;
    --verified|--phase-change|--topic-shift|--quality-drop|--task-complete|--meter-over-50)
      BOUNDARY_ARGS+=("$1")
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    research|plan|implement|review|verified|phase-change|topic-shift|quality-drop|task-complete|meter-over-50)
      BOUNDARY_ARGS+=("$1")
      shift
      ;;
    *)
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        BOUNDARY_ARGS+=("$1")
        shift
      else
        echo "Unknown option: $1" >&2
        usage >&2
        exit 2
      fi
      ;;
  esac
done

if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "ERROR: not inside a git repository." >&2
  exit 1
fi

BOUNDARY_OUTPUT="$(bash "$SCRIPT_DIR/session-boundary.sh" "${BOUNDARY_ARGS[@]}")"
STATUS_OUTPUT="$(git status --short)"
STAGED_STAT="$(git diff --cached --stat)"
MERGE_CONFLICTS="$(git diff --name-only --diff-filter=U)"

has_flag() {
  local flag="$1"
  local arg
  for arg in "${BOUNDARY_ARGS[@]}"; do
    if [[ "$arg" == "$flag" ]]; then
      return 0
    fi
  done
  return 1
}

CHECKPOINT_READY="yes"
CHECKPOINT_REASON="verified phase with a coherent diff is ready for a checkpoint commit"

if ! has_flag "--verified" && ! has_flag "verified"; then
  CHECKPOINT_READY="no"
  CHECKPOINT_REASON="phase is not marked verified yet"
elif [[ -n "$MERGE_CONFLICTS" ]]; then
  CHECKPOINT_READY="no"
  CHECKPOINT_REASON="merge conflicts must be resolved before any checkpoint commit"
elif [[ -z "$STATUS_OUTPUT" ]]; then
  CHECKPOINT_READY="no"
  CHECKPOINT_REASON="working tree is already clean"
fi

printf '%s\n' "$BOUNDARY_OUTPUT"
if [[ -n "$STATUS_OUTPUT" ]]; then
  echo "Git status: dirty"
else
  echo "Git status: clean"
fi
echo "Checkpoint commit ready: $CHECKPOINT_READY"
echo "Checkpoint reason: $CHECKPOINT_REASON"
if [[ -n "$STAGED_STAT" ]]; then
  echo "Staged diff summary:"
  printf '%s\n' "$STAGED_STAT"
fi
