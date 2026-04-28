#!/usr/bin/env bash
# =============================================================================
# check-sync-status.sh - Check if templates are up to date with hub
# =============================================================================
# Compares local templates with the hub version and reports if updates are needed.
#
# Usage:
#   ./check-sync-status.sh            # Check current folder
#   ./check-sync-status.sh /path/to/folder # Check specific folder
# =============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATES_DIR="$REPO_ROOT/propagation"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
log_ok() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Target folder to check (default: current directory)
TARGET="${1:-.}"
cd "$TARGET" 2>/dev/null || TARGET="."

echo "============================================="
echo "Sync Status Check"
echo "============================================="
echo ""
echo "Checking: $(pwd)"
echo ""

MANAGED_MARKER="Managed-By: AI-Prompting-Library"

# Templates to check
templates=(
    "AGENTS.md"
    "topic-insights.md"
    "git-github-best-practices.md"
    "workspace-system-overview.md"
    "quality-standards.md"
    "audit-folder-quality.ps1"
    "check-sync-status.ps1"
    "sync-from-hub.ps1"
    "opencode.json"
    "opencode-agent-system.md"
    ".cleanup-protect"
    "session-state.json"
    "README.md"
)

out_of_sync=0
missing=0
ok=0

for tmpl in "${templates[@]}"; do
    if [[ -f "$tmpl" ]]; then
        # Check if it's a managed file
        if grep -q "$MANAGED_MARKER" "$tmpl" 2>/dev/null; then
            log_ok "$tmpl: managed (up to date)"
            ((ok++))
        else
            log_warn "$tmpl: exists but not managed by hub"
            ((out_of_sync++))
        fi
    else
        log_warn "$tmpl: missing (not propagated)"
        ((missing++))
    fi
done

echo ""
echo "============================================="
echo "Summary"
echo "============================================="
echo ""
echo "Up to date: $ok"
echo "Out of sync: $out_of_sync"
echo "Missing: $missing"
echo ""

if [[ $missing -gt 0 ]] || [[ $out_of_sync -gt 0 ]]; then
    log_warn "Sync needed - run propagate-to-all.sh"
    exit 1
else
    log_ok "All templates are in sync with hub"
    exit 0
fi