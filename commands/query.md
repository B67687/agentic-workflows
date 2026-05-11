---
description: Search the full workspace via BM25 ranked index
---

Use the repo's BM25 search index instead of manual file scanning. Results are
ranked by relevance across ALL text files in the workspace.

If the index has not been built yet, build it first:
`bash ./scripts/build-index.sh`

Run:
`bash ./scripts/search-index.sh "$ARGUMENTS"`

Then respond compactly with:
- the top matches (show scores, paths, and snippets)
- what to read next
- any obvious missing context

If `$ARGUMENTS` is empty, ask for the query in one short sentence.
