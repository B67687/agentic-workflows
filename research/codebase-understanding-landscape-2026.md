# Codebase Understanding for LLM Agents: Landscape Analysis (May 2026)

## The Problem

LLMs have finite context windows (128K–2M tokens). Codebases are large (10K–1M+ files).
No single technique can fit an entire codebase into context. The question is:
**What combination of techniques gives the best approximation of "full codebase understanding"?**

---

## Approach Catalog

### 1. Static Repo Map (Tree-sitter + PageRank)

**Used by:** Aider (44K stars), OpenCode `/repo-map`

**How it works:**
- Parse every source file with tree-sitter (language-aware AST)
- Extract symbols: classes, methods, functions, types, signatures
- Build a dependency graph (nodes = files, edges = imports/requires)
- Run PageRank to rank files by importance
- Format as compact text showing ranked symbols within a token budget

**Strengths:**
- Always available (pre-computed, cached)
- Very cheap (tokens: 1K default, expandable to ~4K)
- Gives LLM a high-level map of the entire repo
- LLM can use the map to decide which files to read in detail
- Caches in SQLite with mtime checking — fast incremental updates

**Weaknesses:**
- Only shows symbols, not implementations
- PageRank can miss task-specific relevance
- Token budget limits how much of the map fits
- Language-specific (needs tree-sitter grammars)

