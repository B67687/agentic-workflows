# Memory Consolidation Workflow

Patterns for deduplicating, merging, and prioritizing learnings and observations,
extracted from Mem0's memory system approach.

**Source:** [Mem0 --- mem0ai/mem0](https://github.com/mem0ai/mem0) (memory consolidation, preference learning)

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
| Error/fix pattern | `bug, fix` | High importance --- prevents repeated debugging |
| User preference | `preference, style` | High importance --- affects interaction quality |
| Architecture decision | `architecture, design` | High importance --- affects all future work |
| Tool quirk | `tool, caveat` | Medium importance --- workaround knowledge |
| Temporary state | `temp, status` | Low importance --- will be stale in a week |

### 4. Periodic Consolidation

Run consolidation regularly to prevent memory bloat:

```bash
# After every meaningful session
bash ./scripts/task-retrospect.sh "insight" tags

# Periodically to clean up
bash ./scripts/consolidate-memory.sh
bash ./scripts/consolidate-memory.sh --stats
```

---

## Verification

After consolidation:
- [ ] `.learnings.jsonl` has fewer entries (dedup worked)
- [ ] No important content was lost (check `--dry-run` first)
- [ ] Critical patterns (bugs, preferences) preserved
- [ ] `agentmemory memory_recall` still finds needed information
