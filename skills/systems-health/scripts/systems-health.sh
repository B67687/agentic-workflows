#!/usr/bin/env bash
# Systems health — measure development system health from git/GitHub data.
# Usage: bash ./scripts/systems-health.sh <command> [dir]
set -euo pipefail

TAP_DIR=".tap"
mkdir -p "$TAP_DIR"
SINCE="${2:-30 days ago}"

case "${1:-help}" in
  collect)
    echo "# Systems Health Data Collection"
    echo "Period: since \"$SINCE\""
    echo ""
    echo "## Commits"
    git log --oneline --since="$SINCE" 2>/dev/null | wc -l | xargs -I{} echo "  {} commits"
    echo ""
    echo "## Contributors"
    git shortlog -sn --no-merges --since="$SINCE" 2>/dev/null || echo "  (no data)"
    echo ""
    echo "## Working tree"
    echo "  $(git diff --stat 2>/dev/null | tail -1 || echo 'clean')"
    ;;
  stocks)
    echo "# Stocks"
    echo ""
    echo "| Stock | Measure | Healthy | Current |"
    echo "|-------|---------|---------|--------|"
    echo "| Backlog | Open issues | Stable/shrinking | (check issue tracker) |"
    echo "| Open PRs | Count + age | < 5, oldest < 3d | (check PR tracker) |"
    echo "| Open bugs | Bug count | Stable/shrinking | (check bug tracker) |"
    echo "| Git objects | .git size | Under 50MB | $(du -sh .git 2>/dev/null | cut -f1) |"
    ;;
  flows)
    echo "# Flows"
    echo ""
    echo "| Flow | Measure | How to get |"
    echo "|------|---------|-----------|"
    echo "| Stories in | Issues created/week | gh issue list --since=\"$SINCE\" |"
    echo "| Stories out | PRs merged/week | gh pr list --state merged --limit 20 |"
    echo "| Cycle time | PR open→merge (median) | gh pr view <number> |"
    echo "| Bug inflow | Bugs created/week | gh issue list --label bug |"
    echo ""
    echo "Note: Requires GitHub CLI (gh) for full data"
    ;;
  feedback)
    echo "# Feedback Loops"
    echo ""
    echo "## Tests"
    if [ -f "scripts/test-smoke.sh" ]; then
      echo "Smoke suite exists"
    else
      echo "No smoke test suite found"
    fi
    test_count=$(find . -name 'test_*.py' -o -name '*.test.ts' -o -name '*.test.js' 2>/dev/null | grep -v '.git/' | wc -l)
    echo "  $test_count test files"
    echo ""
    echo "## CI"
    if [ -f ".github/workflows" ]; then
      echo "GitHub Actions configured"
    else
      echo "No CI workflow detected"
    fi
    echo ""
    echo "## Quality"
    echo "  Lint: $( (which shellcheck >/dev/null 2>&1 && echo 'available') || echo 'not available')"
    echo "  Type check: $( (which mypy >/dev/null 2>&1 && echo 'available') || echo 'not available')"
    ;;
  complexity)
    echo "# Complexity Signals"
    echo ""
    echo "Total tracked files: $(git ls-files | wc -l)"
    echo "Script count: $(find . -name '*.sh' -not -path './.git/*' | wc -l)"
    echo "Large files (>500 lines):"
    find . -type f -not -path './.git/*' -exec bash -c 'wc -l "$1"' _ {} \; 2>/dev/null | sort -rn | head -5
    ;;
  diagnose)
    echo "# Diagnosis"
    echo ""
    echo "Based on collected data, consider:"
    echo "1. Is throughput stable or degrading?"
    echo "2. Are feedback loops fast enough?"
    echo "3. Is complexity under control?"
    echo "4. What's the biggest bottleneck?"
    echo ""
    echo "See: $TAP_DIR/tap-audit.md, $TAP_DIR/learnings.md"
    ;;
  report)
    report_file="$TAP_DIR/system-health.md"
    {
      echo "# System Health Report"
      echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
      echo ""
      echo "## Commits (since $SINCE)"
      git log --oneline --since="$SINCE" 2>/dev/null | wc -l | xargs -I{} echo "- {} commits" || echo "- unknown"
      echo ""
      echo "## Working tree"
      git diff --stat 2>/dev/null | tail -1 || echo "clean"
      echo ""
      echo "## Tracked files"
      git ls-files | wc -l | xargs -I{} echo "- {} tracked files"
    } > "$report_file"
    echo "✓ Report written to $report_file"
    ;;
  help|*)
    echo "Usage: $0 <command> [since]"
    echo "  collect [since]  — collect data from git"
    echo "  stocks           — measure stocks"
    echo "  flows            — measure flows"
    echo "  feedback         — assess feedback loops"
    echo "  complexity       — complexity signals"
    echo "  diagnose         — diagnose and prescribe"
    echo "  report           — generate report"
    echo ""
    echo "  [since] defaults to '30 days ago'"
    exit 0
    ;;
esac
