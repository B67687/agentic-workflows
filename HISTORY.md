# History

Active session ledger for the AI Prompting workspace.

Full April 2026 history before the optimization pass is preserved at [archive/history-2026-04.md](archive/history-2026-04.md).

Newest entries stay here. Older full entries should move to archive files, with compact summaries left in this ledger.

---

## 2026-04-23

### Session 44 - Cognitive Identity & Learning Thread

**Intent:** User wanted a full session history documenting the decision threads from a deep conversation about AI coding tools, learning, and cognitive identity. The requested format: user intent → assistant improvement → user improvement → final agreement → implementation, with detailed timestamps.

**What Happened:** Created `44-HISTORY-WITH-CODEX.md` with 7 decision threads covering: (1) AI coding tools feeling like spectator sport, (2) understanding MCP/n8n/RAG, (3) the learning-efficiency paradox, (4) research integration for AI autonomy practices, (5) fear of AI acceleration and being left behind, (6) the "slow learner" core belief, and (7) the session history documentation itself. Research findings integrated into `research/research-log.md`. No major repo restructuring occurred, but durable conceptual decisions about AI usage, learning strategy, and cognitive identity were made.

**Finalised:** `44-HISTORY-WITH-CODEX.md` now documents the full decision chain for this session. `research/research-log.md` updated with AI autonomy and learning research.

**Learnt:** The user's core concern is not tool selection but identity preservation: not becoming a spectator to their own work. The "slow learner" belief is protective armor that prevents the struggle necessary for growth. The most useful framing is "ownership > efficiency" and "don't quit" rather than "learn faster."

---

### Session 44 - Late History Handover

**Intent:** Create a detailed late-thread handover history so another agent can understand the user's intent, assistant proposals, user corrections, final agreements, and implemented repo state.

**What Happened:** Created `LATE-HISTORY-WITH-CODEX.md` with timestamp provenance, a master timeline, decision threads in the user's requested intent/improvement/correction/agreement/implementation shape, final operating assumptions, implementation map, and next-agent advice. The file covers the chain from access-aware model routing and GPT-5 nano placement through NoFaceScanApp propagation, content-folder rules, workflow-vs-scripts separation, session-state startup rules, root-drift cleanup, model-routing refinement, OpenCode agent routing, skills, git initialization, and final hub optimization. While verifying, fixed stale research references from `research/archived-findings.md` to `docs/research-findings.md`.

**Finalised:** `LATE-HISTORY-WITH-CODEX.md` now sits beside the earlier handover files as the detailed narrative handoff for the late redesign thread.

**Learnt:** Dense redesign work needs a decision-thread record, not just per-file changes. The most useful unit is: user intent -> assistant structure -> user correction -> final agreement -> implemented files.

---

### Session 43 - Middle History Handover

**Intent:** Create a detailed handover history for the middle Codex phase so another agent can understand the intent, refinements, agreements, and implementations in order.

**What Happened:** Created `MIDDLE-HISTORY-WITH-CODEX.md` with a chronological narrative from the interrupted GitHub trending handoff through structure cleanup, system overview, repository optimization, command wrappers, WSL strategy, research methodology, model routing, PR communication patterns, and the native OpenCode agentic system. Added timestamp caveats because exact wall-clock times were not preserved for every session.

**Finalised:** Root handover file plus README link and audit exemption for the requested uppercase filename.

**Learnt:** The most useful history format for this repo is not a raw changelog. It is the chain: user intent -> Codex structure -> user correction -> final agreement -> implementation.

## 2026-04-22

### Session 38 - OpenCode Go Model Comparison

**Intent:** Determine if Kimi K2.6 is a pure upgrade from MiniMax M2.7, and compare all Go models for cost-efficiency.

**What Happened:** Researched MiniMax M2.7, Qwen 3.6 Plus, MiMo V2 Pro/Omni, and GLM 5.1 benchmarks and pricing. Built head-to-head comparison table. K2.6 beats M2.7 on every benchmark (SWE-Pro +2.4, AIME +6.6, GPQA +3.5, HLE +6.7). However, M2.7 gives ~3x more requests per dollar on Go (3,400 vs 1,150 per 5hr). GLM 5.1 is most expensive (880 req/5hr) — confirms user's credit drain concern.

