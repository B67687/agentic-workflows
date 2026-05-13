---
name: systems-health
description: Measure the health of a software development system using stocks, flows, and feedback loops. Pulls data from git, GitHub, and CI to diagnose what's working and what's broken. Use when someone
  says "systems health", "how's the project going", "health check", "are we shipping fast enough", "what's slowing us down". Outputs to .tap/system-health.md.
compatibility: claude-code, cursor, opencode, gemini-cli, codex-cli
allowed-tools: bash, read, grep, glob
metadata:
  companion-script: scripts/systems-health.sh
  handoffs: retrospective (to capture learnings from problems found), tap-audit (for full repo readiness)
  trigger-phrases: systems health, how's the project going, health check, are we shipping fast enough, what's slowing us down, measure our process
  bundle: assess
---
# Systems Health

Diagnose the development system. Measure stocks, flows, and feedback loops. Find what's sick and prescribe the cheapest fix.

**Companion script:** `scripts/systems-health.sh`
```bash
bash ./scripts/systems-health.sh collect [dir]   # collect data from git/GitHub/CI
bash ./scripts/systems-health.sh stocks           # measure stocks
bash ./scripts/systems-health.sh flows            # measure flows
bash ./scripts/systems-health.sh feedback         # assess feedback loops
bash ./scripts/systems-health.sh complexity       # complexity signals
bash ./scripts/systems-health.sh diagnose         # diagnose and prescribe
bash ./scripts/systems-health.sh report           # generate report
```

## Process

### 1. Collect Data

Pull from available sources:
```
git log --oneline --since="30 days ago"          -> commit frequency
git shortlog -sn --no-merges --since="30 days ago" -> contributors
gh pr list --state all --limit 50                -> PR lifecycle
gh run list --limit 20                           -> CI pass/fail rate
gh issue list --label bug --limit 50             -> bug lifecycle
```

Also read: `.tap/tap-audit.md`, `.tap/system-health.md` (prior snapshot for trends).

### 2. Measure Stocks

| Stock | Measure | Healthy signal |
|-------|---------|----------------|
| Backlog | Open issues count | Stable or shrinking |
| Open PRs | Count + age | < 5 open, oldest < 3 days |
| Open bugs | Bug issues count | Stable or shrinking |
| Test count | Test runner dry-run | Growing with codebase |

Trend: ▲ growing / ▼ shrinking / ─ stable

### 3. Measure Flows

| Flow | Measure | What it tells |
|------|---------|---------------|
| Stories in | Issues created/week | Demand on system |
| Stories out | PRs merged/week | Throughput |
| Cycle time | PR open->merge (median) | How fast work moves |
| Review time | PR open->review (median) | Bottleneck indicator |
| Bug inflow | Bugs created/week | Quality signal |
| Deploy frequency | Deploys/week | Delivery cadence |

### 4. Assess Feedback Loops

**Balancing (self-correcting):** CI gate, code review, bug triage, test failures
**Reinforcing (amplifying):** Test coverage, documentation, small batches

For each: is it working or broken? Evidence, not guesswork.

### 5. Measure Complexity Signals

| Signal | How | Concern |
|--------|-----|---------|
| Change amplification | Median files/commit | Trending up |
| Shotgun surgery | % commits 5+ files / 3+ dirs | > 20% |
| Cognitive load | Large files with high churn | Any? |
| Unknown unknowns | % merged PRs with no test change | Trending up |

### 6. Diagnose and Prescribe

```
Diagnosis: [what's sick]
Evidence:  [data that proves it]
Impact:    [how it slows delivery or hurts quality]
Rx:        [cheapest intervention]
```

Common diagnoses:
- Stocks accumulating -> find bottleneck flow
- Slow cycle time -> usually review or CI time
- Broken feedback loop -> who stopped responding to the signal?
- No feedback loop -> suggest creating one

### 7. Write Output

Write to `.tap/system-health.md`. If prior exists, compare trends.

```
`★ Systems Health ────────────────────────────────`
[repo] --- [Healthy / N problems / Backing up]
  ├─ [most impactful finding]
  └─ [cheapest fix]
`─────────────────────────────────────────────────`
```

## Boundaries

- Read-only --- does NOT modify code, config, or process
- Does NOT assess code quality (-> code-review-and-quality)
- Does NOT assess agent readiness (-> tap-audit)
- Data-driven --- every claim backed by evidence from git/GitHub/CI
