<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://img.shields.io/badge/agentic--workflows-ffffff?style=for-the-badge&logo=github&logoColor=white&labelColor=181717">
    <img alt="agentic-workflows" src="https://img.shields.io/badge/agentic--workflows-000000?style=for-the-badge&logo=github&logoColor=white">
  </picture>
</p>

<p align="center">
  <a href="#quick-start">Quick Start</a>&ensp;·&ensp;
  <a href="#features">Features</a>&ensp;·&ensp;
  <a href="#how-it-works">How It Works</a>&ensp;·&ensp;
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
  <br><br>
  <img src="docs/typing-animation.svg" width="100%" alt="Typing animation" style="max-width:760px;">
</p>

<p align="center">
  <a href="docs/hub-architecture.svg">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="docs/hub-architecture.svg">
      <img src="docs/hub-architecture-light.svg" width="100%" alt="Hub Architecture Diagram" style="max-width:900px;">
    </picture>
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Shell-121011?style=flat-square&logo=gnubash&logoColor=white" alt="Shell">
  <img src="https://img.shields.io/badge/Python-3776AB?style=flat-square&logo=python&logoColor=white" alt="Python">
  <img src="https://img.shields.io/badge/Markdown-000000?style=flat-square&logo=markdown&logoColor=white" alt="Markdown">
  <img src="https://img.shields.io/badge/JavaScript-F7DF1E?style=flat-square&logo=javascript&logoColor=black" alt="JavaScript">
</p>

<p align="center">
  <b>Works with</b>&ensp;
  <img src="https://img.shields.io/badge/Claude_Code-CC5A9C?style=flat-square&logo=anthropic&logoColor=white" alt="Claude Code">
  <img src="https://img.shields.io/badge/Pi-777777?style=flat-square" alt="Pi">
  <img src="https://img.shields.io/badge/Cursor-6C47FF?style=flat-square&logo=cursor&logoColor=white" alt="Cursor">
  <img src="https://img.shields.io/badge/OpenCode-333333?style=flat-square" alt="OpenCode">
  <img src="https://img.shields.io/badge/Codex_CLI-000000?style=flat-square&logo=openai&logoColor=white" alt="Codex CLI">
  <img src="https://img.shields.io/badge/Any_AGENTS.md_AI-555555?style=flat-square" alt="AGENTS.md compatible">
</p>

<h2 id="quick-start">Quick Start</h2>

```bash
git clone https://github.com/B67687/agentic-workflows.git
cd agentic-workflows
```

Open **[`AGENTS.md`](AGENTS.md)** -- that's the operating contract. Every agent reads it first. Then verify everything works:

```bash
bash ./scripts/test-smoke.sh
bash ./scripts/propagate.sh all --apply    # push templates to your repos
```


<h2 id="how-it-works">How It Works</h2>

<h3>Define</h3>
<a href="AGENTS.md"><code>AGENTS.md</code></a> sets the operating contract. Every agent reads it on entry. Skills, commands, and propagation templates inherit from this single source of truth.

<h3>Propagate</h3>
<a href="scripts/propagate.sh"><code>propagate.sh</code></a> pushes templates to topic folders. One change in the hub updates 15+ repos. Commands, scripts, and configs all synced.

<h3>Harvest</h3>
Learnings flow back to the hub via insight harvesting. Cross-project memory loops keep knowledge circulating instead of siloed in individual projects.


<h2 id="features">Features</h2>

<div align="center">

