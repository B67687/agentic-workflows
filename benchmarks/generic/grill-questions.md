---
id: generic-grill-questions
name: Generate probing questions for a feature
type: generic
difficulty: medium
estimated_time: 3min
skills: [grill-me]
verification: |
  output="$RUN_DIR/output.md"
  if [ ! -f "$output" ]; then echo "FAIL: no output file at $output"; exit 1; fi
  # Count lines ending with ? (each question must end with ?)
  questions=$(grep -cE '\?$' "$output" 2>/dev/null || echo 0)
  if [ "$questions" -ge 3 ]; then
    echo "PASS: agent asked $questions questions"
    exit 0
  else
    echo "FAIL: agent asked $questions questions (need >= 3)"
    exit 1
  fi
---

# Task

You are using the **grill-me** skill to interview a stakeholder about adding a **dark mode feature** to a web application.

Use the grill-me approach:

1. **Set the stage** --- explain what you're about to do
2. **Walk the decision tree** --- ask detailed questions, one per topic
3. **Stress-test with scenarios** --- ask about edge cases
4. **Confirm shared understanding** --- summarize the agreed direction

Generate ALL questions you would ask in a single session. Each question must end with `?`. After each question, include your recommended answer.

**Output format:**

```
Q1: [question]
    Recommended: [answer]

Q2: [question]
    Recommended: [answer]
```

List at least 3 questions. Output to `output.md`.
