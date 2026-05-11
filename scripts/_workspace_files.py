#!/usr/bin/env python3
"""
_workspace_files.py — Shared utility: list text files in a workspace.

Used by build-index.py, repo-map.py, and any other script that needs
to discover text files to process. Respects a hardcoded ignore-dir set
plus optional .gitignore if requested.

Usage:
    from _workspace_files import list_text_files, ignore_dirs, text_exts
    files = list_text_files(root_path)
"""

import sys
from pathlib import Path

# Directories to skip entirely (hardcoded for speed + safety)
ignore_dirs: set[str] = {
    ".git", ".hg", ".svn",
    ".cache", ".pytest_cache", ".mypy_cache", ".ruff_cache",
    ".venv", "venv", "env",
    "node_modules",
    "__pycache__",
    "dist", "build", "target",
    ".next", ".turbo",
    ".opencode", ".pi",
    ".aider", ".gitpod",
    ".vscode", ".idea",
    ".dart_tool", ".packages",
    # Generated / derived content (mirrors of originals)
    "raw", "state", "archive",
}

# File extensions treated as text (parsable for search/indexing)
text_exts: set[str] = {
    # Documentation / config
    ".md", ".txt", ".rst", ".adoc",
    ".json", ".jsonc", ".jsonl",
    ".yaml", ".yml", ".toml",
    ".ini", ".cfg", ".conf",
    ".xml", ".svg", ".html", ".css", ".scss", ".less",
    # Scripts / code
    ".py", ".js", ".jsx", ".ts", ".tsx", ".mjs", ".cjs",
    ".go", ".rs", ".java", ".kt", ".cs",
    ".cpp", ".c", ".h", ".hpp", ".cxx", ".hxx", ".cc", ".hh",
    ".sh", ".ps1", ".bash", ".zsh", ".fish",
    ".rb", ".php", ".swift", ".scala", ".r", ".jl",
    # Build / tooling
    ".gradle", ".bazel", ".bzl", ".rules",
    ".sql", ".lock",
    # Other text
    ".env", ".gitignore", ".gitattributes",
    ".editorconfig", ".prettierrc",
}


def is_ignored(path: Path) -> bool:
    """Check if any component of the path is in the ignore set."""
    return any(part in ignore_dirs for part in path.parts)


def is_text_file(path: Path) -> bool:
    """Check if the file extension is in the text set."""
    return path.suffix.lower() in text_exts


def list_text_files(root: Path, respect_gitignore: bool = False) -> list[Path]:
    """
    Walk *root* recursively and return sorted list of text files.

    Ignores directories in *ignore_dirs*.  Optionally also consults
    ``.gitignore`` (expensive — do not enable for large trees on every
    build).
    """
    if not root.is_dir():
        raise NotADirectoryError(f"{root} is not a directory")

    files: list[Path] = []
    for p in root.rglob("*"):
        if is_ignored(p):
            continue
        if p.is_file() and is_text_file(p):
            files.append(p)

    if respect_gitignore and (root / ".gitignore").exists():
        import pathspec
        with open(root / ".gitignore") as fh:
            spec = pathspec.PathSpec.from_lines("gitwildmatch", fh)
        files = [f for f in files if not spec.match_file(str(f.relative_to(root)))]

    return sorted(files)


# ---- CLI entry point ----
if __name__ == "__main__":
    root = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()
    for f in list_text_files(root):
        print(f)
