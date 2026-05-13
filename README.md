# agentic-workflows --- Systems Engineering for AI Agents

Systems engineering applied to the agent domain: an agent harness for orchestrating,
managing, and extending AI agents. Cross-repo orchestration, knowledge propagation,
and capability management.

## Start Here: Pick Your Goal

| I Want To... | Start With |
|--------------|------------|
| **Write better prompts** | [Daily Prompts](docs/daily-prompts.md) -> [Prompt Library](docs/prompt-templates.md) |
| **Set up AI agents in my project** | [Hub Quickstart](docs/hub-quickstart.md) -> [Workflow](docs/workflow.md) -> [AGENTS.md](AGENTS.md) |
| **Build an AI product** | [AI Product Building](docs/ai-product-building.md) -> [TDD with Agents](docs/tdd-with-agents.md) |
| **Research a new AI topic** | [Research Methodology](research/research-prompt.md) -> [Well-Maintained Systems](research/well-maintained-system-research.md) |
| **Understand this whole system** | [Workflow](docs/workflow.md) -> [Cross-Project Memory](docs/cross-project-memory-loop.md) |
| **Resume interrupted work** | [Session State](session-state.json) -> [AGENTS.md](AGENTS.md) |

## Structure

```
/ (root)
|- AGENTS.md              # Operating contract --- rules for working in this repo
|- README.md              # This file --- navigation and learning paths
|- docs/                  # Core knowledge base
|- research/              # Active research campaigns
|- scripts/               # Automation scripts
|- workflow/              # Session state, sync logs, registries
|- propagation/   # Templates synced to topic folders
`- ../personal-voice/      # User voice profile (topic folder, not embedded)
```

## Learning Paths

### Prompting Path
For anyone who wants to write better prompts immediately.

1. **[docs/daily-prompts.md](docs/daily-prompts.md)** --- 5 reusable prompt shapes for common tasks
2. **[docs/prompt-templates.md](docs/prompt-templates.md)** --- Full copy-paste library index
3. **[docs/token-efficient-prompting.md](docs/token-efficient-prompting.md)** --- Reduce token burn without losing quality

### Agent Setup Path
For setting up agentic workflows in your projects.

1. **[docs/hub-quickstart.md](docs/hub-quickstart.md)** - Fast orientation for the current system
2. **[docs/fast-stable-delivery.md](docs/fast-stable-delivery.md)** --- Why this system is structured around big goals, bounded bets, and small verified slices
3. **[archive/superseded/agentic-workflows.md](archive/superseded/agentic-workflows.md)** --- Routing ideas, fresh-context patterns, and execution lanes
4. **[archive/superseded/core-agent-doctrine.md](archive/superseded/core-agent-doctrine.md)** --- 10 principles that underpin the system
5. **[AGENTS.md](AGENTS.md)** - Operating contract: rules, thresholds, coordination notes
6. **[AGENTS.md](AGENTS.md)** + **[session-state.json](session-state.json)** --- Runtime contract and resume state

### Product Building Path
For building products fast with AI agents.

1. **[docs/ai-product-building.md](docs/ai-product-building.md)** --- One-page spec, 6-week timeline, agent patterns
2. **[docs/tdd-with-agents.md](docs/tdd-with-agents.md)** --- Tests-first and red/green patterns
3. **[archive/lessons/learning-while-building-with-agents.md](archive/lessons/learning-while-building-with-agents.md)** --- Keep learning speed close to build speed

### Research Path
For investigating AI topics authoritatively.

1. **[archive/research/research-methodology.md](archive/research/research-methodology.md)** --- Source hierarchy, verification, confidence levels
2. **[archive/lessons/authoritative-agent-best-practices.md](archive/lessons/authoritative-agent-best-practices.md)** --- Cross-tool guidance
3. **[archive/research/research-findings.md](archive/research/research-findings.md)** --- Durable discoveries from past research
4. **[research/research-log.md](research/research-log.md)** --- Active research campaigns

### System Path
For understanding how this hub and its ecosystem work.

1. **[docs/workflow.md](docs/workflow.md)** --- Whole-system map
2. **[docs/cross-project-memory-loop.md](docs/cross-project-memory-loop.md)** --- How knowledge flows: topic folders ↔ hub
3. **[scripts/propagate-to-all.sh](scripts/propagate-to-all.sh)** + **[docs/workflow.md](docs/workflow.md)** --- How shared defaults propagate to topic folders

## Quick Reference

| Need | Doc |
|------|-----|
| Session checkpoint rules | [docs/session-checkpoint.md](docs/session-checkpoint.md) |
| Model selection guide | [docs/model-selection-guide.md](docs/model-selection-guide.md) |
| Provider runtime and account switching | [docs/provider-runtime.md](docs/provider-runtime.md) |
| Quality standards | [docs/quality-standards.md](docs/quality-standards.md) |
| Git/GitHub best practices | [docs/git-github-best-practices.md](docs/git-github-best-practices.md) |
| Fast stable delivery model | [docs/fast-stable-delivery.md](docs/fast-stable-delivery.md) |
| Counsel model selection | [docs/counsel-model-selection.md](docs/counsel-model-selection.md) |
| Borrowed workflow patterns that fit this hub | [archive/superseded/agentic-workflows.md](archive/superseded/agentic-workflows.md) |
| Repo tooling (Windows/WSL) | [docs/repo-tooling.md](docs/repo-tooling.md) |
| Token-efficient prompting | [docs/token-efficient-prompting.md](docs/token-efficient-prompting.md) |

## Research

- **[research/research-log.md](research/research-log.md)** --- Active research intake and campaign index
- **[research/research-prompt.md](research/research-prompt.md)** --- Reusable research prompt with analysis framework
- **[research/integration-log.md](research/integration-log.md)** --- Research-to-knowledge-base integration tracker
- **[archive/research/research-findings.md](archive/research/research-findings.md)** --- Durable validated discoveries
- **[archive/research-log-2026-04.md](archive/research-log-2026-04.md)** --- Full April 2026 pre-optimization research log.

## Scripts

Use [scripts/ws.sh](scripts/ws.sh) for common workspace operations:

```bash
bash ./scripts/ws.sh status      # Check workspace state
bash ./scripts/ws.sh validate    # Run quality audit
bash ./scripts/ws.sh hotspots    # Find recent changes
bash ./scripts/ws.sh search -q "session-state"
```

## Propagation

Templates in `propagation/` drive two different actions:

- bootstrap missing shared files into topic folders
- refresh only the hub-owned managed core in topic folders

```bash
bash ./scripts/propagate-to-all.sh
bash ./scripts/propagate-to-all.sh --apply
bash ./scripts/checkpoint-commit.sh -m "checkpoint summary"
```

- Managed core: `AGENTS.md`, `archive/superseded/workspace-system-overview.md`, `checkpoint-commit.sh`, and helper scripts
- Repo-owned after bootstrap: `session-state.json`, `topic-insights.md`, `.cleanup-protect`, and archive history files
- Topic folders create `[folder-name]-content/` for normal project work
- Run the smoke test after changing `propagate-to-all.sh`, `check-sync-status.sh`, `sync-from-hub.template.sh`, or `propagation-contract.sh`

## Acknowledgments

This harness was built by studying, referencing, and integrating patterns from the
following open-source projects. Each contributed ideas, architecture patterns,
workflow concepts, or direct code references.

### Agent Frameworks & SDKs
| Repo | What it contributed |
|------|-------------------|
| [microsoft/autogen](https://github.com/microsoft/autogen) | Multi-agent conversation patterns |
| [crewAIInc/crewAI](https://github.com/crewAIInc/crewAI) | Role-based agent orchestration |
| [openai/openai-agents-python](https://github.com/openai/openai-agents-python) | Agent loop and handoff design |
| [google/adk-python](https://github.com/google/adk-python) | Agent Development Kit patterns |
| [anthropics/claude-agent-sdk](https://github.com/anthropics/claude-agent-sdk) | Agent lifecycle and tool use |
| [pydantic/pydantic-ai](https://github.com/pydantic/pydantic-ai) | Type-safe agent definitions |
| [Significant-Gravitas/AutoGPT](https://github.com/Significant-Gravitas/AutoGPT) | Autonomous agent loop concepts |
| [1024lab/MetaGPT](https://github.com/1024lab/MetaGPT) | Role-based software team simulation |
| [a2aproject/A2A](https://github.com/a2aproject/A2A) | Agent-to-agent protocol |
| [nousresearch/hermes-agent](https://github.com/nousresearch/hermes-agent) | Research agent architecture |
| [agentscope-ai/agentscope](https://github.com/agentscope-ai/agentscope) | Distributed agent platform |
| [langchain-ai/Open-SWE](https://github.com/langchain-ai/Open-SWE) | Software engineering agent patterns |

### Agent CLIs & Developer Tools
| Repo | What it contributed |
|------|-------------------|
| [anthropics/claude-code](https://github.com/anthropics/claude-code) | Agentic coding workflow patterns |
| [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) | Plugin/skill integration patterns |
| [Aider-AI/aider](https://github.com/Aider-AI/aider) | Pair-programming agent patterns |
| [SWE-agent/mini-SWE-agent](https://github.com/SWE-agent/mini-SWE-agent) | Lightweight agent architecture |
| [garrytan/gstack](https://github.com/garrytan/gstack) | Git workflow and stack management |
| [browser-use/browser-use](https://github.com/browser-use/browser-use) | Browser automation patterns |
| [bytedance/UI-TARS-desktop](https://github.com/bytedance/UI-TARS-desktop) | UI agent interaction patterns |
| [bytedance/deer-flow](https://github.com/bytedance/deer-flow) | Workflow-based agent coordination |
| [GitHub Copilot](https://github.com/features/copilot) | Agentic coding assistant concepts |

### Skills, Quality & Methodology
| Repo | What it contributed |
|------|-------------------|
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | **Core skill framework** --- 27 engineering skills + TAP methodology skills that this hub integrates |
| [donnemartin/system-design-primer](https://github.com/donnemartin/system-design-primer) | Systems engineering methodology |

### UI & Design Systems
| Repo | What it contributed |
|------|-------------------|
| [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md) | Visual language specification patterns |
| [voltagent/voltagent](https://github.com/voltagent/voltagent) | Agent design system concepts |
| [charmbracelet/crush](https://github.com/charmbracelet/crush) | TUI design inspiration |

### Memory & Knowledge Management
| Repo | What it contributed |
|------|-------------------|
| [mem0ai/mem0](https://github.com/mem0ai/mem0) | Memory layer patterns |
| [LMCache/LMCache](https://github.com/LMCache/LMCache) | LLM context caching patterns |
| [MemPalace/mempalace](https://github.com/MemPalace/mempalace) | Memory palace architecture |
| [MemTensor/MemOS](https://github.com/MemTensor/MemOS) | Memory operating system concepts |
| [VectifyAI/PageIndex](https://github.com/VectifyAI/PageIndex) | Knowledge indexing patterns |
| [HKUDS/RAG-Anything](https://github.com/HKUDS/RAG-Anything) | RAG pipeline patterns |

### Workflow & Automation Platforms
| Repo | What it contributed |
|------|-------------------|
| [n8n-io/n8n](https://github.com/n8n-io/n8n) | Workflow automation patterns |
| [FlowiseAI/Flowise](https://github.com/FlowiseAI/Flowise) | Visual workflow builder concepts |
| [langflow-ai/langflow](https://github.com/langflow-ai/langflow) | LangChain-based workflow patterns |
| [langgenius/dify](https://github.com/langgenius/dify) | LLM application platform patterns |
| [mnfst/manifest](https://github.com/mnfst/manifest) | Backend-as-code workflow concepts |
| [Infisical/infisical](https://github.com/Infisical/infisical) | Secrets management patterns |

### Learning Resources & Inspirations
| Repo | What it contributed |
|------|-------------------|
| [alexzhang13/rlm](https://github.com/alexzhang13/rlm) | Research on language model patterns |
| [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) | Comprehensive Claude Code resource |
| [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | Claude Code tooling collection |
| [selopo-ec/my-awesome-copilot](https://github.com/selopo-ec/my-awesome-copilot) | Copilot workflow patterns |
| [sansan0/TrendRadar](https://github.com/sansan0/TrendRadar) | AI trend tracking methodology |
| [thunderbird/thunderbolt](https://github.com/thunderbird/thunderbolt) | Architecture documentation patterns |
| [vercel-labs/portless](https://github.com/vercel-labs/portless) | Serverless agent patterns |
| [zilliztech/claude-context](https://github.com/zilliztech/claude-context) | Context engineering patterns |

### Additional Starred Resources
These repositories from the owner's starred list also influenced the direction
of this harness:

| Category | Repos |
|----------|-------|
| **Agent Platforms** | [cline/cline](https://github.com/cline/cline), [earendil-works/pi](https://github.com/earendil-works/pi), [trycua/cua](https://github.com/trycua/cua), [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents), [ultraworkers/claw-code](https://github.com/ultraworkers/claw-code), [karpathy/autoresearch](https://github.com/karpathy/autoresearch), [karpathy/llm-council](https://github.com/karpathy/llm-council), [bytedance/trae-agent](https://github.com/bytedance/trae-agent), [ThePrimeagen/harpoon](https://github.com/ThePrimeagen/harpoon) |
| **Agent Skills & Prompts** | [badlogic/pi-skills](https://github.com/badlogic/pi-skills), [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills), [mattpocock/skills](https://github.com/mattpocock/skills), [ComposioHQ/awesome-codex-skills](https://github.com/ComposioHQ/awesome-codex-skills), [jiangjiax/counsel](https://github.com/jiangjiax/counsel) |
| **MCP & Protocols** | [modelcontextprotocol/registry](https://github.com/modelcontextprotocol/registry), [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers), [github/github-mcp-server](https://github.com/github/github-mcp-server) |
| **Memory & RAG** | [rohitg00/agentmemory](https://github.com/rohitg00/agentmemory), [microsoft/graphrag](https://github.com/microsoft/graphrag), [ruvnet/ruflo](https://github.com/ruvnet/ruflo), [ruvnet/RuView](https://github.com/ruvnet/RuView) |
| **Tools Used in This Hub** | [tree-sitter/tree-sitter](https://github.com/tree-sitter/tree-sitter) (repo-map), [microsoft/playwright](https://github.com/microsoft/playwright) (browser automation), [newren/git-filter-repo](https://github.com/newren/git-filter-repo) (rewrote history), [promptfoo/promptfoo](https://github.com/promptfoo/promptfoo) (prompt testing), [anomaloco/opencode](https://github.com/anomaloco/opencode) (the runtime this harness runs on) |
| **LLMs & Models** | [deepseek-ai/DeepSeek-V3](https://github.com/deepseek-ai/DeepSeek-V3), [QwenLM/Qwen](https://github.com/QwenLM/Qwen), [QwenLM/qwen-code](https://github.com/QwenLM/qwen-code), [openai/codex](https://github.com/openai/codex), [google-gemini/gemini-cli](https://github.com/google-gemini/gemini-cli) |
| **Learning & Community** | [datawhalechina/hello-agents](https://github.com/datawhalechina/hello-agents), [jjyaoao/HelloAgents](https://github.com/jjyaoao/HelloAgents), [shanraisshan/claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice), [shareAI-lab/learn-claude-code](https://github.com/shareAI-lab/learn-claude-code), [pingdotgg/t3code](https://github.com/pingdotgg/t3code), [DayuanJiang/next-ai-draw-io](https://github.com/DayuanJiang/next-ai-draw-io), [microsoft/generative-ai-for-beginners](https://github.com/microsoft/generative-ai-for-beginners) |

### Also Referenced
- [OpenViking (volcengine/OpenViking)](https://github.com/volcengine/OpenViking)
- [OpenClaw / Pen](https://github.com/openclaw/pen)
- [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md)
- [RLM (alexzhang13/rlm)](https://github.com/alexzhang13/rlm)

If you are a maintainer of any project listed here and would prefer a different
attribution or removal, please open an issue.

## Maintenance Rule

If you want to keep improving this folder:

1. Save the prompt shape that worked.
2. Save the lesson that should change future behavior.
3. Save one compact example of when to use it.

## Common Commands

Use bash as the default terminal for workspace automation. Only fall back to PowerShell in repos that explicitly require it.

Fast workflow:

- keep the dream large, but only execute one verified slice at a time
- type normally; serious requests route internally through `/route`
- prompting best practices run internally through `/prompt-contract`
- `/task your goal` --- classify, grill, shape, slice, and intake any task
- `/counsel your decision` when a high-cost decision needs independent challenge
- `/repo-map` when the folder is unfamiliar or the task is broad
- `/research your task`
- `/plan your task`
- `/implement your task`
- `/optimize your task` for performance or architecture cost work
- `/session checkpoint` to wrap up a verified phase
- `/session handoff` before a new session or high-context transition
- `/session finish` to close and checkpoint in one step
