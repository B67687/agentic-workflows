# Prompt Templates

These are copy-paste prompts you can reuse and adjust.

## Quick Reference Index

| # | Template | Purpose |
|---|----------|---------|
| 1 | Fix A Failed CI Build | Debug CI issues |
| 2 | Teach Me [Topic] | Fast skill growth |
| 3 | Deep Research | Comprehensive research |
| 4 | First Run The Tests | TDD debugging approach |
| 5 | Fix Logic Error | Root cause analysis |
| 6 | Summarize Long Context | Condense large inputs |
| 7 | Model Handover | Context transfer between models |
| 8 | Verification Prompt | Force verification before answering |
| 9 | Beginner/Amateur Voice | Natural voice for assignments |
| 10 | Beginner/Amateur Reasoning | Cognitive constraints for novices |
| 11 | Student Voice (Full) | Casual assignment writing |
| 12 | Casual Collaborative | Lightweight voice modifier |
| 13 | Authentic Uncertainty | Add human hedge words |
| 14 | Socratic Beginner | Ask genuine novice questions |
| 15 | Typical Beginner Mistakes | Domain-specific error patterns |
| 16 | Humanizing AI Writing | Evading AI detection |
| 17 | Voice Samples + Style Transfer | Match personal voice |
| 18 | Personal Voice Training | Ongoing voice improvement |
| 19 | Quick Humanization Add-On | Fast humanizing elements |
| 20 | Anti-Academic Punctuation | Avoid em-dashes, semicolons |
| 21-26 | AI Detection Tools Reference | Evasion strategies by tool |
| 27 | Generate Excalidraw Diagram | Visual system explanations |

---

## 1. Fix A Failed CI Build

```text
Investigate the failing CI build end to end.

Context:
- Repo: [repo]
- Branch/PR: [branch or PR]
- Failing workflow/job: [name if known]
- Recent changes: [optional summary]

What I want:
- Identify the exact failing step
- inspect the workflow, related scripts, and recent changes
- reproduce locally if possible
- form a short hypothesis list before making changes
- fix the root cause with the smallest correct patch
- run the closest local verification
- do not bypass tests, checks, or security gates

Output:
- root cause
- files changed and why
- verification performed
- any remaining uncertainty or CI-only risk

Do not stop at the first symptom if it looks like a downstream effect.
```

## 1B. CI Build Prompt With Evidence

```text
Role:
Senior engineer for this stack and CI system.

Scenario:
The CI build failed after a recent change.

Context:
- Repo: [repo]
- Stage/job: [job]
- Environment: [runner, OS, runtime, container, toolchain]
- Recent changes: [summary]
- Relevant files: [paths or pasted snippets]

Error logs:
[paste the failing log or the last important section]

Task:
1. Analyze the logs and identify the most likely root cause
2. Inspect the workflow and related code before proposing a fix
3. If multiple causes are plausible, rank them briefly
4. Provide the smallest maintainable fix
5. Explain why the fix resolves the failure
6. State how to verify it locally and what still depends on CI

Constraints:
- do not bypass tests or security checks
- prefer maintainable fixes over narrow hacks
- if uncertain, say exactly what evidence is missing
```

## 1C. Red/Green TDD Prompt

```text
Use red/green TDD.

Goal:
Change behavior safely and leave behind test coverage for it.

Process:
1. First run the relevant tests
2. Write or identify a failing test that captures the intended behavior
3. Implement the smallest maintainable change that makes the test pass
4. Rerun the relevant tests
5. Do manual verification too if the problem is not fully covered by tests

Output:
- failing behavior that was captured
- test changes
- implementation changes
- what is now covered by tests
- what was verified manually
```

## 2. Teach Me What You Just Did

```text
Teach me what you just did, but optimize for learning speed.

Teach in this order:
1. A 60-second summary
2. The mental model of the system you were working in
3. The important steps you took, in order
4. Why the key decisions mattered
5. The files, commands, and tools that are worth remembering
6. The 3 things I should learn first if I want to do this myself next time

Separate:
- task-specific details
- generally useful concepts
- tool usage

Do not explain everything equally. Focus on leverage.
```

## 2B. Macro-To-Micro Teaching Prompt

```text
I want to understand the solution without getting buried in details.

Teach this from macro to micro:
1. The big picture: what system or environment was involved
2. The tactical change: what changed and how
3. The significance: why this mattered
4. The key concept: the single most important idea to retain

For the tactical part, also cover:
- what files, commands, tools, or libraries mattered
- why this method was chosen over common alternatives

For the key concept, explain it in two short sentences with a simple analogy.
```

## 3. Teach Me This Repo