**Finalised:** Updated model-selection-guide.md with OpenCode Go comparison table, K2.6 vs M2.7 section, and per-model routing rules.

**Learnt:** K2.6 is strictly better quality than M2.7 but not a pure upgrade if volume is the priority. Best routing: K2.6 as default, M2.7 for bulk drafts, Qwen 3.6 Plus as middle ground. Avoid GLM 5.1 on Go unless you need its specific benchmark edge.

---

## 2026-04-22

### Session 39 - Full OpenCode Go Model Analysis

**Intent:** Expand research to all 10 OpenCode Go models with focus on speed and token efficiency.

**What Happened:** Researched all Go models — GLM-5/5.1, Kimi K2.5/2.6, MiMo-V2-Pro/Omni, MiniMax M2.5/2.7, Qwen3.5/3.6 Plus. Key findings: MiniMax M2.5 Lightning hits 100 TPS (fastest in Go), Qwen3.5 Plus delivers 10,200 req/5hr (highest volume), K2.6 3x promo temporarily makes it volume-competitive (~3,450 req/5hr). Post-promotion, M2.5 becomes the speed+volume king while K2.6 stays quality king. GLM-5.1 remains most expensive at 880 req/5hr.

**Finalised:** Replaced basic OpenCode Go table in model-selection-guide.md with comprehensive guide: 10-model comparison, benchmark table, speed analysis, token efficiency ratings, individual profiles, routing cheat sheet, post-promotion strategy.

**Learnt:** M2.5 is the hidden gem — 100 TPS + 80.2% SWE-V + 6,300 req/5hr makes it competitive on speed, quality, AND volume. User's keepers (GLM-5.1, K2.6, M2.7) are solid; M2.5 and Qwen 3.6 Plus are worthy additions.

---

## 2026-04-22

### Session 40 - Unified Multi-Provider Model Analysis

**Intent:** Analyze ALL accessible models across GitHub Copilot, Google Gemini, DeepSeek, Qwen API, and OpenCode Go.

**What Happened:** Researched Copilot premium request multipliers (Opus 4.7 = 7.5x, Sonnet 4.6 = 1x), Gemini AI Studio free tier (10–15 RPM, no monthly cap), DeepSeek API ($0.252/$0.378 per 1M + free chat app), Qwen API and local options (Qwen3.6-35B-A3B Apache-2.0). Built unified comparison: for 1,000 prompts/month, cheapest quality is Gemini 3.1 Pro (free), then M2.5 Go (~$2), then DeepSeek API (~$5). Copilot Student gives 300 premium requests — 40 Opus 4.7 prompts or 300 Sonnet 4.6.

**Finalised:** Added 5 new sections to model-selection-guide.md: Copilot deep dive, Gemini free tier, DeepSeek API+free, Qwen beyond Go, unified master comparison with task-based routing across all providers.

**Learnt:** The free tier ecosystem is stronger than expected. Gemini AI Studio free = 14,400 requests/day. DeepSeek Chat is free. Copilot Student = $0 for 300 premium requests. User's optimal stack: Copilot (40x Opus 4.7 for hardest tasks) + Gemini free (research/multimodal) + Go M2.5 (speed/volume) + K2.6 (quality during promo) + M2.7 (harness engineering).

---

## 2026-04-22

### Session 41 - PR Sequence Diagram Pattern

**Intent:** Integrate sequence diagrams in PRs as a communication pattern and propagate to all topic folders.

**What Happened:** Added PR Communication Patterns section to docs/ai-product-building.md covering when to use sequence diagrams (behavioral PRs: async workflows, multi-service interactions, state machines), when to skip them (trivial refactors), Mermaid syntax example, and the rule of thumb: "add a diagram when explaining behavior takes more text than drawing the interaction." Also added the pattern to propagate-templates/git-github-best-practices.template.md under Pull Request Craft. Ran full propagation to all 23 folders (69 file operations).

