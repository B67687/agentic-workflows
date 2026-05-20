# Session Handover -- 2026-05-20

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
| agentic-workflows | main | (current) fix: harden cleanup-runs.sh and quality-gate.sh guardrails |

Changes: 0 uncommitted (run data in .runtime/bench-runs/ is gitignored)

  Guardrails active:
  - cleanup-runs.sh (empty-rid/glob/path-traversal rejection) -- HARDENED
  - quality-gate.sh (check_dangerous_rm catches -fr, --force variants) -- HARDENED
  - AGENTS.md (rule forbid raw rm -rf on .runtime/bench-runs/)

  NOTE: All 168 previous benchmark runs were lost to the empty-rid bug discovered
  during guardrail testing. 24 runs have been re-established for terminal-workflow
  benchmarks (3 passes each). BigCodeBench and generic runs need re-running when
  signal data is needed again.

  Workflow: none  Step: none  Trace: 0 entries

## Goal Tree -- COMPLETE

Both north stars completed this session. See `.runtime/goal-tree.json` for full tree.

## Benchmark System

**8 terminal-workflow benchmarks, 24 runs, 100% pass rate:**

| Category | Benchmarks | Runs |
|----------|------------|------|
| harness (terminal-workflow) | 8 | 24 (3 passes each) |

**Note:** All BigCodeBench (94 benchmarks, 114 runs) and generic (6 benchmarks, 18 runs)
data was lost during guardrail vulnerability testing. Infrastructure is intact and
re-runnable. The original 162-run, 114-benchmark result was verified before loss.

## Guardrail Hardening (This Session -- Critical)

**Discovered and fixed: empty-rid vulnerability in cleanup-runs.sh**
`cleanup-runs.sh rm ''` would delete the ENTIRE `.runtime/bench-runs/` directory because
`target="$REAL_RUNS_DIR/$rid"` with empty `$rid` resolves to the runs dir itself.
All 168 benchmark runs were lost when this was discovered during guardrail testing.

**Fixes applied (commit b3565d9):**

| Fix | File | What it catches |
|-----|------|-----------------|
| Empty-rid rejection | `cleanup-runs.sh` | `rm ''` -- deletes all runs |
| Path traversal rejection | `cleanup-runs.sh` | `rm .` or `rm ..` -- targets repo root |
| Flag-ordering detection | `quality-gate.sh` | `rm -fr`, `rm -r --force` -- any flag variant |
| Broad wildcard detection | `quality-gate.sh` | `rm .runtime/*` -- globs on .runtime path |
| Expanded regex patterns | `quality-gate.sh` | `rm\s+.*` instead of `rm\s+-rf` -- catches all flag forms |

**Guardrail test results (sandbox-verified):**
- Empty rid → blocked ✓
- `.` path traversal → blocked ✓
- `..` path traversal → blocked ✓
- `*` wildcard → blocked ✓
- `?` wildcard → blocked ✓
- `[a-z]` bracket → blocked ✓
- `;` injection → blocked ✓
- `rm -fr bench-runs/*` → now caught (was missed) ✓
- `rm -r --force bench-runs/*` → now caught (was missed) ✓
- Valid explicit ID → deletes correctly ✓
- Safe patterns (`cleanup-runs.sh rm id`, `rm /tmp/foo`) → clean ✓

**Acceptable residual gaps:**
- `rm -rf "$VARIABLE"` where VARIABLE points to bench-runs (static analysis limit)
- Direct filesystem operations outside commit path

## Terminal-Workflow Benchmarks (3 Passes Each)

**8 harness benchmarks** -- all at 3-run signal strength (3 passes each, all PASS):

| Type | Benchmark | Passes |
|------|-----------|--------|
| File traversal | find-largest-file | 3/3 PASS |
| Data processing | merge-csv-files | 3/3 PASS |
| Data transform | json-recursive-sort | 3/3 PASS |
| Pattern search | batch-text-dryrun | 3/3 PASS |
| File aggregation | file-type-inventory | 3/3 PASS |
| Data pipeline | data-pipeline-chained | 3/3 PASS |
| Git analysis | git-history-stats | 3/3 PASS |
| Dir lifecycle | temp-directory-operations | 3/3 PASS |

