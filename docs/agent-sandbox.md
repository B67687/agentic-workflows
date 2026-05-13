# Agent Sandbox

Safe YOLO-mode execution for agent operations.

## Problem

Agents running arbitrary commands (YOLO mode) risk:
- **Data loss** --- bad `rm`, `mv`, or `dd` commands
- **Exfiltration** --- prompt injection steals files via network
- **System corruption** --- agent modifies system configuration

## Solution: Sandboxed Agent

Two tiers of sandbox available:

### Tier 1: Bubblewrap (works now, no Docker)

Uses Linux namespace isolation via `bubblewrap`. Best for quick isolation.

```bash
# Run a command in the sandbox
bash ./scripts/agent-sandbox.sh bwrap "python3 scripts/search-index.sh 'query'"

# Interactive shell in sandbox
bash ./scripts/agent-sandbox.sh bwrap

# Run the agent in sandbox (wraps OpenCode)
bash ./scripts/agent-sandbox.sh bwrap "opencode"
```

**What it does:**
- Isolates network (no egress at all)
- Read-only system libraries
- Writable only in the workspace directory
- Process isolation (separate PID namespace)

### Tier 2: Docker (stronger, requires Docker)

Uses Docker with iptables network filtering. Network allowlist prevents exfiltration.

```bash
# One-time setup: install Docker for WSL2
# https://docs.docker.com/engine/install/ubuntu/

# Run a command
bash ./scripts/agent-sandbox.sh docker "python3 scripts/search-index.sh 'query'"
```

**What it adds over bwrap:**
- Full network allowlist (PyPI, npm, GitHub + API endpoints only)
- Dedicated non-root user inside container
- Controlled capability set (NET_ADMIN for firewall only)

## Firewall Configuration

The `.devcontainer/init-firewall.sh` script controls network access:

```bash
# Default: allowlist mode (PyPI, npm, GitHub + API hosts)
./init-firewall.sh

# Full network (debugging)
ALLOW_ALL=1 ./init-firewall.sh

# No network (data processing, no API calls needed)
BLOCK_ALL=1 ./init-firewall.sh
```

The firewall automatically detects API endpoints from `opencode.jsonc`.

## When to Sandbox

| Task Type | Sandbox | Why |
|-----------|---------|-----|
| Code research / proofs-of-concept | Yes | Low risk, high iteration speed |
| Dependency upgrades | Yes | Package installs from untrusted sources |
| Data analysis with unknown files | Yes | Files may contain prompt injections |
| Editing own workspace files | No sandbox | Need full write access |
| API/script development | Tier 2 | Need network + isolation |
