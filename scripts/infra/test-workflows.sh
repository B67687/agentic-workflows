#!/bin/bash
# =============================================================================
# test-workflows.sh --- Structural and cross-reference tests for workflows
#
# Validates that the Agent Research Methodology and Macro-to-Micro Funnel
# documents are structurally complete, cross-referenced correctly, and free
# of stale content. These are NOT tool smoke tests --- they verify the workflow
# documentation itself is sound.
#
# Usage:
#   bash ./scripts/test-workflows.sh            # run all tests
#   bash ./scripts/test-workflows.sh --quick    # skip slow file-based tests
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT" || { echo "ERROR: cannot cd to $REPO_ROOT"; exit 1; }

PASS=0
FAIL=0
SKIP=0

MODE="${1:-all}"

WIKI_DIR="$REPO_ROOT/wiki"
STATE_DIR="$REPO_ROOT/state"

# === Test framework ===

test_pass() { PASS=$((PASS + 1)); echo "  ✓ $1"; }
test_fail() { FAIL=$((FAIL + 1)); echo "  ✗ $1"; }
test_skip() { SKIP=$((SKIP + 1)); echo "  - $1 (skipped)"; }

assert_file_contains() {
  local name="$1" file="$2" pattern="$3"
  if [ ! -f "$file" ]; then
    test_fail "$name (file not found: $file)"
    return
  fi
  if grep -q "$pattern" "$file"; then
    test_pass "$name"
  else
    test_fail "$name (missing: '$pattern' in $file)"
  fi
}

assert_file_not_contains() {
  local name="$1" file="$2" pattern="$3"
  if [ ! -f "$file" ]; then
    test_fail "$name (file not found: $file)"
    return
  fi
  if grep -q "$pattern" "$file"; then
    test_fail "$name (found stale content: '$pattern')"
  else
    test_pass "$name"
  fi
}

assert_section_count() {
  local name="$1" file="$2" heading_pattern="$3" expected="$4"
  if [ ! -f "$file" ]; then
    test_fail "$name (file not found: $file)"
    return
  fi
  local count
  count=$(grep -c "$heading_pattern" "$file" 2>/dev/null || echo 0)
  if [ "$count" -eq "$expected" ]; then
    test_pass "$name"
  else
    test_fail "$name (expected $expected matches for '$heading_pattern', got $count)"
  fi
}

assert_section_order() {
  local name="$1" file="$2" heading_pattern="$3"
  # Verify headings appear in the expected order by checking their line numbers
  local lines
  lines=$(grep -n "$heading_pattern" "$file" 2>/dev/null | cut -d: -f1)
  if [ -z "$lines" ]; then
    test_fail "$name (no matches for '$heading_pattern')"
    return
  fi
  local prev=0
  while IFS= read -r line; do
    if [ "$line" -lt "$prev" ]; then
      test_fail "$name (out of order: line $line before $prev)"
      return
    fi
    prev=$line
  done <<< "$lines"
  test_pass "$name"
}

assert_file_exists() {
  local name="$1" file="$2"
  if [ -f "$file" ]; then
    test_pass "$name"
  else
    test_fail "$name (file not found: $file)"
  fi
}

assert_output_contains() {
  local name="$1" cmd="$2" pattern="$3"
  if output=$(eval "$cmd" 2>&1); then
    if echo "$output" | grep -q "$pattern"; then
      test_pass "$name"
    else
      test_fail "$name (output missing: '$pattern')"
    fi
  else
    test_fail "$name (exit $?)"
  fi
}

echo "=== Workflow Integrity Tests ==="
echo ""

# ===========================================================================
echo "--- Agent Research Methodology (research/research-prompt.md) ---"

RPM="research/research-prompt.md"
assert_file_exists "research-prompt.md exists" "$RPM"

# Core sections
assert_file_contains "Core Principles section" "$RPM" "## Core Principles"
assert_file_contains "Source Triangulation subsection" "$RPM" "### Source Triangulation"
assert_file_contains "Authority Weighting subsection" "$RPM" "### Authority Weighting"
assert_file_contains "Confidence Levels subsection" "$RPM" "### Confidence Levels"
assert_file_contains "Uncertainty Encoding subsection" "$RPM" "### Uncertainty Encoding"
assert_file_contains "Error Impact Audit subsection" "$RPM" "### Error Impact Audit"

