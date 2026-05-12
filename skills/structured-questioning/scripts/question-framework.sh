#!/usr/bin/env bash
# question-framework.sh — Structured Question Decomposition
#
# Companion script for the structured-questioning skill.
# Automates the 5W+H checklist, Socratic self-probe, and ACI formatting.
#
# INTERACTIVE modes (for human use):
#   bash question-framework.sh checklist "question"  — guided 5W+H fill-in
#   bash question-framework.sh socratic "question"   — guided Socratic probe
#   bash question-framework.sh full "question"       — both phases
#
# NON-INTERACTIVE modes (for AI auto-call — no stdin needed):
#   bash question-framework.sh analyze "question"    — JSON analysis of missing 5W+H dimensions
#   bash question-framework.sh probe "question"      — structured probe questions per gap
#   bash question-framework.sh aci "question"        — outputs an ACI-optimized version

set -euo pipefail

MODE="${1:-help}"
QUESTION="${2:-}"

# ── Colors ──────────────────────────────────────────────────────────────
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${BOLD}${CYAN}═══ $1 ═══${NC}"
    echo ""
}

print_field() {
    echo -e "  ${GREEN}$1${NC}: $2"
}

# ── Help ─────────────────────────────────────────────────────────────────
if [[ "$MODE" == "help" || "$MODE" == "--help" || "$MODE" == "-h" ]]; then
    echo "Usage:"
    echo "  bash question-framework.sh analyze \"question\"   # non-interactive"
    echo "  bash question-framework.sh probe \"question\"    # non-interactive"
    echo "  bash question-framework.sh aci \"question\"      # non-interactive"
    echo "  bash question-framework.sh checklist \"question\" # interactive"
    echo "  bash question-framework.sh socratic \"question\"  # interactive"
    echo "  bash question-framework.sh full \"question\"      # interactive"
    echo ""
    echo "Non-interactive modes (for AI auto-call):"
    echo "  analyze  — JSON output of which 5W+H dimensions are present/missing"
    echo "  probe    — Structured probe questions per missing dimension"
    echo "  aci      — ACI-optimized rewrite of your question"
    echo ""
    echo "Interactive modes (for human use):"
    echo "  checklist  — Prompt you through the 5W+H pre-flight scan"
    echo "  socratic   — Generate Socratic probe questions"
    echo "  full       — Run both phases in sequence"
    exit 0
fi

# ── Mode: analyze (non-interactive, JSON output) ───────────────────────────
do_analyze() {
    local q="$1"
    local fields=("Who" "What" "When" "Where" "Why" "How")
    local present=0
    local missing=0
    local missing_list=""

    for field in "${fields[@]}"; do
        # Heuristic: check if the question text mentions anything related to this dimension
        local field_lower
        field_lower=$(echo "$field" | tr '[:upper:]' '[:lower:]')
        local q_lower
        q_lower=$(echo "$q" | tr '[:upper:]' '[:lower:]')

        # These are simple heuristics — the AI should use judgment
        local found=false
        case "$field_lower" in
            who)
                if echo "$q_lower" | grep -Eq '(who|user|customer|team|developer|person|stakeholder|engineer|admin|agent)'; then found=true; fi ;;
            what)
                if echo "$q_lower" | grep -Eq '(what|need|want|build|create|fix|change|implement|feature|thing|output|result|deliverable)'; then found=true; fi ;;
            when)
                if echo "$q_lower" | grep -Eq '(when|deadline|before|after|sprint|by |urgent|time|schedule|asap|timeline)'; then found=true; fi ;;
            where)
                if echo "$q_lower" | grep -Eq '(where|in |at |component|module|file|page|screen|environment|location)'; then found=true; fi ;;
            why)
                if echo "$q_lower" | grep -Eq '(why|because|goal|purpose|motivation|reason|priority|business|value)'; then found=true; fi ;;
            how)
                if echo "$q_lower" | grep -Eq '(how|method|approach|way|using|via|with|by |tool|framework)'; then found=true; fi ;;
        esac

        if $found; then
            ((present++))
        else
            ((missing++))
            [[ -n "$missing_list" ]] && missing_list+=", "
            missing_list+="$field"
        fi
    done

    # Don't try to use true JSON with bash — output structured text
    echo ""
    echo "=== ANALYSIS ==="
    echo "Question: $q"
    echo "Dimensions present: $present/6"
    if (( missing > 0 )); then
        echo "Dimensions missing: $missing_list"
        echo "Verdict: INCOMPLETE — probe before proceeding"
    else
        echo "Dimensions missing: (none)"
        echo "Verdict: COMPLETE — ready for action"
    fi
    echo "=== END ==="
}

