#!/usr/bin/env python3
"""
repo-map.py — Build a compact, ranked map of the workspace using tree-sitter.

Usage:
    python3 repo-map.py [root-dir] [--max-tokens N]

Scans text files via tree-sitter, extracts symbols (classes, functions, methods,
types), builds a dependency graph, runs PageRank for importance, and outputs a
compact, ranked map.

Dependencies:
    tree_sitter_language_pack  (installed automatically with grep_ast)
"""

import json
import math
import os
import re
import sys
import time
from collections import defaultdict
from pathlib import Path
from typing import NamedTuple

# ---- Shared utility ---------------------------------------------------------
_SCRIPT = Path(__file__).resolve()
sys.path.insert(0, str(_SCRIPT.parent))
import _workspace_files  # noqa: E402

# Tree-sitter language pack (provides process() for parsing)
from tree_sitter_language_pack import process, ProcessConfig


# ---- Data types -------------------------------------------------------------

class Symbol(NamedTuple):
    name: str
    kind: str          # Function, Class, Method, Interface, TypeAlias, etc.
    line: int
    column: int


# ---- Language support --------------------------------------------------------

# Languages supported by tree_sitter_language_pack
# We use the `process()` function which auto-detects or takes a language name.
TREE_SITTER_LANGS = {
    ".py": "python",
    ".js": "javascript",
    ".jsx": "javascript",
    ".ts": "typescript",
    ".tsx": "typescript",
    ".go": "go",
    ".rs": "rust",
    ".java": "java",
    ".kt": "kotlin",
    ".cs": "c_sharp",
    ".rb": "ruby",
    ".php": "php",
    ".swift": "swift",
    ".c": "c",
    ".cpp": "cpp",
    ".h": "c",
    ".hpp": "cpp",
    ".sh": "bash",
    ".bash": "bash",
    ".zsh": "bash",
    ".pyi": "python",
    ".mjs": "javascript",
    ".cjs": "javascript",
}

# Regex patterns for languages NOT in tree-sitter (fallback)
# Captures function/class definitions from plain text
SYMBOL_REGEX = [
    re.compile(r"^\s*(?:export\s+)?(?:async\s+)?function\s+(\w+)\s*\("),
    re.compile(r"^\s*(?:export\s+)?(?:class|interface|type|enum)\s+(\w+)"),
    re.compile(r"^\s*(?:export\s+)?(?:default\s+)?(?:function|class)\s+(\w+)"),
    re.compile(r"^\s*(?:def|class)\s+(\w+)\s*[\(:]"),
    re.compile(r"^\s*func\s+(?:\([^)]+\)\s*)?(\w+)\s*\("),
    re.compile(r"^\s*(?:pub\s+)?(?:async\s+)?fn\s+(\w+)\s*\("),
    re.compile(r"^\s*(?:export\s+)?(?:const|let|var)\s+(\w+)\s*=\s*(?:async\s*)?\(?"),
]

# Import regex patterns for dependency graph
IMPORT_REGEX = {
    "python": [
        re.compile(r"^\s*import\s+(\S+)"),
        re.compile(r"^\s*from\s+(\S+)\s+import"),
    ],
    "javascript": [
        re.compile(r"""^\s*import\s+(?:\{[^}]*\}\s+from\s+)?['\"]([^'\"]+)['\"]"""),
        re.compile(r"""^\s*(?:const|let|var)\s+\w+\s*=\s*require\s*\(['\"]([^'\"]+)['\"]"""),
    ],
    "bash": [
        re.compile(r"^\s*source\s+(\S+)"),
        re.compile(r"^\s*\.\s+(\S+)"),
    ],
}


# ---- Helpers ----------------------------------------------------------------

def _get_lang(ext: str) -> str | None:
    """Map file extension to tree-sitter language name."""
    return TREE_SITTER_LANGS.get(ext.lower())


def _get_imports(text: str, ext: str) -> list[str]:
    """Extract import paths from text using regex patterns."""
    imports = []
    for pat in IMPORT_REGEX.get("python" if ext == ".py" else
                                "javascript" if ext in (".js", ".jsx", ".ts", ".tsx", ".mjs", ".cjs") else
                                "bash" if ext in (".sh", ".bash", ".zsh") else
                                ext, []):
        for m in pat.finditer(text):
            imports.append(m.group(1).strip())
    return imports


def _extract_symbols_tree_sitter(text: str, lang: str) -> list[Symbol]:
    """Extract symbols using tree-sitter."""
    symbols = []
    try:
        config = ProcessConfig(language=lang, structure=True, symbols=False)
        result = process(text, config)
        for item in result.structure:
            kind_str = str(item.kind)
            # Filter to relevant kinds
            if kind_str in ("Function", "Class", "Method", "Interface",
                            "TypeAlias", "Enum", "Struct", "Trait",
                            "Module", "Decorator"):
                symbols.append(Symbol(
                    name=item.name or "",
                    kind=kind_str,
                    line=item.span.start_line,
                    column=item.span.start_column,
                ))
    except Exception:
        pass  # Fall through to regex
    return symbols


