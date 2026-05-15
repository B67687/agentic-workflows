# Repo Tooling

This file captures the compact tool baseline for repo work on WSL/Linux.

The goal is not to install everything. It is to install the small set of tools that prevents slow searches, fragile JSON parsing, awkward Git inspection, and repeated shell fallbacks.

## Default For This Workspace

**Current (2026-04-30):** Linux-native tools are the primary workflow. Use bash for both read-only inspection and supported workspace automation.

- Read-only: `bash scripts/ws.sh status`, `hotspots`, `validate`, `search -q "text"`
- Mutating: Use the bash scripts directly
- PowerShell is not part of the forward-looking automation contract

## Safe Mutation Rules

For mutating file operations in this workspace:

- Use one shell end to end. Do not enumerate paths in one shell and delete/move them through another.
- Prefer native Linux commands: `rm`, `mv`, `cp`, `mv -i` with explicit paths.
- Before recursive delete or move, resolve the absolute target and confirm it stays inside the intended workspace or explicitly named target directory.
- Treat compound shell commands as unsafe when they are too long or too nested to review quickly. Split into smaller commands with visible boundaries.
- Do not turn shell wrappers, env manipulation, redirects, or path-changing commands into broad allow rules.
- For bulk edits, run read-only discovery first, checkpoint state, then mutate the smallest safe batch.
- For large outputs, write summaries and artifact paths instead of dumping the full output into the conversation.

These rules come from the same lesson as robust agent runtimes: permission and path safety must be explicit data, not vibes inferred from a command string.

## Core Toolset

**Always use the fastest tool:**

| Use This | Not This | Why |
|----------|----------|-----|
| `fd` | `glob` | 10x faster for file finding |
| `rg` | `grep` | Faster + regex support |
| `bash jq` | `read` for JSON | Parses + validates |
| `bash` | MCP for scripts | Only way to run scripts |

## MCP vs Native Tools

**Rule:** Native CLI tools are faster. Use MCP tools only when native tools don't work.

| Task | Use | Don't Use |
|------|-----|-----------|
| Find files | `fd` or `bash find` | `glob` |
| Search text | `rg` | `grep` |
| Read JSON | `bash jq` | `read` |
| Run scripts | `bash` | MCP exec |
| List dir | `bash ls` | `filesystem_list_directory` |

**When MCP is fine:**
- Reading single small files (< 100 lines)
- Simple directory listings
- When native tool not available

**When native is required:**
- Anything involving scripts/execution
- JSON parsing/validation
- Large repo operations
- Complex patterns

Essential:

- `git`: repo history, diffs, branches, status
- `rg`: fast text search
- `fd`: fast file and directory search
- `jq`: JSON parsing
- `gh`: GitHub workflows, PRs, issues, auth-backed operations

Strongly recommended:

- `fzf`: fuzzy selection
- `delta`: readable Git diffs
- `bat`: readable file previews
- `uv`: fast Python package and script runner
- `eza`: modern `ls`
- `sd`: friendlier replacement for many `sed` uses
- `lazygit`: terminal Git UI

Useful depending on repo:

- `pnpm`: Node package manager
- `bun`: JS runtime and package manager

## Windows Install

Scoop is the preferred Windows install path:

```powershell
scoop install git ripgrep fd jq gh fzf bat delta uv bun sd eza lazygit
corepack enable
corepack prepare pnpm@latest --activate
```

Verify:

```powershell
$tools = 'git','rg','fd','jq','gh','fzf','bat','delta','uv','python','node','pnpm','bun','eza','sd','lazygit'
foreach ($t in $tools) {
  $cmd = Get-Command $t -ErrorAction SilentlyContinue
  if ($cmd) { "$t`t$($cmd.Source)" } else { "$t`tMISSING" }
}
```

After Scoop installs or updates:

```powershell
scoop cleanup * --cache
```

## WSL Install

Base packages:

```bash
sudo apt update
sudo apt install -y \
  git \
  ripgrep \
  fd-find \
  jq \
  gh \
  fzf \
  bat \
  git-delta \
  curl \
  wget \
  unzip \
  zip \
  build-essential \
  python3 \
  python3-pip \
  python3-venv \
  nodejs \
  npm
```

Ubuntu/Debian often names `fd` and `bat` as `fdfind` and `batcat`. Add user-local aliases:

```bash
mkdir -p ~/.local/bin
ln -sf "$(command -v fdfind)" ~/.local/bin/fd
ln -sf "$(command -v batcat)" ~/.local/bin/bat
```

