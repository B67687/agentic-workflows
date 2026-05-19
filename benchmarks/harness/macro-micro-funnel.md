---
id: harness-macro-micro-funnel
name: Apply macro-to-micro funnel to diagnose a harness issue
type: harness
difficulty: medium
estimated_time: 5min
skills: [debugging-and-error-recovery, harness-orientation]
verification: |
  output="$RUN_DIR/output.md"
  if [ ! -f "$output" ]; then echo "FAIL: no output file at $output"; exit 1; fi
  # Check for all 4 funnel levels
  system=$(grep -ciE '\b(System|system level|architecture|architectural)\b' "$output" 2>/dev/null || echo 0)
  domain=$(grep -ciE '\b(Domain|subsystem|which part)\b' "$output" 2>/dev/null || echo 0)
  module=$(grep -ciE '\b(Module|file|code path)\b' "$output" 2>/dev/null || echo 0)
  root_cause=$(grep -ciE '\b(Root Cause|root cause|specific logic|fails)\b' "$output" 2>/dev/null || echo 0)
  all_levels=$(( (system>0) + (domain>0) + (module>0) + (root_cause>0) ))
  if [ "$all_levels" -ge 4 ]; then
    echo "PASS: agent applied all 4 funnel levels (System/Domain/Module/Root Cause)"
    exit 0
  else
    echo "FAIL: agent covered $all_levels/4 funnel levels"
    exit 1
  fi
---

# Task

Apply the macro-to-micro funnel to diagnose the following issue.

## Issue Description

"When running `bash scripts/bench/detect-gaps.sh`, the output shows 5 coverage gaps for `bigcodebench-0` through `bigcodebench-4`. However, running `bash scripts/bench/aggregate.sh summary` reports these benchmarks exist with pass/fail data. The BigCodeBench benchmarks were previously run and passed, but the gap detector reports them as having zero runs. Something is inconsistent."

## Instructions

Use the macro-to-micro funnel from `AGENTS.md` (System -> Domain -> Module -> Root Cause):

### Level 1: System
How do the benchmark runner, registry, aggregator, and gap detector connect? What data flows between them? Where does the gap detector get its data?

### Level 2: Domain
Which subsystem is likely responsible for this inconsistency? Is it the gap detector, the aggregator, the run storage, or the registry?

### Level 3: Module
Which specific files and code paths are involved? Trace the data flow from run creation through gap detection.

### Level 4: Root Cause
What specific logic causes the gap detector to disagree with the aggregator? Identify the exact mechanism.

**Output format:**

```
## Macro-to-Micro Diagnostic Funnel

### Level 1: System Architecture
[Description of system connections and data flow]

### Level 2: Domain Identification
[Which subsystem and why]

### Level 3: Module / Code Path
[Specific files and code paths]

### Level 4: Root Cause
[The specific logic that causes the inconsistency]
```

Output to `output.md`.
