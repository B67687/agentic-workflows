#!/usr/bin/env python3
"""
Repo Map — tree-sitter + PageRank codebase map generator.

Generates a ranked, token-budgeted map of the codebase by:
1. Parsing each file with tree-sitter to extract symbols (definitions, references)
2. Building a dependency graph (file A → file B when A references B's symbols)
3. Running PageRank to rank files by importance
4. Rendering ranked files with key symbol context within a token budget

Usage:
  ./scripts/repo-map.py                   # Generate repo map (auto-detect)
  ./scripts/repo-map.py --tokens 2048     # Custom token budget
  ./scripts/repo-map.py --root /path      # Custom root
  ./scripts/repo-map.py --chat file1.py   # Files currently in chat (higher rank)
  ./scripts/repo-map.py --mention ident   # Mentioned identifiers (higher rank)
  ./scripts/repo-map.py --refresh         # Force refresh all caches
  ./scripts/repo-map.py --output          # Print to stdout
"""

import argparse
import json
import os
import sqlite3
import sys
import time
from collections import Counter, defaultdict
from pathlib import Path
from typing import Optional

try:
    from tree_sitter import Language, Parser, Query
    HAS_TS = True
except ImportError:
    HAS_TS = False

try:
    import networkx as nx
    HAS_NX = True
except ImportError:
    HAS_NX = False


# Languages supported with tag queries
LANGUAGE_QUERIES = {
    "python": """
        (function_definition name: (identifier) @name.definition.function)
        (class_definition name: (identifier) @name.definition.class)
        (decorated_definition name: (identifier) @name.definition.function)
        (call function: (identifier) @name.reference.call)
    """,
    "javascript": """
        (function_declaration name: (identifier) @name.definition.function)
        (method_definition name: (property_identifier) @name.definition.method)
        (arrow_function name: (identifier) @name.definition.function)
        (class_declaration name: (identifier) @name.definition.class)
        (call_expression function: (identifier) @name.reference.call)
        (variable_declarator name: (identifier) @name.definition.variable)
    """,
    "typescript": """
        (function_declaration name: (identifier) @name.definition.function)
        (method_definition name: (property_identifier) @name.definition.method)
        (class_declaration name: (identifier) @name.definition.class)
        (interface_declaration name: (type_identifier) @name.definition.interface)
        (type_alias_declaration name: (type_identifier) @name.definition.type)
        (call_expression function: (identifier) @name.reference.call)
    """,
    "rust": """
        (function_item name: (identifier) @name.definition.function)
        (struct_item name: (type_identifier) @name.definition.struct)
        (enum_item name: (type_identifier) @name.definition.enum)
        (trait_item name: (type_identifier) @name.definition.trait)
        (impl_item name: (type_identifier) @name.definition.impl)
        (call_expression function: (identifier) @name.reference.call)
    """,
    "bash": """
        (function_definition name: (word) @name.definition.function)
        (command name: (command_name) @name.reference.call)
    """,
    "go": """
        (function_declaration name: (identifier) @name.definition.function)
        (method_declaration name: (field_identifier) @name.definition.method)
        (type_declaration (type_spec name: (type_identifier) @name.definition.type))
        (call_expression function: (identifier) @name.reference.call)
    """,
}

# File extension to language mapping
EXTENSION_MAP = {
    ".py": "python",
    ".js": "javascript",
    ".jsx": "javascript",
    ".ts": "typescript",
    ".tsx": "typescript",
    ".rs": "rust",
    ".sh": "bash",
    ".bash": "bash",
    ".go": "go",
}

# Directories to always ignore
IGNORE_DIRS = {
    "node_modules", ".git", "__pycache__", ".venv", "venv",
    "dist", "build", "target", ".cache", ".tap",
}


