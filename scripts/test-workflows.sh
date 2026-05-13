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
cd "$REPO_ROOT"

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
