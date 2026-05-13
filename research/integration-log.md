# Integration Log

Tracks when research findings are integrated into the knowledge base.

## Format

```
## Integration: YYYY-MM-DD (Day N of cycle)

### Synthesized Findings
[3-day synthesis in my own understanding]

### Updates Made
- [doc name]: Added/Updated [what]
- [doc name]: Added/Updated [what]

### Knowledge Base Impact
[New pattern or lesson worth remembering]

### Next Steps
[Any follow-up research or monitoring needed]
```

## Cycle Tracker

| Cycle | Start Date | End Date | Status |
|-------|------------|----------|--------|
| 1 | 2026-04-15 | 2026-04-17 | Completed |
| 2 | 2026-04-17 | 2026-04-19 | Completed |
| 3 | 2026-04-18 | 2026-04-20 | Completed |
| 4 | 2026-04-19 | 2026-04-21 | Completed |
| 5 | 2026-04-22 | 2026-04-22 | Completed |

## Integration: 2026-04-21 (Focused Model Refresh)

### Synthesized Findings

Model selection should be task-routed, not winner-take-all. The current best practical routing is:

1. Claude Opus 4.7 for the hardest agentic coding and long-running professional work.
2. Claude Sonnet 4.6 as the daily default.
3. GPT-5.4 for OpenAI tool-heavy and broad professional workflows.
4. GPT-5.3-Codex for Codex-style repo editing.
5. Gemini 3.1 Pro for long-context multimodal synthesis.
6. GLM-5.1 for top open-weight coding when hosted or enterprise infrastructure is available.
7. Qwen3.6-35B-A3B, MiniMax M2.7, DeepSeek V3.2, and MiMo-V2-Pro for cost-performance lanes.

### Updates Made

- `model-selection-guide.md`: Rewritten around routing lanes instead of one model leaderboard.
- `research-log.md`: Added 2026-04-21 focused model refresh entry with sources and corrections.

### Correction

The old guide still had a leftover row calling GPT-5.3-Codex an open-weight leader. That was wrong because GPT-5.3-Codex is a closed OpenAI API model. The guide now routes open-weight coding to GLM-5.1 and practical local-ish coding to Qwen3.6-35B-A3B.

### Knowledge Base Impact

The model guide now encodes the main durable lesson: benchmark rank is not enough. Availability, license, provider, cost, harness, and verification matter.

### Next Steps

- Re-check OpenRouter rankings and provider pricing by 2026-05-21.
- Verify any "open-weight" claim against Hugging Face or an official model repo before adding it.

---

## Integration: 2026-04-22 (Starred Repos Research)

### Synthesized Findings

238 starred repos clustered into 12 groups. AI agent tooling (~45 repos) dominates. Key patterns:

1. **Token efficiency is multi-dimensional** --- output compression (caveman 65-75%), input compression (caveman-compress 46%), context rotation (get-shit-done fresh 200k/plan), learned skill compression (hermes-agent, everything-claude-code)

2. **Context rotation is the central engineering problem** --- three solutions: rotation (fresh subagent contexts), compression (keep essentials), search (retrieve on demand)

3. **Multi-agent team pattern** --- gstack (23 roles via slash commands), agency-agents (144 agents, 12 divisions), MetaGPT (role-SOP with message passing)

4. **Self-improvement is emerging** --- hermes-agent creates skills from experience, everything-claude-code evolves instincts with confidence scoring

5. **hermes-agent is the most mature self-improving agent** --- skill creation loop, FTS5 cross-session search, model-agnostic, persistent memory

### Updates Made

- `archive/starred-repos-2026-04-22.md`: Full Phase 1 --- 238-repo table, cluster analysis, top 30 candidates
- `archive/starred-repos-phase2-2026-04-22.md`: Phase 2-3 --- top 10 deep dives, cross-cutting patterns, integration recommendations mapped to 5 docs

### Knowledge Base Impact

The starred repos confirm the workspace is on the right track: context management, token efficiency, and self-improvement are the central unsolved problems. hermes-agent's self-improvement loop is the pattern to study most carefully.

### Next Steps

