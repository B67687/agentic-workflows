#!/usr/bin/env bash
# =============================================================================
# check-sync-status.sh - Check if templates are synced with hub
# =============================================================================
# This is a template. Copy to your topic folder and check periodically.

set -uo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

MANAGED_MARKER="Managed-By: AI-Prompting-Library"

log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
log_ok() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

echo "============================================="
echo "Sync Status Check"
echo "============================================="
echo ""

# Check each managed file
for file in AGENTS.md topic-insights.md git-github-best-practices.md quality-standards.md .cleanup-protect; do
    if [[ -f "$file" ]]; then
        if grep -q "$MANAGED_MARKER" "$file" 2>/dev/null; then
            log_ok "$file: managed"
        else
            log_warn "$file: exists but not managed"
        fi
    else
        log_warn "$file: missing"
    fi
done

echo ""
log_info "Run ./scripts/propagate-to-all.sh --preview from the hub to see what would be synced"