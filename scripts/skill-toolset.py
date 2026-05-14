#!/usr/bin/env python3
"""Progressive disclosure toolset --- L1/L2/L3 skill loading.

Implements the three-tier information model from the Agent Skills specification:

  L1 --- Metadata:  skill names and descriptions (~100 tokens each)
  L2 --- Full load: complete SKILL.md instructions
  L3 --- Resource:  specific files from references/, assets/, or scripts/

Usage:
    python3 scripts/skill-toolset.py list                   # L1 --- names + descriptions
    python3 scripts/skill-toolset.py list --compact         # L1 --- one line per skill
    python3 scripts/skill-toolset.py list --json            # L1 --- machine-readable JSON
    python3 scripts/skill-toolset.py list --active          # filter: active only
    python3 scripts/skill-toolset.py list --deprecated      # filter: deprecated only
    python3 scripts/skill-toolset.py list --archived        # filter: archived only
    python3 scripts/skill-toolset.py load <name>            # L2 --- full SKILL.md
    python3 scripts/skill-toolset.py resource <name> <path> # L3 --- specific file
    python3 scripts/skill-toolset.py find <query>           # search by name/desc/pattern
    python3 scripts/skill-toolset.py info <name>            # detail for one skill (all metadata)
"""

import json
import os
import pathlib
import sys
import yaml

SKILLS_DIR = pathlib.Path(__file__).resolve().parent.parent / "skills"

# Colors (disabled if piped or non-interactive)
USE_COLOR = sys.stdout.isatty()
GREEN = "\033[32m" if USE_COLOR else ""
CYAN = "\033[36m" if USE_COLOR else ""
YELLOW = "\033[33m" if USE_COLOR else ""
DIM = "\033[2m" if USE_COLOR else ""
RESET = "\033[0m" if USE_COLOR else ""


def get_skill_dirs():
    """Return sorted list of skill directories with SKILL.md."""
    return sorted(
        d for d in SKILLS_DIR.iterdir()
        if d.is_dir() and not d.name.startswith(".") and (d / "SKILL.md").exists()
    )


def parse_frontmatter(skill_dir):
    """Parse frontmatter from skill's SKILL.md. Returns dict or None."""
    path = skill_dir / "SKILL.md"
    content = path.read_text(encoding="utf-8")

    if not content.startswith("---"):
        return None

    rest = content[3:].lstrip("\n\r")
    for pattern in ["\n---\n", "\n---\r\n"]:
        idx = rest.find(pattern)
        if idx != -1:
            fm_raw = rest[:idx + 1]
            break
    else:
        return None

    try:
        fm = yaml.safe_load(fm_raw)
        return fm if isinstance(fm, dict) else None
    except yaml.YAMLError:
        return None


def cmd_list(args):
    """L1 --- names and descriptions (compact by default for agent consumption)."""
    compact = "--compact" in args or len(args) == 0
    as_json = "--json" in args
    show_all = "--all" in args or "-a" in args

    dirs = get_skill_dirs()
    results = []

    for d in dirs:
        fm = parse_frontmatter(d)
        if not fm:
            continue
        meta = fm.get("metadata", {}) or {}
        results.append({
            "name": fm.get("name", d.name),
            "description": fm.get("description", ""),
            "pattern": meta.get("pattern", ""),
            "bundle": meta.get("bundle", ""),
            "status": fm.get("status", "active"),
            "companion_script": meta.get("companion-script", ""),
        })

    # Filter by status if requested
    status_filter = None
    for a in args:
        if a.startswith("--status="):
            status_filter = a.split("=", 1)[1]
        elif a == "--deprecated":
            status_filter = "deprecated"
        elif a == "--archived":
            status_filter = "archived"
        elif a == "--active":
            status_filter = "active"
    if status_filter:
        results = [r for r in results if r.get("status") == status_filter]

    if as_json:
        print(json.dumps(results, indent=2))
        return

    if not results:
        print("No skills found.")
        return

    # L1 header
    print(f"{CYAN}SKILLS ── L1 metadata ({len(results)} skills, ~100 tokens each){RESET}")
    print(f"{DIM}Use: skill-toolset load <name> for L2 instructions{RESET}")
    print()

    # Compact list
    if compact:
        # Name runs, pattern and bundle are abbreviated, description is trimmed
        name_w = max(len(r["name"]) for r in results) + 2
        for r in results:
            pat = f"[{r['pattern']}]" if r["pattern"] else ""
            bun = f"({r['bundle']})" if r["bundle"] else ""
            sts = f"{{{r['status']}}}" if r["status"] != "active" else ""
            tags = f"{pat:14s} {bun:10s} {sts:14s}" if pat or bun or sts else ""
            desc = r["description"]
            # Trim long descriptions for compact mode
            max_desc = 70 - len(tags)
            if len(desc) > max_desc:
                desc = desc[:max_desc - 3] + "..."
            print(f"  {r['name']:{name_w}s}{tags}{DIM}{desc}{RESET}")
        return

    # Full list
    for r in results:
        print(f"\n  {GREEN}{r['name']}{RESET}")
        if r["pattern"]:
            print(f"    Pattern: {r['pattern']}   Bundle: {r['bundle']}")
        print(f"    {DIM}{r['description']}{RESET}")
        if r["companion_script"]:
            print(f"    Companion: {r['companion_script']}")
    print(f"\n{DIM}Total: {len(results)} skills{RESET}")


