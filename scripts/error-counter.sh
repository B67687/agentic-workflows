#!/usr/bin/env bash
# =============================================================================
# error-counter.sh --- Error counter with human escalation (12-factor F9)
#
# Tracks consecutive failures per operation and escalates to a human after
# N failed attempts. Implements the "compact errors into context window"
# pattern: errors feed back into context for self-healing, with a counter
# to prevent infinite retry loops.
#
# Usage:
#   bash $(basename "$0") increment <operation> [error-message]
#     Increment the error counter for an operation.
#     If count >= threshold (default: 3), escalates to human via A2H.
#
#   bash $(basename "$0") check <operation>
#     Show current count and escalation status.
#
#   bash $(basename "$0") reset <operation>
#     Reset counter (call on success).
#
#   bash $(basename "$0") context <operation>
#     Output error context in compact XML format (for feeding into LLM context).
#
#   bash $(basename "$0") list
#     Show all tracked operations.
#
# Environment:
#   ERROR_THRESHOLD    Max retries before escalation (default: 3)
#   COOLDOWN_BASE      Base delay in seconds for exponential backoff (default: 30)
#                      Actual cooldown = COOLDOWN_BASE * 2^(count-1)
#
# Cooldown behavior:
#   After each increment, a cooldown period is set before the next retry.
#   The cooldown grows exponentially: base * 2^count seconds.
#   check subcommand shows cooldown status and remaining time.
#   Use --retry-after on increment to override with explicit seconds.
#
# Principle: "Add error counters to prevent infinite retry loops. Escalate
# to humans after N consecutive failures."
#   --- 12-Factor Agents, Factor 9
# =============================================================================

set -euo pipefail
trap 'echo "[ERROR] $BASH_SOURCE:$LINENO"' ERR

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COUNTER_DIR="$REPO_ROOT/.runtime/error-counter"
mkdir -p "$COUNTER_DIR"

THRESHOLD="${ERROR_THRESHOLD:-3}"
COOLDOWN_BASE="${COOLDOWN_BASE:-30}"

CMD="${1:-help}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  error-counter.sh increment <operation> [error-message] [--retry-after <N>]
    Increment counter. Sets exponential backoff cooldown (base * 2^count).
    Use --retry-after to override cooldown (e.g. from Retry-After header).
    Escalates to human after threshold.
    Example: error-counter.sh increment build "timeout" --retry-after 60

  error-counter.sh check <operation>
    Show current count, escalation status, and cooldown remaining.

  error-counter.sh reset <operation>
    Reset counter (on success).

  error-counter.sh route <operation> <1|2|3|4> [--note "..."]
    Route an escalation to target: 1=human, 2=subagent, 3=safety-system, 4=auto-retry

  error-counter.sh context <operation>
    Output compact XML error context for LLM consumption.

  error-counter.sh decide <operation>
    Classify failure type and get recommended next action.
    Outputs structured template: agent chooses C/S/E and records via 'classify'.

  error-counter.sh classify <operation> <C|S|E> [--note "..."]
    Record failure classification. C=comprehension, S=strategy, E=environment.
    Logs decision to .runtime/error-counter/decisions/ for audit trail.

  error-counter.sh list
    Show all tracked operations with cooldown status.

Environment:
  ERROR_THRESHOLD    Max retries before escalation (default: 3)
  COOLDOWN_BASE      Base delay in seconds for exponential backoff (default: 30)
                     Actual cooldown = COOLDOWN_BASE * 2^(count-1)
EOF
}

