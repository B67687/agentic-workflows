# Systems Health: [repo name]

**Run:** [date]
**Verdict:** [Healthy / N problems / Backing up]

## Stocks
| Stock | Level | Healthy | Trend |
|-------|-------|---------|-------|
| Backlog | [N open issues] | Stable/shrinking | ─/▲/▼ |
| Open PRs | [N, oldest] | < 5, < 3d old | ─/▲/▼ |
| Open bugs | [N] | Stable/shrinking | ─/▲/▼ |
| Test count | [N] | Growing | ─/▲/▼ |

## Flows
| Flow | Rate | Signal |
|------|------|--------|
| Stories in | [N/week] | Demand |
| Stories out | [N/week] | Throughput |
| Cycle time | [N days median] | Speed |
| Review time | [N hours median] | Bottleneck |
| Bug inflow | [N/week] | Quality |
| Deploy freq | [N/week] | Delivery |

## Feedback Loops
- CI gate: [working / broken / missing]
- Code review: [working / rubber-stamped / stuck]
- Bug triage: [working / accumulating]
- Test coverage loop: [positive / negative / none]

## Complexity Trends
| Signal | Current | Trend |
|--------|---------|-------|
| Change amplification | [N files/commit] | ─/▲/▼ |
| Shotgun surgery | [N%] | ─/▲/▼ |
| Cognitive load | [large+churn files] | ─/▲/▼ |
| Unknown unknowns | [N% PRs no tests] | ─/▲/▼ |

## Diagnosis

### Problem 1: [name]
- Evidence: [data]
- Impact: [effect on delivery]
- Rx: [cheapest fix]