class RepoMap:
    """Generates ranked codebase maps using tree-sitter + PageRank."""

    def __init__(
        self,
        root: str = ".",
        map_tokens: int = 1024,
        refresh: bool = False,
        chat_files: list[str] = None,
        mentioned_idents: list[str] = None,
    ):
        self.root = Path(root).resolve()
        self.max_map_tokens = map_tokens
        self.refresh = refresh
        self.chat_files = set(chat_files or [])
        self.mentioned_idents = set(mentioned_idents or [])
        self.cache_dir = self.root / ".repo-map.cache"
        self.cache_db = self.cache_dir / "tags.db"

        if HAS_TS:
            self.init_parser()

    def init_parser(self):
        """Initialize tree-sitter parsers for supported languages."""
        self.parsers = {}
        self.languages = {}

        for lang in LANGUAGE_QUERIES:
            try:
                # Try to load tree-sitter language
                lang_module = __import__(f"tree_sitter_{lang}", fromlist=["language"])
                language = Language(lang_module.language())
                parser = Parser(language)
                self.parsers[lang] = parser
                self.languages[lang] = language
            except ImportError:
                pass  # Language not available, skip

    def get_language(self, filepath: Path) -> Optional[str]:
        """Detect language from file extension."""
        return EXTENSION_MAP.get(filepath.suffix.lower())

    def extract_tags(self, filepath: Path) -> list[tuple]:
        """Extract tags (symbol definitions and references) from a file using tree-sitter."""
        lang = self.get_language(filepath)
        if not lang or lang not in self.parsers:
            return []

        try:
            code = filepath.read_text(encoding="utf-8", errors="replace")
        except Exception:
            return []

        parser = self.parsers[lang]
        language = self.languages[lang]

        try:
            tree = parser.parse(bytes(code, "utf-8"))
            query = Query(language, LANGUAGE_QUERIES[lang])
            captures = query.captures(tree.root_node)
        except Exception:
            return []

        tags = []
        for node, tag_name in captures:
            try:
                name = node.text.decode("utf-8")
                line = node.start_point[0]
                if tag_name.startswith("name.definition."):
                    kind = "def"
                elif tag_name.startswith("name.reference."):
                    kind = "ref"
                else:
                    continue
                tags.append((name, kind, line, str(filepath)))
            except Exception:
                continue

        return tags

    def walk_files(self) -> list[Path]:
        """Walk repository and collect all source files."""
        files = []
        for ext in EXTENSION_MAP:
            files.extend(self.root.rglob(f"*{ext}"))

        # Filter ignored directories
        filtered = []
        for f in files:
            parts = f.relative_to(self.root).parts
            if any(d in parts for d in IGNORE_DIRS):
                continue
            if f.is_file():
                filtered.append(f)
        return sorted(filtered)

    def get_tags_cached(self, filepath: Path) -> list[tuple]:
        """Get tags with disk caching for performance."""
        if self.refresh:
            return self.extract_tags(filepath)

        rel_path = str(filepath.relative_to(self.root))
        mtime = filepath.stat().st_mtime

        if self.cache_db.exists():
            try:
                conn = sqlite3.connect(str(self.cache_db))
                conn.row_factory = sqlite3.Row
                cursor = conn.execute(
                    "SELECT mtime, tags_json FROM tag_cache WHERE path = ?",
                    (rel_path,),
                )
                row = cursor.fetchone()
                conn.close()

                if row and row["mtime"] == mtime:
                    return json.loads(row["tags_json"])
            except Exception:
                pass

        # Cache miss — extract and store
        tags = self.extract_tags(filepath)
        self.cache_dir.mkdir(parents=True, exist_ok=True)

        try:
            conn = sqlite3.connect(str(self.cache_db))
            conn.execute(
                """CREATE TABLE IF NOT EXISTS tag_cache
                   (path TEXT PRIMARY KEY, mtime REAL, tags_json TEXT)"""
            )
            conn.execute(
                "INSERT OR REPLACE INTO tag_cache (path, mtime, tags_json) VALUES (?, ?, ?)",
                (rel_path, mtime, json.dumps(tags)),
            )
            conn.commit()
            conn.close()
        except Exception:
            pass

        return tags

    def build_graph(self, files: list[Path]) -> tuple:
        """Build a dependency graph and return ranked files."""
        if not HAS_NX:
            print("Warning: networkx not available, using frequency-based ranking", file=sys.stderr)
            return self._rank_by_frequency(files)

        defines = defaultdict(set)
        references = defaultdict(list)
        definitions = defaultdict(set)

        rel_files = set()
        for f in files:
            rel = str(f.relative_to(self.root))
            rel_files.add(rel)

            tags = self.get_tags_cached(f)
            for name, kind, line, path in tags:
                if kind == "def":
                    defines[name].add(rel)
                    definitions[(rel, name)].add((name, line, path))
                elif kind == "ref":
                    references[name].append(rel)

        if not references:
            references = dict((k, list(v)) for k, v in defines.items())

        idents = set(defines.keys()) & set(references.keys())

        G = nx.MultiDiGraph()

        for ident in idents:
            definers = defines[ident]
            mul = 1.0

            # Boost CamelCase and snake_case (likely significant symbols)
            is_snake = "_" in ident and any(c.isalpha() for c in ident)
            is_camel = any(c.isupper() for c in ident) and any(c.islower() for c in ident)
            if ident in self.mentioned_idents:
                mul *= 10
            if (is_snake or is_camel) and len(ident) >= 6:
                mul *= 2
            if ident.startswith("_"):
                mul *= 0.1
            if len(defines[ident]) > 5:
                mul *= 0.1

            for referencer, num_refs in Counter(references[ident]).items():
                for definer in definers:
                    use_mul = mul
                    if referencer in self.chat_files:
                        use_mul *= 20
                    num_refs_sqrt = num_refs ** 0.5
                    G.add_edge(referencer, definer, weight=use_mul * num_refs_sqrt, ident=ident)

        # Personalization: boost chat files and mentioned idents
        personalization = {}
        personalization_val = 100.0 / max(len(rel_files), 1)
        for rel_f in rel_files:
            if rel_f in self.chat_files:
                personalization[rel_f] = personalization_val
            else:
                # Check if any path component matches a mentioned ident
                path_parts = set(Path(rel_f).parts)
                basename = Path(rel_f).stem
                if path_parts & self.mentioned_idents or basename in self.mentioned_idents:
                    personalization[rel_f] = personalization_val

        if not G.nodes():
            return self._rank_by_frequency(files)

        try:
            if personalization:
                ranked = nx.pagerank(G, weight="weight", personalization=personalization)
            else:
                ranked = nx.pagerank(G, weight="weight")
        except (nx.PowerIterationFailedConvergence, ZeroDivisionError):
            return self._rank_by_frequency(files)

        # Distribute rank from source nodes to definitions
        ranked_defs = defaultdict(float)
        for src in G.nodes:
            src_rank = ranked.get(src, 0)
            out_edges = list(G.out_edges(src, data=True))
            total_weight = sum(d["weight"] for _, _, d in out_edges) or 1
            for _, dst, d in out_edges:
                ranked_defs[(dst, d["ident"])] += src_rank * d["weight"] / total_weight

        # Sort definitions by rank
        sorted_defs = sorted(ranked_defs.items(), key=lambda x: -x[1])

        # Deduplicate tags
        seen_tags = set()
        ranked_tags = []
        for (fname, _), rank in sorted_defs:
            for tag in definitions.get((fname, _), []):
                if tag not in seen_tags:
                    seen_tags.add(tag)
                    ranked_tags.append((fname, tag[0], tag[1]))

        # Add files without tags
        for fname in sorted(rel_files):
            if not any(t[0] == fname for t in ranked_tags):
                ranked_tags.append((fname, "", -1))

        return ranked_tags

    def _rank_by_frequency(self, files: list[Path]) -> list:
        """Fallback ranking using reference frequency."""
        tag_counts = Counter()
        file_tags = {}

        for f in files:
            rel = str(f.relative_to(self.root))
            tags = self.get_tags_cached(f)
            file_tags[rel] = tags
            tag_counts[rel] += len(tags)

        # Files in chat get boosted
        ranked = []
        for rel in sorted(tag_counts, key=lambda x: -tag_counts[x]):
            boost = 10000 if rel in self.chat_files else 0
            ranked.append((rel, "", -1))

        # Add files without tags
        all_rel = {str(f.relative_to(self.root)) for f in files}
        for rel in sorted(all_rel):
            if not any(r[0] == rel for r in ranked):
                ranked.append((rel, "", -1))

        return ranked

    def render_tags(self, tags: list) -> str:
        """Render ranked tags into a compact string."""
        if not tags:
            return ""

        output_lines = []
        current_file = None
        file_tags_map = defaultdict(list)

        for tag in tags:
            fname = tag[0]
            if tag[1]:
                file_tags_map[fname].append(f"{tag[1]}:{tag[2]}")
            else:
                if fname not in file_tags_map:
                    file_tags_map[fname] = []

        for fname, symbols in file_tags_map.items():
            output_lines.append(fname)
            for sym in symbols[:10]:  # Limit to 10 symbols per file
                sym_name, sym_line = sym.split(":")
                output_lines.append(f"  {sym_name} ({sym_line})")
            output_lines.append("")

        output = "\n".join(output_lines)

        # Truncate by token budget (rough: 4 chars ≈ 1 token)
        max_chars = self.max_map_tokens * 4
        if len(output) > max_chars:
            output = output[:max_chars] + "\n... (truncated)"

        return output

    def generate(self) -> str:
        """Generate the repo map."""
        files = self.walk_files()
        if not files:
            return ""

        rel_chat = {str(Path(f)) for f in self.chat_files}
        self.chat_files = rel_chat

        ranked_tags = self.build_graph(files)
        return self.render_tags(ranked_tags)


def main():
    parser = argparse.ArgumentParser(description="Generate a ranked codebase map")
    parser.add_argument("--tokens", type=int, default=1024, help="Token budget")
    parser.add_argument("--root", default=".", help="Repository root")
    parser.add_argument("--chat", nargs="*", default=[], help="Files currently in chat")
    parser.add_argument("--mention", nargs="*", default=[], help="Mentioned identifiers")
    parser.add_argument("--refresh", action="store_true", help="Force refresh caches")
    parser.add_argument("--output", action="store_true", help="Print to stdout")
    args = parser.parse_args()

    if not HAS_TS:
        print(
            "Warning: tree-sitter not installed. Install with:\n"
            "  pip install tree-sitter\n\n"
            "Falling back to file-listing mode (no dependency graph).",
            file=sys.stderr,
        )

    mapper = RepoMap(
        root=args.root,
        map_tokens=args.tokens,
        refresh=args.refresh,
        chat_files=args.chat,
        mentioned_idents=args.mention,
    )

    result = mapper.generate()
    if args.output or True:
        print(result)
    else:
        print(f"Generated repo map ({mapper.max_map_tokens} tokens)")
        print(result[:200] + "..." if len(result) > 200 else result)


if __name__ == "__main__":
    main()
