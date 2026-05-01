#!/usr/bin/env bash
# =============================================================================
# check-sync-status.sh - Check propagation status by ownership class
# =============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/propagation-contract.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_ok() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_drift() { echo -e "${RED}[DRIFT]${NC} $1"; }

TARGET="${1:-.}"
cd "$TARGET" 2>/dev/null || TARGET="."
TARGET_DIR="$(pwd)"

echo "============================================="
echo "Sync Status Check"
echo "============================================="
echo ""
echo "Checking: $TARGET_DIR"
echo ""

managed_clean=0
managed_drift=0
managed_missing=0
repo_owned_present=0
repo_owned_missing=0

check_entry() {
  local entry="$1"
  local owner template_path target_rel target_path

  owner="$(propagation_entry_owner "$entry")"
  template_path="$(propagation_template_path "$entry")"
  target_rel="$(propagation_entry_target "$entry")"
  target_path="$TARGET_DIR/$target_rel"

  if [[ ! -f "$target_path" ]]; then
    if [[ "$owner" == "managed" ]]; then
      log_warn "$target_rel: missing managed-core file"
      ((managed_missing++))
    else
      log_warn "$target_rel: missing repo-owned bootstrap file"
      ((repo_owned_missing++))
    fi
    return
  fi

  if [[ "$owner" == "repo-owned" ]]; then
    log_ok "$target_rel: present (repo-owned)"
    ((repo_owned_present++))
    return
  fi

  if cmp -s "$template_path" "$target_path"; then
    log_ok "$target_rel: clean (managed core)"
    ((managed_clean++))
  else
    log_drift "$target_rel: drifted from managed core"
    ((managed_drift++))
  fi
}

while IFS= read -r entry; do
  [[ -n "$entry" ]] || continue
  check_entry "$entry"
done < <(propagation_iter_entries all)

echo ""
echo "============================================="
echo "Summary"
echo "============================================="
echo ""
echo "Managed clean: $managed_clean"
echo "Managed drifted: $managed_drift"
echo "Managed missing: $managed_missing"
echo "Repo-owned present: $repo_owned_present"
echo "Repo-owned missing: $repo_owned_missing"
echo ""

if [[ $managed_drift -gt 0 || $managed_missing -gt 0 || $repo_owned_missing -gt 0 ]]; then
  log_warn "Action needed - use sync-from-hub.sh for managed refresh or propagate-to-all.sh for bootstrap."
  exit 1
fi

log_ok "Managed core is aligned and repo-owned bootstrap files are present."
