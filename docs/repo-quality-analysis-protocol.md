# Repository Quality Analysis Protocol

Use this protocol when evaluating repository structure, identifying compression opportunities, or deciding whether content should be kept, merged, moved, or deleted.

## Core Principle

Before flagging anything as redundant or unnecessary, understand WHAT the content uniquely provides and WHY it exists. Surface-level similarity is not redundancy.

---

## The Analysis Framework

### Step 1: Articulate the File's Purpose

For each file under review:

1. **Read the file** - completely, not just headers
2. **Identify the audience** - who is this for?
3. **State the unique claim** - what does this file provide that no other file provides?

### Step 2: Redundancy Check

**Only flag as redundant if:**
- Content is IDENTICAL to another file (not just similar)
- Content appears in 3+ places and is actively diverging (maintenance burden)
- The duplication serves no structural purpose

**Do NOT flag as redundant if:**
- Same topic from a different perspective (one is synthesis, one is deep-dive)
- Same principle for different audiences (human vs AI vs tool)
- One file references another (this is linking, not redundancy)
- Content serves a different purpose (provenance vs doctrine vs reference)

### Step 3: Audience Awareness

| Audience | File Characteristics |
|----------|---------------------|
| Human reader | Narrative, accessible language, examples |
| AI agent | Condensed, indexed, operational directives |
| Tool system | Scripts, configs, executable templates |
| Provenance | Citations, sources, attribution |

### Step 4: Orphan Detection

**Before declaring a file an orphan:**
- Search ALL files for links TO this file
- Check table of contents, reference sections, AGENTS.md templates
- Verify the file is truly unused, not just poorly linked

### Step 5: Ask Contradiction Questions

For every flagged issue, ask:

1. "What would CONTRADICT my redundancy claim?"
2. "What unique value would be LOST if I remove this?"
3. "Is this serving a DIFFERENT AUDIENCE than I initially thought?"
4. "Am I confusing 'similar' with 'redundant'?"

If you cannot answer these confidently, do not flag the file.

### Step 6: Decision Framework

| Finding | Decision | Rationale |
|---------|----------|-----------|
| Identical content in 3+ places | Merge | Maintenance burden |
| Substantially overlapping, one primary source | Keep primary, reference from secondary | Primary is authoritative |
| Different audience for similar content | Keep both | Intentional structure |
| Different purpose (provenance vs doctrine vs reference) | Keep both | Different information types |
| Orphan but useful content | Link or move | Preserve useful content |
| Orphan and obsolete | Archive | Preserve for reference |
| Cannot articulate WHY it's problematic | Keep | May be intentional |

---

## Common Analysis Errors (From Past Mistakes)

### Error 1: Surface-Level Pattern Matching

**Wrong:** Flagged `README.md` and `docs/CONTEXT.md` as nearly identical because both had folder structure blocks and "High-Signal Files" tables.

**Why it was wrong:** They serve different audiences (human navigation vs AI orientation). The duplication was intentional for each audience's convenience.

**Lesson:** Read to understand purpose before comparing.

### Error 2: Confusing Purpose with Content

**Wrong:** Flagged `authoritative-agent-best-practices.md` as having content "absorbed into archive/superseded/core-agent-doctrine.md."

**Why it was wrong:** The file's unique value is PROVENANCE - showing exactly what each vendor (OpenAI, Claude, GitHub Copilot, Simon Willison) emphasizes. This is source attribution, not doctrine.

**Lesson:** Distinguish doctrine (what to do) from provenance (where ideas came from).

### Error 3: Misidentifying Restatement vs Application

**Wrong:** Flagged `cross-project-memory-loop.md` as restating scope hierarchy from `project-rollout-template.md`.

**Why it was wrong:** `project-rollout-template.md` explains WHAT the hierarchy IS. `cross-project-memory-loop.md` explains WHEN to use each level. One is definition, one is application.

**Lesson:** Same hierarchy can appear in multiple files if each file applies it differently.

### Error 4: Flagging Useful Orphan Content

**Wrong:** Suggested `session-recovery-guide.md` should be deleted or moved because it was "too narrow" and had no references.

**Why it was wrong:** Narrow utility doesn't mean useless - it's OpenCode-specific troubleshooting. The issue was lack of links, not lack of value.

**Lesson:** Useful orphan content should be linked, not deleted.

---

## Recursive Self-Check Requirement

For any proposed compression or structural change:

1. **State the current state** - what exists, where
2. **State the proposed change** - what would change
3. **Ask contradiction questions** - what would make this wrong?
4. **Verify before acting** - can I articulate why this is correct?

If you cannot complete step 4 confidently, do not proceed.

---

## Protocol Summary

```
Before flagging: Read, understand purpose, identify audience
Redundancy: Identical content OR 3+ places diverging
Audience: Different audiences = intentional structure
Orphan: Search ALL references before declaring
Contradiction: Ask "what would contradict this?"
Decision: Keep when uncertain, merge only when necessary
```

---

## When to Use This Protocol

- Before recommending file deletions or merges
- During repository compression analysis
- When evaluating whether new content duplicates existing content
- When unsure whether content is "dead weight" or useful