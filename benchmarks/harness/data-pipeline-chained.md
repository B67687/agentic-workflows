---
id: terminal-data-pipeline-chained
name: Multi-step data pipeline with extraction, transformation, and summarization
type: harness
difficulty: hard
estimated_time: 5min
skills: [terminal-workflow, data-processing]
verification: |
  output="$RUN_DIR/output.md"
  if [ ! -f "$output" ]; then echo "FAIL: no output file at $output"; exit 1; fi
  # Check for extraction results
  extract_line=$(grep -E '^\*\*Extracted:\*\*' "$output" 2>/dev/null | head -1)
  if [ -z "$extract_line" ]; then echo "FAIL: missing 'Extracted:' section"; exit 1; fi
  # Check for transformation results  
  transform_line=$(grep -E '^\*\*Transformed:\*\*' "$output" 2>/dev/null | head -1)
  if [ -z "$transform_line" ]; then echo "FAIL: missing 'Transformed:' section"; exit 1; fi
  # Check for summary results
  summary_line=$(grep -E '^\*\*Summary:\*\*' "$output" 2>/dev/null | head -1)
  if [ -z "$summary_line" ]; then echo "FAIL: missing 'Summary:' section"; exit 1; fi
  # Check for the pipeline diagram
  pipeline_count=$(grep -cE -i '(extract|transform|summarize|load|pipeline|step|chain|pipe)' "$output" 2>/dev/null || echo 0)
  if [ "$pipeline_count" -lt 5 ]; then echo "FAIL: fewer than 5 pipeline-related terms in output"; exit 1; fi
  # Check for at least one command block
  cmd_block=$(grep -cE '^```(bash|sh)' "$output" 2>/dev/null || echo 0)
  if [ "$cmd_block" -eq 0 ]; then echo "FAIL: no bash command block found in output"; exit 1; fi
  echo "PASS: multi-step data pipeline complete with extraction, transformation, and summary"
  exit 0
---

# Task: Multi-Step Data Pipeline

Build a chained data pipeline that extracts structured information from the repository, transforms it, and produces a summary. The pipeline should demonstrate multi-step terminal workflow with data flowing between stages.

## Pipeline Stages

### Stage 1: Extract

Extract lines matching the pattern `# Task:` from all `.md` files under `benchmarks/`. For each match, record:
- The file path (relative to repo root)
- The task title (the text after `# Task:` on the same line)

### Stage 2: Transform

From the extracted data:
1. Categorize each task by its directory (e.g., `benchmarks/harness/`, `benchmarks/generic/`, `benchmarks/public/`)
2. Count how many tasks per category
3. Calculate the average title length per category

### Stage 3: Summarize

Produce a summary with:
1. Total number of task references found
2. Per-category breakdown (count, average title length)
3. Category with the most tasks
4. Top 3 longest task titles

## Output Format

```
## Pipeline: Extract -> Transform -> Summarize

### Stage 1: Extraction
**Extracted:** N task references from benchmarks/ .md files

### Stage 2: Transformation
| Category | Count | Avg Title Length |
|----------|-------|-----------------|
| harness  | 6     | 45.2            |
| generic  | 6     | 38.5            |
| public   | 5     | 42.0            |

### Stage 3: Summary
**Total tasks found:** N
**Most populated category:** harness (N tasks)
**Top 3 longest titles:**
1. "Interpret benchmark scores and identify coverage gaps" (57 chars)
2. ...

### Pipeline Commands
```bash
# Extraction step
grep -rn '# Task:' benchmarks/ --include='*.md' > extracted.txt

# Transformation step
...
```

### Pipeline Flow
```
Extract (grep) -> Transform (awk/sort) -> Summarize (report)
```
```

## Instructions

- Each stage should be a distinct step in the pipeline
- Use pipe (`|`) chaining and intermediate files where appropriate
- Report actual data from the current codebase
- Show the commands you used for each stage
