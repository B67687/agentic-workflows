<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://img.shields.io/badge/agentic–workflows-121212?style=for-the-badge&logo=github&logoColor=white">
    <img alt="agentic-workflows" src="https://img.shields.io/badge/agentic–workflows-000000?style=for-the-badge&logo=github&logoColor=white">
  </picture>
</p>

<p align="center">
  <b>Systems engineering for AI agents.</b>
  <br>
  An operating contract, workflow system, and knowledge propagation harness
  <br>
  for orchestrating AI agents across repos.
</p>

<p align="center">
  <a href="https://github.com/B67687/agentic-workflows/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-green" alt="MIT License"></a>
  <a href="https://github.com/B67687/agentic-workflows"><img src="https://img.shields.io/github/last-commit/B67687/agentic-workflows" alt="Last Commit"></a>
  <a href="https://github.com/B67687/agentic-workflows"><img src="https://img.shields.io/github/repo-size/B67687/agentic-workflows" alt="Repo Size"></a>
  <a href="https://github.com/B67687/agentic-workflows"><img src="https://img.shields.io/github/stars/B67687/agentic-workflows" alt="Stars"></a>
</p>

---

## Why

AI agents are powerful, but they lack structure. Without an operating contract, every session starts from scratch. Without knowledge propagation, each repo reinvents the wheel. Without workflow discipline, context degrades and quality drops.

**agentic-workflows** solves this by applying systems engineering to the agent domain — giving agents a shared contract, a memory system, and a propagation layer that keeps knowledge flowing across repositories.

## Quick Start

```bash
# Clone the harness
git clone https://github.com/B67687/agentic-workflows.git
cd agentic-workflows

# Run the smoke test to verify everything works
bash ./scripts/test-smoke.sh

# Check workspace orientation
bash ./scripts/session-status.sh
```

Then open `AGENTS.md` — that's your operating contract. Every agent reads it first.

## Features

| | Area | What it gives you |
|---|---|---|
| 🧠 | **Operating Contract** | `AGENTS.md` — shared rules, conventions, and escalation paths that every agent reads first |
| 📚 | **Skill System** | 41 production-grade engineering skills with companion scripts — debug, test, review, ship |
| 🔄 | **Knowledge Propagation** | Cross-repo sync: one change in the hub propagates to all topic folders |
| 💾 | **Persistent Memory** | agentmemory + learnings system — agents remember what they learned across sessions |
| 🧪 | **Workflow Discipline** | Checkpoint, handoff, session management — structured phases, not chaotic chats |
| 🔍 | **Research Methodology** | 6-phase systematic research engine — source triangulation, confidence levels, authority weighting |
| 🛡️ | **Quality Guardrails** | Assumption expiry, context pressure monitoring, debug triage, pre-push hooks |
| 🌐 | **Multi-Repo** | Propagate templates and shared knowledge to 25+ topic folders from one hub |

## One-Minute Orientation

```
agentic-workflows/
├── AGENTS.md              ← Read this first — the operating contract
├── commands/              ← Slash commands (/task, /plan, /research, etc.)
├── docs/                  ← Core documentation
├── scripts/               ← Automation and tooling
├── skills/                ← 41 production-grade engineering skills
├── propagation/           ← Templates synced across topic folders
└── research/              ← Active research campaigns
```

## Documentation

| I Want To... | Start Here |
|---|---|
| Understand the whole system | [docs/workflow.md](docs/workflow.md) |
| Set this up in my project | [docs/hub-quickstart.md](docs/hub-quickstart.md) |
| Write better prompts | [docs/daily-prompts.md](docs/daily-prompts.md) |
| Research a new AI topic | [research/research-prompt.md](research/research-prompt.md) |
| Build an AI product | [docs/ai-product-building.md](docs/ai-product-building.md) |
| Debug a failure | [skills/debugging-and-error-recovery/SKILL.md](skills/debugging-and-error-recovery/SKILL.md) |
| Review code quality | [skills/code-review-and-quality/SKILL.md](skills/code-review-and-quality/SKILL.md) |
| Know the quality standards | [docs/quality-standards.md](docs/quality-standards.md) |
| Resume interrupted work | [session-state.json](session-state.json) + [AGENTS.md](AGENTS.md) |

## Quick Commands

