#!/usr/bin/env python3
"""
search-index.py --- Query a pre-built BM25 index.

Usage:  python3 search-index.py <query> [root-dir] [--top-k N]

Results are printed to stdout with scores, file paths, and short snippets.

Requires ``bm25s`` (pip install bm25s) and a pre-built index
(build-index.py must have been run first).
"""

import json
import os
import re
import sys
from pathlib import Path

import bm25s


# ---- helpers -----------------------------------------------------------------


def _format_snippet(text: str, query_terms: list[str], width: int = 80) -> str:
    """Extract a short window around the first query term match."""
    lower = text.lower()
    for term in query_terms:
        pos = lower.find(term)
        if pos < 0:
            continue
        start = max(0, pos - width // 2)
        end = min(len(text), pos + len(term) + width // 2)
        prefix = "..." if start > 0 else ""
        suffix = "..." if end < len(text) else ""
        raw = text[start:end].replace("\n", " ↵ ").strip()
        if len(raw) > width + 40:
            raw = raw[:width] + "..."
        return f"{prefix}{raw}{suffix}"
    return text[:width].replace("\n", " ↵ ").strip()


# ---- main --------------------------------------------------------------------


def main() -> None:
    args = sys.argv[1:]
    if not args or args[0] in ("-h", "--help"):
        print("Usage: python3 search-index.py <query> [root-dir] [--top-k N]",
              file=sys.stderr)
        sys.exit(1 if args and args[0] not in ("-h", "--help") else 0)

    query = args[0]

    # Parse positional root-dir  (stops before a -- flag)
    root: Path | None = None
    top_k = 10
    i = 1
    while i < len(args):
        if args[i] == "--top-k" and i + 1 < len(args):
            top_k = int(args[i + 1])
            i += 2
        elif args[i].startswith("--"):
            i += 1
        else:
            root = Path(args[i]).resolve()
            i += 1
            break  # consume exactly one positional

    if root is None:
        root = Path.cwd()

    cache_dir = root / ".cache" / "bm25"
    if not (cache_dir / "params.index.json").exists():
        print(f"ERROR: no index found at {cache_dir}.", file=sys.stderr)
        print("  Run: bash ./scripts/build-index.sh", file=sys.stderr)
        sys.exit(1)

    # Load index
    retriever = bm25s.BM25.load(str(cache_dir), load_corpus=True)

    # Load file list
    with open(cache_dir / "files.json") as fh:
        file_list: list[str] = json.load(fh)

    # Query
    query_tokens = bm25s.tokenize([query])
    results, scores = retriever.retrieve(query_tokens, k=top_k)

    # Display
    num_cols = results.shape[1]
    header = f"Top {num_cols} results for: {query}"
    print(header)
    print("-" * len(header))
    print()

    query_terms = re.findall(r"\w+", query.lower())

    found_any = False
    for col in range(num_cols):
        doc_idx = results[0, col]
        score = float(scores[0, col])
        if score <= 0:
            continue
        found_any = True
        rel_path = file_list[doc_idx]

        # Snippet from the on-disk file (more reliable than corpus store)
        on_disk = root / rel_path
        snippet_text = ""
        if on_disk.is_file():
            try:
                raw = on_disk.read_text("utf-8", errors="replace")
                snippet_text = _format_snippet(raw, query_terms)
            except OSError:
                snippet_text = "(unreadable)"

        print(f"  [{score:.3f}]  {rel_path}")
        if snippet_text:
            print(f"           {snippet_text}")
        print()

    if not found_any:
        print("  (no matching results)")


if __name__ == "__main__":
    main()
