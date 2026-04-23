# Merge Log

Cross-domain merge history. Records all insights that have been merged from topic folders into the central AI Prompting knowledge base.

## How It Works

When an insight is merged from any topic folder into the AI Prompting central knowledge base:
1. The insight is added to the appropriate doc in AI Prompting/docs/
2. A bidirectional back-link note is created in the source folder's topic-insights.md
3. The merge is recorded here for traceability

## Merge Entry Format

```markdown
- **Merge ID**: [unique-id]
  - **Source folder**: [folder-name]
  - **Source file**: [path/to/topic-insights.md]
  - **Original text**: [what was originally captured]
  - **Target doc**: AI Prompting/[target-doc].md
  - **Confidence**: Level [1-4]
  - **Tags**: [any detected tags]
  - **Generalized wording**: [how it was phrased in target doc]
  - **Merged at**: [timestamp]
  - **Bidirectional link**: Created in source folder
```

## Metadata

```yaml
---
total_merges: 0
last_merge_at: null
central_hub: AI Prompting
version: 1.0
created: 2026-04-19
---
```

## Merge History

*No merges recorded yet. Run merge-and-propagate.ps1 after reviewing cross-domain-candidates.md to execute a merge.*
