#!/usr/bin/env bash
# =============================================================================
# assumption-expiry.sh — Check and manage assumption staleness
#
# Implements the Assumption Expiry pattern (docs/assumption-expiry.md):
# every non-verifiable claim in the workspace gets a TTL. Downstream ops
# check before assuming it still holds.
#
# Authority:
#   - Martin Fowler, Technical Debt Quadrant (2009): prudent-inadvertent debt
#   - Manny Lehman, Laws of Software Evolution (1985): complexity increases
#   - Bertrand Meyer, Design by Contract (1988): preconditions must hold
#
# Usage:
#   bash ./scripts/assumption-expiry.sh check      # Check all assumptions
#   bash ./scripts/assumption-expiry.sh list       # List all with status
#   bash ./scripts/assumption-expiry.sh mark <id>  # Mark as reviewed, reset TTL
#   bash ./scripts/assumption-expiry.sh dismiss <id> # Dismiss as no longer relevant
#   bash ./scripts/assumption-expiry.sh init       # First-time: migrate residualRisk to assumptions
#
# Exit codes:
#   0 — all assumptions current (none overdue)
#   1 — at least one assumption overdue or expiring soon
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STATE_FILE="$REPO_ROOT/session-state.json"
NOW_TS=$(date -u +%s)
NOW_ISO=$(date -u +%Y-%m-%dT00:00:00Z)
MODE="${1:-check}"

# Default TTLs in days (from docs/assumption-expiry.md)
TTL_P2=60   # contextual: residualRisk, immediateNextSteps
TTL_P1=90   # stable: workspace structure, propagation contracts

case "$MODE" in
  check|list)
    python3 -c "
import json, sys, os
from datetime import datetime, timezone

now = datetime.now(timezone.utc)
state_file = '$STATE_FILE'

try:
    with open(state_file) as f:
        data = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    print('ASSESSMENT=error')
    print('MESSAGE=Cannot read session-state.json')
    sys.exit(1)

assumptions = data.get('assumptions', [])
residual_raw = data.get('residualRisk', '')

# Build assumption list: if no assumptions array yet, infer from residualRisk
if not assumptions and residual_raw:
    # Infer a single assumption from residualRisk string
    created = data.get('lastRetrospect', now.isoformat())
    try:
        created_dt = datetime.fromisoformat(created.replace('Z', '+00:00'))
    except:
        created_dt = now
    age_days = (now - created_dt).days
    default_ttl = ${TTL_P2}
    expires = created_dt.isoformat().replace('+00:00', 'Z') if age_days < default_ttl else 'EXPIRED'
    assumptions = [{
        'id': 'residualRisk-inferred',
        'claim': residual_raw[:200],
        'created': created,
        'expiresAt': expires,
        'status': 'overdue' if age_days >= default_ttl else 'active'
    }]

overdue = []
expiring_soon = []
active = []

for a in assumptions:
    aid = a.get('id', 'unknown')
    claim = a.get('claim', '')[:120]
    status = a.get('status', 'active')
    expires_raw = a.get('expiresAt', None)

    # Determine effective expiry
    if expires_raw and expires_raw != 'EXPIRED':
        try:
            expires_dt = datetime.fromisoformat(expires_raw.replace('Z', '+00:00'))
        except:
            expires_dt = now
        days_left = (expires_dt - now).days
    else:
        days_left = -1  # already expired or no expiry set

    if status == 'dismissed':
        continue  # skip dismissed entries

    if days_left <= 0:
        overdue.append(a)
    elif days_left <= 14:
        expiring_soon.append(a)
    else:
        active.append(a)

# Output
is_list = '${MODE}' == 'list'

if is_list:
    print('')
    if active:
        print('=== ACTIVE ASSUMPTIONS ===')
        for a in active:
            print(f'  [{a.get(\"id\",\"?\")}] {a.get(\"claim\",\"\")[:100]}')
            print(f'         expires: {a.get(\"expiresAt\",\"unknown\")}')
            print()
    if expiring_soon:
        print('=== EXPIRING SOON (<14 days) ===')
        for a in expiring_soon:
            print(f'  [{a.get(\"id\",\"?\")}] {a.get(\"claim\",\"\")[:100]}')
            print(f'         expires: {a.get(\"expiresAt\",\"unknown\")}')
            print()
    if overdue:
        print('=== OVERDUE ===')
        for a in overdue:
            print(f'  [{a.get(\"id\",\"?\")}] {a.get(\"claim\",\"\")[:100]}')
            print(f'         created: {a.get(\"created\",\"unknown\")}')
            print()
    if not active and not expiring_soon and not overdue:
        print('No assumptions found.')
    print(f'Summary: {len(active)} active, {len(expiring_soon)} expiring, {len(overdue)} overdue')