- Phase 3 deep dives on: hermes-agent skill creation, gstack Conductor, caveman-compress, instinct evolution, wave execution
- Consider integrating specific findings into ai-product-building.md (wave execution, self-improvement loop) and token-efficient-prompting.md (caveman, context rotation)
- Run propagation if docs are updated

---

### Synthesized Findings
Daily research cycle completed. Key findings:

1. **OpenRouter Rankings**: MiniMax M2.7 now at 1.03T tokens (7th). Mimo V2 Pro new with 140% growth.
2. **BenchLM April 2026**: Claude Mythos Preview leads coding at 100% weighted. GPT-5.3 Codex was initially misread as open-weight; corrected below.
3. **MCP Ecosystem**: 84k stars, production-ready with frameworks in TypeScript/Python/Java/Elixir.
4. **Cursor Automations**: Security scanning + CI fixing = agents moving to "code stewardship."

### ERROR CORRECTION (2026-04-19-later)

**Error**: GPT-5.3 Codex listed as "open-weight" --- **INCORRECT**

**What happened**: BenchLM showed GPT-5.3 Codex as "top open-weight coding model" in benchmark comparison. I assumed weights were publicly available. They are not --- it's a closed API model.

**Impact**:
- model-selection-guide.md had wrong info in Quick Decision Matrix and OpenRouter sections
- User could spend resources trying to self-host a closed model

**Correction applied**:
- Quick Decision Matrix: "Open-Weight Coding" now correctly shows **GLM-5.1** (754B, 58.4% SWE-bench Pro, HuggingFace: zai-org/GLM-5.1)
- OpenRouter section: GLM-5.1 added correctly

**Root cause**: Single-source benchmark claim without license verification. Should have checked Hugging Face for weight availability.

**Prevention**: Research prompt updated with:
- Source triangulation (verify against official sources, not just benchmarks)
- Confidence levels (Level 1-4)
- Error impact audit before integration

### Updates Made
- model-selection-guide.md:
  - Added Mimo V2 Pro to Free Alternatives
  - Added Claude Mythos Preview to Quick Decision Matrix (Production Coding leader)
  - Added GLM-5.1 as Open-Weight leader (CORRECTED from GPT-5.3 Codex)
  - Updated Coding Performance table with SWE-bench Pro column
- research-log.md: Added 2026-04-19 entry
- integration-log.md: Recorded cycle 4, error correction, research prompt update
- research-prompt.md: Full verification framework added

### Knowledge Base Impact
Claude Mythos Preview should be the default for production coding. GLM-5.1 is actual open-weight leader.

### Next Steps
- Monitor GLM-5.1 benchmarks as they develop
- Add hardware requirements for open-weight models (RT 4090 / 8x H100)
- Verify any benchmark claims against official sources before next integration

---

## Integration: 2026-04-18 (Cycle 3)

### Synthesized Findings
User requested manual research on 3 URLs: system-design-primer (343k stars), OWASP Top Ten (security), Cursor agent best practices.

**Cursor patterns extracted** (8 key patterns):
1. Plan Mode before coding --- forces clear thinking
2. Let agent find context --- don't over-tag files  
3. Rules (static) + Skills (dynamic) --- context management
4. Long-running loops --- iterate until tests pass
5. Parallel agents with git worktrees --- isolation + multi-model judging
6. Evidence-based Debug Mode --- hypothesis testing
7. TDD with agents --- write tests, confirm fail, then code
8. Git workflows as commands --- reusable automations

**Model benchmarks updated**: Claude Opus 4.7 leads SWE-bench at 87.6%. MiniMax M2.7 (new) ~81%.

### Updates Made
- research-prompt.md: Added model selection guide, manual research section
- model-selection-guide.md: Added MiniMax M2.7, updated benchmarks from April 2026 data
- agent-context-handover.md: Updated to MiniMax M2.7
- research-log.md: Added entry for 2026-04-18 with analysis

### Knowledge Base Impact
Cursor patterns are **directly actionable** and should integrate into:
- ai-product-building.md: Agent workflow patterns (Plan Mode, parallel agents, TDD, hooks)
- daily-prompts.md: "Start with Plans" prompt template
- core-agent-doctrine.md: Evidence-based debugging pattern

