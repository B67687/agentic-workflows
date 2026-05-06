---
description: Run a counsel review with optional OpenRouter-backed model calls
---

Use this after `/counsel` says a counsel review is useful and the decision is worth the extra model calls.

Pass the plain decision on the same line, like:
`/counsel-run decide the first playable milestone for the Elemental Battlegrounds recreation`

First run dry:
`bash ./scripts/counsel-run.sh "$ARGUMENTS" --dry-run`

Only run live when `OPENROUTER_API_KEY` is set and the user explicitly wants live counsel calls:
`bash ./scripts/counsel-run.sh "$ARGUMENTS" --mode lite`

Return only the compressed recommendation, not all intermediate model chatter, unless the user asks for the role views.