# All 6 phases
assert_file_contains "Phase 0: Frame" "$RPM" "### Phase 0: Frame the Question"
assert_file_contains "Phase 1: Discover Local" "$RPM" "### Phase 1: Discover Local Knowledge"
assert_file_contains "Phase 2: Gather External" "$RPM" "### Phase 2: Gather External Sources"
assert_file_contains "Phase 3: Triangulate" "$RPM" "### Phase 3: Triangulate & Synthesize"
assert_file_contains "Phase 4: Apply" "$RPM" "### Phase 4: Apply to the Problem"
assert_file_contains "Phase 5: Preserve" "$RPM" "### Phase 5: Preserve"

# Architecture specialization
assert_file_contains "Architecture Analysis section" "$RPM" "## Architecture Analysis Specialization"
assert_file_contains "Architecture research questions" "$RPM" "### Architecture Research Questions"
assert_file_contains "Architecture analysis synthesis" "$RPM" "### Architecture Analysis (Phase 3"
assert_file_contains "Architecture output format" "$RPM" "### Architecture Output"

# Scope control
assert_file_contains "Scope Control section" "$RPM" "## Scope Control"

# Integration rules
assert_file_contains "Integration Rules section" "$RPM" "## Integration Rules"

# Anti-patterns
assert_file_contains "Anti-Patterns section" "$RPM" "## Anti-Patterns"

# No stale AI-specific content
assert_file_not_contains "No stale AI-specific content" "$RPM" "Prompting Knowledge Base"
assert_file_not_contains "No SWE-bench reference" "$RPM" "SWE-bench"
assert_file_not_contains "No BenchLM reference" "$RPM" "BenchLM"
assert_file_not_contains "No model benchmarks" "$RPM" "Model Benchmark"

# Count verification --- exactly 6 phases
assert_section_count "Exactly 6 phases in research-prompt.md" "$RPM" "^### Phase [0-5]:" 6

# Phase ordering (regression: no phase should be reordered or lost)
assert_section_order "Phases in document order" "$RPM" "^### Phase [0-9]:"

echo ""
echo "--- Macro-to-Micro Funnel (skills/debugging-and-error-recovery/SKILL.md) ---"

DBG="skills/debugging-and-error-recovery/SKILL.md"
assert_file_exists "Debugging skill exists" "$DBG"

# Funnel section
assert_file_contains "Macro-to-Micro Funnel section" "$DBG" "## The Macro-to-Micro Funnel"
assert_file_contains "Funnel is default behavior" "$DBG" "default behavior"

# All 4 levels
assert_file_contains "Level 1: System" "$DBG" "### Level 1"
assert_file_contains "Level 2: Domain" "$DBG" "### Level 2"
assert_file_contains "Level 3: Module" "$DBG" "### Level 3"
assert_file_contains "Level 4: Root Cause" "$DBG" "### Level 4"

# Why this sequence table
assert_file_contains "Why This Sequence table" "$DBG" "### Why This Sequence"

# Cross-reference to research methodology
assert_file_contains "Level 1 references research-prompt.md" "$DBG" "research/research-prompt.md"

# Cross-reference to AGENTS.md
assert_file_contains "Funnel references AGENTS.md" "$DBG" "AGENTS.md"

# Count verification --- exactly 4 levels
assert_section_count "Exactly 4 funnel levels" "$DBG" "^### Level [1-4]" 4

# Level ordering (regression: no level should be reordered or lost)
assert_section_order "Levels in document order" "$DBG" "^### Level [1-4]"

# Verification checklist update
assert_file_contains "Verification checklist has system understanding item" "$DBG" "System architecture was understood"

# Red Flags updates
assert_file_contains "Red Flag: jumping to code" "$DBG" "Jumping to code"
assert_file_contains "Red Flag: skipping funnel" "$DBG" "Skipping the funnel"

# Rationalizations updates
assert_file_contains "Rationalization: skipping system understanding" "$DBG" "I know where the fix goes"
assert_file_contains "Rationalization: error message file" "$DBG" "error message tells me"

echo ""
echo "--- Cross-Reference Consistency ---"

# AGENTS.md references
assert_file_contains "AGENTS.md references research-prompt.md in Default Research Conduct" \
  "AGENTS.md" "research/research-prompt.md"
assert_file_contains "AGENTS.md references debugging skill in Default Fix Conduct" \
  "AGENTS.md" "skills/debugging-and-error-recovery/SKILL.md"
