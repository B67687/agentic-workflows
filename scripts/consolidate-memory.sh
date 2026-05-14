#!/usr/bin/env bash
# =============================================================================
# consolidate-memory.sh --- Deduplicate and merge similar learnings
#
# Mem0-inspired memory consolidation pattern:
#   1. Read all learnings from .learnings.jsonl
#   2. Detect duplicates by normalized text similarity
#   3. Merge similar entries, keeping the most recent
#   4. Re-write the file with consolidated entries
#
# Source: Mem0's memory consolidation approach
# (https://github.com/mem0ai/mem0 --- memory consolidation)
#
# Usage:
#   bash ./scripts/consolidate-memory.sh                # consolidate and report
#   bash ./scripts/consolidate-memory.sh --dry-run      # preview only
#   bash ./scripts/consolidate-memory.sh --stats        # report only
#   bash ./scripts/consolidate-memory.sh --sync         # consolidate + flag for agentmemory sync
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LEARNINGS_FILE="$REPO_ROOT/.learnings.jsonl"
MODE="${1:-consolidate}"

[ ! -f "$LEARNINGS_FILE" ] && echo "No learnings file found at $LEARNINGS_FILE" && exit 0

TOTAL=$(wc -l < "$LEARNINGS_FILE")
echo "=== Memory Consolidation ==="
echo "  Source: $LEARNINGS_FILE"
echo "  Total entries: $TOTAL"
echo ""

case "$MODE" in
  --stats|stats)
    # Count unique tags and entries per day
    echo "Tags breakdown:"
    python3 -c "
import json
from collections import Counter
tags = Counter()
with open('$LEARNINGS_FILE') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            entry = json.loads(line)
            raw_tags = entry.get('tags', '')
            if isinstance(raw_tags, str):
                for t in raw_tags.split(','):
                    t = t.strip()
                    if t:
                        tags[t] += 1
            elif isinstance(raw_tags, list):
                for t in raw_tags:
                    tags[t] += 1
        except:
            pass
for tag, count in tags.most_common():
    print(f'  {tag}: {count}')
print()
print(f'Unique tags: {len(tags)}')
" 2>/dev/null || echo '  (parse error)'
    exit 0
    ;;

  --dry-run)
    echo "Running in dry-run mode (no changes written)"
    python3 -c "
import json, re

entries = []
with open('$LEARNINGS_FILE') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            entries.append(json.loads(line))
        except:
            pass

# Normalize: lowercase, strip punctuation, collapse whitespace
def normalize(text):
    text = text.lower()
    text = re.sub(r'[^a-z0-9 ]', '', text)
    return ' '.join(text.split())

# Find potential duplicates by content overlap
removed = 0
normalized = {}
for i, e in enumerate(entries):
    # Use first 60 chars as dedup key
    content = e.get('insight', e.get('content', ''))
    short = normalize(content)[:60]
    if short in normalized:
        removed += 1
        print(f'  DUPLICATE [{i}]: \"{content[:60]}...\"')
        print(f'    vs [{normalized[short]}]: same normalized prefix')
    else:
        normalized[short] = i

print()
if removed > 0:
    print(f'  Would remove: {removed} duplicate(s)')
else:
    print('  No duplicates found')
print(f'  Would keep: {len(normalized)} entry(ies)')
" 2>/dev/null
    exit 0
    ;;

  consolidate)
    echo "Consolidating..."
    python3 -c "
import json, re

entries = []
with open('$LEARNINGS_FILE') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            entries.append(json.loads(line))
        except:
            pass

# Normalize for dedup
def normalize(text):
    text = text.lower()
    text = re.sub(r'[^a-z0-9 ]', '', text)
    return ' '.join(text.split())

# Dedup by first 60 normalized chars
seen = {}
kept = []
removed = 0
for e in entries:
    content = e.get('insight', e.get('content', ''))
    key = normalize(content)[:60]
    if key in seen:
        # Merge tags from duplicate into the original
        orig = seen[key]
        orig_tags = orig.get('tags', '')
        if isinstance(orig_tags, str):
            orig_tags_set = set(orig_tags.split(','))
        else:
            orig_tags_set = set(orig_tags)
        new_tags = e.get('tags', '')
        if isinstance(new_tags, str):
            new_tags_list = new_tags.split(',')
        else:
            new_tags_list = new_tags
        for t in new_tags_list:
            t = t.strip()
            if t and t not in orig_tags_set:
                orig_tags_set.add(t)
                orig_tags = orig.get('tags', '')
                if isinstance(orig_tags, str):
                    orig['tags'] = orig_tags + ',' + t
                else:
                    orig['tags'].append(t)
        # Keep the most recent timestamp
        ts = e.get('ts', '')
        if ts > orig.get('ts', ''):
            orig['ts'] = ts
        removed += 1
    else:
        kept.append(e)
        seen[key] = e

# Write consolidated file
with open('$LEARNINGS_FILE', 'w') as f:
    for e in kept:
        f.write(json.dumps(e) + '\n')

print(f'  Removed: {removed} duplicate(s)')
print(f'  Kept:    {len(kept)} entry(ies)')
print(f'  Before:  {len(entries)} -> After: {len(kept)}')
" 2>/dev/null
    ;;

  --entity-extract)
    echo "Extracting entities from learnings..."
    python3 -c "
import json, re

