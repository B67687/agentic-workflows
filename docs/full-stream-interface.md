# Full-Stream Interface Architecture

The interface contract between the orchestration layer (agentic-workflows) and
the execution layer (DeepSeek-TUI, OpenCode, Claude Code, etc.).

---

## The Agent Stack

```
Layer 5: HUMAN INTERFACE           Natural language goal from the user
           │
           │  structured intake via Question Gate / Route
           ▼
Layer 4: ORCHESTRATION (us)        Methodology, quality, skills, tools
           │
           │  ═══ FULL STREAM INTERFACE ═══
           │  MCP protocol + structured manifests
           ▼
Layer 3: EXECUTION RUNTIME         Tool execution, LSP, sub-agents, sessions
           │
           │  OpenAI-compatible Chat Completions API
           ▼
Layer 2: LLM INTEGRATION           Model routing, streaming, cost tracking
           │
           │  HTTP API
           ▼
Layer 1: MODEL PROVIDERS           DeepSeek, NVIDIA NIM, OpenRouter, etc.
```

## The Interface (Layer 4 ↔ Layer 3)

Our orchestration layer communicates with the execution layer through
**three structured artifacts**:

### 1. Tool Registry (`scripts/tools.toml`)

Every agent-callable tool is defined with:

| Field | Type | Purpose |
|-------|------|---------|
| `name` | string | Stable identifier for tool dispatch |
| `description` | string | Human-readable purpose (model sees this) |
| `category` | string | Functional grouping (workflow, quality, session, etc.) |
| `path` | string | Script path for invocation |
| `type` | string | `script`, `command`, `hook`, or `internal` |
| `phases` | string[] | Which workflow phases this tool participates in |
| `quality_gates` | string[] | Which quality gates to trigger after use |
| `inputs` | object | JSON Schema-style input definitions |

**Consumed by:**
- MCP server (registers each tool dynamically)
- Agent prompts (tool discovery via `--json` flag)
- Quality gates (know which gates fire after which tools)

### 2. Skill Index (`scripts/skills.toml`)

Every skill is defined with:

| Field | Type | Purpose |
|-------|------|---------|
| `name` | string | Matches SKILL.md frontmatter `name` |
| `description` | string | Human-readable purpose for model routing |
| `bundle` | string | Lifecycle bundle (define, build, verify, ship, meta, product) |
| `compatibility` | string | Compatible agent runtimes |
| `companion` | string | Optional companion script path |
| `trigger_phrases` | string[] | Natural-language triggers for skill activation |

**Consumed by:**
- Agent runtimes (discover skills compatible with their format)
- Skill-toolset progressive loading (L1/L2/L3)
- MCP resources endpoint

### 3. SKILL.md Files (`skills/<name>/SKILL.md`)

DeepSeek-TUI-compatible frontmatter, auto-discovered from multiple directories:

| Directory | Precedence | Purpose |
|-----------|------------|---------|
| `.agents/skills/` | Highest | DeepSeek-native convention |
| `skills/` | | Project-local skills (our primary location) |
| `.opencode/skills/` | | OpenCode interop |
| `.claude/skills/` | | Claude Code interop |
| `.cursor/skills/` | | Cursor interop |
| `~/.agents/skills/` | | agentskills.io global |
| `~/.claude/skills/` | | Claude-ecosystem global |
| `~/.deepseek/skills/` | Lowest | DeepSeek global default |

SKILL.md frontmatter fields used by DeepSeek-TUI's parser:
- `name` (required) — skill identifier
- `description` (recommended) — driver for model-visible skills block
- All other fields stored as body (harmless extras)

## Data Flow (One Complete Turn)

```
[User] "Fix the bug in parse_config()"
    │
    ▼  Layer 5→4
[Question Gate] probes ambiguity, clarifies scope
[Research] maps system, finds call sites, analyzes bug
[Plan] breaks into steps, defines files and verification
    │
    │  Layer 4→3 via MCP:
    │  tool_call("phase-gate", {phase: "implement"})
    │  tool_call("implement", {steps: [...]})
    │
    ▼
[Execution Runtime]
    ├─ file:read existing code
    ├─ file:edit → LSP diagnostics → auto-fix if errors
    ├─ shell:run cargo test
    ├─ Checkpoint session state
    ├─ Call back to quality gates via MCP:
    │   tool_call("quality-gate", {phase: "post-edit"})
    │   tool_call("comprehension-gate", {action: "verify"})
    │
    ▼
    ── structured results return ──
    {
      steps: [
        {file: "src/config.rs", status: "edited", diagnostics: []},
        {cmd: "cargo test", status: "passed"}
      ],
      quality: {passed: 3, warnings: [], blocked: false}
    }
    │
    ▼
[Verify] confirms quality results
[Retrospect] captures learnings
[Checkpoint] commits and updates session state
```

## Build Timeline

| Phase | Artifacts | Status |
|-------|-----------|--------|
| **1. Structured Interface** | `tools.toml`, `skills.toml`, `tools.sh --json`, SKILL.md alignment | **DONE** ← current |
| **2. MCP Server** | `scripts/serve-mcp.sh`, MCP config for DeepSeek-TUI/OpenCode | Next |
| **3. Post-Edit Quality Loop** | Post-edit hook protocol, feedback aggregator | Planned |
| **4. Full Integration** | Methodology MCP resources, session state sync, cognitive safeguard tools | Future |

## Related

- `scripts/tools.toml` — structured tool manifest
- `scripts/skills.toml` — structured skill index
- `scripts/tools.sh` — tool registry (reads tools.toml, supports --json)
- `docs/mcp-architecture.md` — MCP reference
- `docs/workflow.md` — workflow methodology
