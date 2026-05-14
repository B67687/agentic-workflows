#!/bin/bash
# meta-standardize.sh --- Self-standardization for autonomous runtime.
# Enforces workspace conventions automatically:
#   - Frontmatter on new skills/docs
#   - Drift detection between propagated copies and hub
#   - Stale .learnings.jsonl cleanup
#   - Auto-generate reference files from inline code blocks
#
# Usage:
#   bash ./scripts/meta-standardize.sh check          # Dry run: report issues
#   bash ./scripts/meta-standardize.sh fix            # Auto-fix standard issues
#   bash ./scripts/meta-standardize.sh drift          # Detect propagation drift
#   bash ./scripts/meta-standardize.sh stats          # Workspace quality stats

set -euo pipefail
trap 'echo "[ERROR] $BASH_SOURCE:$LINENO"' ERR

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")

CMD="${1:-check}"

# ---------------------------------------------------------------------------
# Check: report all standard issues (dry run)
# ---------------------------------------------------------------------------
check() {
  echo "=== Meta-Standardization: Check ==="
  ISSUES=0

  # 1. Check skill frontmatter
  echo ""
  echo "--- Skill Frontmatter ---"
  for skill_dir in "$REPO_ROOT/skills"/*/; do
    skill_file="${skill_dir}SKILL.md"
    [ -f "$skill_file" ] || continue
    if ! head -5 "$skill_file" | grep -q "^---$"; then
      echo "  MISSING frontmatter: $skill_file"
      ISSUES=$((ISSUES + 1))
    fi
  done

  # 2. Check for dangling references (referenced but missing)
  echo ""
  echo "--- Dangling L3 References ---"
  rtk grep -rP 'skill-toolset\.sh resource \S+ (\S+/)*(\S+)' "$REPO_ROOT/skills" --include="SKILL.md" 2>/dev/null | while IFS=: read -r file line content; do
    ref=$(echo "$content" | grep -oP 'resource \S+ (\S+/)*(\S+)' | awk '{print $2, $3}' 2>/dev/null || true)
    if [ -n "$ref" ]; then
      skill=$(echo "$ref" | awk '{print $1}')
      refpath=$(echo "$ref" | awk '{print $2}')
      # Check if ref file exists
      found=false
      for d in "$REPO_ROOT/skills"/*/; do
        skill_name=$(basename "$d")
        if [ "$skill_name" = "$skill" ] && [ -f "$d$refpath" ]; then
          found=true
          break
        fi
      done
      if [ "$found" = false ]; then
        echo "  MISSING REF: $skill references $refpath"
      fi
    fi
  done || true

  # 3. Check learnings for duplicate entries
  echo ""
  echo "--- Learnings Quality ---"
  if [ -f "$REPO_ROOT/.learnings.jsonl" ]; then
    TOTAL=$(wc -l < "$REPO_ROOT/.learnings.jsonl")
    DUPS=$(sort "$REPO_ROOT/.learnings.jsonl" | uniq -d | wc -l)
    echo "  Total entries: $TOTAL"
    echo "  Duplicates:    $DUPS"
    if [ "$DUPS" -gt 0 ]; then
      ISSUES=$((ISSUES + 1))
    fi
  fi

  echo ""
  if [ "$ISSUES" -eq 0 ]; then
    echo "Check PASSED: No standard issues found."
  else
    echo "Check FAILED: $ISSUES issue(s) found. Run 'meta-standardize.sh fix' to resolve."
  fi
}

