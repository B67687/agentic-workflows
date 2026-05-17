#!/usr/bin/env python3
"""
Skill Processor --- YAML frontmatter expansion + dynamic context injection.

Reads skills from the skills/ directory, processes their YAML frontmatter,
expands dynamic context injection (!`command` syntax), and generates a
discovery index for fast agent access.

Usage:
  ./scripts/skill-processor.py validate     # Validate all skill frontmatter
  ./scripts/skill-processor.py expand       # Expand !`command` in all skills
  ./scripts/skill-processor.py index        # Generate discovery index
  ./scripts/skill-processor.py list         # List all skills with metadata
  ./scripts/skill-processor.py check <name> # Check specific skill frontmatter
"""

import json
import os
import re
import subprocess
import sys
import yaml
from pathlib import Path
from typing import Any, Optional


SKILLS_DIR = Path(__file__).resolve().parent.parent / "skills"


# Required and optional frontmatter fields for validation
REQUIRED_FIELDS = {"name", "description"}
RECOMMENDED_FIELDS = {"trigger-phrases", "handoffs"}
OPTIONAL_FIELDS = {
    "companion-script",
    "allowed-tools",
    "context",
    "agent",
    "arguments",
    "disable-model-invocation",
    "paths",
    "when-to-use",
    "effort",
    "model",
    "shell",
    "hooks",
}

VALID_VALUES = {
    "context": {"fork", None},
    "shell": {"bash", "powershell", None},
    "effort": {"low", "medium", "high", "xhigh", "max", None},
}


def discover_skills() -> list[Path]:
    """Discover all SKILL.md files in the skills directory tree."""
    if not SKILLS_DIR.exists():
        print(f"Error: skills directory not found at {SKILLS_DIR}", file=sys.stderr)
        sys.exit(1)

    skill_files = []
    for path in SKILLS_DIR.rglob("SKILL.md"):
        skill_files.append(path)

    return sorted(skill_files)


def parse_frontmatter(content: str) -> tuple[Optional[dict], str]:
    """Parse YAML frontmatter from a skill file. Returns (frontmatter, body)."""
    content = content.lstrip("\n")
    if not content.startswith("---"):
        return None, content

    # Find closing ---
    end_idx = content.find("---", 3)
    if end_idx == -1:
        return None, content

    yaml_str = content[3:end_idx]
    body = content[end_idx + 3:].lstrip("\n")

    try:
        frontmatter = yaml.safe_load(yaml_str)
        if frontmatter is None:
            frontmatter = {}
        return frontmatter, body
    except yaml.YAMLError as e:
        print(f"  YAML parse error: {e}", file=sys.stderr)
        return None, content


def expand_dynamic_context(content: str, skill_dir: Path) -> str:
    """Expand !`command` dynamic context injection syntax.
    
    Replaces !`command` with the output of running the command.
    Expands ${CLAUDE_SKILL_DIR} to the skill directory path.
    """
    # First expand ${CLAUDE_SKILL_DIR} to the actual skill directory
    content = content.replace("${CLAUDE_SKILL_DIR}", str(skill_dir))

    # Match !`command` patterns (inline)
    inline_pattern = re.compile(r'!`([^`]+)`')
    
    def replace_inline(match):
        cmd = match.group(1)
        try:
            result = subprocess.run(
                cmd, shell=True, capture_output=True, text=True, timeout=30
            )
            output = result.stdout.strip()
            if result.returncode != 0:
                return f"[command failed: {cmd}]\n{result.stderr.strip()}"
            return output
        except subprocess.TimeoutExpired:
            return f"[command timed out: {cmd}]"
        except Exception as e:
            return f"[command error: {e}]"

    content = inline_pattern.sub(replace_inline, content)

    # Match multi-line ```! blocks
    block_pattern = re.compile(r'```!\n(.*?)```', re.DOTALL)
    
    def replace_block(match):
        cmd_block = match.group(1).strip()
        try:
            result = subprocess.run(
                cmd_block, shell=True, capture_output=True, text=True, timeout=30
            )
            output = result.stdout.strip()
            if result.returncode != 0:
                return f"```\n# command failed: {cmd_block}\n# {result.stderr.strip()}\n```"
            return f"```\n{output}\n```"
        except subprocess.TimeoutExpired:
            return f"```\n# command timed out: {cmd_block}\n```"
        except Exception as e:
            return f"```\n# command error: {e}\n```"

    content = block_pattern.sub(replace_block, content)
    return content


def validate_frontmatter(frontmatter: dict, skill_path: Path) -> list[str]:
    """Validate skill frontmatter and return list of issues."""
    issues = []
    name = frontmatter.get("name", skill_path.parent.name)

    # Check required fields
    for field in REQUIRED_FIELDS:
        if field not in frontmatter:
            issues.append(f"Missing required field: '{field}'")

    # Check recommended fields
    for field in RECOMMENDED_FIELDS:
        if field not in frontmatter:
            issues.append(f"Missing recommended field: '{field}'")

    # Validate allowed values
    for field, valid_values in VALID_VALUES.items():
        val = frontmatter.get(field)
        if val is not None and val not in valid_values:
            issues.append(
                f"Invalid value for '{field}': '{val}'. "
                f"Expected one of: {', '.join(str(v) for v in valid_values if v is not None)}"
            )

    # Check name matches directory name
    dir_name = skill_path.parent.name
    if frontmatter.get("name") and frontmatter["name"] != dir_name:
        issues.append(
            f"Name '{frontmatter['name']}' differs from directory name '{dir_name}'"
        )

    return issues


