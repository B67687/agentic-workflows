# Starred Repos Phase 2 Analysis — 2026-04-22

**Top 10 medium scans + integration recommendations**

---

## What Each Top Candidate Does

### 1. get-shit-done (56k stars)
**What:** Context engineering + spec-driven dev system for Claude Code (and 15+ other harnesses)

**Core mechanisms:**
- **Wave execution**: Plans grouped into waves, parallel within waves, sequential across. "Vertical slices" parallelize better than "horizontal layers"
- **Fresh 200k context per plan**: Each plan executes in a fresh subagent context — zero context garbage accumulation
- **XML-structured plans**: `<task><name><files><action><verify><done>` — precise instructions with built-in verification
- **Multi-phase workflow**: discuss → plan → execute → verify → ship — each phase feeds the next
- **Quality gates**: Schema drift detection, security enforcement, scope reduction detection
- **Spiking & sketching**: Throwaway experiments before committing to a plan direction
- **Context rotation**: `.planning/` files (PROJECT.md, REQUIREMENTS.md, ROADMAP.md, STATE.md) keep project context while rotating session context

**Token efficiency angle:** Fresh subagent contexts = never accumulated garbage. Multi-agent orchestration keeps main context at 30-40%.

**Best for:** Solo builders who want structured methodology without enterprise overhead

---

### 2. everything-claude-code (163k stars)
**What:** Complete agent harness optimization system — 38 agents, 156 skills, cross-harness (Claude Code, Codex, Cursor, OpenCode, Gemini)

**Core mechanisms:**
- **AgentShield**: Security auditor — 1282 tests, 102 rules, adversarial red-team/blue-team/auditor pipeline
- **Continuous learning v2**: Instinct-based learning — confidence-scored patterns extracted from sessions, auto-evolve into skills
- **Hook runtime controls**: `ECC_HOOK_PROFILE=minimal|standard|strict` + `ECC_DISABLED_HOOKS=...` for runtime gate tuning
- **Token optimization**: Model profiles (quality/balanced/budget), context management, size-budget enforcement
- **Git worktree isolation**: Parallel execution in isolated directories
- **Multi-agent orchestration**: `/multi-plan`, `/multi-execute`, `/multi-backend`, `/multi-frontend`
- **Skill stocktake**: Audit skills/commands for quality

**Token efficiency angle:** Instinct compression (learned patterns = smaller than raw session dumps), hook-based memory persistence

**Best for:** Power users who want every harness optimization available

---

### 3. gstack (79k stars)
**What:** Garry Tan's virtual engineering team — 23 specialists as slash commands for Claude Code

**Core mechanisms:**
- **Role-based workflow**: `/office-hours` (YC-style interrogation) → `/plan-ceo-review` → `/plan-eng-review` → `/design-review` → `/review` → `/qa` → `/ship`
- **Team sprint structure**: Think → Plan → Build → Review → Test → Ship → Reflect, each skill feeds the next
- **Parallel sprints via Conductor**: 10-15 parallel Claude Code sessions, each in isolated workspace
- **Browser with sidebar agent**: GStack Browser — Claude controls Chromium with anti-bot stealth, prompt injection defense (22MB ML classifier + canary tokens)
- **Multi-agent second opinion**: `/codex` — independent Codex review alongside Claude review
- **Cross-model routing**: Sonnet for fast actions, Opus for analysis, cost tracking per model
- **Design shotgun → HTML pipeline**: `/design-shotgun` (4-6 AI mockup variants) → `/design-html` (production HTML via Pretext)

**Token efficiency angle:** Quality-gated workflow reduces rework. Smaller PRs (p50 = 118 lines), squash merges, atomic commits per task.

**Best for:** Founders/operators who want a complete team without managing people

---

### 4. caveman (42k stars)
**What:** Token-compressing Claude skill — 65-75% output token reduction by removing filler

**Core mechanisms:**
- **Intensity levels**: Lite (drop filler) / Full (articles gone, fragments OK) / Ultra (telegraphic) / 文言文 (classical Chinese)
- **caveman-commit**: Terse commit messages, ≤50 char subject, why over what
- **caveman-review**: One-line PR comments — `L42: 🔴 bug: user null. Add guard.`
- **caveman-compress**: Compress CLAUDE.md and memory files so Claude reads fewer tokens (~46% average)
- **Self-validation**: Benchmarks on real API calls show 22-87% token savings across task types
- **Research backing**: Cites arxiv paper "Brevity Constraints Reverse Performance Hierarchies" — verbose not always better

**Token efficiency angle:** 65-75% output token reduction, 46% input compression for memory files. Scientific backing.

**Best for:** Anyone who wants faster, cheaper, more readable AI output

---

### 5. learn-claude-code (55k stars)
**What:** Harness engineering education — "Bash is all you need" — teaches how to build agent harnesses from first principles

