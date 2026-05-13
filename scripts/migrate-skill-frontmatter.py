#!/usr/bin/env python3
"""Migrate all SKILL.md frontmatter to agentskills.io spec-compliant format.

Moves custom fields (trigger-phrases, handoffs, companion-script) into 'metadata'
and adds standard fields (compatibility, allowed-tools, pattern, bundle).

Safe to re-run: idempotent. Only modifies files that need changes.

Usage:
    python3 scripts/migrate-skill-frontmatter.py              # migrate all skills
    python3 scripts/migrate-skill-frontmatter.py <name>       # migrate one skill
    python3 scripts/migrate-skill-frontmatter.py --dry-run    # preview only
"""

import re
import sys
import os
import yaml
import pathlib
import copy

SKILLS_DIR = pathlib.Path(__file__).resolve().parent.parent / "skills"

# Default allowed tools per pattern
PATTERN_TOOLS = {
    "tool-wrapper": "bash, read, grep, glob",
    "generator": "bash, read, write, grep",
    "reviewer": "bash, read, grep, glob, edit",
    "inversion": "bash, read",
    "pipeline": "bash, read, grep, glob, write, edit",
}

# Pattern mapping based on skill name/role
PATTERN_MAP = {
    "api-and-interface-design": "tool-wrapper",
    "browser-testing-with-devtools": "tool-wrapper",
    "source-driven-development": "tool-wrapper",
    "security-and-hardening": "tool-wrapper",
    "documentation-and-adrs": "generator",
    "spec-driven-development": "generator",
    "code-review-and-quality": "reviewer",
    "performance-optimization": "reviewer",
    "blast-radius": "reviewer",
    "code-simplification": "reviewer",
    "grill-me": "inversion",
    "structured-questioning": "inversion",
    "debugging-and-error-recovery": "pipeline",
    "test-driven-development": "pipeline",
    "incremental-implementation": "pipeline",
    "git-workflow-and-versioning": "pipeline",
    "implementation-planning": "pipeline",
    "shipping-and-launch": "pipeline",
    "ci-cd-and-automation": "pipeline",
    "deprecation-and-migration": "pipeline",
}

# Bundle mapping from manifest.json
BUNDLE_MAP = {
    "grill-me": "define", "idea-refine": "define", "divergent-ideation": "define",
    "spec-driven-development": "define", "structured-questioning": "define",
    "planning-and-task-breakdown": "define",
    "incremental-implementation": "build", "test-driven-development": "build",
    "source-driven-development": "build", "frontend-ui-engineering": "build",
    "api-and-interface-design": "build",
    "debugging-and-error-recovery": "verify", "code-review-and-quality": "verify",
    "code-simplification": "verify", "browser-testing-with-devtools": "verify",
    "security-and-hardening": "verify", "performance-optimization": "verify",
    "git-workflow-and-versioning": "ship", "ci-cd-and-automation": "ship",
    "deprecation-and-migration": "ship", "documentation-and-adrs": "ship",
    "shipping-and-launch": "ship",
    "context-engineering": "meta", "doubt-driven-development": "meta",
    "skill-evaluator": "meta", "using-agent-skills": "meta", "bash-explore": "meta",
    "product-thinker": "product", "strategic-thinker": "product",
    "shaping-work": "product", "product-discovery": "product",
    "product-primitives": "product", "design-language": "product",
    "implementation-planning": "plan-technical",
    "loop-check": "assess", "tighten-loop": "assess", "tap-audit": "assess",
    "blast-radius": "assess", "systems-health": "assess",
    "retrospective": "assess", "curate-product-context": "assess",
}

SEPARATOR = "---"

CUSTOM_FIELDS = {"trigger-phrases", "trigger_phrases",
                 "handoffs", "companion-script", "companion_script"}

COMPATIBILITY = "claude-code, cursor, opencode, gemini-cli, codex-cli"


def parse_skill_md(path):
    """Parse SKILL.md into frontmatter dict and body string."""
    with open(path) as f:
        content = f.read()

    if not content.startswith(SEPARATOR):
        return None, content, content

    rest = content[3:].lstrip("\n\r")
    # Find closing separator on its own line
    end_idx = None
    for pattern in ["\n---\n", "\n---\r\n"]:
        idx = rest.find(pattern)
        if idx != -1:
            end_idx = idx + 1
            break

    if end_idx is None:
        return None, content, content

    fm_raw = rest[:end_idx]
    body = rest[end_idx + 4:]

    try:
        frontmatter = yaml.safe_load(fm_raw)
    except yaml.YAMLError:
        return None, content, content

    if not isinstance(frontmatter, dict):
        frontmatter = {}

    return frontmatter, body, content


