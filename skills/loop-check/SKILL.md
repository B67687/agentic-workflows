---
name: loop-check
description: "Assess what's needed to make feedback loops autonomous in a repo. Use when someone says loop check, what do I need to work autonomously, what's manual here, can an agent iterate here, or before starting work in an unfamiliar repo. NOT for: full repo audits (-> tap-audit), coding, test writing, or implementation."
trigger-phrases: loop check, what do I need to work autonomously, what's manual here, can an agent iterate, what should I automate, feedback loops
handoffs: tap-audit (for full repo audit), tighten-loop (for conversation-level steers)
companion-script: scripts/loop-check.sh
---

# Loop Check

**Companion script:** `scripts/loop-check.sh` --- assess feedback loops, identify gaps and leverage points.
```bash
bash ./scripts/loop-check.sh assess   # feedback loop assessment
```

Answer one question: **"What's needed to make feedback loops autonomous in this repo?"**

Find what's manual, what's missing, and prescribe concrete automation paths.

**Companion script:** `scripts/loop-check.sh`
```bash
bash ./scripts/loop-check.sh workflows [dir]   # discover top workflows
bash ./scripts/loop-check.sh assess "<wf>"      # assess a workflow's loop
bash ./scripts/loop-check.sh rate "<wf>"        # rate loop type
bash ./scripts/loop-check.sh prescribe "<wf>"   # prescribe fix
```

## Process

### 1. Discover Workflows

Find the top 3 workflows --- both automated and manual. If the user specified a task, prioritize relevant workflows.

**Run these scans:**

**Binary assets without generators** --- find committed images, fonts, audio, video, PDFs. Check if generation scripts produce them.

```
Find: *.png, *.jpg, *.svg, *.gif, *.mp3, *.pdf, *.ttf
Then: look for Makefile, generate-*.sh, scripts/, or build steps
Missing generator = manual workflow
```

**Git history churn** --- files re-committed with small changes suggest manual iteration.

```
git log --all --diff-filter=M --name-only --pretty=format: | sort | uniq -c | sort -rn | head -20
```

**Human-in-the-loop scripts** --- scan for steps requiring visual inspection, manual input, or judgment:
- Scripts that open a browser and wait for human
- Steps phrased as "then you...", "manually...", "visually check..."
- Scripts with `read`, `open`, `sleep`, or comments like `# check this looks right`

**Workflow descriptions in docs** --- read CLAUDE.md, README, contributing guides. Multi-step processes in prose are unautomated pipelines.

**Existing audit** --- if `.tap/tap-audit.md` exists, read its feedback loops section.

### 2. Assess Each Loop

| Element | Question |
|---------|----------|
| **Generator** | Can an agent produce the output? If not, what's missing? |
| **Evaluator** | Can something *other than the generator* verify the output? |
| **Handoff** | Can an agent context-reset and resume? |
| **Grading criteria** | Are quality expectations measurable? |

Rate each workflow:

- **Closed** --- all four present. Agent iterates autonomously.
- **Open** --- evaluator or grading missing. Agent produces but can't verify quality.
- **No loop** --- no evaluator, no criteria. Agent guesses.
- **Manual** --- human does this entirely by hand.

### 3. Prescribe Fixes

For each non-closed workflow, prescribe concrete automation:

- **Skill to create** --- name it, describe tools needed
- **MCP to wire up** --- which server, what it enables
- **Hook to add** --- what event, what it does
- **Tool to integrate** --- CLI tool, API, or service
- **Test to write** --- kind and coverage
- **Grading criteria** --- measurable spec

### 4. Present Findings

```
`★ Loop Check ────────────────────────────────────`
[N] workflows assessed --- [N closed] / [N open] / [N manual]
  ├─ [most impactful finding]
  ├─ [second finding]
  └─ [top recommendation to close a loop]
`─────────────────────────────────────────────────`
```

Lead with manual and open workflows --- closed loops don't need attention.

If everything is closed: say so and get out of the way.

## Boundaries

- Does NOT write code, tests, or config --- prescribes what to create
- Does NOT assess infrastructure (CI/CD, permissions --- that's tap-audit)
- Does NOT produce a report file --- output is conversational
- Does NOT auto-run --- manual invocation only
- Findings are recommendations, not gates