```text
Teach me this repo so I can become useful in it quickly.

Please cover:
1. What this repo does
2. The important directories and what lives in them
3. The major execution flow or architecture
4. The key commands for setup, dev, test, build, and release
5. The conventions and patterns that matter here
6. The common traps or confusing areas
7. A recommended learning path with what I should read first, second, and third

Please keep it practical and grounded in the actual repo rather than generic advice.
```

## 3B. Repo DNA Prompt

```text
Act like the lead architect onboarding a new contributor.

Teach me this repo's DNA efficiently:
1. Architectural blueprint: what style of system this is and how input becomes output
2. Directory landscape: what the key folders do and which file acts as the main entry point or control center
3. Tech stack and tooling: what the important frameworks, libraries, and config files are doing here
4. Execution lifecycle: walk me through one real event in this repo from start to finish
5. Senior secret: name one non-obvious design choice or convention that is easy to miss but important

Keep this grounded in the actual repo, not a generic template.
```

## 4. Resume A Long-Running Audit Or Campaign

```text
Resume this work from the exact current state below.

Current state:
[paste latest status update]

Before doing new work:
- restate what is already completed
- restate what is still pending
- list the next 3 best actions in priority order

Then execute only the next phase.

Constraints:
- do not redo already-validated work
- update the relevant local artifacts as you go
- keep public upstream activity paused unless escalation is clearly necessary

End with:
- what changed
- what remains
- what the next recommended step is
```

## 5. Keep Work Aligned With Repo Culture

```text
Before doing issue or PR work, align yourself to the repo's actual culture, not only the written rules.

Do this first:
1. Read the local lessons file
2. Read issue and PR templates
3. Inspect recent merged and open PRs/issues
4. Infer the real conventions for scope, title style, tone, evidence, and escalation

Then:
- follow the living convention unless it conflicts with an explicit rule
- keep changes small and maintainer-aligned
- if you discover a new maintainer preference, update the lessons file before continuing similar work

In your summary, separate:
- hard rules
- inferred conventions
- uncertain areas that may need confirmation
```

## 5B. Repo Culture And Vibe Check Prompt

```text
Act like a senior contributor who knows that living repo culture matters as much as written rules.

Before doing issue or PR work:
1. Read the local lessons file
2. Read the issue and PR templates
3. Review recent merged and open PRs/issues
4. Infer the actual conventions for title style, scope, tone, evidence, and escalation

Then compare the planned action against those observations.

Do a vibe check:
- does this look native to the community?
- is the scope something maintainers actually accept?
- does the wording sound like it belongs in this repo?

If new maintainer feedback reveals a missing convention, update the lessons file before continuing similar work.
```

## 6. Repo Operating Mandate Prompt

```text
Before taking any action, internalize the local lessons file for this repo and use it as the standing operating mandate.

Mandatory behavior:
1. State which concrete lesson applies to the task
2. Perform the required pre-flight environment checks before diagnosing repo logic
3. Prefer built-ins and established repo patterns over custom cleverness
4. Respect upstream semantics and maintainer guidance
5. Do not call a fix complete until all required architecture or platform checks are done

Current task:
[insert task]

Before proposing a solution, briefly state:
- which lesson applies
- which checks you performed
- what type of problem this is
```

## 7. Current Practices And Drift Protection Prompt

```text
Treat this task as potentially sensitive to knowledge drift.

Requirements:
1. Do not rely on memory alone where tooling, syntax, or conventions may have changed
2. Prefer current official docs, current repo configs, and current workflow evidence
3. If a field, flag, or pattern may be outdated, say so explicitly and verify before using it
4. If a newer practice is better, explain why it is better than the older approach

Focus:
- prioritize [security, minimalism, maintainability, arm64 support, etc.]
- avoid [deprecated syntax, legacy workaround, unnecessary manual steps, etc.]

When relevant, use actual CI errors, workflow files, or current docs as evidence rather than generic best-practice claims.
```

## 8. Work First, Then Teach Me

```text
Do the task normally, but after finishing, teach me efficiently.

After the work is done, explain:
- what the real problem was
- how you approached it
- which files and commands mattered most
- what conventions shaped your decisions
- what I should study next so I can handle similar work myself

Keep the explanation concise, practical, and optimized for independence.
```

## 9. Deep Repo Onboarding Prompt

```text
I want you to onboard me to this repo while also being useful.

When working, keep a short running map of:
- what subsystem you are touching
- how it fits into the repo
- what conventions it follows
- what I should notice and remember

After each substantial change, leave a compact explanation aimed at helping me build the right mental model, not just understand the patch.
```

## 10. Strong Resume Prompt For Your Scoop Campaign

