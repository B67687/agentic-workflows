#!/usr/bin/env bash
# Companion script for tap-audit skill
# Assess how ready a repo is for autonomous agent work
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [args]

Commands:
  check-existing     Check if audit exists and is current
  scan               Scan repository for key config files
  dimensions         Assess all 6 harness dimensions
  score              Calculate readiness score (FULL/PARTIAL/MINIMAL)
  leverage           Identify top leverage points
  report             Generate summary report
  help               Show this help
EOF
}

cmd="${1:-help}"
shift 2>/dev/null || true

case "$cmd" in
  check-existing)
    echo "★ Checking Existing Audit ───────────────────────"
    if [[ -f .tap/tap-audit.md ]]; then
      echo "Audit exists. Checking age..."
      mtime=$(stat -c %Y .tap/tap-audit.md 2>/dev/null || stat -f %m .tap/tap-audit.md)
      now=$(date +%s)
      days_old=$(( (now - mtime) / 86400 ))
      echo "Age: ${days_old} days"
      if git rev-parse --git-dir &>/dev/null 2>&1; then
        echo "Commits since: $(git log --oneline --since="$(date -d @"$mtime" '+%Y-%m-%d')" 2>/dev/null | wc -l)"
      fi
    else
      echo "No existing audit found at .tap/tap-audit.md"
    fi
    echo "─────────────────────────────────────────────────"
    ;;
  scan)
    echo "★ Scanning Repository ───────────────────────────"
    for f in ".claude/settings.json" ".claude/settings.local.json" ".mcp.json" "CLAUDE.md" "AGENTS.md" "package.json" "tsconfig.json" ".github/workflows/"; do
      if [[ -e "$f" || -d "$f" ]]; then
        echo "  ✓ $f"
      else
        echo "  ✗ $f (not found)"
      fi
    done
    echo "─────────────────────────────────────────────────"
    ;;
  dimensions)
    echo "★ Agent Harness Dimensions ──────────────────────"
    echo ""
    echo "1. Documentation: CLAUDE.md, AGENTS.md, ADRs"
    echo "2. Strategic Context: .tap/product.md"
    echo "3. MCP Servers: .mcp.json"
    echo "4. Skills: skills/ available"
    echo "5. CLI Tools: package manager, test runner, linter"
    echo "6. Permissions: .claude/settings.json"
    echo "7. Test Infrastructure: unit, integration, e2e"
    echo "─────────────────────────────────────────────────"
    ;;
  score)
    echo "★ Readiness Score ───────────────────────────────"
    echo ""
    echo "FULL:    Agent can implement, test, verify e2e. All MCP/CLI configured."
    echo "PARTIAL: Agent can implement + some tests. Some gaps."
    echo "MINIMAL: Read/write code only. No tests, no MCP, thin CLAUDE.md."
    echo "─────────────────────────────────────────────────"
    ;;
  leverage)
    echo "★ Leverage Points ──────────────────────────────"
    echo ""
    echo "Find 3-5 leverage points. Each answers:"
    echo "what's slowing delivery OR letting defects through?"
    echo ""
    echo "### N. [Description] -> [Consequence]"
    echo "- Symptom: [observable problem]"
    echo "- Why it costs: [concrete impact]"
    echo "- Fix: [cheapest intervention + effort]"
    echo "─────────────────────────────────────────────────"
    ;;
  report)
    echo "★ Audit View ────────────────────────────────────"
    echo "[repo name] --- [FULL/PARTIAL/MINIMAL]"
    echo "  ├─ [top feedback loop finding]"
    echo "  ├─ [#1 leverage point]"
    echo "  └─ [cheapest fix to start with]"
    echo "─────────────────────────────────────────────────"
    ;;
  help|*)
    usage
    ;;
esac
