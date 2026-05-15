#!/usr/bin/env bash
# =============================================================================
# task-decompose.sh - Decompose plan artifacts into structured task graph
#
# Reads research notes and plan artifacts, generates structured tasks.md
# with task IDs, parallel markers [P], file paths, verification targets,
# dependency ordering, and constitution gate references.
#
# Usage: ./scripts/task-decompose.sh "milestone" [options]
#   --from <dir>     Read plan artifacts from directory (default: research/)
#   --output <file>  Write tasks.md to file
#   --story <name>   User story name (repeatable)
#   --check-gates    Add constitution gate references per task
#   --help, -h       Show this help
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$REPO_ROOT/.runtime"
DATE="$(date +%Y-%m-%d)"

FROM_DIR="$REPO_ROOT/research"
OUTPUT_FILE=""
USER_STORIES=()
CHECK_GATES=false

usage() {
  cat <<'USAGE'
Usage: ./scripts/task-decompose.sh "milestone description" [options]

Decompose plan into structured task graph with parallel markers.

Options:
  --from <dir>       Research/plan artifacts directory (default: research/)
  --output <file>    Write tasks.md to file (default: stdout)
  --story <name>     User story (repeatable for multiple stories)
  --check-gates      Add constitution gate refs per task
  --help, -h         Show this

Output format:
  Story N with tasks T1-T4, [P] parallel markers, dependency order,
  file paths, verification targets, constitution gate references.

Examples:
  bash scripts/task-decompose.sh "Build auth" --story "User login"
  bash scripts/task-decompose.sh "Search" --output .runtime/tasks.md
USAGE
}

# Parse args
MILESTONE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --from) FROM_DIR="${2:-}"; shift 2 ;;
    --output) OUTPUT_FILE="${2:-}"; shift 2 ;;
    --story) USER_STORIES+=("${2:-}"); shift 2 ;;
    --check-gates) CHECK_GATES=true; shift ;;
    --help|-h) usage; exit 0 ;;
    -*)
      if [[ -z "$MILESTONE" ]]; then
        MILESTONE="$1"
      else
        echo "Unknown: $1" >&2; exit 2
      fi
      shift ;;
    *)
      if [[ -z "$MILESTONE" ]]; then MILESTONE="$1"; else echo "Unexpected: $1" >&2; exit 2; fi
      shift ;;
  esac
done

[[ -z "$MILESTONE" ]] && { echo "ERROR: milestone required" >&2; usage >&2; exit 2; }

# Generate output
{
  echo "# Task Decomposition"
  echo ""
  echo "**Milestone**: $MILESTONE"
  echo "**Generated**: $DATE"
  [[ ${#USER_STORIES[@]} -gt 0 ]] && echo "**Stories**: ${USER_STORIES[*]}"
  echo ""
  echo "---"
  echo ""

  [[ ${#USER_STORIES[@]} -eq 0 ]] && USER_STORIES=("$MILESTONE")

  story_num=0
  task_num=0
  for story in "${USER_STORIES[@]}"; do
    story_num=$((story_num + 1))
    echo "## Story $story_num: $story"
    echo ""

    # Task 1: Foundation
    task_num=$((task_num + 1))
    echo "- [ ] **T$task_num**: Set up $story foundation"
    echo "  - Files: (from plan)"
    echo "  - Verify: (build/test command)"
    echo "  - Depends: —"
    echo "  - Notes: Scaffolding, config, project structure"
    [[ "$CHECK_GATES" == true ]] && echo "  - Constitution: Art.V (Comprehension), Art.VIII (Phase Order)"
    echo ""

    # Task 2: Core logic (parallel with tests)
    task_num=$((task_num + 1))
    echo "- [ ] [P] **T$task_num**: Implement $story core logic"
    echo "  - Files: (from plan)"
    echo "  - Verify: (unit test for core behavior)"
    echo "  - Depends: T$((task_num - 1))"
    echo "  - Notes: Primary implementation, business rules"
    [[ "$CHECK_GATES" == true ]] && echo "  - Constitution: Art.II (Verification), Art.IV (CATFISH)"
    echo ""

    # Task 3: Tests (parallel with core)
    task_num=$((task_num + 1))
    echo "- [ ] [P] **T$task_num**: Write tests for $story"
    echo "  - Files: (from plan)"
    echo "  - Verify: all tests pass"
    echo "  - Depends: T$((task_num - 2))"
    echo "  - Notes: Test-first — write before implementation"
    [[ "$CHECK_GATES" == true ]] && echo "  - Constitution: Art.II (Verification), Art.III (Checkpoint)"
    echo ""

    # Task 4: Integration
    task_num=$((task_num + 1))
    echo "- [ ] **T$task_num**: Wire $story into system"
    echo "  - Files: (from plan)"
    echo "  - Verify: end-to-end flow works"
    echo "  - Depends: T$((task_num - 2)), T$((task_num - 1))"
    echo "  - Notes: API wiring, integration points, data flow"
    [[ "$CHECK_GATES" == true ]] && echo "  - Constitution: Art.IX (Recognition)"
    echo ""

    # Checkpoint
    echo "### ✓ Checkpoint $story_num"
    echo "- Verify $story works independently"
    echo "- Run: (relevant test command)"
    echo "- Commit checkpoint before next story"
    echo ""
  done

  echo "---"
  echo "**Total**: $task_num tasks across ${#USER_STORIES[@]} story(s)"
  echo ""
  echo "### Legend"
  echo "- \`[P]\` — Parallel task (no dependency on sibling)"
  echo "- \`T<ID>\` — Task identifier for dep references"
  echo "- \`Depends on\` — Tasks that must complete first"
  echo "- \`Constitution\` — Articles triggered by this task"
  echo ""
  echo "### Next Steps"
  echo "1. Fill in file paths from the plan"
  echo "2. Replace (from plan) with specific verification commands"
  echo "3. Add/remove tasks based on actual scope"
  echo "4. Run phase gate: bash scripts/phase-gate.sh implement --constitution"
  echo "5. Each task: comprehension evidence, implement, verify, commit"

} > /tmp/task-decompose-output.$$

if [[ -n "$OUTPUT_FILE" ]]; then
  cat /tmp/task-decompose-output.$$ > "$OUTPUT_FILE"
  rm /tmp/task-decompose-output.$$
  echo "Tasks written to $OUTPUT_FILE"
  echo "  $(grep -c '^- \[ \]' "$OUTPUT_FILE" || true) tasks across ${#USER_STORIES[@]} story(s)"
else
  cat /tmp/task-decompose-output.$$
  rm /tmp/task-decompose-output.$$
fi
