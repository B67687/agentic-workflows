# Session Handover -- 2026-05-20 (Updated)

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
| agentic-workflows | main | d9a31ce Fix BigCodeBench categorization + 140933d BigCodeBench pipeline |

Changes: 0 uncommitted (run data in .runtime/bench-runs/ is gitignored)

  Guardrails active:
  - cleanup-runs.sh (empty-rid/glob/path-traversal rejection) -- HARDENED
  - quality-gate.sh (check_dangerous_rm catches -fr, --force variants) -- HARDENED
  - AGENTS.md (rule forbid raw rm -rf on .runtime/bench-runs/)

  Total runs: 142 (24 harness + 18 generic + 100 BigCodeBench) — 97.9% pass rate.
  3 BigCodeBench failures: all version-compat issues (pandas applymap, scipy mode).
  Docker installed (moby-engine v29.4.3), Harbor 0.7.1, Docker Compose (moby-compose v5.1.3).
  Terminal-Bench 2.0 oracle baseline in progress (~91% mean).

  Workflow: none  Step: none  Trace: 0 entries

## Benchmark System

**142 runs across 114 benchmarks, 97.9% pass rate:**

| Category | Benchmarks | Runs | Pass Rate |
|----------|------------|------|-----------|
| BigCodeBench (diverse subset) | 100 | 100 | 97% |
| generic (system skills) | 6 | 18 | 100% |
| harness (terminal-workflow) | 8 | 24 | 100% |

## Guardrail Hardening

**Previously hardened (committed):**
- cleanup-runs.sh: empty-rid/glob/path-traversal rejection
- quality-gate.sh: flag-ordering, -fr, --force detection
- All verified in sandbox, no gaps found in active use

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

## Terminal-Bench 2.0 — Calibrating

**Published at ICLR 2026.** 89 Docker-sandboxed terminal tasks. Setup complete:

| Info | Detail |
|------|--------|
| Website / Leaderboard | tbench.ai |
| Framework | Harbor 0.7.1 (installed) |
| Docker | moby-engine 29.4.3 (running) |
| Docker Compose | moby-compose 5.1.3 (installed) |
| Tasks | 89, Docker-sandboxed |
| Our env | 8 CPUs, 11.68GB RAM, 914GB free |
| Oracle baseline | In progress (~91% mean) |

**To run oracle baseline (from terminal):**
```bash
source /home/namikaz/projects/dev/agentic-workflows/.runtime/bench-env/bin/activate
harbor run -d terminal-bench/terminal-bench-2 -a oracle
```

**To run with an agent (for leaderboard):**
```bash
harbor run -d terminal-bench@2.0 -a "agent-name" -m "model" -k 5
```

## Next Session Priorities

### COMPLETED (previous sessions):
- **P1**: Worker timeout / parent-fallback system (worker-dispatch.sh)
- **P2**: Benchmark dispatch system + generic benchmarks re-established (18/18)
- **P3**: BigCodeBench pipeline + scale to 100 problems (97/100, 97%)
- **P4**: Docker/Harbor/Terminal-Bench infrastructure set up

### Backlog (remaining work):

**1. Fix remaining 3 BigCodeBench failures**
   - BigCodeBench/602, 797: DataFrame.applymap() removed in pandas 2.2+
   - BigCodeBench/736: scipy.stats.mode() return type changed
   - Options: pin library versions to match dataset, or patch canonical solutions

**2. Complete Terminal-Bench oracle baseline**
   - Wait for current run to finish (~91% mean, 89 tasks)
   - Investigate any failures (expected due to Docker env quirks)
   
**3. Run agent on Terminal-Bench for leaderboard**
   - Adapt OpenCode/agent harness to Harbor's agent interface (`-a "agent"`)
   - Run with `-k 5` (5 trials per task for statistical significance)
   - Submit results via PR to `harborframework/terminal-bench-2-leaderboard` on HuggingFace

**4. Scale BigCodeBench further**
   - Currently 100 problems, 1,040 remaining in dataset
   - Could push to 200, 500, or all 1,140

**5. Mini PC research (NEW)**
   - Find dedicated hardware for running benchmarks long-term
   - Requirements: headless Linux, 32GB+ RAM, 1TB NVMe, 8+ cores
   - Budget: ~$500-700
   - Candidates: Intel NUC, ASUS NUC, Minisforum, Beelink SER series
   - Goal: always-on benchmark runner, no laptop tied up

## Entry Prompt

```
Read HANDOVER.md for complete context before responding.

Current state: 142 runs across 114 benchmarks (24 harness + 18 generic + 100 BigCodeBench, 97.9%).
Docker/Harbor/Terminal-Bench infrastructure ready. Oracle baseline in progress (~91%).

COMPLETED:
- P1: Worker timeout/parent-fallback system.
- P2: Benchmark dispatch + generic benchmarks re-established (18/18).
- P3: BigCodeBench pipeline + scale to 100 problems (97/100 pass).
- P4: Docker installed, Harbor 0.7.1, Docker Compose, Terminal-Bench oracle running.

REMAINING:
1. Fix 3 BigCodeBench version-compat failures (pandas applymap, scipy mode).
2. Complete Terminal-Bench oracle baseline, verify results.
3. Run actual agent on Terminal-Bench for leaderboard submission.
4. Scale BigCodeBench further (from 100 toward 1,140).
5. Research mini PC for dedicated benchmark hardware (~$500-700).

Key files:
- scripts/tools/benchmark-dispatch.sh (batch benchmark dispatch)
- scripts/tools/worker-dispatch.sh (worker dispatch with step budget)
- scripts/bench/public/solve-bigcodebench.py (batch-solve + verify)
- scripts/bench/public/select-batch.sh (diverse problem selection)
- .runtime/bench-env/ (Python venv with BigCodeBench 0.2.5 + Harbor 0.7.1)
```
<!-- session-data:end -->
