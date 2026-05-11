#!/usr/bin/env python3
"""
build-index.py — Build BM25 index of workspace text files.

Usage:  python3 build-index.py [root-dir]

Scans all text files under *root-dir*, builds a BM25 retrieval index,
and saves it to ``.cache/bm25/`` relative to the root.

Requires ``bm25s`` (pip install bm25s).
"""

import json
import os
import sys
import time
from pathlib import Path

# Allow import of sibling _workspace_files.py
_SCRIPT = Path(__file__).resolve()
sys.path.insert(0, str(_SCRIPT.parent))

import _workspace_files  # noqa: E402

import bm25s


# ---- helpers -----------------------------------------------------------------


def _read_text(path: Path, max_bytes: int = 512 * 1024) -> str | None:
    """Return file contents as UTF-8, or *None* if binary / too large."""
    try:
        if path.stat().st_size > max_bytes:
            return None
        return path.read_text("utf-8", errors="replace")
    except (OSError, UnicodeDecodeError):
        return None


# ---- main --------------------------------------------------------------------


def main() -> None:
    root = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()
    cache_dir = root / ".cache" / "bm25"
    cache_dir.mkdir(parents=True, exist_ok=True)

    t0 = time.time()

    # 1. Discover text files ------------------------------------------------
    print(f"Scanning  {root} …")
    files = _workspace_files.list_text_files(root)
    print(f"  Found  {len(files)} text files")

    # 2. Read contents -------------------------------------------------------
    documents: list[str] = []
    valid_rels: list[str] = []
    skipped = 0
    for f in files:
        content = _read_text(f)
        if content is None:
            skipped += 1
            continue
        documents.append(content)
        rel = os.path.relpath(str(f), str(root))
        valid_rels.append(rel)

    print(f"  Read   {len(documents)} files  ({skipped} skipped for size / binary)")

    # 3. Build BM25 index ----------------------------------------------------
    corpus_tokens = bm25s.tokenize(documents)
    retriever = bm25s.BM25()
    retriever.index(corpus_tokens)

    # 4. Persist -------------------------------------------------------------
    retriever.save(str(cache_dir))
    with open(cache_dir / "files.json", "w", encoding="utf-8") as fh:
        json.dump(valid_rels, fh)

    elapsed = time.time() - t0
    sz_mb = sum(f.stat().st_size for f in files) / (1024 * 1024)
    print(f"\n  Done  ({elapsed:.1f}s  |  {sz_mb:.0f} MB raw text)")
    print(f"  Index saved to {cache_dir}")


if __name__ == "__main__":
    main()