assert_file_contains "AGENTS.md mentions 6-phase methodology" \
  "AGENTS.md" "Frame.*Discover Local.*Gather External.*Triangulate.*Apply.*Preserve"
assert_file_contains "AGENTS.md Key Rule mentions 6-phase" \
  "AGENTS.md" "Frame.*Discover Local.*Gather External.*Triangulate.*Apply.*Preserve"
assert_file_contains "AGENTS.md mentions macro-to-micro" \
  "AGENTS.md" "macro-to-micro"

# commands/research.md references
assert_file_contains "commands/research.md references research-prompt.md" \
  "commands/research.md" "research/research-prompt.md"
assert_file_contains "commands/research.md mentions macro-to-micro funnel" \
  "commands/research.md" "macro-to-micro"
assert_file_contains "commands/research.md has architecture path" \
  "commands/research.md" "Architecture / System Research"

# docs/workflow.md references
assert_file_contains "workflow.md Anti-Failure Rules has macro-to-micro" \
  "docs/workflow.md" "macro-to-micro"
assert_file_contains "workflow.md references research-prompt.md" \
  "docs/workflow.md" "research/research-prompt.md"

# Mirrors are synced
assert_file_contains ".opencode/commands/research.md synced" \
  ".opencode/commands/research.md" "6-phase"
assert_file_contains ".pi/prompts/research.md synced" \
  ".pi/prompts/research.md" "6-phase"

echo ""
echo "--- Integration: Tool Health ---"

# repo-map argument parsing regression test
assert_output_contains "repo-map.sh --max-tokens N works" \
  "bash scripts/repo-map.sh . --max-tokens 256 2>&1" \
  "Files scanned"

# search-index works
assert_output_contains "search-index.sh finds content" \
  "bash scripts/search-index.sh 'research methodology' 2>&1 | head -20" \
  "research"

# sync-commands is executable
assert_file_exists "sync-commands.sh is executable" \
  "scripts/sync-commands.sh"

# ═══════════════════════════════════════════════════════════════════════
# Workflow graph regression tests
# ═══════════════════════════════════════════════════════════════════════

WGF="workflow-graph.html"

if [ -f "$WGF" ]; then
  # 1. Zoom limits present
  assert_file_contains "wg: zoom MIN_ZOOM defined" "$WGF" "MIN_ZOOM = 0.12"
  assert_file_contains "wg: zoom MAX_ZOOM defined" "$WGF" "MAX_ZOOM = 4.0"
  assert_file_contains "wg: zoom uses zoomIn/zoomOut not moveTo" "$WGF" "zoomIn(MIN_ZOOM"
  assert_file_contains "wg: zoom has re-entrance guard" "$WGF" "zoomCorrecting"

  # 2. Legend has data attributes for highlight
  assert_file_contains "wg: legend-item has data-legend-group" "$WGF" "data-legend-group="
  assert_file_contains "wg: legend-edge-item has data-legend-edge" "$WGF" "data-legend-edge="

  # 3. Legend dimming + highlight logic
  assert_file_contains "wg: applyHighlight function" "$WGF" "function applyHighlight"
  assert_file_contains "wg: resetHighlight function" "$WGF" "function resetHighlight"
  assert_file_contains "wg: highlightActive flag" "$WGF" "highlightActive"
  assert_file_contains "wg: hover disabled when highlight active" "$WGF" "if (highlightActive) return;"

  # 4. Smart connected-node/edge dimming + font dimming
  assert_file_contains "wg: connected nodes from edge filter" "$WGF" "connectedNodes.add(e.from)"
  assert_file_contains "wg: connected edges from node filter" "$WGF" "visibleEdgeIndices"
  assert_file_contains "wg: edge LegendType helper" "$WGF" "function edgeLegendType"
  assert_file_contains "wg: font dimming on highlight" "$WGF" "newFont.color = 'rgba(80,90,110,0.15)'"
  assert_file_contains "wg: font restore on highlight reset" "$WGF" "origFonts"

  # 5. SVG companion exists and is valid
  if [ -f "workflow-graph.svg" ]; then
    if python3 -c "import xml.etree.ElementTree as ET; ET.parse('workflow-graph.svg')" 2>/dev/null; then
      test_pass "wg: SVG is valid XML"
    else
      test_fail "wg: SVG XML is invalid"
    fi
  else
    test_fail "wg: SVG file missing"
  fi

  # 6. Generator script executable
  assert_file_exists "wg: workflow-graph.py exists" "scripts/workflow-graph.py"
  assert_file_exists "wg: workflow-graph.sh exists" "scripts/workflow-graph.sh"

  # 7. docs/ copy exists for GitHub Pages
  assert_file_exists "wg: docs/workflow-graph.html exists for Pages" "docs/workflow-graph.html"

  # 8. README has the correct Workflows section
  assert_file_contains "wg: README links SVG in workflows section" "README.md" "workflow-graph.svg"
  assert_file_contains "wg: README links to hosted interactive" "README.md" "b67687.github.io/agentic-workflows/workflow-graph.html"

  # 9. Auto-discovery: gate plugins, agent personas, commands from filesystem
  if python3 -c "
