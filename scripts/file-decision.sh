#!/usr/bin/env bash
# =============================================================================
# file-decision.sh --- Decision: edit existing file or create a new one?
#
# Heuristic engine: given a proposed change and target file, recommends:
#   - edit (change fits within the file's scope and size)
#   - split (change adds >30% to an already-large file)
#   - create (file doesn't exist or change is a new responsibility)
#   - restructure (file is already too large, needs refactoring first)
#
# Usage:
#   evaluate <change-desc> --target <file> [--added-lines N] [--out <file>]
#   assess   <file>        Show file profile (lines, type, responsibility)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$SCRIPT_DIR/..")"
RUNTIME_DIR="$REPO_ROOT/.runtime"
DECISION_LOG="$RUNTIME_DIR/file-decisions.jsonl"

CMD="${1:-help}"
shift || true

LARGE_FILE_THRESHOLD=400    # lines: files above this are "large"
SPLIT_THRESHOLD=30          # percent: change adding >this % -> suggest split
MAX_SCOPE_SCORE=5           # scale for scope fit scoring

usage() {
  cat <<'EOF'
Usage:
  evaluate <change-description> --target <file> [options]
           Decide: edit, split, create, or restructure?
           Options:
             --added-lines N   Estimated lines the change adds (default: auto)
             --out <file>      Write decision packet to file

  assess <file>
           Show file profile (lines, type, responsibility hints).
           Useful before calling evaluate.

  log <change-desc> <decision> [--target <file>] [--reason "..."]
           Manually record a file decision.
EOF
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log_decision() {
  local entry="$1"
  mkdir -p "$RUNTIME_DIR"
  echo "$entry" >> "$DECISION_LOG"
}

# ---------------------------------------------------------------------------
# Assess a file: size, type, responsibility hints
# ---------------------------------------------------------------------------
assess_file() {
  local target_file="${1:-}"
  if [[ -z "$target_file" ]]; then
    echo "ERROR: file path required" >&2
    exit 2
  fi

  if [[ ! -f "$target_file" ]]; then
    echo "File: $target_file"
    echo "  Exists: no"
    echo "  Decision: CREATE --- file does not exist"
    return 0
  fi

  local line_count
  line_count=$(wc -l < "$target_file" 2>/dev/null || echo 0)
  local file_type=""
  case "$target_file" in
    *.sh) file_type="shell script" ;;
    *.py) file_type="python script" ;;
    *.md) file_type="markdown doc" ;;
    *.json) file_type="json" ;;
    *.yaml|*.yml) file_type="yaml config" ;;
    *.ts|*.tsx) file_type="typescript" ;;
    *.js|*.jsx) file_type="javascript" ;;
    *.css) file_type="stylesheet" ;;
    *) file_type="text" ;;
  esac

  local size_bin="small"
  if [[ "$line_count" -gt "$LARGE_FILE_THRESHOLD" ]]; then
    size_bin="LARGE"
  elif [[ "$line_count" -gt 200 ]]; then
    size_bin="medium"
  fi

  # Try to infer responsibility from first comment block or filename
  local header
  header=$(head -20 "$target_file" 2>/dev/null | grep -E '^# |^// |^/\*\*|^-- |^#=' | head -3 || echo "")

  echo "File: $target_file"
  echo "  Lines:    $line_count ($size_bin)"
  echo "  Type:     $file_type"
  if [[ -n "$header" ]]; then
    echo "  Purpose:  $(echo "$header" | head -1 | sed 's/^# \?//; s/^\/\/ \?//; s/^\/\*\* \?//' 2>/dev/null)"
  fi
}

