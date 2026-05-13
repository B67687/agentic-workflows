---
name: tighten-loop
description: "Harvest course-corrections from the current conversation and convert them into durable fixes so the agent doesn't need the same steer next time. Use when someone says tighten the loop, debrief this session, what should I update, what tripped you up. NOT for: repo readiness (-> loop-check), retros on past PRs/incidents (-> retrospective), or applying edits inline."
trigger-phrases: tighten the loop, debrief this session, what should I update, what tripped you up, what slowed you down, session debrief
handoffs: loop-check (for repo-level loop assessment), retrospective (for event-driven retro)
companion-script: scripts/tighten-loop.sh
---

# Tighten Loop

Answer one question: **"From the corrections I gave the agent in this conversation, what should I update so it doesn't need them next time?"**

**Companion script:** `scripts/tighten-loop.sh`
```bash
bash ./scripts/tighten-loop.sh classify "<steer>"  # classify by gap type
bash ./scripts/tighten-loop.sh route <intent>       # route to fix tool
bash ./scripts/tighten-loop.sh report [file]        # generate report
bash ./scripts/tighten-loop.sh template             # report table template
```

## Process

### 1. Harvest Steers

Scan the conversation for moments where the user redirected the agent:

- **Corrections** --- "no", "stop", "don't", "instead", "actually", "that's wrong"
- **Standing rules** --- "always do X", "never do Y", "from now on..."
- **Validated judgment calls** --- when user accepts a non-obvious choice without pushback
- **Repeated friction** --- reminded of same thing twice (strongest signal)

Skip: tactical exchanges, one-off task pivots, personal orchestration style.

If harvest is thin (≤2 steers after filtering), say so honestly. Empty harvest on a low-friction session is correct --- don't pad.

### 2. Classify by Gap Type

| Gap | Agent lacked... | Example |
|-----|-----------------|---------|
| **Context** | Information | Convention not in CLAUDE.md, missing ADR |
| **Harness** | Tools or access | Missing MCP, CLI, skill |
| **Feedback** | Way to verify | No tests for the area, no browser QA |
| **Scope** | Boundaries | Took on decision needing human judgment |

### 3. Route to Fix

Each finding routes to one intent:

| Intent | What it means | Where |
|--------|---------------|-------|
| `project-instruction` | Durable rule agent should follow | CLAUDE.md, AGENTS.md |
| `agent-config` | Harness behavior change | .claude/settings.json, opencode.jsonc |
| `tool-install` | Missing capability | Install the tool |
| `new-skill` | Repeated multi-step task | Create skills/<name>/SKILL.md |
| `skill-update` | Existing skill needs adjustment | Edit SKILL.md |
| `test-coverage` | Missing verification path | Add tests or QA scaffolding |

### 4. Present Findings

```
`★ Tighten Loop ──────────────────────────────────`
[N] steers harvested --- [N context] / [N harness] / [N feedback] / [N scope]
  ├─ [most impactful finding]
  ├─ [second]
  └─ [top recommended fix]
`─────────────────────────────────────────────────`
```

| # | Steer (paraphrased) | Gap | Intent | Concrete fix |
|---|---------------------|-----|--------|--------------|
| 1 | [steer] | [gap] | [intent] | [specific fix] |

### 5. Optionally Append to .tap/learnings.md

If `.tap/learnings.md` exists, append harvested findings:

```
[YYYY-MM-DD] --- session debrief
- [steer] -> [gap type] -> [specific fix]
```

Skip silently if file doesn't exist --- don't create it here.

## Boundaries

- Does NOT scan the repo (that's `loop-check`)
- Does NOT pull git/gh history (that's `retrospective`)
- Does NOT apply edits itself --- routes to the right fix method
- Does NOT route to harness-local memory --- only repo-portable fixes
- Does NOT create GitHub tickets
- Does NOT auto-trigger --- user invokes when ready
