# Model Selection Guide (refreshed 2026-04-22)

Use this when choosing which model to use for work right now. The simple rule:

**Match the model to the job. Do not chase one universal winner.**

The April 2026 market has split into lanes:
- Claude Opus 4.7: hardest agentic coding and professional reasoning
- Claude Sonnet 4.6: daily serious work, best balance
- GPT-5.4: broad OpenAI tool ecosystem, long-context professional work
- GPT-5.3-Codex: agentic coding inside Codex-like harnesses
- Kimi K2.6: strongest open-source agentic model, beats GPT-5.4 on SWE-bench Pro and agent swarm benchmarks
- Gemini 3.1 Pro: long-context, multimodal, complex synthesis
- GLM-5.1: strongest verified open-weight coding option, but huge
- Ling 2.6 Flash: fast free agentic model (340 tokens/s), but low coding benchmarks
- MiniMax M2.7 / Qwen3.6 Plus: cost-performance champions on OpenCode Go
- Qwen3.6-35B-A3B / DeepSeek V3.2 / MiMo-V2-Pro: additional cost lanes

---

## Your Current Quotas

Known from this workspace. Verify inside the actual product before relying on exact daily limits.

| Model | Daily Limit | Use It For |
|-------|-------------|------------|
| **Claude Opus 4.7** | 144k | Hard debugging, long-running agentic work, deep review |
| **Claude Sonnet 4.6** | 200k | Default daily professional coding and writing |
| **Gemini 3.1 Pro Preview** | 128k | Long-context research, multimodal analysis, science/reasoning |
| **GPT-5.2 Codex** | 400k | Coding-heavy workflows if 5.3 is not available |
| **GPT-5.4** | 400k | Broad tool-heavy work, long-context professional tasks |

## Access-Aware Routing For This Setup

Local scan on 2026-04-21 confirmed:
- GitHub CLI is logged in as `B67687`.
- OpenCode has credentials for OpenRouter, GitHub Copilot, OpenCode Go, and Google.
- `opencode models` could not be enumerated because OpenCode hit a local SQLite WAL checkpoint error. Treat provider access as confirmed, but check `/models` in the TUI after the local DB issue is cleared.

The practical answer:

| Lane | Best Pick | Why |
|------|-----------|-----|
| **Daily default** | Claude Sonnet 4.6 through GitHub Copilot | Best quality-to-quota balance. Strong enough for most coding, writing, refactors, and planning. |
| **Hardest work** | Claude Opus 4.7 through Copilot or Zen | Strongest reasoning lane, but expensive. Use for stuck bugs, final reviews, architecture, and high-risk edits. |
| **Agentic repo editing** | GPT-5.3-Codex / GPT-5.4 through Copilot or Zen | Best fit when the task is patch-heavy, terminal-heavy, or needs tool discipline. |
| **Long-context free API** | Gemini 3.1 Pro / Gemini 2.5 Pro through Google AI Studio | Best free/API lane for big docs, synthesis, multimodal input, and research. Free tier limits are account/project-specific, so check AI Studio before a long run. |
| **High-volume cheap coding** | OpenCode Go: **Kimi K2.6**, MiniMax M2.7, Qwen3.6 Plus | Kimi K2.6 beats GPT-5.4 on agentic benchmarks (SWE-bench Pro +0.9, DeepSearchQA +13.9). ~1,150 requests per 5 hours. Go is $5 first month, then $10/month. MiniMax M2.7 gives ~3,400 req/5hr for higher volume at lower quality. |
| **Free coding fallback** | OpenCode Zen free models: MiniMax M2.5 Free, **Ling 2.6 Flash** (limited time), Nemotron 3 Super Free, Big Pickle | Ling 2.6 Flash is fast (340 tokens/s) but has low coding benchmarks (23.2% artificial-analysis-coding). Use for exploration only, not production coding. |
| **Free worker fallback** | GPT-5 nano through OpenCode Zen | Better for summarization, classification, extraction, ranking, and small structured transforms than full coding-agent work. |
| **Editor alternative** | Cursor Student if eligible | One free year of Cursor Pro with $20/month included usage. Worth claiming if you have a matching `.edu` email, but not necessary if OpenCode is your main workflow. |

### Is OpenCode Zen Worth Paying For?

Probably not as the first paid upgrade, because OpenCode Go already gives you the main open coding models cheaply and your GitHub Education/Copilot lane gives you frontier models.

Zen becomes worth paying for when:
- You regularly exhaust Copilot's 300 monthly premium requests.
- You want direct pay-as-you-go access to Claude Opus 4.7, Sonnet 4.6, GPT-5.4, GPT-5.3-Codex, or Gemini 3.1 Pro inside OpenCode.
- You want a spending cap and one gateway instead of separate provider accounts.
- You need a frontier model inside OpenCode after GitHub Copilot quota is low.

Do not enable auto-reload casually. Zen auto-reloads $20 by default when balance drops below $5. Set a monthly limit first.

## Kimi K2.6 vs MiniMax M2.7: Is It a Pure Upgrade?

**Short answer: Yes on quality, no on volume.**

K2.6 beats M2.7 on every major benchmark:

| Benchmark | Kimi K2.6 | MiniMax M2.7 | Winner |
|-----------|-----------|--------------|--------|
| SWE-Bench Pro | 58.6% | 56.2% | K2.6 (+2.4) |
| SWE-Bench Verified | 80.2% | ~76%* | K2.6 |
| AIME 2026 (math) | 96.4% | 89.8% | K2.6 (+6.6) |
| GPQA-Diamond (science) | 90.5% | 87.0% | K2.6 (+3.5) |
| HLE-Full (knowledge) | 34.7% | 28.0% | K2.6 (+6.7) |
| HLE-Full w/ tools | 54.0% | Not reported | K2.6 |
| BrowseComp | 83.2% | Not reported | K2.6 |
| DeepSearchQA | 92.5% | Not reported | K2.6 |
| MLE Bench Lite | Not reported | 66.6% | M2.7 (competitive) |

*M2.7 SWE-Bench Verified inferred from comparable models.

**Cost tradeoff:** On OpenCode Go, M2.7 delivers ~3x more requests per dollar (3,400 vs 1,150 per 5 hours). If you need to run many cheap drafts or exploratory queries, M2.7 remains useful. But for any task where quality matters — final implementation, debugging, reasoning — K2.6 is strictly better.

**Routing rule:** Use K2.6 as your default Go model. Drop to M2.7 only when you're burning through quota and can afford lower quality.

---

## Current Best Picks

