#!/usr/bin/env bash
# =============================================================================
# validate-proposal.sh — Phase 2: Proposal format validation
#
# Validates improvement proposal JSON packets against the schema defined in
# benchmarks/proposal-schema.json.
#
# Usage:
#   bash scripts/bench/validate-proposal.sh < proposal.json
#   bash scripts/bench/validate-proposal.sh --file proposal.json
#
# Exit codes:
#   0 = valid proposal
#   1 = invalid proposal (errors printed to stderr)
#   2 = schema or input error
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCHEMA_FILE="$REPO_ROOT/benchmarks/proposal-schema.json"

usage() {
  cat <<'USAGE'
Usage: bash scripts/bench/validate-proposal.sh [options]

Options:
  --file <path>     Read proposal from file
  --schema <path>   Use custom schema (default: benchmarks/proposal-schema.json)
  --help            Show this help

Without --file, reads proposal JSON from stdin.
USAGE
}

INPUT_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
  --file)
    INPUT_FILE="$2"
    shift 2
    ;;
  --schema)
    SCHEMA_FILE="$2"
    shift 2
    ;;
  --help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown option: $1" >&2
    usage
    exit 2
    ;;
  esac
done

# Read proposal
if [[ -n "$INPUT_FILE" ]]; then
  if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: file not found: $INPUT_FILE" >&2
    exit 2
  fi
  PROPOSAL=$(cat "$INPUT_FILE")
else
  PROPOSAL=$(cat)
fi

# Validate JSON parses
if ! echo "$PROPOSAL" | python3 -m json.tool >/dev/null 2>&1; then
  echo "Error: invalid JSON" >&2
  echo "$PROPOSAL" | python3 -m json.tool 2>&1 || true
  exit 1
fi

# Check schema exists
if [[ ! -f "$SCHEMA_FILE" ]]; then
  echo "Warning: schema file not found at $SCHEMA_FILE — performing basic field validation only" >&2
  # Basic validation without schema
  ERRORS=0

  # Check required fields
  for field in proposal_id title target_gap hypothesis change predicted_impact scope risk verification; do
    if ! echo "$PROPOSAL" | python3 -c "
import json, sys
p = json.load(sys.stdin)
if '$field' not in p or p['$field'] is None:
    sys.exit(1)
" 2>/dev/null; then
      echo "Missing required field: $field" >&2
      ERRORS=$((ERRORS + 1))
    fi
  done

  if [[ "$ERRORS" -gt 0 ]]; then
    exit 1
  fi
  echo "Basic validation passed ($ERRORS errors)"
  exit 0
fi

# Full schema validation — pass data via temp file to avoid quoting issues
TMP_FILE=$(mktemp)
echo "$PROPOSAL" >"$TMP_FILE"
trap "rm -f $TMP_FILE" EXIT

python3 -c "
import json, sys

schema_file = '$SCHEMA_FILE'
proposal_file = '$TMP_FILE'

with open(schema_file) as f:
    schema = json.load(f)

with open(proposal_file) as f:
    proposal = json.load(f)

errors = []

# Check required fields
required = schema.get('required', [])
for field in required:
    if field not in proposal or proposal[field] is None:
        errors.append('Missing required field: ' + field)

# Check enum fields
props = schema.get('properties', {})

# risk enum
if 'risk' in proposal:
    risk_schema = props.get('risk', {})
    risk_valid = risk_schema.get('enum', [])
    if risk_valid and proposal['risk'] not in risk_valid:
        errors.append('Invalid risk value: ' + str(proposal['risk']) + ' (valid: ' + str(risk_valid) + ')')

# predicted_impact sub-fields
if 'predicted_impact' in proposal:
    pi = proposal['predicted_impact']
    pi_schema = props.get('predicted_impact', {}).get('properties', {})
    for sub in ['direction', 'magnitude']:
        if sub in pi:
            valid_vals = pi_schema.get(sub, {}).get('enum', [])
            if valid_vals and pi[sub] not in valid_vals:
                errors.append('Invalid predicted_impact.' + sub + ': ' + str(pi[sub]) + ' (valid: ' + str(valid_vals) + ')')

# scope sub-fields
if 'scope' in proposal:
    sc = proposal['scope']
    if 'files' in sc and not isinstance(sc['files'], list):
        errors.append('scope.files must be an array')
    if 'phases' in sc:
        if not isinstance(sc['phases'], list):
            errors.append('scope.phases must be an array')
        else:
            valid_phases = props.get('scope', {}).get('properties', {}).get('phases', {}).get('items', {}).get('enum', [])
            for phase in sc['phases']:
                if valid_phases and phase not in valid_phases:
                    errors.append('Invalid phase: ' + str(phase) + ' (valid: ' + str(valid_phases) + ')')

# Check minLength constraints
for field in ['title', 'hypothesis', 'change', 'verification']:
    if field in proposal:
        min_len = props.get(field, {}).get('minLength', 0)
        if min_len and len(proposal[field]) < min_len:
            errors.append(field + ' too short (' + str(len(proposal[field])) + ' < ' + str(min_len) + ' chars)')

if errors:
    print('INVALID')
    for e in errors:
        print('  - ' + e, file=sys.stderr)
    sys.exit(1)
else:
    print('VALID')
" 2>&1
