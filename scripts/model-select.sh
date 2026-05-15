#!/usr/bin/env bash
# =============================================================================
# model-select.sh --- Task-driven model selection
#
# Given a task description, classifies it on relevant dimensions and
# recommends the best model from the current routing table.
#
# The routing table is a snapshot. Run `model-select.sh refresh` to see
# the monthly refresh checklist from model-selection-guide.md.
#
# Usage:
#   classify <task-description>
#           Auto-detect task type + complexity, recommend model.
#
#   by-type <task-type>
#           Quick lookup: coding, debugging, research, writing,
#           architecture, extraction, multimodal, planning.
#
#   compare <model-A> <model-B>
#           Side-by-side comparison from the registry.
#
#   refresh
#           Show the monthly refresh checklist.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$SCRIPT_DIR/..")"

CMD="${1:-help}"
shift || true

# ---------------------------------------------------------------------------
# Registry snapshot (refreshed 2026-05-15 from model-selection-guide.md)
# Update via monthly refresh checklist
# ---------------------------------------------------------------------------
REFRESH_DATE="2026-05-15"

# Task type classifier keywords
declare -A TASK_TYPES
TASK_TYPES=(
  ["coding"]="implement|write code|add feature|build|refactor|fix bug|debug|patch|program|script"
  ["debugging"]="debug|bug|error|fail|crash|broken|wrong|incorrect|stack.trace|exception"
  ["research"]="research|investigate|explore|learn|understand|analyze|compare|survey|literature"
  ["writing"]="write|document|draft|compose|explain|describe|summarize|report|readme"
  ["architecture"]="architecture|design|plan|structure|system|component|interface|api|schema"
  ["extraction"]="extract|parse|classify|rank|structure|transform|convert|format"
  ["multimodal"]="image|video|audio|visual|screenshot|diagram|chart|figure"
  ["planning"]="plan|strategy|roadmap|milestone|prioritize|scope|timeline"
)

# Complexity classifiers
COMPLEXITY_SIMPLE="typo|rename|format|cosmetic|trivial|minor|simple|quick|small"
COMPLEXITY_COMPLEX="complex|hard|difficult|subtle|large|multi.file|deep|architectural"

