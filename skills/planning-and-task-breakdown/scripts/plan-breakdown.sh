#!/usr/bin/env bash
# =============================================================================
# plan-breakdown.sh --- Companion script for Planning and Task Breakdown
#
# Generates ordered task breakdowns with dependencies and acceptance criteria.
# Follows the skill's Step 2 (Dependency Graph) and Step 3 (Task Decomposition).
#
# Usage:
#   bash ./scripts/plan-breakdown.sh template
#     Output a blank task breakdown template.
#
#   bash ./scripts/plan-breakdown.sh size <lines-of-code>
#     Sizing guidance based on change scope.
#
#   bash ./scripts/plan-breakdown.sh decompose "<description>"
#     Generate a task breakdown from a high-level description.
#     Example: bash ./scripts/plan-breakdown.sh decompose \
#       "Add user authentication with OAuth2 and session management"
# =============================================================================

set -euo pipefail

MODE="${1:-template}"

case "$MODE" in
  template)
    cat << "TEMPLATE"
# Task Breakdown

## Goal
<!-- What are we building? One paragraph. -->

## Dependencies
<!-- What must exist before this work starts? -->
- [ ] Prerequisite 1
- [ ] Prerequisite 2

## Tasks

### Task 1: <short name>
- **File(s):** <paths>
- **Acceptance criteria:**
  - [ ] Criterion 1
  - [ ] Criterion 2
- **Estimated size:** <small/medium/large>
- **Depends on:** <task IDs>
- **Verification:** <how to test>

### Task 2: <short name>
- **File(s):** <paths>
- **Acceptance criteria:**
  - [ ] Criterion 1
  - [ ] Criterion 2
- **Estimated size:** <small/medium/large>
- **Depends on:** <task IDs>
- **Verification:** <how to test>

## Ordering
<!-- Execution order based on dependency graph -->
1. Task 1 (no deps --- start here)
2. Task 2 (depends on Task 1)
3. Task 3 (depends on Task 1, Task 2)

## Risks
- <risk 1>
- <risk 2>
TEMPLATE
    ;;

  size)
    LINES="${2:-}"
    if [ -z "$LINES" ]; then
      echo "Usage: $0 size <lines-of-code>" >&2
      exit 1
    fi
    
    echo "=== Sizing Guidance ==="
    echo ""
    
    if [ "$LINES" -le 100 ]; then
      echo "  Size: SMALL (${LINES} lines)"
      echo "  Reviewable in one sitting."
      echo "  Recommendation: Single task."
    elif [ "$LINES" -le 300 ]; then
      echo "  Size: MEDIUM (${LINES} lines)"
      echo "  Acceptable if focused on one logical change."
      echo "  Recommendation: 1-2 tasks."
    elif [ "$LINES" -le 1000 ]; then
      echo "  Size: LARGE (${LINES} lines)"
      echo "  Too large for a single review. Must split."
      echo "  Recommendation: 3-5 tasks, each with independent review."
      echo "  Split strategies:"
      echo "    -> Stack (sequential deps)"
      echo "    -> By file group (per-module)"
      echo "    -> Vertical (thin slices through the stack)"
    else
      echo "  Size: VERY LARGE (${LINES} lines)"
      echo "  Must be decomposed before work begins."
      echo "  Recommendation: 5+ tasks, consider a milestone breakdown."
    fi
    echo ""
    echo "  Verification: $(python3 -c "
lines = $LINES
if lines <= 100: print('Code review + tests')
elif lines <= 300: print('Code review + tests + integration test')
elif lines <= 1000: print('Split into tasks first, then per-task review')
else: print('Milestone-level review required')
")"
    ;;

  decompose)
    DESC="${2:-}"
    if [ -z "$DESC" ]; then
      echo "Usage: $0 decompose \"<description>\"" >&2
      echo "Example: $0 decompose \"Add OAuth2 login with Google\"" >&2
      exit 1
    fi
    
    echo "# Task Breakdown"
    echo ""
    echo "## Goal"
    echo "${DESC}"
    echo ""
    echo "## Suggested Tasks"
    echo ""
    echo "Based on the description, here is a structured breakdown."
    echo "Fill in file paths and details specific to your project."
    echo ""
    echo "### Task 1: Define data structures and contracts"
    echo "- **Files:** <models, types, interfaces>"
    echo "- **Acceptance criteria:**"
    echo "  - [ ] Data structures defined"
    echo "  - [ ] Types/interfaces exported"
    echo "  - [ ] No logic yet --- just contracts"
    echo "- **Size:** small"
    echo "- **Depends on:** (none)"
    echo ""
    echo "### Task 2: Implement core logic"
    echo "- **Files:** <core logic files>"
    echo "- **Acceptance criteria:**"
    echo "  - [ ] Core algorithm/logic implements contracts"
    echo "  - [ ] Edge cases handled"
    echo "  - [ ] Error paths covered"
    echo "- **Size:** medium"
    echo "- **Depends on:** Task 1"
    echo ""
    echo "### Task 3: Wire up integration points"
    echo "- **Files:** <API routes, DB calls, external calls>"
    echo "- **Acceptance criteria:**"
    echo "  - [ ] Integration with existing systems"
    echo "  - [ ] Configuration driven"
    echo "- **Size:** medium"
    echo "- **Depends on:** Task 2"
    echo ""
    echo "### Task 4: Add tests"
    echo "- **Files:** <test files>"
    echo "- **Acceptance criteria:**"
    echo "  - [ ] Unit tests for core logic"
    echo "  - [ ] Integration tests for boundaries"
    echo "  - [ ] Edge case coverage"
    echo "- **Size:** medium"
    echo "- **Depends on:** Task 2, Task 3"
    echo ""
    echo "### Task 5: Documentation and cleanup"
    echo "- **Files:** <docs, comments>"
    echo "- **Acceptance criteria:**"
    echo "  - [ ] README/docs updated"
    echo "  - [ ] Dead code removed"
    echo "  - [ ] Final review pass"
    echo "- **Size:** small"
    echo "- **Depends on:** Task 4"
    echo ""
    echo "---"
    echo "Generated from: ${DESC}"
    echo "Adjust task count and scope based on actual project structure."
    ;;

  *)
    echo "Usage: $0 {template|size|decompose}"
    echo ""
    echo "  template                 --- Output blank task breakdown template"
    echo "  size <lines>             --- Sizing guidance for change scope"
    echo "  decompose \"<desc>\"       --- Generate task breakdown from description"
    exit 1
    ;;
esac
