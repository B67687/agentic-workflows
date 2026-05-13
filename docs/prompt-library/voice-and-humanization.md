# Voice And Humanization Prompts

Split from docs/prompt-templates.md during the 2026-04 optimization pass.

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
- "Wait, I thought [misconception] --- what did I miss?"

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

These are not bugs --- they are the authentic reasoning of someone learning.
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
- Use false starts: "The thing is --- and this took me a while to see --- ..."
- Break structural symmetry: don't always do intro -> 3 points -> conclusion
- Include a ramble or apparent digression that still connects thematically
- Add rhetorical questions: "But why does this matter?"
- Use opinionated statements, not just balanced hedging

Avoid AI vocabulary. Do NOT use:
- "delve", "tapestry", "nuanced", "comprehensive", "multifaceted"
- "It's worth noting...", "Furthermore", "In conclusion", "Moreover"
- "First/Second/Third" lists when a natural paragraph would work
- Perfect grammar throughout --- humans make small errors

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
Match my patterns exactly. Do not improve the writing --- match the style.
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

AVOID: Em-dashes (---) and semicolons (;) --- humans rarely use these because keyboards don't make them easy. Use commas or just split into two sentences instead.

Do NOT add these if they would be grammatically wrong in context.
```

### 17E. Anti-Academic Punctuation

Humans rarely use certain punctuation marks naturally:

| Avoid | Why Humans Don't Use It |
|-------|--------------------------|
| Em-dashes (---) | Keyboard awkwardness, just use commas or two sentences |
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
- Irregular punctuation --- not formulaic placement

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
- Start with "But", "So", "And" --- humans do this 15-20% of the time

**3. Break lexical patterns**
- Vary vocabulary range (don't reuse same words)
- Use colloquialisms naturally
- Add context-specific informal language
- Avoid "delve", "tapestry", "nuanced" --- AI vocabulary detectors hate these

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
- GPTZero's "Paraphraser Shield" catches heavy paraphrasing --- need authentic human variation

**Against Copyleaks:**
- Vary syllable patterns
- Avoid mechanical hyphenation
- Don't use overly consistent parts-of-speech patterns

**Against Originality.ai:**
- Hardest to evade --- trained on adversarial datasets
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
| Undetectable.ai paraphrasing | 91% -> 28% detection | Taloni et al. 2023 |
| Mixed human/AI composition | Most detectors miss partial AI | Multiple studies |
| Heavy semantic restructuring | Breaks detection signatures | Weber-Wulff 2023 |

### What DOESN'T Work:
- Minor edits (spacing, punctuation only)
- Single-word synonym swaps
- Automatic "humanizing" tools (often detected themselves)
- Homoglyph attacks (Cyrillic swaps --- easily caught)

---

## 23. Critical Warnings

1. **No detector is 100% accurate** --- all have significant error rates
2. **All detectors bias against ESL writers** --- serious equity concern (Stanford: 61.3% false positive for non-native writers)
3. **Detection degrades rapidly with paraphrasing** --- easy to bypass but changes voice
4. **Universities increasingly skeptical** --- Cambridge, UT Austin rejected Turnitin AI detection
5. **All commercial tools lack transparency** --- proprietary, unverifiable claims

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
| --- | ------ | Em-dash equivalent (used differently) |

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
✓ Mix sentence lengths --- short and long
✓ Vary punctuation --- sometimes end without 。 
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
- Don't punctuate perfectly --- humans don't

---

## 25. The ESL/CSL Structured Writing Problem

**Why school-taught language patterns trigger detection:**

### The Core Problem

```
School teaches:   Structured patterns -> Good grades
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

- ESL writes correctly -> flagged as AI
- Native speakers write casually with errors -> pass detection

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

