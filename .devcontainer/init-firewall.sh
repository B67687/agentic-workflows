#!/bin/bash
# =============================================================================
# init-firewall.sh — Sandbox network filtering
# Sets up iptables rules to allow egress only to trusted hosts.
# Blocks exfiltration by prompt injection attacks.
#
# Usage:
#   ./init-firewall.sh                    # default: strict allowlist
#   ALLOW_ALL=1 ./init-firewall.sh        # unrestricted (debugging)
#   BLOCK_ALL=1 ./init-firewall.sh        # no network at all
#
# Allowlist (by default): PyPI, npm, GitHub, and OpenCode API endpoints.
# =============================================================================
set -euo pipefail

if [ "${BLOCK_ALL:-0}" = "1" ]; then
    echo "[firewall] Blocking all egress..."
    iptables -A OUTPUT -j DROP 2>/dev/null || true
    echo "[firewall] All network disabled."
    exec "$@"
    exit 0
fi

if [ "${ALLOW_ALL:-0}" = "1" ]; then
    echo "[firewall] Allow all mode — unrestricted egress."
    exec "$@"
    exit 0
fi

echo "[firewall] Setting up allowlist egress rules..."

# Default: drop all outgoing
iptables -P OUTPUT DROP 2>/dev/null || true

# Allow established connections
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || true

# Allow loopback
iptables -A OUTPUT -o lo -j ACCEPT 2>/dev/null || true

# Allow DNS (needed for hostname resolution)
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT 2>/dev/null || true

# Package registries (needed for pip install, npm install)
for host in pypi.org files.pythonhosted.org pythonhosted.org \
            registry.npmjs.org npmjs.org npmjs.com \
            github.com; do
    iptables -A OUTPUT -d "$host" -j ACCEPT 2>/dev/null || true
done

# OpenCode API endpoints — detect from config if available
OPENCODE_CONFIG="${HOME}/.config/opencode/opencode.jsonc"
if [ -f "$OPENCODE_CONFIG" ]; then
    # Extract API domains from provider configurations
    python3 -c "
import json, re
with open('$OPENCODE_CONFIG') as f:
    text = f.read()
# Strip comments for json parsing
text = re.sub(r'//.*', '', text)
text = re.sub(r'/\*.*?\*/', '', text, flags=re.DOTALL)
config = json.loads(text)
for name, provider in config.get('provider', {}).items():
    base = provider.get('options', {}).get('baseURL', '')
    if base:
        from urllib.parse import urlparse
        domain = urlparse(base).hostname
        if domain:
            print(domain)
" 2>/dev/null | sort -u | while read -r domain; do
    echo "[firewall] Allowing API: $domain"
    iptables -A OUTPUT -d "$domain" -j ACCEPT 2>/dev/null || true
done
fi

echo "[firewall] Allowlist active. Blocking all other egress."
echo "[firewall] To override: ALLOW_ALL=1 or BLOCK_ALL=1"

exec "$@"
