# AI Prompting Hub — How to Use AI Best

A living knowledge base for prompt design, agent workflows, repo rollout, and reusable lessons.

## Start Here: Pick Your Goal

| I Want To... | Start With |
|--------------|------------|
| **Write better prompts** | [Daily Prompts](docs/daily-prompts.md) → [Prompt Library](docs/prompt-templates.md) |
| **Set up AI agents in my project** | [Hub Quickstart](docs/hub-quickstart.md) → [Agentic Workflows](docs/agentic-workflows.md) → [AGENTS.md](AGENTS.md) |
| **Build an AI product** | [AI Product Building](docs/ai-product-building.md) → [TDD with Agents](docs/tdd-with-agents.md) |
| **Research a new AI topic** | [Research Methodology](docs/research-methodology.md) → [Authoritative Best Practices](docs/authoritative-agent-best-practices.md) |
| **Maintain my cognitive skills** | [Cognitive Identity](docs/cognitive-identity.md) |
| **Understand this whole system** | [System Overview](docs/workspace-system-overview.md) → [Cross-Project Memory](docs/cross-project-memory-loop.md) |
| **Resume interrupted work** | [Session State](workflow/session-state.json) → [AGENTS.md](AGENTS.md) |

## Structure

```
/ (root)
|- AGENTS.md              # Operating contract — rules for working in this repo
|- README.md              # This file — navigation and learning paths
|- docs/                  # Core knowledge base
|- research/              # Active research campaigns
|- scripts/               # Automation scripts
|- workflow/              # Session state, sync logs, registries
|- propagation/   # Templates synced to 25 topic folders
|- archive/               # Preserved historical material
`- personal-voice/        # User voice profile and samples
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
2. **[docs/agentic-workflows.md](docs/agentic-workflows.md)** — Architecture: 2 subagents (Explorer + Worker), routing
2. **[docs/core-agent-doctrine.md](docs/core-agent-doctrine.md)** — 10 principles that underpin the system
3. **[AGENTS.md](AGENTS.md)** - Operating contract: rules, thresholds, coordination notes
4. **[opencode.json](opencode.json)** + **[.opencode/](.opencode/)** — Configuration and definitions

### Product Building Path
For building products fast with AI agents.

1. **[docs/ai-product-building.md](docs/ai-product-building.md)** — One-page spec, 6-week timeline, agent patterns
2. **[docs/tdd-with-agents.md](docs/tdd-with-agents.md)** — Tests-first and red/green patterns
3. **[docs/learning-while-building-with-agents.md](docs/learning-while-building-with-agents.md)** — Keep learning speed close to build speed

### Research Path
For investigating AI topics authoritatively.

1. **[docs/research-methodology.md](docs/research-methodology.md)** — Source hierarchy, verification, confidence levels
2. **[docs/authoritative-agent-best-practices.md](docs/authoritative-agent-best-practices.md)** — Cross-tool guidance
3. **[docs/research-findings.md](docs/research-findings.md)** — Durable discoveries from past research
4. **[research/research-log.md](research/research-log.md)** — Active research campaigns

### System Path
For understanding how this hub and its ecosystem work.

1. **[docs/workspace-system-overview.md](docs/workspace-system-overview.md)** — Whole-system map
2. **[docs/cross-project-memory-loop.md](docs/cross-project-memory-loop.md)** — How knowledge flows: topic folders ↔ hub
3. **[propagation/README.md](propagation/README.md)** — How templates propagate to 25 topic folders

## Quick Reference

| Need | Doc |
|------|-----|
| Session checkpoint rules | [docs/session-checkpoint.md](docs/session-checkpoint.md) |
| Model selection guide | [docs/model-selection-guide.md](docs/model-selection-guide.md) |
| Quality standards | [docs/quality-standards.md](docs/quality-standards.md) |
| Git/GitHub best practices | [docs/git-github-best-practices.md](docs/git-github-best-practices.md) |
| Repo tooling (Windows/WSL) | [docs/repo-tooling.md](docs/repo-tooling.md) |
| Token-efficient prompting | [docs/token-efficient-prompting.md](docs/token-efficient-prompting.md) |
| Cognitive identity | [docs/cognitive-identity.md](docs/cognitive-identity.md) |
| Codex reasoning guide | [docs/codex-reasoning-guide.md](docs/codex-reasoning-guide.md) |

## Research

- **[research/research-log.md](research/research-log.md)** — Active research intake and campaign index
- **[research/research-prompt.md](research/research-prompt.md)** — Reusable research prompt with analysis framework
- **[research/integration-log.md](research/integration-log.md)** — Research-to-knowledge-base integration tracker
- **[docs/research-findings.md](docs/research-findings.md)** — Durable validated discoveries
- **[archive/research-log-2026-04.md](archive/research-log-2026-04.md)** — Full April 2026 pre-optimization research log.

## Scripts

Use [scripts/ws.ps1](scripts/ws.ps1) for common workspace operations:

```pwsh
.\scripts\ws.ps1 status      # Check workspace state
.\scripts\ws.ps1 validate    # Run quality audit
.\scripts\ws.ps1 hotspots    # Find recent changes
.\scripts\ws.ps1 search -Query "session-state"
.\scripts\ws.ps1 research    # Preview research findings
.\scripts\ws.ps1 propagate   # Preview propagation (add -Apply to execute)
```

## Propagation

Templates in `propagation/` sync to 25 topic folders in `M-Namikaz-Others/`.

```pwsh
.\scripts\propagate-to-all.ps1 -Apply   # Sync templates outward
```

- `AGENTS.md`, `topic-insights.md`, `.cleanup-protect`, and other templates are propagated
- Topic folders create `[folder-name]-content/` for normal project work
- Root-level files are protected from cleanup

## Archive

- **[archive/README.md](archive/README.md)** — Archive conventions
- **[archive/history-2026-04.md](archive/history-2026-04.md)** — April 2026 session history
- **[archive/early-history.md](archive/early-history.md)** — Sessions 1–11 (awaiting user input)

## Maintenance Rule

If you want to keep improving this folder:

1. Save the prompt shape that worked.
2. Save the lesson that should change future behavior.
3. Save one compact example of when to use it.

## Common Commands

PowerShell is the default terminal for mutating workspace automation. For WSL read-only inspection, use `bash scripts/ws.sh validate` after installing the Linux tool baseline in [docs/repo-tooling.md](docs/repo-tooling.md).