```text
Resume from this exact state:

Phase 2 is implemented in the campaign artifacts, and public upstream activity remains paused.
Main shortlist validation completed:
- no issue / false positive: git, neovim, nodejs-lts, openssl, vim
- manual-only and deferred: findutils, gzip
- openjdk-ea is already covered by Java PR #583, so it should not remain in the local active logic queue

Artifacts already updated:
- manual-validation-notes.md
- validated-fix-queue.md
- lessons-scoop-prs.md

Current situation:
- there are no new local-only active logic candidates right now
- the next likely work is the deferred manual validation pool in Extras, then Java

Before acting, restate:
- what is done
- what is pending
- the next 3 priority actions

Then continue with the next phase only. Do not revisit already-validated shortlist items unless new evidence appears. Update the campaign artifacts as you go, keep public upstream activity paused, and end with:
- changes made
- remaining queue
- recommended next move
```

## 11. Ultra-Short Prompt Upgrade

If your base prompt is too simple, append this:

```text
Start by building context, identify the real root cause or decision point, verify the result, and summarize in a way that helps me learn the system instead of just seeing the output.
```

## 12. Analyze A Repo And Integrate It Into My Knowledge Base

```text
Analyze this repo deeply and integrate what is worth keeping into my local knowledge base, not just into this one answer.

What I want:
1. Identify the repo's main teaching spine or mechanism dependency order
2. Extract the strongest transferable design, prompting, and teaching patterns
3. Separate source-backed observations from your own inference
4. Compare those findings against my current local notes and call out:
   - what already overlaps
   - what is missing
   - what should be updated
5. Update or create markdown files in this workspace so the new knowledge becomes reusable
6. If the new lessons should change how future work in this workspace is done, update the local instruction file too

Focus especially on:
- smallest-correct-version teaching
- where state lives
- code-reading order
- mainline vs bridge docs
- task vs runtime vs execution-lane distinctions
- global vs repo vs component instruction scope
- prompt assembly, permissions, context control, and tool routing

End with:
- what changed in the knowledge base
- what the most important new lesson is
- what prompt or workflow should change going forward
```

## 15. Cross-Model Plan Review And Verification Prompt

```text
Use a phased workflow for this task.

Phase 1:
- build a plan from the actual repo and artifacts
- keep the phases intact and testable

Phase 2:
- review that plan independently against the codebase
- add findings, missing phases, or risk notes without flattening the original plan

Phase 3:
- implement phase by phase

Phase 4:
- verify the implementation against the plan with a fresh pass

Keep the plan review and the final verification skeptical and evidence-based.
Call out anything that still depends on CI, external systems, or human confirmation.
```

## 13. Compact Serious-Work Prompt

```text
Keep this high-signal and token-efficient.

Context:
[only the relevant repo/failure/state]

Goal:
[specific task]

Constraints:
[important boundaries only]

Done when:
[verification and success criteria]

Do not use more context than needed to make the right decision.
```

## 14. Compact Repo-Analysis Prompt

```text
Analyze this repo efficiently.

Focus on:
- what it does
- major flow
- key files or directories
- where important state lives
- best reading order
- top 3 things I should learn first

Keep the explanation compact and high-signal.
```

## 15. First Run The Tests Prompt

```text
First run the tests.

Then:
1. tell me what that reveals about the project shape and current failures
2. investigate the specific problem
3. implement the smallest maintainable fix
4. run the relevant verification again

If manual verification is also needed, do that too and state what you checked.
```

## 16. Beginner/Amateur Reasoning Mode

**Core insight**: Voice is superficial. Real amateur mode means the AI *reasons from* beginner knowledge, not *explains to* beginners from expert height. The challenge: AI knows too much to naturally think like a beginner.

### 16A. Voice-Level (Casual Sound Only)

For when you just need casual tone, not genuine beginner reasoning:

```text
You are a friendly, slightly confused college student.
Use "everyone" instead of "the team".
Say "I think..." instead of stating things with certainty.
Use casual words: "use" not "utilize", "so then" not "consequently".
Include self-doubt: "wait, am I getting this right?".
Avoid expert tone, jargon, certainty markers.
```

### 16B. Genuine Beginner Reasoning (Cognitive Constraints)

Use this when you want the AI to actually *think like a beginner*, not just sound like one.

**Why voice-only doesn't work**: AI knows the answer and all expert paths to it. Without constraints, it explains *to* beginners rather than reasoning *as* one.

**The constraint set**:

