---
id: harness-benchmark-diagnostics
name: Interpret benchmark scores and identify coverage gaps
type: harness
difficulty: medium
estimated_time: 4min
skills: [benchmark-analysis, data-interpretation]
verification: |
  output="$RUN_DIR/output.md"
  if [ ! -f "$output" ]; then echo "FAIL: no output file at $output"; exit 1; fi
  # Check for score reference, gap classification, and a suggestion
  score_ref=$(grep -ciE '\b(pass|fail|rate|score|category|weight)\b' "$output" 2>/dev/null || echo 0)
  gap_ref=$(grep -ciE '\b(gap|coverage|signal|missing|empty|zero)\b' "$output" 2>/dev/null || echo 0)
  suggestion=$(grep -ciE '\b(suggest|recommend|action|next step|priority)\b' "$output" 2>/dev/null || echo 0)
  if [ "$score_ref" -ge 3 ] && [ "$gap_ref" -ge 2 ] && [ "$suggestion" -ge 1 ]; then
    echo "PASS: agent analyzed scores ($score_ref score refs), identified gaps ($gap_ref gap refs), suggested action"
    exit 0
  else
    echo "FAIL: insufficient diagnostic analysis (score=$score_ref gap=$gap_ref suggestion=$suggestion)"
    exit 1
  fi
---

# Task

Analyze the current benchmark system and produce a diagnostic report.

## Instructions

1. Read `benchmarks/registry.json` to understand the benchmark catalog and categories.
2. Run `bash scripts/bench/aggregate.sh summary` and `bash scripts/bench/aggregate.sh by-category` to get current scores.
3. Run `bash scripts/bench/detect-gaps.sh` to see what gaps the automated detector finds.
4. Analyze and report:

   a. **Coverage**: How many benchmarks exist vs how many have been run? Which categories are covered?
   b. **Category weights**: What are the weight values for each category (generic, harness, public)? Why do they differ?
   c. **Gap analysis**: What types of gaps were detected (coverage, signal, etc.)? Group by severity.
   d. **Priority recommendation**: Based on the gap analysis, what should be addressed first and why?

**Output format:**

```
## Benchmark Diagnostic Report

### Coverage Summary
- Total benchmarks in registry: [N]
- Categories: [list with run counts]
- Category weights: [generic=N, harness=N, public=N]

### Score Overview
[Summary of aggregate scores]

### Gap Analysis
#### High Severity
- [gap type]: [description]

#### Medium Severity
- [gap type]: [description]

### Priority Recommendation
[What to address first and why]
```

Output to `output.md`.
