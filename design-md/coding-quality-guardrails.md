# Coding Quality Guardrails — Design Proposal

## Current State
- **Benchmark pipeline works** — Harbor + 9router → 5/5 tasks completed, zero exceptions
- **Smoke tests** — P16 suite wired, runs on session start
- **Propagation** — template-to-topic-folder sync works (hub → pi-star and others)
- **Quality gate** — pre-commit hook exists (`quality-gate.sh`) but limited to shell style checks
- **No CI** — everything is local/manual

## Desired End State
A layered quality system:
1. **Instant (pre-commit):** Style, safety, drift — fails fast (< 1s)
2. **Fast (pre-push):** Smoke tests, benchmark subset — < 2 min  
3. **Deep (CI/CD):** Full benchmark suite, cross-repo propagation check — on push/main

## Proposed Layers

### Layer 1: Pre-commit Gate (instant)
**What:** Enhancement to existing `quality-gate.sh`
- Shellcheck (already done)
- Propagated file drift check (`propagate-to-all.sh --check`)
- Benchmark smoke test (P16 subset, < 30s)
- **New:** Branch name convention enforcement
- **New:** No large files / secrets in commit

### Layer 2: Pre-push Gate (fast)
**What:** New `scripts/git/pre-push.sh`
- Run P16 smoke suite
- Run 5-task Terminal-Bench smoke (already proven at 2m 37s)
- Check propagation drift for changed templates
- Block push if any fail

### Layer 3: CI Gate (deep)
**What:** GitHub Actions workflow (`.github/workflows/quality.yaml`)
- On push to main / PR to main
- Full benchmark sweep
- Full propagation check across all topic folders
- Build verification (if applicable)
- Comment results on PR

## Patterns to Follow
- **Composability:** Each layer is a standalone script, layers can be skipped with flags
- **Progressive failure:** Instant → Fast → Deep, fail early
- **Benchmark-as-gate:** Use the pipeline we just built for real enforcement

## Open Questions
1. Where do benchmark results go? (Job registry? PR comments? Slack?)
2. Should we gate on pass rate or just completion? (0.0 model score ≠ infra failure)
3. Which topic folders get propagation checks?
4. Do we want CI secrets management for 9router?
