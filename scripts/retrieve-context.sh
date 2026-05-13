#!/usr/bin/env bash
# =============================================================================
# retrieve-context.sh - Pull only the local context relevant to this step
#
# Features (12-factor aligned):
#   --xml     Output in XML-style tagged format (factor 3: own your context)
#   --prefetch  Include deterministic pre-fetch of git/tools state (factor 13)
#   (default) Ranked text output
# =============================================================================

set -euo pipefail

ROOT_DIR="$(pwd)"
QUERY=""
LIMIT="${LIMIT:-8}"
DEEP_HISTORY=false
XML_MODE=false
PRE_FETCH=false
POSITIONAL=()

usage() {
  cat <<'EOF'
Usage: ./scripts/retrieve-context.sh "query" [root-dir] [options]

Search only high-signal local files and return ranked context.
Options:
  --deep-history   Include archive/history-full-detailed.md
  --xml            Output in XML-style tagged format (token-efficient)
  --prefetch       Include deterministic pre-fetch of git/tools state
  --help, -h       Show this help

Default search scope:
  - session-state.json   AGENTS.md   docs/   meta/
  - topic-insights.md    archive/history-index.md
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --deep-history)
      DEEP_HISTORY=true
      shift
      ;;
    --xml)
      XML_MODE=true
      shift
      ;;
    --prefetch)
      PRE_FETCH=true
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

QUERY="${POSITIONAL[0]:-}"
ROOT_DIR="${POSITIONAL[1]:-$(pwd)}"

if [[ -z "$QUERY" ]]; then
  echo "ERROR: query is required." >&2
  usage >&2
  exit 2
fi

# --- Pre-fetch contextual data if requested (factor 13) ---
if $PRE_FETCH; then
  PREFETCH_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")
  PREFETCH_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "?")
  PREFETCH_COMMITS=$(git log --oneline -5 2>/dev/null || echo "")
  PREFETCH_DIRTY=$(git status --short 2>/dev/null | head -10 || echo "")
  PREFETCH_DIRTY_COUNT=$(echo "$PREFETCH_DIRTY" | grep -c . 2>/dev/null || echo "0")
  PREFETCH_TOOLS=$(bash "$ROOT_DIR/scripts/tools.sh" 2>/dev/null | head -20 || echo "?")
  PREFETCH_HEALTH=$(bash "$ROOT_DIR/scripts/context-pressure.sh" --json 2>/dev/null || echo "{}")
else
  PREFETCH_BRANCH=""
  PREFETCH_HASH=""
  PREFETCH_COMMITS=""
  PREFETCH_DIRTY=""
  PREFETCH_DIRTY_COUNT="0"
  PREFETCH_TOOLS=""
  PREFETCH_HEALTH="{}"
fi

python3 - "$ROOT_DIR" "$QUERY" "$LIMIT" "$DEEP_HISTORY" "$XML_MODE" \
  "$PREFETCH_BRANCH" "$PREFETCH_HASH" "$PREFETCH_COMMITS" \
  "$PREFETCH_DIRTY" "$PREFETCH_DIRTY_COUNT" "$PREFETCH_TOOLS" \
  "$PREFETCH_HEALTH" <<'PY'
from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path
from typing import Any

root = Path(sys.argv[1]).resolve()
query = sys.argv[2]
limit = int(sys.argv[3])
deep_history = sys.argv[4].lower() == "true"
xml_mode = sys.argv[5].lower() == "true"

# Pre-fetched contextual data
pf_branch = sys.argv[6]
pf_hash = sys.argv[7]
pf_commits = sys.argv[8]
pf_dirty = sys.argv[9]
pf_dirty_count = sys.argv[10]
pf_tools = sys.argv[11]
pf_health = sys.argv[12]

if not root.exists():
    print(f"ERROR: root directory does not exist: {root}", file=sys.stderr)
    sys.exit(1)


# --- Gather candidates ---

candidates: list[Path] = []

def add(path: Path) -> None:
    if path.exists() and path.is_file():
        candidates.append(path)

add(root / "session-state.json")
add(root / "AGENTS.md")
add(root / "topic-insights.md")
add(root / "archive" / "history-index.md")
if deep_history:
    add(root / "archive" / "history-full-detailed.md")

for base in ("docs", "meta"):
    folder = root / base
    if folder.exists():
        for path in sorted(folder.rglob("*")):
            if path.is_file():
                candidates.append(path)

if not candidates:
    if xml_mode:
        print("<context_query>\n  <query>", query, "</query>\n  <status>no_sources</status>\n</context_query>")
    else:
        print("No approved context files found.")
    sys.exit(0)


# --- Search with ripgrep ---

cmd = ["rg", "-n", "-i", "--no-heading", query, *[str(p) for p in candidates]]
proc = subprocess.run(cmd, capture_output=True, text=True)
lines = [line for line in proc.stdout.splitlines() if line.strip()]


