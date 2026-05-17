#!/usr/bin/env bash
# generate-repo-stats.sh — Auto-update stale counts in SVG diagrams
#
# Scans actual filesystem and updates number labels.
# Run before every release or commit that touches docs/.
#
# Usage:
#   bash ./scripts/generate-repo-stats.sh         # dry-run (show changes)
#   bash ./scripts/generate-repo-stats.sh --apply  # apply changes

set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

DRY_RUN=true
[ "${1:-}" = "--apply" ] && DRY_RUN=false

echo "═ Scanning repo ═"

SKILLS=$(ls -d skills/*/ 2>/dev/null | wc -l)
SCRIPTS=$(find scripts/ -maxdepth 2 -name '*.sh' 2>/dev/null | wc -l)
COMMANDS=$(ls commands/ 2>/dev/null | wc -l)
PROPAGATION=$(ls propagation/ 2>/dev/null | wc -l)
# Smoke tests: count test_ function definitions
TESTS=$(grep -cE '^\s*test_\w+' scripts/test-smoke.sh 2>/dev/null || echo "0")

echo "  skills:      $SKILLS"
echo "  scripts:     $SCRIPTS"
echo "  commands:    $COMMANDS"
echo "  propagate:   $PROPAGATION"
echo "  smoke tests: $TESTS"
echo ""

# Update hub-architecture SVGs
for svg in docs/hub-architecture.svg docs/hub-architecture-light.svg; do
    [ ! -f "$svg" ] && continue
    changes=0
    
    echo -n "  $svg: "
    
    # Skills count
    if grep -qP '\d+ Engineering Skills' "$svg" 2>/dev/null; then
        sed -i "s/[0-9]\+ Engineering Skills/${SKILLS} Engineering Skills/" "$svg" && changes=$((changes+1))
    fi
    # Templates count
    if grep -qP '\d+ Templates\b' "$svg" 2>/dev/null; then
        sed -i "s/[0-9]\+ Templates\b/${PROPAGATION} Templates/" "$svg" && changes=$((changes+1))
    fi
    # Smoke tests count
    if grep -qP '\d+ Smoke Tests' "$svg" 2>/dev/null; then
        sed -i "s/[0-9]\+ Smoke Tests/${TESTS} Smoke Tests/" "$svg" && changes=$((changes+1))
    fi
    
    echo "$changes field(s) updated"
done

# Update folder-structure SVGs
for svg in docs/folder-structure.svg docs/folder-structure-light.svg; do
    [ ! -f "$svg" ] && continue
    changes=0
    
    echo -n "  $svg: "
    
    # skills count (format: "44 engineering skills with scripts" or similar)
    if grep -qP '\d+ engineering skills' "$svg" 2>/dev/null; then
        sed -i "s/[0-9]\+ engineering skills/${SKILLS} engineering skills/" "$svg" && changes=$((changes+1))
    fi
    # commands count (format: "14 commands for session...")
    if grep -qP '\d+ commands ' "$svg" 2>/dev/null; then
        sed -i "s/[0-9]\+ commands /${COMMANDS} commands /" "$svg" && changes=$((changes+1))
    fi
    
    echo "$changes field(s) updated"
done

echo ""
if $DRY_RUN; then
    echo "═ Dry-run — no files modified. Use --apply to write changes."
    echo "  Changes pending:"
    git diff --stat 2>/dev/null || true
else
    echo "═ Applied. Review with: git diff --stat"
    git diff --stat 2>/dev/null || true
fi
