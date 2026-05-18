#!/usr/bin/env bash
# =============================================================================
# parallel-dispatch.sh — Generic parallel step runner for workflow.d
#
# Reads sub-step definitions from stdin as JSON, runs all sub-step scripts
# concurrently, captures outputs, optionally merges results.
#
# Input (stdin):
#   {
#     "sub_steps": [
#       {"id": "q1", "script": "scripts/research/explore.sh", "args": ["question text"]},
#       {"id": "q2", "script": "scripts/research/explore.sh", "args": ["other question"]}
#     ],
#     "merge_with": "scripts/research/merge-findings.sh"   # optional
#   }
#
# Output (stdout): JSON with results per sub-step, or merged result.
# Exit code: 0 if all sub-steps passed, 1 if any failed.
# =============================================================================

set -u
# Note: no 'set -e' — the Python dispatcher may return non-zero when sub-steps fail.
# The exit code is captured and propagated manually.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RUNTIME_DIR="$REPO_ROOT/.runtime"
mkdir -p "$RUNTIME_DIR"

# ── Parse input ──

INPUT=$(cat)
SUB_STEPS=$(echo "$INPUT" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(json.dumps(data.get('sub_steps', [])))
")
MERGE_WITH=$(echo "$INPUT" | python3 -c "
import json, sys
data = json.load(sys.stdin)
mw = data.get('merge_with', '')
print(mw if mw else '')
")

if [[ -z "$SUB_STEPS" || "$SUB_STEPS" == "[]" ]]; then
  echo '{"error":"no sub_steps defined","status":"fail"}'
  exit 1
fi

# ── Create temp workspace ──

WORKSPACE=$(mktemp -d "$RUNTIME_DIR/parallel.XXXXXX")
trap 'rm -rf "$WORKSPACE"' EXIT

# ── Run sub-steps in parallel ──

echo "$SUB_STEPS" >"$WORKSPACE/sub_steps.json"

# Run dispatcher (may return non-zero when checks fail — that's expected)
python3 "$SCRIPT_DIR/parallel-dispatch.py" "$WORKSPACE" "$REPO_ROOT" "$MERGE_WITH"
EXIT_CODE=$?

# ── Output result ──

if [[ -f "$WORKSPACE/output.json" ]]; then
  cat "$WORKSPACE/output.json"
else
  echo '{"error":"no output produced","status":"fail"}'
  exit 1
fi

exit $EXIT_CODE