# Path for a counter file
counter_path() {
  local operation="$1"
  # Sanitize operation name for filename
  local safe_name
  safe_name=$(echo "$operation" | python3 -c "
import sys, re
name = sys.stdin.read().strip()
safe = re.sub(r'[^a-zA-Z0-9_-]', '_', name)
print(safe[:64])
" 2>/dev/null || echo "unknown")
  echo "$COUNTER_DIR/$safe_name.json"
}

# Load counter data
load_counter() {
  local file="$1"
  if [ -f "$file" ]; then
    cat "$file"
  else
    echo '{"count": 0, "last_error": "", "last_failure": null, "created": null, "cooldown_until": null}'
  fi
}

# Escalate to human after threshold reached
escalate() {
  local operation="$1"
  local count="$2"
  local error_msg="$3"

  echo "  [escalate] Operation '$operation' failed $count times (threshold: $THRESHOLD)"
  echo "  [escalate] Escalating to human..."

  # Try A2H contact if available
  if [ -f "$SCRIPT_DIR/a2h-contact.sh" ]; then
    bash "$SCRIPT_DIR/a2h-contact.sh" approve \
      "retry-$operation" \
      "{\"operation\": \"$operation\", \"failures\": $count, \"last_error\": $(echo "$error_msg" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()[:500]))" 2>/dev/null || echo "\"\"")}" \
      --urgency high --channel cli 2>&1 || true
  fi

  # Always write escalation notice
  local escalation_dir="$REPO_ROOT/.runtime/error-counter/escalations"
  mkdir -p "$escalation_dir"
  local timestamp
  timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  local esc_file="$escalation_dir/$(echo "$operation" | tr ' /' '__')-$timestamp.json"
  cat > "$esc_file" <<EOF
{
  "operation": $(echo "$operation" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read().strip()))"),
  "failures": $count,
  "threshold": $THRESHOLD,
  "timestamp": "$timestamp",
  "last_error": $(echo "$error_msg" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()[:500]))")
}
EOF
  echo "  [escalate] Escalation recorded: $esc_file"
}

# --- Commands ---

do_increment() {
  local operation="$1"
  shift
  local error_msg="unknown error"
  local retry_after=""
  local file
  file=$(counter_path "$operation")
  local timestamp
  timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

  # Parse remaining args: error message and --retry-after flag
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --retry-after)
        retry_after="$2"
        shift 2
        ;;
      --retry-after=*)
        retry_after="${1#*=}"
        shift
        ;;
      *)
        error_msg="$1"
        shift
        ;;
    esac
  done

  # Read current or create new
  local counter_data
  counter_data=$(load_counter "$file")
  local count
  count=$(echo "$counter_data" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('count', 0))" 2>/dev/null || echo "0")
  local created
  created=$(echo "$counter_data" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('created') or '$timestamp')" 2>/dev/null || echo "$timestamp")

  count=$((count + 1))

  # Calculate cooldown: base * 2^(count-1), or explicit retry-after
  local cooldown_seconds="$COOLDOWN_BASE"
  if [[ -n "$retry_after" ]]; then
    cooldown_seconds="$retry_after"
  else
    # Exponential backoff: base * 2^(count-1)
    cooldown_seconds=$((COOLDOWN_BASE * (2 ** (count - 1))))
  fi
  local cooldown_until
  cooldown_until=$(python3 -c "
import sys
from datetime import datetime, timezone, timedelta
now = datetime.now(timezone.utc)
cd = now + timedelta(seconds=$cooldown_seconds)
print(cd.strftime('%Y-%m-%dT%H:%M:%SZ'))
" 2>/dev/null || echo "")

  # Write updated counter with cooldown
  python3 - "$file" "$count" "$error_msg" "$timestamp" "$created" "$cooldown_until" <<'PY'
import json, sys

file = sys.argv[1]
count = int(sys.argv[2])
error = sys.argv[3]
ts = sys.argv[4]
created = sys.argv[5]
cooldown_until = sys.argv[6] if len(sys.argv) > 6 and sys.argv[6] else None

data = {
    "operation": file.split("/")[-1].replace(".json", ""),
    "count": count,
    "last_error": error[:500],
    "last_failure": ts,
    "created": created,
    "threshold": int(sys.argv[7]) if len(sys.argv) > 7 else 3,
    "cooldown_until": cooldown_until
}

with open(file, "w") as f:
    json.dump(data, f, indent=2)

print(f"Error count for {data['operation']}: {count}")
PY

  # Show cooldown info
  echo "  Cooldown: ${cooldown_seconds}s (until ${cooldown_until})"
  echo "  Backoff: 2^$((count - 1)) × ${COOLDOWN_BASE}s = ${cooldown_seconds}s"

  # Check threshold
  if [ "$count" -ge "$THRESHOLD" ]; then
    escalate "$operation" "$count" "$error_msg"
    return 2  # escalation triggered
  fi

  echo "  Retries remaining: $((THRESHOLD - count)) before escalation"
  echo "  To classify failure: error-counter.sh decide \"$operation\""
  return 0
}