### Next Steps
1. Integrate Cursor patterns to ai-product-building.md
2. Add SWE-bench Pro benchmark to model-selection-guide.md
3. Research Terminal-Bench 2.0 for agentic performance

---

## Integration: 2026-04-17 (External Sources Research)

### Synthesized Findings

Researched 5 external sources for AI agent engineering:

1. **Refactoring.Guru** (22 design patterns) --- Direct application to agent architecture
2. **OWASP Top 10:2025** --- Security risks for AI agents (prompt injection, access control)
3. **IBM AI Agent Security** --- Agent-specific threat model and mitigation
4. **System Design Primer** --- Scalability, CAP, distributed systems for agents
5. **OpenMAIC** --- Multi-agent orchestration patterns

### Updates Made

- **core-agent-doctrine.md**: Added "Security-First Agent Design" section based on OWASP + IBM research --- covers prompt injection, excessive agency, memory poisoning, RBAC, guardrails, security checklist

- **ai-product-building.md**: Added "Agent Architecture Patterns" section based on Refactoring.Guru --- covers behavioral patterns (Strategy, Command, Observer, State, Mediator), structural patterns (Adapter, Builder, Facade, Proxy), SOLID principles for agents, system design for agents (from System Design Primer)

### Knowledge Base Impact

- Core doctrine now includes security as a first-class principle
- Product building guide now includes design patterns for agent architecture
- Research integration is actively working --- external sources analyzed and integrated within same session

### Next Steps

- Consider adding multi-agent prompts to daily-prompts.md based on OpenMAIC patterns
- Monitor for new agent-specific security frameworks (OWASP LLM Top 10)

---

<!-- Integration entries go below -->

## Integration: 2026-04-15 (Day 1 of Cycle 1)

### Synthesized Findings

After reviewing research entries from Apr 14-15, two significant patterns emerged:

1. **Token efficiency breakthroughs** (LLMLingua, TurboQuant) directly improve the token-efficient-prompting.md doc --- these are production-ready techniques that can reduce costs 30-90%.

2. **Tool landscape is shifting** --- Visual builders (Langflow, Dify) and TypeScript frameworks (VoltAgent) are gaining significant traction. The ai-product-building.md needs a "Trending Tools" section to help builders make informed choices.

### Updates Made

- **token-efficient-prompting.md**: Added "2026 Research Updates" section with LLMLingua, LongLLMLingua, and TurboQuant --- the three major token efficiency breakthroughs from April 2026 research.

- **ai-product-building.md**: Added "2026 Research: Trending Tools" section with:
  - Visual/No-Code Builders table (Langflow, Dify, n8n, Flowise)
  - Agent Frameworks table (AutoGPT, MetaGPT, CrewAI, AutoGen, VoltAgent)
  - Coding Agents table (OpenClaw, Claude Agent SDK, Browser-use)
  - Decision Framework for Tool Selection

### Knowledge Base Impact

- Token efficiency guidance now includes 2026's most significant compression techniques
- Product builders have a reference for choosing the right tools based on their needs
- The research-to-integration loop is now active

### Next Steps

- Monitor VoltAgent (TypeScript, growing fast) --- may warrant deeper analysis in future cycles
- Track Hermes Agent for self-improving patterns (noted in Apr 14 research)

---

## Integration: 2026-04-15 (Manual Run - User-Provided Repos)

### Synthesized Findings

User provided 5 additional repos to analyze. Key findings:

1. **andrej-karpathy-skills** (36.3k stars): Four principles addressing LLM failure modes --- directly improves prompting
2. **gstack** (72.7k stars): Virtual engineering team with 23 specialized skills --- transforms single agent to team
3. **everything-claude-code** (156k stars): Complete agent harness optimization across 12 languages
4. **MetaGPT** (67.1k stars): Multi-agent framework simulating software company
5. **coconut** (1.6k stars): Facebook Research --- more research than practical, skip

### Updates Made

- **core-agent-doctrine.md**: Added "2026 Research: LLM Coding Pitfalls (Andrej Karpathy)" section with four principles (Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution) --- directly maps to existing doctrine principles