# Routing table: (task_type, complexity) -> recommended model(s)
# Format: "model|provider_lane|reason"
recommend() {
  task_type="$1"
  complexity="$2"
  budget="${3:-standard}"

  case "$task_type" in
    coding)
      case "$complexity" in
        simple)    echo "DeepSeek V4 Flash|opencode-go|Fastest MIT-licensed volume king (31,650 req/5hr, 79% SWE-V)" ;;
        moderate)  echo "Claude Sonnet 4.6|copilot|Best daily driver balance (300 prompts, 1x multiplier)" ;;
        complex)   echo "Claude Opus 4.7|copilot|Hardest coding (40 prompts, 7.5x --- use sparingly)" ;;
      esac
      # Alternative lanes
      echo "ALT:Kim K2.6|opencode-go|Best quality in Go (80.2% SWE-V, 1,150 req/5hr)"
      echo "ALT:DeepSeek V4 Pro|opencode-go|MIT license, 80.6% SWE-V, 1M context (3,450 req/5hr)"
      echo "ALT:Gemini 3.1 Pro|ai-studio|Free tier, 1M context, strong for research-heavy coding"
      ;;
    debugging)
      case "$complexity" in
        simple)    echo "Claude Sonnet 4.6|copilot|Strong debugging at 1x multiplier" ;;
        moderate)  echo "Claude Opus 4.7|copilot|Best for subtle bugs (7.5x, use when Sonnet fails)" ;;
        complex)   echo "Claude Opus 4.7|copilot|Hardest debugging --- use for stuck bugs" ;;
      esac
      echo "ALT:Kim K2.6|opencode-go|Strong reasoning (96.4% AIME), good debug alternative"
      echo "ALT:DeepSeek V4 Flash|opencode-go|High-volume debug iterations (31,650 req/5hr)"
      ;;
    research)
      echo "Gemini 3.1 Pro|ai-studio|Best free long-context research lane (1M context, 14,400 req/day)"
      echo "ALT:Claude Sonnet 4.6|copilot|Strong synthesis at 1x multiplier"
      echo "ALT:DeepSeek V4 Pro|opencode-go|1M context, MIT license, strong for deep research"
      ;;
    writing)
      echo "Claude Sonnet 4.6|copilot|Best prose quality at reasonable cost (1x multiplier)"
      echo "ALT:Gemini 3.1 Pro|ai-studio|Free tier, 1M context for long docs"
      echo "ALT:GPT-5.4|copilot|Strong for structured writing and tool-heavy docs"
      ;;
    architecture)
      echo "Claude Opus 4.7|copilot|Strongest reasoning for architectural decisions (7.5x)"
      echo "ALT:Kim K2.6|opencode-go|Best Go quality (80.2% SWE-V, strong reasoning)"
      echo "ALT:Gemini 3.1 Pro|ai-studio|Free tier, great for broad architectural synthesis"
      ;;
    extraction)
      case "$budget" in
        free)      echo "GPT-5 nano|copilot|Fastest cheapest extraction (0.25x multiplier, 1,200 prompts)" ;;
        budget)    echo "DeepSeek V4 Flash|opencode-go|High-volume extraction (31,650 req/5hr)" ;;
        standard)  echo "Claude Haiku 4.5|copilot|Cheap extraction specialist (0.33x, ~900 prompts)" ;;
      esac
      echo "ALT:Gemini 3 Flash|ai-studio|Free tier, fast structured extraction"
      ;;
    multimodal)
      echo "Gemini 3.1 Pro|ai-studio|Best free multimodal (vision + text + long context)"
      echo "ALT:GPT-5.4|copilot|Strong multimodal with OpenAI tools (1x)"
      echo "ALT:MiMo-V2-Omni|opencode-go|Native image/video/audio in Go (2,150 req/5hr)"
      ;;
    planning)
      echo "Claude Sonnet 4.6|copilot|Best balance for planning (1x, 300 prompts)"
      echo "ALT:Claude Opus 4.7|copilot|For high-stakes plans (7.5x)"
      echo "ALT:Gemini 3.1 Pro|ai-studio|Free tier, good for broad strategic planning"
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Auto-classify from task description
# ---------------------------------------------------------------------------
classify_task() {
  description="$1"
  lower_desc
  lower_desc=$(echo "$description" | tr '[:upper:]' '[:lower:]')

  # Detect task type by keyword matching (first match wins)
  detected_type="coding"
  for type in "debugging" "research" "writing" "architecture" "extraction" "multimodal" "planning" "coding"; do
    keywords="${TASK_TYPES[$type]}"
    if echo "$lower_desc" | grep -qiE "$keywords" 2>/dev/null; then
      detected_type="$type"
      break
    fi
  done

  # Detect complexity
  detected_complexity="moderate"
  if echo "$lower_desc" | grep -qiE "$COMPLEXITY_SIMPLE" 2>/dev/null; then
    detected_complexity="simple"
  elif echo "$lower_desc" | grep -qiE "$COMPLEXITY_COMPLEX" 2>/dev/null; then
    detected_complexity="complex"
  fi

  # Detect budget
  detected_budget="standard"
  if echo "$lower_desc" | grep -qiE "free|cheap|low.cost|budget" 2>/dev/null; then
    detected_budget="free"
  elif echo "$lower_desc" | grep -qiE "premium|best|maximum|highest.quality" 2>/dev/null; then
    detected_budget="premium"
  fi

  echo "$detected_type|$detected_complexity|$detected_budget"
}

# ---------------------------------------------------------------------------
# Output formatting
# ---------------------------------------------------------------------------
print_header() {
  echo "=========================================="
  echo "  Model Selection"
  echo "=========================================="
  echo "  Registry snapshot: $REFRESH_DATE"
  echo "  Refresh: bash model-select.sh refresh"
  echo ""
}

