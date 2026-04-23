# Prompting Notes

This folder is a living knowledge base for prompt design, agent workflows, repo rollout, and reusable lessons.

## Structure

```
/ (root)
|- AGENTS.md              # Operating contract
|- README.md              # High-level map
|- docs/                  # Source knowledge base
|- research/              # Research logs and integration notes
|- scripts/               # Automation scripts
|- workflow/              # Generated workflow files, state, logs, registries
|- propagate-templates/   # Templates that auto-propagate to topic folders
|- archive/               # Preserved absorbed material
`- personal-voice/        # User voice profile and samples
```

## Start Here 

- [workflow/session-state.json](workflow/session-state.json): Active session state. Read this first when resuming work.
- [AGENTS.md](AGENTS.md): Operating contract and current rules for this hub.
- [docs/workspace-system-overview.md](docs/workspace-system-overview.md): The fastest plain-language map of what this whole workspace system does.
- [docs/core-agent-doctrine.md](docs/core-agent-doctrine.md): The compact shared backbone for scope, evidence, execution lanes, verification, and compounding memory.
- [docs/daily-prompts.md](docs/daily-prompts.md): The shortest set of prompts worth reusing often.
- [propagate-templates/README.md](propagate-templates/README.md): Two-git architecture and propagation guide.
- [docs/prompt-templates.md](docs/prompt-templates.md): Copy-paste prompt templates for serious work.
- [docs/session-checkpoint.md](docs/session-checkpoint.md): Full rules for the session state + checkpoint system.

## Core References

- [docs/token-efficient-prompting.md](docs/token-efficient-prompting.md): Workflow-cost reduction and context hygiene.
- [docs/tdd-with-agents.md](docs/tdd-with-agents.md): Tests-first and red/green TDD patterns.
- [docs/learning-while-building-with-agents.md](docs/learning-while-building-with-agents.md): How to keep learning speed closer to build speed when working with agents.
- [docs/authoritative-agent-best-practices.md](docs/authoritative-agent-best-practices.md): Cross-tool guidance.
- [docs/research-methodology.md](docs/research-methodology.md): Authoritative source hierarchy, evaluation checklist, and AI-specific source pitfalls.
- [docs/cognitive-identity.md](docs/cognitive-identity.md): Human-AI cognitive partnership.
- [docs/codex-reasoning-guide.md](docs/codex-reasoning-guide.md): Practical reasoning-effort guidance.
- [docs/repo-tooling.md](docs/repo-tooling.md): Preferred Windows and WSL/Linux CLI tooling.
- [docs/git-github-best-practices.md](docs/git-github-best-practices.md): Git and GitHub best practices, including state awareness for AI agents.
- [docs/quality-standards.md](docs/quality-standards.md): Quality criteria for this knowledge base.
- [docs/workspace-system-overview.md](docs/workspace-system-overview.md): System map for the hub, topic folders, research loop, propagation loop, and session state.
- [docs/session-recovery-guide.md](docs/session-recovery-guide.md): OpenCode session visibility and restore troubleshooting.
- [docs/prompt-library/](docs/prompt-library/): Full grouped prompt library.

## Research

- [research/README.md](research/README.md): Quick start and workflow
- [research/research-prompt.md](research/research-prompt.md): Reusable research prompt with analysis framework
- [research/research-log.md](research/research-log.md): Active research intake and campaign index
- [research/archived-findings.md](research/archived-findings.md): Durable discoveries
- [research/integration-log.md](research/integration-log.md): Research-to-knowledge-base integration tracker
- [archive/research-log-2026-04.md](archive/research-log-2026-04.md): Full April 2026 pre-optimization research log.

## Model Testing

- [model-tests/README.md](model-tests/README.md): Model testing system — standardized tasks, self-documenting results, comparison archive.
- [model-tests/tasks/](model-tests/tasks/): Standardized test tasks (coding, reasoning, context, tool-use, style, speed)
- [model-tests/run-model-tests.ps1](model-tests/run-model-tests.ps1): Run tests against current model, record results.

## AI Product Building

- [docs/ai-product-building.md](docs/ai-product-building.md): Build products fast with AI agents — spec method, agent patterns, 6-week timeline, reliability thresholds.

## Human-AI Cognitive Partnership

- [docs/cognitive-identity.md](docs/cognitive-identity.md): Maintain your cognitive identity as AI advances — judgment, verification, skill ownership, and growth intentionality.

## Rollout And Templates

- [docs/project-rollout-template.md](docs/project-rollout-template.md): How to propagate these practices across repos.
- [docs/cross-project-memory-loop.md](docs/cross-project-memory-loop.md): How local repo lessons should flow back into this central library and back out again.
- [scripts/bootstrap-project-instructions.ps1](scripts/bootstrap-project-instructions.ps1): Seed one repo with local instruction files.
- [scripts/set-promotion-review-status.ps1](scripts/set-promotion-review-status.ps1): Persist review decisions for promotion candidates.
- [scripts/sync-project-instructions.ps1](scripts/sync-project-instructions.ps1): Sync a chosen set of repos.
- [scripts/sync-all-project-instructions.ps1](scripts/sync-all-project-instructions.ps1): Sync all repos in the cross-domain registry.
- [scripts/propagate-to-all.ps1](scripts/propagate-to-all.ps1): Hub-to-all propagation (run from AI Prompting folder).
- [propagate-templates/AGENTS.template.md](propagate-templates/AGENTS.template.md): Canonical repo `AGENTS.md` template.
- [propagate-templates/topic-insights.template.md](propagate-templates/topic-insights.template.md): Canonical repo lessons template.
- [propagate-templates/git-github-best-practices.template.md](propagate-templates/git-github-best-practices.template.md): Git/GitHub best practices template.
- [propagate-templates/opencode-agent-system.template.md](propagate-templates/opencode-agent-system.template.md): OpenCode agentic workflow guide template.
- [propagate-templates/opencode.template.json](propagate-templates/opencode.template.json): OpenCode native agent config template.
- [propagate-templates/sync-from-hub.template.ps1](propagate-templates/sync-from-hub.template.ps1): Self-service sync script for topic folders.

## Workflow Files

- [workflow/cross-domain-registry.md](workflow/cross-domain-registry.md): Participating folder registry.
- [workflow/cross-domain-candidates.md](workflow/cross-domain-candidates.md): Current cross-domain review queue.
- [workflow/cross-domain-review-state.json](workflow/cross-domain-review-state.json): Persistent candidate review decisions.
- [workflow/harvested-topic-insights.md](workflow/harvested-topic-insights.md): Latest harvested topic insights.
- [workflow/merge-log.md](workflow/merge-log.md): Cross-domain merge history.
- [workflow/sync-state.json](workflow/sync-state.json): Last propagation sync state.
- [workflow/session-state.json](workflow/session-state.json): **Active session state - read first on every resume.**
- [workflow/session-state.template.json](workflow/session-state.template.json): Blank session state template.

## Archive

- [archive/README.md](archive/README.md): Archive conventions and raw snapshot policy.
- [archive/history-2026-04.md](archive/history-2026-04.md): Full April 2026 pre-optimization session history.
- [archive/prompt-templates-2026-04-pre-split.md](archive/prompt-templates-2026-04-pre-split.md): Exact prompt-template file before the prompt-library split.

## Maintenance Rule

If you want to keep improving this folder, the simplest loop is:

1. Save the prompt shape that worked.
2. Save the lesson that should change future behavior.
3. Save one compact example of when to use it.

## Common Commands

Use [scripts/ws.ps1](scripts/ws.ps1) for the repeated workspace checks:

```pwsh
.\scripts\ws.ps1 status
.\scripts\ws.ps1 validate
.\scripts\ws.ps1 hotspots
.\scripts\ws.ps1 search -Query "session-state"
.\scripts\ws.ps1 research
.\scripts\ws.ps1 propagate
```

The wrapper is read-only by default. Use `.\scripts\ws.ps1 propagate -Apply` only when intentionally syncing template changes outward.

PowerShell is the default terminal for mutating workspace automation. For WSL read-only inspection, use `bash scripts/ws.sh validate` after installing the Linux tool baseline in [docs/repo-tooling.md](docs/repo-tooling.md).

## Propagation

- `.cleanup-protect` and `AGENTS.md` are propagated to repos and protected from cleanup.
- Propagation creates a mandatory `[folder-name]-content/` folder; agents should do normal project work there.
- `meta/` is optional; create it only when a project needs durable local context.
- Keep propagated folder roots sparse. Normal notes, source, assets, downloads, logs, archives, datasets, drafts, and project docs belong in `[folder-name]-content/`.
- If old root content exists, classify it before moving. Do not move `.git`, active project roots, caches, or tool-specific folders without explicit approval.
- For public repos, add propagated files to the repo's `.gitignore` before pushing.
- Use `scripts/propagate-to-all.ps1` to propagate templates and `scripts/cleanup-folders.ps1` to clean up.
