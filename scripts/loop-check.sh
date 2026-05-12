#!/usr/bin/env bash
# Companion script for loop-check skill
# Assess what's needed for autonomous feedback loops
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [args]

Commands:
  workflows [dir]   Discover top workflows (binary assets, git churn, manual scripts)
  assess <wf>       Assess a workflow's loop (generator, evaluator, handoff, grading)
  rate <wf>         Rate loop: closed / open / no-loop / manual
  prescribe <wf>    Prescribe fix for non-closed loop
  report            Present findings with signature block
  help              Show this help
EOF
}

cmd="${1:-help}"
shift 2>/dev/null || true

case "$cmd" in
  workflows)
    dir="${1:-.}"
    echo "★ Discovering Workflows in ${dir} ───────────────"
    echo ""
    echo "1. Binary assets without generators:"
    find "$dir" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.svg" -o -name "*.gif" -o -name "*.pdf" \) 2>/dev/null | head -20 || echo "   (none found)"
    echo ""
    echo "2. Git history churn (files modified most):"
    if git -C "$dir" rev-parse --git-dir &>/dev/null 2>&1; then
      git -C "$dir" log --all --diff-filter=M --name-only --pretty=format: 2>/dev/null | sort | uniq -c | sort -rn | head -10
    else
      echo "   (not a git repo)"
    fi
    echo ""
    echo "3. Human-in-the-loop patterns found in scripts/docs (grep):"
    grep -rn "manually\|visually check\|inspect\|# check\|then you\|read -p" "$dir"/scripts/*.sh 2>/dev/null | head -10 || echo "   (none found)"
    ;;
  assess)
    wf="${1:-}"
    echo "★ Loop Assessment: ${wf} ────────────────────────"
    echo ""
    echo "| Element | Status | What's needed |"
    echo "|---------|--------|---------------|"
    echo "| Generator | ✓/✗ | Can agent produce the output? |"
    echo "| Evaluator | ✓/✗ | Can something else verify it? |"
    echo "| Handoff   | ✓/✗ | Can agent context-reset? |"
    echo "| Grading   | ✓/✗ | Measurable quality criteria? |"
    echo "─────────────────────────────────────────────────"
    ;;
  rate)
    wf="${1:-}"
    echo "★ Loop Rating ──────────────────────────────────"
    echo "Workflow: $wf"
    echo ""
    echo "• Closed — all 4 elements present. Agent iterates autonomously."
    echo "• Open — evaluator or grading missing. Agent produces but can't verify."
    echo "• No loop — no evaluator, no criteria. Agent guesses."
    echo "• Manual — human does this entirely by hand."
    echo "─────────────────────────────────────────────────"
    ;;
  prescribe)
    wf="${1:-}"
    echo "★ Prescription for: ${wf} ──────────────────────"
    echo ""
    echo "Skill to create: [name + description + tools needed]"
    echo "MCP to wire up: [server name + what it enables]"
    echo "Hook to add: [event + what it does]"
    echo "Tool to integrate: [CLI/API/service]"
    echo "Test to write: [kind + what it covers]"
    echo "Grading criteria: [measurable spec]"
    echo "─────────────────────────────────────────────────"
    ;;
  report)
    echo "★ Loop Check ────────────────────────────────────"
    echo "[N] workflows assessed — [N closed] / [N open] / [N manual]"
    echo "  ├─ [most impactful finding]"
    echo "  ├─ [second finding]"
    echo "  └─ [top recommendation to close a loop]"
    echo "─────────────────────────────────────────────────"
    ;;
  help|*)
    usage
    ;;
esac