do_check() {
  local operation="$1"
  local file
  file=$(counter_path "$operation")

  if [ ! -f "$file" ]; then
    echo "No errors recorded for: $operation"
    return 0
  fi

  python3 - "$file" "$THRESHOLD" <<'PY'
import json, sys
from datetime import datetime, timezone

with open(sys.argv[1]) as f:
    d = json.load(f)

threshold = int(sys.argv[2])
count = d.get("count", 0)
needs_escalation = count >= threshold
cooldown_until = d.get("cooldown_until")

print(f"Operation: {d.get('operation', '?')}")
print(f"  Consecutive failures: {count}")
print(f"  Threshold: {threshold}")
print(f"  Escalation needed: {'YES' if needs_escalation else 'no'}")
print(f"  Last failure: {d.get('last_failure', 'never')}")
if count > 0:
    print(f"  Last error: {str(d.get('last_error', ''))[:80]}")

# Cooldown status
if cooldown_until:
    try:
        cd = datetime.fromisoformat(cooldown_until.replace('Z', '+00:00'))
        now = datetime.now(timezone.utc)
        remaining = (cd - now).total_seconds()
        if remaining > 0:
            print(f"  Cooldown: ACTIVE ({int(remaining)}s remaining, expires {cooldown_until})")
        else:
            print(f"  Cooldown: EXPIRED (was set to {cooldown_until})")
    except Exception:
        print(f"  Cooldown: until {cooldown_until}")
PY
}

do_reset() {
  local operation="$1"
  local file
  file=$(counter_path "$operation")

  if [ -f "$file" ]; then
    rm "$file"
    echo "Reset error counter for: $operation"
  else
    echo "No counter found for: $operation"
  fi
}

# ---------------------------------------------------------------------------
# Post-failure decision support (QSAF-inspired failure classification)
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Escalation routing (for environment failures: classify E)
# ---------------------------------------------------------------------------

do_route() {
  local operation="$1"
  local route_target="${2:-}"
  local note=""

  shift 2 2>/dev/null || true
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --note) note="$2"; shift 2 ;;
      *) echo "Unknown: $1" >&2; return 2 ;;
    esac
  done

  if [ -z "$route_target" ] || ! echo "1 2 3 4" | grep -q "$route_target"; then
    echo "ERROR: route_target must be 1 (human), 2 (agent), 3 (system), or 4 (retry)" >&2
    return 2
  fi

  local file
  file=$(counter_path "$operation")

  if [ ! -f "$file" ]; then
    echo "No counter file for: $operation"
    echo "Run: error-counter.sh increment '$operation' first"
    return 1
  fi

  # Read error context
  local error_context
  error_context=$(python3 -c "
import json
with open('$file') as f:
    d = json.load(f)
print(d.get('last_error', 'unknown error')[:500])
" 2>/dev/null || echo "unknown error")

  local timestamp
  timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  local route_dir="$COUNTER_DIR/routes"
  mkdir -p "$route_dir"

  echo "=========================================="
  echo "  Escalation Route"
  echo "=========================================="
  echo ""

  case "$route_target" in
    1)
      # Human escalation via a2h-contact.sh
      echo "  Target: human"
      echo "  Executing: a2h-contact.sh approve..."

      if [ -f "$SCRIPT_DIR/a2h-contact.sh" ]; then
        bash "$SCRIPT_DIR/a2h-contact.sh" approve \
          "escalate-$operation" \
          "{\"operation\": \"$operation\", \"failure_type\": \"environment\", \"error\": $(echo "$error_context" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null || echo "\"\"")}" \
          --urgency high --channel cli 2>&1 || true
      fi

      # Record route
      local route_file="$route_dir/$operation-human-$timestamp.json"
      cat > "$route_file" <<EOF
{
  "operation": "$operation",
  "target": "human",
  "route": 1,
  "timestamp": "$timestamp",
  "note": "$note"
}
EOF
      echo "  Route logged: $route_file"
      ;;

    2)
      # Agent dispatch: output subagent prompt
      echo "  Target: subagent"
      echo ""
      echo "  To dispatch a subagent with this error context:"
      echo "    Use the task tool to spawn @worker with:"
      echo ""
      echo '    Prompt:'
      echo "    Analyze this environment failure and identify whether it is transient or permanent, and recommend action."
      cat <<PROMPT
    Error context:
      Operation: $operation
      Error: $error_context

    Task: Analyze this environment failure. Determine:
      1. Is this a transient or permanent failure?
      2. What conditions would need to change for a retry to succeed?
      3. Should the approach be modified to work around this failure?
      4. Or should this be escalated to a human with specific context?

    Return: a structured assessment with recommendation.
