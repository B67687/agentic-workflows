---
name: skill-creator
description: Generates new, spec-compliant Agent Skills from a natural language description. This is a meta-skill that creates other skills. Use when someone says "create a skill for X" or you need to encode a recurring workflow pattern as a reusable skill.
compatibility: claude-code, cursor, opencode, gemini-cli, codex-cli
allowed-tools: bash, read, write, grep, edit
metadata:
  trigger-phrases: create a skill, new skill, generate skill, write a skill, skill for, meta-skill
  handoffs: validate-skill-frontmatter (to validate), skill-evaluator (to test), using-agent-skills (to discover)
  companion-script: scripts/validate-skill-frontmatter.py
  pattern: generator
  bundle: meta
---

# Skill Creator

Generate new, spec-compliant Agent Skills from a natural language description.
This is a **meta-skill** --- its purpose is to create other skills.

## When to Use

- Someone says "create a skill for X" or "write a skill that does Y"
- You need a repetitive task packaged as a reusable skill
- A workflow pattern keeps recurring and should be encoded as a skill
- You want to extend this workspace's capabilities without manual file writing

**Do NOT use** for: editing existing skills (use `skill-evaluator` instead),
or for one-off tasks that don't need to be repeatable.

## L3 Resources

This skill embeds the reference material needed to generate valid skills.
Load them when the generation instructions below call for them:

| Resource | When to load |
|----------|-------------|
| `references/agentskills-spec.md` | Read this FIRST --- it defines the format rules |
| `references/example-skill.md` | Read this SECOND --- it shows a working example |

```bash
# Load the spec (L3)
bash ./scripts/skill-toolset.sh resource skill-creator references/agentskills-spec.md

# Load the example (L3)
bash ./scripts/skill-toolset.sh resource skill-creator references/example-skill.md
```

## Generation Process

### Step 1: Clarify the Requirements (Inversion)

Before generating anything, interview the user to understand:

- **Topic** --- What domain or task does the skill cover?
- **Trigger** --- What phrases should activate this skill? (for trigger-phrases)
- **Output** --- What should the skill produce? (checklist, template, pipeline, etc.)
- **Pattern** --- Which of the 5 design patterns fits best? (see below)
- **Audience** --- What agent tools should this skill work with? (default: all)

Do NOT proceed to generation until these are clear. If the user says "just make
something good," use your best judgment and state your assumptions explicitly.

### Step 2: Load the Spec

Read `references/agentskills-spec.md` to verify you have the current format rules.
The key constraints are:

- `name`: kebab-case, <= 64 chars, matches directory name, no consecutive hyphens
- `description`: 1-1024 chars, describes what AND when
- `compatibility`: comma-separated tool list (optional but recommended)
- `allowed-tools`: space-separated tool names (recommended)
- `metadata`: arbitrary key-value map --- put custom fields here

### Step 3: Choose the Design Pattern

Select the pattern based on the skill's purpose:

| Pattern | Use When | Example |
|---------|----------|---------|
| **tool-wrapper** | Agent needs domain/library expertise on demand | `api-and-interface-design` |
| **generator** | Output must follow a fixed template every time | `documentation-and-adrs` |
| **reviewer** | Need to score/evaluate against a rubric | `code-review-and-quality` |
| **inversion** | Agent must interview user before acting | `grill-me` |
| **pipeline** | Multi-step workflow with gates between steps | `debugging-and-error-recovery` |

Complex skills combine patterns. See `docs/skill-design-patterns.md` for
composition rules.

### Step 4: Load the Example

Read `references/example-skill.md` to see a working, spec-compliant skill
with all recommended fields populated. Use it as a structural template.

### Step 5: Generate the Skill

Write a complete SKILL.md with:

1. **Valid YAML frontmatter** following the agentskills.io spec exactly
2. **L1-optimized description** --- must contain the keywords that will trigger
   an agent to select this skill
3. **Structured body** with overview, when-to-use, step-by-step instructions,
   and verification steps
4. **L3 resource separation** --- move templates to `assets/`, checklists to
   `references/`, scripts to `scripts/`
5. **Handoffs** to related skills (what comes before / after in a workflow)
6. **Metadata** fields: `trigger-phrases`, `handoffs`, `pattern`, `bundle`,
   and optionally `companion-script`

Create the directory:
```
skills/<kebab-case-name>/
├── SKILL.md
└── references/
└── assets/
└── scripts/
```

### Step 6: Validate

Run the validation script to confirm the skill is spec-compliant:

```bash
python3 scripts/validate-skill-frontmatter.py <skill-name>
```

Fix any errors and warnings. Run until clean.

### Step 7: Verify Discoverability

Confirm the new skill appears in the toolset:

```bash
bash ./scripts/skill-toolset.sh list | grep <skill-name>
bash ./scripts/skill-toolset.sh find "<trigger keyword>"
```

## Frontmatter Template (copy this)

```yaml
---
name: <kebab-case-name>
description: <1-1024 chars, what and when>
compatibility: claude-code, cursor, opencode, gemini-cli, codex-cli
allowed-tools: bash, read, <additional tools>
metadata:
  trigger-phrases: <comma-separated keywords for auto-triggering>
  handoffs: <related-skill (reason), next-skill (reason)>
  companion-script: <path relative to skills root if applicable>
  pattern: <tool-wrapper | generator | reviewer | inversion | pipeline>
  bundle: <define | build | verify | ship | meta | assess | product>
---
```

## Common Mistakes

- **Using non-standard top-level fields** --- `trigger-phrases`, `handoffs`, and
  `companion-script` must go under `metadata`, not at top level
- **Uppercase in name** --- kebab-case only (e.g., `code-review` not `CodeReview`)
- **Directory mismatch** --- the directory name and the `name` field must match
- **Description too vague** --- must include both WHAT and WHEN for L1 discovery
- **Missing compatibility** --- the skill works everywhere unless specified
- **Skipping validation** --- always run `validate-skill-frontmatter.py` after creation
