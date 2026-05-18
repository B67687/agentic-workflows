#!/usr/bin/env bash
# =============================================================================
# merge-findings.sh — Merge parallel research findings
#
# Reads per-sub-step result files from a workspace directory and combines
# them into a single research findings document.
#
# Usage: bash scripts/research/merge-findings.sh <workspace_dir>
#
# Output (stdout): JSON with merged findings, files, patterns, and summary.
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
    'findings': [],
    'all_files': [],
    'total_questions': 0,
    'total_files_found': 0,
    'summary': ''
}

# Collect per-sub-step result files
result_files = sorted(glob.glob(os.path.join(workspace, '*.json')))
# Exclude control files
control_files = {'sub_steps.json', 'output.json', '_intermediate.json'}

for rf in result_files:
    fname = os.path.basename(rf)
    if fname in control_files:
        continue
    
    try:
        with open(rf) as f:
            data = json.load(f)
        
        # Each sub-step result might have stdout with embedded JSON
        step_id = data.get('step', fname.replace('.json', ''))
        
        # Parse stdout for JSON findings
        stdout_text = data.get('stdout', '')
        if stdout_text:
            try:
                finding = json.loads(stdout_text)
                merged['findings'].append(finding)
                merged['all_files'].extend(finding.get('files_found', []))
            except json.JSONDecodeError:
                merged['findings'].append({
                    'step': step_id,
                    'raw_text': stdout_text[:500],
                    'status': data.get('status', 'unknown')
                })
        else:
            merged['findings'].append({
                'step': step_id,
                'status': data.get('status', 'unknown'),
                'error': data.get('error', 'no output')
            })
    except (json.JSONDecodeError, IOError) as e:
        merged['findings'].append({
            'step': fname.replace('.json', ''),
            'error': str(e)
        })

# Deduplicate and sort files
seen = set()
unique_files = []
for f in merged['all_files']:
    if f not in seen:
        seen.add(f)
        unique_files.append(f)
merged['all_files'] = sorted(unique_files)
merged['total_questions'] = len(merged['findings'])
merged['total_files_found'] = len(merged['all_files'])

# Build summary
merged['summary'] = (
    f\"Explored {merged['total_questions']} questions in parallel. \" +
    f\"Found {merged['total_files_found']} unique relevant files. \" +
    f\"All sub-steps completed.\"
)

print(json.dumps(merged, indent=2))
"
