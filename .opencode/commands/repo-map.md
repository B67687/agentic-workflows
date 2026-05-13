---
description: Build a compact, ranked map of the workspace (tree-sitter + PageRank)
---

Use this when the folder is unfamiliar, the task is broad, or research needs
orientation before reading files. The map uses tree-sitter to extract symbols,
builds an import dependency graph, runs PageRank for importance, and outputs
the top-N most relevant symbols within a token budget.

Run:
`bash ./scripts/repo-map.sh ${ARGUMENTS:-.}`

Optional flags (appended to ARGUMENTS):
- `--max-tokens N` --- limit output to N tokens (default: 2048)
- `--no-headings` --- skip markdown heading extraction
- `--no-symbols` --- skip code symbol extraction

Examples:
- `bash ./scripts/repo-map.sh` --- default map
- `bash ./scripts/repo-map.sh /path/to/project --max-tokens 1024` --- compact map

Then respond compactly with:
- the highest-ranked files and their key symbols
- what to inspect next
- any obvious gaps

Do not treat the map as proof. It is a navigation aid before targeted reading.
