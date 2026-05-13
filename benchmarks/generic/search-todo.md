---
id: generic-search-todo
name: Search for TODO comments
type: generic
difficulty: easy
estimated_time: 2min
skills: [bash-explore, code-review-and-quality]
verification: |
  output="$RUN_DIR/output.md"
  if [ ! -f "$output" ]; then echo "FAIL: no output file at $output"; exit 1; fi
  # Count properly formatted entries: path/to/file:line: TODO text
  entries=$(grep -cE '^[^:]+:[0-9]+:' "$output" 2>/dev/null || echo 0)
  if [ "$entries" -ge 5 ]; then
    echo "PASS: agent listed $entries TODO entries"
    exit 0
  else
    echo "FAIL: agent listed $entries entries (need >= 5)"
    exit 1
  fi
---

# Task

Search the codebase for all TODO comments. List each one with its file path, line number, and the TODO text.

**Scope:** `.py`, `.sh`, and `.md` files only. Exclude `.git/` directory.

**Expected format:**
```
path/to/file.py:42: TODO: implement this feature
path/to/script.sh:10: TODO: add error handling
```

List at least 5 TODOs. Output to `output.md`.
