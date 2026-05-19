<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://img.shields.io/badge/agentic--workflows-ffffff?style=for-the-badge&logo=github&logoColor=white&labelColor=181717">
    <img alt="agentic-workflows" src="https://img.shields.io/badge/agentic--workflows-000000?style=for-the-badge&logo=github&logoColor=white">
  </picture>
</p>

  An agent harness for orchestrating, managing, and extending AI agents across 18 repos. Not a code project — a systems engineering workspace for agent workflows, cross-repo orchestration, and capability propagation.
</p>

# agentic-workflows

<p align="center">
  <a href="#quick-start">Quick Start</a>&ensp;·&ensp;
  <a href="#workflow-tree">Workflow Tree</a>&ensp;·&ensp;
  <a href="#features">Features</a>&ensp;·&ensp;
  <a href="#orientation">Orientation</a>&ensp;·&ensp;
  <a href="#ecosystem">Ecosystem</a>
</p>

<p align="center">
  <a href="https://github.com/B67687/agentic-workflows/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="MIT"></a>
  <a href="https://github.com/B67687/agentic-workflows"><img src="https://img.shields.io/github/last-commit/B67687/agentic-workflows?style=flat-square&label=Updated" alt="Last Commit"></a>
  <a href="https://github.com/B67687/agentic-workflows"><img src="https://img.shields.io/github/repo-size/B67687/agentic-workflows?style=flat-square" alt="Size"></a>
  <a href="https://github.com/B67687/agentic-workflows"><img src="https://img.shields.io/github/stars/B67687/agentic-workflows?style=flat-square" alt="Stars"></a>
  <a href="https://github.com/B67687/agentic-workflows/issues"><img src="https://img.shields.io/github/issues/B67687/agentic-workflows?style=flat-square" alt="Issues"></a>
  <a href="https://github.com/B67687/agentic-workflows/pulls"><img src="https://img.shields.io/github/issues-pr/B67687/agentic-workflows?style=flat-square" alt="PRs"></a>
  <a href="https://github.com/B67687/agentic-workflows/graphs/commit-activity"><img src="https://img.shields.io/github/commit-activity/m/B67687/agentic-workflows?style=flat-square" alt="Commits per month"></a>
  <a href="https://github.com/B67687/agentic-workflows/commits/main"><img src="https://img.shields.io/github/commit-activity/t/B67687/agentic-workflows?style=flat-square&label=total%20commits" alt="Total Commits"></a>
  <br>
  <img src="https://img.shields.io/badge/Workflow%20Defs-10-%23238636?style=flat-square" alt="10 Workflow Definitions">
  <img src="https://img.shields.io/badge/Deterministic%20Steps-5-%239e6a03?style=flat-square" alt="5 Deterministic Steps">
  <img src="https://img.shields.io/badge/Propagation-90%20targets%20per%20folder-%239e6a03?style=flat-square" alt="Propagation">
  <img src="https://img.shields.io/badge/Scripts-152%20reorganized-%233d444d?style=flat-square" alt="Scripts">
  <img src="https://img.shields.io/badge/Skills-46-%231f6feb?style=flat-square" alt="Skills">
  <img src="https://img.shields.io/badge/Tests-112-%23238636?style=flat-square" alt="Tests">
</p>

<p align="center">
  <b>Works with</b>&ensp;
  <img src="https://img.shields.io/badge/Claude_Code-CC5A9C?style=flat-square&logo=anthropic&logoColor=white" alt="Claude Code">
  <img src="https://img.shields.io/badge/Pi-777777?style=flat-square" alt="Pi">
  <img src="https://img.shields.io/badge/OpenCode-333333?style=flat-square" alt="OpenCode">
  <img src="https://img.shields.io/badge/Cursor-6C47FF?style=flat-square&logo=cursor&logoColor=white" alt="Cursor">
  <img src="https://img.shields.io/badge/Codex_CLI-000000?style=flat-square&logo=openai&logoColor=white" alt="Codex CLI">
  <img src="https://img.shields.io/badge/Any_AGENTS.md_AI-555555?style=flat-square" alt="AGENTS.md compatible">
