# Agentic Context Hygiene Log

Track subagent usage to measure context quality, not cost savings.

**Why not cost?** The per-request cost difference between models is often zero now (Copilot Student = free Sonnet 4.6, Gemini AI Studio = 14,400 free req/day, K2.6 on promotion). The real benefit of subsessions is **fresh context**.

## How to Log a Session

After each work session, fill one row:

```
| Date | Task Type | Agent Used | Why Spawned | Context Quality | Notes |
```

**Why Spawned:** Fresh context / Parallel work / Different capability / Bulk search
**Context Quality:** Did the subagent produce better output because of the clean slate?

---

## Session Log

| Date | Task Type | Agent Used | Why Spawned | Context Quality | Notes |
|------|-----------|------------|-------------|-----------------|-------|
| 2026-04-22 | Find file | Explorer | Bulk search | N/A | Auto-routed, 50+ files |
| 2026-04-22 | Long session | Worker | Fresh context | Better | 20+ turns, quality was degrading |

---

## Weekly Summary Template

Copy this at the end of each week:

```
## Week of YYYY-MM-DD

| Metric | Value |
|--------|-------|
| Total tasks | |
| Handled directly | |
| Spawned Explorer | |
| Spawned Worker | |
| Times fresh context helped | |
| Times spawn was unnecessary | |

### What worked well:
- 

### What needs improvement:
- 

### Model usage:
| Model | Requests Used | Notes |
|-------|--------------|-------|
| Main AI (K2.6/Sonnet) | | |
| Explorer (M2.5 Free) | | |
| Worker (K2.6/M2.7) | | |
```

---

## Notes

- **Cost is no longer the primary metric.** Track whether fresh context actually improved output quality.
- **Explorer** (M2.5 Free) is still worth tracking for bulk searches — it's genuinely free and fast.
- **Worker** should only be spawned when: 15+ turns, topic shift, or quality degradation detected.
- If Worker is spawned frequently, consider whether sessions are too long or tasks too large.