# ---------------------------------------------------------------------------
# Fix: auto-correct standard issues
# ---------------------------------------------------------------------------
fix() {
  echo "=== Meta-Standardization: Fix ==="

  # 1. Dedup learnings
  echo ""
  echo "--- Dedup Learnings ---"
  if [ -f "$REPO_ROOT/.learnings.jsonl" ]; then
    PRE=$(wc -l < "$REPO_ROOT/.learnings.jsonl")
    sort "$REPO_ROOT/.learnings.jsonl" | uniq > "$REPO_ROOT/.learnings.jsonl.tmp"
    mv "$REPO_ROOT/.learnings.jsonl.tmp" "$REPO_ROOT/.learnings.jsonl"
    POST=$(wc -l < "$REPO_ROOT/.learnings.jsonl")
    REMOVED=$((PRE - POST))
    echo "  Removed $REMOVED duplicate entries ($PRE -> $POST)"
  fi

  # 2. Consolidate learnings
  echo ""
  echo "--- Consolidate Memory ---"
  if [ -f "$REPO_ROOT/scripts/consolidate-memory.sh" ]; then
    bash "$REPO_ROOT/scripts/consolidate-memory.sh" --stats 2>&1 | head -5 || true
  fi

  # 3. Check for empty files in skills dirs
  echo ""
  echo "--- Clean Empty Files ---"
  for f in "$REPO_ROOT/skills"/*/references/*; do
    if [ -f "$f" ] && [ ! -s "$f" ]; then
      echo "  REMOVED empty: $f"
      rm "$f"
    fi
  done 2>/dev/null || true

  echo ""
  echo "Fix complete."
}

# ---------------------------------------------------------------------------
# Drift: detect propagation inconsistencies
# ---------------------------------------------------------------------------
drift() {
  echo "=== Meta-Standardization: Drift Detection ==="
  DRIFT=0

  # Check for topic folder copies that diverged from hub
  for topic_dir in "$REPO_ROOT"/../*/; do
    [ -d "$topic_dir" ] || continue
    [ "$(realpath "$topic_dir")" = "$(realpath "$REPO_ROOT")" ] && continue

    # Check for AGENTS.md propagation drift
    hub_agents="$REPO_ROOT/AGENTS.md"
    topic_agents="${topic_dir}AGENTS.md"
    if [ -f "$hub_agents" ] && [ -f "$topic_agents" ]; then
      if ! diff -q "$hub_agents" "$topic_agents" >/dev/null 2>&1; then
        echo "  DRIFT: $(basename "$topic_dir")/AGENTS.md differs from hub"
        DRIFT=$((DRIFT + 1))
      fi
    fi
  done 2>/dev/null || true

  if [ "$DRIFT" -eq 0 ]; then
    echo "No drift detected."
  else
    echo "Run 'propagate-to-all.sh' to fix $DRIFT drifted file(s)."
  fi
}

# ---------------------------------------------------------------------------
# Stats: workspace quality metrics
# ---------------------------------------------------------------------------
stats() {
  echo "=== Meta-Standardization: Stats ==="

  SKILLS=0
  for d in "$REPO_ROOT/skills"/*/; do
    [ -d "$d" ] && SKILLS=$((SKILLS + 1))
  done

  SCRIPTS=$(find "$REPO_ROOT/scripts" -maxdepth 1 -name '*.sh' 2>/dev/null | wc -l)
  TESTS=$(find "$REPO_ROOT/scripts/test-smoke.sh" 2>/dev/null && grep -cP 'assert_' "$REPO_ROOT/scripts/test-smoke.sh" 2>/dev/null || echo "0")
  LEARNINGS=$(wc -l < "$REPO_ROOT/.learnings.jsonl" 2>/dev/null || echo "0")
  COMMITS=$(rtk rev-list --count HEAD 2>/dev/null || echo "?")

  echo "  Skills:    $SKILLS"
  echo "  Scripts:   $SCRIPTS"
  echo "  Tests:     $TESTS"
  echo "  Learnings: $LEARNINGS"
  echo "  Commits:   $COMMITS"

  # Check test health
  echo ""
  echo "--- Test Health ---"
  if bash "$REPO_ROOT/scripts/test-smoke.sh" 2>&1 | tail -1 | grep -q "ALL TESTS PASSED"; then
    echo "  Tests: PASSING"
  else
    echo "  Tests: FAILING"
  fi 2>/dev/null || echo "  Tests: unknown"

  # Check quality gate status
  echo ""
  echo "--- Workspace Quality ---"
  if [ -d "$REPO_ROOT/.git" ]; then
    UNCOMMITTED=$(rtk status --porcelain 2>/dev/null | wc -l)
    echo "  Uncommitted files: $UNCOMMITTED"
    echo "  Branch: $(rtk branch --show-current 2>/dev/null || echo '?')"
  fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
case "$CMD" in
  check) check ;;
  fix) fix ;;
  drift) drift ;;
  stats) stats ;;
  help|--help|-h|*) echo "Usage: bash ./scripts/meta-standardize.sh [check|fix|drift|stats]" ;;
esac
