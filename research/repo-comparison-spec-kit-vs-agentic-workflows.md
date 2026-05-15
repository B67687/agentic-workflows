# Comparative Analysis: agentic-workflows vs github/spec-kit

**Status**: ESTABLISHED
**Goal**: Systematically compare both repos to identify high-impact improvements for agentic-workflows
**Method**: Source triangulation --- primary source analysis of both repos + ecosystem literature
**Date**: 2026-05-15

---

## 1. High-Level Comparison

| Dimension | agentic-workflows (ours) | github/spec-kit |
|-----------|--------------------------|-----------------|
| **Purpose** | Agent orchestration harness + systems engineering workspace | Spec-Driven Development toolkit for AI coding agents |
| **Age** | ~2+ years | ~9 months (Aug 2025) |
| **Scale** | 110 scripts, 46 skills, 14 commands, 42 docs | CLI (5.4K line Python), 30 integrations, 91 extensions |
| **Architecture** | Distributed scripts + phase gates + skill system | Monolithic CLI + template hierarchy + integration registry |
| **Primary user** | Agent orchestrators & systems engineers | AI coding agent users (any agent) |
| **License** | MIT | MIT |
| **Language** | Bash (80%) + Python (15%) + Markdown (5%) | Python (92.8%) + Shell (3.8%) + PowerShell (3.4%) |

---

## 2. Detailed Dimension-by-Dimension Comparison

### 2.1 Workflow & Pipeline

| Aspect | Ours | Spec Kit | Assessment |
|--------|------|----------|------------|
| Pipeline definition | `docs/workflow.md` --- descriptive pipeline shape | `spec-driven.md` + templates --- prescriptive, executable pipeline | Spec Kit's pipeline IS the tool; ours is described but agent-discretionary |
| Phase enforcement | `phase-gate.sh` --- executable blockers per phase | Constitution Check in plan-template.md --- template checkboxes | Our gates are actually executable (stronger); theirs are template-embedded (more discoverable) |
| Phase artifacts | Research note -> plan -> implementation | spec.md -> plan.md -> tasks.md -> code | Spec Kit has richer artifact set (research.md, data-model.md, contracts/, quickstart.md) |
| Task decomposition | Manual via `/task` + `task-slice.sh` + `task-intake.sh` | `/speckit.tasks` --- AI-driven decomposition from plan artifacts | **Gap**: Ours has better intake/slicing but no automated spec->task pipeline |
| Verification | Separate `/verify` step, `quality-speed-gate.sh` | Built into templates (checklists, constitution gates) | Ours is more thorough but less integrated |

### 2.2 Governance & Quality

| Aspect | Ours | Spec Kit | Assessment |
|--------|------|----------|------------|
| Phase gates | `phase-gate.sh` --- boolean state checks + quality checks | Constitution Check in plan-template.md --- Phase -1 gates | **Both strong**, different approaches |
| Constitution | No single constitution document | `constitution.md` with 9 articles + amendment process | **GAP**: We have governance rules scattered across files but no unified constitution |
| Test enforcement | Advisory (WARN on quality-gate) | Article III: NON-NEGOTIABLE test-first | **GAP**: Ours is advisory; theirs is enforceable |
| Simplicity gates | Simplicity criterion in AGENTS.md, quality gate | Simplicity Gate (Art VII), Anti-Abstraction Gate (Art VIII) | Spec Kit has explicit gates; ours is a general rule |
| Pre-commit checks | `quality-gate.sh` --- shellcheck, secrets, non-ASCII, TODO | No equivalent (just markdownlint) | **We lead** --- executable pre-commit quality enforcement |
| Error handling | `error-counter.sh`, `log-error.sh`, escalation, classification (C/S/E) | None | **We lead significantly** |
| Post-mortem | `task-retrospect.sh`, `triple-debt.sh` | None | **We lead** |

### 2.3 Cognitive Safety

| Aspect | Ours | Spec Kit | Assessment |
|--------|------|----------|------------|
| Adversarial planning | CATFISH protocol (`plan-challenge.sh`, `plan-guard.sh --challenge`) | None | **We lead** --- this is unique |
| Comprehension enforcement | `comprehension-gate.sh` --- enforced participation before implement | None | **We lead** --- Recognition model implementation |
| Decision audit trail | `decision.sh` --- DCI packet (option + objections + reopen) | None | **We lead** |
| Assumption expiry | `assumption-expiry.sh` --- TTL-based stale claim detection | None | **We lead** |
| Cognitive surrender mitigation | Full research-backed system (recognition, CATFISH, debt tracking, calibration checks) | None | **We lead significantly** --- this is our most distinctive advantage |