- **ai-product-building.md**: Added:
  - "Virtual Engineering Team Pattern" section based on gstack --- 23 specialized skills, sprint workflow
  - "Complete Agent Harness Systems" section based on everything-claude-code --- 38 agents, 156 skills, cross-harness
  - "Integration: Which Tool for What" decision table

### Knowledge Base Impact

- Core agent doctrine now has practical prompting guidance from Karpathy's observations
- Product building guide now has comprehensive tool comparison (gstack, everything-claude-code, MetaGPT)
- Research integration is actively working --- user-provided repos analyzed and integrated same day

### Next Steps

- These three tools (Karpathy skills, gstack, everything-claude-code) are significant enough to warrant ongoing monitoring
- Consider adding gstack-style skills to daily-prompts.md as reusable prompt patterns

---

## Integration: 2026-04-16 (Cognitive Identity Research)

### Synthesized Findings

Research into how humans maintain cognitive abilities while AI tools accelerate. Key finding: the gap between tool velocity (exponential) and human cognition (linear) creates four threats --- cognitive atrophy, illusion of knowledge, self-reinforcing dependency, and lost situational awareness. Each has strong empirical evidence.

### Updates Made

- **cognitive-identity.md**: Added five research-backed sections:
  - "Research-Backed Risks" --- Desirable Difficulty, Cognitive Offloading, Deskilling Evidence, Digital Amnesia, The Four Threats
  - "Product Design: Building AI That Amplifies, Not Replaces" --- Augmentation vs. Replacement framework, design principles table, product building applied section
  - "The Co-Evolution Principle" --- Miton & Jackson (2026) framework
  - Full Sources section with 13 academic citations

### Knowledge Base Impact

- Cognitive identity doc now has empirical evidence backing its practices
- Product building guide has a direct connection to cognitive preservation (one-page spec, reliability thresholds, 5-user validation)
- The key design question ("Does this make the human better at the task, or unnecessary for it?") connects to core-agent-doctrine's "Verify Aggressively" principle

### Next Steps

- Monitor for new deskilling studies (especially coding-specific ones)
- Consider adding cognitive hygiene practices to daily-prompts.md

---

## Integration: 2026-04-15 (Retro-Research from Pre-Integration Period)

### Synthesized Findings

Re-researched repos that were documented before the integration system was established. Found three significant patterns that warrant integration:

1. **Hermes Agent** --- Self-improving agent paradigm (85k+ stars)
2. **OpenClaw** --- Local-first privacy agent (349k stars)
3. **VoltAgent** --- TypeScript-first framework (7,993+ stars)

### Updates Made

- **ai-product-building.md**: Added three new deep-dive sections:
  - **"Self-Improving Agents"** --- Hermes Agent details, self-evolution ecosystem, why "agents that improve themselves" matters
  - **"Local-First Privacy Agents"** --- OpenClaw details, privacy/data sovereignty, cost comparison table
  - **"TypeScript Agent Framework (Deep Dive: VoltAgent)"** --- VoltAgent features, TypeScript value proposition, use cases

### Knowledge Base Impact

- Product building guide now has comprehensive coverage of agent paradigms: self-improving, local-first privacy, TypeScript-first
- Decision framework expanded with Hermes Agent (self-improving) and OpenClaw (privacy-first) as distinct categories

### Next Steps

- These three patterns represent major shifts in agent thinking --- worth noting for ongoing monitoring
- Consider: How would product building change when using self-improving agents vs static agents?

---

## Integration: 2026-04-17 (Trending Repos Research)

### Synthesized Findings

Researched 16 trending repos from April 2026. Key findings:

1. **Memory systems are maturing** --- MemPalace (47k stars) brings benchmarking to memory evaluation
2. **Type safety coming to agents** --- Pydantic-AI brings software engineering practices to agent dev
3. **Context engineering becoming discipline** --- get-shit-done (53.9k stars) codifies meta-prompting
4. **Vectorless RAG emerging** --- PageIndex challenges vector embedding orthodoxy
5. **MCP becoming standard** --- Dify and n8n now MCP-native

### Updates Made