# ── Mode: probe (non-interactive, outputs structured questions) ────────────
do_probe() {
    local q="$1"
    echo ""
    echo "=== PROBES ==="
    echo "Your request is missing context. I need to clarify before proceeding:"

    local q_lower
    q_lower=$(echo "$q" | tr '[:upper:]' '[:lower:]')

    if ! echo "$q_lower" | grep -qE '(who|user|customer|team|developer|person|stakeholder|engineer|admin|agent)'; then
        echo ""
        echo "---"
        echo "Q: Who is this for? (stakeholder, audience, agent persona)"
        echo "Context: Without knowing who, I can't scope the work correctly."
        echo "Recommended: The end user / the dev team / an automated agent"
        echo "Impact on answer: Changes the tools, language, and depth needed."
    fi

    if ! echo "$q_lower" | grep -qE '(what|need|want|build|create|fix|change|implement|feature|thing|output|result|deliverable)'; then
        echo ""
        echo "---"
        echo "Q: What exactly is needed? (deliverable, output, format)"
        echo "Context: 'What' is the most critical dimension — the actual ask."
        echo "Recommended: A specific deliverable (code, doc, analysis, etc.)"
        echo "Impact on answer: Different deliverables = completely different approaches."
    fi

    if ! echo "$q_lower" | grep -qE '(when|deadline|before|after|sprint|by |urgent|time|schedule|asap|timeline)'; then
        echo ""
        echo "---"
        echo "Q: When is this needed? (deadline, sequence, blockers)"
        echo "Context: Time constraints affect scope, quality, and approach."
        echo "Recommended: <specific timeframe or milestone>"
        echo "Impact on answer: Urgent = simplest path. Flexible = more thorough approach."
    fi

    if ! echo "$q_lower" | grep -qE '(where|in |at |component|module|file|page|screen|environment|location)'; then
        echo ""
        echo "---"
        echo "Q: Where does this apply? (context, environment, scope boundary)"
        echo "Context: Without scope boundaries, I may over- or under-deliver."
        echo "Recommended: <specific component, file, environment, or scope>"
        echo "Impact on answer: Changes the boundaries of what I do."
    fi

    if ! echo "$q_lower" | grep -qE '(why|because|goal|purpose|motivation|reason|priority|business|value)'; then
        echo ""
        echo "---"
        echo "Q: Why does this matter? (goal, priority, trade-off weight)"
        echo "Context: Understanding the 'why' helps me make the right trade-offs."
        echo "Recommended: <business goal, user need, or problem being solved>"
        echo "Impact on answer: Changes how I prioritize depth vs. speed vs. quality."
    fi

    if ! echo "$q_lower" | grep -qE '(how|method|approach|way|using|via|with|by |tool|framework)'; then
        echo ""
        echo "---"
        echo "Q: How should it be approached? (method, constraints, preferred tools)"
        echo "Context: Knowing your preferred approach avoids wasted alternatives."
        echo "Recommended: <specific method, constraint, or tool preference>"
        echo "Impact on answer: Narrows the solution space significantly."
    fi

    echo ""
    echo "=== END ==="
}

# ── Mode: aci (non-interactive, outputs ACI-optimized version) ──────────────
do_aci() {
    local q="$1"
    echo ""
    echo "=== ACI-OPTIMIZED ==="
    echo "To give an agent this task effectively, include all known context:"
    echo ""
    echo "Task: $q"
    echo ""
    echo "Fill in what you know:"
    echo "  For [who], [what] is needed by [when]"
    echo "  in [where], because [why]."
    echo "  Preferred approach: [how]."
    echo ""
    echo "=== END ==="
}

