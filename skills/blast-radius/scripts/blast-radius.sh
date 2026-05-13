#!/usr/bin/env bash
# Blast radius — map the impact surface of changes before merging.
# Usage: bash ./scripts/blast-radius.sh <command> [args]
set -euo pipefail

case "${1:-help}" in
  diff)
    PR="${2:-}"
    if [ -n "$PR" ]; then
      gh pr diff "$PR" 2>/dev/null || echo "No PR $PR found"
    else
      git diff main...HEAD 2>/dev/null || git diff HEAD~1..HEAD
    fi
    ;;
  intent)
    echo "# Change Intent"
    echo "State the change goal in 1-2 sentences:"
    echo "${2:-<edit this with intent>}"
    ;;
  map)
    shift 2>/dev/null || true
    if [ $# -eq 0 ]; then
      echo "Usage: $0 map <files...>" >&2
      exit 1
    fi
    echo "# Impact Surface"
    for f in "$@"; do
      echo "## $f"
      if [ -f "$f" ]; then
        echo "- Lines: $(wc -l < "$f")"
        echo "- Modified: $(stat --format='%y' "$f" 2>/dev/null || echo 'N/A')"
      fi
      # Find dependent files
      deps=$(grep -rl "$(basename "$f" .py)" --include='*.py' --include='*.ts' --include='*.js' . 2>/dev/null | grep -v '.git/' | grep -v "$f" | head -5 || true)
      if [ -n "$deps" ]; then
        echo "- Dependents:"
        echo "$deps" | sed 's/^/    -> /'
      fi
    done
    ;;
  risk)
    level="${2:-medium}"
    echo "# Risk Assessment"
    echo "Risk level: $(echo "$level" | tr '[:lower:]' '[:upper:]')"
    case "$level" in
      low) echo "Cosmetic, isolated leaf, new code, or full coverage." ;;
      medium) echo "Shared utilities, API routes, 3+ files, or partial coverage. Test specific flows." ;;
      high) echo "Auth/payments, DB migrations, API contracts, or zero coverage. Test everything." ;;
    esac
    ;;
  blindspots)
    echo "# Blind Spots (Static analysis blind spots)"
    echo "Check for:"
    echo "- Obscurity: env vars, feature flags, runtime values"
    echo "- Hidden deps: event emitters, pub/sub, webhooks"
    echo "- Amplification: external API consumers, shared DB tables"
    ;;
  checklist)
    echo "# Verification Checklist"
    echo "□ [page/flow] — [what to verify] — [why it might break]"
    echo ""
    echo "Include: happy paths, edge cases, regressions, blind spot items."
    ;;
  help|*)
    echo "Usage: $0 <command> [args]"
    echo "  diff [pr]       — get the diff"
    echo "  intent \"<text>\" — summarize intent"
    echo "  map <files...>  — map impact surface"
    echo "  risk <level>    — assess risk (low/medium/high)"
    echo "  blindspots      — identify blind spots"
    echo "  checklist       — verification checklist"
    exit 0
    ;;
esac
