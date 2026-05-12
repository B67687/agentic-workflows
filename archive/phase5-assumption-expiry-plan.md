# Phase 5 Implementation Plan — Assumption Expiry Pattern

**Status:** Implemented. This is a retroactive plan document.

## Goal

Give every non-verifiable claim in the workspace an expiry date (TTL) and provide
a downstream challenge process so stale assumptions don't silently degrade agent quality.

## Authoritative Sources

- Martin Fowler, "Technical Debt Quadrant" (2009) — prudent-inadvertent debt classification
- Manny Lehman, "Laws of Software Evolution" (1985) — complexity increases without active work
- Bertrand Meyer, "Design by Contract" (1988) — precondition verification must fail hard
- Wikipedia, "Software Rot" — active rot vs dormant rot classification

## Scope

- `session-state.json` `residualRisk` entries → structured `assumptions[]` array with TTL
- New script: `scripts/assumption-expiry.sh` with check/list/mark/dismiss/init modes
- New doc: `docs/assumption-expiry.md` with full pattern documentation
- `detect-gaps.sh` Check 6: expired assumption detection at session start
- `AGENTS.md`: 3 integration points (High-Signal Files, Key Rules, Deep References)

## Milestones

| # | Milestone | Status |
|---|-----------|--------|
| 1 | Research: 4 authoritative sources gathered and synthesized | done |
| 2 | Design: pattern spec written to `docs/assumption-expiry.md` | done |
| 3 | Script: `assumption-expiry.sh` — check, list, mark, dismiss, init | done |
| 4 | Integration: `detect-gaps.sh` Check 6 | done |
| 5 | Integration: `session-state.json` assumptions field | done |
| 6 | Integration: `AGENTS.md` references | done |
| 7 | Verification: end-to-end testing, backward compat checks | done |

## Verification

- [x] `bash ./scripts/assumption-expiry.sh check` — exit 0 if current, exit 1 if overdue
- [x] init migrates existing residualRisk without data loss
- [x] mark resets TTL to now + TTL_P2 days
- [x] dismiss removes from active tracking, keeps in history
- [x] detect-gaps.sh flags expired assumptions
- [x] Backward compat: original residualRisk string still works
