# Free-Tier Agentic Coding Guide

**Use this when your OpenCode Go credits are low and you want to keep agentic workflows running at $0.**

## The Core Insight

The agentic framework (tools, permissions, subagent spawning) is **model-agnostic**. You can run the exact same orchestrator → explorer → worker system on free models. The free models available on OpenCode Zen are genuinely capable coding agents:

| Model | SWE-bench Verified | Context | Best Role |
|-------|-------------------|---------|-----------|
| **MiniMax M2.5 Free** | **80.2%** | 1M | **Orchestrator** — Same coding benchmark as K2.6 |
| **Hy3 Preview Free** | **74.4%** | 256K | **Worker** — Elite free coding, strong reasoning |
| **Trinity Large Preview Free** | **63.2%** | 512K | **Long-context Worker** — Huge context for big docs |

**M2.5 Free matches K2.6 on SWE-bench Verified.** This is not a "dumbed down" fallback — it's a legitimate coding agent.

---

## Quick Toggle: Three Modes

Switch your orchestrator model in `/home/namikaz/.config/opencode/opencode.jsonc` based on your current credit situation:

### Mode 1: Full Go (Quality First)
```json
"agent": {
  "orchestrator": {
    "model": "opencode-go/kimi-k2.6"
  },
  "explorer": {
    "model": "opencode/minimax-m2.5-free"
  },
  "worker": {
    "model": "opencode-go/kimi-k2.6"
  }
}
```
**Use when:** You have plenty of Go credits and want maximum quality.

### Mode 2: Hybrid (Recommended Default)
```json
"agent": {
  "orchestrator": {
    "model": "opencode/minimax-m2.5-free"
  },
  "explorer": {
    "model": "opencode/minimax-m2.5-free"
  },
  "worker": {
    "model": "opencode-go/kimi-k2.6"
  }
}
```
**Use when:** You want to conserve Go credits but keep K2.6 for complex tasks. The orchestrator handles 90% of work directly. K2.6 is only spawned when fresh context is genuinely needed.

### Mode 3: Full Free (Zero Cost)
```json
"agent": {
  "orchestrator": {
    "model": "opencode/minimax-m2.5-free"
  },
  "explorer": {
    "model": "opencode/minimax-m2.5-free"
  },
  "worker": {
    "model": "opencode/hy3-preview-free"
  }
}
```
**Use when:** Go credits are exhausted or you want to run completely free. Trinity Large Free can substitute for Hy3 if you need 512K context.

---

## Choosing the Free Orchestrator Model

| Model | Use As Orchestrator When... |
|-------|----------------------------|
| **M2.5 Free** | You want 1M context, fastest speed (100 TPS), and highest free coding benchmark. Best all-around free orchestrator. |
| **Hy3 Preview Free** | You want stronger reasoning than M2.5 and don't need 1M context (256K is enough). Slightly lower benchmark but more robust on complex tasks. |
| **Trinity Large Free** | You specifically need 512K context for your orchestrator's direct-handling tasks. Slightly lower benchmark (63.2%) but huge context window. |

**Default recommendation:** Start with **M2.5 Free** as orchestrator. It has the highest coding benchmark and 1M context. Only switch to Hy3 if you notice M2.5 struggling with complex multi-step reasoning.

---

## Choosing the Free Worker Model

| Model | Use As Worker When... |
|-------|----------------------|
| **Hy3 Preview Free** | You need a free worker for complex implementation, debugging, or review. 74.4% SWE-bench Verified is elite for a free model. |
| **Trinity Large Free** | You need to process huge documents, massive codebases, or long-context agent loops. 512K context is unmatched in free tier. |
| **M2.5 Free** | You need a fast worker for high-volume tasks. Good enough for most coding, especially with fresh context. |

---

## Tradeoffs and Warnings

### Rate Limits
Free models may have lower requests-per-minute (RPM) limits than Go models. If you hit rate limits:
- Switch to a different free model (M2.5 → Hy3 → Trinity)
- Add a small delay between rapid-fire requests
- Fall back to Go models only for the blocked task

