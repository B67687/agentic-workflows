#!/usr/bin/env python3
"""
explore.py — Structured file discovery for bash-hybrid exploration.

Companion script for the bash-explore skill. Provides reusable,
structured operations for codebase exploration. Use when you need
to programmatically discover files, count patterns, or assess
directory structure — avoids ad-hoc `find`/`grep` parsing errors.

Usage from SKILL.md examples:
    python3 core/explore.py find-by-name '*handler*'
    python3 core/explore.py largest-files --ext .py --top 10
    python3 core/explore.py file-stats
    python3 core/explore.py dir-tree --max-depth 3
"""

import argparse
import subprocess
import sys
from collections import Counter
from pathlib import Path


def find_by_name(pattern: str, root: str = ".") -> list[Path]:
    """Find files matching a glob name pattern (e.g. '*handler*')."""
    return sorted(Path(root).rglob(pattern))


def find_by_content(pattern: str, extensions: list[str] | None = None,
                    root: str = ".") -> list[tuple[str, int, str]]:
    """
    Find files containing a regex pattern.
    Returns list of (filepath, line_number, line_text).
    Limited to common text extensions if extensions is None.
    """
    if extensions:
        ext_args = [e if e.startswith(".") else f".{e}" for e in extensions]
        ext_args = [e for e in ext_args]
        exts = "|".join(f"--include=*{e}" for e in ext_args)
    else:
        exts = "--include=*.py --include=*.ts --include=*.tsx --include=*.js --include=*.jsx --include=*.rs --include=*.go --include=*.md --include=*.sh --include=*.yaml --include=*.yml --include=*.json"

    cmd = f"grep -rn '{pattern}' {exts} {root}"
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=30)

    matches: list[tuple[str, int, str]] = []
    for line in result.stdout.strip().split("\n"):
        if not line:
            continue
        parts = line.split(":", 2)
        if len(parts) >= 3:
            matches.append((parts[0], int(parts[1]), parts[2].strip()[:200]))
    return matches


def largest_files(extension: str = ".py", top: int = 10,
                  root: str = ".") -> list[tuple[str, int]]:
    """Find largest files by line count for a given extension."""
    cmd = f"find {root} -name '*{extension}' -exec wc -l {{}} + 2>/dev/null"
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=30)
    files: list[tuple[str, int]] = []
    for line in result.stdout.strip().split("\n"):
        if not line or "total" in line:
            continue
        parts = line.strip().split()
        if len(parts) >= 2:
            files.append((" ".join(parts[1:]), int(parts[0])))
    return sorted(files, key=lambda x: x[1], reverse=True)[:top]


def file_stats(root: str = ".") -> dict[str, int]:
    """
    Count files by extension. Returns dict like {'.py': 42, '.md': 15, ...}.
    """
    root_path = Path(root)
    counts: Counter[str] = Counter()
    for f in root_path.rglob("*"):
        if f.is_file() and f.suffix:
            counts[f.suffix.lower()] += 1
    return dict(counts.most_common())


def dir_tree(max_depth: int = 2, root: str = ".") -> list[str]:
    """Get directory tree structure as a list of strings."""
    cmd = f"find {root} -maxdepth {max_depth} -type d | sort"
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=10)
    return [l for l in result.stdout.strip().split("\n") if l]


def main():
    parser = argparse.ArgumentParser(description="Structured file discovery")
    sub = parser.add_subparsers(dest="command", required=True)

    # find-by-name
    fn = sub.add_parser("find-by-name", help="Find files by glob pattern")
    fn.add_argument("pattern", help="Glob pattern (e.g. '*handler*' )")
    fn.add_argument("--root", default=".", help="Root directory")

    # find-by-content
    fc = sub.add_parser("find-by-content", help="Find files by content pattern")
    fc.add_argument("pattern", help="Regex pattern")
    fc.add_argument("--ext", nargs="*", help="File extensions to search (e.g. .py .ts)")
    fc.add_argument("--root", default=".", help="Root directory")

    # largest-files
    lf = sub.add_parser("largest-files", help="Largest files by line count")
    lf.add_argument("--ext", default=".py", help="File extension filter")
    lf.add_argument("--top", type=int, default=10, help="Number of files")
    lf.add_argument("--root", default=".", help="Root directory")

    # file-stats
    fs = sub.add_parser("file-stats", help="Count files by extension")
    fs.add_argument("--root", default=".", help="Root directory")

    # dir-tree
    dt = sub.add_parser("dir-tree", help="Directory tree structure")
    dt.add_argument("--max-depth", type=int, default=2, help="Max depth")
    dt.add_argument("--root", default=".", help="Root directory")

    args = parser.parse_args()

    if args.command == "find-by-name":
        for p in find_by_name(args.pattern, args.root):
            print(p)
    elif args.command == "find-by-content":
        matches = find_by_content(args.pattern, args.ext, args.root)
        for fpath, ln, text in matches:
            print(f"{fpath}:{ln}: {text}")
    elif args.command == "largest-files":
        for fpath, count in largest_files(args.ext, args.top, args.root):
            print(f"{count:>6}  {fpath}")
    elif args.command == "file-stats":
        for ext, count in file_stats(args.root).items():
            print(f"{count:>6}  {ext}")
    elif args.command == "dir-tree":
        for d in dir_tree(args.max_depth, args.root):
            print(d)


if __name__ == "__main__":
    main()
