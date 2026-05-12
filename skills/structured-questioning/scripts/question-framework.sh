#!/usr/bin/env bash
# question-framework.sh — Structured Question Decomposition
#
# Companion script for the structured-questioning skill.
# Automates the 5W+H checklist and Socratic self-probe.
#
# Usage:
#   bash question-framework.sh checklist "your question"
#   bash question-framework.sh full "your question"
#   bash question-framework.sh socratic "your question"

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
    echo "  bash question-framework.sh checklist \"your question\""
    echo "  bash question-framework.sh full \"your question\""
    echo "  bash question-framework.sh socratic \"your question\""
    echo ""
    echo "Modes:"
    echo "  checklist  — Prompt you through the 5W+H pre-flight scan"
    echo "  socratic   — Generate Socratic probe questions"
    echo "  full       — Run both phases in sequence"
    exit 0
fi

# ── Mode: checklist ──────────────────────────────────────────────────────
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

# ── Mode: socratic ───────────────────────────────────────────────────────
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

# ── Mode: full ───────────────────────────────────────────────────────────
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
    checklist) do_checklist "$QUESTION" ;;
    socratic)  do_socratic "$QUESTION"  ;;
    full)      do_full "$QUESTION"      ;;
    *)
        echo -e "${RED}Unknown mode: $MODE${NC}"
        echo "Use: checklist, socratic, or full"
        exit 1
        ;;
esac
