#!/usr/bin/env bash
# =============================================================================
# select-batch.sh - Select N diverse BigCodeBench problems for batch solving
#
# Selects problems with balanced library coverage and prompt-length diversity.
# Outputs a JSON file with problem IDs to .runtime/bigcodebench-selection.json
#
# Usage:
#   bash scripts/bench/public/select-batch.sh [--count N] [--output <file>]
#
# Options:
#   --count N    Number of problems to select (default: 100)
#   --output f   Output file (default: .runtime/bigcodebench-selection.json)
#   --help       Show this help
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
VENV_DIR="$REPO_ROOT/.runtime/bench-env"
RUNS_DIR="$REPO_ROOT/.runtime/bench-runs"

COUNT=100
OUTPUT="$REPO_ROOT/.runtime/bigcodebench-selection.json"

usage() {
  cat <<'USAGE'
Usage: bash scripts/bench/public/select-batch.sh [options]

Options:
  --count N    Number of problems to select (default: 100)
  --output f   Output file (default: .runtime/bigcodebench-selection.json)
  --help       Show this help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  --count)
    COUNT="$2"
    shift 2
    ;;
  --output)
    OUTPUT="$2"
    shift 2
    ;;
  --help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown: $1" >&2
    usage
    exit 2
    ;;
  esac
done

if [[ ! -d "$VENV_DIR" ]]; then
  echo "Error: bench venv not found. Run: bash scripts/bench/public/setup.sh bigcodebench" >&2
  exit 1
fi

source "$VENV_DIR/bin/activate"

python3 <<PYEOF
import json, os, ast
from bigcodebench.data import get_bigcodebench

problems = get_bigcodebench()

def parse_libs(libs_str):
    try:
        return ast.literal_eval(libs_str)
    except:
        return []

# Already solved in previous session (skip these)
already_solved = {
    'BigCodeBench/254', 'BigCodeBench/260', 'BigCodeBench/330',
    'BigCodeBench/380', 'BigCodeBench/6', 'BigCodeBench/98',
    'BigCodeBench/738', 'BigCodeBench/863', 'BigCodeBench/379', 'BigCodeBench/695',
}

# Categorize each problem
def categorize(pid, p):
    libs = [l.lower() for l in parse_libs(p.get('libs', '[]'))]
    cp_len = len(p.get('complete_prompt', ''))
    if any('sklearn' in l for l in libs):
        return 'sklearn'
    if any('pandas' in l for l in libs):
        return 'pandas'
    if any('matplotlib' in l for l in libs):
        return 'matplotlib'
    if any('seaborn' in l for l in libs):
        return 'seaborn'
    if any('scipy' in l for l in libs):
        return 'scipy'
    if any('requests' in l for l in libs):
        return 'requests'
    if any('numpy' in l for l in libs):
        return 'numpy'
    std_libs = {'math','random','itertools','collections','string','statistics',
                'functools','re','json','os','sys','datetime','typing','bisect',
                'heapq','copy','decimal','fractions','operator','filecmp','csv',
                'glob','hashlib','shutil','io','pathlib','sqlite3','xml','zipfile',
                'tarfile','argparse','base64','binascii','calendar','uuid','tempfile',
                'time','textwrap','pprint','pickle','shelve','configparser','logging',
                'warnings','inspect','subprocess'}
    if all(l in std_libs for l in libs):
        return 'stdlib'
    return 'other'

# Build categorized lists (excluding already solved)
categorized = {'stdlib': [], 'numpy': [], 'pandas': [], 'sklearn': [],
               'matplotlib': [], 'scipy': [], 'seaborn': [], 'requests': [], 'other': []}

for pid, p in problems.items():
    if pid in already_solved:
        continue
    cat = categorize(pid, p)
    cp_len = len(p.get('complete_prompt', ''))
    categorized[cat].append({'id': pid, 'num': int(pid.split('/')[1]), 'cp_len': cp_len})

# Sort each category by prompt length (shortest first = easiest)
for cat in categorized:
    categorized[cat].sort(key=lambda x: x['cp_len'])

# Target distribution for 100 problems (proportional but weighted toward easier)
targets = {
    'stdlib': 25, 'numpy': 10, 'pandas': 20, 'sklearn': 10,
    'matplotlib': 10, 'scipy': 5, 'seaborn': 3, 'requests': 5, 'other': 12,
}
# Scale to requested count
scale_factor = $COUNT / 100.0
targets = {k: max(1, int(v * scale_factor)) for k, v in targets.items()}

selected = []
for cat, target in targets.items():
    pool = categorized[cat]
    if not pool:
        continue
    # Take from shortest prompts first (easier)
    take = min(target, len(pool))
    selected.extend(pool[:take])
    print(f"  {cat}: selected {take}/{len(pool)} (target {target})")

# Sort by problem number for readability
selected.sort(key=lambda x: x['num'])

# Write output
os.makedirs(os.path.dirname('$OUTPUT'), exist_ok=True)
with open('$OUTPUT', 'w') as f:
    json.dump([s['id'] for s in selected], f, indent=2)

print(f"\nTotal selected: {len(selected)}")
print(f"Output: $OUTPUT")
PYEOF
