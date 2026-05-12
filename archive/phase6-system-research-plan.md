# Phase 6 Implementation Plan — System Research

**Status:** Implemented. This is a retroactive plan document.

## Goal

Research authoritative sources on building enduring, high-productivity systems that
keep up with the times, and synthesize them into a unified framework for this workspace.

## Authoritative Sources

| Source | Author(s) | Year | Core Idea |
|--------|-----------|------|-----------|
| Building Evolutionary Architectures | Ford, Parsons, Kua | 2017 | Fitness functions for guided incremental change |
| Antifragile | Taleb | 2012 | Systems that gain from disorder |
| Technical Debt Quadrant | Fowler | 2009 | Prudent-inadvertent debt is inevitable |
| Design by Contract | Meyer | 1988 | Preconditions must fail hard |
| Lehman's Laws of Evolution | Lehman | 1974-1996 | Complexity increases without active work |
| The Pragmatic Programmer | Hunt & Thomas | 1999/2019 | Don't live with broken windows |
| Is High Quality Software Worth the Cost? | Fowler | 2019 | Internal quality is cheaper |
| DORA State of DevOps | Google | 2014-present | Elite teams ship fast AND are reliable |
| Software Engineering at Google | Winters et al. | 2020 | Culture, not just code |

## Scope

- `research/well-maintained-system-research.md` — synthesized writeup
- Cross-reference: how each source maps to existing workspace implementations

## Breakdown

| # | Step | Status |
|---|------|--------|
| 1 | Fetch: Building Evolutionary Architectures (Thoughtworks) | done |
| 2 | Fetch: Antifragility (Wikipedia) | done |
| 3 | Fetch: Technical Debt (Wikipedia) | done |
| 4 | Fetch: Is High Quality Software Worth the Cost? (Fowler) | done |
| 5 | Synthesize: 9 sources into unified framework | done |
| 6 | Map: each source to existing workspace implementation | done |

## Synthesis

No single authoritative source covers "the whole system" because the domain spans
software engineering, risk/mathematics, and management/operations. The workspace
implements all nine sources in combination:

| Source | Implementation in Workspace |
|--------|---------------------------|
| Evolutionary Architecture | `assumption-expiry.sh` + `detect-gaps.sh` |
| Antifragility | `doubt-adversarial.sh`, assumption TTL |
| Technical Debt Quadrant | `assumptions[]` TTL tracking |
| Design by Contract | `assumption-expiry.sh check` as precondition verification |
| Lehman's Laws | Session audits, `context-pressure.sh` |
| Pragmatic Programmer | Companion scripts, `checkpoint-commit.sh` |
| Quality Economics | Macro-to-micro audit cycle |
| DORA | Smoke tests, trunk-based development |
| Google SRE | `/counsel`, code review skill |

## Remaining

- [ ] Reference `research/well-maintained-system-research.md` from AGENTS.md hot path