| | |
|---|---|
| **AGENTS.md** | Shared rules and conventions every agent reads on entry |
| **42 engineering skills** | Debug, review, ship, document patterns. Companion scripts for each |
| **Template propagation** | Change once in the hub, sync to 15+ repos automatically |
| **agentmemory MCP** | Captures tool use, compresses observations across sessions |
| **Workflow discipline** | Checkpoints, handoffs, pipelines instead of chaotic chats |
| **6-phase research** | Frame, discover, triangulate, apply, preserve methodology |
| **Quality guardrails** | A2H escalation, assumption expiry, pre-push gates, error counters |
| **Cross-project loop** | Propagate templates, harvest insights across all repos |
| **32-test smoke suite** | Every change verified before commit. TDD patterns included |

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
bash ./scripts/session-status.sh        # Workspace health
bash ./scripts/tools.sh                 # Tool registry
bash ./scripts/search-index.sh "query"  # BM25 search
bash ./scripts/propagate.sh status      # Sync status
bash ./scripts/checkpoint-commit.sh -m "msg"  # Verified commit
```

See [docs/workflow.md](docs/workflow.md) for the full system, [docs/hub-quickstart.md](docs/hub-quickstart.md) to set up your own project, or open [session-state.json](session-state.json) to resume interrupted work.


<h2 id="ecosystem">Ecosystem</h2>

<p>This harness was built by studying and integrating patterns from <b>50+ open-source projects</b> across the agent ecosystem. Projects with <code>*</code> have patterns extracted into skills, scripts, or documentation.</p>

<h3>Core Inspirations</h3>

<div align="center">

<table>
<tr>
  <td width="33%" valign="top">
    <img src="https://img.shields.io/badge/Agent%20Frameworks-12-58a6ff?style=flat-square" alt="Agent Frameworks"><br>
    AutoGen · <a href="https://github.com/google/adk-python"><b>*Google ADK</b></a> · Claude Agent SDK · OpenAI Agents SDK · Pydantic AI · AutoGPT · MetaGPT · A2A Protocol · Hermes Agent · AgentScope · Open-SWE · <a href="https://github.com/crewAIInc/crewAI"><b>*crewAI</b></a>
  </td>
  <td width="33%" valign="top">
    <img src="https://img.shields.io/badge/Developer%20Tools-9-0ea5e9?style=flat-square" alt="Dev Tools"><br>
    <a href="https://code.claude.com/docs/en/best-practices"><b>*Claude Code</b></a> · <a href="https://github.com/Aider-AI/aider"><b>*Aider</b></a> · <a href="https://github.com/humanlayer/humanlayer"><b>*HumanLayer</b></a> · <a href="https://github.com/garrytan/gstack"><b>*GStack</b></a> · UI-TARS · Deer Flow · <a href="https://github.com/browser-use/browser-use"><b>*browser-use</b></a> · <a href="https://github.com/anomalyco/opencode"><b>*OpenCode</b></a> · Pi
  </td>
  <td width="33%" valign="top">
    <img src="https://img.shields.io/badge/Skills%20%26%20Quality-5-3fb950?style=flat-square" alt="Skills"><br>
    <a href="https://github.com/addyosmani/agent-skills"><b>*Agent-Skills</b></a> · <a href="https://github.com/humanlayer/12-factor-agents"><b>*12-Factor Agents</b></a> · System Design Primer · <a href="https://github.com/tree-sitter/tree-sitter"><b>*tree-sitter</b></a> · promptfoo
  </td>
</tr>
</table>

</div>

<h3>Full Ecosystem</h3>

<details open>
<summary>50+ projects across 8 more categories</summary>

<div align="center">

| Category | Projects |
|----------|----------|
| <img src="https://img.shields.io/badge/Memory%20%26%20RAG-8-e1306c?style=flat-square" alt="Memory"> | Mem0, LMCache, MemPalace, MemOS, PageIndex,<br><a href="https://github.com/zilliztech/claude-context"><b>*agentmemory</b></a>, GraphRAG, RAG-Anything |
| <img src="https://img.shields.io/badge/Workflow%20Platforms-6-58a6ff?style=flat-square" alt="Workflow"> | n8n, Flowise, Langflow, Dify, Manifest, Infisical |
| <img src="https://img.shields.io/badge/Prompt%20Libraries-7-0ea5e9?style=flat-square" alt="Prompts"> | Pi-Skills, <a href="https://github.com/karpathy/autoresearch"><b>*Karpathy-Skills</b></a>, Codex Skills, <b>*Counsel</b>,<br>Everything Claude Code, Awesome Claude Code, awesome-codex-skills |
| <img src="https://img.shields.io/badge/MCP%20%26%20Protocols-3-3fb950?style=flat-square" alt="MCP"> | MCP Registry, MCP Servers, GitHub MCP Server |
| <img src="https://img.shields.io/badge/Agent%20Platforms-6-e1306c?style=flat-square" alt="Platforms"> | Cline, CUA, <b>*Rufo (ruflo)</b>, Agency-Agents,<br>Codex CLI, generative-ai-for-beginners |
| <img src="https://img.shields.io/badge/README%20Design-4-58a6ff?style=flat-square" alt="Readme Design"> | readme-svg-wave-divider-generator, readme-hub,<br>GitHub Readme Stats, <a href="https://github.com/VoltAgent/awesome-design-md"><b>*awesome-design-md</b></a> |
| <img src="https://img.shields.io/badge/LLMs%20%26%20Learning-6-0ea5e9?style=flat-square" alt="LLMs"> | DeepSeek-V3, OpenAI Codex, Qwen, Gemini CLI,<br>Hello Agents, Claude Code Best Practice |

</div>

</details>

<h3>Tools Used</h3>

<details open>
<summary>Software that helped build this project</summary>

<div align="center">

| Tool | Use |
|------|-----|
| [tree-sitter](https://github.com/tree-sitter/tree-sitter) | Repo-map generation |
| [*Playwright](https://github.com/microsoft/playwright) | Browser automation (POM) |
| [RTK](https://github.com/ericseppanen/rtk) | File counting & analysis |
| [git-filter-repo](https://github.com/newren/git-filter-repo) | Git history management |
| [promptfoo](https://github.com/promptfoo/promptfoo) | Prompt evaluation |

</div>

</details>

<br>
<p align="center"><sub>Ready to start? Read <a href="#quick-start">Quick Start</a> or open <a href="AGENTS.md">AGENTS.md</a> to begin.</sub></p>

<p align="center"><sub>&ensp;&middot;&ensp;&middot;&ensp;&middot;&ensp;</sub></p>
<p align="center"><sub>If you maintain a project listed here and would prefer different attribution or removal, please <a href="https://github.com/B67687/agentic-workflows/issues">open an issue</a>.</sub></p>

<p align="center">
  <sub>
    <a href="https://github.com/B67687/agentic-workflows/blob/main/LICENSE">MIT License</a>
    ·
    <a href="https://github.com/B67687/agentic-workflows/issues">Issues</a>
  </sub>
  <br>
  <sub>Built with &hearts; from the open-source agent community.</sub>
</p>
