#!/usr/bin/env bash
# =============================================================================
# ui-component.sh --- Companion script for Frontend UI Engineering
#
# Scaffolds common UI component patterns with production-quality structure.
#
# Usage:
#   bash ./scripts/ui-component.sh component <name>
#     Scaffold a new component.
#   bash ./scripts/ui-component.sh pattern <type>
#     Show a UI pattern template (list, form, modal, table).
# =============================================================================

set -euo pipefail

MODE="${1:-component}"
NAME="${2:-}"

case "$MODE" in
  component)
    [ -z "$NAME" ] && echo "Usage: $0 component <name>" >&2 && exit 1
    cat << COMP
# Component: ${NAME}

## Props
\`\`\`ts
interface ${NAME}Props {
  // TODO: define
}
\`\`\`

## State
- **Loading:**
- **Empty:**
- **Error:**
- **Success:**

## States to Cover
- [ ] Loading skeleton
- [ ] Empty state
- [ ] Error state
- [ ] Edge: no data / overflow / truncation

## Accessibility
- [ ] Keyboard navigation
- [ ] ARIA labels
- [ ] Focus management
- [ ] Screen reader test

## Performance
- [ ] Memoization needed?
- [ ] Bundle size impact?
COMP
    ;;

  pattern)
    case "${NAME}" in
      list)
        echo "Pattern: List --- loading -> empty -> items -> pagination"
        ;;
      form)
        echo "Pattern: Form --- validation -> submission -> error -> success"
        ;;
      modal)
        echo "Pattern: Modal --- open -> focus trap -> close -> cleanup"
        ;;
      table)
        echo "Pattern: Table --- headers -> rows -> sort -> filter -> paginate"
        ;;
      *)
        echo "Available patterns: list, form, modal, table"
        ;;
    esac
    ;;

  *)
    echo "Usage: $0 {component|pattern}"
    exit 1
    ;;
esac
