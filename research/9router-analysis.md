# 9Router --- Architectural Analysis

**Status**: ESTABLISHED
**Source**: Primary (repo README, source code, architecture docs) + Session implementation (5 structural upgrades on main)
**Date**: 2026-05-15

---

## 1. What Is 9Router?

**decolua/9Router** is a router architecture for agentic systems that separates **pipeline transforms** from the **state machine**. Agents route requests through a configurable pipeline of gates, with a separate state machine tracking phase, autonomy level, and accumulated errors.

| Metric | Value |
|--------|-------|
| Repo | [decolua/9Router](https://github.com/decolua/9Router) |
| Key Insight | Pipeline (pure transforms) ≠ State machine (phase state) |

---

## 2. Core Architecture

```
                 ┌──────────────┐
                 │   Request    │
                 └──────┬───────┘
                        │
            ┌───────────▼───────────┐
            │    Routing Pipeline    │  ← Pure transforms, no side effects
            │  (gate composition)    │
            └───────────┬───────────┘
                        │
            ┌───────────▼───────────┐
            │     State Machine     │  ← Phase, autonomy, error state
            │  (session tracking)   │
            └───────────┬───────────┘
                        │
                 ┌──────▼───────┐
                 │   Response   │
                 └──────────────┘
```

### 2.1 Key Architectural Principles

| Principle | Description | Our Implementation |
|-----------|-------------|-------------------|
| **Pipeline/Separation** | Pure transformation chains separate from mutable state | `decision-pipeline.sh` (transforms) vs `session-state.json` + dashboard (state) |
| **Gate Composition** | Pluggable gates that chain with standard exit codes | `scripts/gates/{phase}/*.sh` - auto-discovered, 0/1/2/3 exit codes |
| **Dynamic Autonomy** | Mid-request autonomy escalation based on signals | `autonomy-gate.sh` start/adjust/status |
| **Cooldown Backoff** | Exponential backoff on repeated failures | `error-counter.sh` cooldown = COOLDOWN_BASE × 2^(count-1) |
| **Unified Observability** | Single view into pipeline + state + gates | `session-dashboard.sh` normal/JSON/watch modes |

---

## 3. Implemented Upgrades (All on main)

### Upgrade 1 — Gate Plugin Discovery
`phase-gate.sh` converted from hardcoded case-statement to auto-discovery engine scanning `scripts/gates/{phase}/*.sh`. 9 plugins across 5 phases:

| Phase | Gate Plugins |
|-------|-------------|
| research | sufficiency |
| plan | catfish, scope-check |
| implement | ambiguity-check, autonomy, comprehension, decisions, preflight |
| verify | quality-speed |

Each plugin uses standard exit codes: 0=pass, 1=fail, 2=warn, 3=skip. Adding a new check = creating a file; no editing of `phase-gate.sh`.

### Upgrade 2 — Dynamic Autonomy Cascade
`autonomy-gate.sh` with `start|adjust|status` subcommands. Mid-phase autonomy adjustment based on error-counter signals, comprehension-audit results, and file-decision outcomes. The behavioral counterpart of 9Router's mid-request fallback.

### Upgrade 3 — Decision Pipeline Composition
`decision-pipeline.sh` with 3 defined transitions:
- `research→plan`
- `plan→implement`
- `implement→verify`

Short-circuits on failure. Each step is a gate plugin, results are JSON-logged to `.runtime/decision-log.jsonl`.

### Upgrade 4 — Cooldown + Exponential Backoff
`error-counter.sh` calculates `cooldown = COOLDOWN_BASE × 2^(count-1)`, supports `--retry-after N` override. Prevents cascading failures without permanent blocking.

### Upgrade 5 — Unified Session Dashboard
`session-dashboard.sh` aggregates phase state, gate status, decisions, errors, debt, and autonomy level in normal, JSON, or `--watch` mode. Single entry point for session observability.

---

## 4. Integration Points

| Component | Where it integrates |
|-----------|-------------------|
| All 8 commands (`task.md`, `research.md`, `plan.md`, etc.) | Reference dashboard, pipeline, and autonomy tools |
| `AGENTS.md` | High-Signal Files table updated with new tools |
| `docs/workflow.md` | Decision Pipeline + Session Dashboard sections added |
| `serve-mcp.py` | 3 new resources (`state://dashboard`, `state://autonomy`, `gate://{phase}/{name}`), pipeline/run method, quality gate auto-discovery → 61 resources, 130 tools |
| `phase-gate.sh --check-quality` | Comprehensive flag: runs constitution gates + gate plugins + decision pipeline in one invocation |

---

## 5. Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Exit code 3 (SKIP) for missing evidence | Gates gracefully degrade rather than blocking with confusing errors |
| `--check-quality` as comprehensive flag | Single invocation runs constitution + gates + pipeline |
| MCP `gate://` resources execute live | Agents query gate state programmatically via MCP |
| `session-state.json` overwritten each session | Bare template reset is expected behavior, not drift |
| Gate URI count test uses `>= 8` | Stays robust against new plugin additions |

---

## 6. Architectural Insight Mapped to Our System

```
9Router Concept          → Our Implementation
──────────────────────────────────────────────────
Pipeline (pure transforms) → decision-pipeline.sh
State machine              → session-state.json + dashboard
Gate composition           → scripts/gates/{phase}/*.sh + phase-gate.sh
Dynamic autonomy           → autonomy-gate.sh
Cooldown/backoff           → error-counter.sh
Observability              → session-dashboard.sh
MCP gateway                → serve-mcp.py gate:// resources
```

---

## 7. Smoke Tests

115 tests pass across the entire harness (up from 68 before 9Router work began). The MCP gate-system tests (8 new) cover dashboard, autonomy, `gate://` URIs, gate-plugins, and pipeline/run methods.

---

## References

- [decolua/9Router](https://github.com/decolua/9Router) — source repository
- [scripts/gates/](https://github.com/B67687/agentic-workflows/tree/main/scripts/gates) — gate plugin implementation
- [scripts/phase-gate.sh](https://github.com/B67687/agentic-workflows/blob/main/scripts/phase-gate.sh) — auto-discovery engine
- [scripts/autonomy-gate.sh](https://github.com/B67687/agentic-workflows/blob/main/scripts/autonomy-gate.sh) — dynamic autonomy cascade
- [scripts/decision-pipeline.sh](https://github.com/B67687/agentic-workflows/blob/main/scripts/decision-pipeline.sh) — decision chains
- [scripts/error-counter.sh](https://github.com/B67687/agentic-workflows/blob/main/scripts/error-counter.sh) — exponential backoff
- [scripts/session-dashboard.sh](https://github.com/B67687/agentic-workflows/blob/main/scripts/session-dashboard.sh) — observability
