#!/usr/bin/env bash
# =============================================================================
# decision.sh --- Unified decision scaffold (DCI Decision Packet pattern)
#
# Wraps the repo's fragmented decision infrastructure into a single framework.
# Every decision produces a structured DECISION PACKET with:
#   - Selected option
#   - Residual objections
#   - Reopen conditions
#   - Confidence score
#   - Evidence cited
#
# Depth adapts to stakes:
#   LOW    -> quick binary with 1-line reasoning
#   MEDIUM -> tradeoff matrix with weighted criteria
#   HIGH   -> recommends multi-perspective (counsel/parley)
#
# Integrates with existing infrastructure instead of replacing it:
#   - Delegates to phase-gate.sh for phase decisions
#   - Delegates to plan-challenge.sh for plan dissent
#   - Delegates to counsel-run.sh for multi-perspective
#
# Usage:
#   evaluate "question" [--options "A,B,C"] [--stakes low|medium|high]
#            [--criteria "speed,cost,quality"]
#   log <label> <selected> [--confidence N] [--objections "..."]
#   review <decision-id>
#   audit [--recent N] [--all] [--failed]
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$SCRIPT_DIR/..")"
RUNTIME_DIR="$REPO_ROOT/.runtime"
DECISION_LOG="$RUNTIME_DIR/decision-log.jsonl"

CMD="${1:-help}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  evaluate "question" [--options "A,B,C"] [--stakes low|medium|high]
                      [--criteria "speed,cost,quality"]
           Run structured decision scaffold. Produces a decision packet
           with selected option, confidence, residual objections, reopen
           conditions. Depth adapts to stakes.

  log <label> <selected> [--confidence N] [--objections "..."]
                         [--reopen "..."] [--evidence "..."]
           Record a decision outcome (for decisions made outside scaffold).

  review <decision-id>
           Reopen a past decision. Check if reopen conditions are met.
           Show residual objections.

  audit [--recent N] [--all] [--failed]
           Show decision history. Default: last 10.
EOF
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
gen_id() {
  # Generate a unique decision ID from timestamp + hash of question
  # Avoids collision when multiple decisions are evaluated sequentially
  local ts
  ts=$(date +%s)
  local hash
  hash=$(echo "$ts$RANDOM" | md5sum 2>/dev/null | head -c 6 || echo "$RANDOM")
  echo "dec-$(date +%H%M)-$hash"
}

log_decision() {
  local entry="$1"
  mkdir -p "$RUNTIME_DIR"
  echo "$entry" >> "$DECISION_LOG"
}

