#!/usr/bin/env bash
# =============================================================================
# session-boundary.sh - Decide whether to continue, checkpoint, or restart
# =============================================================================

set -euo pipefail

PHASE=""
TURNS=0
VERIFIED=false
PHASE_CHANGE=false
TOPIC_SHIFT=false
QUALITY_DROP=false
TASK_COMPLETE=false
METER_OVER_50=false

usage() {
  cat <<'EOF'
Usage: ./scripts/session-boundary.sh [options]

Options:
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
    --phase)
      PHASE="${2:-}"
      shift 2
      ;;
    --turns)
      TURNS="${2:-0}"
      shift 2
      ;;
    --verified)
      VERIFIED=true
      shift
      ;;
    --phase-change)
      PHASE_CHANGE=true
      shift
      ;;
    --topic-shift)
      TOPIC_SHIFT=true
      shift
      ;;
    --quality-drop)
      QUALITY_DROP=true
      shift
      ;;
    --task-complete)
      TASK_COMPLETE=true
      shift
      ;;
    --meter-over-50)
      METER_OVER_50=true
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    research|plan|implement|review)
      if [[ -z "$PHASE" ]]; then
        PHASE="$1"
      else
        echo "Unknown option: $1" >&2
        usage >&2
        exit 2
      fi
      shift
      ;;
    verified)
      VERIFIED=true
      shift
      ;;
    phase-change)
      PHASE_CHANGE=true
      shift
      ;;
    topic-shift)
      TOPIC_SHIFT=true
      shift
      ;;
    quality-drop)
      QUALITY_DROP=true
      shift
      ;;
    task-complete)
      TASK_COMPLETE=true
      shift
      ;;
    meter-over-50)
      METER_OVER_50=true
      shift
      ;;
    ''|*[!0-9]*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      if [[ "$TURNS" -eq 0 ]]; then
        TURNS="$1"
        shift
      else
        echo "Unknown option: $1" >&2
        usage >&2
        exit 2
      fi
      ;;
  esac
done

DECISION="continue"
WHY="same phase, same task"
NEXT="stay in the current session"

if [[ "$TASK_COMPLETE" == true || "$PHASE_CHANGE" == true || "$TOPIC_SHIFT" == true || "$QUALITY_DROP" == true || "$METER_OVER_50" == true || "$TURNS" -ge 15 ]]; then
  DECISION="checkpoint-and-restart"
  WHY="phase boundary or degraded context"
  NEXT="update session-state.json, checkpoint commit if verified, then open a new session"
elif [[ "$VERIFIED" == true || "$TURNS" -ge 8 ]]; then
  DECISION="checkpoint-now"
  WHY="verified phase or long-enough thread"
  NEXT="update session-state.json now; restart if the next step changes phase"
fi

# Commit signal: always recommend commit after a verified phase or at task boundary
COMMIT_SUGGEST=""
if [[ "$VERIFIED" == true ]]; then
  COMMIT_SUGGEST="commit verified work: bash ./scripts/checkpoint-commit.sh -m 'phase: summary'"
elif [[ "$TASK_COMPLETE" == true ]]; then
  COMMIT_SUGGEST="commit completed task before new session"
fi

echo "Decision: $DECISION"
echo "Phase: ${PHASE:-unspecified}"
echo "Reason: $WHY"
echo "Next: $NEXT"
if [[ -n "$COMMIT_SUGGEST" ]]; then
  echo "Commit:  $COMMIT_SUGGEST"
fi
