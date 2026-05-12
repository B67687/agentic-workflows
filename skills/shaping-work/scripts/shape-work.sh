#!/usr/bin/env bash
# Companion script for shaping-work skill
# Shape rough ideas into clear, actionable work definitions
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [args]

Commands:
  shape <title> <desc>    Shape a work item from rough idea
  bug <title> <desc>      Shape a bug fix work item
  improve <title> <desc>  Shape an improvement/tech debt item
  ac <criterion>          Check acceptance criterion quality
  template <type>         Output template (feature, bug, improvement)
  help                    Show this help
EOF
}

cmd="${1:-help}"
shift 2>/dev/null || true

case "$cmd" in
  shape)
    title="${1:-}"
    desc="${2:-}"
    cat <<EOF
★ Shaped View ───────────────────────────────────
[problem] → [solution]
  ├─ [key flow or behavior 1]
  ├─ [key flow or behavior 2]
  └─ [key constraint or open question]
─────────────────────────────────────────────────

## $title

$desc

### Acceptance Criteria

- [Observable behavior, not implementation detail]
- [What triggers this feature/flow]
- [What the user sees or experiences]
- [Key states and edge cases]

### Designs

N/A

### Risks & Unknowns

- **[Question or risk]**
  Recommend: [option] — [why]
  Discarded: [option] ([why not])
EOF
    ;;
  bug)
    title="${1:-Fix: }"
    desc="${2:-}"
    cat <<EOF
★ Shaped View ───────────────────────────────────
[bug] → [expected behavior]
  ├─ [what breaks]
  └─ [root cause area]
─────────────────────────────────────────────────

## $title

$desc

**Current behavior**: [what happens now]
**Expected behavior**: [what should happen]
**Reproduction**: [steps or conditions]

### Acceptance Criteria

- [The specific broken behavior that should be fixed]
- [Related edge cases to verify]

### Risks & Unknowns

- **[Question or risk]**
  Recommend: [option] — [why]
  Discarded: [option] ([why not])
EOF
    ;;
  improve)
    title="${1:-Improve: }"
    desc="${2:-}"
    cat <<EOF
★ Shaped View ───────────────────────────────────
[current state] → [desired state]
  ├─ [what's wrong today]
  └─ [what it should look like]
─────────────────────────────────────────────────

## $title

$desc

**Current state**: [what exists today]
**Desired state**: [what it should look like]

### Acceptance Criteria

- [Measurable outcomes — what changes for user or system]

### Risks & Unknowns

- **[Migration concerns, backwards compatibility]**
  Recommend: [option] — [why]
  Discarded: [option] ([why not])
EOF
    ;;
  ac)
    criterion="${1:-}"
    echo "★ Acceptance Criterion Check ────────────────────"
    echo "Criterion: $criterion"
    echo ""
    echo "Checklist:"
    echo "✓ Independently testable (pass/fail without reading code)?"
    echo "✓ Describes observable behavior, not implementation?"
    echo "✓ Specific inputs, states, outputs?"
    echo "✗ NO vague language ('works well', 'fast', 'handles edge cases')?"
    echo "─────────────────────────────────────────────────"
    ;;
  template)
    case "${1:-}" in
      feature)
        echo "See: \`bash ./scripts/shape-work.sh shape \"title\" \"desc\"\`"
        ;;
      bug)
        echo "See: \`bash ./scripts/shape-work.sh bug \"title\" \"desc\"\`"
        ;;
      improvement)
        echo "See: \`bash ./scripts/shape-work.sh improve \"title\" \"desc\"\`"
        ;;
      *)
        echo "Options: feature, bug, improvement"
        ;;
    esac
    ;;
  help|*)
    usage
    ;;
esac
