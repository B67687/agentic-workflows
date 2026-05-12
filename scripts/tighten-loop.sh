#!/usr/bin/env bash
# Companion script for tighten-loop skill
# Harvest conversation-level steers into durable fixes
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [args]

Commands:
  classify <steer>  Classify a steer by gap type (context/harness/feedback/scope)
  route <intent>    Route to fix tool (project-instruction, agent-config, etc.)
  report [file]     Generate report from harvested steers JSON
  template          Report table template
  help              Show this help
EOF
}

cmd="${1:-help}"
shift 2>/dev/null || true

case "$cmd" in
  classify)
    steer="${1:-}"
    echo "★ Gap Classification ───────────────────────────"
    echo "Steer: $steer"
    echo ""
    echo "| Gap | Agent lacked... | Example |"
    echo "|-----|-----------------|---------|"
    echo "| Context | Information | Convention not in CLAUDE.md, missing ADR |"
    echo "| Harness | Tools/access | Missing MCP, CLI, skill |"
    echo "| Feedback | Way to verify | No tests, no browser QA |"
    echo "| Scope | Boundaries | Took on decision needing human |"
    echo "─────────────────────────────────────────────────"
    ;;
  route)
    intent="${1:-}"
    echo "★ Intent Routing ───────────────────────────────"
    case "$intent" in
      project-instruction)
        echo "Durable rule agent should follow in this repo"
        echo "→ Update CLAUDE.md or AGENTS.md"
        ;;
      agent-config)
        echo "Harness behavior change — hooks, permissions, env"
        echo "→ Update .claude/settings.json or opencode.jsonc"
        ;;
      tool-install)
        echo "Missing capability — MCP server, CLI, API"
        echo "→ Install the specific tool"
        ;;
      new-skill)
        echo "Repeated multi-step task should become reusable"
        echo "→ Create skills/<name>/SKILL.md"
        ;;
      skill-update)
        echo "Existing skill needs adjustment"
        echo "→ Edit skills/<name>/SKILL.md"
        ;;
      test-coverage)
        echo "Missing verification path"
        echo "→ Add tests or browser-QA scaffolding"
        ;;
      *)
        echo "Unknown intent. Options: project-instruction, agent-config, tool-install, new-skill, skill-update, test-coverage"
        ;;
    esac
    echo "─────────────────────────────────────────────────"
    ;;
  report)
    file="${1:-}"
    echo "★ Tighten Loop ──────────────────────────────────"
    echo "[N] steers harvested — [N context] / [N harness] / [N feedback] / [N scope]"
    echo "  ├─ [most impactful finding]"
    echo "  ├─ [second]"
    echo "  └─ [top recommended fix]"
    echo "─────────────────────────────────────────────────"
    echo ""
    if [[ -n "$file" && -f "$file" ]]; then
      cat "$file"
    else
      echo "| # | Steer | Gap | Intent | Fix |"
      echo "|---|-------|-----|--------|-----|"
      echo "|   |       |     |        |     |"
    fi
    ;;
  template)
    echo "| # | Steer (paraphrased) | Gap | Intent | Concrete fix |"
    echo "|---|----------------------|-----|--------|---------------|"
    echo "| 1 | [steer] | context/harness/feedback/scope | [intent] | [specific fix] |"
    ;;
  help|*)
    usage
    ;;
esac