# ---------------------------------------------------------------------------
# Depth-adaptive evaluation
# ---------------------------------------------------------------------------
evaluate_decision() {
  local question="" options_str="" stakes="medium" criteria_str=""

  # Parse args
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --options) options_str="$2"; shift 2 ;;
      --stakes) stakes="$2"; shift 2 ;;
      --criteria) criteria_str="$2"; shift 2 ;;
      --help|-h) usage; exit 0 ;;
      *)
        if [[ -z "$question" ]]; then
          question="$1"
        else
          echo "Unknown: $1" >&2
          usage
          exit 2
        fi
        shift
        ;;
    esac
  done

  if [[ -z "$question" ]]; then
    echo "ERROR: question is required" >&2
    usage
    exit 2
  fi

  local decision_id
  decision_id=$(gen_id)
  local timestamp
  timestamp=$(date +%s)

  # Split options into array
  local IFS=','
  local -a options=()
  if [[ -n "$options_str" ]]; then
    read -ra options <<< "$options_str"
  fi
  local -a criteria=()
  if [[ -n "$criteria_str" ]]; then
    read -ra criteria <<< "$criteria_str"
  fi

  echo ""
  echo "=========================================="
  echo "  Decision Scaffold"
  echo "  ID:     $decision_id"
  echo "  Stakes: $stakes"
  echo "=========================================="
  echo ""
  echo "Question: $question"
  echo ""

  case "$stakes" in
    low)
      # Quick binary: just surface key tradeoff
      echo "--- LOW STAKES ---"
      echo "This decision is reversible or low-cost."
      echo "Recommendation: choose the simpler option."
      echo ""
      if [[ ${#options[@]} -ge 2 ]]; then
        echo "Options:"
        for opt in "${options[@]}"; do
          echo "  - $opt"
        done
      fi
      echo ""
      echo "Decision packet:"
      echo "  Selected:    ${options[0]:-(choose based on simplicity)}"
      echo "  Confidence:  0.8 (low stakes, quick check sufficient)"
      echo "  Objections:  minor --- reversible if wrong"
      echo "  Reopen if:   new information changes the tradeoff"
      echo ""

      # Log the decision
      local low_opts_json
      if [[ -n "$options_str" ]]; then
        low_opts_json="[\"$(echo "$options_str" | sed 's/,/","/g')\"]"
      else
        low_opts_json="null"
      fi
      local entry
      entry=$(cat <<EOF
{"id":"$decision_id","question":"$question","stakes":"low","options":$low_opts_json,"selected":"${options[0]:-}","confidence":0.8,"residual_objections":"minor - reversible","reopen_conditions":"new information","timestamp":$timestamp}
EOF
)
      log_decision "$entry"
      echo "Logged: $decision_id"
      ;;

    medium)
      # Tradeoff matrix with weighted criteria
      echo "--- MEDIUM STAKES ---"
      echo "This decision has moderate impact."
      echo ""

      # If no options provided, prompt for them
      if [[ ${#options[@]} -eq 0 ]]; then
        echo "No options provided. Generate options from context, then"
        echo "re-run with: --options \"option1,option2,option3\""
        echo ""
        echo "Suggested evaluation criteria:"
        for c in "${criteria[@]:-speed reliability cost time}"; do
          echo "  - $c"
        done
        echo ""
        echo "Decision packet (pending option definition):"
        echo "  Selected:    (not yet determined)"
        echo "  Confidence:  (pending)"
        echo "  Objections:  (pending)"
        echo "  Reopen if:   performance < threshold or new option emerges"
      else
        # Build a weighted criteria template
        echo "Options:"
        for opt in "${options[@]}"; do
          echo "  - $opt"
        done
        echo ""
        echo "Criteria:"
        if [[ ${#criteria[@]} -gt 0 ]]; then
          for c in "${criteria[@]}"; do
            echo "  - $c [weight 1-5]: assign weight based on priority"
          done
        else
          echo "  (specify with --criteria \"speed,cost,quality\")"
        fi
        echo ""
        echo "For each option, score 1-5 per criterion."
        echo "Weighted total = sum(weight * score) per option."
        echo ""
        echo "Decision packet (fill in scored evaluation):"
        echo "  Selected:    (highest weighted total)"
        echo "  Confidence:  (1-10, based on score spread)"
        echo "  Objections:  (weaknesses of selected option)"
        echo "  Reopen if:   (conditions that would change the decision)"
        echo ""

        # Log the decision template
        local options_json="[\"$(echo "$options_str" | sed 's/,/","/g')\"]"
        local criteria_json="[\"$(echo "$criteria_str" | sed 's/,/","/g')\"]"
        local m_entry
        m_entry=$(cat <<EOF
{"id":"$decision_id","question":"$question","stakes":"medium","options":$options_json,"criteria":$criteria_json,"selected":"PENDING_SCORING","confidence":null,"residual_objections":"requires weighted scoring","reopen_conditions":"after scoring","timestamp":$timestamp,"status":"pending"}
EOF
)
        log_decision "$m_entry"
        echo "Logged: $decision_id (pending weighted scoring)"
      fi
      ;;

    high)
      # Multi-perspective decision --- delegate to counsel/parley
      echo "--- HIGH STAKES ---"
      echo "This decision is costly or hard to reverse."
      echo "Recommend: multi-perspective review before deciding."
      echo ""

      # Check if counsel infrastructure exists
      local counsel_script="$SCRIPT_DIR/counsel-run.sh"
      local parley_script="$SCRIPT_DIR/parley.sh"

      echo "Available review mechanisms:"
      if [[ -f "$counsel_script" ]]; then
        echo "  1. Counsel (multi-agent review):"
        echo "     bash $counsel_script --question \"$question\""
        echo "     Provides 4-6 independent perspectives + compressed recommendation."
      fi
      if [[ -f "$parley_script" ]]; then
        echo "  2. Parley (interactive debate):"
        echo "     bash $parley_script --topic \"$question\""
        echo "     Generates structured debate transcript."
      fi
      echo "  3. Escalate to human (A2H):"
      echo "     bash $SCRIPT_DIR/a2h-contact.sh approve \"$question\""
      echo ""

      # Log the decision as pending
      local high_opts_json
      if [[ -n "$options_str" ]]; then
        high_opts_json="[\"$(echo "$options_str" | sed 's/,/","/g')\"]"
      else
        high_opts_json="null"
      fi
      local entry
      entry=$(cat <<EOF
{"id":"$decision_id","question":"$question","stakes":"high","options":$high_opts_json,"selected":"PENDING_MULTI_PERSPECTIVE","confidence":null,"residual_objections":"requires multi-perspective review","reopen_conditions":"after review","timestamp":$timestamp,"status":"pending"}
EOF
)
      log_decision "$entry"
      echo "Logged: $decision_id (pending multi-perspective)"
      echo ""
      echo "After review, update decision:"
      echo "  bash scripts/decision.sh log $decision_id \"selected-option\" \\"
      echo "    --confidence 7 --objections \"...\" --reopen \"...\""
      ;;
  esac

  echo ""
  echo "--- Decision Packet ---"
  echo "ID:      $decision_id"
  echo "Log:     $DECISION_LOG"
}

# ---------------------------------------------------------------------------
# Log a decision manually
# ---------------------------------------------------------------------------
log_decision_entry() {
  local label="" selected="" confidence="" objections="" reopen_cond="" evidence=""

  label="${1:-}"
  selected="${2:-}"
  shift 2 || true

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --confidence) confidence="$2"; shift 2 ;;
      --objections) objections="$2"; shift 2 ;;
      --reopen) reopen_cond="$2"; shift 2 ;;
      --evidence) evidence="$2"; shift 2 ;;
      *) echo "Unknown: $1" >&2; usage; exit 2 ;;
    esac
  done

  if [[ -z "$label" || -z "$selected" ]]; then
    echo "ERROR: usage: decision.sh log <label> <selected> [options]" >&2
    exit 2
  fi

  local decision_id="$label"
  local timestamp
  timestamp=$(date +%s)

  local entry
  entry=$(cat <<EOF
{"id":"$decision_id","selected":"$selected","confidence":${confidence:-null},"residual_objections":"${objections:-}","reopen_conditions":"${reopen_cond:-}","timestamp":$timestamp,"evidence":"${evidence:-}"}
EOF
)
  log_decision "$entry"
  echo "Logged: $decision_id -> $selected"
}

# ---------------------------------------------------------------------------
# Review a past decision
# ---------------------------------------------------------------------------
review_decision() {
  local target_id="${1:-}"
  if [[ -z "$target_id" ]]; then
    echo "ERROR: decision-id is required" >&2
    usage
    exit 2
  fi

  if [[ ! -f "$DECISION_LOG" ]]; then
    echo "No decisions logged yet."
    exit 1
  fi

  python3 -c "
import json, sys, time

target = '$target_id'
found = False
with open('$DECISION_LOG') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            d = json.loads(line)
            if d.get('id') == target:
                found = True
                ts = time.strftime('%Y-%m-%d %H:%M', time.localtime(d.get('timestamp', 0)))
                print(f'Decision Review: {target}')
                print(f'  When:     {ts}')
                print(f'  Question: {d.get(\"question\", \"(not recorded)\")}')
                print(f'  Stakes:   {d.get(\"stakes\", \"?\")}')
                print(f'  Selected: {d.get(\"selected\", \"?\")}')
                print(f'  Confidence: {d.get(\"confidence\", \"?\")}/10')
                print(f'')
                print(f'  Residual Objections:')
                obj = d.get('residual_objections', '')
                if obj:
                    for o in obj.split(';'):
                        print(f'    - {o.strip()}')
                else:
                    print(f'    (none recorded)')
                print(f'')
                print(f'  Reopen Conditions:')
                ro = d.get('reopen_conditions', '')
                if ro:
                    for r in ro.split(';'):
                        print(f'    - {r.strip()}')
                else:
                    print(f'    (none recorded)')
                print(f'')
                print(f'  Status: {\"still valid\" if not ro else \"check conditions\"}')
                break
        except json.JSONDecodeError:
            pass

if not found:
    print(f'Decision not found: {target}')
    sys.exit(1)
" 2>/dev/null
}

# ---------------------------------------------------------------------------
# Audit trail
# ---------------------------------------------------------------------------
audit_decisions() {
  local mode="recent"
  local count=10

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --recent) mode="recent"; count="${2:-10}"; shift 2 ;;
      --all) mode="all"; shift ;;
      --failed) mode="failed"; shift ;;
      *) echo "Unknown: $1" >&2; usage; exit 2 ;;
    esac
  done

  if [[ ! -f "$DECISION_LOG" ]]; then
    echo "No decisions logged yet."
    exit 0
  fi

  local total
  total=$(wc -l < "$DECISION_LOG" 2>/dev/null || echo 0)

  echo "=== Decision Audit ($total total) ==="
  echo ""

  case "$mode" in
    recent)
      tail -"$count" "$DECISION_LOG" | python3 -c '
