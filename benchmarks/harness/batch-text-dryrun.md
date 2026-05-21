---
id: terminal-batch-text-dryrun
name: Batch search across files with pattern counting
type: harness
difficulty: medium
estimated_time: 3min
skills: [terminal-workflow, bash-explore]
verification: |
  output="$RUN_DIR/output.md"
  if [ ! -f "$output" ]; then echo "FAIL: no output file at $output"; exit 1; fi
  # Check for total count
  total_line=$(grep -E '^\*\*Total matches:\*\*' "$output" 2>/dev/null | head -1)
  if [ -z "$total_line" ]; then echo "FAIL: missing 'Total matches:' in output"; exit 1; fi
  total=$(echo "$total_line" | grep -oE '[0-9]+' | head -1)
  if [ -z "$total" ] || [ "$total" -eq 0 ] 2>/dev/null; then echo "FAIL: total matches is 0 or missing"; exit 1; fi
  # Check for per-file breakdown table
  table_rows=$(grep -cE '^\|.*\|.*\|' "$output" 2>/dev/null || echo 0)
  if [ "$table_rows" -lt 3 ]; then echo "FAIL: fewer than 3 table rows in output (need header + separator + at least 1 data row)"; exit 1; fi
  # Check for reported top files
  top_file=$(grep -E '^\|.*\|[[:space:]]*[0-9]+[[:space:]]*\|' "$output" 2>/dev/null | head -1)
  if [ -z "$top_file" ]; then echo "FAIL: no data rows with counts found"; exit 1; fi
  echo "PASS: agent found $total matches across scripts/ with proper per-file breakdown"
  exit 0
---

# Task: Batch Pattern Search Across Script Files

Search for the pattern `exit 1` across all `.sh` files in the repository's `scripts/` directory. Produce an aggregated report with per-file counts and a total.

## Requirements

1. **Find all `.sh` files** under the `scripts/` directory (recursive)
2. **Search for the literal pattern `exit 1`** in each file (not `exit 10`, `exit 100`, etc. -- only `exit 1`)
3. **Count occurrences per file** -- how many times each file has `exit 1`
4. **Calculate the total** across all files
5. **Identify files with the most hits** (top 3)

## Output Format

Produce a structured report in `output.md`:

```
## Batch Search Report: 'exit 1' in scripts/

### Per-File Breakdown
| File | Matches |
|------|---------|
| scripts/bench/aggregate.sh | 3 |
| scripts/hooks/quality-gate.sh | 2 |
| ... | ... |

### Top 3 Files
1. scripts/bench/aggregate.sh (3 matches)
2. scripts/hooks/quality-gate.sh (2 matches)
3. ...

**Total matches:** 42

### Command Used
```
grep -rn 'exit 1' scripts/ --include='*.sh' | ...
```
```

## Instructions

- Use terminal commands (grep, find, wc, sort, etc.)
- Do not modify any files
- Report the actual counts from the current codebase
- Use a markdown table for the per-file breakdown
