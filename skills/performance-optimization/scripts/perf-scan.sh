#!/usr/bin/env bash
# =============================================================================
# perf-scan.sh --- Companion script for Performance Optimization
#
# Implements the MEASURE -> IDENTIFY -> FIX -> VERIFY -> GUARD workflow.
# Provides baseline measurement, bottleneck identification, and regression
# guarding tools.
#
# Usage:
#   bash ./scripts/perf-scan.sh check
#     Quick performance health check: file sizes, bundle analysis, common
#     anti-patterns.
#
#   bash ./scripts/perf-scan.sh baseline
#     Generate a baseline performance report for tracking.
#
#   bash ./scripts/perf-scan.sh guardian <command>
#     Run a command and measure its execution time, for use in CI.
#     Exits 0 if within threshold, 1 if exceeded.
#     Example: bash ./scripts/perf-scan.sh guardian "npm test" --max 30
#
#   bash ./scripts/perf-scan.sh cwv
#     Core Web Vitals reference table.
# =============================================================================

set -euo pipefail

MODE="${1:-check}"
MAX_SECONDS="${3:-30}"

case "$MODE" in
  check)
    echo "=== Performance Health Check ==="
    echo ""
    
    # Check 1: Large files
    echo "--- Large files (>500KB) ---"
    LARGE=$(find . -path ./.git -prune -o -path ./node_modules -prune -o -path ./__pycache__ -prune -o -type f -size +500k -print 2>/dev/null | head -10)
    if [ -n "$LARGE" ]; then
      echo "$LARGE" | while read -r f; do
        echo "  $(du -h "$f" | cut -f1)  $f"
      done
    else
      echo "  No large files found (threshold: 500KB)"
    fi
    echo ""
    
    # Check 2: Unoptimized images
    echo "--- Unoptimized images (>100KB) ---"
    IMAGES=$(find . -path ./.git -prune -o -path ./node_modules -prune -o \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.gif' \) -size +100k -not -name '.screenshots_*' -print 2>/dev/null | head -10)
    if [ -n "$IMAGES" ]; then
      echo "$IMAGES" | while read -r f; do
        echo "  $(du -h "$f" | cut -f1)  $f"
      done
    else
      echo "  No unoptimized images found"
    fi
    echo ""
    
    # Check 3: Large tracked assets in git
    echo "--- Git-tracked files >1MB ---"
    GIT_LARGE=$(git ls-tree -r HEAD --name-only 2>/dev/null | while read -r f; do
      sz=$(git cat-file -s "HEAD:$f" 2>/dev/null || echo 0)
      if [ "$sz" -gt 1048576 ] 2>/dev/null; then
        echo "  $(numfmt --to=iec "$sz" 2>/dev/null || echo "${sz}B") $f"
      fi
    done | head -10)
    if [ -n "$GIT_LARGE" ]; then
      echo "$GIT_LARGE"
    else
      echo "  No tracked files >1MB"
    fi
    echo ""
    
    # Check 4: N+1 query patterns
    echo "--- N+1 query patterns ---"
    NPLUS1=$(grep -rn '\.forEach\|\.map' --include='*.ts' --include='*.js' . 2>/dev/null | grep -i 'await\|async\|fetch\|query' | head -5 || true)
    if [ -n "$NPLUS1" ]; then
      echo "  ℹ   Possible N+1 patterns (review each):"
      echo "$NPLUS1"
    else
      echo "  ✓  No obvious N+1 patterns detected"
    fi
    echo ""
    
    echo "=== Performance check complete ==="
    echo "For detailed analysis: Lighthouse CI, Chrome DevTools, or your profiler"
    ;;

  baseline)
    TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    echo "=== Performance Baseline ==="
    echo "Generated: $TIMESTAMP"
    echo ""
    
    # Total file count and size
    echo "--- Repository ---"
    echo "  Tracked files: $(git ls-files | wc -l)"
    echo "  Total tracked size: $(git ls-tree -r HEAD --name-only | while read f; do git cat-file -s "HEAD:$f"; done | awk '{s+=$1} END {print s/1024/1024 " MB"}' 2>/dev/null)"
    echo ""
    
    # Largest directories
    echo "--- Largest directories (tracked) ---"
    git ls-tree -r HEAD --name-only 2>/dev/null | sed 's|/[^/]*$||' | sort | uniq -c | sort -rn | head -10
    echo ""
    
    # Git stats
    echo "--- Git history ---"
    echo "  .git size: $(du -sh .git 2>/dev/null | cut -f1)"
    echo "  Commits: $(git rev-list --all --count 2>/dev/null)"
    echo "  Branches: $(git branch | wc -l)"
    echo ""
    
    echo "Save this baseline for comparison."
    echo "Next: run \`bash ./scripts/perf-scan.sh check\` after changes to compare."
    ;;

  guardian)
    # Usage: $0 guardian <command> --max <seconds>
    # Extract command and max from args
    CMD=""
    MAX_VAL="$MAX_SECONDS"
    BUILD_ARGS=()
    AFTER_GUARDIAN=false
    
    for arg in "$@"; do
      if [ "$arg" = "guardian" ]; then
        AFTER_GUARDIAN=true
        continue
      fi
      if $AFTER_GUARDIAN; then
        if [ "$arg" = "--max" ]; then
          continue
        elif [ "$MAX_VAL" != "$MAX_SECONDS" ]; then
          # Already set max, this is part of command
          BUILD_ARGS+=("$arg")
        elif [[ "$arg" =~ ^[0-9]+$ ]]; then
          MAX_VAL="$arg"
        else
          BUILD_ARGS+=("$arg")
        fi
      fi
    done
    
    if [ ${#BUILD_ARGS[@]} -eq 0 ]; then
      echo "Usage: $0 guardian \"<command>\" --max <seconds>" >&2
      echo "Example: $0 guardian \"npm test\" --max 30" >&2
      exit 1
    fi
    
    CMD="${BUILD_ARGS[*]}"
    
    echo "PERF_GUARDIAN_TIMEOUT=${MAX_VAL}s"
    echo "PERF_GUARDIAN_COMMAND=${CMD}"
    echo ""
    
    START=$(date +%s.%N)
    eval "$CMD" || true
    END=$(date +%s.%N)
    DURATION=$(echo "$END - $START" | bc 2>/dev/null || echo 0)
    DURATION_INT=${DURATION%.*}
    
    echo ""
    echo "PERF_GUARDIAN_DURATION=${DURATION}s"
    echo "PERF_GUARDIAN_THRESHOLD=${MAX_VAL}s"
    
    if [ "${DURATION_INT:-0}" -gt "$MAX_VAL" ] 2>/dev/null; then
      echo "PERF_GUARDIAN_RESULT=fail"
      echo "PERF_GUARDIAN_MESSAGE=Duration ${DURATION}s exceeded threshold of ${MAX_VAL}s"
      exit 1
    else
      echo "PERF_GUARDIAN_RESULT=pass"
      echo "PERF_GUARDIAN_MESSAGE=Duration ${DURATION}s within threshold of ${MAX_VAL}s"
      exit 0
    fi
    ;;

  cwv)
    cat << "CWV"
=== Core Web Vitals Reference ===

| Metric | Good | Needs Improvement | Poor |
|--------|------|-------------------|------|
| LCP (Largest Contentful Paint) | ≤ 2.5s | ≤ 4.0s | > 4.0s |
| INP (Interaction to Next Paint) | ≤ 200ms | ≤ 500ms | > 500ms |
| CLS (Cumulative Layout Shift) | ≤ 0.1 | ≤ 0.25 | > 0.25 |

Measurement tools:
- Chrome DevTools -> Lighthouse
- Chrome DevTools -> Performance tab
- web-vitals library (RUM)
- PageSpeed Insights
- CrUX (Chrome User Experience Report)

Common fixes:
- LCP: Optimize largest element (image sizing, CDN, lazy loading)
- INP: Break up long tasks, debounce handlers, use web workers
- CLS: Set explicit dimensions on images/embeds, avoid late-inserting content
CWV
    ;;

  *)
    echo "Usage: $0 {check|baseline|guardian|cwv}"
    echo ""
    echo "  check              --- Quick performance health check"
    echo "  baseline           --- Generate baseline performance report"
    echo "  guardian <cmd>     --- Run command with timeout guard"
    echo "  cwv                --- Core Web Vitals reference table"
    exit 1
    ;;
esac
