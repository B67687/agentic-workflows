#!/usr/bin/env python3
"""Validate all SKILL.md frontmatter against the agentskills.io specification.

Usage:
    python3 scripts/validate-skill-frontmatter.py              # validate all skills
    python3 scripts/validate-skill-frontmatter.py <name>       # validate one skill
    python3 scripts/validate-skill-frontmatter.py --fix        # fix non-compliance warnings

Validates:
  - name: kebab-case, <=64 chars, matches directory name
  - description: non-empty, <=1024 chars
  - No unrecognized top-level fields (all custom fields under metadata)
  - compatibility: <=500 chars if present
  - allowed-tools: string type if present
"""

import re
import sys
import os
import yaml
import pathlib

SKILLS_DIR = pathlib.Path(__file__).resolve().parent.parent / "skills"

ALLOWED_TOP_LEVEL = {"name", "description", "license", "compatibility",
                     "metadata", "allowed-tools", "allowed_tools"}

NAME_PATTERN = re.compile(r'^[a-z0-9]+(-[a-z0-9]+)*$')


def parse_skill_md(path):
    """Parse SKILL.md into frontmatter dict and body string.

    Properly handles YAML frontmatter even when the content contains '---'
    by finding the closing delimiter on its own line.
    """
    with open(path) as f:
        content = f.read()

    if not content.startswith("---"):
        return None, content

    # Find the closing '---' that is on its own line (start of line, optional \r)
    # Skip the opening ---
    rest = content[3:].lstrip("\n\r")
    end_idx = None
    # Look for \n---\n or \n---\r\n at the start of a line
    for pattern in ["\n---\n", "\n---\r\n"]:
        idx = rest.find(pattern)
        if idx != -1:
            end_idx = idx + 1  # include the leading \n
            break

    if end_idx is None:
        # Try end of file
        return None, content

    fm_raw = rest[:end_idx]
    body = rest[end_idx + 4:]  # skip the ---\n

    try:
        frontmatter = yaml.safe_load(fm_raw)
    except yaml.YAMLError as e:
        return {"_yaml_error": str(e)}, content

    return frontmatter if isinstance(frontmatter, dict) else {}, body


def validate_skill(skill_dir, fix=False):
    """Validate a single skill directory. Returns list of (type, message)."""
    results = []
    name = skill_dir.name
    skill_md = skill_dir / "SKILL.md"

    if not skill_md.exists():
        results.append(("ERROR", "SKILL.md not found"))
        return results

    fm, body = parse_skill_md(skill_md)
    if fm is None:
        results.append(("ERROR", "Cannot parse frontmatter (missing --- delimiters)"))
        return results

    if fm.get("_yaml_error"):
        results.append(("ERROR", f"YAML parse error: {fm['_yaml_error']}"))
        return results

    # --- name validation ---
    fm_name = fm.get("name", "")
    if not fm_name:
        results.append(("ERROR", "name is missing"))
    elif len(fm_name) > 64:
        results.append(("ERROR", f"name is {len(fm_name)} chars (max 64)"))
    elif not NAME_PATTERN.match(fm_name):
        results.append(("WARN", f"name '{fm_name}' is not valid kebab-case"))
    elif fm_name != name:
        results.append(("WARN", f"name '{fm_name}' doesn't match directory name '{name}'"))

    # --- description validation ---
    fm_desc = fm.get("description", "")
    if not fm_desc:
        results.append(("ERROR", "description is missing"))
    elif len(fm_desc) > 1024:
        results.append(("WARN", f"description is {len(fm_desc)} chars (max 1024)"))

    # --- unrecognized top-level fields ---
    custom_top = set(fm.keys()) - ALLOWED_TOP_LEVEL
    if custom_top:
        for field in sorted(custom_top):
            results.append(("WARN", f"non-standard top-level field '{field}' — should be under 'metadata'"))
        if fix:
            results.append(("FIX", f"Would move {sorted(custom_top)} into metadata"))

    # --- compatibility ---
    compat = fm.get("compatibility", "")
    if compat and len(compat) > 500:
        results.append(("WARN", f"compatibility is {len(compat)} chars (max 500)"))

    # --- allowed-tools ---
    allowed = fm.get("allowed-tools", fm.get("allowed_tools", None))
    if allowed is not None and not isinstance(allowed, str):
        results.append(("WARN", "allowed-tools should be a space-separated string"))

    # --- metadata contents (informational) ---
    metadata = fm.get("metadata", {})
    if isinstance(metadata, dict) and metadata:
        valid_meta_keys = {"trigger-phrases", "trigger_phrases", "handoffs",
                           "companion-script", "companion_script", "pattern",
                           "bundle", "author", "version"}
        unknown_meta = set(metadata.keys()) - valid_meta_keys
        if unknown_meta:
            results.append(("INFO", f"Unknown metadata keys: {sorted(unknown_meta)}"))

    return results


def main():
    args = sys.argv[1:]
    fix_mode = "--fix" in args
    if fix_mode:
        args.remove("--fix")

    target = args[0] if args else None

    if target:
        skill_dir = SKILLS_DIR / target
        if not skill_dir.exists():
            print(f"Skill '{target}' not found in {SKILLS_DIR}")
            sys.exit(1)
        dirs = [skill_dir]
    else:
        dirs = sorted(
            d for d in SKILLS_DIR.iterdir()
            if d.is_dir() and not d.name.startswith(".") and (d / "SKILL.md").exists()
        )

    total_errors = 0
    total_warns = 0
    total_fixes = 0
    all_valid = True

    for skill_dir in dirs:
        results = validate_skill(skill_dir, fix=fix_mode)
        name = skill_dir.name
        errors = [r for r in results if r[0] == "ERROR"]
        warns = [r for r in results if r[0] == "WARN"]
        fixes = [r for r in results if r[0] == "FIX"]
        infos = [r for r in results if r[0] == "INFO"]

        total_errors += len(errors)
        total_warns += len(warns)
        total_fixes += len(fixes)

        if errors or warns:
            all_valid = False
            status = "❌" if errors else "⚠️"
            print(f"\n{status} {name}")
            for r in errors:
                print(f"   ERROR  {r[1]}")
            for r in warns:
                print(f"   WARN   {r[1]}")
            for r in fixes:
                print(f"   FIX    {r[1]}")
            for r in infos:
                print(f"   INFO   {r[1]}")
        else:
            print(f"✅ {name}")

    print(f"\n---")
    print(f"Total: {len(dirs)} skills")
    if total_errors or total_warns:
        print(f"Errors: {total_errors}  Warnings: {total_warns}  Fixes available: {total_fixes}")
    else:
        print(f"All skills pass spec validation.")

    return 0 if all_valid else 1


if __name__ == "__main__":
    sys.exit(main())