**Core mechanisms:**
- **12 progressive sessions**: s01 (agent loop) → s12 (worktree isolation), each adds one mechanism
- **Mental-model-first**: Problem → solution → ASCII diagram → minimal code
- **Core pattern**: while loop + stop_reason → execute tools → append results
- **Harness = tools + knowledge + observation + action + permissions**
- **Session isolation via subagents**: Fresh `messages[]` per subagent = context never bleeds
- **Sister repos**: claw0 (proactive always-on harness with heartbeat/cron/IM), Kode CLI (production harness)

**Key teaching:** "Agency comes from the model. The harness makes agency real. Build great harnesses. The model will do the rest."

**Best for:** Understanding WHY agent systems work, not just HOW to configure them

---

### 6. hermes-agent (107k stars)
**What:** Nous Research's self-improving agent — creates skills from experience, persists memory, multi-platform messaging

**Core mechanisms:**
- **Self-improving loop**: Creates skills from complex tasks, skills self-improve during use
- **Memory persistence**: FTS5 session search with LLM summarization — cross-session recall
- **Model-agnostic**: OpenRouter (200+ models), NVIDIA NIM, Xiaomi MiMo, GLM, Kimi, MiniMax, HuggingFace, OpenAI, any endpoint
- **6 terminal backends**: Local, Docker, SSH, Daytona, Singularity, Modal (serverless hibernate)
- **Messaging gateway**: Telegram, Discord, Slack, WhatsApp, Signal, Email — all from one gateway
- **Cron scheduling**: Natural language scheduled tasks, delivery to any platform
- **Honcho dialectic user modeling**: User profile persistence across sessions
- **Skills system + Skills Hub**: Procedural memory, compatible with agentskills.io standard

**Token efficiency angle:** Learned skills = compressed knowledge. FTS5 search means less re-explanation per session.

**Best for:** Anyone who wants persistent memory and self-improvement across sessions

---

### 7. claude-code-best-practice (47k stars)
**What:** Comprehensive Claude Code patterns from community + team (Boris Cherny, Thariq, etc.)

**Core mechanisms:**
- **10 development workflows** compared in table: everything-claude-code, superpowers, spec-kit, gstack, get-shit-done, BMAD-METHOD, OpenSpec, oh-my-claude-code, compound-engineering, humanlayer
- **82 tips/tricks** organized: prompting, planning, context, session, CLAUDE.md, agents, commands, skills, hooks, workflows, git/PR, debugging, utilities, daily
- **Context rot rule**: 300-400k tokens on 1M model — "dumb zone" at 40% context
- **Subagent pattern**: "will I need this tool output again, or just the conclusion?" — 20 file reads + 12 greps + 3 dead ends stay in child's context
- **Karpathy's 4 failure modes**: Wrong assumptions, overcomplexity, orthogonal edits, imperative over declarative — covered by every major workflow

**Best for:** Fast pattern lookup — what does the community actually use?

---

### 8. agency-agents (85k stars)
**What:** 144 specialized agents across 12 divisions — each with personality, processes, and deliverables

**Core mechanisms:**
- **12 divisions**: Engineering, Design, Paid Media, Sales, Marketing, Product, Project Management, Testing, Support, Spatial Computing, Specialized, Finance, Game Development, Academic
- **Personality-driven**: Each agent has unique voice, not generic prompt templates
- **Deliverable-focused**: Concrete outputs, measurable outcomes
- **Multi-tool**: Claude Code, GitHub Copilot, Antigravity, Gemini CLI, OpenCode, OpenClaw, Cursor, Aider, Windsurf, Kimi Code
- **Division examples**: Engineering (Frontend, Backend, AI Engineer, DevOps, Security, SRE...), Sales (Outbound, Discovery, Deal Strategist, SE, Proposal...), Marketing (Growth Hacker, Content, SEO, Reddit, China ecosystems...)

**Best for:** Understanding domain-specific agent specializations taxonomy

---

### 9. OpenMythos (5.8k stars)
**What:** Theoretical reconstruction of Claude Mythos architecture — Recurrent-Depth Transformer (RDT)

**Core mechanisms:**
- **3-stage architecture**: Prelude (standard transformer) → Recurrent Block (looped T times) → Coda (standard transformer)
- **Recurrence rule**: `h_{t+1} = A·h_t + B·e + Transformer(h_t, e)` — input injection prevents drift
- **MoE suspected**: Fine-grained experts + shared experts for breadth across domains
- **Stability fix**: LTI-constrained injection (spectral radius < 1) = guaranteed convergence
- **Loop index embedding**: Suspected RoPE-like positional signal per iteration
- **ACT halting**: Adaptive Computation Time for when to stop looping
- **Overthinking problem**: More loops ≠ better past convergence point

