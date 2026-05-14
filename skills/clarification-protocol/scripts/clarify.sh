#!/usr/bin/env bash
# clarify.sh --- Clarification Protocol companion script
#
# Companion script for the clarification-protocol skill.
# Provides automation for the decision gate, ambiguity analysis, and question generation.
#
# The agent calls these modes automatically when the Question Gate detects ambiguity.
# This script provides structured output that the agent uses to make triage decisions.
#
# Usage:
#   bash clarify.sh analyze "request"     --- ambiguity level + types detected
#   bash clarify.sh gate "request"        --- full triage decision (act/ask/offer)
#   bash clarify.sh question "request"    --- structured question template
#   bash clarify.sh check "request"       --- pre-flight clarity check
#   bash clarify.sh help                  --- this message
#
# Output format: structured text (not JSON) for agent parsing.

set -euo pipefail

MODE="${1:-help}"
REQUEST="${2:-}"

# ── Colors ──────────────────────────────────────────────────────────────
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${BOLD}${CYAN}═══ $1 ═══${NC}"
    echo ""
}

print_section() {
    echo -e "${BOLD}$1${NC}"
}

# ── Help ─────────────────────────────────────────────────────────────────
if [[ "$MODE" == "help" || "$MODE" == "--help" || "$MODE" == "-h" ]]; then
    echo "Usage:"
    echo "  bash clarify.sh analyze \"request\"    Ambiguity level + types detected"
    echo "  bash clarify.sh gate \"request\"       Full triage decision (act/ask/offer)"
    echo "  bash clarify.sh question \"request\"   Structured question template"
    echo "  bash clarify.sh check \"request\"      Pre-flight clarity check"
    echo ""
    echo "Non-interactive modes (for agent auto-call):"
    echo "  analyze   --- Heuristic ambiguity analysis of a user request"
    echo "  gate      --- Decision gate: confidence + risk + action recommendation"
    echo "  question  --- Generate question template for the One Good Question"
    echo "  check     --- Quick pre-flight: is this request clear enough?"
    exit 0
fi