def cmd_validate():
    """Validate all skill frontmatter."""
    skills = discover_skills()
    total_issues = 0
    valid_count = 0

    for skill_path in skills:
        name = skill_path.parent.name
        content = skill_path.read_text()
        frontmatter, _ = parse_frontmatter(content)

        if frontmatter is None:
            print(f"  {name}: NO FRONTMATTER (missing YAML frontmatter)")
            total_issues += 1
            continue

        issues = validate_frontmatter(frontmatter, skill_path)
        if issues:
            print(f"  {name}: ISSUES ({len(issues)}):")
            for issue in issues:
                print(f"    - {issue}")
            total_issues += len(issues)
        else:
            valid_count += 1

    print(f"\nSummary: {valid_count} valid, {total_issues} issue(s) across {len(skills)} skills")
    return 0 if total_issues == 0 else 1


def cmd_expand():
    """Preview !`command` expansion without executing (dry-run mode)."""
    skills = discover_skills()
    for skill_path in skills:
        name = skill_path.parent.name
        content = skill_path.read_text()
        frontmatter, body = parse_frontmatter(content)

        # Find dynamic context injections
        inline_matches = re.findall(r'!`([^`]+)`', body)
        block_matches = re.findall(r'```!\n(.*?)```', body, re.DOTALL)

        if inline_matches or block_matches:
            print(f"\n  {name}:")
            for cmd in inline_matches:
                print(f"    !`{cmd}`")
            for cmd in block_matches:
                print(f"    ```!\n{cmd.strip()}\n    ```")

    print("\nNo commands executed. Use with caution in production.")
    return 0


def cmd_index():
    """Generate a skill discovery index as JSON."""
    skills = discover_skills()
    index = {
        "version": 1,
        "total": len(skills),
        "skills": [],
    }

    for skill_path in skills:
        content = skill_path.read_text()
        frontmatter, body = parse_frontmatter(content)

        entry = {
            "name": skill_path.parent.name,
            "path": str(skill_path.relative_to(SKILLS_DIR.parent)),
        }

        if frontmatter:
            entry["description"] = frontmatter.get("description", "")
            entry["trigger_phrases"] = frontmatter.get("trigger-phrases", "")
            entry["handoffs"] = frontmatter.get("handoffs", "")
            entry["allowed_tools"] = frontmatter.get("allowed-tools", "")
            entry["context"] = frontmatter.get("context", "")
            entry["companion_script"] = frontmatter.get("companion-script", "")

            # Detect dynamic context injection
            has_dynamic = bool(re.search(r'!`[^`]+`', body)) or bool(re.search(r'```!\n', body))
            entry["has_dynamic_context"] = has_dynamic

        index["skills"].append(entry)

    # Write index
    index_path = SKILLS_DIR / ".skill-index.json"
    index_path.write_text(json.dumps(index, indent=2))
    print(f"Index written to {index_path}")
    print(f"Total: {len(skills)} skills indexed")

    # Also print a compact summary
    print(f"\n{'Name':30} {'Context':8} {'Dynamic':8} {'Tools'}")
    print("-" * 60)
    for s in sorted(index["skills"], key=lambda x: x["name"]):
        ctx = s.get("context", "") or "-"
        dyn = "✓" if s.get("has_dynamic_context") else "-"
        tools = (s.get("allowed_tools", "") or "-")[:20]
        print(f"{s['name']:30} {ctx:8} {dyn:8} {tools}")

    return 0


def cmd_list():
    """List all skills with metadata."""
    skills = discover_skills()
    print(f"{'Skill':30} {'Description'}")
    print("-" * 80)
    for skill_path in skills:
        name = skill_path.parent.name
        content = skill_path.read_text()
        frontmatter, _ = parse_frontmatter(content)
        desc = ""
        if frontmatter:
            desc = frontmatter.get("description", "")
        desc = desc[:50] + "..." if len(desc) > 50 else desc
        print(f"{name:30} {desc}")

    print(f"\nTotal: {len(skills)} skills")
    return 0


def cmd_check(skill_name: str):
    """Check a specific skill's frontmatter in detail."""
    skills = discover_skills()
    target = None
    for skill_path in skills:
        if skill_path.parent.name == skill_name:
            target = skill_path
            break

    if target is None:
        print(f"Skill '{skill_name}' not found")
        return 1

    content = target.read_text()
    frontmatter, body = parse_frontmatter(content)

    print(f"Skill: {target.parent.name}")
    print(f"Path: {target}")
    print(f"\n--- Frontmatter ---")
    print(yaml.dump(frontmatter, default_flow_style=False).strip())
    print(f"\n--- Body ({len(body)} chars) ---")
    print(body[:300] + ("..." if len(body) > 300 else ""))
    print()

    if frontmatter:
        issues = validate_frontmatter(frontmatter, target)
        if issues:
            print(f"Issues ({len(issues)}):")
            for issue in issues:
                print(f"  - {issue}")
        else:
            print("Frontmatter: VALID")

    return 0


def main():
    if len(sys.argv) < 2 or sys.argv[1] in ("-h", "--help"):
        print(__doc__)
        return 0

    command = sys.argv[1]

    commands = {
        "validate": cmd_validate,
        "expand": cmd_expand,
        "index": cmd_index,
        "list": cmd_list,
    }

    if command == "check":
        if len(sys.argv) < 3:
            print("Usage: skill-processor.py check <skill-name>")
            return 1
        return cmd_check(sys.argv[2])

    handler = commands.get(command)
    if handler is None:
        print(f"Unknown command: {command}", file=sys.stderr)
        print(__doc__)
        return 1

    return handler()


if __name__ == "__main__":
    sys.exit(main())
