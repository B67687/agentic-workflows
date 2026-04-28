#!/usr/bin/env bash
# =============================================================================
# sync-from-hub.sh - Pull latest templates from AI Prompting hub
# =============================================================================
# Run this from any topic folder to sync with the hub.
# This is a template - copy to your folder and run.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_DIR="$(pwd)"

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
echo "Sync From Hub"
echo "============================================="
echo ""

# Find hub - look in parent directories
HUB_DIR=""
for d in "$CURRENT_DIR"/.. "$CURRENT_DIR"/../.. "$CURRENT_DIR"/../../..; do
    if [[ -d "$d/AI Prompting" ]] && [[ -f "$d/AI Prompting/propagation/AGENTS.template.md" ]]; then
        HUB_DIR="$d/AI Prompting"
        break
    fi
done

if [[ -z "$HUB_DIR" ]]; then
    log_warn "Could not find AI Prompting hub"
    exit 1
fi

log_ok "Found hub: $HUB_DIR"

TEMPLATES_DIR="$HUB_DIR/propagation"

# Files to sync
declare -a FILES=(
    "AGENTS.template.md:AGENTS.md"
    "topic-insights.template.md:topic-insights.md"
    "git-github-best-practices.template.md:git-github-best-practices.md"
    "audit-folder-quality.template.sh:audit-folder-quality.sh"
    "check-sync-status.template.sh:check-sync-status.sh"
    "sync-from-hub.template.sh:sync-from-hub.sh"
)

echo ""
for pair in "${FILES[@]}"; do
    template="${pair%%:*}"
    target="${pair##*:}"
    template_path="$TEMPLATES_DIR/$template"
    target_path="$CURRENT_DIR/$target"
    
    if [[ ! -f "$template_path" ]]; then
        log_warn "Template missing: $template"
        continue
    fi
    
    if [[ -f "$target_path" ]]; then
        # Check if managed
        if grep -q "$MANAGED_MARKER" "$target_path" 2>/dev/null; then
            cp "$template_path" "$target_path"
            log_ok "Updated: $target"
        else
            log_warn "Skipped (not managed): $target"
        fi
    else
        cp "$template_path" "$target_path"
        chmod +x "$target_path"
        log_ok "Created: $target"
    fi
done

echo ""
log_ok "Sync complete"