</p>

<h2 id="quick-start">Quick Start</h2>

```bash
git clone https://github.com/B67687/agentic-workflows.git
cd agentic-workflows
```

Open **[`AGENTS.md`](AGENTS.md)** — that's the operating contract (190 lines, 11 sections). The agent reads it first, then routes through the [workflow tree](#workflow-tree).

```bash
bash scripts/infra/test-smoke.sh          # 112-test suite
bash scripts/infra/propagate-to-all.sh --apply  # Push templates to 17 sibling repos
```

<h2 id="workflow-tree">Workflow Tree</h2>

The harness runs on **workflow-driven execution** — state machines in `workflow.d/` that classify requests and route through deterministic or deliberative steps. Inspired by HumanLayer's session state machine architecture.

```
User request
  → root.yaml classify (deliberative)
    → research → design → implement → verify (auto-cycle via next:)
    → debug (bug diagnosis)
    → review (code review)
    → docs (documentation)
    → refactor (restructure)
    → propagate (sync templates to repos)
```

Each workflow is a YAML state machine with ordered steps. Deterministic steps run scripts automatically. Deliberative steps reason with the user and go back and forth until consensus. State persists in `workflow-state.json` — populated automatically as the agent advances.

| Workflow | Steps | Description |
|----------|-------|-------------|
| `root.yaml` | classify | Entry point — classifies requests and branches |
| `research.yaml` | 3 | Formulate questions → gather facts (deterministic) → review |
| `design.yaml` | 3 | Map state → design discussion → structure outline |
| `implement.yaml` | 3 | Slice scope → execute slices → final verify (deterministic) |
| `verify.yaml` | 2 | Review diff (deterministic) → assess quality |
| `debug.yaml` | 3 | Reproduce → diagnose (deterministic) → propose fix |
| `propagate.yaml` | 5 | Select targets → preview → review → apply → verify |
| `review.yaml` | 2 | Collect diff (deterministic) → assess quality |
| `docs.yaml` | 2 | Research existing → write and iterate |
| `refactor.yaml` | 4 | Map current → design target → execute → verify |

See [`workflow.d/SCHEMA.md`](workflow.d/SCHEMA.md) for the full YAML schema.

<h2 id="features">Features</h2>

<div align="center">

<table>
<tr>
  <td width="33%" valign="top"><b>🧠 Workflow-Driven Execution</b><br><sub>State machines in workflow.d/ route every request. Deterministic steps auto-run, deliberative steps align with you.</sub></td>
  <td width="33%" valign="top"><b>📚 Skill System</b><br><sub>Debug, review, ship, document — 46 engineering skills with progressive loading (L1/L2/L3)</sub></td>
  <td width="33%" valign="top"><b>🔄 Knowledge Propagation</b><br><sub>Change once in the hub, sync templates to 17 repos automatically via propagation contract</sub></td>
</tr>
<tr>
  <td width="33%" valign="top"><b>💾 Auto-Generated State</b><br><sub>workflow-state.json populates as side effect of advancing steps. No manual session management needed.</sub></td>
  <td width="33%" valign="top"><b>⚡ Deterministic + Deliberative Split</b><br><sub>Scripts for deterministic operations (search, read, verify). AI + human for deliberative decisions.</sub></td>
  <td width="33%" valign="top"><b>🔬 Research Engine</b><br><sub>Frame → discover → triangulate → apply → preserve — 6-phase methodology</sub></td>
</tr>
<tr>
  <td width="33%" valign="top"><b>🛡️ Human-Inspired Architecture</b><br><sub>Patterns from HumanLayer's daemon/session model — session-scoped runtime, tree-based workflow state</sub></td>
  <td width="33%" valign="top"><b>🌐 Multi-Repo Orchestration</b><br><sub>17 topic folders, each with workflow.d/ + workflow-state.json via propagation</sub></td>
  <td width="33%" valign="top"><b>🧪 112-Test Smoke Suite</b><br><sub>Every change verified before commit. Covers tools, hooks, gates, pipelines, MCP.</sub></td>