```text
You are working through this as someone who just learned [topic] for the first time.

Your actual knowledge state:
- You have only seen: [beginner resource, e.g., week-1 notes, basic tutorial]
- You do NOT know: [advanced concept the task involves]
- Your mental model is: [oversimplified but coherent beginner understanding]

Required reasoning patterns:
- Start from [naive assumption], not from the expert insight
- Use [basic method], not [advanced technique]
- Overlook [common edge case] because you don't know to check for it
- Be confused by [expert pattern] because it seems counterintuitive from your level]

Express genuine uncertainty about things beginners actually wonder:
- "I'm not sure if I should [X] or [Y]"
- "I think maybe [naive hypothesis] but no idea really"
- "Wait, does [basic thing] even work like that?"

Make reasoning errors characteristic of real beginners:
- Overgeneralize from limited examples
- Apply patterns outside their valid domain
- Skip validation steps experts would take
- Miss non-obvious implications
```

### 16C. Fresh Mind Constraint (Add-On)

Append this to any task to force beginner reasoning:

```text
Reason from a fresh mind, not from expert knowledge.

Before solving, state explicitly:
1. What I currently understand (limited)
2. What I'm unsure about (gaps)
3. What naive approach I tried first
4. Why the expert approach is not obvious to me

Work through the problem as if you just learned the basics and are figuring out the rest on your own.
Do not skip to the expert solution. Show the genuine struggle.
```

### 16D. Socratic Beginner Mode

For assignments where a beginner asking questions feels more authentic than a beginner answering:

```text
Generate questions a true novice would actually ask about [topic].
A real beginner wouldn't think to ask:
- "What are the edge cases?"
- "What assumptions am I making?"
- "Does this pattern apply broadly or just here?"

A real beginner WOULD ask:
- "Can I just [basic approach]?"
- "Why does [expert technique] work when [naive expectation] seems right?"
- "Wait, I thought [misconception] — what did I miss?"

Then work through [task] using these genuine beginner questions as your guide.
```

### 16E. Typical Beginner Mistakes (Domain-Specific)

For programming/math/technical tasks, add domain-specific beginner errors:

```text
Make these characteristic beginner mistakes in your reasoning:
- [Programming] Forget to handle empty/null cases
- [Programming] Use == instead of .equals() for objects
- [Math] Cancel terms incorrectly when simplifying fractions
- [Math] Forget that sqrt(x^2) = |x|, not x
- [Logic] Assume "or" means exclusive or
- [General] Overgeneralize from one example

These are not bugs — they are the authentic reasoning of someone learning.
```

### Key Insight

| Voice-Only (Superficial) | Genuine Beginner Reasoning (Cognitive) |
|--------------------------|----------------------------------------|
| "I think..." instead of "It is..." | Actually doesn't know the advanced path |
| "everyone" instead of "the team" | Makes naive overgeneralizations |
| Casual vocabulary | Has specific knowledge gaps and misconceptions |
| Sounding uncertain | Asking what beginners actually wonder |

The difference: Voice-only AI explains what it already knows in casual words. Genuine beginner reasoning AI *restricts its knowledge* to appear authentically amateur.

---

## 17. Humanizing AI Writing (Evading Detection)

**Why AI gets detected**: Detectors measure perplexity (text is too predictable) and burstiness (uniform sentence length). AI writing has fingerprints humans don't have: perfect grammar, consistent register, formulaic transitions, "AI vocabulary" (delve, tapestry, nuanced), no false starts or self-corrections.

### 17A. Anti-Detection Writing Style

Add this to any task where you need AI output to pass detection:

```text
Write in a way that sounds human, not AI-generated.

Humanize the output:
- Vary sentence length intentionally: mix 5-word fragments with 25-word sentences
- Add controlled "imperfections": informal contractions, em dashes mid-thought, occasional fragments
- Use false starts: "The thing is — and this took me a while to see — ..."
- Break structural symmetry: don't always do intro → 3 points → conclusion
- Include a ramble or apparent digression that still connects thematically
- Add rhetorical questions: "But why does this matter?"
- Use opinionated statements, not just balanced hedging

Avoid AI vocabulary. Do NOT use:
- "delve", "tapestry", "nuanced", "comprehensive", "multifaceted"
- "It's worth noting...", "Furthermore", "In conclusion", "Moreover"
- "First/Second/Third" lists when a natural paragraph would work
- Perfect grammar throughout — humans make small errors

Include specific concrete details (named examples, dates) instead of vague generalities.
```

### 17B. Voice Samples + Style Transfer

When you want AI to write in YOUR voice:

```text
Here are [3-5] samples of my writing style:

[SAMPLE 1 - paste your actual writing here]
[SAMPLE 2 - paste your actual writing here]
[SAMPLE 3 - paste your actual writing here]

Analyze these samples and extract my specific patterns:
- Sentence length variation (short? long? mixed?)
- Typical transition words I use
- Whether I use contractions, fragments, em dashes
- My level of formality (casual, formal, or shifting?)
- Any personal quirks (humor, analogies, questions?)
- How I start conclusions
- My typical paragraph structure

Then write [the assignment] in MY voice, not in generic AI voice.
Match my patterns exactly. Do not improve the writing — match the style.
```

