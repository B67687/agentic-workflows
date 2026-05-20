# HANDOVER — Session 3 (2026-05-21)

## State
- **BigCodeBench**: 1103/1140 pass (96.8%), 37 fail, 0 unknown
- **Terminal-Bench oracle**: 89/89, 95.5% mean — DONE
- **Working tree**: clean, all changes committed

## What Happened This Session

### Priority 1: Terminal-Bench Agent Run — NOT RESOLVED
- Nop agent test: ✅ Docker + Harbor pipeline works (33s, 0 exceptions)
- `opencode-go/deepseek-v4-flash` via Harbor: ❌ All trials get 0 reward
- Root cause identified: Harbor's `opencode-go` agent handler doesn't forward `OPENCODE_API_KEY` (no `elif provider == "opencode-go"` in the agent code)
- The host's `opencode-go` wraps 9router proxy as a sub-provider — Harbor's flat config generation can't replicate this structure

### Current Config (last working approach)
`adapters/terminal-bench/run_terminal-bench.yaml` uses `openai` provider routing through 9router:
- `model_name: openai/ds/deepseek-v4-flash`
- `OPENAI_API_KEY: ${OPENAI_API_KEY}` (resolved from env)
- `OPENAI_BASE_URL: http://172.17.0.1:20128/v1` (Docker gateway → host 9router proxy)
- The agent handles `openai` provider correctly (forwards `OPENAI_API_KEY`, `OPENAI_BASE_URL`)

### Priority 2: Wire Smoke Tests — ✅ DONE
- Added P16: Benchmark Tools section to `scripts/infra/test-smoke.sh`
- 23/24 benchmark tests pass (1 pre-existing timeout in cleanup-runs)
- Added `.env*` to `.gitignore`

### Priority 3: Pi-Star Propagation — NOT STARTED

## Next Session: To Run Terminal-Bench Agent
The user needs to:
```bash
export OPENAI_API_KEY=sk-b50b209ecb0b0428-1vyj4i-064e61c3
source .runtime/bench-env/bin/activate && harbor run \
  -c adapters/terminal-bench/run_terminal-bench.yaml \
  -k 5 \
  -y \
  --jobs-dir adapters/terminal-bench/jobs/opencode-k5
```

Or alternatively:
- Patch Harbor's opencode agent to forward `OPENCODE_API_KEY` for `opencode-go` provider
- Use OpenRouter free models
- Read Terminal-Bench official docs: `github.com/harbor-framework/terminal-bench`

## Backlog
1. Finish Priority 1: Terminal-Bench agent run
2. Priority 3: Phase 4 Pi-Star propagation

## Startup
```bash
bash ./scripts/hooks/session-start.sh
bash scripts/bench/audit-state.sh
```
