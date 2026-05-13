---
id: generic-debug-traceback
name: Debug a Python traceback using the macro-to-micro funnel
type: generic
difficulty: medium
estimated_time: 5min
skills: [debugging-and-error-recovery]
verification: |
  output="$RUN_DIR/output.md"
  if [ ! -f "$output" ]; then echo "FAIL: no output file at $output"; exit 1; fi
  # Check for all 4 funnel levels
  l1=$(grep -ciE '\b(Syste(m|mic)|Level\s*1|Macro)\b' "$output" 2>/dev/null || echo 0)
  l2=$(grep -ciE '\b(Domain|Level\s*2)\b' "$output" 2>/dev/null || echo 0)
  l3=$(grep -ciE '\b(Module|Level\s*3)\b' "$output" 2>/dev/null || echo 0)
  l4=$(grep -ciE '\b(Root\s*[Cc]ause|Level\s*4)\b' "$output" 2>/dev/null || echo 0)
  if [ "$l1" -ge 1 ] && [ "$l2" -ge 1 ] && [ "$l3" -ge 1 ] && [ "$l4" -ge 1 ]; then
    echo "PASS: all 4 funnel levels present (L1=$l1 L2=$l2 L3=$l3 L4=$l4)"
    exit 0
  else
    echo "FAIL: missing funnel levels (L1=$l1 L2=$l2 L3=$l3 L4=$l4)"
    exit 1
  fi
---

# Task

Debug the following error using the **debugging-and-error-recovery** skill's macro-to-micro funnel.

## Error

```
Traceback (most recent call last):
  File "order.py", line 42, in process_order
    total = calculate_total(items, discount_code)
  File "order.py", line 28, in calculate_total
    discount = get_discount(discount_code)
  File "order.py", line 15, in get_discount
    return DISCOUNTS[code]
KeyError: 'SUMMER2026'
```

## Instructions

Apply the macro-to-micro funnel (4 levels):

**Level 1 --- System:** How does the order processing system work? What are the components, data flows, and boundaries? Before looking at code, describe the system architecture.

**Level 2 --- Domain:** Which subsystem or domain is affected? Narrow your focus to the relevant area.

**Level 3 --- Module:** Which specific file or code path contains the error? Identify the exact function and line.

**Level 4 --- Root Cause:** What specific logic failure caused the bug? What's the fix?

Output all 4 levels. Output to `output.md`.
