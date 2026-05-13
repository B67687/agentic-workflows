---
description: Build a compact self-prompt contract before phase work
---

Use this internally before non-trivial research, planning, implementation, or review.

Run:
`bash ./scripts/prompt-contract.sh "$ARGUMENTS"`

Then use the output as a compact self-check:
- outcome
- context
- constraints
- **simplicity check** --- does this change make the system simpler or more complex? If more complex, is the improvement proportional? "All else equal, simpler is better." (karpathy/autoresearch simplicity criterion)
- examples
- verification
- **expectation** (what you predict the output will look like --- structure, approach, key decisions)
- ask/proceed policy

**Calibration check:** Before running any generative action, mentally compare your expectation against what you are about to produce. When the output matches your expectation, you are calibrated. When it does not, you have a genuine decision to make. That decision is the thing cognitive surrender skips.

Ask the user only when missing information would materially change the work. Otherwise proceed with stated assumptions.