import json, sys, time
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        d = json.loads(line)
        ts = time.strftime("%H:%M", time.localtime(d.get("timestamp", 0)))
        q = d.get("question", d.get("id", "?"))[:50]
        sel = d.get("selected", "?")[:30]
        conf = str(d.get("confidence", "?"))
        iid = d.get("id", "?")
        print(f"  {ts} | {iid:14s} | {conf:4s} | {sel:30s} | {q}")
    except Exception as e:
        sys.stderr.write(f"AUDIT ERROR: {e}\n")
'
      ;;
    all)
      cat "$DECISION_LOG" | python3 -c '
import json, sys, time
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        d = json.loads(line)
        ts = time.strftime("%m-%d %H:%M", time.localtime(d.get("timestamp", 0)))
        q = d.get("question", d.get("id", "?"))[:50]
        sel = d.get("selected", "?")[:30]
        conf = str(d.get("confidence", "?"))
        iid = d.get("id", "?")
        print(f"  {ts} | {iid:14s} | {conf:4s} | {sel:30s} | {q}")
    except:
        pass
'
      ;;
    failed)
      local failed_output
      failed_output=$(python3 -c "
import json, sys, time
found = False
with open('$DECISION_LOG') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            d = json.loads(line)
            conf = d.get('confidence')
            if conf is None or conf == '' or (isinstance(conf, (int, float)) and conf < 5):
                found = True
                ts = time.strftime('%H:%M', time.localtime(d.get('timestamp', 0)))
                q = d.get('question', d.get('id', '?'))[:50]
                sel = d.get('selected', '?')[:30]
                iid = d.get('id', '?')
                print(f'  {ts} | {iid:14s} | {str(conf):4s} | {sel:30s} | {q}')
        except:
            pass
if not found:
    print('NONE')
" 2>/dev/null || echo "NONE")
      if [[ "$failed_output" == "NONE" ]]; then
        echo "  (no low-confidence or pending decisions)"
      else
        echo "$failed_output"
      fi
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Subcommands
# ---------------------------------------------------------------------------
case "$CMD" in
  evaluate)
    evaluate_decision "$@"
    ;;

  log)
    log_decision_entry "$@"
    ;;

  review)
    review_decision "${1:-}"
    ;;

  audit)
    audit_decisions "$@"
    ;;

  help|--help|-h|*)
    usage
    exit 0
    ;;
esac
