---
name: source-extraction
description: Extracts patterns from an external open-source project and integrates them into this workspace using the macro-to-micro funnel. Use when auditing sources, finding missed integration points, or adopting a pattern from another project (e.g., after a source audit pass).
compatibility: claude-code, cursor, opencode, gemini-cli, codex-cli
allowed-tools: bash, read, grep, glob, write, edit, webfetch, websearch
metadata:
  handoffs: bash-explore (to discover existing references), using-agent-skills (to pick a creation skill)
  trigger-phrases: extract pattern, source extraction, macro-to-micro funnel, audit source, missed integration, extract from source
  pattern: pipeline
  bundle: define
---

# Source Extraction

Systematically extract patterns from an external open-source project and
integrate them into this workspace. Follows the macro-to-micro funnel:
System -> Domain -> Module -> Root Cause.

**Source of this skill:** This skill encodes the process used during the
84-source audit of this workspace. The macro-to-micro funnel is derived from
`skills/debugging-and-error-recovery/SKILL.md`, adapted for source analysis.

## When to Use

- After a source audit pass identifies a namedrop-only project
- When you encounter a project with patterns that could improve the workspace
- When asked "did we miss any integration from source X?"
- When creating a new skill or workflow and you want to check if a proven
  pattern already exists in an external project

**Do NOT use** for: one-off research (use `websearch` + `webfetch` directly),
or for reading documentation that has no integration potential.

## The Macro-to-Micro Funnel

Analyze each source at four levels, top to bottom. Do not skip levels.

```
Macro (System)     -- What does this project do? Where does it connect?
Domain (Subsystem) -- Which part of our system does it map to?
Module (File)      -- Which specific files already reference it?
Root (Pattern)     -- What specific integration did we implement vs. miss?
```

## Extraction Process

### Step 1: Macro Analysis (System Level)

Understand the external project at the system level:

```
- What does this project do? (framework, tool, library, reference, paper)
- What problem does it solve?
- What is its architectural approach?
- Which of our subsystems would it connect to?
  (commands, scripts, skills, docs, research, propagation)
```

**Output:** A one-line classification: `[type] / [subsystem] / [connection]`

### Step 2: Domain Analysis (Subsystem Level)

Map the project to our workspace structure:

```bash
# Find all existing references to this project
bash ./scripts/search-index.sh "<project-name>" 2>/dev/null || true
grep -rn "<org>/<repo>" --include="*.md" . 2>/dev/null | grep -v "raw/\|state/" || true
```

Categorize references by domain:
- `skills/` -- already extracted as a skill pattern?
- `docs/` -- cited in documentation?
- `scripts/` -- used in automation?
- `README.md` -- listed in ecosystem table?
- (none) -- not yet referenced at all

**Output:** Count of files per domain, integration tier (deep/medium/namedrop).

### Step 3: Module Analysis (File Level)

Identify specific patterns the project offers that we haven't extracted:

```bash
# Browse the project's key files
webfetch https://github.com/<org>/<repo>  # README
webfetch https://github.com/<org>/<repo>/blob/main/docs/  # docs
```

For each pattern the project offers, ask:
```
- Does this pattern exist in our system already?
- If yes, is our version as good as the source?
- If no, would extracting it improve our system?
- How would we verify it works after extraction?
```

**Output:** List of candidate patterns with yes/no/maybe assessment.

### Step 4: Root Cause Analysis (Pattern Extraction)

For the highest-value candidate pattern, extract it:

1. **Choose integration target:**
   - New skill (`skills/<name>/SKILL.md`) for complex workflows
   - New script (`scripts/<name>.sh`) for automation
   - New doc (`docs/<name>.md` or `workflow/<name>.md`) for reference
   - Update existing skill/script/doc for incremental improvements

2. **Implement the pattern** following the target's conventions

3. **Cite the source** at point of use:
   ```
   **Source:** [Project Name](https://github.com/org/repo) -- brief context
   ```

4. **Verify** the extraction works:
   ```bash
   bash ./scripts/test-smoke.sh  # No regressions
   # Manual check for the specific pattern
   ```

5. **Update session-state** with what was extracted and from where

## Pattern Assessment Matrix

| Signal | Assessment |
|--------|-----------|
| Unique architecture not in our system | HIGH value -- extract as skill or script |
| Could replace a custom solution | MEDIUM -- adopt or adapt |
| Similar to existing pattern | LOW -- cite source, skip extraction |
| Only relevant to specific domain | DEFER -- file for later |
| Not relevant to our use case | SKIP -- no extraction needed |

## Verification

After extraction:

- [ ] Source cited at point of use (`[Name](URL)` format)
- [ ] Quality gate passes (`bash ./scripts/test-smoke.sh`)
- [ ] Session-state updated with extraction record
- [ ] Pattern works for its intended use case
- [ ] No regressions in existing functionality