### 17C. Personal Voice Training (Ongoing)

For long-term use, train AI on your writing corpus:

**Step 1**: Collect your writing
- Emails, essays, notes, texts, informal writing
- 50-200 samples minimum
- Real writing, not AI-assisted

**Step 2**: Fine-tune with LoRA (for advanced users)
```bash
# Using unsloth for faster fine-tuning
# Train on your corpus to get a personal style adapter
```

**Step 3**: Use retrieval-augmented voice
- Store your writing in a vector DB (Chroma, Qdrant)
- On generation, retrieve similar passages as context
- AI implicitly mirrors your patterns

**Step 4**: Continuous correction loop
- When AI writes something that doesn't sound like you, correct it
- Over time, AI learns your specific patterns

### 17D. Quick Humanization Add-On

Append to any prompt to add humanizing elements:

```text
Add these human characteristics:
- 2-3 sentence fragments (incomplete sentences)
- 1-2 run-on sentences that trail off
- Rhetorical questions used naturally, not as formula
- Short punchy sentence after a long one
- A concrete specific example instead of abstract generalities
- One opinionated claim (not just balanced "on the other hand...")
- Slight informality in 1-2 places

AVOID: Em-dashes (—) and semicolons (;) — humans rarely use these because keyboards don't make them easy. Use commas or just split into two sentences instead.

Do NOT add these if they would be grammatically wrong in context.
```

### 17E. Anti-Academic Punctuation

Humans rarely use certain punctuation marks naturally:

| Avoid | Why Humans Don't Use It |
|-------|--------------------------|
| Em-dashes (—) | Keyboard awkwardness, just use commas or two sentences |
| Semicolons (;) | Almost nobody uses them except academic writers |
| Colons mid-sentence | Formally reserved, rare in casual writing |
| Perfect ellipsis placement | Humans trail off irregularly |

**Instead use**:
- Commas for aside thoughts
- Two sentences when you need a break
- "..." irregularly placed (not predictable positions)
- Parentheses sparingly for brief asides

---

## 18. AI Detection Fingerprints Reference

**What detectors measure** (so you can avoid them):

| Feature | AI Pattern | Human Pattern |
|---------|-----------|---------------|
| Perplexity | Very low (too predictable) | High (surprising word choices) |
| Burstiness | Low (uniform sentences) | High (short + long mixed) |
| Vocabulary | Narrow, consistent | Wide, shifts with register |
| Grammar | Perfect | Small errors, fragments |
| Em-dashes | Overused as structural tool | Rarely used (keyboard awkward) |
| Semicolons | Overused as sophistication signal | Almost never used except academic |
| Transitions | Formulaic (Furthermore, Moreover) | Varied, abrupt, missing |
| Structure | Symmetric (3-point lists) | Asymmetric, circular |
| Self-correction | None | Visible false starts |
| Specificity | Vague generalities | Named examples, dates |
| Coherence | Too perfect | Some ramble/digression |
| Contractions | Too consistent or avoided | Used naturally (~80-90% in casual) |
| Hedge words | "it is possible that" formulaic | "maybe", "I guess", "sort of" |
| First-person | Uniform pattern | Variable, sometimes absent |

**AI vocabulary to avoid** (detectors flag these):
- delve, tapestry, multifaceted, nuanced, comprehensive
- "It's worth noting...", "First/Second/Third"
- "In conclusion", "Furthermore", "Moreover"
- "It should be noted", "It is important to"

