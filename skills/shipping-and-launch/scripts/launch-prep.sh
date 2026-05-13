#!/usr/bin/env bash
# =============================================================================
# launch-prep.sh --- Companion script for Shipping and Launch
#
# Generates pre-launch checklists and rollback plans.
#
# Usage:
#   bash ./scripts/launch-prep.sh checklist "<version>"
#     Generate a pre-launch checklist.
#
#   bash ./scripts/launch-prep.sh rollback "<version>"
#     Generate a rollback plan template.
# =============================================================================

set -euo pipefail

MODE="${1:-checklist}"
VERSION="${2:-$(git describe --tags 2>/dev/null || echo 'unknown')}"

case "$MODE" in
  checklist)
    cat << CHECKLIST
# Pre-Launch Checklist: ${VERSION}

## Verification
- [ ] All tests pass
- [ ] Build succeeds
- [ ] No known regressions
- [ ] Performance benchmarks within threshold
- [ ] Security scan clean

## Communication
- [ ] Changelog written
- [ ] Stakeholders notified
- [ ] Support team briefed

## Deployment
- [ ] Database migrations validated
- [ ] Feature flags configured
- [ ] Monitoring alerts reviewed
- [ ] Rollback plan ready

## Post-Launch
- [ ] Smoke tests on production
- [ ] Metrics verified
- [ ] Error rates normal
CHECKLIST
    ;;

  rollback)
    cat << ROLLBACK
# Rollback Plan: ${VERSION}

## Trigger Conditions
- Error rate increase > 5%
- P1 or P2 bug introduced
- Performance regression > 10%

## Rollback Steps
1. Revert to ${VERSION}:
   \`git revert <commit-hash>\`
2. Deploy revert
3. Verify: \`bash ./scripts/test-smoke.sh\`
4. Notify stakeholders

## Verification After Rollback
- [ ] All services healthy
- [ ] Error rates back to baseline
- [ ] Users unblocked
ROLLBACK
    ;;

  *)
    echo "Usage: $0 {checklist|rollback} [version]"
    exit 1
    ;;
esac
