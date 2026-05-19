---
id: terminal-git-history-stats
name: Git log analysis and commit statistics
type: harness
difficulty: medium
estimated_time: 4min
skills: [terminal-workflow, bash-explore]
verification: |
  output="$RUN_DIR/output.md"
  if [ ! -f "$output" ]; then echo "FAIL: no output file at $output"; exit 1; fi
  # Check for total commit count
  commit_line=$(grep -E '^\*\*Total commits:\*\*' "$output" 2>/dev/null | head -1)
  if [ -z "$commit_line" ]; then echo "FAIL: missing 'Total commits' line"; exit 1; fi
  # Check for author breakdown
  author_section=$(grep -cE '^\|.*author.*\|' "$output" 2>/dev/null || echo 0)
  author_data=$(grep -cE '^\|.*[0-9]+\|' "$output" 2>/dev/null || echo 0)
  if [ "$author_data" -lt 2 ]; then echo "FAIL: fewer than 2 author data rows"; exit 1; fi
  # Check for time-based stats
  time_stats=$(grep -cE '(day|week|month|hour|date|202[0-9])' "$output" 2>/dev/null || echo 0)
  if [ "$time_stats" -lt 2 ]; then echo "FAIL: fewer than 2 time-based statistics references"; exit 1; fi
  # Check for at least one command block
  cmd_block=$(grep -cE '^```(bash|sh)' "$output" 2>/dev/null || echo 0)
  if [ "$cmd_block" -eq 0 ]; then echo "FAIL: no command block found"; exit 1; fi
  echo "PASS: git history analysis complete with commit counts, author breakdown, and time stats"
  exit 0
---

# Task: Git Log Analysis and Statistics

Analyze the repository's git history and produce a structured statistical report.

## Requirements

1. **Total commits**: Count all commits in the repository's history
2. **Author breakdown**: Group commits by author, count per author, show percentage
3. **Time-based statistics**:
   - Commits per day (average)
   - Date range (first commit to latest)
   - Most active day (date with most commits)
   - Commits in the last 7 days, 30 days
4. **Files changed**: Total files changed across all commits (approximate)
5. **Top 5 most-changed files**: Files with the most commits touching them

## Output Format

```
## Git History Analysis

### Overview
| Metric | Value |
|--------|-------|
| **Total commits** | 42 |
| **Date range** | 2026-04-01 to 2026-05-19 |
| **Total authors** | 3 |
| **Total files changed** | ~156 |

### Per-Author Breakdown
| Author | Commits | Percentage |
|--------|---------|------------|
| Author One | 20 | 47.6% |
| Author Two | 15 | 35.7% |
| Author Three | 7 | 16.7% |

### Time-Based Activity
| Metric | Value |
|--------|-------|
| **Commits per day (avg)** | 0.4 |
| **Most active day** | 2026-05-18 (8 commits) |
| **Last 7 days** | 12 commits |
| **Last 30 days** | 42 commits |

### Most-Changed Files
1. `scripts/bench/aggregate.sh` (8 changes)
2. `HANDOVER.md` (6 changes)
3. ...

### Commands Used
```bash
git log --oneline | wc -l
git shortlog -sn
...
```
```

## Instructions

- Use git commands (git log, git shortlog, git diff, etc.)
- Report actual data from the repository's git history
- Include commands used for each metric
- All numbers must be accurate
