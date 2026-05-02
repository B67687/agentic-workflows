---
description: Retrieve only the local context relevant to the current step
---

Use the repo's local retrieval helper instead of reading broad context by hand.

Run:
`bash ./retrieve-context.sh "$ARGUMENTS"`

Then respond compactly with:
- the top matches
- what to read next
- any obvious missing context

If `$ARGUMENTS` is empty, ask for the query in one short sentence.