import json, re, os

with open('workflow-graph.html') as f:
    html = f.read()
nodes_m = re.search(r'const NODES = (\[.*?\]);\s*\n\s*const EDGES', html, re.DOTALL)
if not nodes_m:
    print('FAIL: could not find NODES JSON')
    exit(1)
nodes = json.loads(nodes_m.group(1))

# Count agent-group nodes (personas from files + dispatch backends)
agent_count = sum(1 for n in nodes if n.get('group') == 'agent')
agent_files = [f for f in os.listdir('agents') if f.endswith('.md') and f != 'README.md']
agent_persona_count = sum(1 for n in nodes if n.get('group') == 'agent' and 'persona' in n.get('id', ''))
print(f'OK: {agent_persona_count} persona nodes for {len(agent_files)} agent files ({agent_count} total agent nodes)')
" 2>&1; then
    test_pass "wg: agent personas auto-discovered from agents/*.md"
  else
    test_fail "wg: agent personas auto-discovery failed"
  fi

  # 9b. Command count matches filesystem
  CMD_FS=$(ls commands/*.md 2>/dev/null | wc -l)
  CMD_HTML=$(python3 -c "
import json, re
with open('workflow-graph.html') as f:
    html = f.read()
m = re.search(r'const NODES = (\[.*?\]);', html, re.DOTALL)
nodes = json.loads(m.group(1))
for n in nodes:
    l = n.get('label', '')
    if '.opencode/commands/' in l.replace(chr(10), ' '):
        import re as r
        mm = r.search(r'(\d+) mirrored', l)
        if mm:
            print(mm.group(1))
            exit(0)
print('0')
" 2>/dev/null)
  if [ "$CMD_HTML" = "$CMD_FS" ] && [ -n "$CMD_HTML" ] && [ "$CMD_HTML" != "0" ]; then
    test_pass "wg: command count ($CMD_FS) matches filesystem"
  else
    test_fail "wg: command count mismatch (html='$CMD_HTML' fs='$CMD_FS')"
  fi

  # 10. Arrow markers use refX=6 (not 10) to prevent line overhang past arrow tip
  if [ -f "workflow-graph.svg" ]; then
    assert_file_contains "wg: arrow marker refX=6 (no overhang)" "workflow-graph.svg" 'refX="6"'
    assert_file_contains "wg: arrow stroke-linecap=butt" "workflow-graph.svg" 'stroke-linecap="butt"'
  else
    test_skip "wg: arrow checks (SVG not found)"
  fi

  # 11. Orphan detection: all nodes should have connections (0 orphans)
  if python3 -c "
import json, re
with open('workflow-graph.html') as f:
    html = f.read()
m = re.search(r'const NODES = (\[.*?\]);', html, re.DOTALL)
nodes = json.loads(m.group(1))
orphans = [n for n in nodes if n.get('orphaned')]
if orphans:
    print('FAIL: ' + ', '.join(o['id'] for o in orphans))
    exit(1)
print('OK: 0 orphans')
" 2>&1; then
    test_pass "wg: no orphaned nodes (all connected)"
  else
    test_fail "wg: orphaned nodes detected"
  fi
else
  test_skip "workflow-graph.html not generated (run 'bash scripts/workflow-graph.sh' first)"
fi

echo ""
echo "--- Results ---"
echo "  Pass: $PASS"
echo "  Fail: $FAIL"
echo "  Skip: $SKIP"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo "FAILURES DETECTED"
  exit 1
else
  echo "ALL TESTS PASSED"
  exit 0
fi