# ---------------------------------------------------------------------------
# Full decision evaluation
# ---------------------------------------------------------------------------
evaluate() {
  local change_desc="" target_file="" added_lines=0 auto_lines=true
  local out_file=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --target) target_file="$2"; shift 2 ;;
      --added-lines) added_lines="$2"; auto_lines=false; shift 2 ;;
      --out) out_file="$2"; shift 2 ;;
      --help|-h) usage; exit 0 ;;
      *)
        if [[ -z "$change_desc" ]]; then
          change_desc="$1"
        else
          echo "Unknown: $1" >&2
          usage
          exit 2
        fi
        shift
        ;;
    esac
  done

  if [[ -z "$change_desc" || -z "$target_file" ]]; then
    echo "ERROR: change description and --target are required" >&2
    usage
    exit 2
  fi

  echo "=========================================="
  echo "  File Decision"
  echo "=========================================="
  echo ""
  echo "Change: $change_desc"
  echo "Target: $target_file"
  echo ""

  # --- Does the file exist? ---
  if [[ ! -f "$target_file" ]]; then
    local dir_exists=false
    local parent_dir
    parent_dir=$(dirname "$target_file")
    if [[ -d "$parent_dir" ]]; then
      dir_exists=true
    fi

    echo "File status: DOES NOT EXIST"
    echo ""

    if [[ "$dir_exists" == true ]]; then
      echo "Recommendation: CREATE"
      echo "Reason: target file doesn't exist but its parent directory does."
      echo "  Creating a new file here is the natural choice."
    else
      echo "Recommendation: CREATE (with new directory)"
      echo "Reason: neither file nor parent directory exists."
      echo "  Ensure the new module belongs in this path."
    fi

    # Log
    local ts
    ts=$(date +%s)
    log_decision "{\"change\":\"$change_desc\",\"target\":\"$target_file\",\"decision\":\"create\",\"timestamp\":$ts}"
    return 0
  fi

  # --- File exists: analyze ---
  local line_count
  line_count=$(wc -l < "$target_file" 2>/dev/null || echo 0)

  # Auto-estimate added lines from change description (rule of thumb)
  if [[ "$auto_lines" == true ]]; then
    # Estimate: longer description ≈ more lines of code
    local desc_len=${#change_desc}
    added_lines=$(( desc_len / 10 ))
    [[ "$added_lines" -lt 5 ]] && added_lines=5
    [[ "$added_lines" -gt 200 ]] && added_lines=200
  fi

  local added_pct=0
  if [[ "$line_count" -gt 0 ]]; then
    added_pct=$(( added_lines * 100 / line_count ))
  fi

  echo "File status: EXISTS ($line_count lines)"
  echo "  Estimated added lines: $added_lines ($added_pct% increase)"
  echo ""

  # --- Decision logic ---
  local decision="edit"
  local reason=""

  # Signal 1: File is very large and change is proportionally large
  if [[ "$line_count" -gt "$LARGE_FILE_THRESHOLD" && "$added_pct" -gt "$SPLIT_THRESHOLD" ]]; then
    decision="split"
    reason="File is $line_count lines (above ${LARGE_FILE_THRESHOLD}L threshold) and change adds ~${added_pct}% more. Recommend splitting the new functionality into a separate file."

  # Signal 2: File is large and change is significant in absolute terms
  elif [[ "$line_count" -gt "$LARGE_FILE_THRESHOLD" && "$added_lines" -gt 100 ]]; then
    decision="split"
    reason="File is already $line_count lines. Adding $added_lines more lines compounds maintenance burden. Consider a new file."

  # Signal 3: File is not large but change is disproportionate
  elif [[ "$added_pct" -gt 50 && "$line_count" -gt 50 ]]; then
    decision="split"
    reason="Change adds ~${added_pct}% to a $line_count-line file. The new code is a significant fraction of existing code --- may warrant its own file."

  # Signal 4: File is already critical size
  elif [[ "$line_count" -gt 500 ]]; then
    decision="restructure"
    reason="File is $line_count lines --- well above the large threshold. Even if this change is small, the file likely needs refactoring before adding more."

  # Signal 5: Default to editing
  else
    decision="edit"
    reason="File is $line_count lines and change adds ~${added_pct}%. Proportionate and in-scope. Edit the existing file."
  fi

  echo "Recommendation: $decision"
  echo "Reason: $reason"
  echo ""

  # Suggest command for each outcome
  case "$decision" in
    edit)
      echo "  Action: edit $target_file"
      echo "  After: verify with quality-speed-gate.sh"
      ;;
    split)
      echo "  Action: extract new functionality to a separate file in $(dirname "$target_file")"
      echo "  Template: reference patterns from similar files in the same directory"
      echo "  After: update any imports or references in $target_file"
      ;;
    create)
      echo "  Action: touch $target_file and populate"
      echo "  After: ensure it's discoverable (index, README, or parent doc)"
      ;;
    restructure)
      echo "  Action: refactor $target_file into smaller modules first"
      echo "  Suggested: split into 2-3 files, then add the new change"
      ;;
  esac
  echo ""

  # Log
  local ts
  ts=$(date +%s)
  log_decision "{\"change\":\"$change_desc\",\"target\":\"$target_file\",\"decision\":\"$decision\",\"added_lines\":$added_lines,\"file_lines\":$line_count,\"added_pct\":$added_pct,\"timestamp\":$ts}"

  case "$decision" in
    edit) return 0 ;;
    split) return 1 ;;
    create) return 2 ;;
    restructure) return 3 ;;
  esac
}

# ---------------------------------------------------------------------------
# Subcommands
# ---------------------------------------------------------------------------
case "$CMD" in
  evaluate)
    evaluate "$@"
    ;;

  assess)
    assess_file "${1:-}"
    ;;

  log)
    change="${1:-}"
    decision="${2:-}"
    shift 2 2>/dev/null || true
    target=""
    reason=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --target) target="$2"; shift 2 ;;
        --reason) reason="$2"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage; exit 2 ;;
      esac
    done
    ts=$(date +%s)
    log_decision "{\"change\":\"$change\",\"target\":\"$target\",\"decision\":\"$decision\",\"reason\":\"$reason\",\"timestamp\":$ts}"
    echo "Logged: $change -> $decision"
    ;;

  help|--help|-h|*)
    usage
    exit 0
    ;;
esac