def _extract_symbols_regex(text: str) -> list[Symbol]:
    """Extract symbols using regex (fallback)."""
    symbols = []
    lines = text.splitlines()
    for idx, line in enumerate(lines, start=1):
        for pattern in SYMBOL_REGEX:
            m = pattern.match(line)
            if m:
                symbols.append(Symbol(
                    name=m.group(1),
                    kind="Function" if "function" in line.lower() or "def " in line or "fn " in line else "Class" if "class " in line else "Symbol",
                    line=idx,
                    column=line.index(m.group(1)),
                ))
                break
    return symbols


def _extract_headings(text: str) -> list[Symbol]:
    """Extract markdown headings as pseudo-symbols."""
    symbols = []
    for i, line in enumerate(text.splitlines(), start=1):
        if line.startswith("#"):
            level = len(line) - len(line.lstrip("#"))
            text_content = line.lstrip("#").strip()
            if text_content:
                symbols.append(Symbol(
                    name=text_content,
                    kind=f"H{level}",
                    line=i,
                    column=0,
                ))
    return symbols


def _resolve_import(imp: str, source_file: Path, root: Path) -> Path | None:
    """Try to resolve an import path to an actual file."""
    # Normalize: strip quotes, handle relative paths
    imp = imp.strip("'\"")
    if imp.startswith("."):
        # Relative import
        base = source_file.parent
    else:
        base = root

    candidates = [
        base / imp,
        base / imp / "__init__.py",
        base / imp / "index.js",
        base / imp / "index.ts",
        Path(f"{base}/{imp}.py"),
        Path(f"{base}/{imp}.js"),
        Path(f"{base}/{imp}.ts"),
        Path(f"{base}/{imp}.sh"),
    ]
    for c in candidates:
        try:
            resolved = c.resolve()
            if resolved.exists() and resolved.is_file():
                return resolved
        except OSError:
            continue
    return None


# ---- Cache ------------------------------------------------------------------

CACHE_DIR_NAME = ".cache/repo-map-cache"


def _load_cache(cache_dir: Path) -> dict:
    cache_file = cache_dir / "symbols.json"
    if cache_file.exists():
        try:
            return json.loads(cache_file.read_text())
        except (json.JSONDecodeError, OSError):
            pass
    return {}


def _save_cache(cache_dir: Path, cache: dict) -> None:
    cache_dir.mkdir(parents=True, exist_ok=True)
    (cache_dir / "symbols.json").write_text(json.dumps(cache, indent=2))


def _get_file_mtime(path: Path) -> float:
    try:
        return path.stat().st_mtime
    except OSError:
        return 0.0


# ---- PageRank ----------------------------------------------------------------

def page_rank(
    graph: dict[str, set[str]],
    damping: float = 0.85,
    max_iter: int = 100,
    tol: float = 1e-6,
) -> dict[str, float]:
    """Compute PageRank over a directed graph of file paths."""
    nodes = set(graph.keys()) | {n for v in graph.values() for n in v}
    if not nodes:
        return {}

    n = len(nodes)
    node_list = list(nodes)
    idx = {node: i for i, node in enumerate(node_list)}

    # Build adjacency matrix (sparse: list of outgoing indices per node)
    out_links = {i: [idx[neighbor] for neighbor in graph.get(node, set())
                     if neighbor in idx]
                 for i, node in enumerate(node_list)}

    # Handle dangling nodes (no outgoing links)
    dangling = [i for i, links in out_links.items() if not links]
    is_dangling = [i in dangling for i in range(n)]

    # Initialize
    rank = [1.0 / n] * n
    teleport = (1.0 - damping) / n

    for _ in range(max_iter):
        prev = rank[:]
        # Distribute dangling rank evenly
        dangling_sum = sum(rank[i] for i in dangling) / n if dangling else 0

        for i in range(n):
            rank[i] = teleport + damping * (
                dangling_sum +
                sum(prev[j] / max(len(out_links[j]), 1)
                    for j in range(n) if i in out_links[j])
            )

        # Check convergence
        diff = sum(abs(rank[i] - prev[i]) for i in range(n))
        if diff < tol:
            break

    return {node_list[i]: rank[i] for i in range(n)}


# ---- Main --------------------------------------------------------------------

