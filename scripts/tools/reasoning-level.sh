#!/bin/bash
# =============================================================================
# reasoning-level.sh --- DeepSeek V4 reasoning effort classifier
#
# Determines the appropriate reasoning level for a task description.
# Maps task types to: non-think, high, max
#
# Usage:
#   bash ./scripts/reasoning-level.sh "<task description>"
#   bash ./scripts/reasoning-level.sh --explain "<task description>"
#
# Output:
#   Prints one of: non-think, high, max
#   With --explain: level + reasoning
#
# Source: Benchmark-informed heuristics based on DeepSeek V4 Flash testing.
#   Max (+20% BrowseComp, +5% SWE-bench) for agentic/refactor tasks.
#   High (within noise on knowledge) for planning/routine.
#   Non-think for trivial operations.
# =============================================================================
set -euo pipefail

TASK="${1:-}"
EXPLAIN=false

if [ "$1" = "--explain" ]; then
  EXPLAIN=true
  TASK="${2:-}"
fi

if [ -z "$TASK" ]; then
  echo "Usage: bash ./scripts/reasoning-level.sh [--explain] \"<task description>\""
  echo ""
  echo "Returns one of: non-think, high, max"
  echo ""
  echo "Heuristics (based on DeepSeek V4 Flash benchmarks):"
  echo "  non-think : commits, tests, status, git ops, trivial edits"
  echo "  high      : planning, architecture analysis, research, documentation, simple pattern extraction"
  echo "  max       : complex pattern extraction, refactoring, multi-file changes, hard bugs,"
  echo "              agentic coding, architectural restructuring"
  exit 1
fi

TASK_LOWER=$(echo "$TASK" | tr '[:upper:]' '[:lower:]')

# ─── non-think triggers ─────────────────────────────────────────
# These tasks need NO reasoning. Pure execution.
NON_THINK_PATTERNS=(
  "git commit" "git add" "git push" "commit" "run tests"
  "run test" "npm test" "pytest" "status check" "git status"
  "merge" "rebase" "checkout" "simple edit" "typo"
  "format" "lint fix" "remove file" "delete file"
  "checkpoint" "smoke test" "test-smoke"
)

# ─── max triggers ───────────────────────────────────────────────
# These need MAX reasoning. They're the +20% BrowseComp / +5% SWE-bench tasks.
MAX_PATTERNS=(
  "refactor" "restructure" "architect" "redesign" "rewrite"
  "complex" "multi-file" "cross-cutting" "deep"
  "pattern extraction" "extract pattern" "source audit"
  "research source" "investigate" "debug" "root cause"
  "macro-to-micro" "architectural" "hard bug" "regression"
  "agentic" "autonomous" "orchestrat" "pipeline redesign"
  "knowledge graph" "schema redesign" "compile"
  "full rewrite" "migration" "deprecat"
)

check_match() {
  local patterns=("$@")
  local last_idx=$(( ${#patterns[@]} - 1 ))
  unset 'patterns[last_idx]'
  for pattern in "${patterns[@]}"; do
    if echo "$TASK_LOWER" | grep -q "$pattern"; then
      return 0
    fi
  done
  return 1
}

if check_match "${MAX_PATTERNS[@]}"; then
  if [ "$EXPLAIN" = true ]; then
    echo "max --- complex/agentic task detected"
    echo "  Max gives +5-20% on complex coding and agentic browsing tasks."
    echo "  Worth the extra reasoning tokens for this type of work."
  else
    echo "max"
  fi
  exit 0
fi

if check_match "${NON_THINK_PATTERNS[@]}"; then
  if [ "$EXPLAIN" = true ]; then
    echo "non-think --- trivial/operational task detected"
    echo "  No reasoning needed. Use non-think to save tokens."
  else
    echo "non-think"
  fi
  exit 0
fi

# Default: high --- covers planning, research, documentation, analysis
if [ "$EXPLAIN" = true ]; then
  echo "high --- routine or knowledge task (default)"
  echo "  High is within 1-2 points of Max on most knowledge and planning tasks."
  echo "  Significantly cheaper than Max. Default unless task is complex/agentic."
else
  echo "high"
fi
