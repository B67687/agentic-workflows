#!/usr/bin/env bash
# =============================================================================
# api-contract.sh --- Companion script for API and Interface Design
#
# Generates API contract templates and validates interface design consistency.
# Covers REST endpoints, GraphQL schemas, and module boundaries.
#
# Usage:
#   bash ./scripts/api-contract.sh rest <name>
#     Generate a REST endpoint contract template.
#   bash ./scripts/api-contract.sh module <name>
#     Generate a module boundary contract template.
#   bash ./scripts/api-contract.sh principles
#     Output the core design principles.
# =============================================================================

set -euo pipefail

MODE="${1:-principles}"
NAME="${2:-}"

case "$MODE" in
  rest)
    [ -z "$NAME" ] && echo "Usage: $0 rest <name>" >&2 && exit 1
    cat << CONTRACT
# API Contract: ${NAME}

## Endpoint
\`${METHOD:-GET} /api/${NAME}\`

## Request
- **Headers:**
- **Query params:**
- **Body:**
\`\`\`

\`\`\`

## Response
- **200 OK:**
\`\`\`

\`\`\`
- **4xx Errors:**
\`\`\`

\`\`\`

## Behaviors (Hyrum's Law)
- **Stable:** response shape, error codes, auth
- **May change:** timing, error message text, field ordering
- **Not guaranteed:** log output, debug headers

## Tests
- [ ] Happy path
- [ ] Error path
- [ ] Auth/unauthorized
- [ ] Edge: empty, large, invalid input
CONTRACT
    ;;

  module)
    [ -z "$NAME" ] && echo "Usage: $0 module <name>" >&2 && exit 1
    cat << CONTRACT
# Module Boundary: ${NAME}

## Public API
- **Exports:**
- **Types:**
- **Events emitted:**

## Dependencies
- **Owns:**
- **Consumes:**
- **Must NOT depend on:**

## Invariants
- [ ] <must-always-be-true condition>
- [ ] <must-never-be-true condition>

## Test Surface
- Unit tests for each public function
- Integration test for boundary crossing
CONTRACT
    ;;

  principles)
    cat << PRIN
=== API Design Principles ===

1. Hyrum's Law --- all observable behaviors become de facto contracts
2. Make the right thing easy, the wrong thing hard
3. Be intentional about what you expose
4. Fail fast with clear error messages
5. Version APIs at the integration boundary, not the code level
6. Design for the caller, not the implementer
7. Prefer composition over inheritance in type design
8. Immutable interfaces are easier to reason about
PRIN
    ;;

  *)
    echo "Usage: $0 {rest|module|principles}"
    exit 1
    ;;
esac