# ── Mode: analyze ──────────────────────────────────────────────────────────
# Outputs: ambiguity level, detected types, missing dimensions
do_analyze() {
    local req="$1"
    local req_lower
    req_lower=$(echo "$req" | tr '[:upper:]' '[:lower:]')

    print_header "Ambiguity Analysis"

    echo -e "${BOLD}Request:${NC} $req"
    echo ""

    # Detect ambiguity types using heuristics
    # These are fast pre-checks --- the agent should use deeper LLM analysis
    local detected=()
    local clear=()

    # 1. Referential ambiguity (pronouns or vague references)
    if echo "$req_lower" | grep -qE '\b(it|that|this|those|there|the thing|the stuff)\b'; then
        detected+=("REFERENTIAL: Request contains vague pronouns ('it', 'that', 'this') without clear antecedent")
    else
        clear+=("REFERENTIAL: No vague pronouns detected")
    fi

    # 2. Missing target (action without clear target)
    if echo "$req_lower" | grep -qE '\b(fix|improve|optimize|update|change|handle|do|make|clean|sort)\b' && \
       ! echo "$req_lower" | grep -qE '\b(in |for |of |on |the |file|api|page|component|module|function)\b'; then
        detected+=("VAGUE_ACTION: Action verb present but no clear target")
    else
        clear+=("VAGUE_ACTION: Action has a clear target")
    fi

    # 3. Scope ambiguity
    if echo "$req_lower" | grep -qE '\b(all|everything|whole|entire|full)\b'; then
        detected+=("SCOPE: Broad scope qualifiers ('all', 'everything') -- boundaries unclear")
    fi
    if echo "$req_lower" | grep -qE '\b(some|somewhere|sometime|any|anything)\b'; then
        detected+=("SCOPE: Indefinite qualifiers ('some', 'any') -- scope ambiguous")
    fi

    # 4. Missing key parameters (deploy, delete, send without target)
    if echo "$req_lower" | grep -qE '\b(deploy|release|publish)\b' && \
       ! echo "$req_lower" | grep -qE '\b(to |service|app|environment|prod|staging)\b'; then
        detected+=("MISSING_INPUT: Deploy/release without target specified")
    fi
    if echo "$req_lower" | grep -qE '\b(delete|remove|destroy|drop)\b' && \
       ! echo "$req_lower" | grep -qE '\b(the |file|row|record|account|user|data)\b'; then
        detected+=("MISSING_INPUT + IRREVERSIBLE: Delete without specific target -- HIGH RISK")
    fi
    if echo "$req_lower" | grep -qE '\b(send|email|message|notify)\b' && \
       ! echo "$req_lower" | grep -qE '\b(to |user|customer|team|address)\b'; then
        detected+=("MISSING_INPUT: Send action without recipient")
    fi

    # 5. Conflicting requirements
    if echo "$req_lower" | grep -qE '\b(but |however|although|while|fast.*cheap|cheap.*good|quick.*quality)\b'; then
        detected+=("CONFLICTING: Request contains tradeoff indicators -- implicit conflict")
    fi

    # 6. Temporal ambiguity
    if echo "$req_lower" | grep -qE '\b(now|soon|later|asap|whenever|sometime)\b' && \
       ! echo "$req_lower" | grep -qE '\b(by |before|after|at |this week|today|tomorrow|sprint)\b'; then
        detected+=("TEMPORAL: Vague time reference -- no deadline specified")
    fi

    # 7. Irreversible action detection
    local irreversible=false
    if echo "$req_lower" | grep -qE '\b(delete|remove|destroy|drop|overwrite|replace|merge|push|deploy.*prod|send.*email|charge|pay|cancel|terminate)\b'; then
        irreversible=true
    fi

    echo -e "${BOLD}Detected ambiguities:${NC}"
    if [[ ${#detected[@]} -eq 0 ]]; then
        echo -e "  ${GREEN}None detected${NC} (request appears clear at heuristic level)"
    else
        for d in "${detected[@]}"; do
            echo -e "  ${YELLOW}⚠${NC}  $d"
        done
    fi

    echo ""
    echo -e "${BOLD}Clear dimensions:${NC}"
    if [[ ${#clear[@]} -eq 0 ]]; then
        echo "  (none)"
    else
        for c in "${clear[@]}"; do
            echo -e "  ${GREEN}✓${NC}  $c"
        done
    fi

    echo ""
    if $irreversible; then
        echo -e "${RED}⚠ IRREVERSIBLE ACTION DETECTED${NC}"
        echo "  Always ask for confirmation, even if confidence is high."
    fi

    local severity="LOW"
    if [[ ${#detected[@]} -ge 3 ]]; then
        severity="HIGH"
    elif [[ ${#detected[@]} -ge 1 ]]; then
        severity="MEDIUM"
    fi
    echo ""
    echo -e "${BOLD}Overall verdict:${NC} ${#detected[@]} ambiguity(-ies) detected -- severity: ${BOLD}$severity${NC}"
    echo "=== END ==="
}

# ── Mode: gate ─────────────────────────────────────────────────────────────
# Outputs: confidence estimate, risk assessment, recommended action
do_gate() {
    local req="$1"
    local req_lower
    req_lower=$(echo "$req" | tr '[:upper:]' '[:lower:]')

    print_header "Clarification Decision Gate"

    echo -e "${BOLD}Request:${NC} $req"
    echo ""

    # ── Factor 1: Confidence heuristic ──
    print_section "Factor 1: Confidence"
    local confidence_score=0
    local confidence_label=""

    # Check for specificity indicators
    if echo "$req_lower" | grep -qE '\b(in |on |at |for |with |using |via )\b'; then ((confidence_score+=2)); fi
    if echo "$req_lower" | grep -qE '\b(file|api|page|component|module|class|function|method)\b'; then ((confidence_score+=2)); fi
    if echo "$req_lower" | grep -qE '\b(because|so that|in order to|goal|purpose)\b'; then ((confidence_score+=1)); fi
    if echo "$req_lower" | grep -qE '\b(urgent|asap|by |before|after|sprint|today|this week)\b'; then ((confidence_score+=1)); fi
    if echo "$req_lower" | grep -qE '\b(not |except|unless|but |however|only)\b'; then ((confidence_score+=1)); fi

    # Check for ambiguity indicators
    local ambiguity_penalty=0
    if echo "$req_lower" | grep -qE '\b(it|that|this|the thing)\b'; then ((ambiguity_penalty+=2)); fi
    if echo "$req_lower" | grep -qE '\b(some|something|somewhere|any|anything)\b'; then ((ambiguity_penalty+=1)); fi
    if echo "$req_lower" | grep -qE '\b(fix|improve|optimize|make better|clean up)\b' && \
       ! echo "$req_lower" | grep -qE '\b(in |for |of |on )\b'; then ((ambiguity_penalty+=2)); fi
    if echo "$req_lower" | grep -qE '\b(all|everything|whole|entire)\b'; then ((ambiguity_penalty+=1)); fi

    local net_score=$((confidence_score - ambiguity_penalty))

    if [[ $net_score -ge 4 ]]; then
        confidence_label="HIGH (est. >0.85)"
    elif [[ $net_score -ge 2 ]]; then
        confidence_label="MODERATE (est. 0.7-0.85)"
    elif [[ $net_score -ge 0 ]]; then
        confidence_label="LOW (est. 0.3-0.7)"
    else
        confidence_label="VERY LOW (est. <0.3)"
    fi

    echo -e "  Score: ${BOLD}$net_score${NC} (confidence: +$confidence_score, ambiguity: -$ambiguity_penalty)"
    echo -e "  Estimate: ${BOLD}$confidence_label${NC}"
    echo ""

    # ── Factor 2: Reversibility ──
    print_section "Factor 2: Reversibility"
    local reversible=true
    local risk_level="low"

    if echo "$req_lower" | grep -qE '\b(delete|remove|destroy|drop|overwrite|replace)\b'; then
        reversible=false
        risk_level="high"
        echo -e "  ${RED}IRREVERSIBLE${NC} -- destructive action"
    elif echo "$req_lower" | grep -qE '\b(deploy.*prod|production|merge.*main|send.*email|charge|pay|cancel|terminate)\b'; then
        reversible=false
        risk_level="high"
        echo -e "  ${RED}IRREVERSIBLE${NC} -- high-impact action"
    elif echo "$req_lower" | grep -qE '\b(deploy|release|publish|merge|push|migrate)\b'; then
        reversible=false
        risk_level="medium"
        echo -e "  ${YELLOW}COSTLY IF WRONG${NC} -- reversible but impactful"
    else
        echo -e "  ${GREEN}REVERSIBLE${NC} -- low risk"
    fi
    echo ""

    # ── Factor 3: Cost of Wrong Action ──
    print_section "Factor 3: Cost of Wrong Action"
    local cost_level="trivial"

    if [[ "$risk_level" == "high" ]]; then
        cost_level="high"
        echo -e "  ${RED}HIGH${NC} -- wrong action has serious consequences"
    elif echo "$req_lower" | grep -qE '\b(database|schema|migration|refactor|redesign|rewrite|restructure)\b'; then
        cost_level="medium"
        echo -e "  ${YELLOW}MEDIUM${NC} -- wrong action requires significant rework"
    else
        echo -e "  ${GREEN}TRIVIAL${NC} -- wrong action easily corrected"
    fi
    echo ""

    # ── Decision ──
    print_section "Decision"

    local action=""
    local reasoning=""

    if [[ "$reversible" == "false" ]]; then
        action="ASK"
        reasoning="Irreversible action. Always ask for confirmation regardless of confidence."
    elif [[ $net_score -ge 4 ]]; then
        action="ACT"
        reasoning="High confidence + reversible. Proceed with stated assumptions."
    elif [[ $net_score -ge 2 ]]; then
        if [[ "$cost_level" == "high" ]]; then
            action="ASK"
            reasoning="Moderate confidence but high cost. Ask to be safe."
        else
            action="ACT"
            reasoning="Moderate confidence + reversible + low cost. Proceed with stated assumptions."
        fi
    elif [[ $net_score -ge 0 ]]; then
        action="ASK"
        reasoning="Low confidence. Ask one clarifying question before proceeding."
    else
        action="ASK"
        reasoning="Very low confidence. Must ask for clarification."
    fi

    echo -e "  ${BOLD}Recommended action:${NC} ${BOLD}$action${NC}"
    echo -e "  Reasoning: $reasoning"
    echo ""

    if [[ "$action" == "ACT" ]]; then
        echo -e "${GREEN}Proceed with execution.${NC}"
        echo "State these assumptions explicitly:"
        echo "  - [assumption 1 based on request context]"
        echo "  - [assumption 2 based on project patterns]"
        echo "  - [assumption 3 -- if wrong, user will correct]"
    elif [[ "$action" == "ASK" ]]; then
        echo -e "${YELLOW}Pause for clarification.${NC}"
        echo "Design one question following Phase 5 of the protocol:"
        echo "  1. Identify the single highest-impact ambiguity"
        echo "  2. Use the appropriate template (forking / missing key / risk confirm)"
        echo "  3. Include options + recommendation"
        echo "  4. End turn with the question (no tools, no extra text)"
    fi

    echo ""
    echo -e "Gate recommendation: ${BOLD}$action${NC} | confidence=$confidence_label | risk=$risk_level | cost=$cost_level"
    echo "=== END ==="
}

# ── Mode: question ─────────────────────────────────────────────────────────
# Outputs: structured question template for the agent to fill in
do_question() {
    local req="$1"
    local req_lower
    req_lower=$(echo "$req" | tr '[:upper:]' '[:lower:]')

    print_header "Structured Question Template"

    echo -e "${BOLD}Request:${NC} $req"
    echo ""
    echo "Use this template to ask your ONE clarifying question:"
    echo ""

    # Determine best question template
    local template="forking"
    if echo "$req_lower" | grep -qE '\b(delete|remove|destroy|deploy|send|charge|pay)\b'; then
        template="risk_confirm"
    elif echo "$req_lower" | grep -qE '\b(which|what is|what are|who is)\b'; then
        template="missing_key"
    elif echo "$req_lower" | grep -qE '\b(all|everything|scope|whole|full)\b'; then
        template="scope"
    fi

    echo -e "  ${BOLD}Template:${NC} $template"
    echo ""

    case "$template" in
        forking)
            echo "┌─────────────────────────────────────────────────────┐"
            echo "│ Header: [SHORT LABEL]" 
            echo "│"
            echo "│ Question: Do you mean [option A] or [option B]?"
            echo "│"
            echo "│ Options:"
            echo "│   A) [Option A] — [description of what this means]"
            echo "│   B) [Option B] — [description] (Recommended)"
            echo "│"
            echo "│ Why: [1 line — why this matters]"
            echo "│ Next: [1 line — what you'll do after answer]"
            echo "└─────────────────────────────────────────────────────┘"
            ;;
        risk_confirm)
            echo "┌─────────────────────────────────────────────────────┐"
            echo "│ Header: CONFIRM"
            echo "│"
            echo "│ Question: Confirm: should I [action]?"
            echo "│"
            echo "│ Options:"
            echo "│   Yes — Proceed with [action]" 
            echo "│   No — Skip this action"
            echo "│   Modified — [user types custom]"
            echo "│"
            echo "│ Why: This action is irreversible / high-impact."
            echo "│ Next: If yes, I'll proceed immediately."
            echo "└─────────────────────────────────────────────────────┘"
            ;;
        missing_key)
            echo "┌─────────────────────────────────────────────────────┐"
            echo "│ Header: [SHORT LABEL]"
            echo "│"
            echo "│ Question: What's the [missing parameter]?"
            echo "│"
            echo "│ Options:"
            echo "│   A) [candidate 1] — [description]"
            echo "│   B) [candidate 2] — [description] (Recommended)"
            echo "│   C) [Custom — type your answer]"
            echo "│"
            echo "│ Why: I need this to proceed with [action]."
            echo "│ Next: Once specified, I'll [next step]."
            echo "└─────────────────────────────────────────────────────┘"
            ;;
        scope)
            echo "┌─────────────────────────────────────────────────────┐"
            echo "│ Header: SCOPE"
            echo "│"
            echo "│ Question: Should this apply to [scope A] or [scope B]?"
            echo "│"
            echo "│ Options:"
            echo "│   A) [Scope A] — [description of boundaries]"
            echo "│   B) [Scope B] — [description] (Recommended)"
            echo "│   C) [Custom — describe the scope]"
            echo "│"
            echo "│ Why: Without scope boundaries I may over- or under-deliver."
            echo "│ Next: I'll work within the specified scope."
            echo "└─────────────────────────────────────────────────────┘"
            ;;
    esac

    echo ""
    echo "=== END ==="
}

# ── Mode: check ────────────────────────────────────────────────────────────
# Outputs: pass/fail pre-flight clarity check
do_check() {
    local req="$1"
    local req_lower
    req_lower=$(echo "$req" | tr '[:upper:]' '[:lower:]')

    print_header "Pre-Flight Clarity Check"

    echo -e "${BOLD}Request:${NC} $req"
    echo ""

    # Run the heuristic analysis
    local checks_passed=0
    local checks_total=6

    # Check 1: Has a clear target?
    if echo "$req_lower" | grep -qE '\b(file|api|page|component|module|class|function|function|db|table|repo|service)\b'; then
        echo -e "  ${GREEN}✓${NC} Has clear target"
        ((checks_passed++))
    else
        echo -e "  ${YELLOW}✗${NC} Missing clear target (file, component, or module)"
    fi

    # Check 2: Has a specific action verb?
    if echo "$req_lower" | grep -qE '\b(add|create|write|implement|fix|update|rename|delete|refactor|move|extract|change|optimize|test)\b'; then
        echo -e "  ${GREEN}✓${NC} Has specific action verb"
        ((checks_passed++))
    else
        echo -e "  ${YELLOW}✗${NC} Vague or missing action verb ('handle', 'do', 'work on')"
    fi

    # Check 3: Has scope boundaries?
    if echo "$req_lower" | grep -qE '\b(only|just|specifically|not |except|unless|but |however)\b'; then
        echo -e "  ${GREEN}✓${NC} Has scope boundaries"
        ((checks_passed++))
    else
        echo -e "  ${YELLOW}✗${NC} No scope boundaries (may be too broad)"
    fi

    # Check 4: Has context/motivation?
    if echo "$req_lower" | grep -qE '\b(because|so that|in order to|goal|purpose|reason|motivation|why|for)\b'; then
        echo -e "  ${GREEN}✓${NC} Has context or motivation"
        ((checks_passed++))
    else
        echo -e "  ${YELLOW}✗${NC} Missing context (why this matters)"
    fi

    # Check 5: Has constraints?
    if echo "$req_lower" | grep -qE '\b(using|with |via |in |for |on |at |by |before|after|urgent|asap|deadline)\b'; then
        echo -e "  ${GREEN}✓${NC} Has constraints or preferences"
        ((checks_passed++))
    else
        echo -e "  ${YELLOW}✗${NC} No constraints specified"
    fi

    # Check 6: Irreversible?
    if echo "$req_lower" | grep -qE '\b(delete|remove|destroy|overwrite|replace|deploy.*prod|send.*email|charge|pay)\b'; then
        echo -e "  ${RED}⚠${NC} Action appears irreversible — clarification recommended regardless"
    else
        echo -e "  ${GREEN}✓${NC} Action is reversible"
        ((checks_passed++))
    fi

    echo ""
    local verdict="PASS"
    local threshold=4
    if [[ $checks_passed -lt $threshold ]]; then
        verdict="NEEDS_CLARIFICATION"
    fi

    echo -e "${BOLD}Result:${NC} $checks_passed/$checks_total checks passed"
    echo -e "${BOLD}Verdict:${NC} ${BOLD}$verdict${NC}"

    if [[ "$verdict" == "NEEDS_CLARIFICATION" ]]; then
        echo ""
        echo "Run the full protocol:"
        echo "  bash clarify.sh analyze \"$req\""
        echo "  bash clarify.sh gate \"$req\""
    fi

    echo "=== END ==="
}

# ── Dispatch ─────────────────────────────────────────────────────────────
case "$MODE" in
    analyze)  do_analyze "$REQUEST"  ;;
    gate)     do_gate "$REQUEST"    ;;
    question) do_question "$REQUEST" ;;
    check)    do_check "$REQUEST"   ;;
    *)
        echo -e "${RED}Unknown mode: $MODE${NC}"
        echo "Use: analyze, gate, question, or check"
        exit 1
        ;;
esac
