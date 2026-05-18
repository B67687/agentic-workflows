# Deep References

Full reference table for all skills, scripts, docs, and governance links.

| Topic | Reference |
|-------|-----------|
| Workflow and routing | `docs/workflow.md`, `workflow.d/SCHEMA.md` |
| Agentic behavior rules | moved to `docs/workflow.md` |
| Skills reference | `skills/`, `docs/agent-skills/`, `scripts/skill-toolset.sh` |
| Model selection and fallbacks | `docs/model-selection-guide.md` |
| Token/context efficiency | `docs/token-efficient-prompting.md` |
| Session checkpoints and recovery | `docs/session-checkpoint.md`, `docs/session-recovery-guide.md` |
| Assumption expiry (upwards management) | `docs/assumption-expiry.md`, `scripts/assumption-expiry.sh` |
| Agent-human interaction patterns | `docs/agent-human-interaction.md` |
| Agent-to-agent (A2A) protocol | `docs/a2a-protocol.md` |
| Agent context handover guide | `docs/agent-context-handover.md` |
| Multi-agent debate (Parley) | `docs/parley-system.md` |
| Cross-project memory loop | `docs/cross-project-memory-loop.md` |
| Memory architecture | `docs/learnings-strategy.md` (3-store system: learnings.jsonl, agentmemory MCP, ruflo) |
| Domain language glossary | `docs/context-format.md` |
| Visual language spec | `docs/design-md-pattern.md` |
| Fast / stable delivery patterns | `docs/fast-stable-delivery.md` |
| Free-tier agentic coding guide | `docs/free-tier-agentic-guide.md` |
| Quality standards | `docs/quality-standards.md` |
| GitHub best practices | `docs/git-github-best-practices.md` |
| MCP architecture reference | `docs/mcp-architecture.md` |
| Prompt templates library | `docs/prompt-templates.md`, `docs/prompt-library/` |
| Counsel model selection | `docs/counsel-model-selection.md` |
| Requirements alignment | `skills/grill-me/SKILL.md` |
| Structured questioning | `skills/structured-questioning/SKILL.md` |
| Skill design patterns | `docs/skill-design-patterns.md` |
| Bash-hybrid exploration | `skills/bash-explore/SKILL.md` |
| BM25 workspace search | `scripts/search-index.sh` |
| Repo map (tree-sitter) | `scripts/repo-map.sh` |
| Project rollout template | `docs/project-rollout-template.md` |
| Agent sandbox | `docs/agent-sandbox.md`, `scripts/agent-sandbox.sh` |
| Provider runtime notes | `docs/provider-runtime.md` |
| Daily prompts | `docs/daily-prompts.md` |
| AI product building with agents | `docs/ai-product-building.md` |
| TDD with agents | `docs/tdd-with-agents.md` |
| Retrieval policy | `docs/retrieval-policy.md` |
| Source citation workflow | `workflow/source-citation.md` |
| Memory consolidation workflow | `workflow/memory-consolidation.md` |
| Unified memory query | `scripts/memory-query.sh` |
| 12-Factor Agents principles map | `docs/12-factor-agents-integration.md` |
| A2H (Agent-to-Human) protocol | `drafts/a2h-spec.md` in [humanlayer/12-factor-agents](https://github.com/humanlayer/12-factor-agents) |
| Agent-to-Human contact tool | `scripts/a2h-contact.sh` |
| Error counter with escalation | `scripts/error-counter.sh` |
| Deterministic context pre-fetch | `scripts/prefetch-context.sh` |
| XML-style context retrieval | `scripts/retrieve-context.sh --xml` |
| 12-factor agent scaffold | `scripts/create-hl-agent.sh` |
| Learnings strategy (three-store system) | `docs/learnings-strategy.md` |
| Hub quickstart (full index) | `docs/hub-quickstart.md` |
| Cognitive surrender research and evidence | `research/cognitive-surrender-research.md` |
| System architecture research | `research/well-maintained-system-research.md` |
| Agent coding rules (common) | `rules/common/` (coding-style, security, git-workflow, testing) |
| Agent coding rules (language) | `rules/typescript/patterns.md`, `rules/python/patterns.md` |
| Structural governance | `docs/structural-governance.md` |
| TAP project memory | `.tap/README.md` (`tap-audit`, `systems-health`, `retrospective`, `curate-product-context`) |
| Superseded design docs | `archive/superseded/` (core-agent-doctrine, phase-based, etc.) |
| Bug memory | `buglog.json` in project root |
| Do-not-repeat | inline in `session-state.json` under `doNotRepeat` key |