PROMPT
      echo ""

      # Record route
      local route_file="$route_dir/$operation-agent-$timestamp.json"
      cat > "$route_file" <<EOF
{
  "operation": "$operation",
  "target": "subagent",
  "route": 2,
  "timestamp": "$timestamp",
  "note": "$note"
}
EOF
      echo "  Route logged: $route_file"
      ;;

    3)
      # System escalation via safety-guard.sh
      echo "  Target: system (safety-guard)"
      echo "  Executing: safety-guard.sh check..."

      if [ -f "$SCRIPT_DIR/safety-guard.sh" ]; then
        # Check against generic safety profile
        bash "$SCRIPT_DIR/safety-guard.sh" check "pipeline-$operation" "task-1" --file "" 2>&1 || true
      else
        echo "  safety-guard.sh not available --- escalate to human instead"
        echo "  Route: falling back to route 1"
        do_route "$operation" 1 --note "fallback from route 3: safety-guard unavailable"
        return
      fi

      # Record route
      local route_file="$route_dir/$operation-system-$timestamp.json"
      cat > "$route_file" <<EOF
{
  "operation": "$operation",
  "target": "system",
  "route": 3,
  "timestamp": "$timestamp",
  "note": "$note"
}
EOF
      echo "  Route logged: $route_file"
      ;;

    4)
      # Auto-retry with backoff
      echo "  Target: auto-retry (transient failure)"
      echo ""

      # Read current count for backoff
      local current_count
      current_count=$(python3 -c "
import json
with open('$file') as f:
    print(json.load(f).get('count', 0))
" 2>/dev/null || echo 1)

      local backoff=$((current_count * 2))
      echo "  Backoff: ${backoff}s (retry ${current_count})"
      echo "  Reset counter and retry with modified conditions."
      echo ""

      # Reset counter (so retry doesn't immediately hit threshold)
      if [ -f "$file" ]; then
        rm "$file"
      fi

      echo "  Counter reset. Retry with:"
      echo "    - Wait ${backoff}s before retry"
      echo "    - Use different conditions if possible (timeout, retry count, etc.)"
      echo "    - If fails again: error-counter.sh increment '$operation' with --decide"

      # Record route
      local route_file="$route_dir/$operation-retry-$timestamp.json"
      cat > "$route_file" <<EOF
{
  "operation": "$operation",
  "target": "auto-retry",
  "route": 4,
  "backoff": $backoff,
  "timestamp": "$timestamp",
  "note": "$note"
}
EOF
      echo "  Route logged: $route_file"
      ;;
  esac
}