**Finalised:** docs/ai-product-building.md, propagate-templates/git-github-best-practices.template.md, 23 topic folder git-github-best-practices.md files updated.

**Learnt:** Sequence diagrams are selective high-signal — valuable for behavioral PRs, noise for trivial ones. Mermaid's native GitHub rendering makes it zero-friction. Propagation reached all 23 active folders successfully.

---

## 2026-04-22

### Session 42 - Agentic Token-Efficiency System

**Intent:** Cut token burn 40–60% without losing continuity or quality.

**What Happened:** Built agentic workflow system with Orchestrator (K2.6) + 3 specialist agents (Explorer/M2.5, Drafter/M2.7, Reviewer/GLM-5.1). All on OpenCode Go. Key behaviors: brevity by default, proactive checkpointing every 10 turns, automatic routing by trigger words, context compression for subsessions, fallback chains, quality guardrails. Created docs/agentic-workflows.md. Updated 4 existing docs. Propagated to all 23 folders.

**Finalised:** docs/agentic-workflows.md, docs/token-efficient-prompting.md, docs/session-checkpoint.md, docs/model-selection-guide.md, AGENTS.md. 69 file operations propagated.

**Learnt:** User's core fear was context loss when switching models. Agentic subsessions solve this — compressed handoffs preserve continuity while fresh context maintains quality. Fixed assignment (not dynamic) is simpler and predictable. Brevity mode must be default, not opt-in.

---

## 2026-04-22

### Session 34 - Research Methodology Doc

**Intent:** Ensure agents use authoritative sources, not random ones.

**What Happened:** Created 5-tier source hierarchy (vendor docs → academic → expert practitioners → community → anonymous). Built evaluation checklist, triangulation rules, and AI-specific source pitfalls.

**Finalised:** docs/research-methodology.md — integrated into README.md, workspace-system-overview.md, and research-log.md.

**Learnt:** SEO rankings don't equal credibility. "Internal testing" benchmarks are unverifiable. Model name appearing in results doesn't mean benchmarks are accurate. 6-month-old AI docs can be dangerously outdated.

---

### Session 33 - Terminal Strategy Guardrails

**Intent:** Resolve PowerShell vs WSL for this workspace.

**What Happened:** Decided PowerShell stays as source of truth for mutating hub automation. Native WSL commands serve as read-only inspection layer. Created shared Windows/WSL tooling guide.

**Finalised:** docs/repo-tooling.md, scripts/ws.sh, updated ws.ps1 validate with terminal-strategy probe.

**Learnt:** PowerShell is the right mutating layer for Windows-filesystem workspace. WSL native commands (git, rg) better for read-only inspection than requiring PowerShell inside WSL.

### Session 32 - Workspace Command Wrapper

**Intent:** Turn repeated orientation, validation, search, research, and propagation commands into one hardened entry point.

**What Happened:** Created ws.ps1 with help, status, hotspots, validate, search, research, and propagate commands. Added test-ws.ps1 for command matrix validation.

**Finalised:** scripts/ws.ps1, scripts/test-ws.ps1, updated AGENTS.md/README.md/workspace-system-overview.md.

**Learnt:** A unified entry point reduces friction for common operations. Read-only mutation guards prevent accidental destructive calls in the wrapper.

---

### Session 31 - Repository Optimization

**Intent:** Optimize cold-start cost while preserving history and research value.

**What Happened:** Archived pre-optimization HISTORY.md, research-log.md, and prompt-templates.md. Split prompt library into docs/prompt-library/. Compressed hot-path files. Upgraded audit guardrails for recursive scanning.

**Finalised:** docs/prompt-library/, archive/ originals, compressed hot-path files.

**Learnt:** Hot-path files need to stay compact. Archive old full content; keep current ledger lean.

---

### Session 30 - Overview Second Pass

**Intent:** Tighten workspace system overview into faster cold-start protocol.

**What Happened:** Rewrote workspace-system-overview.md around 30-second read, fast startup protocol, hub-vs-topic distinction. Normalized hub startup order across AGENTS.md, README.md, and CONTEXT.md.

**Finalised:** docs/workspace-system-overview.md (tightened), updated README.md and quality-standards.md.