</tr>
<tr>
  <td width="33%" valign="top"><b>🔁 Auto Cycle</b><br><sub>research → design → implement → verify flows automatically. Agent proposes next; you authorize.</sub></td>
  <td width="33%" valign="top"><b>📊 Session Observability</b><br><sub>Dashboard aggregates workflow state, trace history, and current context live</sub></td>
  <td width="33%" valign="top"><b>🧰 Organized Scripts</b><br><sub>152 scripts reorganized into tools/ (48), infra/ (27), archive/ (18). Symlinks at old paths.</sub></td>
</tr>
</table>

</div>

<h2 id="orientation">Orientation</h2>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/folder-structure.svg">
    <img src="docs/folder-structure-light.svg" width="100%" alt="Folder structure" style="max-width:720px;">
  </picture>
</p>

<h3 id="commands">Common Commands</h3>

```bash
bash scripts/infra/test-smoke.sh            # 112-test suite
bash scripts/tools/session-status.sh        # Workspace health
bash scripts/tools/tools.sh                 # Tool registry
bash scripts/tools/search-index.sh "query"  # BM25 search
bash scripts/tools/session-dashboard.sh     # Live observability dashboard
bash scripts/infra/checkpoint-commit.sh -m "msg"  # Verified commit
bash scripts/infra/propagate-to-all.sh --preview  # Preview template sync
```

See [`docs/workflow.md`](docs/workflow.md) for the reference, [`workflow.d/SCHEMA.md`](workflow.d/SCHEMA.md) for the schema, or open [`workflow-state.json`](workflow-state.json) to check active workflow.

<h2 id="ecosystem">Ecosystem</h2>

This harness was built by studying and integrating patterns from **80+ open-source projects** across the agent ecosystem. Projects with `*` have patterns extracted into skills, scripts, or documentation.

<h3>Core Inspirations</h3>

<div align="center">

<table>
<tr>
  <td width="33%" valign="top">
    <img src="https://img.shields.io/badge/Agent%20Frameworks-12-58a6ff?style=flat-square" alt="Agent Frameworks"><br>
    AutoGen · <a href="https://github.com/google/adk-python"><b>*Google ADK</b></a> · Claude Agent SDK · <a href="https://platform.openai.com/docs/guides/agents"><b>*OpenAI Agents SDK</b></a> · <a href="https://github.com/pydantic/pydantic-ai"><b>*Pydantic AI</b></a> · AutoGPT · MetaGPT · <a href="https://github.com/a2aproject/A2A"><b>*A2A Protocol</b></a> · <a href="https://github.com/NousResearch/hermes-agent"><b>*Hermes Agent</b></a> · AgentScope · Open-SWE · <a href="https://github.com/crewAIInc/crewAI"><b>*crewAI</b></a>
  </td>
  <td width="33%" valign="top">
    <img src="https://img.shields.io/badge/Developer%20Tools-13-0ea5e9?style=flat-square" alt="Dev Tools"><br>
    <a href="https://code.claude.com/docs/en/best-practices"><b>*Claude Code</b></a> · <a href="https://github.com/Aider-AI/aider"><b>*Aider</b></a> · <a href="https://github.com/humanlayer/humanlayer"><b>*HumanLayer</b></a> · <a href="https://github.com/garrytan/gstack"><b>*GStack</b></a> · <a href="https://github.com/anthropics/claude-plugins-official"><b>*Claude Plugins</b></a> · UI-TARS · Deer Flow · <a href="https://github.com/browser-use/browser-use"><b>*browser-use</b></a> · <a href="https://github.com/anomalyco/opencode"><b>*OpenCode</b></a> · Pi · <a href="https://github.com/SWE-agent/SWE-agent"><b>*SWE-agent</b></a> · <a href="https://github.com/Hmbown/DeepSeek-TUI"><b>*DeepSeek-TUI</b></a> · <a href="https://github.com/decolua/9router"><b>*9Router</b></a>
  </td>
  <td width="33%" valign="top">
    <img src="https://img.shields.io/badge/Skills%20%26%20Quality-6-3fb950?style=flat-square" alt="Skills"><br>
    <a href="https://github.com/addyosmani/agent-skills"><b>*Agent-Skills</b></a> · <a href="https://github.com/humanlayer/12-factor-agents"><b>*12-Factor Agents</b></a> · <a href="https://github.com/github/spec-kit"><b>*Spec Kit</b></a> · System Design Primer · <a href="https://github.com/tree-sitter/tree-sitter"><b>*tree-sitter</b></a> · <a href="https://github.com/promptfoo/promptfoo"><b>*promptfoo</b></a>
  </td>
