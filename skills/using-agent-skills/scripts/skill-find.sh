#!/usr/bin/env bash
# =============================================================================
# skill-find.sh --- Companion script for Using Agent Skills
#
# Discovers and lists skills, their trigger phrases, and companion scripts.
#
# Usage:
#   bash ./scripts/skill-find.sh find "<query>"
#     Search skills by name or trigger phrase.
#   bash ./scripts/skill-find.sh list [bundle]
#     List all skills, optionally filtered by bundle.
#   bash ./scripts/skill-find.sh stats
#     Show coverage statistics.
# =============================================================================

set -euo pipefail

MODE="${1:-list}"
QUERY="${2:-}"

case "$MODE" in
  find)
    [ -z "$QUERY" ] && echo "Usage: $0 find \"<query>\"" >&2 && exit 1
    echo "=== Skill Search: ${QUERY} ==="
    for d in skills/*/; do
        name=$(basename "$d")
        SKILL="$d/SKILL.md"
        [ ! -f "$SKILL" ] && continue
        if grep -qi "$QUERY" "$SKILL" 2>/dev/null; then
            desc=$(grep -m1 'description:' "$SKILL" | sed 's/.*: //; s/^"//; s/"$//' 2>/dev/null | head -c 100)
            echo "  $name --- ${desc:-}"
        fi
    done
    ;;

  list)
    if [ -n "$QUERY" ]; then
        # Filter by bundle
        echo "=== Bundle: ${QUERY} ==="
        python3 -c "
import json
with open('skills/manifest.json') as f:
    m = json.load(f)
b = m.get('bundles', {}).get('$QUERY', {})
for s in b.get('skills', []):
    print(f'  {s}')
" 2>/dev/null || echo "  Unknown bundle: ${QUERY}. Available: $(python3 -c "import json; m=json.load(open('skills/manifest.json')); print(' '.join(m.get('bundles',{}).keys()))")"
    else
        echo "=== All Skills ==="
        for d in skills/*/; do
            [ -f "$d/SKILL.md" ] || continue
            name=$(basename "$d")
            has_script=$(find "$d" -type f -not -name 'SKILL.md' -not -name 'manifest.json' 2>/dev/null | head -1 | xargs -I{} echo "✓" || echo " ")
            trig=$(grep -m1 'trigger-phrases' "$d/SKILL.md" 2>/dev/null | sed 's/.*: //' | head -c 60)
            echo "  [${has_script}] $name --- ${trig:-}"
        done
    fi
    ;;

  stats)
    total=0; with=0
    for d in skills/*/; do
        [ -f "$d/SKILL.md" ] || continue
        total=$((total + 1))
        has=$(find "$d" -type f -not -name 'SKILL.md' -not -name 'manifest.json' 2>/dev/null | head -1)
        [ -n "$has" ] && with=$((with + 1))
    done
    echo "Skills: ${with}/${total} have companion scripts ($(( with * 100 / total ))%)"
    ;;

  *)
    echo "Usage: $0 {find|list|stats}"
    exit 1
    ;;
esac
