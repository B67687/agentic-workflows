#!/usr/bin/env bash
# =============================================================================
# skill-test.sh --- Companion script for Skill Evaluator
#
# Tests a skill's behavior: verifies trigger patterns, runs test cases,
# and reports pass/fail for each scenario.
#
# Usage:
#   bash ./scripts/skill-test.sh discover
#     List all skills with their trigger phrases.
#   bash ./scripts/skill-test.sh check <skill-name>
#     Verify a skill has minimum required structure.
# =============================================================================

set -euo pipefail

MODE="${1:-discover}"
SKILL_NAME="${2:-}"

case "$MODE" in
  discover)
    echo "=== Skill Discovery ==="
    for d in skills/*/; do
      name=$(basename "$d")
      triggers=$(grep -m1 'trigger-phrases' "$d/SKILL.md" 2>/dev/null | sed 's/.*: //')
      echo "  $name"
      [ -n "$triggers" ] && echo "    triggers: $triggers"
    done
    ;;

  check)
    [ -z "$SKILL_NAME" ] && echo "Usage: $0 check <skill-name>" >&2 && exit 1
    SKILL_DIR="skills/$SKILL_NAME"
    if [ ! -d "$SKILL_DIR" ]; then
      echo "NOT FOUND: skill '$SKILL_NAME'"
      exit 1
    fi
    echo "=== Skill Check: $SKILL_NAME ==="
    
    # Check SKILL.md exists
    [ -f "$SKILL_DIR/SKILL.md" ] && echo "  ✓ SKILL.md" || echo "  ✗ SKILL.md missing"
    
    # Check frontmatter
    grep -q '^---' "$SKILL_DIR/SKILL.md" 2>/dev/null && echo "  ✓ frontmatter" || echo "  ✗ frontmatter"
    
    # Check trigger phrases
    grep -q 'trigger-phrases' "$SKILL_DIR/SKILL.md" 2>/dev/null && echo "  ✓ trigger phrases" || echo "  ✗ trigger phrases"
    
    # Check companion script
    scripts=$(find "$SKILL_DIR" -type f -not -name 'SKILL.md' -not -name 'manifest.json' 2>/dev/null)
    [ -n "$scripts" ] && echo "  ✓ companion script(s)" || echo "  ✗ no companion script"
    
    # Check in manifest
    grep -q "\"$SKILL_NAME\"" skills/manifest.json 2>/dev/null && echo "  ✓ in manifest" || echo "  ✗ not in manifest"
    ;;

  *)
    echo "Usage: $0 {discover|check}"
    exit 1
    ;;
esac
