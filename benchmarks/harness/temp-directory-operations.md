---
id: terminal-temp-directory-operations
name: Temporary directory creation, manipulation, and cleanup
type: harness
difficulty: hard
estimated_time: 5min
skills: [terminal-workflow, bash-explore]
verification: |
  output="$RUN_DIR/output.md"
  if [ ! -f "$output" ]; then echo "FAIL: no output file at $output"; exit 1; fi
  # Check for temp directory creation evidence
  created_line=$(grep -E '^\*\*Created:\*\*' "$output" 2>/dev/null | head -1)
  if [ -z "$created_line" ]; then echo "FAIL: missing 'Created:' section"; exit 1; fi
  # Check for directory structure report
  structure=$(grep -cE '(dir|directory|folder|subdirectory|depth|tree|level)' "$output" 2>/dev/null || echo 0)
  if [ "$structure" -lt 3 ]; then echo "FAIL: fewer than 3 directory structure references"; exit 1; fi
  # Check for file operations
  file_ops=$(grep -cE '(rename|move|copy|delete|remove|modify|create|write)' "$output" 2>/dev/null || echo 0)
  if [ "$file_ops" -lt 3 ]; then echo "FAIL: fewer than 3 file operation references"; exit 1; endif
  # Check for cleanup confirmation
  cleanup=$(grep -cE '(cleanup|clean up|removed|deleted|rm\b|clean)' "$output" 2>/dev/null || echo 0)
  if [ "$cleanup" -lt 1 ]; then echo "FAIL: no cleanup evidence found"; exit 1; fi
  # Check for command blocks
  cmd_blocks=$(grep -cE '^```(bash|sh)' "$output" 2>/dev/null || echo 0)
  if [ "$cmd_blocks" -lt 2 ]; then echo "FAIL: fewer than 2 command blocks"; exit 1; fi
  echo "PASS: temp directory operations complete with creation, manipulation, and cleanup"
  exit 0
---

# Task: Temporary Directory Lifecycle

Create, manipulate, traverse, and clean up a temporary directory structure. This tests your ability to manage filesystem state through a complete lifecycle.

## Requirements

### Phase 1: Create a directory tree

Create a temporary directory under `/tmp/bench-test-XXXXX` (use a unique name with timestamp). Inside it, build this structure:

```
bench-test-XXXXX/
|-- docs/
|   |-- readme.md
|   `-- notes.txt
|-- src/
|   |-- main.py
|   |-- utils.py
|   `-- tests/
|       |-- test_main.py
|       `-- test_utils.py
|-- data/
|   |-- input.csv
|   `-- output/
`-- config/
    `-- settings.json
```

Each file should contain a brief, relevant comment or placeholder content (2-3 lines).

### Phase 2: File operations

Perform these operations in sequence:

1. **Rename** `docs/notes.txt` -> `docs/scratchpad.md`
2. **Copy** `src/main.py` to `src/main_backup.py`
3. **Create** a new directory `archive/` at the top level
4. **Move** `config/settings.json` into `archive/settings.json.bak`
5. **Modify** `src/utils.py` by appending a new comment line

### Phase 3: Traverse and report

Walk the directory tree and report:
- Total directories (including root)
- Total files
- Directory tree structure (use a tree-like format)

### Phase 4: Cleanup

Remove the temporary directory and all its contents. Confirm it no longer exists.

## Output Format

```
## Temporary Directory Lifecycle

### Phase 1: Creation
**Created:** /tmp/bench-test-<timestamp>/
<brief description of structure>

### Phase 2: Operations
1. Renamed docs/notes.txt -> docs/scratchpad.md
2. Copied src/main.py -> src/main_backup.py
3. Created archive/
4. Moved config/settings.json -> archive/settings.json.bak
5. Appended comment to src/utils.py

### Phase 3: Structure (before cleanup)
```
bench-test-XXXXX/
|-- archive/
|   `-- settings.json.bak
|-- data/
|   |-- input.csv
|   `-- output/
|-- docs/
|   |-- readme.md
|   `-- scratchpad.md
|-- src/
|   |-- main.py
|   |-- main_backup.py
|   |-- tests/
|   |   |-- test_main.py
|   |   `-- test_utils.py
|   `-- utils.py
```

**Total directories:** 6
**Total files:** 9

### Phase 4: Cleanup
**Cleaned up:** /tmp/bench-test-<timestamp>/
**Verified:** Directory no longer exists (rm -rf confirmed)

### Commands Used
```bash
mkdir -p /tmp/bench-test-$(date +%s)/{docs,src/tests,data/output,config}
...
```
```

## Instructions

- Each phase must be executed in order
- Report the actual output of commands you run
- Verify cleanup by checking the directory no longer exists
- Include the full commands used in each phase