### Data Collection
OpenCode states that free models "may collect data during the free period." 

**Do not use free models for:**
- Proprietary business logic or trade secrets
- Code containing credentials, API keys, or PII
- Sensitive personal projects you wouldn't want logged

**Free models are fine for:**
- Open-source projects
- Learning, tutorials, and exploration
- Public APIs and standard patterns
- General tooling and automation

### Context Window vs. Quality
- **M2.5 Free:** 1M context, 80.2% SWE-bench Verified — best benchmark, huge context
- **Hy3 Preview Free:** 256K context, 74.4% SWE-bench Verified — slightly lower benchmark but stronger MoE architecture
- **Trinity Large Free:** 512K context, 63.2% SWE-bench Verified — lower benchmark but massive context

For most agentic coding, **M2.5 Free is the best free orchestrator.** Use Trinity only when you specifically need the 512K context.

---

## Practical Workflow

1. **Set orchestrator to M2.5 Free** in `/home/namikaz/.config/opencode/opencode.jsonc`
2. **Work normally.** The orchestrator handles most tasks directly.
3. **When you hit a hard problem,** the orchestrator spawns @worker.
4. **Worker uses K2.6** (hybrid mode) or Hy3 (full free mode).
5. **If K2.6 is exhausted,** worker falls back to Hy3 or Trinity.

You don't need to change your workflow. You just change the model assignments.

---

## Example: Switching to Full Free Mode

```bash
# 1. Edit /home/namikaz/.config/opencode/opencode.jsonc
# 2. Change the top-level "model" and the orchestrator model to opencode/minimax-m2.5-free
# 3. Change the worker model only if you want a different fallback lane
# 4. Save and restart OpenCode (or reload config)
# 5. Work normally — same tools, same permissions, same agentic behavior
```

No repo-local `.opencode/agents/` edits are needed. The supported setup keeps agent behavior in the global OpenCode config and lets topic repos stay focused on repo context files.

---

## When to Switch Back to Go

Switch back to K2.6 as orchestrator when:
- Free models are hitting rate limits and slowing you down
- You're working on sensitive code and need data privacy
- The free model is consistently failing on a complex multi-step task
- You have Go credits to burn and want maximum quality

The hybrid mode (free orchestrator + paid worker) is the sustainable default. It gives you 90% cost savings while keeping K2.6 in reserve for the 10% of tasks that need it.

---

## Benchmark Context

Why these free models work for agentic coding:

| Benchmark | M2.5 Free | Hy3 Free | K2.6 (Go) |
|-----------|-----------|----------|-----------|
| SWE-Bench Verified | **80.2%** | 74.4% | **80.2%** |
| AIME 2026 (Math) | ~90%* | ~85%* | **96.4%** |
| Context | **1M** | 256K | 256K |
| Speed | **100 TPS** | ~60 TPS | ~50 TPS |

*Estimated. M2.5 Free is competitive with K2.6 on coding benchmarks. The gap is in math/reasoning, not coding.

**Bottom line:** For agentic coding specifically (read files, edit code, run bash, spawn subagents), M2.5 Free and Hy3 Free are genuinely capable. The bottleneck is rarely model capability — it's usually rate limits or context management.

---

## Summary

| Mode | Orchestrator | Worker | Monthly Cost | Best For |
|------|-------------|--------|-------------|----------|
| Full Go | K2.6 | K2.6 | $10 | Maximum quality, no rate limit concerns |
| **Hybrid** | **M2.5 Free** | **K2.6** | **~$3-5** | **Best balance — 90% free, 10% paid** |
| Full Free | M2.5 Free | Hy3 Free | $0 | Zero cost, occasional rate limits |

**Recommendation:** Switch to Hybrid mode now. Set orchestrator to M2.5 Free. Keep K2.6 for worker only. You'll cut your Go credit burn by ~80% without losing agentic capability.
