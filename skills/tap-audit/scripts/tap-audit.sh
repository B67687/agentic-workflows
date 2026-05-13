#!/usr/bin/env bash
# TAP audit — assess repo readiness for autonomous agent work.
# Usage: bash ./scripts/tap-audit.sh <command>
set -euo pipefail

TAP_DIR=".tap"
mkdir -p "$TAP_DIR"

case "${1:-help}" in
  check-existing)
    echo "# Existing Audit Check"
    if [ -f "$TAP_DIR/tap-audit.md" ]; then
      last_run=$(grep -i 'last run\|generated\|^# ' "$TAP_DIR/tap-audit.md" 2>/dev/null | head -1)
      echo "Existing audit found: ${last_run:-unknown date}"
      echo "Run 'scan' for full or 'dimensions' for targeted check"
    else
      echo "No existing audit at $TAP_DIR/tap-audit.md"
      echo "Run 'scan' to create one"
    fi
    ;;
  scan)
    echo "# Repo Scan"
    echo ""
    echo "## Config Files"
    for f in ".claude/settings.json" "CLAUDE.md" "AGENTS.md" "session-state.json" "package.json" ".gitignore" "README.md"; do
      if [ -f "$f" ]; then
        echo "  ✓ $f ($(wc -l < "$f") lines)"
      else
        echo "  ✗ $f (missing)"
      fi
    done
    echo ""
    echo "## MCP Servers"
    if [ -f ".claude/settings.json" ]; then
      count=$(grep -c 'mcpServers\|mcp_servers' .claude/settings.json 2>/dev/null || echo 0)
      echo "  $count MCP config entries found"
    fi
    echo ""
    echo "## Tests"
    ts=$(find . -name 'test_*.py' -o -name '*.test.ts' -name '*.test.js' 2>/dev/null | grep -v '.git/' | wc -l)
    echo "  $ts test files"
    echo ""
    echo "## Scripts"
    sc=$(find . -name '*.sh' -not -path './.git/*' | wc -l)
    echo "  $sc shell scripts"
    ;;
  dimensions)
    echo "# Harness Dimensions"
    echo "| Dimension | Status | Notes |"
    echo "|-----------|--------|-------|"
    echo "| Documentation | $( [ -f 'CLAUDE.md' ] && echo '✓' || echo '✗' ) | Agent instructions |"
    echo "| Git config | $( git config user.name >/dev/null 2>&1 && echo '✓' || echo '✗' ) | Identity configured |"
    echo "| CI/CD | $( [ -f '.github/workflows' ] && echo '✓' || echo '✗' ) | Automation |"
    echo "| Tests | $( ls scripts/test-*.sh >/dev/null 2>&1 && echo '✓' || echo '✗' ) | Smoke suite |"
    echo "| MCP | $( [ -f '.claude/settings.json' ] && grep -q 'mcpServers' .claude/settings.json 2>/dev/null && echo '✓' || echo '✗' ) | Agent tools |"
    echo "| Lint | $( which shellcheck >/dev/null 2>&1 && echo '✓' || echo '✗' ) | Code quality |"
    ;;
  score)
    echo "# Readiness Score"
    echo ""
    total=0
    pass=0
    for f in "CLAUDE.md" "AGENTS.md" "session-state.json" ".gitignore"; do
      total=$((total + 1))
      if [ -f "$f" ]; then
        pass=$((pass + 1))
      fi
    done
    [ -f ".claude/settings.json" ] && grep -q 'mcpServers' .claude/settings.json 2>/dev/null && pass=$((pass + 1))
    total=$((total + 1))
    [ -f "scripts/test-smoke.sh" ] && pass=$((pass + 1))
    total=$((total + 1))
    
    pct=$((pass * 100 / total))
    echo "Score: $pass/$total ($pct%)"
    echo ""
    if [ "$pct" -ge 80 ]; then
      echo "Assessment: Ready for autonomous work"
    elif [ "$pct" -ge 50 ]; then
      echo "Assessment: Needs setup — see gaps above"
    else
      echo "Assessment: Early stage — significant setup needed"
    fi
    ;;
  leverage)
    echo "# Leverage Points"
    echo ""
    echo "Highest-impact improvements:"
    echo "1. Documentation (CLAUDE.md + AGENTS.md) — agent context"
    echo "2. MCP server config — agent capabilities"
    echo "3. Test suite — agent feedback loop"
    echo "4. CI/CD pipeline — quality gate"
    echo "5. Skill definitions — agent workflows"
    ;;
  report)
    report_file="$TAP_DIR/tap-audit.md"
    TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    {
      echo "# TAP Audit Report"
      echo ""
      echo "**Generated:** $TIMESTAMP"
      echo "**Repo:** $(basename "$(pwd)")"
      echo ""
      echo "## Config Check"
      for f in "CLAUDE.md" "AGENTS.md" "session-state.json" ".gitignore"; do
        if [ -f "$f" ]; then
          echo "- ✓ \`$f\`"
        else
          echo "- ✗ \`$f\` (missing)"
        fi
      done
      echo ""
      echo "## Repository Stats"
      echo "- Tracked files: $(git ls-files | wc -l)"
      echo "- Shell scripts: $(find . -name '*.sh' -not -path './.git/*' | wc -l)"
      echo "- Skills: $(ls -d skills/*/ 2>/dev/null | wc -l)"
    } > "$report_file"
    echo "✓ Report written to $report_file"
    ;;
  help|*)
    echo "Usage: $0 <command>"
    echo "  check-existing  — check if existing audit is current"
    echo "  scan            — scan for key config files"
    echo "  dimensions      — assess harness dimensions"
    echo "  score           — calculate readiness score"
    echo "  leverage        — identify leverage points"
    echo "  report          — generate report"
    exit 0
    ;;
esac
