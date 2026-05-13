# Blast Radius Report: [PR # or branch]

**Risk level:** [LOW / MEDIUM / HIGH]
**Intent:** [1-2 sentence summary of what this change tries to do]

## Changed Files
- [file1] --- [what changed]
- [file2] --- [what changed]

## Impact Surface

### Direct Changes
- [function/component] --- [behavioral change]

### Dependents
- [caller/importer] --- [ripple effect]

### Shared State
- [✓/✗] DB schema changes
- [✓/✗] API contract changes
- [✓/✗] Config / env vars / feature flags
- [✓/✗] Global state / context providers
- [✓/✗] CSS / style changes

## Verification Checklist

- [ ] [page/flow] --- [what to verify] --- [why it might break]
- [ ] [page/flow] --- [what to verify] --- [why it might break]
- [ ] [page/flow] --- [what to verify] --- [why it might break]

## Blind Spots (MEDIUM/HIGH only)
- [hidden dependency] --- [why it matters]

## Suspicious Patterns
- [✓/✗] Scope creep
- [✓/✗] Orphaned code
- [✓/✗] New dependencies
- [✓/✗] Missing migrations
- [✓/✗] Hardcoded values
- [✓/✗] Test gaps