### 2.4 Memory & Context

| Aspect | Ours | Spec Kit | Assessment |
|--------|------|----------|------------|
| Memory system | 3-store (learnings.jsonl + agentmemory + ruflo) | Single `constitution.md` | **We lead** --- multi-store architecture |
| Session state | `session-state.json` --- structured session tracking | None | **We lead** |
| Context pressure monitoring | `context-pressure.sh` | None | **We lead** |
| Prefetch/retrieve | `prefetch-context.sh`, `retrieve-context.sh` | None | **We lead** |

### 2.5 Skills & Knowledge

| Aspect | Ours | Spec Kit | Assessment |
|--------|------|----------|------------|
| Skill system | 46 skills, L1/L2/L3 progressive loading, skill registry | Extensions (91) + Presets (18) --- different model | Different approaches; ours is deeper per-skill, theirs is broader per-extension |
| Skill loading | `skill-toolset.sh list/load/resource/find` | Extension/preset install via CLI | Different: ours is context-efficiency focused, theirs is feature-addition focused |
| Template system | Flat templates in skills/ + commands/ | Priority-resolved hierarchy (overrides > presets > extensions > core) | **GAP**: Their template system is significantly more sophisticated |
| Cross-agent support | OpenCode + manual Claude/Cursor/Codex support | 30+ formal integrations with registry | **GAP**: Their integration model is more systematic |

### 2.6 Research

| Aspect | Ours | Spec Kit | Assessment |
|--------|------|----------|------------|
| Research methodology | 6-phase framework with source triangulation, confidence levels, authority weighting | Lightweight research notes (research.md) | **We lead** --- significantly more rigorous |
| Research sufficiency | `research-sufficiency.sh` --- 7 red flag checks | None | **We lead** |
| Web research | `websearch` tool | `research.md` generated by agent | Comparable |

### 2.7 Agent Architecture

| Aspect | Ours | Spec Kit | Assessment |
|--------|------|----------|------------|
| Multi-agent | `agent-dispatch.sh`, `pipeline-run.sh`, worktree isolation, subagent patterns | Single-agent sequential by default | **We lead** |
| Agent coordination | 6 patterns (fan-out, thin-result, preflight-execute, fail-escalate, coordinator/specialist/verifier, spec-driven decomposition) | Sequential command pipeline | **We lead significantly** |
| Worktree isolation | `session-fork.sh`, `git-worktree-branch.sh` | Branch per feature | We lead with actual worktree support |

---

## 3. What We Do Better (Preserve & Double Down)

These are areas where we should NOT follow spec-kit --- we're ahead:

### 3.1 Cognitive Safety System
This is our most distinctive advantage. Spec-kit has no equivalent of:
- **CATFISH** --- counterfactual adversarial planning with fresh-context subagent dissent
- **Comprehension Gate** --- enforced participation before acting (Recognition model)
- **Triple Debt** --- tracking technical + cognitive + intent debt at task boundaries
- **Decision scaffold** --- DCI packet with residual objections and reopen conditions
- **Assumption expiry** --- TTL-based re-evaluation of non-verifiable claims
- **Calibration checks** --- expectation construction + "can I reconstruct this reasoning?"

**Recommendation**: Maintain and deepen. Consider integrating these checks into a unified constitution.

### 3.2 Error Recovery & Post-Failure Analysis
- `error-counter.sh` with escalate + classify (C/S/E failure types)
- `log-error.sh` pipeable capture
- `task-retrospect.sh` learning capture
- Buglog

**Recommendation**: Spec-kit has nothing here. Keep and extend.

### 3.3 Multi-Agent Orchestration
- `agent-dispatch.sh`, `pipeline-run.sh`, subagent patterns with fresh context
- Worktree isolation
- Coordinator/specialist/verifier roles

**Recommendation**: Spec-kit is single-agent by design. Our multi-agent capability is an architectural advantage. Keep.

### 3.4 Research Rigor
- 6-phase methodology with source triangulation
- Confidence levels (SPECULATIVE -> ESTABLISHED)
- Research sufficiency checks (7 red flags)
- Authority weighting and cited sources

**Recommendation**: Spec-kit's research is lightweight. Ours is more thorough. Keep and make more discoverable.

### 3.5 Memory Architecture
- Three distinct stores with different roles and availability
- Cross-store query
- One-way sync from durable to semantic

**Recommendation**: Keep. Consider adding constitution.md as a fourth store.

---

## 4. What Spec Kit Does Better (Adopt & Adapt)