**Learnt:** Startup order matters — session-state first, then rules, then system map prevents redundant scans.

### Session 29 - Workspace System Overview

**Intent:** Create a plain-language map of what the hub does and how its parts fit together.

**What Happened:** Created docs/workspace-system-overview.md as the fast system-level orientation file. Linked it from README.md, AGENTS.md, and CONTEXT.md. Documented the core model: central brain + distribution system + live workflow state.

**Finalised:** docs/workspace-system-overview.md.

**Learnt:** A plain-language first-pass map reduces cold-start cost significantly. Deep docs stay linked, not embedded.

---

### Session 28 - Root Drift Cleanup

**Intent:** Analyze root-drift findings, remove obvious generated/stale artifacts, move safe content into canonical content folders.

**What Happened:** Moved legacy content into content folders (bulk-crap-uninstaller, computer-organisation-and-architecture, fluent-search-manifest, unigetui). Removed generated/stale artifacts (temp_logs.zip, .build-check, stray audit-folder-quality.md copies). Identified 2 items needing manual decision.

**Finalised:** Cleaned root structure, confirmed 2 pending manual items (temp_extras, opencode-content).

**Learnt:** Not all root content is drift — active git clones and project roots need case-by-case judgment.

---

## Foundation Highlights

These entries are summarized here because they explain why the workspace looks the way it does. Full details remain in the respective archive files.

| Session | Durable importance |
|---|---|
| Sessions 1–11 + earlier | **Full record pending user input.** See [archive/early-history.md](archive/early-history.md) once early history is provided. |
| Session 12–15 | [archive/history-2026-04.md](archive/history-2026-04.md) |
| Session 16 | Created the repository compression protocol: similar content is not automatically redundant. |
| Session 18 | First major `AGENTS.md` compression, proving the hub contract should be an index plus rules, not a knowledge dump. |
| Sessions 20-21 | Refined access-aware model routing and added NoFaceScanApp to propagation. |
| Session 22 | Established the research -> integrate -> propagate cycle for GitHub trending research. |
| Session 23 | Language-filtered trending research added repo-by-repo reporting tables and combined learnings. |
| Session 24 | Visualization and proactive context handover became explicit workflow patterns. |
| Session 25 | Starred repo research found context rotation, compression, multi-agent teams, and self-improving agent patterns. |

---

## Archive Index

| Archive | Contents |
|---|---|
| [archive/history-2026-04.md](archive/history-2026-04.md) | Full pre-optimization April history, including early formation details. |
| [archive/early-history.md](archive/early-history.md) | **Early session history (Sessions 1–11 and earlier).** Full details preserved for reference. Currently placeholder — to be filled once user provides the actual history. |
| [archive/research-log-2026-04.md](archive/research-log-2026-04.md) | Full pre-optimization research log. |
| [archive/prompt-templates-2026-04-pre-split.md](archive/prompt-templates-2026-04-pre-split.md) | Exact prompt template file before splitting into `docs/prompt-library/`. |
| [archive/README.md](archive/README.md) | Archive conventions and raw snapshot policy. |

---

## Template For Future Sessions

```markdown
### Session N - Short Title

**Intent:** What was the goal or problem being addressed.

**What Happened:** The actual sequence — what was tried, what didn't work, what changed direction.

**Finalised:** What was completed and where it lives.

**Learnt:** Key insight that should change future behavior.
```

Notes:
- "What happened" is not a task list — it's the narrative arc including dead ends and pivots
- Accuracy over completeness: if a back-and-forth didn't produce a durable change, skip it
- Each entry should be readable in under 60 seconds
- If more detail is needed for a complex session, link to an archive file
- "Learnt" is the most valuable part — it enables compound growth
- Entries older than 2 weeks should be summarised and moved to archive if they exceed ~15 lines

---

## Session Archives

| Session | File | Description |
|---------|------|-------------|
| session-44 | `SESSION-44-HISTORY-WITH-CODEX.md` | Full decision chain record — intent → proposal → correction → agreement → implementation. Complete record of workspace standardization across 21 folders. |
