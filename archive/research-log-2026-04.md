# Research Log

Daily research findings in AI agent engineering, token efficiency, and trending repos.

## Format

Each entry follows:
```
## YYYY-MM-DD

### Trending Repos
- [repo]: [stars] — [1-line why it matters]

### Revolutionary Finds
- [tool]: [what it does] — [adoption potential]

### Token Efficiency
- [technique/tool]: [compression claim] — [source]

### Notes
- [pattern or lesson worth remembering]
```

## Retention

- Keep last 30 days here
- Archive significant finds to `archived-findings.md`

---

<!-- Entries go below. Oldest first. -->

## 2026-04-22 (Starred Repos Research)

**Research Focus**: Phase 1 (all 238), Phase 2 (top 10), Phase 3 (integration)

### What Was Found

**Cluster analysis of 238 starred repos:**
- AI Agents / Coding Tools: ~45 repos (openclaw 362k, hermes-agent 107k, everything-claude-code 163k, gstack 79k, etc.)
- Learning / CS Education: ~35 repos (build-your-own-x 492k, system-design-primer 344k, free-programming-books 386k, hello-algo 126k, etc.)
- Windows Utilities: ~15 repos (PowerToys 132k, winutil 52k, Flow.Launcher 14k)
- Android Modding / Apps: ~20 repos (revanced-manager 27k, LibreTube 12k, InnerTune 5.9k)
- Own repos: 5 found (MathLearningNotes 1★, CS50p-2022 1★, H2-Computing 1★, BEPb 3139★, Password-Generator 1★)

### Top 10 Deep Dives

| Repo | Stars | Key Pattern |
|------|-------|-------------|
| **get-shit-done** | 56k | Wave execution, fresh 200k context per plan, context rotation |
| **everything-claude-code** | 163k | Instinct scoring, AgentShield security, cross-harness |
| **gstack** | 79k | 23 specialist roles, parallel sprints via Conductor |
| **caveman** | 42k | 65-75% token reduction through terse output |
| **learn-claude-code** | 55k | Harness engineering education, 12 sessions |
| **hermes-agent** | 107k | Self-improving skills, FTS5 memory, model-agnostic |
| **claude-code-best-practice** | 47k | 82 tips, 10 workflows compared |
| **agency-agents** | 85k | 144 agents across 12 divisions |
| **OpenMythos** | 5.8k | Recurrent-Depth Transformer theory |
| **MetaGPT** | 67k | Role-SOP multi-agent software company |

### Key Pattern Findings

1. **Context Rotation vs Accumulation** — Three solutions: rotation (fresh contexts), compression (caveman, instincts), search (FTS5)
2. **Multi-Agent Teams** — gstack (roles), agency-agents (divisions), MetaGPT (SOPs) — different implementations of specialization
3. **Token Efficiency Is Multi-Dimensional** — output compression, input compression, context rotation, learned skill compression
4. **Self-Improvement** — hermes-agent creates skills from experience, everything-claude-code evolves instincts
5. **Context is the Bottleneck** — Every major system addresses context management differently

### Integration (mapped to docs)

| Finding | Target Doc |
|---------|-----------|
| Wave execution, parallel sprints | ai-product-building.md |
| hermes-agent self-improvement loop | core-agent-doctrine.md |
| caveman token compression | token-efficient-prompting.md |
| context rotation patterns | token-efficient-prompting.md |
| discuss→plan→verify→ship workflow | core-agent-doctrine.md |

### High-Priority Future Deep Dives

1. hermes-agent skill creation mechanism
2. gstack Conductor parallel sprint orchestration
3. caveman-compress compression algorithm
4. everything-claude-code instinct evolution
5. get-shit-done wave dependency detection

### Sources

- gh api users/B67687/starred (238 total, 3 pages)
- README files from top 10 candidates

---

## 2026-04-21 (Session Recovery + Visualization + Context Awareness)

**Research Focus**: Visualization in AI explanations, proactive context handover, session recovery patterns

### Visualization in AI Explanations

Session 12 established *why* visualization works (Dual Coding Theory, Picture Superiority Effect). Session 16 research added *how to operationalize* it — AI generates actual `.excalidraw` JSON files.

**Three integration paths:**

| Approach | How it works | Token cost | Best for |
|----------|--------------|------------|----------|
| Excalidraw MCP Server | AI calls MCP tool → streams live diagram to `mcp.excalidraw.com` | Low | Interactive debugging, quick sketches |
| GitHub Copilot Excalidraw Skill | AI generates `.excalidraw` JSON file → user opens in Excalidraw | Medium-High | Complex architecture, flowcharts |
| Python Script Pipeline | AI creates base diagram → scripts add icons via CLI | Very Low | AWS/cloud with professional icons |

**Key finding**: The `.excalidraw` format is plain JSON. AI generates the structure with elements (rectangles, ellipses, diamonds, arrows, text). User opens at excalidraw.com or VS Code — fully editable.

**Complexity rule**: Keep diagrams under 15 elements. Break complex systems into high-level + detail layers.