# --- Ranking ---

def score(path: str) -> int:
    if path.endswith("session-state.json"):
        return 100
    if path.endswith("AGENTS.md"):
        return 95
    if path.endswith("archive/superseded/workspace-system-overview.md"):
        return 90
    if "/docs/" in path:
        return 75
    if "/meta/" in path:
        return 65
    if path.endswith("topic-insights.md"):
        return 55
    if path.endswith("archive/history-index.md"):
        return 40
    if path.endswith("archive/history-full-detailed.md"):
        return 20
    return 30


def get_reason(path: str) -> str:
    if path.endswith("session-state.json"):
        return "active state"
    if path.endswith("AGENTS.md"):
        return "operating contract"
    if path.endswith("archive/superseded/workspace-system-overview.md"):
        return "system map"
    if "/docs/" in path:
        return "doc"
    if "/meta/" in path:
        return "project context"
    if path.endswith("topic-insights.md"):
        return "repo lessons"
    return "approved source"


# --- Format output ---

def escape_xml(text: str) -> str:
    """Minimal XML escaping for text content."""
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;")


def format_ranked_text(grouped: dict[str, list[tuple[int, str]]]) -> str:
    ranked = sorted(grouped.items(), key=lambda item: (-score(item[0]), item[0]))
    out_parts = [f"Top matches for: {query}", ""]
    for idx, (path, snippets) in enumerate(ranked[:limit], start=1):
        p = Path(path)
        rel = p.relative_to(root) if p.is_relative_to(root) else p
        reason = get_reason(path)
        out_parts.append(f"{idx}. {rel}")
        out_parts.append(f"   reason: {reason}")
        for lineno, snippet in snippets[:3]:
            out_parts.append(f"   {lineno}: {snippet}")
        out_parts.append("")
    return "\n".join(out_parts)


def format_xml(grouped: dict[str, list[tuple[int, str]]]) -> str:
    """XML-style tagged output — token-efficient, attention-friendly (factor 3)."""
    ranked = sorted(grouped.items(), key=lambda item: (-score(item[0]), item[0]))
    parts: list[str] = []

    parts.append("<context_query>")

    # Query
    parts.append(f"  <query>{escape_xml(query)}</query>")

    # Pre-fetched context (factor 13)
    if pf_branch:
        parts.append("  <prefetched>")
        parts.append(f"    <git_state>")
        parts.append(f"      <branch>{escape_xml(pf_branch)}</branch>")
        parts.append(f"      <hash>{escape_xml(pf_hash)}</hash>")
        parts.append(f"      <dirty_files>{escape_xml(pf_dirty_count)}</dirty_files>")
        if pf_dirty:
            parts.append("      <changes>")
            for line in pf_dirty.strip().split("\n"):
                parts.append(f"        <change>{escape_xml(line)}</change>")
            parts.append("      </changes>")
        parts.append("    </git_state>")
        if pf_commits:
            parts.append("    <recent_commits>")
            for line in pf_commits.strip().split("\n"):
                parts.append(f"      <commit>{escape_xml(line)}</commit>")
            parts.append("    </recent_commits>")
        if pf_tools:
            parts.append(f"    <tools_available>")
            for line in pf_tools.strip().split("\n"):
                parts.append(f"      <tool>{escape_xml(line)}</tool>")
            parts.append(f"    </tools_available>")
        parts.append("  </prefetched>")

    # Matches
    if lines:
        parts.append("  <matches>")
        for idx, (path, snippets) in enumerate(ranked[:limit], start=1):
            p = Path(path)
            rel = p.relative_to(root) if p.is_relative_to(root) else p
            reason = get_reason(path)
            parts.append(f'    <match rank="{idx}" file="{escape_xml(str(rel))}" reason="{escape_xml(reason)}">')
            for lineno, snippet in snippets[:3]:
                parts.append(f'      <line number="{lineno}">{escape_xml(snippet)}</line>')
            parts.append("    </match>")
        parts.append("  </matches>")
    else:
        parts.append(f"  <status>no_matches</status>")

    parts.append("</context_query>")
    return "\n".join(parts)


# --- Group and output ---

grouped: dict[str, list[tuple[int, str]]] = {}
for line in lines:
    parts = line.split(":", 2)
    if len(parts) != 3:
        continue
    path, lineno, snippet = parts
    grouped.setdefault(path, []).append((int(lineno), snippet.strip()))

if not grouped:
    if xml_mode:
        print(f"<context_query>\n  <query>{escape_xml(query)}</query>\n  <status>no_matches</status>\n</context_query>")
    else:
        print(f"No approved matches found for: {query}")
    sys.exit(0)

if xml_mode:
    print(format_xml(grouped))
else:
    print(format_ranked_text(grouped))
PY