def build_new_frontmatter(fm, skill_name):
    """Build spec-compliant frontmatter dict from old one."""
    nfm = {}

    # Required fields
    nfm["name"] = fm.get("name", skill_name)
    nfm["description"] = fm.get("description", "")

    # Standard optional fields
    nfm["compatibility"] = COMPATIBILITY

    tools = PATTERN_TOOLS.get(PATTERN_MAP.get(skill_name, ""), "bash, read, grep, glob")
    nfm["allowed-tools"] = tools

    # Build metadata from custom fields
    metadata = {}
    for field in sorted(CUSTOM_FIELDS):
        if field in fm and fm[field]:
            canonical = field.replace("_", "-")
            metadata[canonical] = str(fm[field])

    # Add pattern and bundle
    pattern = PATTERN_MAP.get(skill_name)
    if pattern:
        metadata["pattern"] = pattern
    bundle = BUNDLE_MAP.get(skill_name)
    if bundle:
        metadata["bundle"] = bundle

    # Preserve any existing metadata
    existing_meta = fm.get("metadata", {})
    if isinstance(existing_meta, dict):
        for k, v in existing_meta.items():
            if k not in metadata:
                metadata[k] = v

    if metadata:
        nfm["metadata"] = metadata

    return nfm


def frontmatter_to_yaml(fm):
    """Convert frontmatter dict to clean YAML string with frontmatter delimiters."""
    yaml_str = yaml.dump(fm, default_flow_style=False, allow_unicode=True,
                         sort_keys=False, width=200)
    return f"{SEPARATOR}\n{yaml_str}{SEPARATOR}\n"


def migrate_skill(skill_dir, dry_run=False):
    """Migrate a single skill. Returns (changed, messages)."""
    messages = []
    name = skill_dir.name
    skill_md = skill_dir / "SKILL.md"

    if not skill_md.exists():
        return False, ["SKILL.md not found"]

    fm, body, original = parse_skill_md(skill_md)
    if fm is None:
        return False, ["Cannot parse frontmatter"]

    # Check if migration is needed
    has_custom = any(f in fm for f in CUSTOM_FIELDS)
    needs_compat = "compatibility" not in fm
    needs_tools = "allowed-tools" not in fm and "allowed_tools" not in fm
    needs_metadata_update = False

    existing_meta = fm.get("metadata", {})
    if isinstance(existing_meta, dict):
        pattern = PATTERN_MAP.get(name)
        bundle = BUNDLE_MAP.get(name)
        if pattern and existing_meta.get("pattern") != pattern:
            needs_metadata_update = True
        if bundle and existing_meta.get("bundle") != bundle:
            needs_metadata_update = True

    if not has_custom and not needs_compat and not needs_tools and not needs_metadata_update:
        return False, ["Already compliant"]

    # Build new frontmatter
    nfm = build_new_frontmatter(fm, name)

    new_yaml = frontmatter_to_yaml(nfm)
    new_content = new_yaml + body.lstrip("\n")

    if dry_run:
        messages.append(f"Would migrate: {skill_md.name}")
        removed = [f for f in CUSTOM_FIELDS if f in fm]
        if removed:
            messages.append(f"  Move to metadata: {removed}")
        if needs_compat:
            messages.append("  Add: compatibility")
        if needs_tools:
            messages.append("  Add: allowed-tools")
        return True, messages

    with open(skill_md, "w") as f:
        f.write(new_content)

    messages.append(f"Migrated: {skill_md.name}")
    return True, messages


def main():
    args = sys.argv[1:]
    dry_run = "--dry-run" in args or "-n" in args
    if dry_run:
        for flag in ("--dry-run", "-n"):
            if flag in args:
                args.remove(flag)

    target = args[0] if args else None

    if target:
        skill_dir = SKILLS_DIR / target
        if not skill_dir.exists():
            print(f"Skill '{target}' not found")
            sys.exit(1)
        dirs = [skill_dir]
    else:
        dirs = sorted(
            d for d in SKILLS_DIR.iterdir()
            if d.is_dir() and not d.name.startswith(".") and (d / "SKILL.md").exists()
        )

    changed = 0
    unchanged = 0

    for skill_dir in dirs:
        did_change, messages = migrate_skill(skill_dir, dry_run=dry_run)
        if did_change:
            changed += 1
            for msg in messages:
                print(f"  {msg}")
        else:
            if not any("Already compliant" in m for m in messages):
                print(f"  ✗ {skill_dir.name}: {'; '.join(messages)}")
            unchanged += 1

    mode = " [DRY RUN — no files changed]" if dry_run else ""
    print(f"\n---{mode}")
    print(f"Total: {len(dirs)}  Changed: {changed}  Unchanged: {unchanged}")

    if dry_run and changed:
        print(f"\nRun without --dry-run to apply {changed} migration(s).")

    return 0


if __name__ == "__main__":
    sys.exit(main())
