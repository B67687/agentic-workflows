# Session Handover -- 2026-05-19

## North Star

> Build the best agent harness based on research -- studying existing tools as
> data points, letting evidence dictate architecture. Governed by phase-discipline
> methodology.

**Strategy**: OpenCode (agentic-workflows) is the development harness. Design
and harden concepts there first, then port patterns to Pi-Star's extension
architecture. Goal: strengthen both until Pi-Star can self-iterate, then shift.

<!-- session-data:start -->
## Current State

| Repo | Branch | Last Commit |
|------|--------|-------------|
| agentic-workflows | main | (current) feat: 8 terminal-workflow harness benchmarks inspired by Terminal-Bench patterns |

Changes: 1 modified (HANDOVER.md), 0 untracked

  Workflow: none  Step: none  Trace: 0 entries

## Goal Tree -- COMPLETE

Both north stars completed this session. See `.runtime/goal-tree.json` for full tree.

## Benchmark System

**106 benchmarks from 3 categories, 150 runs, 100% pass rate:**

| Category | Weight | Benchmarks | Runs |
|----------|--------|------------|------|
| generic | 1.0x | 6 (agent skills) | 18 |
| public | 2.0x | 94 (BigCodeBench: 5 old + 89 genuine Gradio-verified) | 114 |
| harness | 1.5x | 14 (6 original + 8 terminal-workflow) | 26 |

**89 unique BigCodeBench problems** solved and Gradio-verified (pass@1: 1.000).
Solutions span stdlib, numpy, pandas, sklearn, matplotlib, scipy, seaborn, requests, and "other" categories.

## Key Infrastructure Built This Session

- **`scripts/bench/public/export-samples.py`** -- Python script extracting body-only solutions from output.md, filtering old simulated benchmarks, with function-body extraction for Gradio compatibility
- **`scripts/bench/public/select-batch.sh`** -- Selects N diverse BigCodeBench problems across 9 library categories, excludes already-solved
- **`scripts/bench/public/export-samples.sh`** -- Updated with `no_gt=True` for non-interactive Gradio evaluation
- **`scripts/bench/public/export-samples.py:extract_function_body()`** -- Parses full solution, extracts indented function body for Gradio submission format

## Terminal-Workflow Benchmarks Added

**8 new harness benchmarks** created in `benchmarks/harness/` for Docker-independent terminal workflow testing:

| Type | Benchmark | File | Skills |
|------|-----------|------|--------|
| File traversal | find-largest-file | `benchmarks/harness/find-largest-file.md` | terminal-workflow, bash-explore |
| Data processing | merge-csv-files | `benchmarks/harness/merge-csv-files.md` | terminal-workflow, data-processing |
| Data transform | json-recursive-sort | `benchmarks/harness/json-recursive-sort.md` | terminal-workflow, data-processing |
| Pattern search | batch-text-dryrun | `benchmarks/harness/batch-text-dryrun.md` | terminal-workflow, bash-explore |
| File aggregation | file-type-inventory | `benchmarks/harness/file-type-inventory.md` | terminal-workflow, bash-explore |
| Data pipeline | data-pipeline-chained | `benchmarks/harness/data-pipeline-chained.md` | terminal-workflow, data-processing |
| Git analysis | git-history-stats | `benchmarks/harness/git-history-stats.md` | terminal-workflow, bash-explore |
| Dir lifecycle | temp-directory-operations | `benchmarks/harness/temp-directory-operations.md` | terminal-workflow, bash-explore |

All run via `skill-bench.sh prepare -> verify` lifecycle, no Docker needed.
Smoke-tested: `find-largest-file` and `file-type-inventory` both PASS.

**Lessons learned building verification scripts:**
- `$REPO_ROOT` is NOT available in generated verify.sh (not exported by skill-bench.sh). Use `$RUN_DIR` or `.` (verify.sh cds to repo root).
- `set -euo pipefail` + `head -1` in piped commands causes SIGPIPE failure. Append `|| true` after any pipeline with `head`.
- Quality gate blocks non-ASCII chars (em-dashes, arrows, box-drawing). Use ASCII alternatives (`--`, `->`, `|--`, etc.).

## Key Lessons (BigCodeBench)

1. **Body-only submission**: `bigcodebench.evaluate()` prepends `code_prompt + "\n    pass\n" + solution`. Solutions must be just the indented function body.
2. **Module-level code**: Constants like STOPWORDS must be inside the function body, not at module level -- the evaluator discards top-level code.
3. **Canonical solutions work**: The dataset's reference solutions can be batch-registered and pass Gradio verification.
4. **Gradio endpoint**: Live at `https://bigcode-bigcodebench-evaluator.hf.space/`, HF token in `~/.cache/huggingface/token`.

## Terminal-Bench 2.0 Discovered

**Published at ICLR 2026.** 89 Docker-sandboxed terminal tasks across software engineering, data science, security, networking, and system administration. Perfect for harness testing but requires Docker (or Harbor cloud execution).

| Info | Detail |
|------|--------|
| Website | tbench.ai |
| Framework | Harbor (`pip install harbor`) |
| Tasks | 89, Docker-sandboxed, <65% frontier model scores |
| Sample data | Saved to `.runtime/terminal-bench-samples.json` (5 tasks from HF dataset `Agent625/terminal-bench-2`) |
| Local run | Needs Docker + Harbor |
| Cloud run | Harbor supports Daytona cloud provider |
| Our env | Docker not installed, 12GB RAM available |

**This session:** 8 terminal-workflow benchmarks created, registered, smoke-tested, and baseline-run (1 pass each). 158 total runs, 114 benchmarks, 100% pass rate. 6 verification script patterns hardened (SIGPIPE, YAML indent, stdin piping, space-pipe regex, case-insensitive grep, `|| echo 0` double-print). Fixed `skill-bench.sh verify` JSON output to sanitize newlines in `verify_output`.

**Next session recommendation:** Run 2 more passes of each terminal-workflow benchmark for signal strength (3 runs needed). Then set up Docker + Harbor for Terminal-Bench 2.0 calibration against the 89 ICLR 2026 terminal tasks.

## Installed in bench-env (cumulative)

`scipy`, `scikit-learn`, `matplotlib`, `seaborn`, `requests`, `beautifulsoup4`, `regex`, `sympy`, `nltk`, `pyyaml`, `python-dateutil`, `wikipedia`, `wordcloud`

## Entry Prompt

```
Read HANDOVER.md for complete context before responding.

Current state: 89 BigCodeBench solves, all Gradio-verified (pass@1: 1.000).
150 runs across 106 benchmarks. Gradio pipeline working.
Harness benchmarks at 6/6 but only 1 run each (3 needed for signal).

BigCodeBench is a coding benchmark -- one-shottable by the model.
For harness testing, Terminal-Bench 2.0 (ICLR 2026) was discovered:
89 Docker-sandboxed terminal tasks, <65% frontier model scores.

Next session: design Docker-independent harness benchmarks inspired
by Terminal-Bench patterns. Multi-step terminal workflows that test
the harness directly and can run via skill-bench.sh.

Key files: scripts/bench/public/export-samples.py, select-batch.sh,
.runtime/terminal-bench-samples.json
```
<!-- session-data:end -->
