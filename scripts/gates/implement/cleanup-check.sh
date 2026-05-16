#!/usr/bin/env bash
# =============================================================================
# Gate plugin: implement/cleanup-check
#
# Warns about project disk bloat before implementation:
#   - Git pack bloat (prune-packable objects)
#   - Large build artifact directories
#   - Stale caches
#
# Standard gate interface:
#   Exit 0 = PASS (no significant bloat, or cleanup not urgent)
#   Exit 2 = WARN (significant reclaimable space detected)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "  ── Gate: implement/cleanup-check"

total_waste_mb=0
warnings=()

# ── Check git bloat ──────────────────────────────────────────────────────────
if git -C "$REPO_ROOT" rev-parse --git-dir &>/dev/null; then
  prune=$(git -C "$REPO_ROOT" count-objects -v 2>/dev/null | grep "prune-packable" | awk '{print $2}')
  pack_size_kb=$(git -C "$REPO_ROOT" count-objects -v 2>/dev/null | grep "size-pack" | awk '{print $2}')
  pack_size_mb=$((pack_size_kb / 1024))

  if [ "${prune:-0}" -gt "0" ]; then
    total_waste_mb=$((total_waste_mb + prune / 10)) # rough estimate
    warnings+=(" $prune prune-packable git objects (run: git gc --aggressive)")
  fi
  if [ "$pack_size_mb" -gt "100" ]; then
    warnings+=(" Git pack: ${pack_size_mb}M (consider: git gc --aggressive)")
  fi
fi

# ── Check build artifacts ────────────────────────────────────────────────────
for dir in "build" "dist" ".next" "target" ".dart_tool"; do
  if [ -d "$REPO_ROOT/$dir" ]; then
    sz_kb=$(du -sk "$REPO_ROOT/$dir" 2>/dev/null | cut -f1)
    if [ "$sz_kb" -gt "102400" ]; then # >100M
      sz_mb=$((sz_kb / 1024))
      total_waste_mb=$((total_waste_mb + sz_mb))
      warnings+=(" $dir/: ${sz_mb}M")
    fi
  fi
done

# ── Check node_modules staleness ─────────────────────────────────────────────
if [ -f "$REPO_ROOT/package.json" ] && [ -d "$REPO_ROOT/node_modules" ]; then
  if [ -f "$REPO_ROOT/package-lock.json" ]; then
    lock_time=$(stat -c %Y "$REPO_ROOT/package-lock.json" 2>/dev/null || echo 0)
    nm_time=$(stat -c %Y "$REPO_ROOT/node_modules" 2>/dev/null || echo 0)
    if [ "$lock_time" -gt "$nm_time" ] && [ "$lock_time" -gt "0" ]; then
      warnings+=(" node_modules may be stale (package-lock.json is newer)")
    fi
  fi
fi

# ── Report ───────────────────────────────────────────────────────────────────
if [ "$total_waste_mb" -gt "500" ]; then
  echo "    ⚠  ${total_waste_mb}M reclaimable detected in project:"
  for w in "${warnings[@]}"; do
    echo "      *$w"
  done
  echo "    => Run /cleanup --apply to reclaim space"
  echo "    => WARN  Cleanup recommended before implementation"
  exit 2
elif [ "$total_waste_mb" -gt "100" ]; then
  echo "    ℹ  ${total_waste_mb}M reclaimable"
  for w in "${warnings[@]}"; do
    echo "      *$w"
  done
  echo "    => PASS  Minor bloat, cleanup optional"
  exit 0
else
  echo "    ✓ PASS  Project is lean (<100M reclaimable)"
  exit 0
fi
