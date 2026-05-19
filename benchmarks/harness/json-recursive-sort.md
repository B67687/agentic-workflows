---
id: terminal-json-recursive-sort
name: Recursively sort JSON object keys
type: harness
difficulty: medium
estimated_time: 3min
skills: [terminal-workflow, data-processing]
verification: |
  output="$RUN_DIR/output.md"
  if [ ! -f "$output" ]; then echo "FAIL: no output file at $output"; exit 1; fi
  # Extract sorted JSON from code block
  sorted_json=$(sed -n '/^```json$/,/^```$/p' "$output" 2>/dev/null | sed '1d;$d')
  if [ -z "$sorted_json" ]; then echo "FAIL: no JSON code block in output.md"; exit 1; fi
  # Verify it's valid JSON
  if ! echo "$sorted_json" | python3 -m json.tool >/dev/null 2>&1; then echo "FAIL: output is not valid JSON"; exit 1; fi
  # Verify keys are sorted recursively
  python3 -c "
import json, sys
data = json.loads('''$sorted_json''')
def check(obj, path=''):
    if isinstance(obj, dict):
        keys = list(obj.keys())
        if keys != sorted(keys):
            print(f'FAIL: keys not sorted at {path}: {keys}')
            sys.exit(1)
        for k, v in obj.items():
            check(v, f'{path}.{k}')
    elif isinstance(obj, list):
        for i, v in enumerate(obj):
            check(v, f'{path}[{i}]')
check(data)
print('PASS: all keys sorted at all nesting levels')
" 2>&1 || exit 1
  # Verify it's pretty-printed with 2-space indent
  if ! echo "$sorted_json" | grep -qE '^  "'; then echo "FAIL: output is not pretty-printed with 2-space indentation"; exit 1; fi
  exit 0
---

# Task: Recursively Sort JSON Keys

Create a nested JSON configuration object and sort all keys alphabetically at every level of nesting.

## Requirements

### Step 1: Create a nested JSON structure

Create a JSON object with at least 3 levels of nesting and 2+ keys at each level. The keys should NOT be in alphabetical order (to demonstrate the sorting). Include at least one array with objects that also need key sorting.

For example (your actual JSON should have different keys and values -- at least 8 total keys across all levels):

```json
{
  "zebra": {"apple": 1, "banana": 2},
  "alpha": {
    "delta": [{"x": 1, "y": 2}, {"b": 3, "a": 4}],
    "charlie": 3
  }
}
```

### Step 2: Sort all keys recursively

Write a script (bash + python or similar) that:

1. Reads the JSON object
2. Recursively sorts all keys alphabetically at every nesting level
3. Outputs pretty-printed JSON with 2-space indentation and a trailing newline

### Step 3: Report

Include in `output.md`:

1. The script or commands you used (short explanation)
2. The sorted JSON in a ` ```json ` code block

## Output Format

```
## Approach
<2-4 sentences explaining your method>

## Sorted JSON
```json
{
  "alpha": {
    "charlie": 3,
    "delta": [
      {
        "x": 1,
        "y": 2
      },
      {
        "a": 4,
        "b": 3
      }
    ]
  },
  "zebra": {
    "apple": 1,
    "banana": 2
  }
}
```
```