- **ai-product-building.md**: Added/updated:
  - Visual/No-Code Builders table (Dify 138k, n8n 184k)
  - Agent Frameworks table (Google ADK Python 19k, Pydantic-AI 16.4k)
  - Multi-Agent Harnesses section (Deer-Flow, AgentScope)
  - Memory Systems section (MemPalace, MemOS, OpenViking)
  - Coding Agents section (crush, awesome-claude-code)
  - New Paradigm: Vectorless RAG (PageIndex)
  - Updated Decision Framework table

- **token-efficient-prompting.md**: Added LMCache to KV Cache Compression section

- **core-agent-doctrine.md**: Added Context Engineering Discipline section based on get-shit-done

### Knowledge Base Impact

- ai-product-building.md now covers: workflow platforms, frameworks, multi-agent harnesses, memory systems, coding agents, and new paradigms
- token-efficient-prompting.md now has 3 KV cache solutions (TurboQuant, LMCache)
- core-agent-doctrine.md now includes context engineering as a learnable discipline

### Key Insight

**The maturity signal**: Memory systems getting benchmarked, type safety spreading to agents, and meta-prompting becoming codified = the agent engineering discipline is maturing beyond "clever prompts."

---

## Integration: 2026-04-16 (Cognitive Identity Gaps Filled)

### Synthesized Findings

Identified 9 gaps in cognitive-identity.md during earlier research. Completed the remaining 6 gaps:

1. ✅ Daily habits (specific practices) --- Added Daily and Weekly Practices section with specific 15-min routines
2. ✅ Team dimension --- Added Team Cognitive Identity section covering shared patterns and team practices
3. ✅ Emotional/psychological --- Added section covering acceleration anxiety, imposter syndrome, dependency shame
4. ✅ Concrete benchmarks --- Added 5 testable benchmarks with tracking table
5. ✅ "AI first" beginner trap --- Added section explaining the pattern and remediation path
6. ✅ Practical prompts --- Added prompts for critical thinking, learning, decision-making, skill maintenance

### Updates Made

- **cognitive-identity.md**: Added 6 new sections:
  - **"Daily and Weekly Practices"** --- Minimum viable practice (15 min/day), practice stack tables
  - **"Team Cognitive Identity"** --- Signs of team-level atrophy, team practices for cognitive health
  - **"Emotional and Psychological Dimensions"** --- Anxiety, imposter syndrome, dependency shame, recovery path
  - **"Concrete Benchmarks"** --- 5 testable benchmarks (Debugging, Explanation, Prediction, Solo Hour, Teaching) with pass/fail criteria
  - **"The 'AI First' Beginner Trap"** --- Pattern explanation, Foundation First Principle, remediation path
  - **"Practical Prompts for Maintaining Cognitive Identity"** --- Specific prompts for critical thinking, learning, decision-making, skill maintenance

### Knowledge Base Impact

- cognitive-identity.md is now comprehensive --- all 9 identified gaps have been addressed
- Document now covers: risks, framework, practices, team, emotions, benchmarks, traps, and practical tools
- Ready for promotion to other repos via propagate templates

### Key Insight

**The golden rule for AI interaction**: "Use AI to think with, not think for you." Every interaction should leave you more capable, not more dependent.

---

## Integration: 2026-04-17 (Learning Science Research)

### Synthesized Findings

Researched human learning science and its application to AI prompting:

1. **Cognitive Load Theory** --- Working memory limits apply to context windows; CLT principles map to prompt design
2. **Retrieval Practice / Testing Effect** --- "Verify your answer" prompts improve AI reasoning the same way testing improves human learning
3. **Spaced Repetition** --- Iterative prompting, curriculum learning
4. **Active Recall** --- Chain-of-thought is the AI equivalent

Key insight: **No existing literature connects cognitive science to prompting** --- this is a synthesis opportunity.

### Updates Made

- **token-efficient-prompting.md**: Added "Cognitive Load Theory for Prompts" section --- maps CLT principles (intrinsic/extraneous/germane load, chunking, worked examples) to prompt design
- **daily-prompts.md**: Added "Retrievation Practice for AI (Testing Effect)" section --- verification prompts that leverage the testing effect

### Knowledge Base Impact

