#!/usr/bin/env bash
# Companion script for blast-radius skill
# Analyze impact surface of PR changes before merging
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [args]

Commands:
  diff [pr]        Get the diff (PR number, branch, or default current)
  intent <text>    Summarize change intent
  map <files>      Map impact surface from changed files
  risk [level]     Assess risk level (LOW/MEDIUM/HIGH)
  blindspots       Identify blind spots (MEDIUM/HIGH only)
  checklist        Generate verification checklist
  report           Present findings with signature block
  help             Show this help
EOF
}

cmd="${1:-help}"
shift 2>/dev/null || true

case "$cmd" in
  diff)
    pr="${1:-}"
    if [[ -n "$pr" ]]; then
      echo "gh pr diff $pr"
    elif git rev-parse --git-dir &>/dev/null 2>&1; then
      echo "git diff main...HEAD"
    else
      echo "No PR or branch specified"
    fi
    ;;
  intent)
    echo "★ Intent Summary ───────────────────────────────"
    echo "What this change is TRYING to do (1-2 sentences):"
    echo "${1:-}"
    echo "─────────────────────────────────────────────────"
    ;;
  map)
    echo "★ Impact Surface ───────────────────────────────"
    echo "Changed files: $*"
    echo ""
    echo "Direct changes:"
    for f in "$@"; do
      echo "  - $f"
    done
    echo ""
    echo "Dependents (trace imports/callers):"
    echo "  [grep for imports, function calls, component usage]"
    echo ""
    echo "Shared state to check:"
    echo "  □ DB schema changes (migrations)"
    echo "  □ API contract changes (request/response)"
    echo "  □ Config, env vars, feature flags"
    echo "  □ Global state, context providers"
    echo "  □ CSS/style changes affecting multiple components"
    echo ""
    echo "Test coverage gaps:"
    echo "  □ Which changed paths have tests?"
    echo "  □ What's NOT tested that could break?"
    echo "─────────────────────────────────────────────────"
    ;;
  risk)
    level="${1:-}"
    echo "★ Risk Assessment ───────────────────────────────"
    case "$level" in
      LOW)
        echo "Merge confidently."
        echo "Cosmetic/isolated/new code with full coverage."
        ;;
      MEDIUM)
        echo "Test specific flows."
        echo "Shared utilities, API routes, 3+ file changes, partial coverage."
        ;;
      HIGH)
        echo "Test everything on the checklist."
        echo "Auth/payments/mutations, DB migrations, API contracts, zero coverage."
        ;;
      *)
        echo "Levels: LOW (merge confidently), MEDIUM (test flows), HIGH (test everything)"
        ;;
    esac
    echo "─────────────────────────────────────────────────"
    ;;
  blindspots)
    echo "★ Blind Spots ───────────────────────────────────"
    echo "What static analysis CAN'T see:"
    echo ""
    echo "Obscurity (behavior depends on info not in diff):"
    echo "  □ Env vars, config files, feature flags, runtime values"
    echo "  □ Conditional logic driven by external state"
    echo ""
    echo "Hidden dependencies (not traceable via static imports):"
    echo "  □ Dynamic dispatch, event emitters, pub/sub"
    echo "  □ Webhook contracts, callback registrations"
    echo "  □ String-based lookups, reflection"
    echo ""
    echo "Change amplification (unknown consumers):"
    echo "  □ API response shapes consumed externally"
    echo "  □ Shared DB tables read by other services"
    echo "  □ Published events consumed by unknown subscribers"
    echo "─────────────────────────────────────────────────"
    ;;
  checklist)
    echo "★ Verification Checklist ────────────────────────"
    echo ""
    echo "□ [page/flow] --- [what to verify] --- [why it might break]"
    echo "□ [page/flow] --- [what to verify] --- [why it might break]"
    echo "□ [page/flow] --- [what to verify] --- [why it might break]"
    echo ""
    echo "Prioritize: most likely to break first, most damaging if broken second."
    echo "─────────────────────────────────────────────────"
    ;;
  report)
    echo "★ Blast Radius ──────────────────────────────────"
    echo "Risk: [LOW/MEDIUM/HIGH]"
    echo "Intent: [1-2 sentence summary]"
    echo "  ├─ [top impact finding]"
    echo "  └─ [key verification needed]"
    echo "─────────────────────────────────────────────────"
    ;;
  help|*)
    usage
    ;;
esac
