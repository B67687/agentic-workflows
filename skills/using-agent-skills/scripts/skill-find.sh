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
        echo "=== All Skills (pattern/bundle) ==="
        # Delegate to skill-toolset for L1 listing with pattern/bundle info
        if [ -x "$(dirname "$0")/../../scripts/skill-toolset.sh" ]; then
            exec "$(dirname "$0")/../../scripts/skill-toolset.sh" list
        fi
        # Fallback: show from .skill-index.json
        python3 -c "
import json
idx = json.load(open('skills/.skill-index.json'))
for s in idx['skills']:
    pat = f'[{s[\"pattern\"]}]' if s.get('pattern') else ''
    bun = f'({s[\"bundle\"]})' if s.get('bundle') else ''
    desc = s['description'][:60]
    print(f'  {s[\"name\"]:40s} {pat:14s} {bun:10s} {desc}')
" 2>/dev/null
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
