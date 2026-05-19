---
name: harness-orientation
description: Navigate and understand the agentic-workflows harness -- workflow definitions, goal tree, benchmark system, startup gate, and operating contract.
compatibility: opencode
allowed-tools: read, grep, glob, bash
metadata:
  bundle: meta
  handoffs: context-engineering (to set up context), using-agent-skills (to pick a skill)
  trigger-phrases: read harness, workflow structure, goal tree, benchmark system, AGENTS.md, startup gate
---

# Harness Orientation

## Overview

The agentic-workflows harness is a systems engineering workspace for orchestrating, managing, and extending AI agents. Key subsystems:

### 1. Operating Contract (AGENTS.md)
Read `AGENTS.md` for the full operating contract. Key rules:
- Supply missing structure when safe
- Verify aggressively
- Commit after every meaningful change
- Fix macro-to-micro by default

### 2. Workflow Engine
Workflows are state machines defined in `workflow.d/<id>.yaml`. State persists in `workflow-state.json`.
- Steps can be `deterministic` (script-based, run automatically) or `deliberative` (conversational, require user consensus)
- Steps output results, trace appended, workflow advances
- `next:` field defines what runs after completion

### 3. Goal Tree
The goal tree at `.runtime/goal-tree.json` maintains a macro/meso/micro hierarchy of project goals.
- Each goal has a `status` (done/not done), `d` depth level, and optional children
- Read before resume for context

### 4. Benchmark System
Benchmarks live in `benchmarks/` organized by category: `generic/`, `harness/`, `public/`.
- Registry: `benchmarks/registry.json` maps benchmark IDs to metadata
- Runner: `scripts/tools/skill-bench.sh` (prepare -> execute -> verify)
- Aggregator: `scripts/bench/aggregate.sh` (summary, by-category, by-skill views)
- Gap detector: `scripts/bench/detect-gaps.sh` (coverage, signal, degradation, plateau)

### 5. Startup Gate
Every session runs `scripts/hooks/session-start.sh` first. It checks workflow state and guides classification.

## Navigation Sequence

When working with the harness, read files in this order:
1. `AGENTS.md` -- operating contract
2. `docs/workflow.md` -- fast workflow orientation
3. `workflow-state.json` -- current active workflow state
4. Task-specific files from the high-signal files table in AGENTS.md
