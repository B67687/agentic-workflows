#!/usr/bin/env bash
# =============================================================================
# context-pressure.sh --- Context window pressure monitoring
#
# Guides session lifecycle decisions based on context window usage.
# Takes the context percentage (visible in the OpenCode UI at the top)
# and provides prescriptive guidance.
#
# Usage:
#   bash scripts/tools/context-pressure.sh               # Print full guidelines
#   bash scripts/tools/context-pressure.sh <percent>     # Status + guidance
#   bash scripts/tools/context-pressure.sh <percent> --brief  # Compact output
#
# Examples:
#   bash scripts/tools/context-pressure.sh 18
#   bash scripts/tools/context-pressure.sh 42 --brief
#
# Thresholds:
#   0-15%   Green  — Full capacity, continue normally
#   15-25%  Yellow — Getting warm, consider planning next handover
#   25-40%  Orange — Plan checkpoint in next 3-5 turns
#   40-60%  Red    — Checkpoint NOW, handover recommended
#   60-80%  Critical — Immediate handover, quality at risk
#   80%+    Fatal  — Stop, checkpoint, force fresh session
# =============================================================================
set -euo pipefail

usage() {
  cat <<EOF
Usage: bash scripts/tools/context-pressure.sh [percent] [--brief]

If called without arguments, prints the full guidelines table.
If called with a percentage, shows current status + action.

Examples:
  bash scripts/tools/context-pressure.sh 18    # "I'm at 18%"
  bash scripts/tools/context-pressure.sh       # Full reference

Thresholds:
  0-15%   🟢 Green    — Full capacity. Continue without worry.
  15-25%  🟡 Yellow   — Getting warm. Plan next handover within 5-10 turns.
  25-40%  🟠 Orange   — Warm. Checkpoint within 3-5 turns. No new broad tasks.
  40-60%  🔴 Red      — Hot. Checkpoint NOW. Handover recommended.
  60-80%  🚨 Critical — Immediate handover. Quality will degrade rapidly.
  80%+    💀 Fatal    — STOP. Checkpoint. Force fresh session immediately.
EOF
}

# ── Full reference mode ──
if [[ $# -eq 0 ]]; then
  echo "=== Context Pressure Reference ==="
  echo ""
  echo "Context % is visible in the OpenCode UI (top bar)."
  echo "Use: bash scripts/tools/context-pressure.sh <percent>"
  echo ""
  echo "  Zone       %        Signal                          Action"
  echo "  ─────────────────────────────────────────────────────────────────"
  echo "  🟢 Green    0-15%   Full capacity                   Continue normally"
  echo "  🟡 Yellow  15-25%   Getting warm                    Plan handover in 5-10 turns"
  echo "  🟠 Orange  25-40%   Warm                            Checkpoint in 3-5 turns. No new broad tasks."
  echo "  🔴 Red     40-60%   Hot                             Checkpoint NOW. Handover recommended."
  echo "  🚨 Critical 60-80%  Overheated                      Immediate handover. Quality degrading."
  echo "  💀 Fatal   80%+     Saturated                       STOP. Force fresh session."
  echo ""
  echo "  At 18-20% (your current zone):"
  echo "    - Still safe for focused work"
  echo "    - AVOID: large file reads, broad searches, multi-phase planning"
  echo "    - PREFER: single concrete tasks, direct execution, narrow scope"
  echo "    - Plan your next handover point before crossing 25%"
  echo ""
  echo "  Handover template:"
  echo "    bash ./scripts/checkpoint-commit.sh -m \"<summary>\""
  echo "    # Then start a fresh session"
  exit 0
fi

# ── Parse arguments ──
PERCENT=""
BRIEF=false
for arg in "$@"; do
  case "$arg" in
  --brief | -b) BRIEF=true ;;
  --help | -h)
    usage
    exit 0
    ;;
  *)
    if [[ "$arg" =~ ^[0-9]+$ ]]; then
      PERCENT="$arg"
    fi
    ;;
  esac
done

if [[ -z "$PERCENT" ]]; then
  echo "ERROR: provide a percentage (0-100) or run without args for reference" >&2
  usage >&2
  exit 1
fi

# ── Determine zone ──
ZONE=""
COLOR=""
RECOMMENDATION=""
CHECKPOINT_URGENCY=""
if [ "$PERCENT" -lt 15 ]; then
  ZONE="Green"
  COLOR="🟢"
  RECOMMENDATION="Continue normally. Full capacity."
  CHECKPOINT_URGENCY="not needed"
elif [ "$PERCENT" -lt 25 ]; then
  ZONE="Yellow"
  COLOR="🟡"
  RECOMMENDATION="Getting warm. Plan handover in 5-10 turns. Avoid broad searches."
  CHECKPOINT_URGENCY="plan within 5-10 turns"
elif [ "$PERCENT" -lt 40 ]; then
  ZONE="Orange"
  COLOR="🟠"
  RECOMMENDATION="Warm. Checkpoint within 3-5 turns. No new multi-phase tasks."
  CHECKPOINT_URGENCY="within 3-5 turns"
elif [ "$PERCENT" -lt 60 ]; then
  ZONE="Red"
  COLOR="🔴"
  RECOMMENDATION="Hot. Checkpoint NOW. Handover recommended. Quality may degrade."
  CHECKPOINT_URGENCY="IMMEDIATE"
elif [ "$PERCENT" -lt 80 ]; then
  ZONE="Critical"
  COLOR="🚨"
  RECOMMENDATION="Overheated. Immediate handover. Quality will degrade rapidly."
  CHECKPOINT_URGENCY="IMMEDIATE - force handover"
else
  ZONE="Fatal"
  COLOR="💀"
  RECOMMENDATION="Saturated. STOP. Checkpoint and force fresh session."
  CHECKPOINT_URGENCY="IMMEDIATE - stop all work"
fi

# ── Output ──
if $BRIEF; then
  echo "${COLOR} ${ZONE} @ ${PERCENT}% — ${RECOMMENDATION}"
else
  echo "=== Context Pressure ==="
  echo "  Usage: ${PERCENT}%"
  echo "  Zone:  ${COLOR} ${ZONE}"
  echo "  Action: ${RECOMMENDATION}"
  echo "  Checkpoint urgency: ${CHECKPOINT_URGENCY}"
  echo ""
  echo "  To checkpoint: bash ./scripts/checkpoint-commit.sh -m \"summary\""
  echo "  Then fresh:    <start new session>"
fi

# Exit with urgency code
if [ "$PERCENT" -ge 40 ]; then
  exit 2 # urgent
elif [ "$PERCENT" -ge 25 ]; then
  exit 1 # warn
else
  exit 0 # ok
fi
