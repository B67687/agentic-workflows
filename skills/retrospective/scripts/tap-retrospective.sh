#!/usr/bin/env bash
# Retrospective --- reflect on what happened and improve agent autonomy.
# Usage: bash ./scripts/tap-retrospective.sh <command> [args]
set -euo pipefail

TAP_DIR=".tap"
mkdir -p "$TAP_DIR"

case "${1:-help}" in
  identify)
    echo "### Retrospective Trigger"
    echo ""
    echo "Possible triggers (choose one):"
    echo "  - feature-shipped"
    echo "  - incident"
    echo "  - agent-failure-pattern"
    echo "  - project-wrap"
    echo "  - ad-hoc"
    echo ""
    echo "Current: ${2:-<specify trigger>}"
    echo "Suggested evidence to gather:"
    echo "  git log --since=\"[period]\""
    echo "  gh pr list --state merged --search"
    echo "  gh pr list --state closed --search"
    ;;
  gather)
    trigger="${2:-recent}"
    echo "## Evidence: $trigger"
    echo ""
    echo "### Recent commits"
    git log --oneline -20 2>/dev/null || echo "(no commits)"
    echo ""
    echo "### Unmerged changes"
    git diff --stat HEAD~5..HEAD 2>/dev/null || true
    echo ""
    echo "### Recent history"
    if [ -f "$TAP_DIR/learnings.md" ]; then
      echo "Existing learnings found ($(wc -l < "$TAP_DIR/learnings.md") lines)"
    else
      echo "No existing learnings file"
    fi
    ;;
  analyze)
    echo "## Autonomy Gap Analysis"
    echo ""
    echo "| Gap | Agent lacked... | Check |"
    echo "|-----|-----------------|-------|"
    echo "| Context | Information | □ CLAUDE.md, □ ADR, □ clear AC |"
    echo "| Harness | Tools/access | □ MCP, □ CLI, □ skill, □ permissions |"
    echo "| Feedback | Verification | □ tests, □ browser QA, □ CI catch |"
    echo "| Design | Code complexity | □ god file, □ high coupling |"
    echo ""
    echo "For each gap found, ask:"
    echo "\"What's the cheapest change to an agent-readable file that prevents this gap next time?\""
    ;;
  capture)
    finding="${2:-<learning>}"
    TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    echo "## Learning Captured"
    echo "- $finding ($TIMESTAMP)"
    echo ""
    echo "Would append to: $TAP_DIR/learnings.md"
    ;;
  ticket)
    learning="${2:-<learning>}"
    echo "## Improvement Ticket"
    echo ""
    echo "**What happened:** $learning"
    echo "**Fix:** <one change that prevents recurrence>"
    echo "**Target file:** <path>"
    echo "**Priority:** P1"
    ;;
  append)
    learning="${2:-<learning>}"
    TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    echo "# Learning ($TIMESTAMP)" >> "$TAP_DIR/learnings.md"
    echo "- $learning" >> "$TAP_DIR/learnings.md"
    echo "" >> "$TAP_DIR/learnings.md"
    echo "✓ Appended to $TAP_DIR/learnings.md"
    ;;
  help|*)
    echo "Usage: $0 <command> [args]"
    echo "  identify              --- identify the trigger"
    echo "  gather \"<trigger>\"    --- gather evidence"
    echo "  analyze               --- analyze through autonomy lens"
    echo "  capture \"<finding>\"   --- capture a learning"
    echo "  ticket \"<learning>\"   --- create improvement ticket"
    echo "  append \"<learning>\"   --- append to .tap/learnings.md"
    exit 0
    ;;
esac