# Known tool/script names to detect
KNOWN_TOOLS = [
    'pipeline-run.sh', 'agent-dispatch.sh', 'browser.sh', 'consolidate-memory.sh',
    'memory-query.sh', 'sync-learnings.sh', 'search-index.sh', 'test-smoke.sh',
    'task-retrospect.sh', 'context-pressure.sh', 'a2h-contact.sh', 'skill-toolset.sh',
    'checkpoint-commit.sh', 'explore.py', 'triage.sh',
]

# Known skill names to detect
KNOWN_SKILLS = [
    'source-extraction', 'debugging-and-error-recovery', 'test-driven-development',
    'incremental-implementation', 'ci-cd-and-automation', 'frontend-ui-engineering',
    'browser-testing-with-devtools', 'code-review-and-quality', 'code-simplification',
    'security-and-hardening', 'performance-optimization', 'documentation-and-adrs',
    'planning-and-task-breakdown', 'git-workflow-and-versioning', 'shipping-and-launch',
    'context-engineering', 'bash-explore', 'skill-creator',
]

def extract_entities(text):
    entities = set()
    text_lower = text.lower()
    
    # Tool names
    for tool in KNOWN_TOOLS:
        if tool.lower() in text_lower:
            entities.add('entity:' + tool.replace('.sh', '').replace('.py', ''))
    
    # Skill names
    for skill in KNOWN_SKILLS:
        if skill.replace('-', ' ') in text_lower or skill in text_lower:
            name = skill.split('-')[0] if '-' in skill else skill
            entities.add('entity:' + name)
    
    # Session and pipeline references
    for pat in [r'\bpipeline-[\w-]+\b', r'\bsession[- ]\d+\b', r'\btraj-[\w-]+\b']:
        for m in re.finditer(pat, text_lower):
            entities.add('entity:reference')
    
    return list(entities)

entries = []
with open('$LEARNINGS_FILE') as f:
    for line in f:
        line = line.strip()
        if not line: continue
        try:
            entries.append(json.loads(line))
        except:
            pass

total_entities = 0
updated = 0
for e in entries:
    content = e.get('insight', e.get('content', ''))
    tags = e.get('tags', '')
    
    # Detect existing entity tags
    existing_entities = [t for t in (tags.split(',') if isinstance(tags, str) else tags) if t.startswith('entity:')]
    
    # Extract new entities
    new_entities = extract_entities(content)
    
    # Filter to only new ones
    to_add = [e for e in new_entities if e not in existing_entities]
    
    if to_add:
        if isinstance(tags, str):
            if tags:
                e['tags'] = tags + ',' + ','.join(to_add)
            else:
                e['tags'] = ','.join(to_add)
        else:
            e['tags'] = list(tags) + to_add
        updated += 1
        total_entities += len(to_add)

# Write back
with open('$LEARNINGS_FILE', 'w') as f:
    for e in entries:
        f.write(json.dumps(e) + '\n')

print(f'  Entries processed: {len(entries)}')
print(f'  Updated: {updated} entries')
print(f'  Entity tags added: {total_entities}')
" 2>/dev/null
    ;;

  --sync)
    echo "Syncing to agentmemory..."
    # First run consolidation
    python3 -c "
import json, re, pathlib

entries = []
with open('$LEARNINGS_FILE') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            entries.append(json.loads(line))
        except:
            pass

# Normalize for dedup
def normalize(text):
    text = text.lower()
    text = re.sub(r'[^a-z0-9 ]', '', text)
    return ' '.join(text.split())

seen = {}
kept = []
removed = 0
for e in entries:
    content = e.get('insight', e.get('content', ''))
    key = normalize(content)[:60]
    if key in seen:
        orig = seen[key]
        for t in str(e.get('tags', '')).split(','):
            t = t.strip()
            if t and t not in str(orig.get('tags', '')).split(','):
                if isinstance(orig.get('tags', ''), str):
                    orig['tags'] = (orig.get('tags', '') + ',' + t).strip(',')
        if e.get('ts', '') > orig.get('ts', ''):
            orig['ts'] = e['ts']
        removed += 1
    else:
        kept.append(e)
        seen[key] = e

with open('$LEARNINGS_FILE', 'w') as f:
    for e in kept:
        f.write(json.dumps(e) + '\n')
" 2>/dev/null
    
    # Write pending sync file for agent to pick up
    mkdir -p "$REPO_ROOT/.runtime"
    python3 -c "
import json
with open('$LEARNINGS_FILE') as f:
    content = f.read()

# Write as JSON array for agent consumption
entries = []
for line in content.strip().split('\n'):
    if not line: continue
    try:
        e = json.loads(line)
        entries.append(e)
    except:
        pass

with open('$REPO_ROOT/.runtime/pending-sync.json', 'w') as f:
    json.dump({'entries': entries, 'count': len(entries), 'synced': False}, f, indent=2)

print(f'  Pending sync: {len(entries)} entries flagged for agentmemory')
print('  Run: python3 scripts/sync-learnings.sh to push to agentmemory')
" 2>/dev/null
    ;;

  *)
    echo "Usage: consolidate-memory.sh [--dry-run|--stats|consolidate|--entity-extract|--sync]"
    echo ""
    echo "  consolidate       Deduplicate and merge (default)"
    echo "  --dry-run         Preview dedup changes"
    echo "  --stats           Tag frequency report"
    echo "  --entity-extract  Extract entity tags from content (Mem0 v3 pattern)"
    echo "  --sync            Consolidate + flag for agentmemory sync"
    exit 1
    ;;
esac
