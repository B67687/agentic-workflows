#!/usr/bin/env bash
# =============================================================================
# doubt-adversarial.sh --- Companion script for Doubt-Driven Development
#
# Automates Steps 2-4 of the doubt cycle:
#   Step 2: EXTRACT --- format artifact + contract for review
#   Step 3: DOUBT  --- generate adversarial prompt, write to temp file
#   Step 4: RECONCILE --- structure findings classification
#
# Usage:
#   bash ./scripts/doubt-adversarial.sh prompt    # generate adversarial prompt
#   bash ./scripts/doubt-adversarial.sh reconcile # output RECONCILE template
#   bash ./scripts/doubt-adversarial.sh full      # interactive full cycle
#
# For Step 3 (cross-model), pipe the prompt file to an external CLI:
#   bash ./scripts/doubt-adversarial.sh prompt > /tmp/doubt-prompt.md
#   gemini --approval-mode plan -p "" < /tmp/doubt-prompt.md
#   codex exec --sandbox read-only -C <repo-path> - < /tmp/doubt-prompt.md
# =============================================================================

set -euo pipefail

MODE="${1:-full}"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

case "$MODE" in
  prompt)
    # === Step 3: DOUBT --- Generate adversarial prompt ===
    # Expects ARTIFACT + CONTRACT via stdin heredoc or pipe.
    # Writes the adversarial prompt to stdout for piping or redirect.

    if [ ! -t 0 ]; then
      INPUT=$(cat)
    else
      echo "Paste ARTIFACT (end with CTRL+D on a blank line):" >&2
      ARTIFACT=$(cat)
      echo "" >&2
      echo "Paste CONTRACT (end with CTRL+D on a blank line):" >&2
      CONTRACT=$(cat)
      INPUT="ARTIFACT: ${ARTIFACT}
CONTRACT: ${CONTRACT}"
    fi

    # Extract sections
    ARTIFACT_TEXT=$(echo "$INPUT" | sed -n '/^ARTIFACT:/,/^CONTRACT:/p' | sed '1d;$d')
    CONTRACT_TEXT=$(echo "$INPUT" | sed -n '/^CONTRACT:/,$p' | sed '1d')

    # Validate artifact size
    LINE_COUNT=$(echo "$ARTIFACT_TEXT" | wc -l)
    if [ "$LINE_COUNT" -gt 100 ]; then
      echo "WARNING: Artifact is $LINE_COUNT lines. Consider decomposing." >&2
      echo "Recommend: max 100 lines for one-shot review." >&2
      echo "" >&2
    fi

    cat << PROMPT
Adversarial review. Find what is wrong with this artifact.
Assume the author is overconfident. Look for:
- Unstated assumptions
- Edge cases not handled
- Hidden coupling or shared state
- Ways the contract could be violated
- Existing conventions this might break
- Failure modes under unexpected input

Do NOT validate. Do NOT summarize. Find issues, or state
explicitly that you cannot find any after thorough examination.

ARTIFACT:
$(echo "$ARTIFACT_TEXT")

CONTRACT:
$(echo "$CONTRACT_TEXT")
PROMPT
    ;;

  reconcile)
    # === Step 4: RECONCILE --- Structured classification template ===
    # Outputs a blank RECONCILE template for filling in.
    # Each finding from the reviewer gets classified.

    echo "# Doubt Cycle --- Reconciliation"
    echo ""
    echo "## Review Source"
    echo "- Model: <model-or-tool>"
    echo "- Artifact size: <lines>"
    echo ""
    echo "## Findings"
    echo ""
    echo "### Finding 1: <short description>"
    echo "- [ ] **Contract misread** --- contract was unclear or incomplete"
    echo "  -> Fix contract, re-classify on next cycle"
    echo "- [ ] **Valid + actionable** --- real issue requiring change"
    echo "  -> Change artifact, re-loop"
    echo "- [ ] **Valid trade-off** --- real but cost > benefit"
    echo "  -> Document explicitly for user"
    echo "- [ ] **Noise** --- correct under context reviewer lacked"
    echo "  -> Note it, move on. Would adding context to contract have prevented?"
    echo ""
    echo "### Finding 2: <short description>"
    echo "- [ ] Contract misread"
    echo "- [ ] Valid + actionable"
    echo "- [ ] Valid trade-off"
    echo "- [ ] Noise"
    echo ""
    echo "---"
    echo "Cycle: <1|2|3>"
    echo "Stop condition: <trivial findings | 3 cycles | user override>"
    echo "Cross-model offered: <yes | no (non-interactive)>"
    echo "Cross-model result: <accepted | skipped | not applicable>"
    ;;

  full)
    # === Full interactive doubt cycle ===
    # Walks through Step 2 (EXTRACT), Step 3 (DOUBT), and Step 4 (RECONCILE)

    echo "=== Doubt Cycle: EXTRACT ==="
    echo ""
    echo "CLAIM (what are you asserting? 2-3 lines):"
    read -r CLAIM
    echo ""
    echo "Why this matters (what's at stake?):"
    read -r STAKES
    echo ""
    echo "---"
    echo ""
    echo "ARTIFACT (paste the code/decision text, CTRL+D when done):"
    ARTIFACT=$(cat)
    echo ""
    echo "CONTRACT (what must the artifact satisfy? CTRL+D when done):"
    CONTRACT=$(cat)
    echo ""

    # Generate prompt file
    PROMPT_FILE=$(mktemp /tmp/doubt-prompt-XXXXXX.md)
    "$0" prompt << EOF > "$PROMPT_FILE"
ARTIFACT:
${ARTIFACT}
CONTRACT:
${CONTRACT}
EOF

    echo "=== Adversarial prompt written to: $PROMPT_FILE ==="
    echo "Lines: $(wc -l < "$PROMPT_FILE")"
    echo ""
    echo "To run cross-model review:"
    echo "  gemini --approval-mode plan -p \"\" < $PROMPT_FILE"
    echo "  codex exec --sandbox read-only -C <path> - < $PROMPT_FILE"
    echo ""
    echo "=== Doubt Cycle: RECONCILE template ==="
    echo "(Fill this after receiving reviewer output)"
    "$0" reconcile
    echo ""
    echo "=== Prompt file preserved at: $PROMPT_FILE ==="
    echo "Delete with: rm $PROMPT_FILE"
    ;;

  *)
    echo "Usage: $0 {prompt|reconcile|full}"
    echo ""
    echo "  prompt    --- Generate adversarial prompt from stdin ARTIFACT+CONTRACT"
    echo "  reconcile --- Output blank RECONCILE template"
    echo "  full      --- Interactive full doubt cycle (EXTRACT -> DOUBT -> RECONCILE)"
    exit 1
    ;;
esac
