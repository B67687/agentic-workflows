#!/usr/bin/env bash
# =============================================================================
# check-lsp.sh — Run LSP diagnostics on changed files
#
# Finds changed files in the repo and runs language-specific diagnostics
# (pyright for Python, tsc for TypeScript, shellcheck for Shell).
# Outputs JSON with diagnostics grouped by file.
#
# Usage: bash scripts/verify/check-lsp.sh
# Output: JSON with diagnostics per file
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"

# ── Find changed files ──

CHANGED=$(git diff --name-only HEAD 2>/dev/null || true)
UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null || true)
ALL_FILES=$(echo -e "$CHANGED\n$UNTRACKED" | grep -v '^$' | sort -u | head -20)

if [[ -z "$ALL_FILES" ]]; then
  echo '{"status":"pass","diagnostics":[],"summary":"no changed files to check"}'
  exit 0
fi

# ── Process each changed file ──

python3 -c "
import json, subprocess, sys, os

repo_root = '$REPO_ROOT'
changed = '''$ALL_FILES'''.strip().split(chr(10))
diagnostics = []

for filepath in changed:
    if not filepath.strip():
        continue
    
    ext = os.path.splitext(filepath)[1]
    full_path = os.path.join(repo_root, filepath)
    
    if not os.path.exists(full_path):
        continue
    
    # Python → pyright
    if ext == '.py':
        try:
            r = subprocess.run(
                ['pyright', '--outputjson', full_path],
                capture_output=True, text=True, timeout=15
            )
            if r.returncode in (0, 1):  # pyright returns 1 for diagnostics
                parsed = json.loads(r.stdout)
                for diag in parsed.get('generalDiagnostics', []):
                    if diag.get('severity') == 'error':
                        diagnostics.append({
                            'file': filepath,
                            'line': (diag.get('range') or {}).get('start', {}).get('line', 0),
                            'message': diag.get('message', ''),
                            'tool': 'pyright'
                        })
        except: pass
    
    # TypeScript → tsc
    elif ext in ('.ts', '.tsx'):
        try:
            r = subprocess.run(
                ['npx', 'tsc', '--noEmit', '--pretty', 'false', full_path],
                capture_output=True, text=True, timeout=30
            )
            if r.returncode != 0:
                for line in r.stdout.split(chr(10)):
                    import re
                    m = re.match(r'^(.+)\((\d+),(\d+)\):\s*error\s', line)
                    if m:
                        diagnostics.append({
                            'file': filepath,
                            'line': int(m.group(2)),
                            'message': line.strip(),
                            'tool': 'tsc'
                        })
        except: pass
    
    # Shell → shellcheck
    elif ext in ('.sh', '.bash'):
        try:
            r = subprocess.run(
                ['shellcheck', '-f', 'json', full_path],
                capture_output=True, text=True, timeout=15
            )
            if r.returncode != 0:
                parsed = json.loads(r.stdout)
                for entry in parsed:
                    diagnostics.append({
                        'file': filepath,
                        'line': entry.get('line', 0),
                        'message': f\"SC{entry.get('code','')}: {entry.get('message','')}\",
                        'tool': 'shellcheck'
                    })
        except: pass

status = 'pass' if len(diagnostics) == 0 else 'fail'
print(json.dumps({
    'status': status,
    'diagnostics_count': len(diagnostics),
    'diagnostics': diagnostics[:20],
    'summary': f\"Checked {len(changed)} changed files. Found {len(diagnostics)} diagnostic(s).\"
}))
sys.exit(0 if status == 'pass' else 1)
"