| Task Type | Pick | Why |
|-----------|------|-----|
| **Default serious coding** | Claude Sonnet 4.6 | Best balance of quality, speed, and quota |
| **Hardest coding / agentic workflows** | Claude Opus 4.7 | Stronger on difficult long-running work, better self-checking |
| **Codex-style coding harness** | GPT-5.3-Codex | Built specifically for agentic coding and patch workflows |
| **Open-source agentic coding** | **Kimi K2.6** | 80.2% SWE-bench Verified, 58.6% SWE-bench Pro (beats GPT-5.4 +0.9), 300-agent swarm. $0.60/$3.00 per 1M tokens. Best open-source all-rounder. |
| **Free fast agentic model** | Ling 2.6 Flash | 340 tokens/s, 256K context, but 23.2% coding benchmark. Agentic efficiency focus, not coding powerhouse. Free for limited time via OpenCode Zen. |
| **High-volume cheap coding** | **MiniMax M2.7** | 56.2% SWE-bench Pro, 89.8% AIME 2026. ~3x more requests per dollar than K2.6 on OpenCode Go. Best when volume matters more than absolute quality. |
| **Cheap reasoning/coding balance** | **Qwen 3.6 Plus** | 78.8% SWE-bench Verified, $0.325/$1.95 per 1M. Similar request volume to MiniMax on OpenCode Go. Good cost-performance middle ground. |
| **OpenAI tool ecosystem** | GPT-5.4 | Best OpenAI default for complex reasoning, coding, tools, and long context |
| **Long-context synthesis** | Gemini 3.1 Pro | Strong for huge docs, codebases, multimodal inputs, and complex synthesis |
| **Open-weight coding** | GLM-5.1 | MIT-licensed 754B model, 58.4 SWE-bench Pro self-reported on model card |
| **Local / smaller open-weight coding** | Qwen3.6-35B-A3B | Apache-2.0, 35B total / 3B active, practical compared with GLM-5.1 |
| **Free or cheap bulk coding** | MiniMax M2.5 Free / MiniMax M2.7 / Qwen3.6 Plus / Gemini 3 Flash | Good enough for high-volume drafts, search, and non-critical coding |
| **Free small worker tasks** | GPT-5 nano | Best free OpenAI-style worker lane for summaries, classification, extraction, ranking, and simple subagents |
| **Math-heavy cheap work** | DeepSeek V3.2 Speciale | Strong reasoning/math lane, MIT model card, low-cost providers |
| **Low-cost agent backend** | MiMo-V2-Pro | 1M context, $1/$3 per 1M on OpenRouter, strong usage growth |
| **Fast subagents / extraction** | GPT-5.4 mini or nano | Cheaper GPT-5.4-class models for high-throughput work |
| **Visual / multimodal work** | Gemini 3.1 Pro or GPT-5.4 | Pick Gemini for multimodal volume, GPT-5.4 for OpenAI tools |

## Short Routing Rules

### Start with Sonnet 4.6 when:
- It is normal coding, writing, refactoring, or planning
- You need quality, but not maximum depth
- You want the best everyday quota-to-quality tradeoff

### Escalate to Opus 4.7 when:
- The work spans many files or many hours
- The bug is subtle and previous attempts missed it
- You need the model to challenge assumptions and verify before reporting
- The output is high-stakes enough to spend premium quota

### Use GPT-5.4 when:
- You need OpenAI tools: web search, file search, computer use, code interpreter, hosted shell, apply patch, MCP, or skills
- The job is professional long-context work, not just one code answer
- You want one broadly capable OpenAI model instead of a specialist

### Use GPT-5.3-Codex when:
- The task is code editing, patching, terminal-heavy, or autonomous coding
- You are in a Codex-like environment with repo tools
- You want 400k context and explicit reasoning effort control for coding

### Use Gemini 3.1 Pro when:
- You are reading or comparing huge documents, PDFs, videos, images, or codebases
- You need broad synthesis more than surgical code editing
- The task is research-heavy, scientific, or visual

### Use GLM-5.1 when:
- You specifically need open weights plus top coding performance
- You have enterprise-scale inference or a hosted provider
- You can tolerate setup/hardware complexity

### Use Qwen3.6-35B-A3B when:
- You want an open-weight model that is more realistic to run than GLM-5.1
- You need coding and repository reasoning at lower resource cost
- You accept lower absolute performance than frontier closed models

