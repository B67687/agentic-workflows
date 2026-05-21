---
id: terminal-find-largest-file
name: Find the largest file in the repository
type: harness
difficulty: easy
estimated_time: 2min
skills: [terminal-workflow, bash-explore]
verification: |
  output="$RUN_DIR/output.md"
  if [ ! -f "$output" ]; then echo "FAIL: no output file at $output"; exit 1; fi
  # Check output contains a file path and byte size
  path_line=$(grep -E '^Path:' "$output" 2>/dev/null | head -1)
  size_line=$(grep -E '^Size:' "$output" 2>/dev/null | head -1)
  if [ -z "$path_line" ]; then echo "FAIL: missing 'Path:' line in output"; exit 1; fi
  if [ -z "$size_line" ]; then echo "FAIL: missing 'Size:' line in output"; exit 1; fi
  # Extract the claimed file path
  claimed_path=$(echo "$path_line" | sed 's/^Path:[[:space:]]*//')
  claimed_size=$(echo "$size_line" | sed 's/^Size:[[:space:]]*//')
  # Verify it exists and size matches
  if [ ! -f "$claimed_path" ]; then echo "FAIL: claimed path does not exist: $claimed_path"; exit 1; fi
  actual_size=$(stat -c%s "$claimed_path" 2>/dev/null || echo "0")
  if [ "$actual_size" -ne "$claimed_size" ] 2>/dev/null; then echo "FAIL: claimed size $claimed_size does not match actual $actual_size"; exit 1; fi
  # Verify relative path starts with scripts/ or benchmarks/ (source-controlled dirs)
  # $RUN_DIR is <repo>/.runtime/bench-runs/<id>, so go up 3 levels to get repo root
  REPO_DIR="$(cd "$RUN_DIR/../../.." && pwd)"
  rel="${claimed_path#$REPO_DIR/}"
  case "$rel" in
    scripts/*|benchmarks/*) ;;
    *) echo "FAIL: claimed path '$rel' is not under scripts/ or benchmarks/"; exit 1 ;;
  esac
  # Verify it's actually the largest in scripts/ + benchmarks/ (exclude __pycache__)
  # || true absorbs SIGPIPE from head under pipefail
  largest=$(find scripts benchmarks -name __pycache__ -prune -o -type f -printf '%s\t%p\n' 2>/dev/null | sort -rn | head -1 | cut -f2-) || true
  largest=$(realpath "$largest" 2>/dev/null || echo "$largest")
  largest_size=$(stat -c%s "$largest" 2>/dev/null || echo 0)
  if [ "$claimed_path" != "$largest" ]; then echo "FAIL: $claimed_path is not the largest file ($largest is $largest_size bytes)"; exit 1; fi
  echo "PASS: agent correctly identified $claimed_path at $claimed_size bytes"
  exit 0
---

# Task: Find the Largest File

Use terminal commands to find the single largest file (by size in bytes) within the `scripts/` and `benchmarks/` directories of this repository.

## Requirements

1. Search only within `scripts/` and `benchmarks/` directories (these are source-controlled and stable)
2. Exclude `__pycache__/` directories
3. Record the size in bytes of each file
4. Identify which file is the largest
5. Write your findings to `output.md`

## Output Format

```
## Result

Path: /absolute/path/to/largest/file.ext
Size: <size in bytes>
Method: <brief description of method, 1-2 sentences>
```

## Instructions

- Use bash commands (find, stat, sort, etc.)
- The absolute path should be the full path from filesystem root
- Verify the file exists and the size matches
- Example: `Path: /home/user/repo/scripts/tools/skill-bench.sh`