- Learning science is now integrated into the knowledge base
- Practitioners can now apply evidence-based learning principles to prompting
- The connection between "test yourself" (human) and "verify your answer" (AI) is now documented

### Key Insight

**The Testing Effect for AI**: Just as humans learn better by retrieving than re-reading (80% vs 36% retention in Roediger & Karpicke 2006), AI outputs improve when forced to verify/reason. "What could be wrong?" is the prompting equivalent of retrieval practice.

---

## Integration: 2026-04-21 (Trending Repos Deep Dive)

### Synthesized Findings

Trending scan today surfaced a useful split:

1. High-noise popularity repos (interesting but not directly reusable for this workspace).
2. High-signal workflow repos that directly improve agent operations.

The strongest reusable patterns came from:
- `zilliztech/claude-context` (retrieval efficiency with evaluation discipline),
- `thunderbird/thunderbolt` (explicit production-readiness signaling),
- `HKUDS/RAG-Anything` (parser-pluggable multimodal ingestion),
- `sansan0/TrendRadar` (schedule/filter/channel decoupling with fallback behavior).

### Updates Made

- `research/research-log.md`:
  - Added `2026-04-21 (GitHub Trending Deep Scan)` entry with trending snapshot, deep-dive analysis, confidence levels, and source links.
- `docs/token-efficient-prompting.md`:
  - Added `Retrieval Efficiency via MCP Code Context (2026-04-21)` section with practical guidance and reproducibility caution.
- `docs/ai-product-building.md`:
  - Added `2026-04-21: GitHub Trending Deep-Dive Patterns` section:
    - production readiness signaling,
    - retrieval stack benchmarking,
    - parser-pluggable multimodal ingestion,
    - operations decoupling + fallback.

### Knowledge Base Impact

The repo now captures a stronger operations lesson: **token efficiency is not just prompt brevity**. Retrieval design, deployment signaling, and fallback-aware workflow architecture materially affect quality, cost, and reliability.

### Next Steps

- Re-run trending deep scan weekly and track whether these repos keep shipping or flatten out.
- Validate retrieval-efficiency claims on one internal representative workflow before treating token savings as expected baseline.

---

## Integration: 2026-04-21 (Language-Filtered Trending: Python + TypeScript)

### Synthesized Findings

The language-filtered pass confirmed that the strongest reusable lessons are infrastructure patterns, not individual app ideas.

Deep-dived:
- `openai/openai-agents-python` for managed runtime primitives.
- `mnfst/manifest` for model-routing cost control.
- `vercel-labs/portless` for stable local development URLs.
- `Infisical/infisical` for secrets, machine identity, and auditability.
- `alexzhang13/rlm` as a research watch item for recursive sandboxed inference.

The combined lesson: strong agent products need a runtime layer, a routing/cost layer, a stable local-dev surface, and an access-control layer. Prompt quality still matters, but infrastructure is now doing more of the reliability work.

### Updates Made

- `research/research-log.md`:
  - Added `2026-04-21 (Language-Filtered GitHub Trending Scan: Python + TypeScript)`.
  - Included tables showing every repo looked at, which repos were deep-dived, what was learned from each, and combined learnings.
- `docs/token-efficient-prompting.md`:
  - Added `Model Routing as Cost Control (2026-04-21)` based on Manifest.
- `docs/ai-product-building.md`:
  - Added `2026-04-21: Language-Filtered Trending Patterns` covering:
    - managed agent runtime baseline,
    - model router as product infrastructure,
    - stable local URLs for agent work,
    - secrets and machine identity plane,
    - recursive sandboxed inference as watch-only.

### Knowledge Base Impact

The workspace now separates two cost/reliability layers:

1. Prompt and retrieval efficiency: smaller or better context.
2. Runtime infrastructure efficiency: routing, fallback, session storage, tracing, local URL stability, and access control.

This makes future product guidance more practical: the answer is not only "write better prompts", but "build the operating layer that keeps prompts from carrying all the burden."

### Next Steps

- Re-check Manifest-style routing only after trying it on one repeated workflow with clear quality metrics.
- Keep RLM as research watch, not doctrine, until there is stronger production evidence.
- In future trending passes, report the looked-at/deep-dived/learned table immediately after each research batch.
