---
id: generic-review-code
name: Review a sample Python file for code quality
type: generic
difficulty: medium
estimated_time: 5min
skills: [code-review-and-quality]
verification: |
  output="$RUN_DIR/output.md"
  if [ ! -f "$output" ]; then echo "FAIL: no output file at $output"; exit 1; fi
  # Check for severity markers (HIGH, MEDIUM, LOW, or CRITICAL, WARNING, INFO)
  # Also check for file/line references or finding descriptions
  findings=$(grep -ciE '\b(HIGH|MEDIUM|LOW|CRITICAL|WARNING|INFO|Finding|Issue|Severity)\b' "$output" 2>/dev/null || echo 0)
  if [ "$findings" -ge 3 ]; then
    echo "PASS: agent identified $findings findings/issues"
    exit 0
  else
    echo "FAIL: agent identified $findings findings (need >= 3)"
    exit 1
  fi
---

# Task

Review the file `benchmarks/generic/review-sample.py` using the **code-review-and-quality** skill.

Use the five-axis review approach:
1. **Correctness** — bugs, edge cases, error handling
2. **Readability & Simplicity** — naming, structure, comments
3. **Architecture** — design patterns, separation of concerns
4. **Security** — injection, data exposure, unsafe patterns
5. **Performance** — inefficiencies, unnecessary work

List at least 3 findings. Each finding should include severity (HIGH/MEDIUM/LOW), what's wrong, and how to fix it.

**Output format:**

```
### [SEVERITY] Finding: [title]
File: review-sample.py, Line: [line]
[description]

### [SEVERITY] Finding: [title]
File: review-sample.py, Line: [line]
[description]
```

Output to `output.md`.
