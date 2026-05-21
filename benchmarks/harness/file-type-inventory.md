---
id: terminal-file-type-inventory
name: File type inventory across the repository
type: harness
difficulty: easy
estimated_time: 3min
skills: [terminal-workflow, bash-explore]
verification: |
  output="$RUN_DIR/output.md"
  if [ ! -f "$output" ]; then echo "FAIL: no output file at $output"; exit 1; fi
  # Check for a table with at least 3 file types
  table_data=$(grep -cE '^\|[[:space:]]*\.[a-zA-Z0-9]+[[:space:]]*\|' "$output" 2>/dev/null || echo 0)
  if [ "$table_data" -lt 3 ]; then echo "FAIL: fewer than 3 file types in the table"; exit 1; fi
  # Check for column headers
  header_ext=$(grep -ciE '\|.*extension.*\|' "$output" 2>/dev/null || echo 0)
  header_count=$(grep -ciE '\|.*count.*\|' "$output" 2>/dev/null || echo 0)
  header_size=$(grep -ciE '\|.*(size|bytes).*\|' "$output" 2>/dev/null || echo 0)
  if [ "$header_ext" -eq 0 ] && [ "$header_count" -eq 0 ]; then echo "FAIL: missing column headers (Extension, Count, Size)"; exit 1; fi
  # Check for total row
  total=$(grep -ciE '\*\*total\*\*' "$output" 2>/dev/null || echo 0)
  if [ "$total" -eq 0 ]; then echo "FAIL: missing Total row in output"; exit 1; fi
  echo "PASS: file type inventory complete with $table_data file types"
  exit 0
---

# Task: File Type Inventory

Build a complete inventory of file types in this repository, organized by extension.

## Requirements

1. **Walk the repository directory tree** excluding `.git/` and `node_modules/`
2. **Group files by extension** (e.g., `.py`, `.sh`, `.md`, `.json`, `.yaml`, `.txt`, etc.)
3. **For each extension, count:**
   - Number of files with that extension
   - Total size in bytes (sum of all file sizes)
4. **Calculate totals** across all extensions
5. **Sort by count descending** (most common file types first)
6. **Include files without extensions** (e.g., `Makefile`, `Dockerfile`) as a special `(no extension)` group

## Output Format

Produce a formatted table in `output.md`:

```
## File Type Inventory

| Extension | Count | Total Size (bytes) |
|-----------|-------|-------------------|
| .sh       | 42    | 1,234,567         |
| .md       | 38    | 987,654           |
| .py       | 15    | 456,789           |
| .json     | 8     | 123,456           |
| ...       | ...   | ...               |
| (no ext)  | 3     | 45,678            |
| **Total** | **N** | **X,XXX,XXX**     |

### Command Used
```bash
find . -type f | ...
```
```

## Instructions

- Use terminal commands (find, awk, sort, etc.)
- Exclude `.git/` and `node_modules/` directories
- Numbers should be accurate for the current codebase
- Include the commands you used below the table
