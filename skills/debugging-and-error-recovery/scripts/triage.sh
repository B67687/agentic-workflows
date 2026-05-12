#!/bin/bash
# =============================================================================
# triage.sh — Capture failure context for agent-driven debugging.
#
# Companion script for the debugging-and-error-recovery skill.
# Collects structured evidence about the most recent failure into a JSON
# artifact that agents (or humans) can use for root-cause analysis.
#
# Usage:
#   bash ./scripts/triage.sh              # capture current failure context
#   bash ./scripts/triage.sh --last-cmd   # show last command from history
#   bash ./scripts/triage.sh --dir DIR    # capture context in specific dir
#
# Output: prints JSON to stdout, also saves to .triage/latest.json
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
TRIAGE_DIR="$REPO_ROOT/.triage"
mkdir -p "$TRIAGE_DIR"

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
CAPTURE_DIR="${1:-$REPO_ROOT}"

OUTPUT_FILE="$TRIAGE_DIR/latest.json"

echo "{" > "$OUTPUT_FILE"
echo "  \"timestamp\": \"$TIMESTAMP\"," >> "$OUTPUT_FILE"
echo "  \"capture_dir\": \"$CAPTURE_DIR\"," >> "$OUTPUT_FILE"
echo "  \"hostname\": \"$(hostname 2>/dev/null || echo 'unknown')\"," >> "$OUTPUT_FILE"
echo "  \"cwd\": \"$(pwd)\"," >> "$OUTPUT_FILE"

# --- Git state ---
echo "  \"git\": {" >> "$OUTPUT_FILE"
echo "    \"branch\": \"$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown')\"," >> "$OUTPUT_FILE"
echo "    \"sha\": \"$(git rev-parse HEAD 2>/dev/null || echo 'unknown')\"," >> "$OUTPUT_FILE"
echo "    \"dirty\": $(git status --short 2>/dev/null | wc -l | tr -d ' ')" >> "$OUTPUT_FILE"
echo "  }," >> "$OUTPUT_FILE"

# --- Most recent error (from .triage/errors.log if exists) ---
if [ -f "$TRIAGE_DIR/errors.log" ]; then
  RECENT_ERROR=$(tail -20 "$TRIAGE_DIR/errors.log" | python3 -c "import sys, json; print(json.dumps(sys.stdin.read()))" 2>/dev/null || echo "\"\"")
  echo "  \"recent_errors\": $RECENT_ERROR," >> "$OUTPUT_FILE"
else
  echo "  \"recent_errors\": null," >> "$OUTPUT_FILE"
fi

# --- Recent commands from bash history (if available) ---
if [ -f "$HOME/.bash_history" ]; then
  LAST_CMDS=$(tail -10 "$HOME/.bash_history" 2>/dev/null | python3 -c "
import sys, json
cmds = [l.strip() for l in sys.stdin if l.strip()]
print(json.dumps(cmds))
" 2>/dev/null || echo "[]")
  echo "  \"recent_commands\": $LAST_CMDS," >> "$OUTPUT_FILE"
else
  echo "  \"recent_commands\": []," >> "$OUTPUT_FILE"
fi

# --- Key env vars ---
echo "  \"env\": {" >> "$OUTPUT_FILE"
for var in PATH HOME SHELL TERM; do
  val="${!var:-}"
  echo "    \"$var\": \"${val//\"/\\\"}\"," >> "$OUTPUT_FILE" 2>/dev/null || true
done
echo "    \"_pwd\": \"$(pwd)\"" >> "$OUTPUT_FILE"
echo "  }," >> "$OUTPUT_FILE"

# --- Uncommitted changes summary ---
DIRTY_OUTPUT=$(git status --short 2>/dev/null | head -20 | python3 -c "
import sys, json
lines = [l.strip() for l in sys.stdin if l.strip()]
print(json.dumps(lines))
" 2>/dev/null || echo "[]")
echo "  \"uncommitted_changes\": $DIRTY_OUTPUT" >> "$OUTPUT_FILE"

echo "}" >> "$OUTPUT_FILE"

# Output to stdout
cat "$OUTPUT_FILE"
echo ""
echo "[triage] Saved to $OUTPUT_FILE" >&2
