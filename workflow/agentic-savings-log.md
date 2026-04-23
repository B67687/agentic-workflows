# Agentic Token Savings Log

Track actual token/model usage to measure savings vs monolithic K2.6.

## How to Log a Session

After each work session, fill one row:

```
| Date | Task Type | Agent Used | Model | Est. Tokens | vs K2.6 | Notes |
```

**Est. Tokens:** Rough count based on output length (or check OpenCode console for exact numbers)
**vs K2.6:** Cheaper / Same / More expensive

---

## Session Log

| Date | Task Type | Agent Used | Model | Est. Req Cost | vs K2.6 | Notes |
|------|-----------|------------|-------|--------------|---------|-------|
| 2026-04-22 | Find file | Explorer | M2.5 | $0.0019 | 5.5× cheaper | Auto-routed |
| 2026-04-22 | Find files | Explorer | M2.5 | $0.0019 | 5.5× cheaper | Auto-routed |
| 2026-04-22 | Explain physics | Debugger | K2.6 | $0.0104 | Same | Manual @debugger |
| 2026-04-22 | Write script | Drafter | M2.7 | $0.0035 | 3× cheaper | Manual @drafter |
| 2026-04-22 | Audit configs | Reviewer | GLM-5.1 | $0.0136 | 1.3× more | Manual @reviewer |

### Running Totals (This Session)

| Metric | Value |
|--------|-------|
| Tasks routed to cheaper models | 3/5 (60%) |
| Tasks at same cost | 1/5 (20%) |
| Tasks at higher cost | 1/5 (20%) |
| Actual cost (agentic) | ~$0.0313 |
| Baseline cost (all K2.6) | ~$0.0520 |
| **Estimated savings** | **~40%** |

---

## Weekly Summary Template

Copy this at the end of each week:

```
## Week of YYYY-MM-DD

| Metric | Value |
|--------|-------|
| Total tasks | |
| Auto-routed tasks | |
| Manual @mention tasks | |
| Avg savings per task | |
| Total estimated savings | |
| Quality issues from routing | |
| Times reverted to monolithic | |

### What worked well:
- 

### What needs improvement:
- 

### Model quota usage:
| Model | Requests Used | Quota Status |
|-------|--------------|--------------|
| M2.5 | | |
| M2.7 | | |
| K2.6 | | |
| GLM-5.1 | | |
```

---

## Notes

- Cost estimates based on OpenCode Go $12/5hr limits (M2.5=6,300 req, M2.7=3,400 req, K2.6=1,150 req, GLM-5.1=880 req)
- Actual costs vary by input/output token counts
- For precise numbers, check opencode.ai/auth console
- Quality preservation is harder to quantify than cost — note any routing mistakes in "What needs improvement"
