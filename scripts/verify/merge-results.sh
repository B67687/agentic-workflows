#!/usr/bin/env bash
# =============================================================================
# merge-results.sh — Merge parallel verification results
#
# Reads per-check result files from a workspace directory and combines
# them into a single verification report.
#
# Usage: bash scripts/verify/merge-results.sh <workspace_dir>
# Output: JSON with merged verification results and pass/fail status
# =============================================================================

set -euo pipefail

WORKSPACE="${1:-}"
if [[ -z "$WORKSPACE" || ! -d "$WORKSPACE" ]]; then
  echo '{"error":"no workspace directory provided","status":"fail"}'
  exit 1
fi

python3 -c "
import json, os, glob

workspace = '$WORKSPACE'
merged = {
    'checks': [],
    'all_pass': True,
    'summary': ''
}

# Collect per-check result files
result_files = sorted(glob.glob(os.path.join(workspace, '*.json')))
control_files = {'sub_steps.json', 'output.json'}

for rf in result_files:
    fname = os.path.basename(rf)
    if fname in control_files:
        continue
    
    try:
        with open(rf) as f:
            data = json.load(f)
        
        step_id = data.get('step', fname.replace('.json', ''))
        check_status = data.get('status', 'unknown')
        
        if check_status == 'fail':
            merged['all_pass'] = False
        
        merged['checks'].append({
            'check': step_id,
            'status': check_status,
            'summary': data.get('summary', ''),
            'details': data
        })
    except (json.JSONDecodeError, IOError) as e:
        merged['checks'].append({
            'check': fname.replace('.json', ''),
            'status': 'error',
            'error': str(e)
        })

total = len(merged['checks'])
passed = sum(1 for c in merged['checks'] if c['status'] == 'pass')
failed = sum(1 for c in merged['checks'] if c['status'] == 'fail')

merged['summary'] = f\"{total} checks: {passed} pass, {failed} fail\"

print(json.dumps(merged, indent=2))
"
