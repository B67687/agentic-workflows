#!/usr/bin/env bash
# =============================================================================
# repo-map.sh - Build a compact map of the current repo/topic folder
# =============================================================================

set -euo pipefail

ROOT_DIR="$(pwd)"
LIMIT="${LIMIT:-80}"
WRITE_PATH=""

usage() {
  cat <<'EOF'
Usage: ./scripts/repo-map.sh [root-dir] [--limit n] [--write path]

Creates a compact repository/topic map:
- important control files
- content directories
- top-level directory shape
- markdown headings
- code symbols

Use before research/planning when the folder is unfamiliar or the task is broad.
EOF
}

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --limit)
      LIMIT="${2:-}"
      shift
      ;;
    --write)
      WRITE_PATH="${2:-}"
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      POSITIONAL+=("$1")
      ;;
  esac
  shift
done

ROOT_DIR="${POSITIONAL[0]:-$(pwd)}"

output="$(
python3 - "$ROOT_DIR" "$LIMIT" <<'PY'
from __future__ import annotations

import os
import re
import subprocess
import sys
from collections import Counter
from pathlib import Path

root = Path(sys.argv[1]).resolve()
limit = int(sys.argv[2])

if not root.exists():
    print(f"ERROR: root directory does not exist: {root}", file=sys.stderr)
    sys.exit(1)

ignore_dirs = {
    ".git",
    ".opencode",
    ".hg",
    ".svn",
    ".cache",
    ".pytest_cache",
    ".mypy_cache",
    ".ruff_cache",
    ".venv",
    "venv",
    "node_modules",
    "dist",
    "build",
    "target",
    ".next",
    ".turbo",
    "__pycache__",
}

text_exts = {
    ".md",
    ".txt",
    ".json",
    ".jsonc",
    ".yaml",
    ".yml",
    ".toml",
    ".py",
    ".js",
    ".jsx",
    ".ts",
    ".tsx",
    ".go",
    ".rs",
    ".java",
    ".kt",
    ".cs",
    ".cpp",
    ".c",
    ".h",
    ".hpp",
    ".sh",
    ".ps1",
    ".html",
    ".css",
}

symbol_patterns = [
    re.compile(r"^\s*(?:export\s+)?(?:async\s+)?function\s+([A-Za-z_][\w]*)\s*\("),
    re.compile(r"^\s*(?:export\s+)?(?:class|interface|type|enum)\s+([A-Za-z_][\w]*)\b"),
    re.compile(r"^\s*(?:def|class)\s+([A-Za-z_][\w]*)\s*[\(:]"),
    re.compile(r"^\s*func\s+(?:\([^)]+\)\s*)?([A-Za-z_][\w]*)\s*\("),
    re.compile(r"^\s*(?:pub\s+)?(?:async\s+)?fn\s+([A-Za-z_][\w]*)\s*\("),
]

def rel(path: Path) -> str:
    try:
        return str(path.relative_to(root))
    except ValueError:
        return str(path)

def is_ignored(path: Path) -> bool:
    return any(part in ignore_dirs for part in path.parts)

def is_text_file(path: Path) -> bool:
    return path.suffix.lower() in text_exts

def safe_read_lines(path: Path, max_lines: int = 220) -> list[str]:
    try:
        with path.open("r", encoding="utf-8", errors="replace") as handle:
            lines = []
            for idx, line in enumerate(handle):
                if idx >= max_lines:
                    break
                lines.append(line.rstrip("\n"))
            return lines
    except OSError:
        return []

files: list[Path] = []
for path in root.rglob("*"):
    if is_ignored(path):
        continue
    if path.is_file() and is_text_file(path):
        files.append(path)

files = sorted(files, key=lambda p: rel(p))

branch = "unknown"
status = "unknown"
if (root / ".git").exists():
    branch_proc = subprocess.run(
        ["git", "-C", str(root), "rev-parse", "--abbrev-ref", "HEAD"],
        capture_output=True,
        text=True,
    )
    if branch_proc.returncode == 0:
        branch = branch_proc.stdout.strip()
    status_proc = subprocess.run(
        ["git", "-C", str(root), "status", "--short"],
        capture_output=True,
        text=True,
    )
    if status_proc.returncode == 0:
        status = "dirty" if status_proc.stdout.strip() else "clean"

control_files = [
    "AGENTS.md",
    ".ai-prompting-hub.sh",
    "session-state.json",
    "topic-insights.md",
    "docs/workspace-system-overview.md",
    "git-github-best-practices.md",
    "quality-standards.md",
]

content_dirs = [
    p for p in sorted(root.iterdir(), key=lambda item: item.name)
    if p.is_dir() and not p.name.startswith(".") and not is_ignored(p) and (p.name.endswith("-content") or p.name in {"docs", "meta", "archive", "research", "workflow"})
]

top_counts: Counter[str] = Counter()
for path in files:
    parts = rel(path).split(os.sep)
    top_counts[parts[0]] += 1

headings: list[tuple[str, int, str]] = []
symbols: list[tuple[str, int, str]] = []

for path in files:
    r = rel(path)
    lines = safe_read_lines(path)
    if path.suffix.lower() == ".md":
        for idx, line in enumerate(lines, start=1):
            if line.startswith("#"):
                text = line.lstrip("#").strip()
                if text:
                    headings.append((r, idx, text))
    if path.suffix.lower() in {".py", ".js", ".jsx", ".ts", ".tsx", ".go", ".rs", ".java", ".kt", ".cs", ".cpp", ".c", ".h", ".hpp", ".sh", ".ps1"}:
        for idx, line in enumerate(lines, start=1):
            for pattern in symbol_patterns:
                match = pattern.match(line)
                if match:
                    symbols.append((r, idx, match.group(1)))
                    break

print("# Repo Map")
print("")
print(f"Root: {root}")
print(f"Branch: {branch}")
print(f"Worktree: {status}")
print(f"Text files indexed: {len(files)}")
print("")

print("## Control Files")
for name in control_files:
    marker = "present" if (root / name).exists() else "missing"
    print(f"- {name}: {marker}")
print("")

print("## Content Areas")
if content_dirs:
    for path in content_dirs:
        print(f"- {rel(path)}/")
else:
    print("- none detected")
print("")

print("## Directory Shape")
for name, count in top_counts.most_common(20):
    print(f"- {name}: {count} text files")
print("")

print("## High-Signal Markdown Headings")
for path, lineno, heading in headings[:limit]:
    print(f"- {path}:{lineno} {heading}")
if not headings:
    print("- none detected")
print("")

print("## Code Symbols")
for path, lineno, symbol in symbols[:limit]:
    print(f"- {path}:{lineno} {symbol}")
if not symbols:
    print("- none detected")
print("")

print("## Suggested Use")
print("- Start with this map when the folder is unfamiliar.")
print("- Use retrieve-context for targeted snippets after choosing a query.")
print("- Read exact files only after the map or retrieval points to them.")
PY
)"

if [[ -n "$WRITE_PATH" ]]; then
  mkdir -p "$(dirname "$WRITE_PATH")"
  printf '%s\n' "$output" > "$WRITE_PATH"
else
  printf '%s\n' "$output"
fi
