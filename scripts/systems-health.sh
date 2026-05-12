#!/usr/bin/env bash
# Companion script for systems-health skill
# Measure dev system health via stocks, flows, feedback loops
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [args]

Commands:
  collect [dir]    Collect data from git, GitHub, CI
  stocks           Measure stocks (backlog, PRs, bugs, tests)
  flows            Measure flows (cycle time, review time, deploy freq)
  feedback         Assess feedback loops (CI, review, bug triage)
  complexity       Measure complexity signals (change amplification, churn)
  diagnose         Diagnose and prescribe fixes
  report           Generate health report
  help             Show this help
EOF
}

cmd="${1:-help}"
shift 2>/dev/null || true

case "$cmd" in
  collect)
    dir="${1:-.}"
    echo "★ Collecting Data ──────────────────────────────"
    if git -C "$dir" rev-parse --git-dir &>/dev/null 2>&1; then
      echo "Commits (30d): $(git -C "$dir" log --oneline --since="30 days ago" 2>/dev/null | wc -l)"
      echo "Commits (90d): $(git -C "$dir" log --oneline --since="90 days ago" 2>/dev/null | wc -l)"
      echo "Contributors (30d):"
      git -C "$dir" shortlog -sn --no-merges --since="30 days ago" 2>/dev/null
    else
      echo "Not a git repo"
    fi
    if command -v gh &>/dev/null; then
      echo "Open PRs: $(gh pr list --state open --limit 100 2>/dev/null | wc -l)"
      echo "Open issues: $(gh issue list --state open --limit 100 2>/dev/null | wc -l)"
    fi
    echo "─────────────────────────────────────────────────"
    ;;
  stocks)
    echo "★ Stocks ────────────────────────────────────────"
    echo "| Stock | Measure | Healthy | Current | Trend |"
    echo "|-------|---------|---------|---------|-------|"
    echo "| Backlog | open issues | Stable/shrinking | | ─/▲/▼ |"
    echo "| Open PRs | open PR count | <5, oldest <3d | | ─/▲/▼ |"
    echo "| Open bugs | bug issues | Stable/shrinking | | ─/▲/▼ |"
    echo "| Test count | test runner | Growing | | ─/▲/▼ |"
    echo "─────────────────────────────────────────────────"
    ;;
  flows)
    echo "★ Flows ─────────────────────────────────────────"
    echo "| Flow | How to measure | What it tells |"
    echo "|------|----------------|---------------|"
    echo "| Stories in | Issues created/week | Demand |"
    echo "| Stories out | PRs merged/week | Throughput |"
    echo "| Cycle time | PR open→merge (median) | Speed |"
    echo "| Review time | PR open→review (median) | Bottleneck |"
    echo "| Bug inflow | Bugs created/week | Quality |"
    echo "| Deploy freq | Deploys/week | Delivery |"
    echo "─────────────────────────────────────────────────"
    ;;
  feedback)
    echo "★ Feedback Loops ───────────────────────────────"
    echo ""
    echo "Balancing (self-correcting):"
    echo "  CI gate:        CI fails → fix → passes? or merged anyway?"
    echo "  Code review:    Catches issues? or rubber-stamped?"
    echo "  Bug triage:     Found → prioritized → fixed? or accumulates?"
    echo "  Test failures:  Investigate → fix? or disabled/ignored?"
    echo ""
    echo "Reinforcing (amplifying):"
    echo "  Test coverage:  Good tests → catch bugs → more tests?"
    echo "  Documentation:  Good docs → agents work → docs updated?"
    echo "  Small batches:  Small PRs → fast review → more small PRs?"
    echo "─────────────────────────────────────────────────"
    ;;
  complexity)
    echo "★ Complexity Signals ────────────────────────────"
    echo ""
    echo "| Signal | Measure | Threshold |"
    echo "|--------|---------|-----------|"
    echo "| Change amp. | Median files/commit | Trending up? |"
    echo "| Shotgun surgery | % commits 5+ files/3+ dirs | >20%? |"
    echo "| Hot churn | Large files with high churn | Any? |"
    echo "| Unknown unknowns | % merged PRs with no test change | Trending up? |"
    echo "─────────────────────────────────────────────────"
    ;;
  diagnose)
    echo "★ Diagnosis ─────────────────────────────────────"
    echo ""
    echo "Diagnosis: [what's sick]"
    echo "Evidence:  [data that proves it]"
    echo "Impact:    [how it slows delivery or hurts quality]"
    echo "Rx:        [cheapest intervention]"
    echo "─────────────────────────────────────────────────"
    ;;
  report)
    echo "★ Systems Health ────────────────────────────────"
    echo "[repo] — [Healthy / N problems / Backing up]"
    echo "  ├─ [most impactful finding]"
    echo "  └─ [cheapest fix]"
    echo "─────────────────────────────────────────────────"
    ;;
  help|*)
    usage
    ;;
esac