def cmd_load(args):
    """L2 --- load full SKILL.md for a named skill."""
    if not args:
        print("Usage: skill-toolset load <name>")
        sys.exit(1)

    name = args[0]
    skill_dir = SKILLS_DIR / name

    if not skill_dir.exists() or not (skill_dir / "SKILL.md").exists():
        print(f"Skill '{name}' not found.")
        sys.exit(1)

    # Output the full SKILL.md body (stripping frontmatter for cleaner context)
    content = (skill_dir / "SKILL.md").read_text(encoding="utf-8")

    # Strip frontmatter --- agent only needs the body
    if content.startswith("---"):
        rest = content[3:].lstrip("\n\r")
        for pattern in ["\n---\n", "\n---\r\n"]:
            idx = rest.find(pattern)
            if idx != -1:
                content = rest[idx + 4:]  # skip past closing ---
                break

    print(content.strip())


def cmd_resource(args):
    """L3 --- load a specific resource file from a skill."""
    if len(args) < 2:
        print("Usage: skill-toolset resource <name> <path>")
        sys.exit(1)

    name = args[0]
    resource_path = args[1]
    # Strip any SKILLS_DIR prefix for safety
    resource_path = resource_path.replace(str(SKILLS_DIR) + "/", "", 1)

    skill_dir = SKILLS_DIR / name

    if not skill_dir.exists():
        print(f"Skill '{name}' not found.")
        sys.exit(1)

    # Resolve the resource --- allow paths relative to skill dir or absolute within skills
    candidates = [
        skill_dir / resource_path,
    ]

    for prefix in ["", "references/", "assets/", "scripts/"]:
        candidates.append(skill_dir / prefix / resource_path)

    found = None
    for c in candidates:
        resolved = c.resolve()
        # Security: ensure resolved path is within the skill directory
        if resolved.exists() and str(resolved).startswith(str(skill_dir.resolve())):
            found = resolved
            break

    if not found:
        print(f"Resource '{resource_path}' not found in skill '{name}'.")
        print(f"Searched: {[str(c) for c in candidates]}")
        sys.exit(1)

    print(found.read_text(encoding="utf-8").strip())


def cmd_find(args):
    """Search skills by name, description, pattern, or bundle."""
    if not args:
        print("Usage: skill-toolset find <query>")
        sys.exit(1)

    query = " ".join(args).lower()
    dirs = get_skill_dirs()
    matches = []

    for d in dirs:
        fm = parse_frontmatter(d)
        if not fm:
            continue
        meta = fm.get("metadata", {}) or {}
        name = fm.get("name", d.name)
        desc = (fm.get("description") or "").lower()
        pattern = (meta.get("pattern") or "").lower()
        bundle = (meta.get("bundle") or "").lower()
        trigger = (meta.get("trigger-phrases") or meta.get("trigger_phrases") or "").lower()

        haystack = f"{name.lower()} {desc} {pattern} {bundle} {trigger}"
        if query in haystack:
            matches.append({
                "name": name,
                "description": fm.get("description", ""),
                "pattern": meta.get("pattern", ""),
                "bundle": meta.get("bundle", ""),
            })

    if not matches:
        print(f"No skills match '{query}'.")
        sys.exit(1)

    print(f"{CYAN}Skills matching '{query}':{RESET}")
    for r in matches:
        pat = f" [{r['pattern']}]" if r["pattern"] else ""
        print(f"  {GREEN}{r['name']}{RESET}{pat}")
        print(f"    {DIM}{r['description']}{RESET}")
    print(f"\n{DIM}{len(matches)} matches{RESET}")


def cmd_info(args):
    """Show detailed metadata for a single skill."""
    if not args:
        print("Usage: skill-toolset info <name>")
        sys.exit(1)

    name = args[0]
    skill_dir = SKILLS_DIR / name
    if not skill_dir.exists():
        print(f"Skill '{name}' not found.")
        sys.exit(1)

    fm = parse_frontmatter(skill_dir)
    if not fm:
        print(f"Cannot parse frontmatter for '{name}'.")
        sys.exit(1)

    meta = fm.get("metadata", {}) or {}
    print(f"{GREEN}{fm.get('name', name)}{RESET}")
    print(f"  Description: {fm.get('description', '')}")
    print(f"  Compatibility: {fm.get('compatibility', 'N/A')}")
    print(f"  Allowed tools: {fm.get('allowed-tools', 'N/A')}")
    print(f"  Pattern: {meta.get('pattern', 'N/A')}")
    print(f"  Bundle: {meta.get('bundle', 'N/A')}")
    print(f"  Trigger phrases: {meta.get('trigger-phrases', 'N/A')}")
    print(f"  Handoffs: {meta.get('handoffs', 'N/A')}")
    if meta.get("companion-script"):
        print(f"  Companion script: {meta['companion-script']}")
    # Show directory structure
    dirs_present = [p.name for p in skill_dir.iterdir() if p.is_dir()]
    if dirs_present:
        print(f"  Subdirs: {', '.join(sorted(dirs_present))}")
    refs = sorted(skill_dir.glob("**/*")) if (skill_dir / "references").exists() else []
    if refs:
        print(f"  References: {len(refs)} files")


def main():
    if len(sys.argv) < 2:
        print(__doc__.strip())
        sys.exit(1)

    command = sys.argv[1]
    args = sys.argv[2:]

    commands = {
        "list": cmd_list,
        "load": cmd_load,
        "resource": cmd_resource,
        "find": cmd_find,
        "info": cmd_info,
    }

    if command not in commands:
        print(f"Unknown command: {command}")
        print(f"Available: {', '.join(commands.keys())}")
        sys.exit(1)

    commands[command](args)


if __name__ == "__main__":
    main()