do_decide() {
  local operation="$1"
  local file
  file=$(counter_path "$operation")

  if [ ! -f "$file" ]; then
    echo "No error counter found for: $operation"
    echo "Run: error-counter.sh increment '$operation' first"
    return 1
  fi

  # Read error context
  echo ""
  echo "=========================================="
  echo "  Post-Failure Decision"
  echo "=========================================="
  echo ""

  python3 - "$file" "$THRESHOLD" <<'PY'
import json, sys, time

with open(sys.argv[1]) as f:
    d = json.load(f)

threshold = int(sys.argv[2])
count = d.get("count", 0)
error = d.get("last_error", "")[:300]
ts = d.get("last_failure", "")
op = d.get("operation", "?")
created = d.get("created", "")

print(f"Operation:    {op}")
print(f"Failures:     {count}/{threshold}")
print(f"Last failure: {ts}")
print(f"")
print(f"Last error:")
for line in error.split("\n"):
    print(f"  | {line}")
print(f"")

print(f"--- Failure Classification ---")
print(f"")
print(f"Three types of failure require different responses:")
print(f"")
print(f"  (C) Comprehension failure --- the agent didn't understand the task,")
print(f"      context, or constraints. Error shows misunderstanding of")
print(f"      requirements, wrong approach from the start, or missing")
print(f"      context.")
print(f"      -> Retry with expanded context (re-read instructions, add error details)")
print(f"")
print(f"  (S) Strategy failure --- the agent understood the task but chose")
print(f"      the wrong approach. Error shows correct intent, wrong")
print(f"      implementation, or incorrect tool choice.")
print(f"      -> Change strategy (switch approach, document why previous failed)")
print(f"")
print(f"  (E) Environment failure --- external dependency is broken, tooling")
print(f"      is unavailable, permissions are wrong, or infrastructure")
print(f"      is down.")
print(f"      -> Escalate (retrying won't help)")
print(f"")

PY

  local decision_log="$COUNTER_DIR/decisions"
  mkdir -p "$decision_log"
  local existing
  existing=$(ls "$decision_log"/"$(echo "$operation" | tr ' /' '__')"*.json 2>/dev/null | head -1 || echo "")
  if [ -n "$existing" ]; then
    echo "  Previous decision found: $existing"
    cat "$existing" | python3 -c "
import json, sys
d = json.load(sys.stdin)
print(f'  Previous classification: {d.get(\"classification\",\"?\")} on {d.get(\"timestamp\",\"?\")}')
" 2>/dev/null || true
  fi

  echo ""
  echo "Record your classification:"
  echo "  bash error-counter.sh classify $operation <C|S|E> [--note \"...\"]"
}

do_classify() {
  local operation="$1"
  local classification="${2:-}"
  local note=""

  shift 2 2>/dev/null || true
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --note) note="$2"; shift 2 ;;
      *) echo "Unknown: $1" >&2; return 2 ;;
    esac
  done

  if [ -z "$classification" ] || ! echo "C S E c s e" | grep -q "$classification"; then
    echo "ERROR: classification must be C (comprehension), S (strategy), or E (environment)" >&2
    return 2
  fi

  # Normalize to uppercase
  classification=$(echo "$classification" | tr '[:lower:]' '[:upper:]')

  local file
  file=$(counter_path "$operation")

  local decision_dir="$COUNTER_DIR/decisions"
  mkdir -p "$decision_dir"
  local timestamp
  timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  local decision_file="$decision_dir/$(echo "$operation" | tr ' /' '__')-$timestamp.json"

  local failure_type=""
  local recommendation=""
  case "$classification" in
    C)
      failure_type="comprehension"
      recommendation="retry with expanded context"
      ;;
    S)
      failure_type="strategy"
      recommendation="change approach"
      ;;
    E)
      failure_type="environment"
      recommendation="escalate"
      ;;
  esac

  cat > "$decision_file" <<EOF
{
  "operation": $(echo "$operation" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read().strip()))"),
  "classification": "$classification",
  "failure_type": "$failure_type",
  "recommendation": "$recommendation",
  "note": $(echo "$note" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read().strip() if sys.stdin.read().strip() else ''))" || echo "\"\""),
  "timestamp": "$timestamp"
}
EOF

  echo "Classified: $operation -> $failure_type failure"
  echo "Recommendation: $recommendation"
  echo "Logged: $decision_file"

  # Show routing options for environment failures
  if [[ "$classification" == "E" ]]; then
    echo ""
    echo "--- Escalation Routing ---"
    echo "Choose where to escalate this environment failure:"
    echo ""
    echo "  (1) Human    --- for permission issues, external deps, broken infra"
    echo "      bash error-counter.sh route $operation 1 [--note "..."]"
    echo ""
    echo "  (2) Agent    --- for parallel analysis or modified retry"
    echo "      bash error-counter.sh route $operation 2 [--note "..."]"
    echo ""
    echo "  (3) System   --- for blocked paths, budget exhaustion"
    echo "      bash error-counter.sh route $operation 3 [--note "..."]"
    echo ""
    echo "  (4) Retry    --- for transient failures (network, timeout)"
    echo "      bash error-counter.sh route $operation 4 [--note "..."]"
    echo ""
  fi
}