</tr>
</table>

</div>

<details>
<summary>60+ projects across 9 more categories</summary>

<div align="center">

| Category | Projects |
|----------|----------|
| <img src="https://img.shields.io/badge/Memory%20%26%20RAG-8-e1306c?style=flat-square" alt="Memory"> | <a href="https://github.com/mem0ai/mem0"><b>*Mem0</b></a>, LMCache, MemPalace, MemOS, PageIndex,<br><a href="https://github.com/zilliztech/claude-context"><b>*agentmemory</b></a>, <a href="https://github.com/microsoft/graphrag"><b>*GraphRAG</b></a>, RAG-Anything |
| <img src="https://img.shields.io/badge/Workflow%20Platforms-6-58a6ff?style=flat-square" alt="Workflow"> | <a href="https://github.com/n8n-io/n8n"><b>*n8n</b></a>, Flowise, Langflow, Dify, Manifest, Infisical |
| <img src="https://img.shields.io/badge/Prompt%20Libraries-7-0ea5e9?style=flat-square" alt="Prompts"> | Pi-Skills, <a href="https://github.com/karpathy/autoresearch"><b>*Karpathy-Skills</b></a>, Codex Skills, <a href="https://github.com/jiangjiax/counsel"><b>*Counsel</b></a>,<br>Everything Claude Code, Awesome Claude Code, awesome-codex-skills |
| <img src="https://img.shields.io/badge/MCP%20%26%20Protocols-5-3fb950?style=flat-square" alt="MCP"> | MCP Registry, MCP Servers, GitHub MCP Server,<br>**sequential-thinking** (structured reasoning), **@opencode-ai/plugin** |
| <img src="https://img.shields.io/badge/Agent%20Platforms-6-e1306c?style=flat-square" alt="Platforms"> | Cline, CUA, <a href="https://github.com/ruvnet/ruflo"><b>*Rufo (ruflo)</b></a>, Agency-Agents,<br>Codex CLI, generative-ai-for-beginners |
| <img src="https://img.shields.io/badge/README%20Design-4-58a6ff?style=flat-square" alt="Readme Design"> | readme-svg-wave-divider-generator, readme-hub,<br>GitHub Readme Stats, <a href="https://github.com/VoltAgent/awesome-design-md"><b>*awesome-design-md</b></a> |
| <img src="https://img.shields.io/badge/LLMs%20%26%20Learning-6-0ea5e9?style=flat-square" alt="LLMs"> | DeepSeek-V3, OpenAI Codex, Qwen, Gemini CLI,<br>Hello Agents, Claude Code Best Practice |

</div>

</details>

<br>
<p align="center"><sub>Ready to start? Read <a href="#quick-start">Quick Start</a> or open <a href="AGENTS.md">AGENTS.md</a> to begin.</sub></p>

<p align="center"><sub>&ensp;&middot;&ensp;&middot;&ensp;&middot;&ensp;</sub></p>

<p align="center">
  <sub>
    <a href="https://github.com/B67687/agentic-workflows/blob/main/LICENSE">MIT License</a>
    ·
    <a href="https://github.com/B67687/agentic-workflows/issues">Issues</a>
  </sub>
  <br>
  <sub>Built with &hearts; from the open-source agent community.</sub>
</p>
