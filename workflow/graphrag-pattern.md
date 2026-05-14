# GraphRAG Pattern: Community Hierarchy + Dual-Mode Query

**Source:** [Microsoft GraphRAG](https://github.com/microsoft/graphrag) --
Modular graph-based RAG system. [Research paper](https://arxiv.org/pdf/2404.16130).

GraphRAG is a knowledge-graph approach to retrieval. Instead of flat
semantic search (chunk-embed-retrieve), it builds a hierarchy of entity
communities from unstructured text and uses those structures for query-time
retrieval. This workflow documents how that pattern applies to SwarmVault
and workspace search.

## Core Insight

Two types of queries need fundamentally different retrieval strategies:

| Query Type | Example | Needs |
|------------|---------|-------|
| **Global** (holistic) | "What agent dispatch tools exist?" | Synthesis across many related entities |
| **Local** (specific) | "How does pipeline-run.sh handle errors?" | Focused entity lookup + immediate context |

Flat semantic search optimizes for neither. GraphRAG solves this by
building two structures during indexing and using both at query time.

## Pattern Overview

```
Indexing Phase:
  Raw text -> Entity extraction -> Knowledge graph -> Community detection
  -> Bottom-up summarization (per community level)

Query Phase:
  Global question -> Use community summaries (holistic answer)
  Local question  -> Fan out from entity + its graph neighbors (specific answer)
```

## Applying to SwarmVault

### 1. Source Tiers

SwarmVault's wiki pages naturally form a community hierarchy by page type:

| Tier | Source | GraphRAG Analog |
|------|--------|-----------------|
| Raw sources (`raw/`) | Original ingested docs | TextUnits |
| Entity pages (`wiki/concepts/`) | Individual tools, scripts, skills | Graph entities |
| Community pages (`wiki/communities/`) | Groups of related entities (optional compile target) | Community summaries |
| Dashboard (`wiki/graph/report.md`, `wiki/index.md`) | Cross-cutting summaries | Top-level community summary |

### 2. Community Detection

The SwarmVault graph already has entity types and relationship types
defined in `swarmvault.schema.md`. Community detection groups related
entities into clusters. Heuristics that work without a full Leiden
implementation:

```bash
# Find entities that share 2+ relationship targets
# (these are likely in the same community)
grep -l "dispatches_to" wiki/concepts/*.md | xargs grep -l "pipeline-run" | head -5

# Group by source_ids overlap
# Pages that cite the same source documents are related communities
rg "source_ids:" wiki/ -l | xargs rg -l "session-state\|AGENTS.md" | head -10
```

For full Leiden-based clustering, export the graph and use the Graspologic
library (as GraphRAG does) or a Python network analysis tool.

### 3. Dual-Mode Query Strategy

#### Local Search (Specific Entity)

Use when you know what you're looking for: a tool name, a script, a skill.

```bash
# 1. Find the entity
bash ./scripts/search-index.sh "pipeline-run.sh"

# 2. Check the entity page for relationships
cat wiki/concepts/pipeline-run.md | grep -A2 "^relates_to\|^uses\|^dispatches_to" || true

# 3. Find neighbors (pages that reference the same sources)
rg -l "pipeline-run" wiki/concepts/ | grep -v "pipeline-run.md"
```

This fan-out pattern gives you the entity + its immediate graph context --
the local search analog from GraphRAG.

#### Global Search (Holistic Understanding)

Use for broad questions: "What's the architecture?", "How do tools connect?"

```bash
# 1. Search the community summaries for a broad pattern
bash ./scripts/search-index.sh "tool orchestration"

# 2. Check the graph report for high-level structure
cat wiki/graph/report.md | head -40

# 3. Synthesize across communities
#    Community pages group related entities. Check the relevant ones.
ls wiki/communities/ | grep -i "agent\|pipeline\|tool"
```

Community summaries replace raw chunks in the LLM context, giving the model
a synthesized understanding of a topic area rather than scattered excerpts.

### 4. Query Mode Selection

When choosing a search strategy, match the question to the mode:

```
"how does X work?"          -> Local search (entity + neighbors)
"where is X defined?"       -> Local search (exact entity)
"what tools exist for Y?"   -> Local search (category/type filter)
"what are the patterns?"    -> Global search (community summaries)
"how does the system work?" -> Global search (graph report + communities)
"compare X and Y"           -> Both: local for each + global synthesis
"why was this decision?"    -> Local search on the entity + check session-state
```

## Verification

When applying this pattern:

- [ ] Question type identified (global or local) before choosing search strategy
- [ ] Local search: entity found, neighbors checked, context adequate
- [ ] Global search: community summaries used, not raw chunk fragments
- [ ] Sources cited inline (`[GraphRAG](URL)` format)
- [ ] Community hierarchy documented in SwarmVault when new communities added

## References

- [GraphRAG GitHub](https://github.com/microsoft/graphrag)
- [GraphRAG Research Paper](https://arxiv.org/pdf/2404.16130)
- [Leiden Clustering Algorithm](https://arxiv.org/pdf/1810.08473.pdf)
- [SwarmVault Schema](../swarmvault.schema.md)