Install `uv`:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Prefer Corepack for `pnpm`:

```bash
corepack enable
corepack prepare pnpm@latest --activate
```

If Corepack is unavailable, configure npm to use a user-local global prefix before global installs:

```bash
mkdir -p ~/.npm-global
npm config set prefix "$HOME/.npm-global"
printf '\nexport PATH="$HOME/.npm-global/bin:$PATH"\n' >> ~/.bashrc
export PATH="$HOME/.npm-global/bin:$PATH"
```

Install Bun with its native installer rather than `npm install -g bun`:

```bash
curl -fsSL https://bun.sh/install | bash
```

Verify:

```bash
git --version
rg --version
fd --version
jq --version
gh --version
fzf --version
bat --version
delta --version
uv --version
node --version
npm --version
pnpm --version
bun --version
```

## WSL Notes

Files under `/mnt/c` or `/mnt/m` are Windows-mounted files, not native Linux filesystem files. WSL works there, but heavy filesystem scans can be slower and path behavior can be different.

For this workspace:

```bash
cd "/path/to/your/repo"
bash scripts/ws.sh validate
```

Use the WSL wrapper for read-only inspection:

```bash
bash scripts/ws.sh status
bash scripts/ws.sh hotspots
bash scripts/ws.sh search -q "session-state"
```

For mutating operations in this repo, use the bash scripts directly.

## Local Context Retrieval

Use local retrieval when a session needs fast workspace context without repeating broad discovery:

```bash
bash scripts/ws.sh context-index
bash scripts/ws.sh context-search -q "session-state"
```

The default index is local SQLite FTS under `workflow/retrieval-index/` and covers curated hub docs, scripts, templates, workflow state, topic control files, and topic meta folders. It excludes archives, generated workflow outputs, binaries, dependency trees, build output, and topic content/source trees by default.

Use `-IncludeSource` only when the curated index misses source-level context and the slower scan is worth it. Keep MCP as a wrapper around these commands later, not a second retrieval implementation.

## Tool Selection Framework (Utility Tree)

When choosing between tooling approaches, a flat criteria list hides tradeoffs. Use this **context-weighted utility tree** (adapted from ATAM --- Architecture Tradeoff Analysis Method, SEI/CMU):

```
Root: Solution fitness for this context
├── Functional quality (weight: high always)
│   ├── Correctness: Does it produce accurate results?
│   └── Coverage: Does it handle the range of inputs needed?
├── Operational harmony (weight: context-dependent)
│   ├── Dependencies: What does it require to run? (API keys, services, packages)
│   ├── Resource profile: Memory/CPU at runtime (bash=1, node=2, docker=3+)
│   └── Reliability: Does it work consistently or flake?
├── Long-term viability (weight: high for permanent tools, low for one-offs)
│   ├── Maintainability: Can someone else fix it?
│   ├── Composability: Does it work with existing tools/scripts?
│   └── Evolution path: Can it be upgraded without replacement?
└── Cost of adoption (weight: inverse of urgency)
    ├── Setup time: Minutes to first working result
    ├── Learning curve: How much new knowledge required
    └── Friction: Signups, config, approval gates
```

**How to use it:**
1. Assign weights (1-10) based on the *specific decision context*
2. Score options against each leaf criterion
3. Weighted sum gives the best-fit solution
4. Surface the tradeoff when two high-weight criteria conflict (like correctness vs. no-API-key)

**When to use:** Any tool or implementation decision trading off multiple competing constraints.

**Always consider Brooks' distinction:** Minimize *accidental complexity* (introduced by the solution), accept *essential complexity* (inherent to the problem).

## What Each Tool Replaces

**Always use the faster native tool over MCP:**

- `rg` over slower MCP grep
- `fd` over slower MCP glob
- `jq` over fragile JSON string parsing
- `fzf` over manual long-list selection
- `delta` over raw Git diff output
- `bat` over plain file previews
- `uv` over heavier Python setup
- `sd` over fragile `sed` escaping for common replacements
- `eza` over basic `ls`

**Why:** Native tools are 10-100x faster for large repos.

## Minimal Install

If staying lean, prioritize:

1. `git`
2. `rg`
3. `fd`
4. `jq`
5. `gh`
6. `delta`

Then add `fzf`, `bat`, `uv`, `eza`, `sd`, and `lazygit` as workflow quality upgrades.