**Why it matters:** Explains WHY Claude Mythos feels qualitatively different — depth (looping) not just breadth (parameters)

**Best for:** Understanding the architecture behind Claude Opus 4.7 and Mythos

---

### 10. MetaGPT (67k stars)
*(README not fetched — already well-known multi-agent framework)*

**Core mechanisms (from earlier research):**
- **Software company simulation**: PM, architect, engineer roles with SOPs
- **Message-passing between agents**: Structured communication with role-specific constraints
- **Self-collaboration**: Multi-agent review before producing output

---

## Cross-Cutting Pattern Analysis

### Pattern 1: Context Rotation vs Context Accumulation

| Repo | Approach |
|------|----------|
| get-shit-done | Fresh 200k subagent per plan |
| learn-claude-code | Fresh messages[] per subagent |
| hermes-agent | Skill-based compression + FTS5 search |
| caveman | Output compression |
| gstack | Quality gates reduce rework |

**Insight:** The battle between context accumulation (rot) and context preservation (memory) is the central engineering problem. Three solutions: rotation (fresh contexts), compression (keep essentials), or search (retrieve on demand).

### Pattern 2: Multi-Agent Orchestration

| Repo | Approach |
|------|----------|
| gstack | Role-based team, Conductor for parallel sprints |
| get-shit-done | Wave execution, parallel within waves |
| agency-agents | 144 agents across 12 divisions |
| MetaGPT | Role-SOP with message passing |

**Insight:** "Team" pattern is appearing everywhere — different implementations of the same idea: specialized agents that coordinate.

### Pattern 3: Token Efficiency Is Not One Thing

| Technique | Repo |
|----------|------|
| Output compression (speak less) | caveman |
| Input compression (read less) | caveman-compress |
| Context rotation (fresh windows) | get-shit-done |
| Learned skill compression | hermes-agent, everything-claude-code |
| Quality gates (reduce rework) | gstack, get-shit-done |

**Insight:** Token efficiency is multi-dimensional. Best results combine multiple techniques.

### Pattern 4: Agent Specialization Spectrum

| Level | Example |
|-------|---------|
| Generic | baseline Claude Code |
| Role-based | gstack (23 specialists) |
| Domain-specific | agency-agents (144 agents, 12 divisions) |
| Team simulation | MetaGPT (PM + architect + engineer) |

**Insight:** The more specialized the agent, the better the output — but more agents means more context management overhead.

---

## Phase 3 Integration Recommendations

### For ai-product-building.md

| Finding | Integration |
|---------|-----------|
| Wave execution (get-shit-done) | Add to workflow patterns: parallel waves > sequential phases |
| Gstack's 23 specialist roles | Add "virtual team" pattern to agent workflows |
| hermes-agent self-improvement | Add "agent that learns from experience" pattern |
| Multi-agent coordination (MetaGPT, gstack) | Expand multi-agent section |
| Conductor for parallel sprints (gstack) | Add parallel sprint pattern |

### For core-agent-doctrine.md

| Finding | Integration |
|---------|-----------|
| get-shit-done's discuss → plan → execute → verify → ship | Add phase workflow |
| Quality gates in gstack + GSD | Add verification checkpoints |
| Self-improvement in hermes-agent | Add to "Update memory after lessons" |

### For token-efficient-prompting.md

| Finding | Integration |
|---------|-----------|
| caveman 65-75% output reduction | Add to compression techniques |
| caveman-compress 46% input reduction | Add for CLAUDE.md/memory files |
| Context rotation (get-shit-done, learn-claude-code) | Add "fresh context per task" pattern |
| Instinct scoring (everything-claude-code) | Add memory compression via learned patterns |

### For prompt-templates.md

| Finding | Integration |
|---------|-----------|
| caveman intensity levels | Add terse communication template |
| gstack's `/office-hours` interrogative process | Add product interrogation prompt pattern |

### For daily-prompts.md

| Finding | Integration |
|---------|-----------|
| claude-code-best-practice context rot rule | Add context monitoring checkpoint |
| Subagent pattern (learn-claude-code) | Add when to use subagents |

---

## High-Priority Deep Dives for Future Sessions

1. **hermes-agent self-improvement mechanism** — How exactly does skill creation from experience work? Can it be replicated in other harnesses?

2. **gstack's Conductor + parallel sprints** — Running 10-15 Claude Code sessions simultaneously. What does orchestration look like at that scale?

3. **caveman-compress algorithm** — How does it compress prose while preserving code/URLs/paths?

4. **everything-claude-code instinct evolution** — How does confidence scoring work? How does learned content decay?

5. **get-shit-done wave execution** — How does the orchestrator group plans into waves? What's the dependency detection algorithm?

---

*Phase 2 source data: READMEs fetched from GitHub for top 10 candidates*
*Phase 1 data: `archive/starred-repos-2026-04-22.md`*