#!/usr/bin/env bash
# Companion script for retrospective skill
# Event-driven retro focused on improving agent autonomy
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [args]

Commands:
  identify          Identify the trigger event (feature/incident/pattern/project)
  gather <trigger>  Gather evidence (git log, PRs, issues)
  analyze           Analyze through autonomy lens (context/harness/feedback/design/scope)
  capture <finding> Capture a learning
  ticket <learning> Create improvement ticket
  append <learning> Append to .tap/learnings.md
  help              Show this help
EOF
}

cmd="${1:-help}"
shift 2>/dev/null || true

case "$cmd" in
  identify)
    echo "★ Trigger Identification ────────────────────────"
    echo ""
    echo "* Feature shipped -> analyze full cycle: ticket to merge"
    echo "* Incident -> what broke, detected, fixed"
    echo "* Agent failure pattern -> rejected PRs, rework cycles"
    echo "* Project wrap -> full engagement"
    echo "* Ad hoc -> user specifies what to reflect on"
    echo "─────────────────────────────────────────────────"
    ;;
  gather)
    trigger="${1:-}"
    echo "★ Gathering Evidence for: $trigger ─────────────"
    if git rev-parse --git-dir &>/dev/null 2>&1; then
      echo "Recent commits:"
      git log --oneline -10
    fi
    if command -v gh &>/dev/null; then
      echo "Merged PRs (recent):"
      gh pr list --state merged --limit 5 --json number,title,mergedAt 2>/dev/null || echo "  (gh not logged in)"
    fi
    echo ""
    echo "Also check: .tap/system-health.md, .tap/tap-audit.md, .tap/learnings.md"
    echo "─────────────────────────────────────────────────"
    ;;
  analyze)
    echo "★ Autonomy Lens Analysis ────────────────────────"
    echo ""
    echo "| Gap | Agent lacked... | Check |"
    echo "|-----|-----------------|-------|"
    echo "| Context | Information | Missing CLAUDE.md? Missing ADR? |"
    echo "| Harness | Tools/access | Missing MCP? Missing CLI? |"
    echo "| Feedback | Verification | No tests? No browser QA? |"
    echo "| Design | Code complexity | God file? High coupling? |"
    echo "| Scope | Boundaries | No AGENTS.md? Too ambiguous? |"
    echo "─────────────────────────────────────────────────"
    ;;
  capture)
    finding="${1:-}"
    echo "★ Learning ──────────────────────────────────────"
    echo "[$(date +%F)] --- [trigger]"
    echo "- $finding"
    echo "  -> [root cause category] -> [specific fix]"
    echo "─────────────────────────────────────────────────"
    ;;
  ticket)
    learning="${1:-}"
    echo "★ Improvement Ticket ────────────────────────────"
    echo ""
    echo "Category: [raises readiness / prevents repeat / reduces complexity]"
    echo "Action: $learning"
    echo "Label: retro-improvement"
    echo ""
    echo "Run: gh issue create --label retro-improvement --title \"$learning\""
    echo "─────────────────────────────────────────────────"
    ;;
  append)
    echo "★ Append to .tap/learnings.md ───────────────────"
    echo "[$(date +%F)] --- [trigger]"
    echo "- [what happened] -> [gap type] -> [specific fix]"
    echo "─────────────────────────────────────────────────"
    ;;
  help|*)
    usage
    ;;
esac
