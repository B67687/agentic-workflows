# Agentic Workflows --- Agent Harness + Systems Engineering

An agent harness for orchestrating, managing, and extending AI agents. Not a code project --- a systems engineering workspace for agent workflows, cross-repo orchestration, and capability propagation.

## Operating Contract

**Core principle: Supply missing structure when safe.**
When the request is clear enough and risk is low, proactively sharpen scope, choose investigation order, define verification targets, use the lightest lane, and switch to tests-first for behavior changes.

**Default research conduct:** Rigorous by default --- source triangulation, confidence levels (SPECULATIVE->ESTABLISHED), authority weighting, cited sources. 6-phase methodology in `research/research-prompt.md`.

**Default fix conduct (macro-to-micro):** Start at system architecture -> affected domain -> module -> root cause. Never skip levels --- see `skills/debugging-and-error-recovery/SKILL.md`.

**Automatic questioning:** Run Clarification Protocol (`skills/clarification-protocol/SKILL.md`) on vague requests. One structured question at a time. Never guess when asking resolves ambiguity.

## Startup Order

1. `session-state.json` --- read first on every resume
2. Lifecycle hooks: `bash ./scripts/hooks/session-start.sh` (merged: branch, session state, gap detection)
3. `AGENTS.md` --- this operating contract
4. `constitution.md` --- governance rules (skip for non-governance tasks)
5. `docs/workflow.md` --- fast orientation (read on demand)
6. Task-specific files only when needed

## High-Signal Files

| File | Purpose |
|------|---------|
| `session-state.json` | Active session; read first on resume |
| `docs/workflow.md` | Compact workflow summary |
| `scripts/tools.sh` | Tool registry --- list all agent-callable tools |
| `scripts/skill-toolset.sh` | Progressive skill loading (L1/L2/L3) |
| `scripts/search-index.sh` | BM25 text index query |
| `scripts/test-smoke.sh` | 115-test smoke suite |
| `scripts/session-status.sh` | Workspace orientation overview |
| `constitution.md` | Governance rules (on demand) |

## Key Rules

- **No new files** if an existing doc covers the need.
- **Verify aggressively** --- verification is the quality engine.
- **Weigh complexity vs improvement** --- simpler is better. Removing code while keeping function is a double win.
- **Summarize work** as root cause, fix, verification, residual risk.
- **Commit after every meaningful change** --- run `bash ./scripts/checkpoint-commit.sh -m "summary"` immediately.
- **Phase-based work**: research -> plan -> implement. Don't jump to code.
- **Fix macro-to-micro**: system -> domain -> module -> root cause.
- **One task per session**: topic shift? Checkpoint and restart fresh.
- **Probe repo before edits**: branch, divergence, dirt, upstream.
- **Batch file reads 3 at a time** --- avoid 6+ reads mixed with long builds (memory pressure on WSL2).

## Governance

- Runtime authority: your agent runtime config (OpenCode at `$HOME/.config/opencode/opencode.jsonc`)
- Repo authority: `session-state.json` -> `AGENTS.md` -> `docs/workflow.md`
- No tool-specific runtime configs repo-locally (no `.claude/settings.json` overrides, etc.)

## Agentic Behavior

- **Brevity by default**: simple->1 sentence, medium->bullets, complex->sections.
- **Proactive checkpointing**: suggest handoff at 10+ turns, compress to 5-line summary.
- **Handle directly by default** (<10 file search, 1-3 line edits, <10 file ops, plans under 5 steps).
  Route to @explore/@worker when exceeding thresholds.
- **Worktree for big tasks, main for quick fixes**: `bash ./scripts/session-fork.sh "<name>"` for multi-file changes.
- **Context compression**: pass only Task (bounded) + Context (3-5 bullets) + Files (paths) + Constraints + Done When.
- **Completion status**: DONE / DONE_WITH_CONCERNS / BLOCKED / NEEDS_CONTEXT. Escalate after 3 consecutive failures.
- **Safety scoping**: `.gstack-freeze` creates a hard edit boundary. Do not edit files outside it.

## Session Documentation

After meaningful work, update `session-state.json`. Write `archive/history-index.md` (compact) and `archive/history-full-detailed.md` (narrative). History is NOT read by default --- it's for long-break resumes.

## Deep References

Full reference tables moved to [`docs/reference/agent-operating-contract.md`](docs/reference/agent-operating-contract.md) covering:
- Skill bundles and lifecycle integration
- Memory architecture (learnings, agentmemory, ruflo)
- SwarmVault rules and schema
- Full key rules list with details
- Deep reference table (50+ entries)
- Provider runtime notes
- Agent coding rules