**Known verification pattern (data-pipeline):** Output must include `**Extracted:**`,
`**Transformed:**`, `**Summary:**` markers that verify.sh checks for. Benchmark
output format was updated to document these required markers.

## Terminal-Bench 2.0

**Published at ICLR 2026.** 89 Docker-sandboxed terminal tasks across software engineering, data science, security, networking, and system administration. 

| Info | Detail |
|------|--------|
| Website | tbench.ai |
| Framework | Harbor (`pip install harbor`) |
| Tasks | 89, Docker-sandboxed, <65% frontier model scores |
| Sample data | `scripts/bench/public/terminal-bench-samples.json` |
| Local run | Needs Docker + Harbor |
| Our env | Docker not installed, 12GB RAM available |

Not yet calibrated. Requires Docker installation.

## Next Session Priorities

### P1: Done — Worker timeout / parent-fallback system (implemented this session)
**Problem:** 2 of 8 workers in Pass 3 failed to complete (stuck in loops). MiniMax M2.5 Free was slow.

**Implementations:**
- **`scripts/tools/worker-dispatch.sh`** — Structured dispatch tool with step budget, model selection (minimax/flash/pro), and fallback contract. Run before dispatching a @worker.
- **Worker model upgrade** — All subagents now on `opencode-go/deepseek-v4-flash` (Sustainable Go mode, was minimax-m2.5-free). Applied via `bash scripts/opencode-model-profile.sh sustainable-go`.
- **Step budget in worker prompt** — Config updated: "You have at most 8 tool calls to complete this task. If stuck, write partial output and report BENCH_SUCCESS: false."
- **Registered in tools.toml** — `worker-dispatch` tool with inputs for task, run_dir, steps, model.

**Usage:**
```bash
bash scripts/tools/worker-dispatch.sh \
  --task "description" \
  --run-dir .runtime/bench-runs/my-run \
  --steps 6 --model flash
# Then dispatch @worker with the generated prompt.md
# On failure, parent handles the task directly
```

**Residual:**
- `opencode-model-profile.sh` is all-or-nothing (sets all agents to same model). Per-agent profiles would enable (orchestrator:flash, explorer:minimax, worker:flash).

### P2: Re-establish BigCodeBench + generic benchmark runs
All 114 previous benchmarks (162 runs) were lost to the empty-rid bug.
Infrastructure is intact and re-runnable. Scripts at `scripts/bench/public/`.

### P3 (Optional): Docker + Terminal-Bench 2.0 calibration
Install Docker, set up Harbor, calibrate against the 89 ICLR 2026 tasks.

## Entry Prompt

```
Read HANDOVER.md for complete context before responding.

Current state: 24 runs across 8 terminal-workflow benchmarks (100% pass rate).
Guardrails hardened: cleanup-runs.sh (empty-rid, path-traversal, wildcards)
+ quality-gate.sh (flag-ordering, -fr, --force variants).
All 168 pre-existing runs lost to empty-rid bug discovered during testing.
Benchmarks at 3 runs each (signal strength).

Key guardrail findings:
- empty-rid bug: rm '' deleted entire bench-runs dir (FIXED)
- rm -fr bench-runs/* was missed by quality gate (FIXED)
- rm -r --force bench-runs/* was missed (FIXED)
- All 8 patterns now tested with sandbox verification

PRIORITY 1: Worker timeout / parent-fallback system.
   Design, implement, and verify a timeout mechanism for worker subagents
   that prevents runaway workers and falls back to parent execution.

PRIORITY 2: Re-establish BigCodeBench + generic benchmark runs
   (lost to the empty-rid bug, infrastructure intact).

Key files: scripts/bench/cleanup-runs.sh (safe deletion),
scripts/hooks/quality-gate.sh (check_dangerous_rm),
AGENTS.md line 95 (rm -rf rule),
benchmarks/harness/*.md (8 terminal-workflow benchmarks, 3 passes each)
```
<!-- session-data:end -->
