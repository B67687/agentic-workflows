# agentic-workflows — Systems Engineering for AI Agents

Systems engineering applied to the agent domain: an agent harness for orchestrating,
managing, and extending AI agents. Cross-repo orchestration, knowledge propagation,
and capability management.

## Start Here: Pick Your Goal

| I Want To... | Start With |
|--------------|------------|
| **Write better prompts** | [Daily Prompts](docs/daily-prompts.md) → [Prompt Library](docs/prompt-templates.md) |
| **Set up AI agents in my project** | [Hub Quickstart](docs/hub-quickstart.md) → [Workflow](docs/workflow.md) → [AGENTS.md](AGENTS.md) |
| **Build an AI product** | [AI Product Building](docs/ai-product-building.md) → [TDD with Agents](docs/tdd-with-agents.md) |
| **Research a new AI topic** | [Research Methodology](research/research-prompt.md) → [Well-Maintained Systems](research/well-maintained-system-research.md) |
| **Understand this whole system** | [Workflow](docs/workflow.md) → [Cross-Project Memory](docs/cross-project-memory-loop.md) |
| **Resume interrupted work** | [Session State](session-state.json) → [AGENTS.md](AGENTS.md) |

## Structure

```
/ (root)
|- AGENTS.md              # Operating contract — rules for working in this repo
|- README.md              # This file — navigation and learning paths
|- docs/                  # Core knowledge base
|- research/              # Active research campaigns
|- scripts/               # Automation scripts
|- workflow/              # Session state, sync logs, registries
|- propagation/   # Templates synced to topic folders
`- ../personal-voice/      # User voice profile (topic folder, not embedded)
```

## Learning Paths

### Prompting Path
For anyone who wants to write better prompts immediately.

1. **[docs/daily-prompts.md](docs/daily-prompts.md)** — 5 reusable prompt shapes for common tasks
2. **[docs/prompt-templates.md](docs/prompt-templates.md)** — Full copy-paste library index
3. **[docs/token-efficient-prompting.md](docs/token-efficient-prompting.md)** — Reduce token burn without losing quality

### Agent Setup Path
For setting up agentic workflows in your projects.

1. **[docs/hub-quickstart.md](docs/hub-quickstart.md)** - Fast orientation for the current system
2. **[docs/fast-stable-delivery.md](docs/fast-stable-delivery.md)** — Why this system is structured around big goals, bounded bets, and small verified slices
3. **[archive/superseded/agentic-workflows.md](archive/superseded/agentic-workflows.md)** — Routing ideas, fresh-context patterns, and execution lanes
4. **[archive/superseded/core-agent-doctrine.md](archive/superseded/core-agent-doctrine.md)** — 10 principles that underpin the system
5. **[AGENTS.md](AGENTS.md)** - Operating contract: rules, thresholds, coordination notes
6. **[AGENTS.md](AGENTS.md)** + **[session-state.json](session-state.json)** — Runtime contract and resume state

### Product Building Path
For building products fast with AI agents.

1. **[docs/ai-product-building.md](docs/ai-product-building.md)** — One-page spec, 6-week timeline, agent patterns
2. **[docs/tdd-with-agents.md](docs/tdd-with-agents.md)** — Tests-first and red/green patterns
3. **[archive/lessons/learning-while-building-with-agents.md](archive/lessons/learning-while-building-with-agents.md)** — Keep learning speed close to build speed

### Research Path
For investigating AI topics authoritatively.

1. **[archive/research/research-methodology.md](archive/research/research-methodology.md)** — Source hierarchy, verification, confidence levels
2. **[archive/lessons/authoritative-agent-best-practices.md](archive/lessons/authoritative-agent-best-practices.md)** — Cross-tool guidance
3. **[archive/research/research-findings.md](archive/research/research-findings.md)** — Durable discoveries from past research
4. **[research/research-log.md](research/research-log.md)** — Active research campaigns

### System Path
For understanding how this hub and its ecosystem work.

1. **[docs/workflow.md](docs/workflow.md)** — Whole-system map
2. **[docs/cross-project-memory-loop.md](docs/cross-project-memory-loop.md)** — How knowledge flows: topic folders ↔ hub
3. **[scripts/propagate-to-all.sh](scripts/propagate-to-all.sh)** + **[docs/workflow.md](docs/workflow.md)** — How shared defaults propagate to topic folders

## Quick Reference

| Need | Doc |
|------|-----|
| Session checkpoint rules | [docs/session-checkpoint.md](docs/session-checkpoint.md) |
| Model selection guide | [docs/model-selection-guide.md](docs/model-selection-guide.md) |
| Provider runtime and account switching | [docs/provider-runtime.md](docs/provider-runtime.md) |
| Quality standards | [docs/quality-standards.md](docs/quality-standards.md) |
| Git/GitHub best practices | [docs/git-github-best-practices.md](docs/git-github-best-practices.md) |
| Fast stable delivery model | [docs/fast-stable-delivery.md](docs/fast-stable-delivery.md) |
| Counsel model selection | [docs/counsel-model-selection.md](docs/counsel-model-selection.md) |
| Borrowed workflow patterns that fit this hub | [archive/superseded/agentic-workflows.md](archive/superseded/agentic-workflows.md) |
| Repo tooling (Windows/WSL) | [docs/repo-tooling.md](docs/repo-tooling.md) |
| Token-efficient prompting | [docs/token-efficient-prompting.md](docs/token-efficient-prompting.md) |

## Research

- **[research/research-log.md](research/research-log.md)** — Active research intake and campaign index
- **[research/research-prompt.md](research/research-prompt.md)** — Reusable research prompt with analysis framework
- **[research/integration-log.md](research/integration-log.md)** — Research-to-knowledge-base integration tracker
- **[archive/research/research-findings.md](archive/research/research-findings.md)** — Durable validated discoveries
- **[archive/research-log-2026-04.md](archive/research-log-2026-04.md)** — Full April 2026 pre-optimization research log.

## Scripts

Use [scripts/ws.sh](scripts/ws.sh) for common workspace operations:

```bash
bash ./scripts/ws.sh status      # Check workspace state
bash ./scripts/ws.sh validate    # Run quality audit
bash ./scripts/ws.sh hotspots    # Find recent changes
bash ./scripts/ws.sh search -q "session-state"
```

## Propagation

Templates in `propagation/` drive two different actions:

- bootstrap missing shared files into topic folders
- refresh only the hub-owned managed core in topic folders

```bash
bash ./scripts/propagate-to-all.sh
bash ./scripts/propagate-to-all.sh --apply
bash ./scripts/checkpoint-commit.sh -m "checkpoint summary"
```

- Managed core: `AGENTS.md`, `archive/superseded/workspace-system-overview.md`, `checkpoint-commit.sh`, and helper scripts
- Repo-owned after bootstrap: `session-state.json`, `topic-insights.md`, `.cleanup-protect`, and archive history files
- Topic folders create `[folder-name]-content/` for normal project work
- Run the smoke test after changing `propagate-to-all.sh`, `check-sync-status.sh`, `sync-from-hub.template.sh`, or `propagation-contract.sh`

## Archive

- **[archive/README.md](archive/README.md)** — Archive conventions
- **[archive/history-index.md](archive/history-index.md)** — Quick archive index
- **[archive/history-full-detailed.md](archive/history-full-detailed.md)** — Full historical narrative
- **[archive/early-history.md](archive/early-history.md)** — Sessions 1–11 (awaiting user input)

## Maintenance Rule

If you want to keep improving this folder:

1. Save the prompt shape that worked.
2. Save the lesson that should change future behavior.
3. Save one compact example of when to use it.

## Common Commands

Use bash as the default terminal for workspace automation. Only fall back to PowerShell in repos that explicitly require it.

Fast workflow:

- keep the dream large, but only execute one verified slice at a time
- type normally; serious requests route internally through `/route`
- prompting best practices run internally through `/prompt-contract`
- `/task your goal` — classify, grill, shape, slice, and intake any task
- `/counsel your decision` when a high-cost decision needs independent challenge
- `/repo-map` when the folder is unfamiliar or the task is broad
- `/research your task`
- `/plan your task`
- `/implement your task`
- `/optimize your task` for performance or architecture cost work
- `/session checkpoint` to wrap up a verified phase
- `/session handoff` before a new session or high-context transition
- `/session finish` to close and checkpoint in one step