```bash
bash ./scripts/session-status.sh          # Workspace orientation
bash ./scripts/ws.sh status               # Check workspace state
bash ./scripts/ws.sh validate             # Quality audit
bash ./scripts/tools.sh                   # Tool registry
bash ./scripts/search-index.sh "query"    # BM25 search across all docs
bash ./scripts/checkpoint-commit.sh -m "summary"  # Safe commit
```

## How It Works

**For a single project:**
1. Copy `AGENTS.md` into your repo root
2. Pick relevant skills from `skills/`
3. Add `docs/workflow.md` for session management
4. Agents now have shared context when they enter your repo

**For multiple projects (the hub model):**
1. This repo becomes the hub
2. Run `bash ./scripts/propagate-to-all.sh --apply`
3. Shared templates flow to every topic folder
4. Run `bash ./scripts/harvest-topic-insights.sh` to pull learnings back

**Compatible with:** Claude Code, Codex CLI, Cursor, OpenCode, and any agentic IDE that reads `AGENTS.md` or `CLAUDE.md`.

## Acknowledgments

This harness was built by studying, referencing, and integrating patterns from
the following open-source projects.

### Agent Frameworks & SDKs

| Repo | Influence |
|---|---|
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

| Repo | Influence |
|---|---|
| [anthropics/claude-code](https://github.com/anthropics/claude-code) | Agentic coding workflow patterns |
| [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) | Plugin/skill integration patterns |
| [Aider-AI/aider](https://github.com/Aider-AI/aider) | Pair-programming agent patterns |
| [SWE-agent/mini-SWE-agent](https://github.com/SWE-agent/mini-SWE-agent) | Lightweight agent architecture |
| [garrytan/gstack](https://github.com/garrytan/gstack) | Git workflow and stack management |
| [humanlayer/humanlayer](https://github.com/humanlayer/humanlayer) | **CodeLayer IDE** + human-in-the-loop SDK for coding agent orchestration |
| [browser-use/browser-use](https://github.com/browser-use/browser-use) | Browser automation patterns |
| [bytedance/UI-TARS-desktop](https://github.com/bytedance/UI-TARS-desktop) | UI agent interaction patterns |
| [bytedance/deer-flow](https://github.com/bytedance/deer-flow) | Workflow-based agent coordination |

### Skills, Quality & Methodology

| Repo | Influence |
|---|---|
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | **Core skill framework** — 27 engineering skills + 14 TAP methodology skills |
| [humanlayer/12-factor-agents](https://github.com/humanlayer/12-factor-agents) | **12-factor principles** for reliable LLM applications — context engineering, small focused agents, own your prompts |
| [donnemartin/system-design-primer](https://github.com/donnamartin/system-design-primer) | Systems engineering methodology |
| [tree-sitter/tree-sitter](https://github.com/tree-sitter/tree-sitter) | Repo-map generation |
| [promptfoo/promptfoo](https://github.com/promptfoo/promptfoo) | Prompt testing patterns |

### Memory, Knowledge & RAG

| Repo | Influence |
|---|---|
| [mem0ai/mem0](https://github.com/mem0ai/mem0) | Memory layer patterns |
| [LMCache/LMCache](https://github.com/LMCache/LMCache) | LLM context caching patterns |
| [MemPalace/mempalace](https://github.com/MemPalace/mempalace) | Memory palace architecture |
| [MemTensor/MemOS](https://github.com/MemTensor/MemOS) | Memory operating system concepts |
| [VectifyAI/PageIndex](https://github.com/VectifyAI/PageIndex) | Knowledge indexing patterns |
| [HKUDS/RAG-Anything](https://github.com/HKUDS/RAG-Anything) | RAG pipeline patterns |
| [rohitg00/agentmemory](https://github.com/rohitg00/agentmemory) | Persistent agent memory |
| [microsoft/graphrag](https://github.com/microsoft/graphrag) | Graph-based RAG |

### Workflow & Automation Platforms

| Repo | Influence |
|---|---|
| [n8n-io/n8n](https://github.com/n8n-io/n8n) | Workflow automation patterns |
| [FlowiseAI/Flowise](https://github.com/FlowiseAI/Flowise) | Visual workflow builder concepts |
| [langflow-ai/langflow](https://github.com/langflow-ai/langflow) | LangChain-based workflow patterns |
| [langgenius/dify](https://github.com/langgenius/dify) | LLM application platform patterns |
| [mnfst/manifest](https://github.com/mnfst/manifest) | Backend-as-code workflow concepts |
| [Infisical/infisical](https://github.com/Infisical/infisical) | Secrets management patterns |

### Agent Skills & Prompt Libraries

| Repo | Influence |
|---|---|
| [badlogic/pi-skills](https://github.com/badlogic/pi-skills) | Agent skill patterns |
| [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) | Developer skill methodology |
| [mattpocock/skills](https://github.com/mattpocock/skills) | TypeScript skill patterns |
| [ComposioHQ/awesome-codex-skills](https://github.com/ComposioHQ/awesome-codex-skills) | Codex skill collection |
| [jiangjiax/counsel](https://github.com/jiangjiax/counsel) | AI counsel / debate methodology |
| [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) | Claude Code resource collection |
| [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | Claude Code tooling collection |

### MCP & Protocols

| Repo | Influence |
|---|---|
| [modelcontextprotocol/registry](https://github.com/modelcontextprotocol/registry) | MCP tool patterns |
| [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers) | MCP server implementations |
| [github/github-mcp-server](https://github.com/github/github-mcp-server) | GitHub MCP integration |
| [anomaloco/opencode](https://github.com/anomaloco/opencode) | The runtime this harness runs on |

### Agent Platforms & Infrastructure

| Repo | Influence |
|---|---|
| [earendil-works/pi](https://github.com/earendil-works/pi) | Agent platform patterns |
| [cline/cline](https://github.com/cline/cline) | Autonomous coding agent |
| [trycua/cua](https://github.com/trycua/cua) | Computer use agent |
| [ruvnet/ruflo](https://github.com/ruvnet/ruflo) | Agent orchestration |
| [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents) | Agency framework |
| [ThePrimeagen/harpoon](https://github.com/ThePrimeagen/harpoon) | Navigation patterns |

### LLMs & Model Providers

| Repo | Influence |
|---|---|
| [deepseek-ai/DeepSeek-V3](https://github.com/deepseek-ai/DeepSeek-V3) | Model architecture |
| [openai/codex](https://github.com/openai/codex) | Coding agent model |
| [QwenLM/Qwen](https://github.com/QwenLM/Qwen) | Open-weight LLM |
| [QwenLM/qwen-code](https://github.com/QwenLM/qwen-code) | Coding-focused Qwen |
| [google-gemini/gemini-cli](https://github.com/google-gemini/gemini-cli) | Gemini CLI patterns |

### UI & Design

| Repo | Influence |
|---|---|
| [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md) | Visual language specification |
| [charmbracelet/crush](https://github.com/charmbracelet/crush) | TUI design patterns |

### Learning & Community

| Repo | Influence |
|---|---|
| [datawhalechina/hello-agents](https://github.com/datawhalechina/hello-agents) | Agent learning resources |
| [jjyaoao/HelloAgents](https://github.com/jjyaoao/HelloAgents) | Agent education |
| [shanraisshan/claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice) | Claude Code best practices |
| [shareAI-lab/learn-claude-code](https://github.com/shareAI-lab/learn-claude-code) | Claude Code learning |
| [microsoft/generative-ai-for-beginners](https://github.com/microsoft/generative-ai-for-beginners) | Gen AI education |
| [karpathy/autoresearch](https://github.com/karpathy/autoresearch) | Autonomous research concepts |
| [karpathy/llm-council](https://github.com/karpathy/llm-council) | Multi-LLM debate patterns |

### Tools Used in This Repository

| Tool | For |
|---|---|
| [tree-sitter/tree-sitter](https://github.com/tree-sitter/tree-sitter) | Repo-map generation |
| [microsoft/playwright](https://github.com/microsoft/playwright) | Browser automation |
| [newren/git-filter-repo](https://github.com/newren/git-filter-repo) | Repository history rewriting |
| [promptfoo/promptfoo](https://github.com/promptfoo/promptfoo) | Prompt testing and evaluation |
| [volcengine/OpenViking](https://github.com/volcengine/OpenViking) | Reference architecture |

If you maintain a project listed here and would prefer different attribution
or removal, please [open an issue](https://github.com/B67687/agentic-workflows/issues).

---

<p align="center">
  <a href="https://github.com/B67687/agentic-workflows/blob/main/LICENSE">MIT License</a>
  ·
  <a href="https://github.com/B67687/agentic-workflows/blob/main/CONTRIBUTING.md">Contributing</a>
</p>
