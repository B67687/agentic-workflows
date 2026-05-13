---
name: skill-evaluator
description: 'Test, evaluate, and iteratively improve skills. Use when: creating a new skill and need to verify it works; an existing skill fails to trigger or produces wrong results; benchmarking skill
  performance across test cases; optimizing skill descriptions for better auto-detection. Do NOT use for routine implementation work.'
compatibility: claude-code, cursor, opencode, gemini-cli, codex-cli
allowed-tools: bash, read, grep, glob
metadata:
  companion-script: scripts/skill-test.sh
  handoffs: using-agent-skills (to discover skills), context-engineering (to refine), skill-creator (to generate new skills)
  trigger-phrases: evaluate skill, test skill, benchmark skill, improve skill, skill quality, optimize skill, pattern compliance, design pattern check
  pattern: reviewer
  bundle: meta
---
# Skill Evaluator

**Companion script:** `scripts/skill-test.sh` --- discover skills, verify structure, check completeness.
```bash
bash ./scripts/skill-test.sh discover         # list all skills with triggers
bash ./scripts/skill-test.sh check <name>     # verify skill completeness
```

A meta-skill for testing, evaluating, and improving skills. Use this when a skill isn't triggering properly, produces wrong results, or you want to verify a new or modified skill works correctly.

## Process

### 1. Capture Baseline

When the user reports a skill issue or wants to test a skill, first understand:

- **Which skill?** Get the exact name from `skills/<name>/SKILL.md`
- **What should it do?** Read the skill's description and instructions
- **What goes wrong?** Does it fail to trigger? Follow wrong steps? Produce wrong output?
- **Test cases?** What prompts should trigger this skill?

```yaml
Skill under test:     spec-driven-development
Current description:  "Creates specs before coding..."
Symptom:              Agent skips the skill and goes straight to code
Test prompt:          "I want to build a login system"
Expected behavior:    Should invoke spec skill first, produce spec doc, ask clarifying questions
Actual behavior:      Started coding immediately, no spec produced
```

### 2. Run the Test

For each test case:

1. **Load the skill** --- use `skill` tool to read the SKILL.md
2. **Simulate the scenario** --- evaluate whether the skill's description matches the user's intent
3. **Check triggering** --- would the skill auto-trigger on the test prompt?
4. **Verify the workflow** --- would the skill's instructions produce correct output?

Document each test result:

```
TEST: "I want to build a login system"
  TRIGGER: spec-driven-development --- ✅ (it's about building a new feature)
  WORKFLOW: Spec -> Plan -> Build --- ✅ (matches user's needs)
  NOTES: Description could add "Also triggers on vague feature requests"
```

### 3. Diagnose Issues

Common failure patterns:

| Symptom | Likely Cause | Fix |
|---|---|---|
| Skill never triggers | Description too narrow or keywords don't match | Broaden description to cover user's language |
| Skill triggers when it shouldn't | Description too broad | Add negative examples to description |
| Agent follows wrong steps | Workflow is ambiguous or has dead ends | Clarify tool-ordering, add decision points |
| Agent skips verification | Verification instructions are optional-sounding | Make verification mandatory ("MUST", not "consider") |

### 4. Iterate

After diagnosing, propose specific changes:

1. **Description fix** --- rewrite the `description` field in SKILL.md frontmatter
2. **Workflow fix** --- clarify steps, add decision logic, fix ordering
3. **Add red flags** --- add "Red Flags" section for what the skill MUST NOT do
4. **Add examples** --- add concrete before/after examples

Apply the fix, then re-run the test. Repeat until all test cases pass.

### 5. Expand Test Coverage

After the skill works for the initial test cases:

- Add edge cases (unusual inputs, error conditions)
- Add non-trigger cases (prompts that should NOT trigger this skill)
- Add integration cases (workflows spanning multiple skills)
- Document the test suite in `skills/<name>/tests/` if applicable

### 6. Check Pattern Compliance

After basic testing, evaluate whether the skill follows its intended design pattern
from `docs/skill-design-patterns.md`. Each pattern has specific structural requirements:

| Pattern | Required Directories | SKILL.md Should Orchestrate |
|---------|---------------------|---------------------------|
| **tool-wrapper** | `references/` with API/lib conventions | Load reference only when topic is relevant |
| **generator** | `assets/` with output template, `references/` with style guide | Load template and style guide, populate, output |
| **reviewer** | `references/` with rubric/checklist | Load checklist, score items by severity |
| **inversion** | `references/` with question bank | Refuse output until interview is complete |
| **pipeline** | `references/` per step, `scripts/` for gates | Enforce sequential steps with Gate: PASS/FAIL |

**Checklist for each evaluation:**

- [ ] Does the skill's `metadata.pattern` match its actual structure?
- [ ] Does the skill have the recommended directories for its pattern?
- [ ] Does the SKILL.md orchestrate L3 resources instead of embedding them?
- [ ] Are gate conditions explicit for pipeline patterns?
- [ ] Is the "refuse to generate" behavior explicit for inversion patterns?
- [ ] Are templates in `assets/` and checklists in `references/` (not inline in SKILL.md)?
- [ ] Can the skill compose naturally with its `handoffs` skills? (e.g., generator outputs feed into pipeline steps)

If a skill claims a pattern but doesn't follow its structure, either fix the
structure or change the `metadata.pattern` to `""` (unpatterned).

### 7. Optimize Description

After the skill works correctly and its pattern is verified, optionally optimize the skill's `description` field for better auto-detection:

**Before:** "Use when starting a new project, feature, or significant change and no specification exists yet"
**After:** "Creates specs before coding. Use when requirements are unclear, ambiguous, or only exist as a vague idea. Triggers on: new features, unclear requirements, missing specifications. Does NOT trigger on: bug fixes, trivial changes, or when a spec already exists."

Good descriptions are:
- **Action-oriented**: "Creates specs" not "Use for specifications"
- **Trigger-positive**: what keywords/concepts should activate it
- **Trigger-negative**: what should NOT activate it
- **Concise**: under 200 characters if possible

## Verification

After any change, confirm:
- [ ] All existing test cases still pass
- [ ] The trigger boundary is clear (what activates it vs what doesn't)
- [ ] Workflow steps are unambiguous
- [ ] Verification gates are mandatory (MUST, not should)
- [ ] Red flags are present for common mistakes