**Human characteristics to include**:
- Occasional sentence fragments
- Varied sentence length
- 1-2 colloquialisms
- Concrete named examples
- Self-correcting or false starts
- Opinionated, not just balanced
- Digression that circles back
- "But", "So", "And" as sentence starters
- Natural contractions (don't/it's/I'm)
- Irregular punctuation — not formulaic placement

**Key insight**: The absence of typos and errors is itself a detection signal. Humans make 2-5 errors per 100 words in casual typing. Perfect grammar is suspicious.

---

## 19. AI Detection Tools: What They Measure

**Top tools used by universities (ranked by accuracy):**

| Tool | Accuracy | Used By |
|------|----------|---------|
| **Turnitin** | ~85-92% (proprietary) | Most universities globally |
| **GPTZero** | 95-99% (independent tests) | Growing adoption in US/Canada |
| **Copyleaks** | 99% (self-claimed, Cornell validated) | Enterprise + academic |
| **Originality.ai** | 87-97% (third-party tested) | Publishers + education |
| **Sapling AI** | 97%+ (self-claimed) | Enterprise |

**What each tool specifically measures:**

### Turnitin
- Perplexity patterns (text predictability)
- Burstiness (sentence length variation)
- Word frequency anomalies
- "Container model" approach (different models for different content types)
- **Weakness**: False positives on ESL writers (~15-61% per Stanford study)

### GPTZero
- Per-token probability distributions
- Burstiness (sentence structure variation)
- **"Paraphraser Shield"** - detects paraphrased content
- 7-component detection architecture
- **Weakness**: Struggles with very short texts (<50 words)

### Copyleaks
- Syllable dispersion patterns
- Parts-of-speech analysis
- Hyphen usage detection
- Cross-model detection (catches even paraphrased content)
- **Weakness**: Requires 255+ characters minimum

### Originality.ai
- Edit痕迹 (editing signatures)
- Writing style fingerprints
- Trained on "adversarial datasets" (actively tests bypass)
- Multiple model variants (Lite, Academic, Turbo)
- **Weakness**: Turbo mode has 1.5% false positive rate

---

## 20. Evasion Strategies by Detection Tool

### Universal Rules (defeat all detectors)

**1. Add perplexity (unpredictability)**
- Use unexpected word choices
- Add surprising transitions
- Include opinionated statements that surprise
- "Even experts say X, but I think Y because..."

**2. Increase burstiness**
- Mix 5-word sentences with 30-word sentences
- Add rhetorical questions
- Use fragments ("Crazy, right?")
- Start with "But", "So", "And" — humans do this 15-20% of the time

**3. Break lexical patterns**
- Vary vocabulary range (don't reuse same words)
- Use colloquialisms naturally
- Add context-specific informal language
- Avoid "delve", "tapestry", "nuanced" — AI vocabulary detectors hate these

**4. Use contractions naturally**
- Humans use contractions ~80-90% in casual writing
- Don't avoid them or over-consistently use them
- Mix: "I don't", "I dont", "I do not" - variation helps

**5. Add hedge words**
- "maybe", "I guess", "sort of", "probably", "perhaps"
- AI uses formulaic hedges: "it is possible that", "one might argue"
- Use natural hedge placement, not systematic

**6. Include first-person variability**
- Mix "I think", "I feel", "my view is", "in my experience"
- Don't use a consistent pattern
- Sometimes omit "I" entirely

---

### Specific Tool Defenses

**Against Turnitin:**
- Avoid formulaic academic transitions
- Mix sentence lengths more than usual
- Include personal anecdotes with specific details
- Turnitin struggles with edited/paraphrased content

**Against GPTZero:**
- Break sentence uniformity
- Use creative transitions (not "first, second, third")
- Add irregular punctuation
- GPTZero's "Paraphraser Shield" catches heavy paraphrasing — need authentic human variation

**Against Copyleaks:**
- Vary syllable patterns
- Avoid mechanical hyphenation
- Don't use overly consistent parts-of-speech patterns

**Against Originality.ai:**
- Hardest to evade — trained on adversarial datasets
- Use "elevate with literary language" trick: ask AI to add metaphor, sensory details, rhetorical devices
- Mixed human/AI composition works best

---

## 21. "Genuine Writing" Characteristics Detectors Miss

Based on Stanford, Weber-Wulff, and MAGE benchmark research:

### What makes text pass detection:

1. **Non-linear structure**
   - Circle back to earlier points unexpectedly
   - Add apparent digressions that connect later
   - Break chronological flow

2. **Specific concrete details**
   - Named examples, dates, places (not vague generalities)
   - "I saw this at Jurong Lake Gardens last Tuesday at 4pm"
   - Specific sensory details

3. **Controlled imperfections**
   - Occasional sentence fragments
   - One-liner paragraphs
   - Slightly informal language in formal context

4. **Idiosyncratic word choices**
   - Using words slightly outside expected register
   - Personal expressions of concepts
   - Mixed formality

5. **Natural hedge placement**
   - Hedge words at natural positions, not systematic
   - "I think" not "It is possible that"
   - "maybe" not "perhaps"

6. **Voice fingerprints**
   - Strong personal voice (which is why personal voice training helps)
   - Consistent patterns across context
   - Authentic self-correction ("Wait, I meant...")

---

## 22. Bypass Methods That Actually Work

### Proven Effective (from peer-reviewed research):

| Method | Result | Source |
|--------|--------|--------|
| "Elevate text with literary language" prompt | Near 0% detection | Liang et al. 2023 |
| Undetectable.ai paraphrasing | 91% → 28% detection | Taloni et al. 2023 |
| Mixed human/AI composition | Most detectors miss partial AI | Multiple studies |
| Heavy semantic restructuring | Breaks detection signatures | Weber-Wulff 2023 |

### What DOESN'T Work:
- Minor edits (spacing, punctuation only)
- Single-word synonym swaps
- Automatic "humanizing" tools (often detected themselves)
- Homoglyph attacks (Cyrillic swaps — easily caught)

---

## 23. Critical Warnings

1. **No detector is 100% accurate** — all have significant error rates
2. **All detectors bias against ESL writers** — serious equity concern (Stanford: 61.3% false positive for non-native writers)
3. **Detection degrades rapidly with paraphrasing** — easy to bypass but changes voice
4. **Universities increasingly skeptical** — Cambridge, UT Austin rejected Turnitin AI detection
5. **All commercial tools lack transparency** — proprietary, unverifiable claims

**Best defense**: Combine humanizing techniques + personal voice training + specific tool-aware modifications

---

## 24. Chinese Writing: Natural Patterns vs. AI Fingerprints

**Critical finding**: Current AI detectors perform significantly worse on Chinese than English. Research from ACL 2026 and EMNLP 2025 shows detectors nearly fail on Chinese poetry and classical Chinese.

### Chinese Punctuation (vs English)

| English | Chinese | Note |
|---------|---------|------|
| . | 。 | Full-width period |
| , | ， | Full-width comma |
| ; | ； | Full-width semicolon (rarely used naturally) |
| : | ： | Full-width colon |
| " " | " " | Full-width quotes |
| — | —— | Em-dash equivalent (used differently) |

**AI fingerprint in Chinese**: Over-regular punctuation. Humans are more irregular.

### What Makes Chinese Sound AI-Generated

| AI-Sounding (Avoid) | Natural Human |
|---------------------|---------------|
| Uniform sentence length | Varied lengths |
| 首先 + 其次 + 最后 (every paragraph) | Organic transitions |
| Perfect 。 after every sentence | Sometimes missing, sometimes doubled |
| 4-6 成语 clustered together | Sparse, natural idiom use |
| Classical phrases in modern context | Register-appropriate |
| "可以看出" "因此" "然而" in every para | Varied, less formulaic |
| Topic-comment structure every time | Topic-drop, subject ellipsis |
| Generic safe vocabulary | Specific personal word choices |

### Chinese-Specific AI Fingerprints to Avoid

```
✗ 首先...其次...最后 chain (every time)
✗ 因此...然而...此外 (every paragraph)
✗ 4-6 成语 in sequence (AI does this more than humans)
✗ Perfect textbook punctuation after every sentence
✗ Classical phrases inserted in modern writing
✗ 标点符号 perfectly placed
✗ Generic transitions: "此外" "并且" "同时"
```

### How to Sound Human in Chinese

```
✓ Mix sentence lengths — short and long
✓ Vary punctuation — sometimes end without 。 
✓ Use colloquial expressions in informal contexts
✓ Drop subjects in appropriate contexts (Chinese allows this)
✓ Use idioms sparingly, organically, not in clusters
✓ Include specific, personal details
✓ Allow some "incorrect" but natural patterns
✓ Break formal register occasionally
✓ Use shorter paragraphs with varied structures
```

### Chinese Detection Accuracy (Current State)

| Type | Accuracy | Notes |
|------|----------|-------|
| Modern Chinese academic | Moderate | Better than poetry but still problematic |
| Classical Chinese (文言文) | Near 0% | ACL 2026: 12 detectors failed completely |
| Modern Chinese poetry | Near 0% | EMNLP 2025: 6 detectors failed |
| Commercial tools | Worse than research | Not trained on enough Chinese data |

**Key insight**: Detectors were built primarily for English. Chinese detection signals are different and commercial tools haven't caught up. Writing Chinese naturally (with variance and imperfections) is your best defense.

### If You're Writing Chinese for Academic/Work

- Use contractions naturally (有的 -> 有的)
- Vary sentence length more than you think necessary
- Mix formal and informal register
- Add specific personal details
- Use idioms sparingly
- Don't punctuate perfectly — humans don't

---

## 25. The ESL/CSL Structured Writing Problem

**Why school-taught language patterns trigger detection:**

### The Core Problem

```
School teaches:   Structured patterns → Good grades
AI trained on:    Lots of academic/school text
Detectors learn:  "Structured" = AI-like
Result:           School-trained writers flagged as AI
```

### English ESL vs. Chinese CSL

Both face the same problem:

| Aspect | School-taught Pattern | Detectors See |
|--------|----------------------|---------------|
| Transitions | "First, Second, Third" | AI fingerprint |
| Punctuation | Perfect, consistent | AI fingerprint |
| Grammar | Textbook-correct | AI fingerprint |
| Register | Formal throughout | AI fingerprint |
| Structure | 5-paragraph essay | AI fingerprint |

### What Actually Sounds Human

**Native speakers sound human because:**
- They break rules (fragments, run-ons, informal)
- They have quirks from "real" exposure (music, movies, texts)
- They don't write like textbooks

**ESL/CSL students sound "too correct" because:**
- They learned formal textbook English/Chinese
- They avoid errors (as taught)
- They use structures that are "correct" but not natural

### The Irony

- ESL writes correctly → flagged as AI
- Native speakers write casually with errors → pass detection

### How to Fix It

**For English ESL writers:**
Write less "perfect" English. Include fragments, informal transitions, slight errors that don't confuse meaning.

**For Chinese CSL writers:**
放松标点符号的使用 (relax punctuation use). Vary sentence length more. Use colloquialisms. Don't cluster 成语. Drop subjects when natural.

---

## 26. Language-Agnostic Principles

Regardless of language, these principles defeat detection:

### 1. Variance (变化)
- Sentence length: Mix short and long
- Word choice: Vary vocabulary, don't repeat same words
- Structure: Don't follow the same pattern every paragraph

### 2. Imperfection (不完美)
- Punctuation: Humans don't punctuate perfectly
- Grammar: Small errors that don't confuse meaning
- Completeness: Fragments and run-ons are human

### 3. Specificity (具体)
- Named examples, dates, places
- Personal details that only you would know
- Sensory descriptions specific to your experience

### 4. Voice (声音)
- Strong personal style across texts
- Consistent patterns (not uniform)
- Self-correction and changing positions

### 5. Register Mixing (语域混合)
- Not everything formal
- Casual intrusions in formal writing
- Context-appropriate informality

### 6. Idiosyncrasy (特殊性)
- Words slightly outside expected register
- Personal ways of expressing concepts
- Non-standard but understood expressions

---

## 27. Generate Excalidraw Diagram

Use when explaining systems, architectures, flows, or relationships — a diagram makes the explanation concrete and editable.

### When to Offer a Diagram

Offer when explaining:
- System architecture or components
- Data flow or process steps
- Entity relationships
- Hierarchies or branching decisions
- Any concept where spatial structure aids understanding

### How to Generate the Diagram

**Step 1**: Extract structured information from your explanation:
- Entities/nodes (name + optional description)
- Relationships (from → to, with label)
- Sequential steps or decision points

**Step 2**: Create the `.excalidraw` JSON structure:

```json
{
  "type": "excalidraw",
  "version": 2,
  "source": "https://excalidraw.com",
  "elements": [
    {
      "id": "[unique-id]",
      "type": "rectangle",
      "x": [x],
      "y": [y],
      "width": [width],
      "height": [height],
      "strokeColor": "#000000",
      "backgroundColor": "#a5d8ff",
      "fillStyle": "solid",
      "fontFamily": 5,
      "text": "[label]"
    }
  ],
  "appState": {
    "viewBackgroundColor": "#ffffff",
    "gridSize": 20
  },
  "files": {}
}
```

**Step 3**: Use these element types:
- `rectangle` — boxes for entities, steps, concepts
- `ellipse` — alternative for emphasis
- `diamond` — decision points
- `arrow` — directional connections (set `points` array for start/end)
- `text` — labels and annotations (must use `fontFamily: 5`)

**Step 4**: Output the complete JSON as a codeblock named `diagram-name.excalidraw`.

### Layout Guidelines

| Element type | Gap between items |
|---|---|
| Horizontal spacing | 200-300px |
| Vertical spacing | 100-150px |
| Text size | 16-24px for readability |

### Color Palette

| Element type | Color |
|---|---|
| Primary elements | Light blue `#a5d8ff` |
| Secondary elements | Light green `#b2f2bb` |
| Important/central | Yellow `#ffd43b` |
| Alerts/warnings | Light red `#ffc9c9` |

### Complexity Rule

Keep diagrams under 15 elements. If the explanation is complex:
1. Create a high-level diagram first
2. Offer to create detailed sub-diagrams
3. Or save as `.excalidraw` and let the user edit/add

### How the User Opens It

1. Go to [https://excalidraw.com](https://excalidraw.com)
2. Click "Open" or drag-and-drop the file
3. The diagram is fully editable — user can move, relabel, annotate

### Example Use

```
After explaining the request pipeline:
"Want me to draw this as a diagram? Here's the flow as an Excalidraw file:"
[dumps diagram.excalidraw codeblock]
"Open it at excalidraw.com and you can edit, annotate, or add to it."
```

### Source

Based on [selopo-ec/my-awesome-copilot Excalidraw Diagram Generator skill](https://github.com/selopo-ec/my-awesome-copilot/blob/main/skills/excalidraw-diagram-generator/SKILL.md) (613 lines, MIT license).