def main() -> None:
    args = sys.argv[1:]

    if any(a in ("--help", "-h") for a in args):
        print("Usage: python3 repo-map.py [root-dir] [--max-tokens N] [--no-headings] [--no-symbols]")
        print("  --max-tokens N    Token budget for output (default: 2048)")
        print("  --no-headings     Skip markdown headings")
        print("  --no-symbols      Skip code symbols")
        sys.exit(0)

    # Parse args
    root = Path.cwd()
    max_tokens = 2048
    show_headings = True
    show_symbols = True

    positional = []
    skip_next = False
    for i, a in enumerate(args):
        if skip_next:
            skip_next = False
            continue
        if a == "--no-headings":
            show_headings = False
        elif a == "--no-symbols":
            show_symbols = False
        elif a.startswith("--max-tokens="):
            max_tokens = int(a.split("=", 1)[1])
        elif a == "--max-tokens" and i + 1 < len(args):
            max_tokens = int(args[i + 1])
            skip_next = True
        else:
            positional.append(a)

    if positional:
        root = Path(positional[0]).resolve()

    t0 = time.time()

    # 1. Discover files
    files = _workspace_files.list_text_files(root)
    print(f"Files scanned: {len(files)}", file=sys.stderr)

    # 2. Extract symbols and build dependency graph
    cache_dir = root / CACHE_DIR_NAME
    cache = _load_cache(cache_dir)

    all_symbols: dict[str, list[Symbol]] = {}
    import_pairs: list[tuple[str, str]] = []  # (source, target)
    parsed_count = 0
    cached_count = 0

    for f in files:
        rel = str(f.relative_to(root))
        mtime = _get_file_mtime(f)
        ext = f.suffix.lower()

        # Check cache
        cached = cache.get(rel)
        if cached and cached.get("mtime") == mtime:
            all_symbols[rel] = [Symbol(**s) for s in cached.get("symbols", [])]
            # Collect cached imports too (for dep graph)
            for imp in cached.get("imports", []):
                resolved = _resolve_import(imp, f, root)
                if resolved:
                    target_rel = str(resolved.relative_to(root))
                    import_pairs.append((rel, target_rel))
            cached_count += 1
            continue

        # Read file
        try:
            text = f.read_text("utf-8", errors="replace")
        except OSError:
            continue

        # Extract symbols
        symbols: list[Symbol] = []
        lang = _get_lang(ext)
        if lang:
            symbols = _extract_symbols_tree_sitter(text, lang)
        if not symbols:
            symbols = _extract_symbols_regex(text)
        if ext == ".md":
            symbols = _extract_headings(text)

        all_symbols[rel] = symbols

        # Extract imports (for dep graph)
        imports = _get_imports(text, ext)
        for imp in imports:
            resolved = _resolve_import(imp, f, root)
            if resolved:
                target_rel = str(resolved.relative_to(root))
                import_pairs.append((rel, target_rel))

        # Update cache
        cache[rel] = {
            "mtime": mtime,
            "symbols": [s._asdict() for s in symbols],
            "imports": imports,
        }
        parsed_count += 1

    _save_cache(cache_dir, cache)

    # 3. Build dependency graph
    graph: dict[str, set[str]] = defaultdict(set)
    for src, tgt in import_pairs:
        graph[src].add(tgt)

    # 4. PageRank
    pr_scores = page_rank(graph)
    if not pr_scores:
        # Fallback: equal weight to all files with symbols
        for rel in all_symbols:
            if all_symbols[rel]:
                pr_scores[rel] = 1.0

    # 5. Rank files by PageRank score, then by number of symbols
    scored_files = []
    for rel, symbols in all_symbols.items():
        if not symbols:
            continue
        score = pr_scores.get(rel, 0)
        scored_files.append((rel, score, symbols))

    scored_files.sort(key=lambda x: (-x[1], -len(x[2])))

    # 6. Format output within token budget
    output_lines: list[str] = []
    output_lines.append(f"# Repo Map")
    output_lines.append(f"")
    output_lines.append(f"Root: {root}")
    output_lines.append(f"Files indexed: {len(files)}")
    output_lines.append(f"Symbols: {sum(len(s) for _, _, s in scored_files)}")
    output_lines.append(f"")

    est_tokens = len("\n".join(output_lines)) // 4  # rough estimate
    remaining = max_tokens - est_tokens

    for rel, score, symbols in scored_files:
        if remaining <= 0:
            break

        # Score indicator
        has_imports = rel in graph and graph[rel]
        score_mark = "★" if score > 0.01 else "·"
        imp_mark = " ⤴" if has_imports else ""

        # File header
        header = f"{score_mark} {rel}{imp_mark}"
        header_tokens = len(header) // 4 + 1
        if header_tokens > remaining:
            break
        output_lines.append(header)
        remaining -= header_tokens

        # Rank-ordered symbols for this file (limit to 5)
        sym_lines = []
        for sym in symbols[:8]:
            kind_str = sym.kind.replace("H", "#")
            sym_line = f"    {kind_str}: {sym.name}"
            sym_tokens = len(sym_line) // 4 + 1
            if sym_tokens <= remaining:
                sym_lines.append(sym_line)
                remaining -= sym_tokens

        output_lines.extend(sym_lines)

    # Print output
    print("\n".join(output_lines))

    elapsed = time.time() - t0
    print(f"\n# Map: {parsed_count} parsed, {cached_count} cached ({elapsed:.1f}s)",
          file=sys.stderr)


if __name__ == "__main__":
    main()
