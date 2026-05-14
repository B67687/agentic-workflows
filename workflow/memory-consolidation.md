# Memory Consolidation Workflow

Patterns for deduplicating, merging, and prioritizing learnings and observations,
extracted from [Mem0](https://github.com/mem0ai/mem0) (universal memory layer for
AI agents).

**Source:** [Mem0 v3](https://github.com/mem0ai/mem0) (April 2026 release:
single-pass ADD-only, entity linking, multi-signal retrieval, temporal reasoning)

---

## Core Patterns

### 1. Deduplication

Duplicate memories degrade retrieval quality. Consolidate by comparing normalized
content and merging similar entries.

**Our implementation:** `scripts/consolidate-memory.sh`

```bash
bash ./scripts/consolidate-memory.sh            # Consolidate and deduplicate
bash ./scripts/consolidate-memory.sh --dry-run  # Preview before writing
bash ./scripts/consolidate-memory.sh --stats    # Tag frequency report
```

Automatically runs as step 4 of `bash ./scripts/task-retrospect.sh`.

### 2. Preference Memory

Track user preferences, tool preferences, and recurring patterns as structured
data, not freeform text. The MCP memory system (`@agentmemory/mcp`) supports
structured memory via `memory_save(type="preference", concepts="...")`.

**Pattern:**
```
memory_save(
    type="preference",
    content="User prefers [X] over [Y]",
    concepts="preference, work-style",
    files=""
)
```

Preferences are consolidated separately from task memories, so they survive
session resets and guide future sessions.

### 3. Importance Scoring

Not all memories are equally valuable. Tag learnings with importance signals:

| Signal | Tag | Meaning |
|--------|-----|---------|
| Error/fix pattern | `bug, fix` | High importance -- prevents repeated debugging |
| User preference | `preference, style` | High importance -- affects interaction quality |
| Architecture decision | `architecture, design` | High importance -- affects all future work |
| Tool quirk | `tool, caveat` | Medium importance -- workaround knowledge |
| Temporary state | `temp, status` | Low importance -- will be stale in a week |

### 4. Single-Pass ADD-Only (Mem0 v3)

The biggest simplification from Mem0 v3: **never update or delete memories.**
Only append new ones. This eliminates the dedup/merge complexity entirely.

**Before (v2):** add -> check for duplicates -> merge or delete stale -> re-embed
**After (v3):** add -> done

How it works:
- Every memory add is a single LLM call -- no UPDATE/DELETE cycle
- Entity extraction and linking happen during the add, not as a separate pass
- Retrieval handles freshness via temporal scoring (not deletion)

**Why this works:** Instead of trying to maintain a single "correct" state of
knowledge, you maintain a stream of facts and let the retrieval layer decide
what's relevant at query time. This matches how real conversation works --
people repeat, refine, and sometimes contradict themselves.

**Our application:** Currently `consolidate-memory.sh` deduplicates by comparing
content similarity. The ADD-only pattern suggests: skip dedup entirely and rely on
retrieval-level scoring. This is safe when we add the entity extraction and
temporal scoring patterns below.

```bash
# ADD-only flow (future direction):
bash ./scripts/consolidate-memory.sh --entity-extract  # Extract + link entities per entry
# Search naturally ranks relevant + recent results higher
```

### 5. Entity Extraction and Linking (Mem0 v3)

Entities (tools, concepts, people, commands) are extracted during memory add and
linked across memories. This enables entity-anchored retrieval -- "find everything
about pipeline-run.sh" -- without relying on exact keyword matches.

**Pattern:**
```
Input: "Pipeline-run.sh now supports CrewAI-style route subcommand"
Extracted entities:
  - pipeline-run.sh (tool)
  - route (command)
  - CrewAI (source)

Linked across memories:
  - [pipeline-run.sh] -> [guardrail subcommand, init, update, next]
  - [route] -> [CrewAI Flow @router pattern]
  - [CrewAI] -> [Flow, routing, @router pattern]
```

**Our implementation:** `scripts/consolidate-memory.sh --entity-extract`
extracts entities from `.learnings.jsonl` entries and appends entity tags.

### 6. Multi-Signal Retrieval (Mem0 v3)

Instead of a single search method, score and fuse three signals in parallel:

| Signal | Our mapping | When it wins |
|--------|-------------|-------------|
| Semantic (embedding) | agentmemory MCP `memory_smart_search` | Conceptual similarity |
| Keyword (BM25) | `scripts/search-index.sh` | Exact tool/command names |
| Entity matching | `--entity-extract` tags in `.learnings.jsonl` | Cross-reference lookup |

**Fusion:** Score each signal independently, then combine. The entity signal
boosts results that share entity tags with the query -- even when the semantic
and keyword scores are low.

### 7. Temporal Reasoning (Mem0 v3)

Time-aware retrieval ranks the right dated instance for queries about current
state, past events, and upcoming plans. Each memory carries a timestamp, and
the retrieval layer can answer time-bound questions.

**Query types and their temporal behavior:**

| Query type | Example | Temporal behavior |
|------------|---------|-------------------|
| Current state | "What's the current pipeline design?" | Most recent matching memory wins |
| Past event | "Why was this decision made?" | Match the timestamp window |
| Sequential | "What changed between v1 and v2?" | Two or more timestamps compared |
| Pattern over time | "How has our approach evolved?" | Multiple timestamps synthesized |

Our `consolidate-memory.sh --entity-extract` automatically preserves the
timestamp from each `.learnings.jsonl` entry, enabling temporal queries via
`grep` + `sort` on the entity-tagged entries.

## Periodic Consolidation

Run consolidation regularly to prevent memory bloat:

```bash
# After every meaningful session
bash ./scripts/task-retrospect.sh "insight" tags

# Entity extraction (after adding new learnings)
bash ./scripts/consolidate-memory.sh --entity-extract

# Check tag distribution
bash ./scripts/consolidate-memory.sh --stats
```

---

## Verification

After consolidation:
- [ ] `.learnings.jsonl` has fewer entries (dedup worked) -- OR -- entries have
      entity tags if using ADD-only flow
- [ ] No important content was lost (check `--dry-run` first)
- [ ] Critical patterns (bugs, preferences) preserved
- [ ] Entity tags link related entries across sessions
- [ ] `agentmemory memory_recall` still finds needed information

## References

- [Mem0 v3 Research](https://mem0.ai/research) -- single-pass algorithm, benchmarks
- [Mem0 GitHub](https://github.com/mem0ai/mem0)
- [Mem0 Migration Guide](https://docs.mem0.ai/migration/oss-v2-to-v3)