print_recommendation() {
  task_type="$1" complexity="$2" budget="$3"

  echo "--- Task Classification ---"
  echo "  Type:       $task_type"
  echo "  Complexity: $complexity"
  echo "  Budget:     $budget"
  echo ""

  echo "--- Primary Recommendation ---"
  primary
  primary=$(recommend "$task_type" "$complexity" "$budget" | grep -v '^ALT:' | head -1)
  model provider reason
  IFS='|' read -r model provider reason <<< "$primary"
  echo "  Model:    $model"
  echo "  Provider: $provider"
  echo "  Reason:   $reason"
  echo ""

  echo "--- Alternatives ---"
  recommend "$task_type" "$complexity" "$budget" | grep '^ALT:' | while IFS='|' read -r alt_label alt_model alt_reason; do
    alt_name="${alt_label#ALT:}"
    echo "  - $alt_name  ($alt_reason)"
  done
  echo ""

  echo "--- Decision Packet ---"
  echo "  Selected:   $model"
  echo "  Confidence: $( [[ "$task_type" == "coding" || "$task_type" == "debugging" ]] && echo "7/10" || echo "6/10" )"
  echo "  Objections: benchmarks are directional; verify with local tests"
  echo "  Reopen if:  task hits provider quota or quality threshold not met"
}

# ---------------------------------------------------------------------------
# Subcommands
# ---------------------------------------------------------------------------
case "$CMD" in
  classify)
    description="$*"
    if [[ -z "$description" ]]; then
      echo "ERROR: task description required" >&2
      exit 2
    fi

    print_header
    classification=$(classify_task "$description")
    IFS='|' read -r task_type complexity budget <<< "$classification"
    print_recommendation "$task_type" "$complexity" "$budget"
    ;;

  by-type)
    task_type="${1:-}"
    if [[ -z "$task_type" ]] || [[ ! "${TASK_TYPES[$task_type]:-}" ]]; then
      echo "ERROR: valid task type required. One of: ${!TASK_TYPES[*]}" >&2
      exit 2
    fi

    print_header
    print_recommendation "$task_type" "moderate" "standard"
    ;;

  compare)
    model_a="${1:-}" model_b="${2:-}"
    if [[ -z "$model_a" || -z "$model_b" ]]; then
      echo "ERROR: usage: model-select.sh compare <model-A> <model-B>" >&2
      exit 2
    fi
    echo "Comparison: $model_a vs $model_b"
    echo ""
    echo "  Quick lookup against registry..."
    echo "  See docs/model-selection-guide.md for detailed benchmarks"
    echo ""
    # Grep the guide for both models
    guide="$REPO_ROOT/docs/model-selection-guide.md"
    if [[ -f "$guide" ]]; then
      echo "  From model-selection-guide.md:"
      grep -i -A2 "$model_a" "$guide" 2>/dev/null | head -6 | sed 's/^/    /'
      echo ""
      grep -i -A2 "$model_b" "$guide" 2>/dev/null | head -6 | sed 's/^/    /'
    fi
    ;;

  refresh)
    echo "=== Monthly Refresh Checklist ==="
    echo ""
    echo "1. Check model availability:"
    echo "   - https://developers.openai.com/api/docs/models"
    echo "   - https://www.anthropic.com/claude/opus"
    echo "   - https://ai.google.dev/gemini-api/docs/models"
    echo "2. Check rankings:"
    echo "   - https://openrouter.ai/rankings"
    echo "   - https://openrouter.ai/collections/programming"
    echo "3. Update docs/model-selection-guide.md with changes"
    echo "4. Update the routing table in model-select.sh (REFRESH_DATE + recommend function)"
    echo ""
    echo "Current registry: $REFRESH_DATE"
    ;;

  help|--help|-h|*)
    cat <<'EOF'
Usage:
  classify <task-description>
      Auto-detect task type + complexity, recommend model.
      Example: classify "implement a new authentication middleware"

  by-type <task-type>
      Quick lookup: coding, debugging, research, writing,
      architecture, extraction, multimodal, planning.

  compare <model-A> <model-B>
      Side-by-side reference to model-selection-guide.md.

  refresh
      Show monthly refresh checklist.
EOF
    exit 0
    ;;
esac
