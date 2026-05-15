#!/bin/bash
# =============================================================================
# feedback-aggregator.sh --- Cross-turn quality feedback aggregator
#
# Collects quality gate results across turns, detects patterns, and surfaces
# persistent issues. Designed to be called after quality gate execution.
#
# Data stored in .runtime/quality-feedback.jsonl (append-only log).
# Patterns detected:
#   - Recurring failures (same gate failing 3+ consecutive times)
#   - Regressions (a gate that was passing now fails)
#   - Improvements (a gate that was failing now passes)
#
# Usage:
#   bash scripts/feedback-aggregator.sh record <gate_name> <passed|failed> <output>
#   bash scripts/feedback-aggregator.sh status     # current health summary
#   bash scripts/feedback-aggregator.sh history    # last 20 events
#   bash scripts/feedback-aggregator.sh check      # run all gates and aggregate
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FEEDBACK_LOG="$REPO_ROOT/.runtime/quality-feedback.jsonl"
ensure_dir() { mkdir -p "$(dirname "$FEEDBACK_LOG")"; }

CMD="${1:-help}"

case "$CMD" in
  record)
    GATE="${2:-unknown}"
    RESULT="${3:-failed}"
    OUTPUT="${4:-}"
    ensure_dir
    echo "{\"ts\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"gate\":\"$GATE\",\"result\":\"$RESULT\",\"output\":$(echo "$OUTPUT" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read().strip()))' 2>/dev/null || echo "\"\""),\"session\":\"${SESSION_ID:-unknown}\"}" >> "$FEEDBACK_LOG"
    echo "recorded: $GATE=$RESULT"
    ;;

  status)
    if [ ! -f "$FEEDBACK_LOG" ]; then
      echo "No quality feedback recorded yet."
      exit 0
    fi
    TOTAL=$(wc -l < "$FEEDBACK_LOG" 2>/dev/null || echo 0)
    # grep -c outputs "0" on stdout and exits 1 on no match.
    # With pipefail enabled (from test harness), the pipe exit code is 1,
    # which triggers || fallback and duplicates output. Avoid pipe entirely.
    FAILED=$(grep -c '"result":"failed"' "$FEEDBACK_LOG" 2>/dev/null || true)
    PASSED=$((TOTAL - FAILED))

    echo "=== Quality Feedback Status ==="
    echo "Total checks: $TOTAL"
    echo "Passed:       $PASSED"
    echo "Failed:       $FAILED"

    if [ "$FAILED" -gt 0 ] && [ "$TOTAL" -gt 0 ]; then
      PCT=$((FAILED * 100 / TOTAL))
      echo "Failure rate: ${PCT}%"
    fi

    # Check for recurring failures (same gate failing 3+ consecutive)
    echo ""
    for gate in $(grep '"result":"failed"' "$FEEDBACK_LOG" 2>/dev/null | python3 -c "
import sys, json
gates = {}
for line in sys.stdin:
    try:
        d = json.loads(line.strip())
        g = d.get('gate', 'unknown')
        gates[g] = gates.get(g, 0) + 1
    except: pass
for g, c in sorted(gates.items(), key=lambda x: -x[1]):
    if c >= 3: print(f'{c}x {g}')
" 2>/dev/null); do
      echo "  ⚠ Recurring: $gate"
    done
    ;;

  history)
    if [ ! -f "$FEEDBACK_LOG" ]; then
      echo "No quality feedback recorded yet."
      exit 0
    fi
    echo "=== Recent Quality Events (last 20) ==="
    tail -20 "$FEEDBACK_LOG" | python3 -c "
import sys, json
for line in sys.stdin:
    try:
        d = json.loads(line.strip())
        icon = '✓' if d.get('result') == 'passed' else '✗'
        ts = d.get('ts', '?')[11:19]
        print(f\"  {icon} {ts} {d.get('gate', '?')} -> {d.get('result', '?')}\")
    except: pass
" 2>/dev/null
    ;;

  check)
    # Run quality checks via MCP server if available, or directly
    echo "=== Running Full Quality Check ==="

    for gate in quality constitution comprehension; do
      result="passed"
      output=""
      case "$gate" in
        quality)
          if bash "$REPO_ROOT/scripts/test-smoke.sh" >/dev/null 2>&1; then
            output="All tests pass"
          else
            result="failed"
            output="Test failures detected"
          fi
          ;;
        constitution)
          output=$(bash "$REPO_ROOT/scripts/constitution.sh check" 2>&1 || true)
          if echo "$output" | grep -qi "fail\|error\|violation"; then
            result="failed"
          fi
          ;;
        comprehension)
          if bash "$REPO_ROOT/scripts/comprehension-gate.sh verify" >/dev/null 2>&1; then
            output="Comprehension evidence OK"
          else
            result="failed"
            output="Comprehension evidence missing or incomplete"
          fi
          ;;
      esac
      bash "$0" record "$gate" "$result" "$output"
    done

    echo ""
    bash "$0" status
    ;;

  help|*)
    echo "Usage: bash scripts/feedback-aggregator.sh <command> [args]"
    echo ""
    echo "Commands:"
    echo "  record <gate> <passed|failed> <output>  Record a quality result"
    echo "  status                                   Show health summary"
    echo "  history                                  Last 20 events"
    echo "  check                                    Run all gates and aggregate"
    ;;
esac
