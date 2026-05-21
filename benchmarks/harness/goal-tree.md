---
id: harness-goal-tree
name: Navigate and report goal tree hierarchy
type: harness
difficulty: easy
estimated_time: 2min
skills: [goal-tree-navigation, harness-orientation]
verification: |
  output="$RUN_DIR/output.md"
  if [ ! -f "$output" ]; then echo "FAIL: no output file at $output"; exit 1; fi
  # Check for at least one top-level goal reference and hierarchy indent
  goals=$(grep -ciE '\bGoal\b' "$output" 2>/dev/null || echo 0)
  hierarchy=$(grep -cE '^\s+' "$output" 2>/dev/null || echo 0)
  if [ "$goals" -ge 3 ] && [ "$hierarchy" -ge 3 ]; then
    echo "PASS: agent identified $goals goal references with hierarchy depth"
    exit 0
  else
    echo "FAIL: agent identified $goals goal references with $hierarchy indented lines (need >= 3 each)"
    exit 1
  fi
---

# Task

Read and report the goal tree hierarchy from `.runtime/goal-tree.json`.

## Instructions

1. Open and read `.runtime/goal-tree.json` to understand the project's goal hierarchy.
2. Identify the top-level north star goal.
3. List all meso-level goals (children of the north star).
4. For each meso-level goal, list its micro-level sub-goals (if any).
5. Report the completion status of each goal (done/not done).
6. Note what the `d` field means in the goal tree entries.

**Output format:**

```
## Goal Tree: [north star title]

**North Star:**
[north star description]

### Meso-Level Goals

1. ✓ Goal Name (done) [d:N]
   - Micro goal 1 (done)
   - Micro goal 2 (done)
   - ...

2. [ ] Goal Name (not done) [d:N]
   - ...

### Notes
- The `d` field represents: [explanation]
```

Output to `output.md`.
