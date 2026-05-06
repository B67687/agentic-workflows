#!/usr/bin/env bash
# =============================================================================
# task-intake.sh - Deterministic task intake with git-aware default routing
# =============================================================================

set -euo pipefail

TASK=""
FETCH=true
SEPARATE_WORK=false
UPSTREAM_FACING=false
SIZE="medium"
CLARITY="mixed"
RISK="medium"
VERIFICATION="normal"
ITERATION_STRATEGY="normal"
ITERATION_REASON="task size looks compatible with one fast cycle"
GOAL_HORIZON="normal"
GOAL_REASON="task looks like a normal near-term execution target"

usage() {
  cat <<'EOF'
Usage: ./scripts/task-intake.sh "task" [options]

Options:
  --size light|medium|heavy
  --clarity clear|mixed|ambiguous
  --risk low|medium|high
  --verification simple|normal|unclear
  --separate-work
  --upstream-facing
  --no-fetch
EOF
}

if [[ $# -eq 0 ]]; then
  usage >&2
  exit 2
fi

TASK="$1"
shift

normalize_task() {
  local text="$1"
  while [[ "$text" =~ ^/[a-z0-9-]+[[:space:]]+(.+)$ ]]; do
    text="${BASH_REMATCH[1]}"
  done
  printf '%s\n' "$text"
}

TASK="$(normalize_task "$TASK")"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --size)
      SIZE="${2:-}"
      shift
      ;;
    --clarity)
      CLARITY="${2:-}"
      shift
      ;;
    --risk)
      RISK="${2:-}"
      shift
      ;;
    --verification)
      VERIFICATION="${2:-}"
      shift
      ;;
    --separate-work)
      SEPARATE_WORK=true
      ;;
    --upstream-facing)
      UPSTREAM_FACING=true
      ;;
    --no-fetch)
      FETCH=false
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

case "$SIZE" in light|medium|heavy) ;; *) echo "ERROR: invalid size" >&2; exit 2 ;; esac
case "$CLARITY" in clear|mixed|ambiguous) ;; *) echo "ERROR: invalid clarity" >&2; exit 2 ;; esac
case "$RISK" in low|medium|high) ;; *) echo "ERROR: invalid risk" >&2; exit 2 ;; esac
case "$VERIFICATION" in simple|normal|unclear) ;; *) echo "ERROR: invalid verification" >&2; exit 2 ;; esac

if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "ERROR: not inside a git repository." >&2
  exit 1
fi

root="$(git rev-parse --show-toplevel)"
branch="$(git rev-parse --abbrev-ref HEAD)"
dirty="clean"
if [[ -n "$(git status --short)" ]]; then
  dirty="dirty"
fi

if [[ "$FETCH" == true ]]; then
  git fetch --all --prune --quiet || true
fi

upstream=""
ahead=0
behind=0
if upstream_ref="$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null)"; then
  upstream="$upstream_ref"
  counts="$(git rev-list --left-right --count HEAD...@{upstream})"
  ahead="${counts%% *}"
  behind="${counts##* }"
fi

task_lower="$(printf '%s' "$TASK" | tr '[:upper:]' '[:lower:]')"
if [[ "$task_lower" =~ (typo|readme|docs|comment|link|rename|small|minor) ]] && [[ "$SIZE" == "medium" ]]; then
  SIZE="light"
fi
if [[ "$task_lower" =~ (architecture|migrate|workflow|system|recreate|multiplayer|benchmark|integrate|refactor) ]] && [[ "$SIZE" == "medium" ]]; then
  SIZE="heavy"
fi
if [[ "$task_lower" =~ (not\ sure|maybe|i\ think|unclear|figure\ out) ]] && [[ "$CLARITY" == "mixed" ]]; then
  CLARITY="ambiguous"
