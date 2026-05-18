#!/usr/bin/env bash
# =============================================================================
# explore.sh — Atomic research sub-step for one question
#
# Searches the codebase for evidence relevant to a single research question.
# Outputs findings as compact JSON to stdout.
#
# Usage: bash scripts/research/explore.sh "<research question>"
#
# This is the atomic unit of parallel research. Each call explores one
# question independently. Multiple explore.sh processes run concurrently
# via parallel-dispatch.sh.
#
# Output: JSON with keys: question, files_found, patterns, summary
# =============================================================================

set -euo pipefail

QUESTION="${1:-}"
if [[ -z "$QUESTION" ]]; then
  echo '{"error":"no question provided","status":"fail"}'
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Search the codebase ──

python3 -c "
import json, subprocess, sys, os

question = '''$QUESTION'''
repo_root = '$REPO_ROOT'
findings = {
    'question': question,
    'searches': [],
    'files_found': [],
    'patterns': [],
    'summary': ''
}

# Extract keywords (skip common words)
stop_words = {'what','how','does','the','this','that','with','from','which',
              'where','when','why','your','their','about','would','could',
              'should','there','these','have','has','had','been','being',
              'some','any','all','each','every','both','few','more','most',
              'other','than','then','into','over','also','very','just'}
words = [w.lower().strip('.,?!:;\"\'()[]{}') for w in question.split()]
keywords = [w for w in words if len(w) > 3 and w not in stop_words]

if not keywords:
    # Fallback: use the whole question as a grep pattern
    keywords = [question]

for word in keywords[:5]:  # limit to 5 keywords
    try:
        r = subprocess.run(
            ['grep', '-rl', '--include=*.py', '--include=*.ts',
             '--include=*.sh', '--include=*.md', '--include=*.yaml',
             '--include=*.json', '-l', word, repo_root],
            capture_output=True, text=True, timeout=15
        )
        files = [f.replace(repo_root + '/', '') for f in r.stdout.strip().split(chr(10)) if f]
        if files:
            findings['searches'].append({'keyword': word, 'count': len(files), 'files': files[:10]})
            findings['files_found'].extend(files[:10])
    except:
        pass

# Deduplicate files
seen = set()
unique_files = []
for f in findings['files_found']:
    if f not in seen:
        seen.add(f)
        unique_files.append(f)
findings['files_found'] = unique_files

findings['summary'] = f\"Found {len(findings['files_found'])} relevant files across {len(findings['searches'])} search patterns\"

# Include grep matches count for relevance scoring
try:
    for search in findings['searches']:
        kw = search['keyword']
        r = subprocess.run(
            ['grep', '-rn', '--include=*.py', '--include=*.ts',
             '--include=*.sh', '--include=*.md', '-c', kw, repo_root],
            capture_output=True, text=True, timeout=10
        )
        total = sum(int(line.split(':')[-1]) for line in r.stdout.strip().split(chr(10)) if line and line.split(':')[-1].isdigit())
        search['total_matches'] = total
except:
    pass

print(json.dumps(findings, indent=2))
"