### Use MiniMax M2.7 when:
- You need maximum request volume on OpenCode Go (~3,400 req/5hr vs K2.6's 1,150)
- The task is bulk research, draft generation, or simple coding where you can verify outputs cheaply
- Cost matters more than absolute best output

### Use Qwen 3.6 Plus when:
- You want a middle ground between MiniMax volume and K2.6 quality (~3,300 req/5hr)
- 78.8% SWE-Bench Verified is sufficient for your coding tasks
- Budget is tight but you need better reasoning than MiniMax

### Use MiMo-V2-Pro / MiMo-V2-Omni when:
- You specifically need 1M context length
- Agent orchestration is the primary use case
- Accept higher cost than K2.6 for specific capabilities

### Use GLM-5.1 when:
- You need the highest open-weight coding benchmark (58.4% SWE-Bench Pro)
- You can tolerate the lowest request volume on OpenCode Go (880 req/5hr)
- Cost is secondary to benchmark performance

### Use DeepSeek V3.2 when:
- The task is math-heavy problem solving
- You need MIT-licensed weights with efficient reasoning
- Cost matters more than absolute best output

### Use GPT-5 nano when:
- The task is summarization, classification, extraction, ranking, or a small structured transform
- You want a fast free OpenAI-style worker inside OpenCode
- You do not need the model to act as the main coding agent

### Prefer MiniMax M2.5 Free over GPT-5 nano when:
- The task is actual coding in OpenCode
- You need repository edits, codebase reasoning, or longer agent loops
- You want a model OpenCode explicitly curates as a coding-agent option

For sensitive work, avoid the free OpenCode Zen endpoints where possible. OpenCode says MiniMax M2.5 Free may collect data during the free period, and OpenAI API requests are retained for 30 days under OpenAI's data policy.

---

## Model Notes By Provider

### Anthropic / Claude

| Model | Current Read | Best Use |
|-------|--------------|----------|
| **Claude Opus 4.7** | Strongest generally available Claude for coding, agents, vision, and long-running professional work | Hard tasks, code review, architecture, multi-step agents |
| **Claude Sonnet 4.6** | Best daily driver. 1M context in API beta, $3/$15 per 1M tokens | Most coding, docs, analysis, agent backends |
| **Claude Mythos Preview** | More capable than Opus 4.7 according to Anthropic, but limited release | Use only if you actually have access |

### OpenAI

| Model | Current Read | Best Use |
|-------|--------------|----------|
| **GPT-5.4** | OpenAI default for complex reasoning and coding. 1M context, $2.50/$15 per 1M | Tool-heavy professional work |
| **GPT-5.4 mini** | Cheaper GPT-5.4-class model. 400k context, $0.75/$4.50 | Subagents, coding loops, high-volume work |
| **GPT-5.4 nano** | Cheapest GPT-5.4-class model. 400k context, $0.20/$1.25 | Classification, extraction, simple workers |
| **GPT-5 nano** | Fastest, cheapest GPT-5 family model. OpenAI recommends starting with GPT-5.4 nano for new speed/cost workloads when available | Summarization, classification, extraction, ranking, small workers |
| **GPT-5.3-Codex** | Agentic coding specialist. 400k context, $1.75/$14 | Repo editing, patches, terminal-heavy coding |
| **gpt-oss-120b** | Open-weight Apache-2.0 reasoning model, single-H100 class | OpenAI open-weight experiments |

### Google / Gemini

| Model | Current Read | Best Use |
|-------|--------------|----------|
| **Gemini 3.1 Pro Preview** | Current complex-task Gemini lane; official docs say Gemini 3 Pro Preview is shut down and users should migrate | Long-context, multimodal, complex synthesis |
| **Gemini 3 Flash Preview** | Fast, high-value model with 1M context and lower latency/cost | Agent loops, coding help, interactive work |
| **Gemini 3.1 Flash-Lite** | Cost-efficient Gemini 3.1 family model | Bulk tasks and simple workers |
| **Nano Banana 2 / Pro** | Current Gemini image-generation/editing lanes | Visual generation and editing |

### Open-Weight / Budget Models

| Model | Current Read | Best Use |
|-------|--------------|----------|
| **GLM-5.1** | MIT license, 754B params, strong model-card benchmarks, very large | Top open-weight coding if hosted/enterprise |
| **Qwen3.6-35B-A3B** | Apache-2.0, 35B total / 3B active, 262k native context, extensible to 1M | Local-ish coding and agentic work |
| **MiniMax M2.7** | 56.2% SWE-Bench Pro, 66.6% MLE Bench Lite, open weights, built for agentic workflows | Highest volume/cost ratio on OpenCode Go (3,400 req/5hr). Best for drafts and exploration. |
| **MiniMax M2.5 Free** | Free OpenCode Zen coding-agent fallback for a limited time | Prefer over GPT-5 nano for coding drafts and OpenCode agent loops |
| **Qwen 3.6 Plus** | 78.8% SWE-Bench Verified, $0.325/$1.95 per 1M on OpenRouter | Best volume-to-quality ratio on OpenCode Go (3,300 req/5hr) |
| **DeepSeek V3.2 Speciale** | MIT license, efficient reasoning and agent performance | Math, algorithms, cheap reasoning |
| **MiMo-V2-Pro** | 1T params, 1M context, $1/$3 per 1M on OpenRouter | Low-cost agent backend, long context. More expensive than K2.6 with lower benchmarks. |
| **MiMo-V2-Omni** | Multimodal variant of MiMo-V2 | Cheaper than Pro on OpenCode Go (2,150 req/5hr) |
| **GLM-5.1** | MIT license, 754B params, 58.4% SWE-Bench Pro, 95.3% AIME 2026 | Top open-weight coding. Most expensive on OpenCode Go (880 req/5hr) — use sparingly. |

---

## OpenCode Go: Complete Model Guide

Your $10/month Go subscription includes **$12/5hr, $30/week, $60/month**. All models below are included. The key decision is which model to use for which task, given the tradeoffs between **quality**, **speed**, and **token efficiency**.

### The 10 Models at a Glance

| Model | Req / 5 hr | Req / week | Req / month | Context | Speed | Best For |
|-------|-----------|-----------|------------|---------|-------|----------|
| **Qwen3.5 Plus** | 10,200 | 25,200 | 50,500 | 1M | Fast | Maximum volume, simple tasks |
| **MiniMax M2.5** | 6,300 | 15,900 | 31,800 | 1M | 100 TPS (Lightning) | High-volume coding, fast agent loops |
| **MiniMax M2.7** | 3,400 | 8,500 | 17,000 | 1M | Fast | Volume + agentic capability |
| **Qwen 3.6 Plus** | 3,300 | 8,200 | 16,300 | 1M | Fast | Best volume-to-quality ratio |
| **MiMo-V2-Omni** | 2,150 | 5,450 | 10,900 | 262K | Medium | Multimodal (image/video/audio) |
| **Kimi K2.5** | 1,850 | 4,630 | 9,250 | 256K | Medium | Quality coding, cheaper than K2.6 |
| **MiMo-V2-Pro** | 1,290 | 3,225 | 6,450 | 1M | Medium | 1M context agent orchestration |
| **Kimi K2.6** | 1,150 | 2,880 | 5,750 | 256K | Medium | Best quality in Go |
| **GLM-5** | 1,150 | 2,880 | 5,750 | 200K | Slow | Strong open-weight coding |
| **GLM-5.1** | 880 | 2,150 | 4,300 | 200K | Slow | Top open-weight coding benchmarks |

**Request count source:** [OpenCode Go docs](https://opencode.ai/docs/go/), based on observed average token patterns per model.

---

### Benchmark Comparison (Coding & Reasoning)

| Model | SWE-V | SWE-Pro | Term-B2 | AIME | HLE w/Tools | BrowseComp |
|-------|-------|---------|---------|------|-------------|------------|
| **GLM-5.1** | — | **58.4** | **63.5** | **95.3** | 52.3 | 68.0 |
| **Kimi K2.6** | **80.2** | **58.6** | **66.7** | 96.4 | **54.0** | 83.2 |
| **MiniMax M2.5** | **80.2** | — | 54.0* | ~90* | 76.3* | 76.3 |
| **MiniMax M2.7** | ~76* | 56.2 | 57.0 | 89.8 | — | — |
| **Qwen 3.6 Plus** | **78.8** | — | — | — | — | — |
| **Kimi K2.5** | 76.8 | 50.7 | 50.8 | 96.1 | 50.2 | 60.6 |
| **GLM-5** | 77.8 | — | 56.2 | — | — | 62.0* |

*SWE-V = SWE-Bench Verified, Term-B2 = Terminal-Bench 2.0. Asterisk (*) denotes estimated or context-managed scores. Dash = not reported.

---

### Speed & Throughput Analysis

**Fastest to slowest (observed/claimed):**

1. **MiniMax M2.5 Lightning** — 100 tokens/sec. MiniMax explicitly claims this is "nearly twice that of other frontier models." Completes SWE-Bench Verified 37% faster than M2.1.
2. **Qwen 3.5 / 3.6 Plus** — No explicit TPS claim, but high request volume suggests efficient inference.
3. **MiniMax M2.7** — Fast, no explicit TPS but MiniMax optimized for speed.
4. **Kimi K2.5 / K2.6** — MoE with 32B active out of 1T. Efficient but not speed demons.
5. **MiMo-V2-Pro / Omni** — 1T+ params, likely slower throughput.
6. **GLM-5 / 5.1** — 744B–754B params. Largest models in Go, slowest inference.

**Speed matters when:** You're in a tight feedback loop (iterative coding, debugging). M2.5 Lightning excels here. For overnight batch jobs, speed is irrelevant — prioritize quality or cost.

---

### Token Efficiency & Cost Per Dollar

OpenCode Go gives you **$12 per 5 hours**. Here's how far that stretches:

| Model | Est. Input $/M | Est. Output $/M | Tokens You Can Buy ($12) | Efficiency Rating |
|-------|---------------|-----------------|-------------------------|-------------------|
| **MiniMax M2.5** | ~$0.15 | ~$1.20 | ~80M input + 10M output | ⭐⭐⭐⭐⭐ |
| **Qwen3.5 Plus** | ~$0.10 | ~$0.60 | ~120M input + 20M output | ⭐⭐⭐⭐⭐ |
| **MiniMax M2.7** | ~$0.20 | ~$1.60 | ~60M input + 7.5M output | ⭐⭐⭐⭐ |
| **Qwen 3.6 Plus** | $0.325 | $1.95 | ~37M input + 6M output | ⭐⭐⭐⭐ |
| **MiMo-V2-Omni** | $0.40 | $2.00 | ~30M input + 6M output | ⭐⭐⭐ |
| **Kimi K2.5** | ~$0.60 | ~$3.00 | ~20M input + 4M output | ⭐⭐⭐ |
| **Kimi K2.6** | $0.60 | $2.80 | ~20M input + 4.3M output | ⭐⭐⭐ |
| **MiMo-V2-Pro** | $1.00 | $3.00 | ~12M input + 4M output | ⭐⭐ |
| **GLM-5** | ~$0.60 | ~$3.00 | ~20M input + 4M output | ⭐⭐⭐ |
| **GLM-5.1** | ~$0.80 | ~$4.00 | ~15M input + 3M output | ⭐⭐ |

**Key insight:** The 3x promotion on Kimi K2.6 (active until ~Apr 27) temporarily triples its effective request count to **~3,450 req/5hr**, making it competitive with M2.7 on volume *while* maintaining superior quality. After the promotion ends, K2.6 drops back to 1,150 req/5hr and M2.7 becomes the clear volume winner.

---

### Individual Model Profiles

#### Qwen3.5 Plus — The Volume King
- **Best for:** Simple tasks, high-volume drafting, exploration
- **Tradeoff:** Lowest per-request cost but weakest benchmarks among Go models
- **Use when:** You need to blast through many simple queries and quality is secondary

#### MiniMax M2.5 — The Speed Demon
- **Best for:** Fast agent loops, real-time coding assistance, high-throughput workflows
- **Key stat:** 100 TPS (Lightning), 80.2% SWE-Bench Verified, 6,300 req/5hr
- **Tradeoff:** Slightly lower reasoning than K2.6 (AIME ~90 vs 96.4)
- **Use when:** Speed matters as much as quality. Best for interactive coding sessions.

#### MiniMax M2.7 — The Volume+Agent Hybrid
- **Best for:** Bulk agentic work, self-improvement harnesses, multi-agent collaboration
- **Key stat:** 56.2% SWE-Pro, 66.6% MLE Bench Lite, 3,400 req/5hr
- **Tradeoff:** Loses to K2.6 on all reasoning benchmarks
- **Use when:** You need agentic capability at high volume, post-promotion

#### Qwen 3.6 Plus — The Sweet Spot
- **Best for:** Balanced volume and quality
- **Key stat:** 78.8% SWE-Bench Verified, 3,300 req/5hr, $0.325/$1.95 per 1M
- **Tradeoff:** Fewer benchmarks published than K2.6 or MiniMax
- **Use when:** You want more quality than M2.7 but more volume than K2.6

#### MiMo-V2-Omni — The Multimodal Specialist
- **Best for:** Tasks requiring image, video, or audio understanding
- **Key stat:** 262K context, $0.40/$2.00, 2,150 req/5hr
- **Tradeoff:** Lower raw coding benchmarks than K2.6
- **Use when:** Your task crosses modalities (e.g., analyze video + write code)

#### Kimi K2.5 — The Budget Kimi
- **Best for:** Quality coding when K2.6 is too expensive
- **Key stat:** 76.8% SWE-V, 50.7% SWE-Pro, 1,850 req/5hr (61% more than K2.6)
- **Tradeoff:** Lower benchmarks than K2.6 across the board
- **Use when:** You want Kimi quality but need more requests per dollar

#### MiMo-V2-Pro — The Context King
- **Best for:** Long-context agent orchestration (1M tokens)
- **Key stat:** 1M context, 1T+ params, 1,290 req/5hr
- **Tradeoff:** More expensive than K2.6 with no clear benchmark advantage
- **Use when:** You specifically need 1M context in a cheap model

#### Kimi K2.6 — The Quality King
- **Best for:** Best possible output from OpenCode Go
- **Key stat:** 80.2% SWE-V, 58.6% SWE-Pro, 96.4% AIME, 54.0% HLE w/tools
- **Tradeoff:** Lowest request volume among quality models (1,150 req/5hr)
- **Use when:** Quality is paramount. Default choice during 3x promotion.

#### GLM-5 — The Open-Weight Workhorse
- **Best for:** Strong open-weight coding, 200K context tasks
- **Key stat:** 744B params, 77.8% SWE-V, 56.2% Term-B2, top open-model on BrowseComp
- **Tradeoff:** Slower inference, same request volume as K2.6
- **Use when:** You need proven open-weight performance

#### GLM-5.1 — The Benchmark Leader (Expensive)
- **Best for:** Maximum open-weight coding performance
- **Key stat:** 754B params, 58.4% SWE-Pro (highest in Go), 95.3% AIME, 63.5% Term-B2
- **Tradeoff:** Most expensive model in Go (880 req/5hr). Drains credits fast.
- **Use when:** You need the highest SWE-Pro score and can afford the credit burn.

---

### Routing Cheat Sheet for OpenCode Go

| Scenario | Pick | Why |
|----------|------|-----|
| **Default (during 3x promo)** | **Kimi K2.6** | ~3,450 effective req/5hr + best quality = unbeatable combo |
| **Default (post-promo)** | **Kimi K2.6** for quality, **MiniMax M2.5** for speed/volume | K2.6 still best quality; M2.5 gives 5.5x more requests |
| **Fast interactive coding** | **MiniMax M2.5 Lightning** | 100 TPS, 80.2% SWE-V, fastest feedback loop |
| **Bulk drafts/exploration** | **Qwen3.5 Plus** or **MiniMax M2.5** | 10,200 or 6,300 req/5hr — maximize queries per dollar |
| **Volume + decent quality** | **Qwen 3.6 Plus** or **MiniMax M2.7** | 3,300/3,400 req/5hr with solid benchmarks |
| **Multimodal tasks** | **MiMo-V2-Omni** | Only Go model with native image/video/audio |
| **1M context needed** | **MiMo-V2-Pro** | Cheapest 1M context in Go |
| **Best open-weight coding** | **GLM-5.1** | 58.4% SWE-Pro, but monitor credits closely |
| **Budget Kimi** | **Kimi K2.5** | 61% more requests than K2.6 with 76.8% SWE-V |

---

### Post-Promotion Strategy (After Kimi K2.6 3x Ends)

When K2.6 drops from ~3,450 back to 1,150 req/5hr:

1. **Quality-first tasks** → K2.6 (hardest bugs, final reviews, reasoning)
2. **Speed-first tasks** → MiniMax M2.5 Lightning (interactive coding, fast loops)
3. **Volume-first tasks** → MiniMax M2.5 or Qwen3.5 Plus (drafts, exploration, bulk)
4. **Balanced tasks** → Qwen 3.6 Plus or MiniMax M2.7 (good enough quality, 3x K2.6 volume)
5. **Multimodal** → MiMo-V2-Omni (no alternative in Go)
6. **Long context** → MiMo-V2-Pro (1M tokens cheaply)

**Your stated keepers (GLM-5.1, K2.6, M2.7) make sense:**
- GLM-5.1: When you need top open-weight benchmarks, cost be damned
- K2.6: Best quality, use sparingly post-promo for high-stakes work
- M2.7: Good agentic capability at 3x K2.6's volume

Consider adding **M2.5** to your rotation for speed-critical work, and **Qwen 3.6 Plus** as a volume-quality middle ground.

---

## Agentic Routing (Session 42)

For agentic workflows, subtasks are routed to specialist agents instead of using one model for everything.

### Agent-to-Model Mapping

| Agent | Model | Handles | Cost vs Monolithic K2.6 |
|-------|-------|---------|------------------------|
| **Orchestrator** | **Kimi K2.6** | Planning, routing, synthesis | Same (negligible volume) |
| **Explorer** | **MiniMax M2.5** | Search, grep, file discovery | **5× cheaper** |
| **Drafter** | **MiniMax M2.7** | Implementation, scaffolding | **3× cheaper** |
| **Debugger** | **Kimi K2.6** | Hard bugs, root cause analysis | Same |
| **Reviewer** | **GLM-5.1** | Code review, verification | Same (sparingly) |

### Routing Triggers

| User Request Contains | Route To | Model |
|----------------------|----------|-------|
| "find," "search," "where is," "locate," "grep" | Explorer | M2.5 |
| "write," "create," "add," "implement," "draft" | Drafter | M2.7 |
| "debug," "fix," "investigate," "root cause" | Debugger | K2.6 |
| "review," "check," "verify," "audit" | Reviewer | GLM-5.1 |
| (everything else) | Orchestrator | K2.6 |

### Cost Impact

| Task Type | Monolithic K2.6 | Agentic | Savings |
|-----------|----------------|---------|---------|
| Search-heavy session | 100% K2.6 | 80% M2.5 | **5× on search** |
| Implementation + review | 100% K2.6 | 70% M2.7 + GLM-5.1 | **3× on draft** |
| Long mixed session (20 turns) | Quadratic degradation | Linear via subsessions | **40–60% overall** |

### Fallback Chain

| Primary | Fallback 1 | Fallback 2 |
|---------|-----------|------------|
| K2.6 (Orchestrator) | K2.5 (61% more requests) | M2.7 |
| M2.5 (Explorer) | Qwen3.5 Plus | M2.7 |
| M2.7 (Drafter) | Qwen 3.6 Plus | K2.6 |
| GLM-5.1 (Reviewer) | K2.6 | M2.7 |

See `docs/agentic-workflows.md` for full architecture, context passing format, and warm handoff protocol.

---

## GitHub Copilot: Your Premium Lane

If you have GitHub Copilot Pro/Student, you have access to frontier models with a **premium request** system. Understanding the multipliers is critical for cost control.

### Copilot Plan Tiers

| Plan | Monthly Cost | Premium Requests | Unlimited Chat With |
|------|-------------|------------------|---------------------|
| **Copilot Free** | $0 | 50 | Haiku 4.5, GPT-5 mini, GPT-4.1, GPT-4o |
| **Copilot Pro** | $10 | 300 | All included + premium models |
| **Copilot Pro+** | $39 | 1,500 | All models including Opus 4.7 |
| **Copilot Student** | $0 | 300 (same as Pro) | Same as Pro |

**Your confirmed access:** Student plan with 300 premium requests/month.

### Model Multipliers (Paid Plans)

Every premium model consumes your allowance based on its multiplier. One "prompt" to Opus 4.7 burns **7.5 requests** from your 300 monthly pool.

| Model | Multiplier | Effective Monthly Prompts | Category |
|-------|-----------|--------------------------|----------|
| GPT-5 mini, GPT-4.1, GPT-4o, Raptor mini | **0** | Unlimited | Included (free) |
| GPT-5.4 nano | 0.25 | 1,200 | Ultra-cheap |
| Grok Code Fast 1 | 0.25 | 1,200 | Ultra-cheap |
| Claude Haiku 4.5 | 0.33 | ~900 | Cheap |
| Gemini 3 Flash | 0.33 | ~900 | Cheap |
| GPT-5.4 mini | 0.33 | ~900 | Cheap |
| **Claude Sonnet 4.6** | **1** | **300** | **Default** |
| Claude Sonnet 4.5 | 1 | 300 | Default |
| Claude Sonnet 4.0 | 1 | 300 | Default |
| **GPT-5.4** | **1** | **300** | **Default** |
| GPT-5.3-Codex | 1 | 300 | Default |
| GPT-5.2 | 1 | 300 | Default |
| GPT-5.2-Codex | 1 | 300 | Default |
| Gemini 2.5 Pro | 1 | 300 | Default |
| **Gemini 3.1 Pro** | **1** | **300** | **Default** |
| Qwen2.5 | 1 | 300 | Default |
| Claude Opus 4.5 | 3 | 100 | Expensive |
| Claude Opus 4.6 | 3 | 100 | Expensive |
| **Claude Opus 4.7** | **7.5** | **40** | **Very expensive** |
| Claude Opus 4.6 (fast mode) | 30 | 10 | Prohibitively expensive |

**Key insight:** With 300 premium requests, you can send **300 prompts to Sonnet 4.6** but only **40 prompts to Opus 4.7**. Use Opus sparingly — reserve it for tasks where Sonnet fails.

### Copilot Model Recommendations

| Task | Best Model | Why |
|------|-----------|-----|
| **Daily coding** | Claude Sonnet 4.6 (1x) | Best balance. 300 prompts/month is enough for regular work. |
| **Agentic coding** | GPT-5.3-Codex (1x) | Built for agentic tasks, patch workflows, terminal work. |
| **Hard debugging** | Claude Opus 4.7 (7.5x) | Use only when stuck. 40 prompts/month — make them count. |
| **Quick questions** | Claude Haiku 4.5 (0.33x) | ~900 prompts/month. Fast, lightweight. |
| **Multimodal** | Gemini 3.1 Pro (1x) | Strong vision + long context. 300 prompts. |
| **Fast coding** | Grok Code Fast 1 (0.25x) | 1,200 prompts/month. Specialized for speed. |
| **Cheap reasoning** | GPT-5.4 mini (0.33x) | ~900 prompts. Good for subagents and exploration. |

### Copilot vs OpenCode Go: When to Use Which

| Factor | Copilot (Student) | OpenCode Go |
|--------|------------------|-------------|
| **Monthly cost** | $0 | $10 |
| **Frontier models** | Yes (Claude, GPT, Gemini) | No (open-weight only) |
| **Best model quality** | Opus 4.7 > Sonnet 4.6 | K2.6 ≈ Sonnet 4.6 |
| **Request volume** | 300 premium + unlimited included | ~5,750–50,500 depending on model |
| **Speed** | Varies by model | M2.5 Lightning at 100 TPS |
| **Best for** | High-stakes work, debugging, final review | Bulk work, exploration, drafts |
| **Harness engineering** | Limited | M2.7 native support |

**Verdict:** Use Copilot for your 40 hardest tasks (Opus 4.7) and daily serious work (Sonnet 4.6). Use Go for everything else — drafts, exploration, bulk coding, harness experiments.

---

## Google Gemini: Free Tier Deep Dive

Google AI Studio offers a **generous free tier** for Gemini models. This is a legitimate zero-cost lane for many tasks.

### Free Tier Limits (AI Studio)

| Model | Free Tier | Rate Limit | Best Use |
|-------|-----------|------------|----------|
| **Gemini 2.5 Pro** | Yes | 10 RPM, 1M tokens/min | Long-context research, reasoning |
| **Gemini 3.1 Pro Preview** | Yes | 10 RPM, 1M tokens/min | Complex tasks, multimodal |
| **Gemini 3 Flash** | Yes | 15 RPM, 1M tokens/min | Fast coding, agent loops |
| **Gemini 3.1 Flash-Lite** | Yes | 15 RPM, 1M tokens/min | Bulk tasks, simple workers |
| **Imagen 4** | Yes | Limited | Image generation |

**RPM = requests per minute.** 10 RPM = 600 requests/hour = 14,400/day.

### When to Use Gemini Free Tier

- **Research and synthesis:** 1M context lets you throw entire codebases or documents at it.
- **Multimodal analysis:** Vision + text understanding for UI debugging, chart reading.
- **Bulk exploration:** 14,400 requests/day is more than enough for exploration.
- **When Copilot quota is low:** Gemini free tier has no monthly cap, only per-minute rate limits.

### Gemini Paid API (if you hit limits)

| Model | Input | Output | Context |
|-------|-------|--------|---------|
| Gemini 3.1 Pro | $3.50/M | $10.50/M | 1M |
| Gemini 3 Flash | $0.15/M | $0.60/M | 1M |
| Gemini 3.1 Flash-Lite | $0.075/M | $0.30/M | 1M |

**Verdict:** Start with free tier. Only pay if you consistently hit the 10-15 RPM rate limit during heavy work sessions.

---

## DeepSeek: API + Free Options

DeepSeek offers both a **free chat app** and dirt-cheap **API access**.

### DeepSeek Models

| Model | API Cost (Input/Output) | Context | License | Best For |
|-------|------------------------|---------|---------|----------|
| **DeepSeek-V3.2** | **$0.252/$0.378 per 1M** | 128K | MIT | General reasoning, agentic tasks |
| **DeepSeek-V3.2-Speciale** | Same API | 128K | MIT | **Deep reasoning** — gold medal IMO/IOI 2025 |
| **DeepSeek-R1** | Similar pricing | 128K | MIT | Reasoning-focused (older) |

### Free Options

1. **DeepSeek Chat (chat.deepseek.com)** — Free web interface. No API needed. Subject to usage limits.
2. **OpenRouter free tier** — DeepSeek V3.2 may be available with daily request caps (check current status).
3. **Local deployment** — MIT license means you can self-host if you have the hardware.

### DeepSeek vs OpenCode Go

| Factor | DeepSeek API | OpenCode Go (K2.6) |
|--------|-------------|-------------------|
| **Cost** | $0.252/$0.378 per 1M | $0.60/$2.80 per 1M |
| **SWE-Bench Verified** | Not reported | 80.2% |
| **Reasoning** | Gold medal IMO/IOI | Strong (96.4% AIME) |
| **Context** | 128K | 256K |
| **Speed** | Moderate | Medium |
| **Best for** | Math, algorithms, cheap reasoning | Coding, agentic work |

**Verdict:** DeepSeek is the cheapest API for reasoning tasks. Use it for math-heavy work or when you need MIT-licensed outputs. For coding, K2.6 has proven benchmarks.

---

## Qwen: Beyond OpenCode Go

Alibaba's Qwen family extends beyond the two Go models. You can access more variants via API or self-hosting.

### Qwen Model Lineup

| Model | Size | License | Context | Best For |
|-------|------|---------|---------|----------|
| **Qwen3.6-Plus** (Go) | API-only | Closed | 1M | Strong coding via Go |
| **Qwen3.6-35B-A3B** | 35B total / 3B active | Apache-2.0 | 262K–1M | **Local deployment**, practical open-weight |
| **Qwen3-VL-235B-A22B** | 235B total / 22B active | Apache-2.0 | 128K | Vision-language tasks |
| **Qwen2.5** (Copilot) | Various | Apache-2.0 | 128K | General coding (available in Copilot) |
| **Qwen2.5-Coder** | 7B–32B | Apache-2.0 | 128K | Specialized coding models |

### Qwen3.6-35B-A3B Benchmarks

| Benchmark | Score |
|-----------|-------|
| SWE-Bench Verified | 73.4% |
| SWE-Bench Pro | 49.5% |
| Terminal-Bench 2.0 | 51.5% |
| AIME 2026 | Not reported |

**Verdict:** Qwen3.6-35B-A3B is a practical local alternative — Apache-2.0, small enough to run on consumer hardware (3B active params), decent coding benchmarks. Not as strong as K2.6 or GLM-5.1, but much more deployable.

### Free Qwen Access

1. **Qwen Chat (chat.qwen.ai)** — Free web interface for Qwen models.
2. **Hugging Face inference** — Some Qwen models have free inference endpoints.
3. **OpenRouter** — Qwen3.6 Plus at $0.325/$1.95 (not free, but cheap).

---

## Unified Master Comparison: All Your Models

### By Provider & Cost

| Provider | Monthly Cost | Best Model | Req/Month | Best For |
|----------|-------------|------------|-----------|----------|
| **GitHub Copilot Student** | $0 | Opus 4.7 (40 prompts) | 300 premium | Frontier quality, debugging |
| **Google AI Studio** | $0 | Gemini 3.1 Pro | ~14,400/day | Long context, multimodal, research |
| **OpenCode Go** | $10 | K2.6 (1,150/5hr) | ~5,750–50,500 | Bulk coding, open models |
| **DeepSeek API** | Pay-as-you-go | V3.2 ($0.252/M) | Unlimited | Cheapest reasoning, math |
| **OpenRouter** | Pay-as-you-go | Various | Varies | Flexible, many models |
| **Qwen Chat** | $0 | Qwen3.6 Plus | Unknown limits | Free Qwen access |

### By Task: Which Model Across ALL Providers

| Task | First Choice | Backup | Free Option |
|------|-------------|--------|-------------|
| **Hardest debugging** | Claude Opus 4.7 (Copilot, 7.5x) | K2.6 (Go) | Gemini 3.1 Pro (AI Studio) |
| **Daily coding** | Claude Sonnet 4.6 (Copilot, 1x) | K2.6 (Go) | Gemini 3 Flash (AI Studio) |
| **Agentic coding** | GPT-5.3-Codex (Copilot, 1x) | MiniMax M2.7 (Go) | — |
| **Harness engineering** | MiniMax M2.7 (Go) | K2.6 (Go) | — |
| **Fast interactive coding** | MiniMax M2.5 Lightning (Go) | Sonnet 4.6 (Copilot) | Gemini 3 Flash (AI Studio) |
| **Bulk drafts/exploration** | Qwen3.5 Plus (Go, 50K/mo) | MiniMax M2.5 (Go) | Gemini 3.1 Pro (AI Studio) |
| **Math/reasoning** | DeepSeek V3.2 (API, $0.252/M) | Opus 4.7 (Copilot) | DeepSeek Chat (free) |
| **Multimodal** | Gemini 3.1 Pro (AI Studio, free) | MiMo-V2-Omni (Go) | Gemini 2.5 Pro (AI Studio) |
| **1M+ context** | MiMo-V2-Pro (Go) | Gemini 3.1 Pro (AI Studio) | Gemini 2.5 Pro (AI Studio) |
| **Local/self-hosted** | Qwen3.6-35B-A3B (Apache-2.0) | DeepSeek V3.2 (MIT) | — |
| **Long-context research** | Gemini 2.5 Pro (AI Studio, free) | Gemini 3.1 Pro (AI Studio) | — |

### Cost-Per-Quality Ranking (Coding)

For **1,000 prompts of serious coding work per month**, cheapest to most expensive:

| Rank | Provider/Model | Est. Monthly Cost | Quality |
|------|---------------|-------------------|---------|
| 1 | **Gemini 3.1 Pro (AI Studio free)** | $0 | High |
| 2 | **MiniMax M2.5 (Go)** | ~$2–3 | High (80.2% SWE-V) |
| 3 | **Qwen3.5 Plus (Go)** | ~$1–2 | Medium |
| 4 | **Kimi K2.6 (Go, post-promo)** | ~$8–10 | Highest (80.2% SWE-V) |
| 5 | **DeepSeek V3.2 (API)** | ~$5–10 | High (reasoning) |
| 6 | **Claude Sonnet 4.6 (Copilot Student)** | $0 | Very High |
| 7 | **Claude Opus 4.7 (Copilot)** | $0 (but 40 prompts) | Maximum |

*Assumes average 500 input + 200 output tokens per prompt. Go costs calculated from $10/month subscription spread across usage.*

---

## Benchmark Snapshot

Treat benchmark numbers as directional. They depend on harness, scaffolding, tool access, and contamination controls.

| Model | Coding / Agent Signal | Notes |
|-------|-----------------------|-------|
| Claude Opus 4.7 | Anthropic reports major gains over Opus 4.6 in advanced software engineering and long-running tasks | Best premium lane right now |
| Claude Sonnet 4.6 | Best daily driver. 1M context in API beta, strong coding and reasoning | Best quality-to-quota balance |
| GPT-5.3-Codex | OpenAI calls it the most capable agentic coding model to date | Best inside OpenAI coding workflows |
| GPT-5.4 | OpenAI flagship for complex reasoning and coding | Broadest OpenAI default |
| Gemini 3.1 Pro | Google says it is for complex tasks and improved reasoning; official model docs list it as current preview | Best long-context / multimodal lane |
| GLM-5.1 | Model card reports 58.4 SWE-bench Pro and 63.5 Terminal-Bench 2.0 | Best open-weight coding claim, verify on your workload |
| Qwen3.6-35B-A3B | Model card reports 73.4 SWE-bench Verified, 49.5 SWE-bench Pro, 51.5 Terminal-Bench 2.0 | Strong practical open-weight alternative |
| MiniMax M2.5 | 80.2% SWE-Bench Verified, 100 TPS, 6,300 req/5hr on Go | Best speed+coding combo in Go |
| MiniMax M2.7 | 56.2% SWE-bench Pro, 66.6% MLE Bench Lite, strong agentic workflows | Best volume/cost ratio on OpenCode Go |
| DeepSeek V3.2 | Gold medal IMO/IOI 2025, $0.252/$0.378 per 1M | Cheapest frontier-class reasoning |
| Kimi K2.6 | 80.2% SWE-V, 58.6% SWE-Pro, 96.4% AIME | Best quality in Go |

## Cost Tiers

| Tier | Models | Typical Use |
|------|--------|-------------|
| **Free / near-free** | Gemini 3.1 Pro (AI Studio), DeepSeek Chat, Claude Sonnet 4.6 (Copilot Student), GPT-5 mini (Copilot), MiniMax M2.5 Free | Drafts, bulk research, low-risk coding, simple workers |
| **Budget** | MiMo-V2-Pro, DeepSeek V3.2 API, GPT-5.4 nano, MiniMax M2.5 (Go) | Workers, extraction, simple agents, high-volume coding |
| **Mid** | Claude Sonnet 4.6, Gemini 3.1 Pro API, GPT-5.4 mini, Qwen 3.6 Plus | Daily serious work |
| **Premium** | Claude Opus 4.7, GPT-5.4, GPT-5.3-Codex, Kimi K2.6 | Hard work, tool-heavy work, deep coding |
| **Ultra premium** | Claude Opus 4.7 (fast mode), GPT-5.4 pro | Only when max quality matters and latency/cost are acceptable |

## Practical Cascades

### Coding Cascade

```
MiniMax M2.7 / Qwen3.6 -> Claude Sonnet 4.6 -> Claude Opus 4.7 or GPT-5.3-Codex
```

Use the cheap model to draft or explore. Use Sonnet for real implementation. Escalate only when the problem is subtle, large, or repeatedly failing.

### Research Cascade

```
Gemini 3 Flash / MiniMax M2.7 -> Gemini 3.1 Pro -> GPT-5.4 or Opus 4.7
```

Use cheap long-context models to gather. Use Gemini Pro for synthesis. Use GPT-5.4 or Opus when the final answer needs stronger judgment or tool work.

### Agent Backend Cascade

```
GPT-5.4 nano / Gemini Flash-Lite -> GPT-5.4 mini / Sonnet 4.6 -> Opus 4.7 / GPT-5.4
```

Cheap workers first. Stronger supervisor only when needed.

## Verification Rules

1. Do not call a model open-weight unless a model card, official repo, or Hugging Face page confirms weights and license.
2. Do not trust a benchmark table without checking whether it used a special scaffold.
3. For any expensive switch, run the same small task on two models before committing.
4. For coding, judge by local tests and review quality, not benchmark rank alone.
5. For long-context tasks, verify retrieval with spot checks. Long context is not the same as correct context use.

## Monthly Refresh Checklist

Check in this order:

1. [OpenAI models](https://developers.openai.com/api/docs/models)
2. [Anthropic model pages](https://www.anthropic.com/claude/opus)
3. [Google Gemini models](https://ai.google.dev/gemini-api/docs/models)
4. [OpenRouter rankings](https://openrouter.ai/rankings)
5. [OpenRouter coding collection](https://openrouter.ai/collections/programming)
6. Hugging Face model cards for any open-weight claim
7. Primary model release posts or technical reports

If a claim affects cost, hardware, licensing, or model availability, verify it from an official source before updating the recommendation.

## Sources Checked

| Source | What It Confirmed |
|--------|-------------------|
| [OpenAI models](https://developers.openai.com/api/docs/models) | GPT-5.4 default, mini/nano costs, context, tools |
| [GPT-5.3-Codex model page](https://developers.openai.com/api/docs/models/gpt-5.3-codex) | Agentic coding positioning, 400k context, pricing |
| [gpt-oss-120b model page](https://developers.openai.com/api/docs/models/gpt-oss-120b) | Open-weight Apache-2.0 model details |
| [Anthropic Opus 4.7 announcement](https://www.anthropic.com/research/claude-opus-4-7) | Opus 4.7 availability, strengths, pricing, effort guidance |
| [Anthropic Sonnet 4.6 page](https://www.anthropic.com/claude/sonnet) | Sonnet 4.6 pricing, 1M context beta, use cases |
| [Google Gemini 3.1 Pro announcement](https://blog.google/innovation-and-ai/models-and-research/gemini-models/gemini-3-1-pro/) | Gemini 3.1 Pro availability and complex-task positioning |
| [Google Gemini model docs](https://ai.google.dev/gemini-api/docs/models) | Gemini 3.1 Pro current preview, Gemini 3 Pro shutdown notice, Gemini family map |
| [Google Gemini pricing](https://ai.google.dev/gemini-api/docs/pricing) | Gemini pricing tiers |
| [OpenRouter rankings](https://openrouter.ai/rankings) | Usage-based market signals |
| [OpenRouter programming collection](https://openrouter.ai/collections/programming) | Coding usage signals |
| [GLM-5.1 Hugging Face](https://huggingface.co/zai-org/GLM-5.1) | MIT license, 754B size, benchmark claims |
| [Qwen3.6-35B-A3B Hugging Face](https://huggingface.co/Qwen/Qwen3.6-35B-A3B) | Apache-2.0 license, model size, context, benchmarks |
| [DeepSeek V3.2 Speciale Hugging Face](https://huggingface.co/deepseek-ai/DeepSeek-V3.2-Speciale) | MIT license and reasoning/agentic positioning |
| [NVIDIA MiniMax M2.7 post](https://developer.nvidia.com/blog/minimax-m2-7-advances-scalable-agentic-workflows-on-nvidia-platforms-for-complex-ai-applications/) | M2.7 open-weight and agentic workflow availability |
| [MiMo-V2-Pro on OpenRouter](https://openrouter.ai/xiaomi/mimo-v2-pro) | API pricing, 1M context, agentic positioning |
| [GitHub Copilot plans](https://docs.github.com/en/copilot/get-started/plans) | Copilot Student/Pro premium request allowances and model availability |
| [GitHub Copilot model comparison](https://docs.github.com/en/copilot/reference/ai-models/model-comparison) | Copilot task routing across GPT, Claude, and Gemini models |
| [GitHub Copilot requests](https://docs.github.com/en/copilot/concepts/billing/copilot-requests) | Premium request multipliers for Opus, Sonnet, Gemini, GPT, and Codex models |
| [OpenCode Go](https://opencode.ai/docs/go/) | Go subscription pricing, model list, and usage limits |
| [OpenCode Zen](https://dev.opencode.ai/docs/zen) | Zen model list, Ling 2.6 Flash free availability, Kimi K2.6 3x promotion, pricing, privacy caveats |
| [Kimi K2.6 benchmarks](https://lushbinary.com/blog/kimi-k2-6-developer-guide-benchmarks-api-agent-swarm) | SWE-bench Verified 80.2%, SWE-bench Pro 58.6%, HLE-Full 54.0%, agent swarm 300 agents |
| [Ling 2.6 Flash](https://blog.kilo.ai/the-elephant-is-out-of-the-bag-meet) | Ant Group's model revealed as "Elephant" stealth model, 104B total / 7.4B active MoE, 340 tokens/s |
| [Kimi K2.6 vs competitors](https://www.buildfastwithai.com/blogs/kimi-k2-6-vs-gpt-claude-benchmarks) | Kimi K2.6 vs GPT-5.4, Claude Opus, benchmarks comparison table |
| [AI Model Comparison - Ling 2.6 Flash](https://aimodelcomparison.org/models/ling-2-6-flash) | Ling 2.6 Flash coding score 23.2%, reasoning 26.2%, 216 tokens/sec |
| [GPT-5 nano model page](https://developers.openai.com/api/docs/models/gpt-5-nano) | GPT-5 nano positioning, cost, context, and tool support |
| [MiniMax M2.7 model page](https://www.minimaxi.com/en/models/text/m27) | M2.7 benchmarks, SWE-Pro 56.22%, agent capabilities |
| [MiniMax M2.7 announcement](https://www.minimaxi.com/en/news/minimax-m27-en) | M2.7 self-evolution, MLE Bench Lite 66.6%, agent teams |
| [OpenCode Go docs](https://opencode.ai/docs/go/) | Go model list, request limits per model, pricing |
| [Qwen 3.6 Plus OpenRouter](https://openrouter.ai/qwen/qwen3.6-plus) | Qwen 3.6 Plus pricing, SWE-Bench Verified 78.8% |
| [MiMo-V2-Pro OpenRouter](https://openrouter.ai/xiaomi/mimo-v2-pro) | MiMo-V2-Pro pricing, 1M context, agent positioning |
| [GLM-5.1 Hugging Face](https://huggingface.co/zai-org/GLM-5.1) | GLM-5.1 benchmarks including MiniMax M2.7 comparison |
| [Gemini API rate limits](https://ai.google.dev/gemini-api/docs/rate-limits) | Free tier behavior, rate-limit dimensions, and AI Studio active limit checks |
| [Gemini API pricing](https://ai.google.dev/gemini-api/docs/pricing) | Free-tier token pricing and paid Gemini API pricing |
| [Gemini Code Assist quotas](https://developers.google.com/gemini-code-assist/resources/quotas) | Free individual daily request quota and GitHub PR review quota |
| [OpenRouter limits](https://openrouter.ai/docs/api-reference/limits/) | Free-model daily request caps and 20 RPM limit |
| [Cursor Students](https://cursor.com/en-US/students) | One free year of Cursor Pro for eligible students and included monthly usage |
| [GitHub Copilot model comparison](https://docs.github.com/en/copilot/reference/ai-models/model-comparison) | Full Copilot model list with task recommendations |
| [GitHub Copilot premium requests](https://docs.github.com/en/copilot/concepts/billing/copilot-requests) | Premium request multipliers for all Copilot models |
| [DeepSeek API docs](https://platform.deepseek.com/api-docs/) | DeepSeek-V3.2 API, pricing, and usage |
| [DeepSeek V3.2 OpenRouter](https://openrouter.ai/deepseek/deepseek-v3.2) | DeepSeek V3.2 pricing on OpenRouter ($0.252/$0.378) |
| [DeepSeek V3.2-Speciale Hugging Face](https://huggingface.co/deepseek-ai/DeepSeek-V3.2-Speciale) | MIT license, gold medal IMO/IOI 2025, reasoning benchmarks |
| [Qwen3.6-35B-A3B Hugging Face](https://huggingface.co/Qwen/Qwen3.6-35B-A3B) | Apache-2.0, 35B/3B active, SWE-Bench Verified 73.4% |

## Metadata

```yaml
---
last_verified: 2026-04-22
next_review: 2026-05-22
review_type: unified_multi_provider_model_analysis
corrections_made:
  - Added Kimi K2.6 as strongest open-source agentic model, beats GPT-5.4 on SWE-bench Pro (+0.9), DeepSearchQA (+13.9).
  - Added Ling 2.6 Flash as free fast model with caveat: low coding benchmarks (23.2%), good for exploration only.
  - Updated OpenCode Go lane to highlight Kimi K2.6 3x promotion active until Apr 27 (~1,150 requests/5 hours).
  - Added Kimi K2.6 vs GPT-5.4/Claude benchmark comparison sources.
  - Added Ling 2.6 Flash origin story (Ant Group's "Elephant" stealth model).
  - Added AI Model Comparison source for Ling 2.6 Flash coding score.
  - Replaced basic OpenCode Go table with comprehensive 10-model guide: all Go models (GLM-5/5.1, Kimi K2.5/2.6, MiMo-V2-Pro/Omni, MiniMax M2.5/2.7, Qwen3.5/3.6 Plus).
  - Added benchmark comparison table covering SWE-V, SWE-Pro, Terminal-Bench 2.0, AIME, HLE, BrowseComp for all Go models.
  - Added speed & throughput analysis — MiniMax M2.5 Lightning at 100 TPS is fastest in Go.
  - Added token efficiency & cost-per-dollar analysis with star ratings for all 10 models.
  - Added individual model profiles with key stats, tradeoffs, and use-when guidance.
  - Added routing cheat sheet for 9 common scenarios.
  - Added post-promotion strategy section for when K2.6 3x ends.
  - Added Kimi K2.6 vs MiniMax M2.7 head-to-head — K2.6 wins on all metrics.
  - Added GLM-5.1 cost warning (lowest request volume on Go at 880 req/5hr).
  - Added GitHub Copilot deep dive: plan tiers, premium request multipliers, model recommendations by task.
  - Added Google Gemini free tier analysis: AI Studio limits, free tier models, paid API fallback.
  - Added DeepSeek analysis: API pricing ($0.252/$0.378), free chat app, local deployment options.
  - Added Qwen beyond Go: Qwen3.6-35B-A3B (Apache-2.0, local), Qwen2.5, Qwen Chat free tier.
  - Added unified master comparison table across ALL providers (Copilot, Gemini, Go, DeepSeek, OpenRouter).
  - Added cost-per-quality ranking for 1,000 prompts/month across all providers.
  - Added task-based routing: "Which model across ALL providers" for 11 common scenarios.
---
```

Last updated: 2026-04-22