### 4.1 Constitution Pattern | HIGH IMPACT, MEDIUM EFFORT

**What they have**: A `constitution.md` with 9 immutable articles, amendment process, and Phase -1 gates in plan templates that enforce constitution compliance (Simplicity, Anti-Abstraction, Integration-First).

**What we have**: Governance rules scattered across AGENTS.md, workflow.md, phase-gate.sh, quality-gate.sh. No single authoritative principles document.

**Why it matters**: Without a constitution, every decision starts from scratch. The constitution encodes accumulated wisdom as enforceable gates --- making the system self-governing rather than relying on the agent to remember 50+ rules.

**Implementation sketch:**
```
scripts/constitution.sh          # init | check | amend | gate
templates/constitution-template.md  # Article template
```

**Integration**: `phase-gate.sh` gets `--constitution <article>` flag that checks compliance before proceed. Quality gate checks constitution validity at commit time.

**Articles to encode** (from our existing rules):
1. **Macro-to-Micro** (understand system before code)
2. **Verify Aggressively** (verification is the quality engine)
3. **Checkpoint Discipline** (commit after every verified phase)
4. **CATFISH First** (adversarial planning dissent before implement)
5. **Comprehension Gate** (enforced participation before action)
6. **Simplicity Criterion** (simpler is better; document complexity cost)
7. **Error Escalate** (3 consecutive failures -> escalate)
8. **Phase Gate** (don't skip phases)
9. **Recognition** (construct expectation before generation)

### 4.2 Template Priority Resolution | HIGH IMPACT, HIGH EFFORT

**What they have**: Templates resolved at runtime with priority: **project-overrides > presets > extensions > core**. First match wins. Any template can be overridden without forking.

**What we have**: Flat template files in skills/ and commands/. No override mechanism. Customization requires editing the original files.

**Why it matters**: This is the most architecturally significant pattern in spec-kit. It enables:
- Teams to customize without forking (presets)
- Third-party additions without touching core (extensions)
- Per-project overrides for one-off adjustments
- Clean separation of concerns

**Implementation sketch:**
```
templates/
├── core/           # Our baseline templates (current files moved here)
├── extensions/     # Community additions (discovery from registry)
├── presets/        # Configuration bundles
└── overrides/      # Per-project local overrides

scripts/template-resolve.sh <name>   # Resolve template path from stack
scripts/template-list.sh             # List available templates by priority
```

**Integration**: `skill-toolset.sh` uses template-resolve.sh for skill loading. Commands reference resolved templates. Phase gates check for overrides.

### 4.3 Structured Ambiguity Tracking | MEDIUM-HIGH IMPACT, LOW EFFORT

**What they have**: `[NEEDS CLARIFICATION: specific question]` markers that LLMs must use instead of guessing. The spec template explicitly requires marking ambiguities.

**What we have**: `[INTELLIGENCE]` tags but no structured format for WHAT needs clarification or WHY.

**Why it matters**: The #1 LLM failure mode is confident-sounding incorrect assumptions. Forcing explicit ambiguity markers directly addresses this --- the LLM must tag what it doesn't know instead of fabricating.

**Implementation sketch:**
```
Define format: [NEEDS CLARIFICATION: question about X]
```

**Integration**: Add to `phase-gate.sh --check-ambiguity` that scans plan.md and spec.md for unresolved `[NEEDS CLARIFICATION]` markers. Block implement phase if any remain. Update spec template to require markers.

### 4.4 Spec-to-Task Decomposition | HIGH IMPACT, MEDIUM EFFORT

**What they have**: `/speckit.tasks` command that reads plan.md + data-model.md + contracts/ + research.md and auto-generates tasks.md with:
- User story -> task mapping
- `[P]` parallel execution markers
- File path specifications per task
- TDD structure (tests before code)
- Checkpoint validation between user stories

**What we have**: Manual `/task` command that relies on agent discretion. `task-slice.sh` for sizing, but no automated decomposition from plan artifacts.

**Why it matters**: The gap between "I have a plan" and "I have a sequence of implementable tasks" is where execution quality degrades. Automated decomposition with structure ensures every task has verification, file paths, and dependency ordering.

**Implementation sketch:**
```
scripts/task-decompose.sh           # Reads plan.md + artifacts -> tasks.md
templates/core/tasks-template.md    # Improved task template with [P] markers
```

**Template structure** (from spec-kit, adapted):
```markdown
### User Story N - [Title]
- [ ] [P] Task: [description]
  - Files: [paths]
  - Verify: [command/manual check]
  - Depends on: [task IDs]

### Checkpoint N
- Verify [specific capability] works independently
```

### 4.5 Cross-Agent Integration Layer | MEDIUM IMPACT, MEDIUM EFFORT

**What they have**: Formal integration registry with 30+ agents. Each agent is a self-contained subpackage with a base class, config, and context file. Commands auto-format to each agent's expected format (`.md`, `.toml`, `.yaml`, `SKILL.md`).

**What we have**: OpenCode-first with `sync-commands.sh` that also writes to `.pi/prompts/`. Manual CLAUDE.md support. Loose support for Cursor/Codex.

**Why it matters**: Not about supporting 30 agents --- it's about having a clean model so adding a new agent doesn't require manual setup.

**Implementation sketch:**
```
scripts/agent-registry.sh          # list | register | inspect
```
Define manifest format for agent properties (name, commands dir, context file, format).

---

## 5. Priority Ranking & Implementation Order

| Rank | Improvement | Impact | Effort | Risk | Dependencies |
|------|-------------|--------|--------|------|-------------|
| **1** | **Constitution system** | High | Medium | Low | None (greenfield) |
| **2** | **Structured ambiguity tracking** | Medium-High | Low | Low | None (additive) |
| **3** | **Spec-to-task decomposition** | High | Medium | Low-Medium | Requires structured plan format |
| **4** | **Template priority resolution** | High | High | Medium | Requires restructuring existing templates |
| **5** | **Cross-agent integration** | Medium | Medium | Low | Depends on template system |

### Recommended Sequencing

**Phase 1 (this session or next session fork):**
1. Constitution system (scripts/constitution.sh + template + phase-gate integration)
2. Structured ambiguity tracking ([NEEDS CLARIFICATION] format + gate check)

**Phase 2 (next session fork):**
3. Spec-to-task decomposition (task-decompose.sh + improved task template)
4. Add constitution gates to plan/implement templates

**Phase 3 (future session):**
5. Template priority resolution (templates/core/ + template-resolve.sh)
6. Cross-agent integration (agent-registry.sh)

---

## 6. What NOT to Copy from Spec Kit

| Spec Kit Feature | Why Not |
|-----------------|---------|
| Monolithic Python CLI (5.4K line __init__.py) | Our distributed Bash script architecture is more maintainable and testable |
| Single-agent sequential workflow | Our multi-agent dispatch with worktree isolation is more advanced |
| Template-checkbox gates (Phase -1) | Our executable phase-gate.sh that actually blocks is stronger |
| No cognitive safety | We lead here --- this is our distinctive advantage |
| Agent-specific command formats (TOML/YAML) | Unnecessary complexity for our use case; Markdown commands work universally |
| Extension/preset marketplace | Premature for our scale; focus on core system first |
| Spec-as-source (Level 3) | Aspirational and unproven in practice |

---

## 7. Key Strategic Insight

**Our repo and spec-kit are solving different problems that happen to overlap at the workflow level.**

Spec-kit solves: *"How do I get an AI agent to produce better code by constraining it with structured specifications?"*

We solve: *"How do I build a resilient, self-improving agent orchestration system that maintains quality across sessions, agents, and tasks?"*

Spec-kit's template system and constitution are directly applicable to us. Their lack of cognitive safety, error recovery, multi-agent dispatch, and research rigor are where we lead.

**The integration opportunity**: Use spec-kit's template priority resolution and constitution patterns to make our governance system more structured, while keeping our cognitive safety, multi-agent, and error recovery systems that spec-kit lacks entirely.

---

## 8. Recommended Architecture Evolution

```
Current:                    Target:
─────────                   ────────
commands/*.md (flat)        templates/core/ command templates
skills/*/SKILL.md (flat)    templates/core/ skill templates
AGENTS.md (rules)           constitution.md (enforceable articles)
phase-gate.sh (state only)  phase-gate.sh (state + constitution + ambiguity)
/tasks (manual)             task-decompose.sh (automated from plan artifacts)
sync-commands.sh            template-resolve.sh + agent-registry.sh
spec-driven skill (advisory) constitution.md Art I-V with gates
```

---

## 9. Sources

- Primary: `github.com/github/spec-kit` (full repo analysis --- README, spec-driven.md, DEVELOPMENT.md, AGENTS.md, templates/, source)
- Primary: Our repo (workflow.md, commands/, skills/, scripts/, AGENTS.md, session-state.json)
- Ecosystem: arXiv 2602.00180, augmentcode.com (tooling comparison), rushis.com (SDD deep dive), zylos.ai (Q1 2026 landscape), delbion.com (SDD platform comparison)
