# Learnings

Append-only file. Each entry records what blocked agent autonomy and the fix.

## Format
```
[YYYY-MM-DD] --- [trigger event]
- [what happened] -> [gap type] -> [specific fix]
```

## Gap Types
| Gap | Agent lacked... |
|-----|-----------------|
| Context | Information (missing CLAUDE.md, ADRs, conventions) |
| Harness | Tools or access (missing MCP, CLI, skill, permissions) |
| Feedback | Way to verify (no tests, no browser QA) |
| Design | Code complexity (god files, high coupling) |
| Scope | Boundaries (ambiguous task, no AGENTS.md) |

---

## Entries

[YYYY-MM-DD] --- [trigger]
- [finding] -> [gap type] -> [fix action]
