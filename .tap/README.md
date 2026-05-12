# Project Memory (.tap/)

This directory stores durable, cross-session project knowledge optimized for agent consumption. Inspired by the teambrilliant/tap-skills methodology.

## Files

| File | Purpose | Created by |
|------|---------|------------|
| `tap-audit.md` | Repo readiness assessment (FULL/PARTIAL/MINIMAL) | `tap-audit` skill |
| `system-health.md` | Dev system health metrics (stocks, flows, loops) | `systems-health` skill |
| `learnings.md` | Append-only retrospective insights | `retrospective` skill |
| `architecture.md` | Architectural decisions (compressed, principle-driven) | `tap-audit` skill (seeded) |
| `product.md` | Product vision, focus, bets, non-goals (≤ 80 lines) | `curate-product-context` skill |

## Conventions

- Files are compact — optimized for agent context windows, not human prose
- Append-only for learnings (never overwrite)
- Architecture decisions: 2-4 lines per decision, capture the principle
- Product context: max 80 lines, refreshed when stale
- All files are markdown, plain text, git-tracked