**Key reference:** [Aider repo map docs](https://aider.chat/docs/repomap.html), [Building a better repo map](https://aider.chat/2023/10/22/repomap.html)

---

### 2. Bash-Only Agentic Exploration

**Used by:** Mini-SWE-agent (74% on SWE-bench verified, 4.3K stars),
SWE-agent (19K stars, NeurIPS 2024)

**How it works:**
- Agent has ONE tool: bash
- Uses standard Unix commands to explore: `find`, `grep`, `cat`, `ls`
- Every action is `subprocess.run` (no stateful shell, no custom tools)
- Linear history (each step appends to messages)
- Docker sandbox for safety

**Strengths:**
- Radically simple (~100 lines of agent code)
- Works with ANY model (no tool-calling API needed)
- Agent naturally reads exactly what it needs
- Extremely stable (no stateful shell bugs)
- Easy to sandbox (swap subprocess for docker exec)

**Weaknesses:**
- Expensive (many turns of exploration)
- No pre-computed index — each session starts from scratch
- Can miss things the LLM doesn't think to search for
- Long exploration chains in large repos
- Relies entirely on the LM's search strategy, which varies

**Key insight from the authors:** "As LMs become more capable, complex tool interfaces are less
needed. The LM can figure out how to use bash to do what it wants."

**Key reference:** [Mini-SWE-agent GitHub](https://github.com/SWE-agent/mini-SWE-agent)

---

### 3. Full Repository Indexing (Vector RAG)

**Used by:** Cursor, GitHub Copilot Enterprise, Sourcegraph Cody

**How it works:**
- Index entire codebase into vector database
- Chunk files with overlap
- Generate embeddings for each chunk
- At query time: semantic search across all chunks
- Often combined with BM25 (hybrid search)

**Strengths:**
- Best semantic retrieval (finds "revenue growth" when user asks "sales trends")
- Fast at query time (pre-computed index)
- Scales to very large repos
- Cursor claims near-instant codebase Q&A

**Weaknesses:**
- Expensive indexing (especially with contextual embeddings)
- Chunk boundaries lose context (the Anthropic problem)
- Embedding model may not understand code-specific queries well
- Requires infrastructure (vector DB, embedding service)
- 5-7% retrieval failure rate even with best techniques

**Key refinement — Anthropic Contextual Retrieval (Sep 2024):**
- Prepend chunk-specific context to each chunk before embedding
- "This is from ACME Corp's Q2 2023 SEC filing..." →
  reduces retrieval failures by 49%
- Adding Cohere reranker: 67% reduction in failures
- Cost: ~$1.02 per million document tokens (with prompt caching)

**Key reference:** [Anthropic Contextual Retrieval](https://www.anthropic.com/news/contextual-retrieval)

---

### 4. IDE-Native Code Intelligence

**Used by:** Cursor, VS Code Copilot, JetBrains AI

**How it works:**
- Tight IDE integration captures workspace context automatically
- Open tabs, visible files, cursor position all feed into context
- Tree-sitter for symbol definitions
- Language server (LSP) for references, go-to-definition
- Diff-aware context (only sends changed portions)

**Strengths:**
- Rich context from IDE state (which file is open, cursor position)
- LSP gives precise symbol resolution
- Low latency (local processing)
- Can see what the developer is looking at

**Weaknesses:**
- Only works within an IDE
- Context is limited to what's in the workspace/editor
- Doesn't solve the fundamental problem for autonomous agents

---

### 5. Multi-Agent / Subagent Architectures

**Used by:** OpenCode (explore/worker routing), OpenAI Codex (subagents),
Claude Code (delegation)

**How it works:**
- Orchestrator dispatches specialized subagents for different tasks
- Explorer agent: bulk search only (read-only)
- Worker agent: implementation in fresh context (write-scoped)
- Review agent: code review in fresh context
- Subagents work in parallel, results merged by orchestrator

**Strengths:**
- Fresh context per subagent (avoids context pollution)
- Parallel execution (faster for large tasks)
- Specialization (explorer can use different tools than worker)
- Bounded risk (each subagent has limited scope)

**Weaknesses:**
- Coordination overhead
- Expensive (multiple model calls)
- Orchestrator must accurately route
- Subagent results may conflict

---

### 6. Large Context Window + Prompt Caching

**Used by:** Anthropic Claude (200K), Gemini (1M+), GPT-4 (128K)

**How it works:**
- Simply fit more code into the context window
- Prompt caching avoids re-sending the same content
- Anthropic's prompt caching: 90% cost reduction for repeated prefixes
- Gemini's 1M context: can fit ~750K tokens in active use

**Strengths:**
- Simplest approach
- No retrieval errors (everything is in context)
- Works well for small-to-medium repos
- Prompt caching makes it affordable for repeated access

**Weaknesses:**
- Still doesn't work for large repos (1M files)
- Even 1M tokens isn't enough for a big TypeScript project
- Cost scales linearly with tokens sent
- More tokens = more distraction for the model

---

## Comparative Analysis

| Approach | Startup Cost | Per-Query Cost | Recall | Precision | Autonomy |
|----------|-------------|---------------|--------|-----------|----------|
| Repo Map (1K tokens) | Low (sec) | ~0.001¢ | Low | High | None |
| Bash Exploration | Low | High (many turns) | Medium | Very High | Full |
| Vector RAG | High (hours) | Low (~0.05¢) | High | Medium | None |
| Contextual Retrieval | Medium | Low-Medium | Very High | High | None |
| Multi-Agent | Low | High | High | High | Full |
| Large Context | None | Very High | Very High | High | None |

---

## The "Reasonably Perfect" Solution

**There is no single perfect solution** — the problem is fundamentally constrained by
the finite context window. However, the **combination of all techniques in a layered
architecture** approximates it well.

### Recommended Architecture (optimal stack as of May 2026)

```
┌─────────────────────────────────────────────────┐
│ Layer 1: Static Repo Map (always in base prompt) │
│  • Tree-sitter → symbols + signatures           │
│  • PageRank on dep graph → ranked importance    │
│  • Fits into 1-4K token budget                  │
│  • Gives the LLM a "table of contents"          │
├─────────────────────────────────────────────────┤
│ Layer 2: Hybrid Retrieval (on demand)           │
│  • BM25 for exact matches (fast, precise)       │
│  • Embedding search for semantic matches        │
│  • Anthropic-style contextual enrichment        │
│  • Optional: reranking via Cohere/Voyage        │
│  • Returns top-20 chunks to context             │
├─────────────────────────────────────────────────┤
│ Layer 3: Agentic Exploration (autonomous)       │
│  • Bash-only approach (mini-swe-agent style)    │
│  • LM uses find/grep/cat to explore             │
│  • Directed by repo map + retrieval results     │
│  • Docker sandboxed for safety                  │
├─────────────────────────────────────────────────┤
│ Layer 4: Context Management (runtime)           │
│  • Sliding window of recent file reads          │
│  • Token budget enforcement                     │
│  • Compaction/summarization of old context      │
│  • Prompt caching for repeated documents        │
├─────────────────────────────────────────────────┤
│ Layer 5: Subagent Dispatch (parallel)           │
│  • Fresh context for large tasks                │
│  • Separation of concerns (reader vs writer)    │
│  • Parallel exploration + implementation        │
└─────────────────────────────────────────────────┘
```

### Key Design Principle

From mini-SWE-agent's breakthrough: **The simpler the agent interface, the more
capable the model feels.** Complex custom tool interfaces (file_surfer, str_replace_editor,
etc.) are being replaced by bash-only approaches. The LM already knows how to use bash —
let it.

### Practical Constraints for agentic-workflows

| Constraint | Impact | Mitigation |
|-----------|--------|------------|
| 4GB RAM on WSL2 | Can't run local embeddings or vector DB | Use API-based embeddings or skip; BM25 works without GPU |
| No GPU | No local model inference | All models via API |
| Disk space (30GB+ free) | Can cache tree-sitter data | SQLite cache works fine |
| Bash availability | All tools work | Unix-native |

### What This Means for Our Hub

**Current state:**
- `/repo-map` command exists (tree-sitter based)
- Explore/Worker subagent routing exists
- Skills provide structured workflows
- Batch file reads (3 at a time)

**Gaps vs optimal:**
| Capability | Current | Optimal |
|-----------|---------|---------|
| Repo map frequency | On demand | Auto-generated on git commit |
| Retrieval | grep only | BM25 + optional embeddings |
| Contextual enrichment | None | Prepending chunk context |
| File read batching | 3 at a time | Smart retrieval-based selection |
| Agent exploration | Tool-based (explore, Read, Grep) | Could be more bash-driven |

**Key insight:** The main limitation in our hub isn't the tool restrictions per se —
it's the **lack of a pre-computed, searchable index** that provides instant retrieval.
The "3 at a time" file read limit is a symptom, not the cause. Even with unlimited
reads, a dumb sequential scan is inferior to a ranked retrieval.

### The One Change That Would Matter Most

If we could make ONE improvement for maximum impact, it would be:

**Implement a lightweight BM25 index** (no GPU, no vector DB) over the workspace
that lets file searches reach any file instantly, ranked by relevance to the current
query. This doesn't need embeddings — BM25 alone captures keyword/symbol matching
which covers most code search needs. Tree-sitter AST data can boost it further.

---

## Sources

1. [Aider RepoMap Documentation](https://aider.chat/docs/repomap.html)
2. [Aider Blog: Building a better repo map with tree-sitter](https://aider.chat/2023/10/22/repomap.html)
3. [Aider repomap.py source (867 lines)](https://github.com/Aider-AI/aider/blob/main/aider/repomap.py)
4. [Mini-SWE-agent: 100-line bash-only agent](https://github.com/SWE-agent/mini-SWE-agent)
5. [SWE-agent paper (NeurIPS 2024)](https://arxiv.org/abs/2405.15793)
6. [Anthropic Contextual Retrieval](https://www.anthropic.com/news/contextual-retrieval)
7. [OpenAI Codex CLI](https://developers.openai.com/codex)
8. [Sourcegraph Cody Context](https://docs.sourcegraph.com/cody/core-concepts/context)
9. [Cursor (various docs)](https://docs.cursor.com)
10. [GitHub Copilot](https://github.com/features/copilot)

---

## Conclusion

**Yes, the restrictions exist because of model limitations** — finite context windows,
imperfect retrieval, and the quadratic cost of attention over long sequences.

**No, there isn't a single "perfect" solution**, but the layered architecture
described above is the practical state of the art. The most important trend is
**simplicity: give the agent bash and a good repo index, then get out of its way.**

The mini-SWE-agent result is the most telling data point: a 100-line bash-only
agent matches or beats complex custom-tool agents on SWE-bench. This suggests that
as models get smarter, the optimal agent scaffold gets simpler, not more complex.
