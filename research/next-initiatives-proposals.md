# Next Initiatives — Shaped Proposals

Session: 2026-05-19
Status: Shaped (proposal level, not yet implemented)
Goal tree: see `.runtime/goal-tree.json`

These four initiatives were shaped after completing the Pi-Star Mastery sprint (6 meso goals).
The core insight: **base everything on first-principles research first**, then execute the research→plan→implement→verify cycle per initiative.

---

## Initiative 1: First-Principles Methodology

**Goal:** Add a first-principles decomposition step to Phase 0 of the research methodology.

**What it is:** A structured decomposition step between "scope the question" and "discover local knowledge."
Before looking at external sources or existing knowledge, decompose the problem to fundamental axioms
and rebuild from there.

**Where it fits:**
```
Phase 0: Frame the Question
├── 1. State topic
├── 2. Apply 5W+H
├── 3. Define "done"
├── 4. Scope the funnel
├── 5. Check assumptions
├── [NEW] 6. First-Principles Decomposition
│     ├── a. Identify core entities/forces
│     ├── b. Strip to fundamentals (what MUST be true?)
│     ├── c. Reconstruct from axioms
│     ├── d. Gap analysis (what fundamentals are unknown?)
│     └── e. Reframe research questions from gaps
└── → Phase 1: Discover Local Knowledge
```

**Status:** Approved. Ready for implementation in next session.

---

## Initiative 2: Research Methodology Audit

**Goal:** Apply first-principles methodology to audit and tighten the existing `research-prompt.md`.

**First-principles audit result:** Current methodology (6 phases, 425 lines) is ~75% solid.
Key gaps found:
1. Per-claim confidence tagging not enforced in output
2. Unknown-unknowns not systematically surfaced
3. Verification before integration is optional, not forced

**Scope:**
| Slice | What | Output |
|-------|------|--------|
| 1 | Audit current methodology against FP axioms | Gap analysis doc (done in shaping) |
| 2 | Add per-claim confidence enforcement | Update Phase 3 output spec |
| 3 | Add unknown-unknowns surfacing | Update Phase 0 |
| 4 | Add verification gate plugin | New `research/verification.sh` gate |

**Status:** Depends on Initiative 1 being written first. Ready to implement after.

---

## Initiative 3: Benchmark Baseline (Hybrid)

**Goal:** Establish objective measurement for harness effectiveness — both public benchmarks and custom.

**Existing assets:** `scripts/tools/skill-bench.sh` (499 lines), `benchmarks/generic/` (7 tasks).

**Two-signal model:**
- **Public benchmarks** → competitiveness signal (periodic, quarterly)
- **Custom benchmarks** → direction signal (continuous, per-change)
- **Custom is only trusted once validated against public** (correlation check)

**Phases:**
| Phase | What | Public | Custom |
|-------|------|--------|--------|
| 1 | Pick 2-3 public benches (SWE-bench, etc.) | Primary | Not yet |
| 2 | First baseline run | Active | Building |
| 3 | Build custom registry + score aggregator | Reference | Active |
| 4 | Validate correlation between public and custom | Reference | Primary |
| 5 | Custom becomes primary, public as calibration | Calibration | Primary |

**Status:** Shaped. Ready for implementation (can run parallel to Initiatives 1+2).

---

## Initiative 4: Self-Improving Framework

**Goal:** Close the loop: detect degradation/plateau → generate improvement → test → keep/discard.

**Core loop (from first-principles):**
```
Measurement ──→ Gap detected ──→ Proposal generated
     ↑                                │
     │                                ▼
     └── Score change ◄── Verify ◄── Test on bench
```

**Dependencies:**
- Bench baseline (Initiative 3) must be validated first — self-improving can't trust the signal until the bench is calibrated against public benchmarks
- FP methodology (Initiative 1) gives the proposal generation structure

**Key risk:** Self-improving can produce negative outcomes if the signal is bad. Must be built last.

**Scope (sequential phases):**
| Phase | What | Depends on |
|-------|------|------------|
| 0 | Design the loop as a workflow definition | Nothing (design doc) |
| 1 | Detection mechanism — bench monitoring, plateau detection | Bench aggregator (I3) |
| 2 | Improvement proposal format — structured packet | FP methodology (I1) |
| 3 | Test harness — run proposal against bench, compare scores | Bench aggregator (I3) |
| 4 | Meta-loop — improve the improver | All of the above |

**Status:** Shaped. Not ready for implementation until Initiatives 1 and 3 produce outputs.

---

## Execution Strategy

```
Track A: #1 (FP Methodology) ──→ #2 (Research Audit)
    ──→ Implementation slot 1

Track B: #3 (Bench Baseline) ──→ #4 (Self-Improving)
    ──→ Implementation slot 2 (parallel to Track A)

Track A and Track B are independent until #4 needs #3's signal.
```

## Files to read in next session

- `research/next-initiatives-proposals.md` (this file — full proposals)
- `.runtime/goal-tree.json` (goal tree with new branches)
- `HANDOVER.md` (state handoff)
- `research/research-prompt.md` (existing methodology, for Initiative 2)
- `scripts/tools/skill-bench.sh` (existing bench infrastructure, for Initiative 3)
- `benchmarks/generic/` (existing benchmark tasks, for Initiative 3)
