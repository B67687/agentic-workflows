# HANDOVER — Session 3 (2026-05-21)

## Overarching Goal
Build benchmark infrastructure (Phase 3) to measure agent performance, then propagate patterns cross-repo (Phase 4: Pi-Star). The Terminal-Bench agent run is a **stepping stone** — we need to prove the Harbor → local agent pipeline works end-to-end so we can iterate on agent quality. If one method is stuck, try another.

## State
- **BigCodeBench**: 1103/1140 pass (96.8%), 37 fail, 0 unknown — FULLY VERIFIED
- **Terminal-Bench oracle**: 89/89, 95.5% mean — DONE (baseline established)
- **Terminal-Bench adapter**: at `adapters/terminal-bench/` — SCAFFOLDED, downloads 89 tasks
- **Harness tests**: 24 tests in `scripts/infra/test-benchmark-tools.sh` — ADDED, wired into P16 of smoke tests
- **Working tree**: clean

## What Happened This Session

### Priority 1: Terminal-Bench Agent Run — STALLED
We tried several approaches to run a real agent (opencode-go/deepseek-v4-flash) against Terminal-Bench:

| Attempt | Result | Why |
|---------|--------|-----|
| Nop agent test | ✅ Pipeline works | Docker + Harbor verified |
| `opencode-go/deepseek-v4-flash` no key | ❌ Missing API key | Expected |
| `--ak opencode_config=...` with key | ❌ Invalid API key | Harbor's agent doesn't handle `opencode-go` provider |
| `environment.env` with `${OPENCODE_API_KEY}` | ❌ Key not reaching container | Env var routing mismatch |
| `agents[].env` with `openai/ds/deepseek-v4-flash` + 9router | ❓ Untested | Config ready, needs `export OPENAI_API_KEY` + run |

**Root cause**: Harbor's opencode agent (`harbor/agents/installed/opencode.py`) has no `elif provider == "opencode-go"` handler. It collects `OPENCODE_API_KEY` only for `provider == "opencode"`. Plus, the host's `opencode-go` wraps a 9router sub-provider with nested config — Harbor's flat config gen can't replicate it.

### Priority 2: Wire Smoke Tests — ✅ DONE
- P16: Benchmark Tools section added to `scripts/infra/test-smoke.sh`
- 23/24 tests pass (1 pre-existing slow test timeout)
- `.env*` added to `.gitignore`

### Priority 3: Pi-Star Propagation — NOT STARTED

## Current Config (untested approach)
`adapters/terminal-bench/run_terminal-bench.yaml` uses `openai` provider → 9router proxy:
```yaml
agents:
  - name: opencode
    model_name: openai/ds/deepseek-v4-flash
    env:
      OPENAI_API_KEY: ${OPENAI_API_KEY}
      OPENAI_BASE_URL: http://172.17.0.1:20128/v1
```

The `openai` provider IS handled by the agent (forwards `OPENAI_API_KEY` and `OPENAI_BASE_URL`). The 9router proxy runs at localhost:20128 and the Docker gateway `172.17.0.1` should reach it.

**To test**: `export OPENAI_API_KEY=sk-b50b209ecb0b0428-1vyj4i-064e61c3` then run without `-a` flag.

## Alternative Approaches (try if config above fails)

### Approach A: Patch Harbor's agent code
Add one line to `harbor/agents/installed/opencode.py` in the `run()` method:
```python
elif provider == "opencode-go":
    keys.append("OPENCODE_API_KEY")
```
Then the `opencode-go/deepseek-v4-flash` model works with `export OPENCODE_API_KEY=...`.

### Approach B: Use `openrouter` with free model
Harbor handles `openrouter` provider. Use a free tier model:
```bash
export OPENROUTER_API_KEY=...
harbor run -c config.yaml -a opencode -m openrouter/meta-llama/llama-3.3-70b-instruct:free ...
```

### Approach C: Use `terminus-2` agent (Harbor's own)
Harbor ships the `terminus-2` agent for Terminal-Bench. This is the officially recommended agent:
```bash
export ANTHROPIC_API_KEY=...
harbor run --dataset terminal-bench@2.0 --agent terminus-2 --model anthropic/claude-opus-4-1
```

### Approach D: Use official dataset registry
Instead of local dataset, use Harbor's registry to download Terminal-Bench 2.0:
```bash
harbor run --dataset terminal-bench@2.0 --agent oracle
```

### Approach E: Use `network_mode: host` in Docker env
Add to YAML to let Docker reach host services:
```yaml
environment:
  type: docker
  network_mode: host
```

## Backlog
1. Finish Priority 1: Terminal-Bench agent run (try approaches above)
2. Priority 2: Done
3. Priority 3: Phase 4 Pi-Star propagation
4. Ongoing: Maintain BigCodeBench verified state, update as needed

## Startup
```bash
bash ./scripts/hooks/session-start.sh
bash scripts/bench/audit-state.sh
```