fi
if [[ "$task_lower" =~ (1:1|one\ to\ one|entire|whole|full|complete|everything|all\ at\ once|from\ scratch|recreate|clone|platform|game|system|engine|app) ]]; then
  ITERATION_STRATEGY="slice-first"
  ITERATION_REASON="task likely spans too many moving parts for one safe fast cycle"
fi
if [[ "$SIZE" == "heavy" ]]; then
  ITERATION_STRATEGY="slice-first"
  ITERATION_REASON="heavy tasks should be broken into milestone slices before normal planning"
fi
if [[ "$task_lower" =~ (1:1|one\ to\ one|exactly|recreate|preserve|nostalgia|future|long-term|years|survive|full\ experience) ]]; then
  GOAL_HORIZON="north-star"
  GOAL_REASON="task sounds like a long-horizon target that should be preserved while execution stays slice-sized"
fi

lane="research"
lane_reason="default safe lane for non-trivial work"

if [[ "$ITERATION_STRATEGY" == "slice-first" && "$CLARITY" != "ambiguous" && "$RISK" != "high" ]]; then
  lane="slice-first"
  lane_reason="task should be split into the next executable slice before normal planning"
elif [[ "$CLARITY" == "ambiguous" || "$RISK" == "high" ]]; then
  lane="grill"
  lane_reason="ambiguity or high risk should be challenged first"
elif [[ "$SIZE" == "light" && "$CLARITY" == "clear" && "$RISK" == "low" && "$VERIFICATION" != "unclear" ]]; then
  lane="direct"
  lane_reason="small, clear, low-risk task with known verification"
else
  lane="research"
  lane_reason="task needs structured understanding before edits"
fi

git_lane="current-checkout"
git_reason="current checkout is acceptable"

if [[ "$dirty" == "dirty" && ( "$SEPARATE_WORK" == true || "$SIZE" == "heavy" || "$RISK" == "high" ) ]]; then
  git_lane="worktree"
  git_reason="dirty checkout plus separate or risky work should be isolated"
elif [[ "$SEPARATE_WORK" == true ]]; then
  git_lane="worktree"
  git_reason="task was marked as separate work"
fi

safe_to_edit="yes"
safety_note="repo state looks normal enough for the chosen lane"

if [[ "$behind" -gt 0 ]]; then
  safe_to_edit="caution"
  safety_note="branch is behind upstream; inspect incoming changes before broad edits"
elif [[ "$dirty" == "dirty" && "$git_lane" == "current-checkout" && "$lane" != "direct" ]]; then
  safe_to_edit="caution"
  safety_note="current checkout is already dirty; make sure the next work belongs here"
fi

next_command="/research $TASK"
if [[ "$GOAL_HORIZON" == "north-star" ]]; then
  next_command="/shape-product $TASK"
elif [[ "$lane" == "grill" ]]; then
  next_command="/grill $TASK"
elif [[ "$lane" == "slice-first" ]]; then
  next_command="/slice-task $TASK"
elif [[ "$lane" == "direct" ]]; then
  next_command="direct handling allowed"
fi

if [[ "$git_lane" == "worktree" ]]; then
  next_command="$next_command (prefer /git-worktree branch-name first)"
fi

echo "Task: $TASK"
echo "Repo: $root"
echo "Branch: $branch"
echo "Worktree: $dirty"
if [[ -n "$upstream" ]]; then
  echo "Upstream: $upstream"
  echo "Ahead: $ahead"
  echo "Behind: $behind"
else
  echo "Upstream: none"
fi
echo "Recommended lane: $lane"
echo "Lane reason: $lane_reason"
echo "Goal horizon: $GOAL_HORIZON"
echo "Goal reason: $GOAL_REASON"
echo "Iteration strategy: $ITERATION_STRATEGY"
echo "Iteration reason: $ITERATION_REASON"
echo "Git lane: $git_lane"
echo "Git reason: $git_reason"
echo "Safe to edit now: $safe_to_edit"
echo "Safety note: $safety_note"
echo "Upstream-facing: $UPSTREAM_FACING"
echo "Next command: $next_command"
