#!/usr/bin/env bash
# Companion script for implementation-planning skill
# Create technical implementation plans with phases, file changes, verification
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [args]

Commands:
  locate <feature>  Sub-agent prompt structure for locating relevant files
  patterns <feat>   Sub-agent prompt for finding similar implementations
  analyze <feat>    Sub-agent prompt for analyzing related feature
  plan <title>      Implementation plan template
  phase <name>      Single phase template
  check <plan>      Check plan quality (specific, actionable?)
  help              Show this help
EOF
}

cmd="${1:-help}"
shift 2>/dev/null || true

case "$cmd" in
  locate)
    feature="${1:-}"
    cat <<EOF
★ Locate: $feature

Sub-agent prompt:
"Find all files related to [$feature]. Group by:
- Routes
- Use-cases/business logic
- Components
- DB schema
- Tests
Report file paths and directory structure only, don't read contents."
EOF
    ;;
  patterns)
    feature="${1:-}"
    cat <<EOF
★ Patterns: $feature

Sub-agent prompt:
"Find similar implementations to [$feature]. Read the code thoroughly.
Extract complete working examples with imports. Note file organization,
naming conventions, error handling approach."
EOF
    ;;
  analyze)
    feature="${1:-}"
    cat <<EOF
★ Analyze: $feature

Sub-agent prompt:
"Analyze how [$related feature] is implemented. Trace data flow from
entry point to DB/API. Map key functions, inputs/outputs, error paths."
EOF
    ;;
  plan)
    title="${1:-}"
    cat <<EOF
★ Implementation Plan: $title

## Overview
[1-2 sentences: what and why]

## Current State
[What exists now, what's missing, relevant code locations]

## Desired End State
[What should work when done, how to verify]

## Out of Scope
[What we're NOT doing — prevents scope creep]

## Implementation Approach
[High-level strategy]

### Phase 1: [Descriptive Name]

**What This Accomplishes:** [summary of phase goal]

**Changes:**
\`\`\`
File: path/to/file.ext
[Complete code, not snippets]
\`\`\`

**Phase Checks:**
- [ ] [build | typecheck | test command]
- [ ] [expected output]

### Phase N: [...]

## Testing Strategy
- [ ] Unit tests: [what to test]
- [ ] Integration: [scenarios]

## File Summary
directory/
├── file.ext  # Purpose

## Open Questions
- [Question] Recommend: [option] — [why]
EOF
    ;;
  phase)
    name="${1:-}"
    cat <<EOF
### Phase: $name

**What This Accomplishes:** [summary]

**Changes:**
\`\`\`
File: path/to/file.ext
[Complete code]
\`\`\`

**Phase Checks:**
- [ ] [command to run]
- [ ] [expected output]
EOF
    ;;
  check)
    plan="${1:-}"
    echo "★ Plan Quality Check ────────────────────────────"
    echo "Plan: $plan"
    echo ""
    echo "✓ File paths exist or clearly describe where to create?"
    echo "✓ Code snippets show COMPLETE implementation (no '...')?"
    echo "✓ Verification steps are concrete commands?"
    echo "✓ Expected outputs documented?"
    echo "✗ No vague statements ('update relevant components', 'add handling')?"
    echo "─────────────────────────────────────────────────"
    ;;
  help|*)
    usage
    ;;
esac