do_context() {
  local operation="$1"
  local file
  file=$(counter_path "$operation")

  if [ ! -f "$file" ]; then
    echo "<!-- no errors for $operation -->"
    return 0
  fi

  # Output compact XML for LLM context window
  python3 - "$file" <<'PY'
import json, sys

with open(sys.argv[1]) as f:
    d = json.load(f)

count = d.get("count", 0)
error = d.get("last_error", "")[:200]
ts = d.get("last_failure", "")

print(f"<error_counter operation=\"{d.get('operation', '?')}\">")
print(f"  <consecutive_failures>{count}</consecutive_failures>")
if error:
    import xml.sax.saxutils as saxutils
    print(f"  <last_error>{saxutils.escape(error)}</last_error>")
if ts:
    print(f"  <last_failure>{ts}</last_failure>")
threshold = d.get('threshold', 3)
print(f"  <action>{'ESCALATE_TO_HUMAN' if count >= threshold else 'retry_possible'}</action>")
print("</error_counter>")
PY
}

do_list() {
  echo "=== Error Counters ==="
  local found=false
  for f in "$COUNTER_DIR"/*.json; do
    [ -f "$f" ] || continue
    found=true
    python3 - "$f" "$THRESHOLD" <<'PY'
import json, sys
from datetime import datetime, timezone

with open(sys.argv[1]) as f:
    d = json.load(f)

count = d.get("count", 0)
threshold = int(sys.argv[2])
needs_esc = "ESCALATE" if count >= threshold else "ok"

# Cooldown badge
cooldown_until = d.get("cooldown_until")
cd_status = ""
if cooldown_until:
    try:
        cd = datetime.fromisoformat(cooldown_until.replace('Z', '+00:00'))
        now = datetime.now(timezone.utc)
        remaining = (cd - now).total_seconds()
        if remaining > 0:
            cd_status = f" CD:{int(remaining)}s"
        else:
            cd_status = " CD:expired"
    except Exception:
        pass

print(f"  [{needs_esc}{cd_status}] {d.get('operation', '?')}")
print(f"    failures: {count}/{threshold}")
print(f"    last: {d.get('last_failure', 'never')}")
PY
  done

  # Check escalation records
  local esc_dir="$COUNTER_DIR/escalations"
  if [ -d "$esc_dir" ]; then
    local esc_count
    esc_count=$(ls "$esc_dir"/*.json 2>/dev/null | wc -l | tr -d ' ')
    if [ "$esc_count" -gt 0 ]; then
      echo ""
      echo "  Escalations recorded: $esc_count"
      echo "  See: $esc_dir/"
    fi
  fi

  if ! $found; then
    echo "  No tracked operations."
  fi
}

# --- Main dispatch ---
case "$CMD" in
  increment|inc)
    if [ $# -lt 1 ]; then
      echo "ERROR: operation name required" >&2
      usage >&2
      exit 2
    fi
    do_increment "$@"
    ;;
  check)
    if [ $# -lt 1 ]; then
      echo "ERROR: operation name required" >&2
      usage >&2
      exit 2
    fi
    do_check "$1"
    ;;
  reset)
    if [ $# -lt 1 ]; then
      echo "ERROR: operation name required" >&2
      usage >&2
      exit 2
    fi
    do_reset "$1"
    ;;
  decide)
    do_decide "$1"
    ;;

  classify)
    do_classify "$@"
    ;;

  route)
    do_route "$@"
    ;;

  context)
    do_context "$1"
    ;;
  list)
    do_list
    ;;
  help|--help|-h)
    usage
    ;;
  *)
    echo "Unknown command: $CMD" >&2
    usage >&2
    exit 2
    ;;
esac
