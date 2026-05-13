---
id: generic-count-files
name: Count files by extension
type: generic
difficulty: easy
estimated_time: 1min
skills: [bash-explore]
verification: |
  output="$RUN_DIR/output.md"
  if [ ! -f "$output" ]; then echo "FAIL: no output file at $output"; exit 1; fi
  # Check that the output contains a count (e.g., "Found 42 .py files")
  if grep -qiE 'found [0-9]+' "$output" >/dev/null 2>&1; then
    count=$(grep -oE '[0-9]+' "$output" | head -1)
    echo "PASS: agent found $count .py files"
    exit 0
  else
    echo "FAIL: output does not contain a file count"
    echo "  Expected format: 'Found 42 .py files'"
    exit 1
  fi
---

# Task

Count how many `.py` files exist in the codebase. Exclude the `.git/` directory.

**Expected format:**
```
Found 42 .py files
```

Report the total count. Output to `output.md`.
