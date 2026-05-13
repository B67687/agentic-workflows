#!/usr/bin/env bash
# =============================================================================
# migrate-plan.sh --- Companion script for Deprecation and Migration
#
# Generates migration plan templates and phase-out checklists.
#
# Usage:
#   bash ./scripts/migrate-plan.sh plan "<old>" "<new>"
#     Generate a migration plan template.
#   bash ./scripts/migrate-plan.sh checklist
#     Generate a deprecation checklist.
# =============================================================================

set -euo pipefail

MODE="${1:-checklist}"
OLD="${2:-}"
NEW="${3:-}"

case "$MODE" in
  plan)
    if [ -z "$OLD" ] || [ -z "$NEW" ]; then
      echo "Usage: $0 plan \"<old-system>\" \"<new-system>\"" >&2
      exit 1
    fi
    cat << PLAN
# Migration Plan: ${OLD} -> ${NEW}

## Scope
- **Removing:**
- **Replacing with:**

## Timeline
- **Deprecation announced:**
- **Migration window:**
- **Old system sunset:**

## Migration Phases

### Phase 1: Prepare
- [ ] Document current ${OLD} usage
- [ ] Identify all consumers
- [ ] Create ${NEW} parallel implementation

### Phase 2: Migrate
- [ ] Migrate internal consumers
- [ ] Migrate external consumers
- [ ] Run both systems in parallel

### Phase 3: Sunset
- [ ] Verify all consumers migrated
- [ ] Remove old code
- [ ] Archive documentation

## Rollback
- **Trigger:** <critical bug, performance regression>
- **Steps:**
  1. Route traffic back to ${OLD}
  2. Notify consumers
  3. Revert deployment

## Verification
- [ ] All consumer tests pass
- [ ] Performance within threshold
- [ ] No data loss
- [ ] Monitoring confirms ${NEW} is healthy
PLAN
    ;;

  checklist)
    cat << CHECK
=== Deprecation Checklist ===

## Before Announcing
- [ ] Clear rationale documented
- [ ] Replacement ready or planned
- [ ] Migration path defined
- [ ] Timeline communicated

## During Migration
- [ ] Both systems run in parallel
- [ ] Consumers notified of timeline
- [ ] Monitoring for both systems active

## After Sunset
- [ ] Old code removed
- [ ] Documentation updated
- [ ] Dependencies cleaned up
- [ ] Post-mortem written
CHECK
    ;;

  *)
    echo "Usage: $0 {plan|checklist}"
    exit 1
    ;;
esac