# ── Mode: checklist (interactive) ──────────────────────────────────────────
do_checklist() {
    local q="$1"
    print_header "5W+H Pre-Flight Checklist"
    echo -e "  Question: ${BOLD}$q${NC}"
    echo ""

    local fields=(
        "Who|Who is involved? (stakeholders, subject, audience, agent persona)"
        "What|What is needed? (deliverable, content, format)"
        "When|When is it needed? (deadline, sequence, dependencies)"
        "Where|Where does this apply? (context, environment, scope)"
        "Why|Why does this matter? (motivation, priority, trade-offs)"
        "How|How should it be done? (method, constraints, approach)"
    )

    local missing=0
    for field in "${fields[@]}"; do
        local label="${field%%|*}"
        local prompt="${field##*|}"
        echo -e "  ${YELLOW}${label}${NC}: ${prompt}"
        read -r answer
        if [[ -z "$answer" ]]; then
            echo -e "  ${RED}  ⚠ Left blank — consider if this matters${NC}"
            ((missing++))
        fi
        echo ""
    done

    if (( missing > 0 )); then
        echo -e "${YELLOW}⚠ ${missing} field(s) were left blank. Review whether they're truly optional.${NC}"
    else
        echo -e "${GREEN}✓ All 5W+H fields covered.${NC}"
    fi

    echo ""
    echo -e "${BOLD}Revised question template:${NC}"
    echo -e "  For ${CYAN}[Who]${NC}, ${CYAN}[What]${NC} is needed by ${CYAN}[When]${NC}"
    echo -e "  in the context of ${CYAN}[Where]${NC}, because ${CYAN}[Why]${NC}."
    echo -e "  Preferred approach: ${CYAN}[How]${NC}."
}

# ── Mode: socratic (interactive) ───────────────────────────────────────────
do_socratic() {
    local q="$1"
    print_header "Socratic Self-Probe"
    echo -e "  Question: ${BOLD}$q${NC}"
    echo ""

    local probes=(
        "Clarification|What exactly do you mean by each key term in this question?"
        "Assumptions|What are you assuming about the context, the data, or the recipient?"
        "Evidence|What makes you believe this is the right question to ask right now?"
        "Perspectives|How would someone with a different background interpret this?"
        "Implications|If you get the answer you expect, what changes? What breaks?"
        "Meta|Is this the most useful question to ask, or is there a deeper one underneath?"
    )

    for probe in "${probes[@]}"; do
        local label="${probe%%|*}"
        local text="${probe##*|}"
        echo -e "  ${YELLOW}${label}${NC}"
        echo -e "  ${text}"
        read -r answer
        if [[ -n "$answer" ]]; then
            echo -e "  ${GREEN}→${NC} $answer"
        fi
        echo ""
    done

    echo -e "${BOLD}Final question after Socratic probe:${NC}"
    read -r revised
    if [[ -n "$revised" ]]; then
        echo -e "  ${GREEN}Revised:${NC} $revised"
    else
        echo -e "  ${YELLOW}(no revision — question unchanged)${NC}"
    fi
}

# ── Mode: full (interactive) ───────────────────────────────────────────────
do_full() {
    local q="$1"
    echo -e "${BOLD}${GREEN}═══════════════════════════════════════════${NC}"
    echo -e "${BOLD}${GREEN}  FULL STRUCTURED QUESTIONING WORKFLOW${NC}"
    echo -e "${BOLD}${GREEN}═══════════════════════════════════════════${NC}"
    do_checklist "$q"
    echo ""
    echo -e "${BOLD}Press Enter to continue to Socratic probing...${NC}"
    read -r
    do_socratic "$q"
    print_header "Done"
    echo -e "  ${GREEN}✓${NC} Question decomposed and probed."
    echo -e "  ${GREEN}✓${NC} Hidden assumptions surfaced."
    echo -e "  ${GREEN}✓${NC} ACI-ready framing available."
    echo ""
}

# ── Dispatch ─────────────────────────────────────────────────────────────
case "$MODE" in
    analyze)   do_analyze "$QUESTION"   ;;
    probe)     do_probe "$QUESTION"     ;;
    aci)       do_aci "$QUESTION"       ;;
    checklist) do_checklist "$QUESTION" ;;
    socratic)  do_socratic "$QUESTION"  ;;
    full)      do_full "$QUESTION"      ;;
    *)
        echo -e "${RED}Unknown mode: $MODE${NC}"
        echo "Use: analyze, probe, aci, checklist, socratic, or full"
        exit 1
        ;;
esac