else:
    # check mode — structured output for agent consumption
    print('ASSESSMENT=check')
    print(f'ASSUMPTIONS={len(assumptions)}')
    print(f'ACTIVE={len(active)}')
    print(f'EXPIRING_SOON={len(expiring_soon)}')
    print(f'OVERDUE={len(overdue)}')
    
    for a in overdue:
        print(f'OVERDUE|{a.get(\"id\",\"?\")}|{a.get(\"claim\",\"\")[:150]}|re-evaluate|')
    for a in expiring_soon:
        print(f'EXPIRING|{a.get(\"id\",\"?\")}|{a.get(\"claim\",\"\")[:150]}|review|')
    
    if overdue:
        print('ACTION=Review overdue assumptions and update or dismiss')
        sys.exit(1)
    elif expiring_soon:
        print('ACTION=Plan review for expiring assumptions')
        sys.exit(0)
    else:
        print('ACTION=All assumptions current')
        sys.exit(0)
" 
    ;;

  mark)
    TARGET_ID="${2:-}"
    if [ -z "$TARGET_ID" ]; then
      echo "Usage: $0 mark <id>" >&2
      exit 1
    fi
    python3 -c "
import json, sys
from datetime import datetime, timezone, timedelta
state_file = '$STATE_FILE'
target = '$TARGET_ID'
now = datetime.now(timezone.utc)
new_expiry = (now + timedelta(days=${TTL_P2})).strftime('%Y-%m-%dT00:00:00Z')
with open(state_file) as f:
    data = json.load(f)
assumptions = data.get('assumptions', [])
found = False
for a in assumptions:
    if a.get('id') == target:
        a['expiresAt'] = new_expiry
        a['status'] = 'active'
        a['lastReviewed'] = now.strftime('%Y-%m-%dT%H:%M:%SZ')
        found = True
        break
if found:
    data['assumptions'] = assumptions
    with open(state_file, 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print(f'OK: {target} marked reviewed, reset TTL to {new_expiry}')
else:
    print(f'NOT FOUND: {target}')
    sys.exit(1)
"
    ;;

  dismiss)
    TARGET_ID="${2:-}"
    if [ -z "$TARGET_ID" ]; then
      echo "Usage: $0 dismiss <id>" >&2
      exit 1
    fi
    python3 -c "
import json, sys
state_file = '$STATE_FILE'
target = '$TARGET_ID'
with open(state_file) as f:
    data = json.load(f)
assumptions = data.get('assumptions', [])
found = False
for a in assumptions:
    if a.get('id') == target:
        a['status'] = 'dismissed'
        a['dismissedAt'] = '$NOW_ISO'
        found = True
        break
if found:
    data['assumptions'] = assumptions
    with open(state_file, 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print(f'OK: {target} dismissed')
else:
    print(f'NOT FOUND: {target}')
    sys.exit(1)
"
    ;;

  init)
    # First-time migration: extract residualRisk into assumptions array
    python3 -c "
import json
state_file = '$STATE_FILE'
with open(state_file) as f:
    data = json.load(f)
assumptions = data.get('assumptions', [])
if assumptions:
    print('SKIP: assumptions already initialized')
    sys.exit(0)

residual = data.get('residualRisk', '')
if not residual:
    print('SKIP: no residualRisk to migrate')
    sys.exit(0)

import sys
from datetime import datetime, timezone
now = datetime.now(timezone.utc)

data['assumptions'] = [{
    'id': 'residualRisk',
    'claim': residual,
    'source': 'session-state.json',
    'created': data.get('lastRetrospect', now.isoformat()),
    'expiresAt': 'EXPIRED',  # first-run: mark for review
    'status': 'overdue'
}]
with open(state_file, 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print(f'MIGRATED: residualRisk → assumptions[0] (status: overdue — needs review)')
"
    ;;

  *)
    echo "Usage: $0 {check|list|mark|dismiss|init}" >&2
    echo "" >&2
    echo "  check   Check all assumptions, exit 1 if any overdue" >&2
    echo "  list    Human-readable list of all assumptions" >&2
    echo "  mark    <id> — Mark reviewed, reset TTL" >&2
    echo "  dismiss <id> — Dismiss as no longer relevant" >&2
    echo "  init    First-time: migrate residualRisk to assumptions" >&2
    exit 1
    ;;
esac
