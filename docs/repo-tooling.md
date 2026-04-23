# Repo Tooling

This file captures the compact tool baseline for repo work on Windows PowerShell and WSL/Linux.

The goal is not to install everything. It is to install the small set of tools that prevents slow searches, fragile JSON parsing, awkward Git inspection, and repeated shell fallbacks.

## Default For This Workspace

Use PowerShell for mutating `AI Prompting` hub automation because the existing write workflows are PowerShell-first.

Use WSL when a task benefits from Linux tooling. In WSL, prefer native Linux commands and `scripts/ws.sh`; do not install PowerShell inside WSL just to run this repo unless you specifically want that compatibility.

## Core Toolset

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
cd "/mnt/m/M-Namikaz-Others/AI Prompting"
bash scripts/ws.sh validate
```

Use the WSL wrapper for read-only inspection:

```bash
bash scripts/ws.sh status
bash scripts/ws.sh hotspots
bash scripts/ws.sh search -q "session-state"
```

Use PowerShell for propagation or other mutating workspace automation.

## What Each Tool Replaces

- `rg` over slower recursive text search
- `fd` over slower recursive file discovery
- `jq` over fragile JSON string parsing
- `fzf` over manual long-list selection
- `delta` over raw Git diff output
- `bat` over plain file previews
- `uv` over heavier Python setup
- `sd` over fragile `sed` escaping for common replacements
- `eza` over basic `ls`

## Minimal Install

If staying lean, prioritize:

1. `git`
2. `rg`
3. `fd`
4. `jq`
5. `gh`
6. `delta`

Then add `fzf`, `bat`, `uv`, `eza`, `sd`, and `lazygit` as workflow quality upgrades.
