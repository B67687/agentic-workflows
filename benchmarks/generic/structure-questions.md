---
id: generic-structure-questions
name: Decompose a topic into structured questions (5W+H + Socratic)
type: generic
difficulty: medium
estimated_time: 3min
skills: [structured-questioning]
verification: |
  output="$RUN_DIR/output.md"
  if [ ! -f "$output" ]; then echo "FAIL: no output file at $output"; exit 1; fi
  # Check for 5W+H categories
  who=$(grep -ci '\bWho\b' "$output" 2>/dev/null || echo 0)
  what=$(grep -ci '\bWhat\b' "$output" 2>/dev/null || echo 0)
  when=$(grep -ci '\bWhen\b' "$output" 2>/dev/null || echo 0)
  where=$(grep -ci '\bWhere\b' "$output" 2>/dev/null || echo 0)
  why=$(grep -ci '\bWhy\b' "$output" 2>/dev/null || echo 0)
  how=$(grep -ci '\bHow\b' "$output" 2>/dev/null || echo 0)
  # Count question marks
  questions=$(grep -cE '\?$' "$output" 2>/dev/null || echo 0)
  total_categories=$(( (who>0) + (what>0) + (when>0) + (where>0) + (why>0) + (how>0) ))
  if [ "$total_categories" -ge 3 ] && [ "$questions" -ge 3 ]; then
    echo "PASS: $total_categories/6 categories covered, $questions questions asked"
    exit 0
  else
    echo "FAIL: $total_categories/6 categories, $questions questions (need ≥3 each)"
    exit 1
  fi
---

# Task

Decompose the following topic using the **structured-questioning** skill's 5W+H framework plus Socratic probes.

## Topic

"Migrating the company's monolith API to a microservices architecture"

## Instructions

Generate structured questions covering Who, What, When, Where, Why, and How dimensions.
After the 5W+H questions, add 2-3 Socratic probes that challenge assumptions.

**Output format:**

```
## 5W+H Questions

**Who:** [questions about who is involved]
**What:** [questions about what is changing]
**When:** [questions about timing]
**Where:** [questions about scope/location]
**Why:** [questions about motivation]
**How:** [questions about implementation]

## Socratic Probes

[questions that challenge assumptions]
```

Output to `output.md`.