Source: [selopo-ec/my-awesome-copilot Excalidraw skill](https://github.com/selopo-ec/my-awesome-copilot/blob/main/skills/excalidraw-diagram-generator/SKILL.md) (613 lines, MIT)

### Proactive Context Handover

**Core problem**: LLMs can't see their remaining token count. But they CAN recognize behavioral symptoms of context pressure.

**Pressure signals:**
- Output becoming generic or repetitive → recycling early context
- Re-explaining settled facts → can't retrieve efficiently
- Losing track of done/remaining → working memory exceeded
- Questions about already-covered material → context drift
- Output quality dropping → approaching hard limit

**The fix**: Add checkpoint trigger to system prompts. Model writes handover at natural break points when it detects 2+ pressure signals. Next model starts with clean summary instead of fighting through noise.

**Why it matters**: A session that hits context limit loses everything at the end. A proactive handover at 80% means the last 20% captures what matters.

See `docs/agent-context-handover.md` — "Proactive Context Handover" section.

### Session Recovery Pattern

When a session is interrupted by context limit:
1. Identify where work was left off (files modified, decisions made, direction chosen)
2. Write a handover before the next session using the template in `agent-context-handover.md`
3. Resume from handover, not from scratch

This is why session documentation matters — it becomes the recovery artifact.

### Integration Log

| Finding | Target | Status |
|---------|--------|--------|
| Excalidraw JSON workflow | `docs/prompt-templates.md` section 27 | Added |
| Proactive context checkpoint | `docs/agent-context-handover.md` | Added |
| Context pressure monitoring | `docs/token-efficient-prompting.md` | Added |

---

## 2026-04-19 (Daily Research Cycle)

**Research Focus**: Weekly trending repos, OpenRouter rankings, MCP ecosystem, BenchLM April 2026

### OpenRouter Weekly Rankings (Usage-Based)

| Rank | Model | Weekly Tokens | Change | Notes |
|------|-------|--------------|--------|-------|
| 1 | Claude Sonnet 4.6 | 1.37T | 21% | Usage leader |
| 2 | Claude Opus 4.6 | 1.32T | 17% | |
| 3 | Deepseek V3.2 | 1.28T | 4% | |
| 4 | Gemini 3 Flash | 1.11T | 6% | |
| 5 | MiniMax M2.5 | 1.09T | 0% | |
| 6 | **Mimo V2 Pro** | 1.07T | **140%** | New entry! |
| 7 | **MiniMax M2.7** | 1.03T | 6% | New entry |
| 8 | Gemini 3.1 Pro | 595B | 130% | |

**Analysis**: MiniMax M2.7 is gaining traction (1.03T tokens, 6% growth). Mimo V2 Pro is a dark horse with 140% growth.

### Top AI Apps on OpenRouter

| App | Tokens | What It Does |
|-----|--------|--------------|
| OpenClaw | 352B | Open-source agent for messaging apps |
| Hermes Agent | 246B | Self-improving, memory across sessions |
| Kilo Code | 207B | Coding agent (VS Code, JetBrains, CLI) |
| Claude Code | 116B | Anthropic's coding agent |

### MCP Ecosystem Update

**MCP Servers Repo**: 84k stars, 10.4k forks, 4,085 commits

**Reference Servers**: Everything, Fetch, Filesystem, Git, Memory, Sequential Thinking, Time

**New Frameworks**:
- FastMCP (TypeScript)
- MCP-Framework (TypeScript, CLI to create projects)
- Spring AI MCP (Java)
- MCP Plexus (Python, multi-tenant)
- Anubis MCP (Elixir)

**Registry/Management Tools**: MCPHub, MCP Router, Smithery, MCP marketplace

### BenchLM Coding Leaderboard (April 2026)

| Rank | Model | Weighted | SWE-bench Verified | SWE-bench Pro |
|------|-------|----------|-------------------|---------------|
| 1 | Claude Mythos Preview | 100% | 93.9% | 77.8% |
| 2 | Gemini 3.1 Pro | 95.4% | — | — |
| 3 | Claude Opus 4.7 | 92.6% | 87.6% | 64.3% |
| 4 | GPT-5.4 | 91% | — | 57.7% |
| 5 | Claude Opus 4.6 | 90.8% | 80.8% | 53.4% |
| 6 | **GPT-5.3 Codex** | 88.3% | ~85% | **56.8%** |

**Correction (2026-04-21):** The earlier open-weight interpretation was wrong. GPT-5.3 Codex is a closed OpenAI API model. Use GLM-5.1 for the open-weight coding lane.

### Cursor Marketplace Updates

**Featured Plugins**: Datadog, Slack, Figma, Linear (all MCP-based)

**Featured Automations**:
- Assign PR reviewers
- Summarize changes daily
- Find vulnerabilities (security scanning)
- Fix bugs reported in Slack

**New Automations**: Fix CI failures, Clean up feature flags, Triage Linear issues

### Analysis (Medium)

1. **MCP Ecosystem Matures**: 84k stars shows MCP is becoming standard. Frameworks now span TypeScript, Python, Java, Elixir — indicates production-ready.

2. **Coding Agent Wars**: OpenClaw (352B tokens) leads usage despite not being the highest benchmark. Self-improving memory (Hermes Agent) shows agents are learning to persist.

3. **Cursor Automations Signal Shift**: Security scanning + CI fixing + PR review automation = agents moving from "code generation" to "code stewardship."

### Integration Check

| Finding | Target | Priority |
|---------|--------|----------|
| Mimo V2 Pro (new model) | model-selection-guide.md | Medium |
| GPT-5.3 Codex closed/API correction | model-selection-guide.md | High |
| Cursor Automations (security focus) | ai-product-building.md | Medium |
| MCP ecosystem maturity | ai-product-building.md | Low (already covered) |

---

## 2026-04-18 (Manual Research)

**Research Focus**: User-provided URLs — system-design-primer, OWASP Top Ten, Cursor agent best practices

### System Design Primer (donnemartin/system-design-primer)

**What it is**: 343k stars — comprehensive system design learning resource

**Analysis**: Not directly an agent, but provides foundational knowledge for:
- CAP theorem, availability vs consistency patterns
- Load balancing, caching, database sharding
- System design interview prep with Anki flashcards

**Workspace Connection**: Adds depth to engineering knowledge. Could integrate into ai-product-building.md under "Architecture Fundamentals"

### OWASP Top Ten (owasp.org/www-project-top-ten/)

**What it is**: Standard awareness document for web application security risks

**Analysis (Medium)**:
- 2025 version coming — data collection until July 2025
- Translates to AI agents: secure coding matters when agents generate code
- Key risks: A01 Broken Access Control, A02 Cryptographic Failures, etc.

**Workspace Connection**: Directly relevant to core-agent-doctrine.md Security-First Agent Design section

### Cursor Agent Best Practices (cursor.com/blog/agent-best-practices)

**What it is**: Lee Robinson's guide to coding with agents (Jan 2026)

**Key Patterns Extracted**:
1. **Start with Plans** — Shift+Tab to toggle Plan Mode, agent waits for approval before building
2. **Manage Context** — Let agent find files, start new conversation when losing focus
3. **Rules + Skills** — Static project context (`.cursor/rules/`) + dynamic capabilities (`SKILL.md`)
4. **Long-Running Loops** — Hooks that iterate until tests pass
5. **Parallel Agents** — Git worktrees for isolation, multi-model judging
6. **Debug Mode** — Evidence-based hypothesis testing
7. **TDD with Agents** — Write tests → confirm fail → write code → iterate
8. **Git Workflows** — Custom `/commands` for repeated workflows

**Deep Integration Worthy**: Yes — these patterns directly improve workspace guidance

**Target Doc**: ai-product-building.md (Agent Workflow Patterns), core-agent-doctrine.md (Prompt Engineering)

---

## 2026-04-17 (Trending Repos Research)

**Research Focus**: Trending GitHub repos in AI agents, memory systems, coding agents, token efficiency

### Trending Repos

| Repo | Stars | Category | What It Does |
|------|-------|----------|--------------|
| Dify | 138k | Agentic Workflow | Production low-code/no-code agent platform |
| AutoGPT | 183k | Agent Framework | OG autonomous agent framework |
| RAGFlow | 78.3k | RAG + Agent | RAG engine with agent capabilities |
| Deer-Flow | 62k | Multi-Agent | ByteDance's long-horizon agent harness |
| MemPalace | 47k | Memory System | Best-benchmarked open-source memory |
| awesome-claude-code | 39.1k | Coding Agent | Claude Code skills/hooks hub |
| get-shit-done | 53.9k | Meta-Prompting | Spec-driven dev with context engineering |
| n8n | 184k | Workflow | MCP-native workflow automation |
| Google ADK Python | 19k | Agent Framework | Google's official Python agent toolkit |
| Pydantic-AI | 16.4k | Agent Framework | Type-safe agent dev with Pydantic |
| AgentScope | 23.9k | Multi-Agent | Visual debugging multi-agent platform |
| MemOS | 8.4k | Memory OS | Cross-task memory operating system |
| OpenViking | 22.4k | Context DB | Filesystem paradigm for context/memory |
| crush | 23.1k | Coding Agent | TUI-first glamorous agentic coding |
| LMCache | 8k | KV Cache | Fastest KV cache with AMD support |
| PageIndex | 25.4k | RAG | Vectorless reasoning-based RAG |

### Revolutionary Finds

#### Deep Analysis Candidates

**1. PageIndex (25.4k stars)** — Vectorless RAG
- **What**: Challenges vector embedding orthodoxy; reasoning-based retrieval instead
- **Why it matters**: Vector embeddings are the dominant RAG paradigm; reasoning-based retrieval is a fundamental shift
- **Integration**: ai-product-building.md — new retrieval paradigm worth monitoring

**2. membrane (80 stars)** — Trust-Aware Memory
- **What**: Selective memory substrate with typed, revisable, decayable memory + competence learning
- **Why it matters**: Trust-aware retrieval addresses a real problem in agent memory systems
- **Integration**: ai-product-building.md or cognitive-identity.md for agent design principles

**3. get-shit-done (53.9k stars)** — Meta-Prompting Discipline
- **What**: Spec-driven development for Claude Code with explicit context engineering
- **Why it matters**: Codifies meta-prompting as a discipline; could influence core-agent-doctrine.md
- **Integration**: core-agent-doctrine.md or prompt-strategies.md

**4. MemPalace (47k stars)** — Best-Benchmarked Memory
- **What**: Explicit benchmarking focus for memory systems
- **Why it matters**: Memory evaluation is a gap in current agent frameworks; this sets a standard
- **Integration**: ai-product-building.md (agent components section)

**5. LMCache (8k stars)** — KV Cache Optimization
- **What**: Fastest KV cache with AMD/ROCm support
- **Why it matters**: Enables democratized inference; pure ROCm support is unique
- **Integration**: token-efficient-prompting.md (already has LLMLingua, TurboQuant)

### Medium Analysis

**Agent Workflow Platforms (Dify, n8n)**
- Both now MCP-native; significant for product building
- Dify: 138k stars, production-grade, bridges no-code to complex agents
- n8n: 184k stars, largest workflow automation now with AI/MCP
- **Integration**: ai-product-building.md trending tools section

**Google ADK Python (19k stars)**
- Google's official code-first Python toolkit
- Signals major tech company investment in agents
- **Integration**: ai-product-building.md (agent frameworks section)

**Deer-Flow (62k stars)**
- ByteDance's answer to complex multi-agent research/coding
- Sandboxes, memories, tools, skills, subagents
- **Integration**: ai-product-building.md (multi-agent section)

**Pydantic-AI (16.4k stars)**
- Type safety for agent development (brings software engineering best practices)
- **Integration**: ai-product-building.md (agent frameworks section)

**crush (23.1k stars)**
- TUI-first "glamorous agentic coding"
- Aesthetic focus for coding agents is new
- **Integration**: ai-product-building.md (coding agents section)

**OpenViking (22.4k stars)**
- Filesystem paradigm for context/memory/skills/resources
- **Integration**: ai-product-building.md (memory systems section)

### Integration Recommendations

| Repo | Stars | Deep Dive? | Target Doc |
|------|-------|------------|------------|
| Dify | 138k | Medium | ai-product-building.md |
| get-shit-done | 53.9k | **Medium** | core-agent-doctrine.md (meta-prompting) |
| PageIndex | 25.4k | **Medium** | ai-product-building.md (new paradigm) |
| MemPalace | 47k | Medium | ai-product-building.md |
| LMCache | 8k | Medium | token-efficient-prompting.md |
| Google ADK | 19k | Medium | ai-product-building.md |
| Pydantic-AI | 16.4k | Medium | ai-product-building.md |
| crush | 23.1k | Medium | ai-product-building.md |
| membrane | 80 | Watch | — |

### Notes

- **Trend**: Memory systems are getting explicit benchmarking (MemPalace) — maturity signal
- **Trend**: Type safety coming to agents (Pydantic-AI) — software engineering practices spreading
- **Trend**: Vectorless/ reasoning-based retrieval challenges dominant paradigm (PageIndex)
- **Trend**: Meta-prompting becoming discipline (get-shit-done) — context engineering codified
- **Watch**: membrane's trust-aware memory could influence how we think about agent reliability

## 2026-04-17 (Daily Research + Gap Analysis)

**Repos Researched**: everything-claude-code (158k stars, growing from 156k)

**Conceptual Research**: Individual cognitive identity gaps in existing doc

### Trending Repos
- [everything-claude-code](https://github.com/affaan-m/everything-claude-code): 158k stars (+2k) — Agent harness optimization, v1.10.0 released with dashboard GUI, operator workflows, ECC 2.0 alpha

### Revolutionary Finds

#### Medium Analysis
- **everything-claude-code v1.10.0**: Dashboard GUI, operator workflows, Rust ECC 2.0 alpha — cross-harness (Claude Code, Codex, Cursor, OpenCode, Gemini)

### Gap Analysis: cognitive-identity.md

Reviewed existing cognitive-identity.md for completeness. Identified 9 gaps:

| Gap | Description |
|-----|-------------|
| 1. Coding-specific | No "vibe coding" risks, maintaining coding skills |
| 2. Recovery path | No guidance if already in bad patterns |
| 3. Daily habits | Frameworks but no specific practices |
| 4. Team dimension | No team-level cognitive identity guidance |
| 5. Emotional/psychological | Anxiety, imposter syndrome from AI acceleration |
| 6. Concrete benchmarks | Vague metrics — need testable benchmarks |
| 7. Research system connection | Research system IS a cognitive practice |
| 8. "AI first" beginner trap | Beginners using AI from day 1 |
| 9. Practical prompts | This is a prompting workspace — needs prompts |

### Deep Analysis: Gap 1 - "Vibe Coding" Risk

**What it is**: Using AI to code without understanding, just "shipping vibes". The code works but you don't know why.

**Risks**:
- Can't debug when it breaks
- Can't verify correctness
- Can't extend or modify confidently
- Complete dependency on AI for any code task

**Connection to cognitive-identity.md**: The "illusion of knowledge" threat manifests directly in coding contexts.

### Integration Check

- **cognitive-identity.md**: Needs updates to address 9 gaps
- **research-prompt.md**: Research system connection should be documented as cognitive practice
- **ai-product-building.md**: "Vibe coding" risks relevant to product building

### Next Steps

- Update cognitive-identity.md with practical sections for each gap
- Add "vibe coding" as explicit risk
- Add recovery path section
- Add daily/weekly practice recommendations
- Add research system as cognitive practice

---

## 2026-04-16 (Manual Run - Cognitive Identity)

**Repos Researched**: None (conceptual research via Wikipedia, academic papers, and web sources)

**Concepts Researched**: Desirable difficulty, cognitive offloading, deskilling from AI, digital amnesia/Google effect, human agency, augmentation vs replacement, Parasuraman's Levels of Automation, Extended Mind Thesis, 4E cognition

### Deep Analysis

**Individual Cognitive Identity in the Age of AI**
- **What**: How humans maintain cognitive abilities, decision-making, and agency while AI tools become increasingly powerful
- **Why Deep**: Directly affects how this workspace's users should interact with AI agents — the gap between tool velocity (exponential) and human cognition (linear) widens monthly
- **Integration**: Enhanced existing cognitive-identity.md with research-backed evidence

### Key Research Findings

#### Desirable Difficulty (Bjork, 1994)
- Learning tasks requiring achievable effort produce stronger, more durable knowledge
- AI tools that eliminate struggle remove the mechanism that makes learning work
- Retrieval practice > passive re-reading; spacing > cramming; delayed feedback > immediate

#### Cognitive Offloading (Risko & Gilbert, 2016)
- Dual-edged: frees working memory but creates self-reinforcing dependency cycle
- Storm, Stone & Benjamin (2017): Using internet for one question increases tendency to use it for easier subsequent questions
- Illusion of knowledge: people overestimate what they know when they have search access (Fisher et al., 2015)

#### Deskilling Evidence
- Endoscopists: adenoma detection dropped 28.4% → 22.4% after AI-assisted detection (Poland, 2025)
- Surgeons: poorer outcomes when AI tool discontinued
- Pilots: Air France 447 — over-reliance on autopilot reduced manual capability
- Automation bias: favor automated suggestions even when wrong (Parasuraman & Riley, 1997)

#### Digital Amnesia / Google Effect (Sparrow et al., 2011)
- People remember where to find info better than the info itself
- London taxi drivers: structural hippocampal changes from navigation, GPS suppresses this plasticity
- fMRI shows decreased activation recalling internet-learned vs encyclopedia-learned info

#### Augmentation vs. Replacement
- Active coupling (augmentation): human thinks, AI processes, human decides
- Passive coupling (replacement): human requests, AI produces, human accepts
- The key question: "Does this make the human better at the task, or unnecessary for it?"

### Integration Check
- **Human cognition** → cognitive-identity.md (added research-backed evidence sections)
- **Product building** → Added "Product Design: Building AI That Amplifies" section
- **Workspace integration** → Connected to ai-product-building.md practices

## 2026-04-15 (Manual Run)

**Repos Researched**: MetaGPT, andrej-karpathy-skills, gstack, coconut, everything-claude-code

### Trending Repos
- [MetaGPT](https://github.com/FoundationAgents/MetaGPT): 67.1k stars — Multi-agent framework simulating a software company (PM, architect, PM, engineers)

### Revolutionary Finds

#### Medium Analysis (Listed, basic connection to workspace)
- [coconut](https://github.com/facebookresearch/coconut): 1.6k stars — Facebook Research on reasoning in latent space. More research than practical tool → skip

#### Deep Analysis (Full research + Integration)

**1. andrej-karpathy-skills** (36.3k stars)
- **What**: 4 principles from Andrej Karpathy's observations on LLM coding pitfalls
- **Why Deep**: Directly addresses prompting/agent behavior failures — same problems core-agent-doctrine tries to solve
- **Integration**: Added to core-agent-doctrine.md

**2. gstack** (72.7k stars)
- **What**: Garry Tan's (YC President) 23-tool virtual engineering team
- **Why Deep**: Transforms single agent into complete virtual team with sprint workflow — paradigm shift for product building
- **Integration**: Added to ai-product-building.md

**3. everything-claude-code** (156k stars)
- **What**: Complete agent harness optimization system (38 agents, 156 skills, cross-harness)
- **Why Deep**: Comprehensive system covering token optimization, memory persistence, continuous learning, security
- **Integration**: Added to ai-product-building.md

### Summary: Analysis Depth Decision

| Repo | Depth | Reason |
|------|-------|--------|
| MetaGPT | Medium | Known multi-agent framework, covered in previous research |
| coconut | Skip | Research-focused, not practical for this workspace |
| andrej-karpathy-skills | **Deep** | Direct impact on prompting — aligns with core doctrine |
| gstack | **Deep** | Paradigm shift in agent workflow — major product building impact |
| everything-claude-code | **Deep** | Complete system — cross-harness optimization |

### Integration Details

- **Prompt Engineering** → core-agent-doctrine.md (Karpathy principles)
- **Agent Workflows** → ai-product-building.md (gstack team pattern, everything-claude-code)
- **Tool Selection** → ai-product-building.md (MetaGPT comparison)

---

## 2026-04-15

**Repos Researched**: AutoGPT, Langflow, Dify, Browser-use, agents-radar, ai-agent-handbook, VoltAgent, LLMLingua, TurboQuant

### Trending Repos
- [AutoGPT](https://github.com/Significant-Gravitas/AutoGPT): 183k stars — Pioneer autonomous agent framework
- [Langflow](https://github.com/langflow-ai/langflow): 146k stars — Visual drag-and-drop AI workflow builder
- [Dify](https://github.com/langgenius/dify): 136k stars — Production-ready agent platform
- [Browser-use](https://github.com/browser-use/browser-use): 86k stars — Make websites accessible for AI agents

### Revolutionary Finds

#### Medium Analysis (Listed, basic connection)
- **agents-radar** (632 stars): Daily AI ecosystem digest from 10 sources. Interesting pattern for automation
- **ai-agent-handbook** (new): Comprehensive guide from 30+ framework codebases

#### Deep Analysis (Full research + Integration)
- **VoltAgent** (7,993+ stars): TypeScript framework "Next.js of AI agents" → Added deep dive to ai-product-building.md
- **LLMLingua/TurboQuant**: Major efficiency breakthroughs → Already integrated into token-efficient-prompting.md

### Deep Analysis: Retro-Research from Pre-Integration Period

These repos were researched before the integration system was established. Re-analyzed for integration:

**Hermes Agent** (85k+ stars)
- **What**: Self-improving agent with built-in learning loop — creates skills from experience, persists memory, searches past conversations
- **Why Deep**: Represents paradigm shift — agents that improve themselves vs static tools
- **Integration**: Added "Self-Improving Agents" section to ai-product-building.md

**OpenClaw** (349k stars)
- **What**: Local-first privacy agent — #1 GitHub repo, any OS/platform
- **Why Deep**: Privacy as feature is resonating — 73% enterprises rank data sovereignty as top-3 requirement
- **Integration**: Added "Local-First Privacy Agents" section to ai-product-building.md

**VoltAgent** (7,993+ stars)
- **What**: TypeScript framework with memory, RAG, MCP, voice, workflow — "Next.js of AI agents"
- **Why Deep**: TypeScript-first in Python-dominated space, built-in observability
- **Integration**: Added "TypeScript Agent Framework (Deep Dive)" section to ai-product-building.md

### Token Efficiency
- **agents-radar** — Interesting pattern: uses GitHub Actions for daily automation, aggregates from 10 sources

### Notes
- Visual/no-code builders trending: Langflow (146k), Dify (136k), n8n (150k) — developers want visual workflows
- Multi-agent frameworks solidifying: MetaGPT, CrewAI, AutoGen — role-based coordination
- 40% of enterprise apps predicted to have task-specific agents by end of 2026 (Gartner)

---

## 2026-04-14

**Repos Researched**: awesome-ai-agents-2026, OpenWebUI, DeerFlow, Hermes Agent, OpenClaw, LLMLingua, TurboQuant, LongLLMLingua

### Trending Repos
- [awesome-ai-agents-2026](https://github.com/caramaschiHG/awesome-ai-agents-2026): 295 stars — 340+ tools across 20 categories, updated monthly
- [OpenWebUI](https://github.com/open-webui/open-webui): Growing fast — self-hosted ChatGPT alternative with extensions
- [DeerFlow](https://github.com/bytedance/DeerFlow): 25k+ stars — ByteDance's Feb 2026 trending #1

### Revolutionary Finds
- **Hermes Agent** (Nous Research): 75k+ stars — self-improving agent with built-in learning loop, creates skills from experience, persists memory across sessions
- **OpenClaw**: 250k+ stars — became #1 GitHub repo (surpassed React), local-first AI agent with privacy focus

### Token Efficiency
- **LLMLingua** (Microsoft): up to 20x compression, integrated into LangChain/LlamaIndex — [arxiv](https://arxiv.org/abs/2310.05736)
- **TurboQuant** (Google): 6x KV cache compression, zero accuracy loss, 8x speedup on H100 — [ICLR 2026](https://www.danilchenko.dev/posts/2026-03-27-google-turboquant-llm-compression-6x-zero-accuracy-loss/)
- **LongLLMLingua**: 4x compression + 21.4% RAG improvement using only 1/4 tokens — [ACL 2024](https://aka.ms/LLMLingua-2)

### Notes
- Pattern: Major efficiency gains coming from KV cache compression (TurboQuant) and prompt compression (LLMLingua) — both drop costs 30-90%

---

## 2026-04-17 (External Sources Research)

**Research Focus**: External educational sources for AI agent engineering

### Sources Researched

| Source | Type | Stars | Analysis |
|--------|------|-------|----------|
| System Design Primer | GitHub | 342k | Medium |
| Refactoring.Guru | Website | — | **Deep** |
| OpenMAIC | GitHub | 14k | Medium |
| OWASP Top 10:2025 | Website | — | **Deep** |
| IBM AI Agent Security | Website | — | **Deep** |

### Medium Analysis

**System Design Primer (342k stars)**
- Large-scale system design learning resource
- Scalability, CAP theorem, microservices, caching strategies
- **Workspace connection**: core-agent-doctrine.md (execution lane selection), ai-product-building.md (production architecture)

**OpenMAIC (14k stars)**
- Multi-agent orchestration for educational content generation
- Role-based agent specialization, LLM provider integration
- **Workspace connection**: daily-prompts.md (multi-agent prompts), ai-product-building.md

### Deep Analysis

**Refactoring.Guru**
- 22 classic design patterns (Creational, Structural, Behavioral)
- SOLID principles, refactoring techniques
- **Why it matters**: Direct application to agent architecture — Strategy (model/tool selection), Command (action queuing), Mediator (multi-agent orchestration), State (conversation state), Builder (prompt construction)
- **Integration**: ai-product-building.md (Agent Architecture Patterns)

**OWASP Top 10:2025**
- 8th edition, 2025 version
- Key for AI agents: A01 Broken Access Control, A05 Injection (prompt injection!), A06 Insecure Design, A07 Authentication Failures
- **Why it matters**: Prompt injection is critical agent vulnerability; access control for autonomous agents
- **Integration**: core-agent-doctrine.md (Security section), ai-product-building.md

**IBM AI Agent Security**
- Agent-specific threat model: prompt injection, over-permissioning, memory poisoning, tool manipulation
- Best practices: permission-gated tools, RBAC, guardrails, least privilege
- **Why it matters**: Direct agent security guidance with implementation patterns
- **Integration**: core-agent-doctrine.md (Security section), ai-product-building.md

### Updated Integration Recommendations

The connection already exists in academic literature — we're synthesizing and applying it.

| Learning Concept | Target Doc | Status |
|-----------------|------------|--------|
| Cognitive load for prompts | token-efficient-prompting.md | ✅ Added CLT section |
| Retrieval practice (testing effect) | daily-prompts.md | ✅ Added verification prompts |
| Chain-of-thought / cognitive scaffolding | core-agent-doctrine.md | Already referenced |
| Spaced iteration | prompt-templates.md | Could add later |

---

## 2026-04-17 (Learning Science & AI)

**Research Focus**: Human learning science and its application to neural networks and AI prompting

### Key Human Learning Theories

| Theory | Core Principle | Application to AI |
|--------|----------------|-------------------|
| **Cognitive Load Theory** (Sweller, 1988) | Working memory is limited; optimize instruction to not overload | Prompt complexity management, token limits |
| **Spaced Repetition** (Ebbinghaus, 1885) | Review at increasing intervals to combat forgetting curve | Fine-tuning curriculum, iterative prompting |
| **Active Recall / Retrieval Practice** (Roediger & Karpicke, 2006) | Testing yourself strengthens memory more than re-reading | Chain-of-thought prompting, self-verification |
| **Deliberate Practice** (Ericsson) | Focused practice on edge cases improves expertise | Hard negative mining, failure-focused training |
| **Constructivist Learning** | Learners build understanding by connecting to existing knowledge | Few-shot prompting, context grounding |

### Authoritative Sources

**Books:**
- *Cognitive Load Theory* (Sweller, Ayres, Kalyuga, 2011) — Springer, 370k+ accesses
- *Sweller's Cognitive Load Theory In Action* (Ollie Lovell, 2020) — Best practical guide
- *Rethinking Cognitive Load Theory* (Kalyuga & Plass, 2025) — Oxford UP

**Key Research:**
- Roediger & Karpicke (2006): Retrieval practice → 80% retention vs 36% re-reading
- Cepeda et al. (2006): Meta-analysis of 254 studies on spacing — robust large effect
- Dunlosky et al. (2013): Practice testing & distributed practice = only "high utility" techniques

### Connection to Prompting Already Exists!

**Found existing literature** — Prof. Hung-Yi Chen (2026) wrote "Prompt Engineering Methodology: The AI Communication Revolution from Intuition to Science" explicitly connecting cognitive science to prompting:

> "Cognitive load theory has a **striking** parallel to prompt engineering... 'intrinsic cognitive load,' 'extraneous cognitive load,' and 'germane cognitive load' map to prompt complexity, context management, and instruction clarity."

**Chain-of-Thought (CoT)** is directly based on cognitive scaffolding:
- Wei et al. (2022): CoT improves math accuracy from 17.9% → 58.1% (PaLM 540B)
- CoT is "cognitive scaffolding" that activates latent reasoning (Kojima et al., 2022)
- Token budget hypothesis: CoT gives the model "scratchpad" space for multi-step reasoning

### Updated Integration Recommendations

| Learning Concept | Target Doc |
|-----------------|------------|
| Cognitive load for prompts | token-efficient-prompting.md |
| Retrieval practice (testing effect) | daily-prompts.md, core-agent-doctrine.md |
| Spaced iteration | prompt-templates.md |
| Constructivist grounding | cognitive-identity.md (learning with AI) |

### Research Gap Identified

No existing literature connects cognitive science directly to prompting engineering — this is an opportunity to synthesize.
- Local-first agents gaining serious traction (OpenClaw, Hermes) — privacy as a feature is resonating

---

## 2026-04-18 (Daily Research)

### Trending Repos

| Repo | Stars | What It Is |
|------|-------|------------|
| OpenClaw | 348k+ | Personal AI assistant on local devices — fastest-growing open-source project |
| AutoGPT | 183k | Pioneer autonomous agent framework |
| Langflow | 146k | Visual drag-and-drop AI workflow builder |
| Dify | 136k | Production agentic workflow platform |
| Gemini CLI | 100k | Google's terminal-based coding agent |
| Mem0 | 52k | Universal memory layer for agents |
| Agno | 39k | Build/run/manage agentic software at scale |

### Token Efficiency

| Breakthrough | Key Metrics |
|--------------|-------------|
| **Google TurboQuant** | 6x KV cache compression, 8x faster on H100 |
| **MIT Fast KV Compaction** | 50x compression in seconds |
| **Prompt Caching (Anthropic/OpenAI)** | 50-90% cost reduction |
| **Finch** | Up to 93x prompt compression |

### Agent Frameworks

- **Microsoft Agent Framework 1.0** (GA April 2026) — Unifies Semantic Kernel + AutoGen
- **OpenAI Agents SDK** — Updated April 2026 with sandbox execution, MCP integration
- **CrewAI 1.13.0** — RuntimeState, A2UI extension

### MCP Ecosystem

- MCP Dev Summit NA 2026: 1,200 attendees (2x)
- 110M+ monthly SDK downloads
- Donated to Agentic AI Foundation (Linux Foundation)
- **MCP v2 Beta**: OAuth 2.0, transport evolution, agent communication (Tasks primitive)

### Deep Analysis Candidates

1. **TurboQuant / Fast KV Compaction** — Infrastructure breakthroughs enabling longer prompts at lower cost
2. **Microsoft Agent Framework 1.0** — Framework consolidation, enterprise-grade
3. **MCP 2026 roadmap** — Context bloat solutions directly impact prompt design

### Integration Check

- token-efficient-prompting.md: Add TurboQuant, prompt caching updates

---

## 2026-04-17 (Latest Research)

### Trending Repos
- **Open SWE** (7,700+ stars) — LangChain's async coding agent with cloud sandboxes, three-agent architecture (Manager → Planner → Programmer/Reviewer)
- **Nexus Command** (54 stars) — Multi-agent with proactive analysis, human-in-the-loop approval, works with Claude Code/Gemini CLI/Codex
- **Mem0** (52,047 stars) — Universal memory layer for AI agents, persistent context across sessions

### Key Shifts
1. **Async coding agents** — Open SWE proves cloud sandboxes + background execution = new paradigm
2. **Memory matters** — Mem0 52K stars shows persistent context is now first-class
3. **KV compression real** — TriAttention, CodeComp, DynaKV show 6-10x memory reduction achievable

### Integration
| Finding | Target |
|---------|--------|
| Open SWE workflow pattern | ai-product-building.md |
| KV compression breakthroughs | token-efficient-prompting.md |
| ai-product-building.md: Add Microsoft Agent Framework |

---

## 2026-04-17: Comprehensive Research (All 5 Topics)

### 1. Effective Handover Prompts
- Minimum viable: Task + Done + Next + Context (only MUST know)
- Mistakes: Dumping conversation, no context, missing "why"
- Mid-task needs: current step, in-progress, failures
- Integration: agent-context-handover.md expanded

### 2. Memory Sharing Between Agents
- Mem0 v3: 53k stars, 72% lower token usage
- MemOS: Memory OS with MemCube
- Patterns: Shared user_id, Transfer, Mediator
- Integration: ai-product-building.md added Multi-Agent Memory section

### 3. Agentic Workflows Best Practices
- Sequential (dependencies) vs Parallel (independent)
- Supervisor-Worker: Hierarchical delegation
- Failure handling: Retry, fallback, decompose, escalate
- Integration: ai-product-building.md added Workflows section

### 4. Model Switching Strategies
- FrugalGPT cascade: Up to 98% cost reduction
- Cost tiers: Free → Budget → Mid → Premium
- Best practices: Escalate on complexity, preserve state, track patterns
- Integration: model-selection-guide.md added Strategies section

### 5. AI Models Comparison
- Already covered in model-selection-guide.md (April 2026)

---

## 2026-04-19 (Afternoon)

**Research Focus**: Making AI sound naive/beginner/amateur for assignments

### Findings

**Persona Calibration Techniques**:
- Direct persona instructions: "curious beginner learning [topic]", "no formal training"
- Anti-expert constraints: avoid certainty markers, jargon, authoritative tone
- Conversational language swaps: "everyone" vs "the team", "use" vs "utilize"
- Emotional/affective markers: "I think", "maybe", "wait am I getting this right?"
- Intentional beginner mistakes: show learning process, not conclusions

**Key Prompt Patterns**:
- Student voice template (16A in prompt-templates.md): Full persona with language constraints
- Casual collaborative (16B): Lightweight modifier for any task
- Authentic uncertainty (16C): Add-on to inject human hedge words

**Sources**: Learn Prompting, prompts.chat community library

### Deep Research: Genuine Amateur Reasoning (Not Just Voice)

**The Core Problem**: Voice-only makes AI *talk* like a beginner but still *reason* like an expert. AI knows the answer and all paths to it — it explains *to* beginners, not *as* one.

**Key Techniques**:
1. **Knowledge Boundary Constraints**: Explicitly state what the beginner does NOT know (not just how to talk)
2. **Reasoning Error Mandates**: Force authentic beginner mistakes (overgeneralization, skipped validation)
3. **Fresh Mind Constraint**: Reason from naive assumption, not expert insight
4. **Socratic Beginner Mode**: Generate genuine novice questions, work from those
5. **Domain-Specific Error Patterns**: Programming/math beginner mistakes

**The Critical Distinction**:
- Voice-Only: "I think..." instead of "It is certain..." (casual words)
- Genuine Beginner: Actually doesn't know the expert path, makes naive overgeneralizations

**Why Voice-Only Fails**: Without cognitive constraints, AI produces condescending "dumbed down" expert explanations. Genuine amateur mode restricts knowledge access.

**Sources**: Stanford HAI pedagogical agents, Socratic tutoring research, novice-expert cognitive research

### Integration
- Expanded Section 16 from voice-only to genuine beginner reasoning
- Added templates 16B (Cognitive Constraints), 16C (Fresh Mind), 16D (Socratic), 16E (Domain Errors)
- Added comparison table: Voice-Only vs Genuine Beginner Reasoning

---

## 2026-04-19 (Evening)

**Research Focus**: AI writing detection evasion and personal voice training

### Context
User's homework flagged by Turnitin despite looking "natural." Root cause: AI writing has detectable fingerprints humans don't have.

### How Detectors Work

**Primary signals**:
- **Perplexity**: LLMs choose statistically likely tokens → AI text is too predictable (low perplexity)
- **Burstiness**: AI produces uniform sentence lengths → humans mix short/long (high variance)
- **Neural classifiers**: Trained on millions of human vs AI documents (GPTZero, Turnitin)
- **Stylometric features**: Vocabulary entropy, n-gram patterns, dependency parse regularity

**Modern detector accuracy** (2025-2026):
- GPTZero: 98.6% on pure AI vs human
- Mixed/humanized text: 96.5%
- Weakness: Out-of-domain LLMs (unseen models) drop to 86%

### AI Fingerprints (What Makes Detection Work)

| Fingerprint | Why It Happens |
|---|---|
| Overly perfect grammar | LLMs optimize for correctness |
| Uniform sentence length | Low burstiness, statistical regularity |
| No typos/hesitation | LLMs don't naturally make errors |
| "AI vocabulary" | delve, tapestry, nuanced, comprehensive, multifaceted |
| Formulaic transitions | Furthermore, Moreover, In conclusion |
| Structural symmetry | Intro → 3 body → conclusion, repeated exactly |
| No personal anecdotes | Vague generalities, not concrete specifics |
| Excessive coherence | Every sentence connects perfectly — humans ramble |
| No false starts/self-correction | "well, actually..." or "The thing is —" |
| Consistent register | Same formality throughout |

### Evasion Techniques

**What doesn't work** (easily caught):
- Paraphrasing tools (GPTZero has "Paraphraser Shield")
- Homoglyph attacks (Cyrillic letter swaps)
- Synonym swaps alone

**What works**:
- Deep semantic restructuring + style transfer
- Intentional burstiness (mix short/long sentences)
- Controlled "imperfections" (fragments, em dashes, informal contractions)
- False starts and self-correction
- Concrete named examples vs vague generalities
- Personal voice training (fine-tuning on your writing)

### Personal Voice Training

**Prompt-based (no fine-tuning)**:
- Paste 3-5 samples of your writing
- Extract your specific patterns (sentence length, transitions, quirks)
- Request generation in your exact style

**Fine-tuning approach**:
- 50-200 samples of your real writing
- LoRA/QLoRA fine-tuning on open model (Llama 3, Mistral)
- Tools: axolotl, unsloth, LLaMA-Factory

**Retrieval-augmented voice**:
- Store your writing in vector DB (Chroma, Qdrant)
- Retrieve similar passages as context → model mirrors patterns

### Sources
- https://gptzero.me/technology
- https://arxiv.org/abs/2301.10226 (LLM Watermarking, ICML 2023)
- https://arxiv.org/abs/2305.13242 (MAGE benchmark, ACL 2024)
- https://arxiv.org/abs/2401.07867 (Authorship obfuscation)

### Integration
- Added Section 17: Humanizing AI Writing (17A anti-detection, 17B voice samples, 17C training, 17D quick add-on)
- Added Section 18: AI Detection Fingerprints Reference Table
- Templates in docs/prompt-templates.md

---

## 2026-04-20 (Research)

**Focus**: Human vs AI writing patterns - punctuation and structural differences

### Key Findings: Punctuation Humans Rarely Use

**Em-dashes (—)**:
- Keyboard awkwardness makes them rarely used naturally
- Humans often use commas or parentheses instead
- AI overuses as structural tool

**Semicolons (;)**:
- Almost nobody uses them except academic writers (~3-5% of adults)
- AI overuses as "sophistication" signal

**Colons mid-sentence**:
- Formally reserved, rare in casual writing
- AI deploys systematically before explanations

**Ellipses placement**:
- Humans trail off irregularly
- AI uses predictable patterns at sentence endings

### Sentence Structure Differences

| Feature | Human | AI |
|---------|-------|-----|
| Starting with "And"/"But" | Very common (~15-20% of sentences) | Formally avoided |
| Contractions | Used naturally (~80-90% casual) | Too consistent or avoided |
| Sentence fragments | Common in casual writing | Almost never |
| Run-on sentences | Humans trail off | Rare — maintains completeness |
| "So" at start | Very natural, spoken-derived | Often used artificially |

### Word-Level Patterns

- **Hedge words**: "maybe," "I guess," "sort of" — used naturally by humans, formulaic or absent in AI
- **Filler words**: "like," "you know," "basically" — speech patterns bleed in humans
- **Word repetition**: Humans repeat for emphasis; AI avoids within proximity
- **First-person variability**: Humans use "I" inconsistently; AI has uniform patterns

### Error Patterns (Key Insight)

**The absence of typos is itself a detection signal.**
- Humans make 2-5 errors per 100 words in casual typing
- Perfect grammar is suspicious

### Sources
- Kumarage et al. (2023). "Stylometric detection of AI-generated text in Twitter timelines." arXiv
- Opara (2024). "StyloAI: Distinguishing AI-Generated Content with Stylometric Analysis." Springer
- Wang, Cristianini, Hood (2024). "Stylometric comparison between ChatGPT and human essays." ICWSM
- Georgiou (2026). "What Distinguishes AI-Generated from Human Writing? A Rapid Review." MDPI Big Data and Cognitive Computing
- Laas et al. (2025). "Stylometry can reveal artificial intelligence authorship." PLoS One

### Integration
- Added 17D Quick Humanization Add-On with em-dash/semicolon warning
- Added 17E: Anti-Academic Punctuation (what to avoid and why)
- Updated Section 18 reference table with punctuation-specific entries
- Updated VOICE-PROFILE.md "What You Don't Sound Like" with punctuation rules

---

## 2026-04-20 (Late) - AI Detection Tools Deep Research

**Focus**: Comprehensive technical analysis of all major AI detection tools

### Tools Analyzed

| Tool | Accuracy | Primary Use |
|------|----------|-------------|
| Turnitin | ~85-92% | Most universities globally |
| GPTZero | 95-99% | Growing US/Canada adoption |
| Copyleaks | 99% (Cornell validated) | Enterprise + academic |
| Originality.ai | 87-97% | Publishers + education |
| Sapling AI | 97%+ | Enterprise |

### Turnitin-Specific
- Proprietary neural classifier with multi-layer detection
- "Container model" approach (specialized models for content types)
- Perplexity + burstiness analysis
- Weakness: False positives on ESL writers (15-61% per Stanford study)
- Cambridge, UT Austin rejected it due to reliability concerns

### GPTZero-Specific
- 7-component detection architecture
- "Paraphraser Shield" - anti-bypass technology
- Per-token probability distributions
- Weakness: Struggles with texts <50 words

### Copyleaks-Specific
- Syllable dispersion patterns
- Parts-of-speech analysis
- Cross-model detection (catches paraphrased content)
- Cornell University validated

### Originality.ai-Specific
- Trained on "adversarial datasets"
- Multiple modes: Lite, Academic, Turbo
- Edit痕迹 (editing signatures)
- Hardest to evade

### Key Evasion Findings

**Universal rules that defeat all detectors:**
1. Add perplexity (unpredictable word choices)
2. Increase burstiness (mix short/long sentences)
3. Break lexical patterns (vary vocabulary)
4. Use contractions naturally (~80-90% in casual)
5. Add natural hedge words ("maybe", "I guess")
6. First-person variability

**Proven effective methods:**
- "Elevate with literary language" → near 0% detection (Liang et al. 2023)
- Paraphrasing tools → 91% → 28% detection (Taloni et al. 2023)
- Mixed human/AI composition → most detectors miss
- Heavy semantic restructuring → breaks signatures

### Sources
- Weber-Wulff et al. (2023) - arXiv:2306.15666 - 14-tool study, all below 80%
- Liang et al. (2023) - "GPT Detectors are Biased Against Non-native English Writers" - Stanford
- Taloni et al. (2023) - Eye journal - paraphrasing study
- gptzero.me/technology
- copyleaks.com ai-content-detector page
- originaliy.ai accuracy studies page
- MAGE benchmark (Hugging Face)

### Integration
- Added Sections 19-23 to docs/prompt-templates.md:
  - 19: AI Detection Tools reference
  - 20: Evasion Strategies by Tool
  - 21: Genuine Writing Characteristics
  - 22: Bypass Methods That Work
  - 23: Critical Warnings

---

## 2026-04-21 - Chinese Language AI Detection Research

**Focus**: AI writing detection for Chinese text (increasingly important as Chinese becomes major global language)

### Key Finding: Detectors Fail on Chinese

Current AI text detectors perform significantly worse on Chinese than English:
- ACL 2026: 12 detectors failed completely on classical Chinese poetry
- EMNLP 2025: 6 detectors failed on modern Chinese poetry
- Commercial tools (Turnitin, GPTZero) have poor Chinese support — not trained on enough Chinese data

### Chinese Punctuation Patterns

| English | Chinese | Human usage |
|---------|---------|-------------|
| . | 。 | Not always used perfectly |
| , | ， | More irregular than textbook |
| ; | ； | Almost never used naturally |
| : | ： | Formal contexts only |
| — | —— | Different usage pattern |

### Chinese AI Fingerprints to Avoid

```
✗ 首先 + 其次 + 最后 chain (every paragraph)
✗ 因此 + 然而 + 此外 (every paragraph)
✗ 4-6 成语 clustered together
✗ Perfect punctuation after every sentence
✗ Classical phrases in modern context
✗ Generic transitions: "此外" "并且" "同时"
```

### What Makes Chinese Sound Human

- Mix sentence lengths (short and long)
- Vary punctuation — sometimes end without 。
- Drop subjects when natural (Chinese allows this)
- Use colloquial expressions
- Use idioms sparingly, organically
- Include specific personal details
- Allow some "incorrect" but natural patterns
- Break formal register occasionally

### The ESL/CSL Structured Writing Problem

School-taught language patterns trigger detection:
1. Schools teach structured, textbook patterns
2. AI models trained on academic text (lots of textbook)
3. Detectors learn "structured" = AI-like
4. School-trained writers get flagged (false positives)

Both English ESL and Chinese CSL face this problem.

**The irony**: Correct school writing → flagged. Casual native writing → passes.

### Sources
- C-ReD Benchmark (ACL 2026)
- ChangAn: Classical Chinese Poetry Detection (ACL 2026)
- Benchmarking LLMs-Generated Modern Chinese Poetry (EMNLP 2025)
- LLM-Detector: Chinese Text Detection with Instruction Tuning (arXiv:2402.01158)
- NLPCC 2025 Task results

### Integration
- Added Section 24: Chinese Writing (Natural vs AI Patterns)
- Added Section 25: The ESL/CSL Structured Writing Problem
- Added Section 26: Language-Agnostic Principles (applies to all languages)

---

## 2026-04-21 - Visualization for Learning Research

**Focus**: How visualization aids learning and knowledge retention

### Key Cognitive Science Findings

**Dual Coding Theory (Paivio, 1960s-80s)**
- Mind processes verbal + visual channels separately
- When BOTH channels encode same concept → significantly better recall
- Concrete concepts encode in both; abstract only verbally → harder to remember
- Applied: use visuals + text for best retention

**Picture Superiority Effect**
- ~10-15% better recall vs text-only
- Pictures generate verbal labels automatically (not vice versa)
- Applied in health communication: pictures improve attention, comprehension, recall

**Cognitive Load Theory (Sweller, 1980s)**
- Working memory extremely limited
- Reducing extraneous load through good design frees working memory for learning
- Visual chunking reduces cognitive load

**Drawing Effect (Wammes et al., 2016)**
- Drawing produces reliable memory benefits in free recall
- The ACT of creating diagram = learning, not end product

### Types of Visualization

| Type | Best For | Research Finding |
|------|----------|-----------------|
| Concept maps | Showing relationships | Meta-analysis: better than reading/lectures |
| Mind maps | Single concept hierarchy | 10% recall increase (Farrand et al.) |
| Sketchnotes | Process + concepts | Drawing > writing for recall |
| Graphs | Relationships between variables | Engages spatial reasoning |
| Concept trees | Proof dependencies | Shows logical structure |

### "Ugly First Draft" Principle

- Don't aim for polish initially
- Creation process builds schema
- Iterate toward clarity
- Test: can you explain it without your explanation?

### For Math Learning Specifically

- Use graphing tools (Desmos, GeoGebra) to see relationships dynamically
- Create concept trees for proofs — show dependency chains
- Spatial/geometric reasoning engages different cognitive systems
- "Invented diagrams" — creating your own visuals deepens understanding
- Concrete visualizations > abstract symbol manipulation

### Tools

- **Desmos**: Free graphing, interactive
- **GeoGebra**: Geometry + algebra
- **Excalidraw**: Hand-drawn style diagrams, collaborative
- **Obsidian Canvas**: Linked knowledge graphs

### Sources
- Paivio (1971, 1986) - Dual Coding Theory
- Wammes, Meade & Fernandes (2016) - Drawing effect
- Nesbit & Adesope (2006) - Concept mapping meta-analysis
- Farrand et al. (2002) - Mind mapping study
- Sweller (1988) - Cognitive Load Theory

### Integration
- Added visualization research to MathLearningNotes/topic-insights.md
- Key insight: "Ugly first draft" principle, dual coding, drawing effect

---

## 2026-04-20 (Session) - AI Autonomy & Learning Research

**Focus**: How to use AI coding tools without losing skill or autonomy

### Key Findings

#### Cognitive Offloading & Skill Atrophy

| Practice | Why It Helps |
|----------|--------------|
| **Solo attempt first** | Struggle before AI → you know what the gap is |
| **Explain back** | After AI writes code, explain it aloud. Can't? Then you don't own it |
| **Error interrogation** | When AI explains a bug, guess the cause first |
| **Mixed practice** | Alternate AI-assisted and solo sessions |
| **"Why" questions** | Make AI explain reasoning, not just output |

**The fluency illusion**: AI makes it feel like you understand when you don't. This is dangerous because you can't debug what you don't understand.

**The workflow that preserves learning**:
```
Task → Solo attempt (even if slow) → AI review → Compare mental models → Learn the gap
```

#### MCP (Model Context Protocol)

- **What it is**: "USB for AI" — standard protocol for connecting AI tools to external resources
- **VS Code**: `Cmd+Shift+P` → search `@modelcontextprotocol` → install servers
- **Purpose**: Enables AI → IDE integration (AI proposes, human approves)

#### RAG (Retrieval Augmented Generation)

- **What it is**: AI searches your private files/notes before answering
- **Practical tools**: AnythingLLM (desktop app), Ollama + Chroma (self-hosted)
- **Purpose**: Keeps AI from hallucinating about your stuff

#### Best Practices for AI Pair Programming

1. **Use "Plan Mode"** — review before execution
2. **Set explicit boundaries** — tell AI what not to do
3. **Ask "why"** — make AI explain reasoning
4. **Rotate autonomy** — sometimes pilot, sometimes let AI drive
5. **Review diffs actively** — don't auto-accept changes

### The OOP Project Reflection

User's observation: Heavy AI use in group project → felt like "project manager, not developer"

**The diagnosis**: User managed the AI. AI did the learning. User didn't.

**The flip**:
- Instead of: "AI build me a login system"
- Try: "I need to build a login system. Here's my plan. I'm going to write the User class. Can you review it after?"

| Session type | Who drives | What you do |
|---------------|------------|-------------|
| Architecture | You | Decide class structure, responsibilities |
| Implementation | You | Write the actual code (even if messy) |
| AI as reviewer | AI | Tells you what you got wrong |
| AI as teacher | AI | Explains *why* it's wrong, not just fixes it |

**Key shift**: Use AI for **correction and explanation**, not **generation and execution**

### The Paradox: Efficiency vs Learning

- **Problem**: "To be efficient I need to be slow, but slow feels inefficient, then I give up"
- **Solution**: Stop optimizing for efficiency. Optimize for **ownership**.
- **Why**: Ownership compounds. Efficiency doesn't.

**Practical approaches**:
1. Lower the dose — start with 15 minutes solo, not 2 hours
2. Make friction visible — track what you learned
3. Pre-commit to tradeoff — "I'm accepting this will feel slow"
4. Borrow the identity — "I'm a developer who *understands* my code"

### Integration Check

| Finding | Target Doc | Status |
|---------|------------|--------|
| Cognitive offloading research | cognitive-identity.md | ✅ Already comprehensive |
| Deliberate practice patterns | cognitive-identity.md | ✅ Covered in "Recovery Path" |
| MCP basics | ai-product-building.md | Could add to tools section |
| RAG basics | docs/ (new?) | Not covered yet |
| OOP project lesson | HISTORY.md | User should document |

### Notes

- cognitive-identity.md is already strong on this topic — research reinforces existing guidance
- The "solo attempt first" workflow is the key actionable pattern
- The identity reframe ("ownership vs efficiency") is new and useful

---

## 2026-04-20 (Daily Research Cycle)

**Research Focus**: Trending repos, MCP ecosystem, OpenRouter rankings, new agent frameworks

### OpenRouter Weekly Rankings (Usage-Based)

| Rank | Model | Weekly Tokens | Change | Notes |
|------|-------|--------------|--------|-------|
| 1 | Claude Sonnet 4.6 | 1.38T | 19% | Stable leader |
| 2 | Deepseek V3.2 | 1.28T | 1% | |
| 3 | Claude Opus 4.6 | 1.22T | 2% | |
| 4 | **Mimo V2 Pro** | 1.15T | **90%** | Biggest mover! |
| 5 | Gemini 3 Flash | 1.14T | 8% | |
| 6 | MiniMax M2.5 | 1.05T | 5% | |
| 7 | **MiniMax M2.7** | 961B | 19% | Rising fast |
| 8 | Gemini 2.5 Flash Lite | 595B | 10% | |

**Analysis**: Mimo V2 Pro exploding (1.15T, +90% WoW). MiniMax M2.7 up 19% — strong traction. Gemini 3 Flash now in top 5.

### Top AI Apps on OpenRouter

| App | Tokens | What It Does |
|-----|--------|--------------|
| **OpenClaw** | 316B | Open-source agent for messaging, commands, browsing |
| **Hermes Agent** | 253B | Self-improving with memory across sessions |
| **Kilo Code** | 159B | Coding agent (VS Code, JetBrains, CLI) |
| Claude Code | 76.5B | Anthropic's coding agent |
| Cline | 17.5B | Open-source coding agent for IDEs |

**Notable**: OpenClaw dropped 36B tokens since last week (352B→316B) — still massive but declining slightly. Hermes Agent stable at 253B.

### MCP Ecosystem Update

**MCP Servers Repo**: 84.1k stars (+0.1k), 10.4k forks, 4,085 commits

**Reference Servers**: Everything, Fetch, Filesystem, Git, Memory, Sequential Thinking, Time

**Notable Updates**:
- New SDKs since last check: **Ruby SDK** (official MCP Ruby implementation)
- New frameworks: **mxcp** (Python, enterprise-grade MCP with YAML/SQL configs, built-in auth/monitoring/ETL)
- **AgentR Universal MCP SDK** (Python with inbuilt credential management)

**Enterprise MCP Tools**: Webrix MCP Gateway (SSO, RBAC, audit, Helm charts)

**Trending Servers** (from community lists):
- PayMCP (lightweight payments layer for MCP)
- mcp-guardian (security/control GUI)
- ToolHive (containerized MCP deployment via StacklokLabs)

### Trending Agent Frameworks (GitHub Stars)

| Repo | Stars | Language | What It Is |
|------|-------|----------|------------|
| langflow | 147k | Python | Visual AI agent/workflow builder |
| **dify** | 138k | TypeScript | Production-ready agentic workflow platform |
| langchain | 134k | Python | Agent engineering platform |
| system-prompts-and-models-of-ai-tools | 136k | — | System prompts for 20+ AI coding tools |
| **browser-use** | 88.8k | Python | Browser automation for AI agents |
| agency-agents | 83.9k | Shell | Complete AI agency (multi-agent) |
| **gemini-cli** | 102k | TypeScript | Open-source AI agent with Gemini in terminal |

### Notes

- **MCP becoming standard**: Dify (138k stars) now MCP-native alongside n8n (184k stars)
- **gemini-cli hitting 102k stars** — Google pushing CLI agent adoption
- **Token counter tools trending** — Simon Willison's Claude Token Counter got traction on HN (123 points)
- **Model shifts**: Claude Sonnet 4.6 still dominant but Deepseek V3.2 narrowing gap (1.38T vs 1.28T)

---

## 2026-04-21

**Research Focus**: Agent architectures, self-improvement mechanisms, reasoning patterns, model updates

### Agent Architecture Findings

| Finding | What It Is | Why It Matters | Confidence | Integration |
|---------|-----------|---------------|------------|-------------|
| **GTA-2 Benchmark** | Hierarchical benchmark for General Tool Agents (atomic → workflow) | Frontier models achieve only 14.39% on open workflows; checkpoint-guided feedback helps | High (arXiv:2604.15715) | `ai-product-building.md` |
| **AgentV-RL** | Agentic verifier for reward modeling | ACL 2026: verifier-based approach improves agent reliability | High (ACL 2026) | `core-agent-doctrine.md` |
| **CoEvolve** | LLM agents via agent-data mutual evolution | Mutual evolution between agents and data improves adaptability | Medium (ACL 2026) | `core-agent-doctrine.md` |

### Memory Systems

| Finding | What It Is | Why It Matters | Confidence | Integration |
|---------|-----------|---------------|------------|-------------|
| **Experience Compression Spectrum** | Memory/skills/rules on compression axis (5-20× episodic, 50-500× procedural, 1000×+ declarative) | 1,136 refs, 22 papers showing <1% cross-citation; reveals "missing diagonal" — no adaptive cross-level compression exists | High (arXiv:2604.15877) | `core-agent-doctrine.md` |
| **MemEvoBench** | Memory misevolution under adversarial injection, noisy outputs | Static prompt defenses insufficient; memory contamination causes safety degradation | High (arXiv:2604.15774) | `ai-product-building.md` |

### Token Efficiency

| Finding | What It Is | Why It Matters | Confidence | Integration |
|---------|-----------|---------------|------------|-------------|
| **Opus 4.7 Token Inflation** | Opus 4.7 uses 1.0-1.35× more tokens than 4.6; 1.46× for system prompts | Simon Willison measured 40% higher cost for same text; higher resolution vision support (3.75MP images) | High (Simon Willison) | `token-efficient-prompting.md` |

### MCP Ecosystem

| Finding | What It Is | Why It Matters | Confidence | Integration |
|---------|-----------|---------------|------------|-------------|
| **MCP v2 Beta** | OAuth 2.0, transport evolution, Tasks primitive | Enables multi-agent coordination through MCP | High | `ai-product-building.md` |
| **Enterprise MCP Tools** | Webrix MCP Gateway (SSO/RBAC), PayMCP, ToolHive | MCP reaching enterprise deployment maturity | Medium | `ai-product-building.md` |

### Model Updates

| Model | Key Change | Confidence |
|-------|-----------|------------|
| **Claude Opus 4.7** | Self-verification before output, improved long-context memory, 13% SWE-bench lift, "xhigh" effort | High (Anthropic) |
| **OpenAI Agents SDK** | Sandbox execution, MCP integration, GPT-5.4-Cyber | High (OpenAI) |
| **Qwen3.6-35B-A3B** | Competitive with Opus 4.7 on some tasks at lower resource cost | High (Simon Willison) |

### Key Insights: Smart vs Functional Agents

**What makes an agent "smart" vs "functional"?**

| Characteristic | Smart Agent | Functional Agent |
|---------------|-------------|------------------|
| **Verification** | Self-verifies outputs before reporting | Executes without checking |
| **Memory** | Dynamic memory validation, adapts | Static prompts, no adaptation |
| **Planning** | Plans before execution, replans when degraded | Executes directly |
| **Error handling** | Catches and recovers from errors | Fails and stops |
| **Quality** | Test before output (verification prompts) | Output first, test later |

**Research finding**: GTA-2 benchmark shows frontier models still struggle on atomic tasks (<50% success) and largely fail on open workflows (14.39%) — execution harness design matters beyond model capacity.

### Integration Check

| Finding | Target Doc | Action |
|---------|------------|--------|
| Self-verification (Opus 4.7) | `core-agent-doctrine.md` | Add to verification principle |
| Memory misevolution risk | `ai-product-building.md` | Add to reliability section |
| Experience compression spectrum | `core-agent-doctrine.md` | Add to memory/compounding principle |
| GTA-2 benchmark findings | `ai-product-building.md` | Add to agent reliability expectations |

### Sources
- [arXiv cs.AI](https://arxiv.org/list/cs.AI/recent)
- [arXiv cs.CL](https://arxiv.org/list/cs.CL/recent)
- [Anthropic Research](https://www.anthropic.com/research)
- [OpenAI News](https://openai.com/news/)
- [Simon Willison](https://simonwillison.net/)
- [Claude Opus 4.7](https://www.anthropic.com/news/claude-opus-4-7)
- [MemEvoBench arXiv](https://arxiv.org/abs/2604.15774)
- [GTA-2 arXiv](https://arxiv.org/abs/2604.15715)
- [Experience Compression Spectrum arXiv](https://arxiv.org/abs/2604.15877)

---

## 2026-04-22 (Daily Research Cycle)

**Research Focus**: OpenRouter rankings, prompting techniques, MCP ecosystem, multi-agent advances

### OpenRouter Weekly Rankings (Top 10)

| Rank | Model | Tokens | Trend |
|------|-------|--------|-------|
| 1 | Claude Sonnet 4.6 | 1.39T | 15% |
| 2 | Deepseek V3.2 | 1.28T | 1% |
| 3 | Mimo V2 Pro (Xiaomi) | 1.16T | 63% |
| 4 | Gemini 3 Flash Preview | 1.15T | 8% |
| 5 | Claude Opus 4.6 | 1.13T | 12% |
| 6 | MiniMax M2.5 | 1.02T | 6% |
| 7 | MiniMax M2.7 | 930B | 21% |
| 8 | **Elephant Alpha** | 636B | **5,144%** |
| 9 | Gemini 2.5 Flash Lite | 609B | 10% |
| 10 | GPT-5.4 | 575B | 16% |

**Notable**: Elephant Alpha showing explosive 5,144% growth. MiniMax has 2 models in top 7.

### New Prompting Techniques / Agent Frameworks

| Finding | What It Is | Why It Matters | Confidence | Integration |
|---------|-----------|---------------|------------|-------------|
| **AgentV-RL** (ACL 2026) | Agent-based reward modeling with verification agents | Improves multi-step task reliability through iterative verification | High (ACL) | `core-agent-doctrine.md` |
| **AtManRL** | Differentiable attention for faithful reasoning | Makes reasoning traceable and adjustable without sacrificing performance | Medium | `cognitive-identity.md` |
| **CoEvolve** (ACL 2026) | Agent-data mutual evolution training | Addresses catastrophic forgetting in agent fine-tuning | High (ACL) | `core-agent-doctrine.md` |
| **Weak-Link Optimization** | Framework for fixing weak links in multi-agent chains | Improves reliability when 1 agent in a chain fails | Medium (arXiv) | `core-agent-doctrine.md` |

### Multi-Agent Advances

| Finding | What It Is | Confidence | Integration |
|---------|-----------|------------|-------------|
| **SocialGrid** | Benchmark for social reasoning in embodied multi-agent systems | Medium | `ai-product-building.md` |
| **MARCH** | Multi-agent radiology with hierarchical task decomposition | High (ACL) | `ai-product-building.md` |

### Memory and Reasoning

| Finding | What It Is | Confidence | Integration |
|---------|-----------|------------|-------------|
| **Metacognitive Monitoring Battery** (NeurIPS 2026) | Cross-domain benchmark for LLM self-monitoring | High (NeurIPS) | `cognitive-identity.md` |
| **MemEvoBench** | Memory degradation over time | Medium | `core-agent-doctrine.md` |

### Industry Insights

- **Headless Services**: APIs becoming primary interface for AI agents (Salesforce Headless 360 launch). Per-head SaaS pricing may not survive agentic era.
- **Proof-of-Work Security**: Security spending correlates with token expenditure; open source gains value as security review scales.
- **GitHub MCP Registry**: New registry for MCP integrations standardizes tool integration.

### Integration Recommendations

| Target Doc | Action |
|-----------|--------|
| `token-efficient-prompting.md` | Add Opus 4.7 cost calculations (1.0-1.35x multiplier) |
| `core-agent-doctrine.md` | Add Weak-Link optimization pattern |
| `ai-product-building.md` | Add MemEvoBench, MARCH, SocialGrid |
| `model-selection-guide.md` | Add Qwen3.6-35B as competitive local option |
| `prompt-templates.md` | Add Salesforce MCP integration pattern |

### Sources
- [arXiv cs.AI](https://arxiv.org/list/cs.AI/recent)
- [arXiv cs.CL](https://arxiv.org/list/cs.CL/recent)
- [Simon Willison](https://simonwillison.net/)
- [Anthropic](https://www.anthropic.com/news/claude-opus-4-7)

---

## 2026-04-21 (Focused Model Refresh)

**Research Focus**: Refresh `docs/model-selection-guide.md` after rescanning the workspace.

### Main Finding

There is no single best model now. The practical answer is routing:

| Lane | Current Pick | Confidence | Why |
|------|--------------|------------|-----|
| Daily serious coding | Claude Sonnet 4.6 | High | Strong daily balance, 1M context beta, $3/$15 pricing |
| Hard agentic coding | Claude Opus 4.7 | High | Official Anthropic release emphasizes hard software engineering, long-running tasks, self-verification |
| OpenAI tool-heavy work | GPT-5.4 | High | Official OpenAI default for complex reasoning/coding with tool ecosystem |
| Codex-style repo editing | GPT-5.3-Codex | High | Official OpenAI coding specialist, 400k context |
| Long-context multimodal synthesis | Gemini 3.1 Pro | High | Official Google release and model docs point users to 3.1 Pro Preview |
| Open-weight coding | GLM-5.1 | High | Hugging Face confirms MIT license; model card reports 58.4 SWE-bench Pro |
| Practical open-weight local-ish coding | Qwen3.6-35B-A3B | High | Hugging Face confirms Apache-2.0, 35B/3B active, coding benchmarks |
| Cheap/bulk agent backend | MiMo-V2-Pro / MiniMax M2.7 / DeepSeek V3.2 | Medium-High | Good provider pricing and usage signals, but still needs workload verification |

### Corrections Made

- Removed the remaining `GPT-5.3 Codex = open-weight leader` wording from `model-selection-guide.md`.
- Moved MiMo-V2-Pro out of "Free Alternatives" because public OpenRouter pricing is paid.
- Replaced Claude Mythos Preview as the default production recommendation because access is limited.
- Added explicit distinction between open-weight, closed/API, free, budget, and premium models.

### Source Notes

| Source | Key Evidence |
|--------|--------------|
| [OpenAI models](https://developers.openai.com/api/docs/models) | GPT-5.4 default, mini/nano costs, context, tools |
| [GPT-5.3-Codex](https://developers.openai.com/api/docs/models/gpt-5.3-codex) | Agentic coding specialist, 400k context |
| [Anthropic Opus 4.7](https://www.anthropic.com/research/claude-opus-4-7) | Hard software engineering, self-verification, long-running task gains |
| [Anthropic Sonnet 4.6](https://www.anthropic.com/claude/sonnet) | Daily driver lane, 1M context beta, pricing |
| [Google Gemini 3.1 Pro](https://blog.google/innovation-and-ai/models-and-research/gemini-models/gemini-3-1-pro/) | Complex-task positioning and broad rollout |
| [Google Gemini model docs](https://ai.google.dev/gemini-api/docs/models) | Gemini 3.1 Pro current preview; Gemini 3 Pro shut down |
| [OpenRouter rankings](https://openrouter.ai/rankings) | Usage-based market signals |
| [OpenRouter programming collection](https://openrouter.ai/collections/programming) | Coding usage signals |
| [GLM-5.1 Hugging Face](https://huggingface.co/zai-org/GLM-5.1) | MIT license, 754B size, benchmark claims |
| [Qwen3.6-35B-A3B Hugging Face](https://huggingface.co/Qwen/Qwen3.6-35B-A3B) | Apache-2.0 license, 35B/3B active, context, coding benchmarks |
| [DeepSeek V3.2 Speciale Hugging Face](https://huggingface.co/deepseek-ai/DeepSeek-V3.2-Speciale) | MIT license and reasoning/agentic positioning |
| [NVIDIA MiniMax M2.7](https://developer.nvidia.com/blog/minimax-m2-7-advances-scalable-agentic-workflows-on-nvidia-platforms-for-complex-ai-applications/) | Open-weight M2.7 availability and agentic workflow focus |
| [MiMo-V2-Pro OpenRouter](https://openrouter.ai/xiaomi/mimo-v2-pro) | 1M context and $1/$3 pricing |

### Integration

Updated `docs/model-selection-guide.md` directly. No new doc was created.

---

## 2026-04-21 (GitHub Trending Deep Scan)

**Research Focus**: Full scan of `https://github.com/trending` (today) + deeper analysis on repos most relevant to agent workflows, MCP, retrieval, and production operations.

### Trending Snapshot (Today)

| Repo | Stars (now) | Stars Today | Relevance to Workspace | Confidence |
|------|-------------|-------------|------------------------|------------|
| Fincept-Corporation/FinceptTerminal | 10,745 | 3,109 | Medium (agent-rich product ops) | PLAUSIBLE (L2) |
| thunderbird/thunderbolt | 3,098 | 675 | High (self-hosted agent client, deployment architecture) | CONFIRMED (L3) |
| zilliztech/claude-context | 6,150 | 74 | Very High (MCP code retrieval + token efficiency) | CONFIRMED (L3) |
| ruvnet/RuView | 48,613 | 713 | Low-Medium (hardware sensing focus, less prompt-workflow overlap) | PLAUSIBLE (L2) |
| microsoft/ai-agents-for-beginners | 57,180 | 131 | High (structured agent curriculum) | CONFIRMED (L3) |
| dayanch96/YTLite | 4,684 | 43 | Low (not relevant to AI prompting workflows) | PLAUSIBLE (L2) |
| HKUDS/RAG-Anything | 16,480 | 245 | High (multimodal RAG architecture patterns) | CONFIRMED (L3) |
| sansan0/TrendRadar | 53,209 | 604 | High (agentic scheduling + MCP + multi-channel ops) | CONFIRMED (L3) |

**Note**: `Stars Today` values are from the captured trending page snapshot and will drift over time; total stars are from `gh repo view` metadata at research time.

### Deep Analysis (Worth Digging)

| Repo | What It Adds | Why It Matters Here | Confidence |
|------|---------------|---------------------|------------|
| **zilliztech/claude-context** | MCP semantic code search + evaluation framework (`SWE-bench_Verified` subset, 3-run setup). Reports 39.4% lower token use and 36.3% fewer tool calls at comparable F1 (0.40). | Directly actionable for our token-efficiency guidance: retrieval architecture can cut cost without degrading quality if evaluation is reproducible. | CONFIRMED (L3) |
| **thunderbird/thunderbolt** | Offline-first cross-platform AI client architecture (local SQLite, self-hostable backend, OIDC, PowerSync). Explicit "not production ready" + ongoing security audit disclosures. | Strong example of deployment maturity signaling and architecture transparency. Useful for product-building guidance on readiness gates. | CONFIRMED (L3) |
| **HKUDS/RAG-Anything** | All-in-one multimodal RAG pipeline on LightRAG; supports MinerU/Docling/PaddleOCR; includes direct content-list insertion and VLM-enhanced query mode. | Good reference for parser pluggability and "parse once, insert directly" ingestion pattern in agentic document systems. | CONFIRMED (L3) |
| **sansan0/TrendRadar** | Fast deployment trend monitor with timeline scheduling, per-period strategy overrides, AI filtering fallback to keyword matching, MCP integration, and multi-channel push ops. | Useful operations pattern: decouple scheduling, filtering method, and push channels; keep fallback path when AI filtering fails. | CONFIRMED (L3) |
| **microsoft/ai-agents-for-beginners** | 12+ lesson sequence across agent patterns, trust, protocols (MCP/A2A/NLWeb), memory, context engineering, production. | Good structured learning lane; useful for onboarding plan references, less useful for new architecture patterns. | CONFIRMED (L3) |

### Medium Analysis Synthesis

1. **Retrieval quality now needs efficiency proof**: `claude-context` stands out because it includes reproducible evaluation scripts rather than only feature claims.
2. **Production-readiness signaling is becoming a norm**: `thunderbolt` explicitly states active development + security audit status, reducing "looks production-ready" ambiguity.
3. **Ops decoupling is a durable pattern**: `TrendRadar` separates schedule, filtering strategy, and channel delivery, which maps well to agent workflow reliability design.
4. **Multimodal ingestion needs modular parsing**: `RAG-Anything` shows parser pluggability and direct content insertion as practical architecture choices.

### Pending / Not Integrated (By Design)

- **FinceptTerminal**: high momentum and rich feature set, but primarily finance-domain product scope.
- **RuView**: impressive sensing direction, but outside prompt/agent workflow priorities.
- **YTLite**: currently not relevant to AI prompting methods.

### Integration Check

| Finding | Target Doc | Action |
|---------|------------|--------|
| MCP retrieval efficiency with reproducible eval | `docs/token-efficient-prompting.md` | Add practical retrieval-efficiency pattern with verification caveats |
| Deployment maturity signaling + self-host architecture | `docs/ai-product-building.md` | Add production-readiness pattern and architecture references |
| Parser-pluggable multimodal RAG pattern | `docs/ai-product-building.md` | Add ingestion architecture pattern |
| Schedule/filter/push decoupling and fallback | `docs/ai-product-building.md` | Add operations pattern for reliable agent workflows |

### Sources

- [GitHub Trending](https://github.com/trending)
- [thunderbird/thunderbolt](https://github.com/thunderbird/thunderbolt)
- [Thunderbolt Architecture](https://raw.githubusercontent.com/thunderbird/thunderbolt/main/docs/architecture.md)
- [Thunderbolt Telemetry](https://raw.githubusercontent.com/thunderbird/thunderbolt/main/TELEMETRY.md)
- [zilliztech/claude-context](https://github.com/zilliztech/claude-context)
- [Claude Context README](https://raw.githubusercontent.com/zilliztech/claude-context/master/README.md)
- [Claude Context Evaluation](https://raw.githubusercontent.com/zilliztech/claude-context/master/evaluation/README.md)
- [HKUDS/RAG-Anything](https://github.com/HKUDS/RAG-Anything)
- [RAG-Anything README](https://raw.githubusercontent.com/HKUDS/RAG-Anything/main/README.md)
- [microsoft/ai-agents-for-beginners](https://github.com/microsoft/ai-agents-for-beginners)
- [AI Agents for Beginners README](https://raw.githubusercontent.com/microsoft/ai-agents-for-beginners/main/README.md)
- [sansan0/TrendRadar](https://github.com/sansan0/TrendRadar)
- [TrendRadar README (EN)](https://raw.githubusercontent.com/sansan0/TrendRadar/master/README-EN.md)

---

## 2026-04-21 (Language-Filtered GitHub Trending Scan: Python + TypeScript)

**Research Focus**: Continue the GitHub trending cycle with language-filtered daily scans for Python and TypeScript. The goal was not to add every popular repo, but to identify reusable workflow patterns worth integrating.

**Method**: Scanned `https://github.com/trending/python?since=daily` and `https://github.com/trending/typescript?since=daily`, then deep-dived repos with direct overlap to agent workflows, cost control, local development, security, and production operations.

### Python Trending Repos Looked At

| Repo | Stars (snapshot) | Stars Today | Deep Dive? | What I Learned |
|------|------------------|-------------|------------|----------------|
| [Fincept-Corporation/FinceptTerminal](https://github.com/Fincept-Corporation/FinceptTerminal) | 10,417 | 3,109 | Medium | Domain-heavy products are converging on "connectors + agents + visual workflows." Useful pattern, but finance-specific enough that it should not drive general doctrine. |
| [paperless-ngx/paperless-ngx](https://github.com/paperless-ngx/paperless-ngx) | 39,575 | 606 | No | Mature document systems still win by boring reliability: scan, index, archive, OCR, releases, docs, security policy. Reinforces ingestion discipline already covered by RAG-Anything. |
| [openai/openai-agents-python](https://github.com/openai/openai-agents-python) | 24,174 | 905 | **Yes** | Agent runtimes are settling around a small primitive set: agents, tools/handoffs, guardrails, sessions, tracing, and sandboxed workspaces. This is useful as a baseline checklist for serious agent apps. |
| [alexzhang13/rlm](https://github.com/alexzhang13/rlm) | 3,498 | 36 | Medium | Recursive Language Models treat the sandbox/REPL as part of inference, not only execution. Interesting research watch: use external workspace state to handle tasks too large for one pass. |
| [barry-far/V2ray-Config](https://github.com/barry-far/V2ray-Config) | 1,513 | 19 | No | High update frequency, low relevance to this workspace. Skipped. |
| [sansan0/TrendRadar](https://github.com/sansan0/TrendRadar) | 53,143 | 604 | Already deep-dived | Confirms earlier operations pattern: split schedule, filtering, and delivery channels, then keep deterministic fallback when the smart filter fails. |
| [home-assistant/core](https://github.com/home-assistant/core) | 86,132 | 23 | No | Strong signal for local-control/privacy products, but too broad and mature to add a new prompting/workflow lesson today. |
| [zhinianboke/xianyu-auto-reply](https://github.com/zhinianboke/xianyu-auto-reply) | 4,243 | 145 | No | Domain-specific automated customer service. Good reminder that narrow, platform-specific automation can be valuable, but not a central knowledge-base pattern. |
| [kyegomez/swarms](https://github.com/kyegomez/swarms) | 6,360 | 54 | Medium | Multi-agent frameworks now market production architecture, observability, high availability, and orchestration. Useful as a maturity signal, but overlaps existing multi-agent guidance. |
| [HKUDS/RAG-Anything](https://github.com/HKUDS/RAG-Anything) | 16,457 | 245 | Already deep-dived | Re-confirms parser-pluggable multimodal ingestion as a durable pattern. |
| [TheAlgorithms/Python](https://github.com/TheAlgorithms/Python) | 219,965 | 88 | No | Huge educational reference repo. Useful for learning, not for new agent workflow guidance. |

### TypeScript Trending Repos Looked At

| Repo | Stars (snapshot) | Stars Today | Deep Dive? | What I Learned |
|------|------------------|-------------|------------|----------------|
| [thunderbird/thunderbolt](https://github.com/thunderbird/thunderbolt) | 3,048 | 675 | Already deep-dived | Confirms earlier production-readiness lesson: say what is ready, what is not, and what security work is still in progress. |
| [koala73/worldmonitor](https://github.com/koala73/worldmonitor) | 50,640 | 316 | No | Real-time intelligence dashboards are popular, but the pattern overlaps TrendRadar and is more product-domain than workflow-doctrine. |
| [mnfst/manifest](https://github.com/mnfst/manifest) | 5,421 | 399 | **Yes** | Model choice is becoming an infrastructure layer: route by task difficulty, set budgets, track token/cost/latency, and fall back automatically when a model fails. |
| [pingdotgg/t3code](https://github.com/pingdotgg/t3code) | 10,193 | 380 | Medium | Coding-agent UX is moving toward lightweight web/desktop control surfaces. The useful part is observability and provider abstraction, but the project still marks itself very early. |
| [Infisical/infisical](https://github.com/Infisical/infisical) | 26,078 | 84 | **Yes** | Agent pipelines need a secrets and machine-identity plane: secret sync, rotation, dynamic secrets, RBAC, approval flows, audit logs, and leak scanning. |
| [zilliztech/claude-context](https://github.com/zilliztech/claude-context) | 6,126 | 74 | Already deep-dived | Re-confirms retrieval efficiency with evaluation as a cost lever. |
| [vercel-labs/portless](https://github.com/vercel-labs/portless) | 7,202 | 39 | **Yes** | Stable named local URLs reduce local-dev friction for humans and agents. This matters for multi-app testing, OAuth callbacks, screenshots, and parallel dev servers. |
| [nexmoe/VidBee](https://github.com/nexmoe/VidBee) | 8,649 | 176 | No | Useful app, low relevance to agent workflow patterns. Skipped. |
| [tonyantony300/alt-sendme](https://github.com/tonyantony300/alt-sendme) | 7,133 | 84 | Medium | Local-first transfer patterns are getting more polished: P2P, encrypted transfer, resumability, relay fallback. Useful adjacent lesson for privacy-first products. |
| [crbnos/carbon](https://github.com/crbnos/carbon) | 2,026 | 74 | No | Strong vertical SaaS/ERP example, but not relevant enough for this workspace. |

### Deep-Dive Findings

| Repo | Deep Lesson | Integration Target | Confidence |
|------|-------------|--------------------|------------|
| [openai/openai-agents-python](https://github.com/openai/openai-agents-python) | Serious agent apps need runtime primitives beyond "call a model": managed loops, handoffs, tools, guardrails, sessions, tracing, and sandboxed execution. Use direct lower-level model calls for short paths, but use a runtime when tools, state, artifacts, or multi-step work matter. | `docs/ai-product-building.md` | ESTABLISHED (L4 for OpenAI docs, L3 for cross-workspace pattern) |
| [mnfst/manifest](https://manifest.build/docs/introduction) | Cost control is shifting from prompt-level advice to routing infrastructure. Route simple/standard/complex/reasoning tasks to different models, monitor usage, set budget limits, and fall back automatically. | `docs/token-efficient-prompting.md`, `docs/ai-product-building.md` | CONFIRMED (L3) |
| [vercel-labs/portless](https://github.com/vercel-labs/portless) | Stable local URLs are part of agent ergonomics. If tools, screenshots, auth callbacks, and parallel dev servers depend on changing ports, agent runs get brittle. | `docs/ai-product-building.md` | CONFIRMED (L3) |
| [Infisical/infisical](https://github.com/Infisical/infisical) | Secrets, certificates, machine identity, RBAC, audit logs, and leak scanning should be treated as the access-control substrate for agent pipelines. | `docs/ai-product-building.md` | CONFIRMED (L3) |
| [alexzhang13/rlm](https://github.com/alexzhang13/rlm) | Recursive sandboxed inference is worth watching, but not yet a core practice. The important idea is externalizing problem state into an inspectable environment, then iterating over it. | Research watch only | PLAUSIBLE (L2) |

### Combined Learnings

| Combined Pattern | Evidence | Practical Rule |
|------------------|----------|----------------|
| Runtime primitives are becoming the baseline | OpenAI Agents SDK, Swarms, T3 Code | For serious workflows, require loop management, tool dispatch, state, guardrails, tracing, and human handoff. |
| Cost control belongs in routing, not only in prompt wording | Manifest, Claude Context | Track quality, token cost, tool calls, latency, and fallback rate. Do not hard-code the expensive model everywhere. |
| Local development needs stable surfaces | Portless, T3 Code, Thunderbolt | Give agents stable URLs, predictable startup commands, and clear local deployment lanes. |
| Security has to move earlier | Infisical, OpenAI guardrails, Thunderbolt security-audit signaling | Treat secrets, RBAC, audit logs, leak scanning, and guardrails as launch gates, not cleanup tasks. |
| Local-first/privacy-first keeps recurring | Home Assistant, Thunderbolt, AltSendme | Where data sensitivity matters, prefer local control, explicit storage boundaries, and fallback paths. |
| Vertical products are bundling intelligence layers | FinceptTerminal, WorldMonitor, TrendRadar | The reusable product pattern is connectors + workflow UI + monitoring + delivery, not the domain-specific claims. |

### Integration Check

| Finding | Target Doc | Action |
|---------|------------|--------|
| Managed agent runtime baseline | `docs/ai-product-building.md` | Add runtime checklist and direct-API vs runtime decision rule |
| Model routing and budget gates | `docs/token-efficient-prompting.md`, `docs/ai-product-building.md` | Add model-router cost-control pattern |
| Stable named local URLs | `docs/ai-product-building.md` | Add local-dev addressability pattern |
| Secrets and machine identity | `docs/ai-product-building.md` | Add access-plane pattern for agent pipelines |
| Recursive sandboxed inference | Research only | Watch, do not promote yet |

### Sources

- [GitHub Trending Python](https://github.com/trending/python?since=daily)
- [GitHub Trending TypeScript](https://github.com/trending/typescript?since=daily)
- [OpenAI Agents SDK repo](https://github.com/openai/openai-agents-python)
- [OpenAI Agents SDK docs](https://openai.github.io/openai-agents-python/)
- [OpenAI Agents SDK guardrails](https://openai.github.io/openai-agents-python/guardrails/)
- [OpenAI Agents SDK sessions](https://openai.github.io/openai-agents-python/sessions/)
- [Manifest repo](https://github.com/mnfst/manifest)
- [Manifest docs](https://manifest.build/docs/introduction)
- [Portless repo](https://github.com/vercel-labs/portless)
- [Infisical repo](https://github.com/Infisical/infisical)
- [RLM repo](https://github.com/alexzhang13/rlm)
- [Swarms repo](https://github.com/kyegomez/swarms)
