---
id: terminal-merge-csv-files
name: Merge multiple CSV files with a new column
type: harness
difficulty: medium
estimated_time: 4min
skills: [terminal-workflow, data-processing]
verification: |
  output="$RUN_DIR/output.md"
  if [ ! -f "$output" ]; then echo "FAIL: no output file at $output"; exit 1; fi
  # Extract the merged CSV from output.md (between CSV_MARKERS)
  merged_csv=$(sed -n '/^```csv$/,/^```$/p' "$output" 2>/dev/null | sed '1d;$d')
  if [ -z "$merged_csv" ]; then echo "FAIL: no CSV code block found in output.md"; exit 1; fi
  # Check header row
  header=$(echo "$merged_csv" | head -1)
  if [ "$header" != "quarter,product,units,revenue" ]; then echo "FAIL: header is '$header', expected 'quarter,product,units,revenue'"; exit 1; fi
  # Check total row count (at least 5 data rows expected)
  row_count=$(echo "$merged_csv" | tail -n +2 | grep -c .)
  if [ "$row_count" -lt 5 ]; then echo "FAIL: only $row_count data rows, expected at least 5"; exit 1; fi
  # Check quarter values are valid
  bad_quarters=$(echo "$merged_csv" | tail -n +2 | cut -d',' -f1 | grep -vE '^(Q1|Q2|Q3)$' || true)
  if [ -n "$bad_quarters" ]; then echo "FAIL: invalid quarter values found: $bad_quarters"; exit 1; fi
  # Check ordering: Q1 rows before Q2 before Q3
  quarters=$(echo "$merged_csv" | tail -n +2 | cut -d',' -f1 | tr -d '\r')
  q1_done=false; q2_done=false; q3_done=false
  for q in $quarters; do
    case "$q" in
      Q1) q1_done=true; if $q2_done || $q3_done; then echo "FAIL: Q1 rows after Q2 or Q3"; exit 1; fi ;;
      Q2) q2_done=true; if $q3_done; then echo "FAIL: Q2 rows after Q3"; exit 1; fi ;;
      Q3) q3_done=true ;;
    esac
  done
  if ! $q1_done || ! $q2_done || ! $q3_done; then echo "FAIL: missing one or more quarter sections"; exit 1; fi
  echo "PASS: merged CSV with $row_count rows across Q1/Q2/Q3"
  exit 0
---

# Task: Merge CSV Files

Create a multi-step terminal workflow that generates sample sales data across three quarters and merges them into a single CSV.

## Requirements

### Step 1: Create the data directory and CSV files

Create a temporary working directory and generate three CSV files with the schema `product,units,revenue`:

- **File 1: `sales_q1.csv`** -- 3 products
- **File 2: `sales_q2.csv`** -- 3 products (any overlap with Q1 is fine)
- **File 3: `sales_q3.csv`** -- 3 products

Use realistic product names (e.g., "Widget A", "Gadget B", etc.) and plausible integer values for units and revenue.

### Step 2: Merge with quarter labels

Merge all three files into a single CSV with these requirements:

1. A new **first column** called `quarter` with values `Q1`, `Q2`, or `Q3` depending on the source file
2. All rows from Q1 first, then Q2, then Q3
3. A single header row (not repeated)
4. Standard CSV format with comma delimiters

### Step 3: Report

Output the merged CSV in a code block within `output.md`:

```csv
quarter,product,units,revenue
Q1,Widget A,10,500
...
```

Also include your commands and approach in a short explanation section above the CSV block.

## Output Format

```
## Approach
<2-4 sentences explaining your method>

## Merged CSV
```csv
quarter,product,units,revenue
...
```

## Verification
- Row count: <N>
- Quarter values: Q1, Q2, Q3 all present
- Order: Q1 -> Q2 -> Q3
```
