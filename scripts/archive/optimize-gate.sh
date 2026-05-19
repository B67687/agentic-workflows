#!/usr/bin/env bash
# =============================================================================
# optimize-gate.sh - Decide when and how optimization should happen
# =============================================================================

set -euo pipefail

TASK=""
EVIDENCE="aesthetic"
SCOPE="auto"

usage() {
  cat <<'EOF'
Usage: ./scripts/optimize-gate.sh "optimization task" [options]

Options:
  --evidence observed|predicted|aesthetic
  --scope function|module|system|architecture|auto
EOF
}

if [[ $# -eq 0 ]]; then
  usage >&2
  exit 2
fi

TASK="$1"
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --evidence)
      EVIDENCE="${2:-}"
      shift 2
      ;;
    --scope)
      SCOPE="${2:-}"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$EVIDENCE" in observed|predicted|aesthetic) ;; *) echo "ERROR: invalid evidence" >&2; exit 2 ;; esac
case "$SCOPE" in function|module|system|architecture|auto) ;; *) echo "ERROR: invalid scope" >&2; exit 2 ;; esac

task_lower="$(printf '%s' "$TASK" | tr '[:upper:]' '[:lower:]')"
if [[ "$SCOPE" == "auto" ]]; then
  if [[ "$task_lower" =~ (architecture|system|platform|rewrite|infra) ]]; then
    SCOPE="architecture"
  elif [[ "$task_lower" =~ (pipeline|module|file|subsystem) ]]; then
    SCOPE="module"
  elif [[ "$task_lower" =~ (function|loop|query|method) ]]; then
    SCOPE="function"
  else
    SCOPE="system"
  fi
fi

decision="measure-first"
reason="optimization should usually follow evidence"
smallest_level="the narrowest layer that fixes the actual bottleneck"
proof="before/after verification for the suspected bottleneck"
next="/research $TASK"

if [[ "$EVIDENCE" == "aesthetic" ]]; then
  decision="wait"
  reason="discomfort alone is not enough evidence to spend optimization complexity budget"
  next="gather evidence first"
elif [[ "$EVIDENCE" == "predicted" && "$SCOPE" == "architecture" ]]; then
  decision="architecture-review"
  reason="hard-to-reverse architectural risk deserves an explicit bounded review before building deeper"
  next="/research $TASK"
elif [[ "$EVIDENCE" == "observed" ]]; then
  decision="bounded-optimize"
  reason="the bottleneck is real enough to optimize at the smallest useful layer"
  next="/plan $TASK"
fi

echo "Task: $TASK"
echo "Optimization scope: $SCOPE"
echo "Evidence class: $EVIDENCE"
echo "Decision: $decision"
echo "Reason: $reason"
echo "Smallest level to act: $smallest_level"
echo "Required proof: $proof"
echo "Next command: $next"
