#!/usr/bin/env bash
# =============================================================================
# handoff.sh - Build a compact continuation packet for session switches
# =============================================================================

set -euo pipefail

TASK=""
PHASE="unknown"
OUTCOME="continue"
TURNS="0"

usage() {
  cat <<'EOF'
Usage: ./scripts/handoff.sh "task" [--phase name] [--outcome continue|checkpoint|finish|park] [--turns n]

Creates a compact handoff packet:
- goal
- phase
- git state
- current files
- decisions
- risks
- next command
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
    --phase)
      PHASE="${2:-}"
      shift
      ;;
    --outcome)
      OUTCOME="${2:-}"
      shift
      ;;
    --turns)
      TURNS="${2:-}"
      shift
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
  shift
done

case "$OUTCOME" in continue|checkpoint|finish|park) ;; *) echo "ERROR: invalid outcome" >&2; exit 2 ;; esac

if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "ERROR: not inside a git repository." >&2
  exit 1
fi

root="$(git rev-parse --show-toplevel)"
branch="$(git rev-parse --abbrev-ref HEAD)"
status_short="$(git status --short)"
dirty="clean"
if [[ -n "$status_short" ]]; then
  dirty="dirty"
fi

boundary="continue"
if [[ -f "$root/session-boundary.sh" ]]; then
  boundary="$(bash "$root/session-boundary.sh" --phase "$PHASE" --turns "$TURNS" 2>/dev/null | awk -F': ' '/^Decision:/ {print $2}' || true)"
elif [[ -f "$root/scripts/session-boundary.sh" ]]; then
  boundary="$(bash "$root/scripts/session-boundary.sh" --phase "$PHASE" --turns "$TURNS" 2>/dev/null | awk -F': ' '/^Decision:/ {print $2}' || true)"
fi
if [[ -z "$boundary" ]]; then
  boundary="continue"
fi

changed_files="none"
if [[ -n "$status_short" ]]; then
  changed_files="$(printf '%s\n' "$status_short" | sed 's/^...//' | head -20 | awk 'NR == 1 {printf "%s", $0; next} {printf ", %s", $0}')"
fi

next="resume the same phase"
case "$OUTCOME" in
  finish)
    next="/finish-task fixed $TASK"
    ;;
  park)
    next="/finish-task parked $TASK"
    ;;
  checkpoint)
    next="/checkpoint $PHASE $TURNS verified"
    ;;
  continue)
    if [[ "$boundary" =~ restart ]]; then
      next="start a fresh session with this handoff"
    else
      next="continue with the current next slice"
    fi
    ;;
esac

cat <<EOF
Handoff Packet
Task: $TASK
Phase: $PHASE
Outcome: $OUTCOME
Repo: $root
Branch: $branch
Worktree: $dirty
Boundary decision: $boundary
Changed files: $changed_files

Carry forward:
- Goal: $TASK
- Current phase: $PHASE
- Verified so far: fill from the last completed check
- Key decisions: fill only decisions needed for the next session
- Open risks: fill only risks that affect the next command
- Next command: $next

Compression rule:
- Keep only facts needed for the next session.
- Drop debate, stale alternatives, and solved branches.
- Preserve exact file paths and verification commands.
EOF
