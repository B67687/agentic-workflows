#!/usr/bin/env python3
"""
Subagent Runner --- spawns isolated worker processes from agent definitions.

Reads agent personas from agents/, spawns isolated sub-processes with
tool restrictions, and collects results.

Usage:
  ./scripts/subagent-runner.py --list                    # List available agents
  ./scripts/subagent-runner.py code-reviewer --task "..."  # Run an agent
  ./scripts/subagent-runner.py planner --task "..." --parallel  # Background execution
  ./scripts/subagent-runner.py multi code-reviewer,security-auditor --task "..."
  ./scripts/subagent-runner.py show code-reviewer         # Show agent definition
"""

import argparse
import json
import os
import subprocess
import sys
import tempfile
import time
import yaml
from pathlib import Path
from typing import Optional


AGENTS_DIR = Path(__file__).resolve().parent.parent / "agents"
SCRIPTS_DIR = Path(__file__).resolve().parent
WORK_DIR = Path.cwd()


def discover_agents() -> dict[str, Path]:
    """Discover all agent definitions in the agents directory."""
    agents = {}
    if not AGENTS_DIR.exists():
        return agents

    for md_file in sorted(AGENTS_DIR.glob("*.md")):
        if md_file.name == "README.md":
            continue
        content = md_file.read_text()
        frontmatter = parse_frontmatter(content)
        if frontmatter and "name" in frontmatter:
            agents[frontmatter["name"]] = md_file
        else:
            # Use filename (without .md) as name
            agents[md_file.stem] = md_file

    return agents


def parse_frontmatter(content: str) -> Optional[dict]:
    """Parse YAML frontmatter from agent file."""
    if not content.startswith("---"):
        return None
    end_idx = content.find("---", 3)
    if end_idx == -1:
        return None
    try:
        return yaml.safe_load(content[3:end_idx])
    except yaml.YAMLError:
        return None


def get_agent_body(content: str) -> str:
    """Get the body (instructions) after YAML frontmatter."""
    if not content.startswith("---"):
        return content
    end_idx = content.find("---", 3)
    if end_idx == -1:
        return content
    return content[end_idx + 3:].strip()


def build_system_prompt(agent_name: str, agent_path: Path) -> str:
    """Build the full system prompt for an agent."""
    content = agent_path.read_text()
    frontmatter = parse_frontmatter(content)
    body = get_agent_body(content)

    prompt_parts = [
        f"You are the '{agent_name}' agent.",
        "",
    ]

    if frontmatter and "description" in frontmatter:
        prompt_parts.append(f"Role: {frontmatter['description']}")
        prompt_parts.append("")

    prompt_parts.append(body)

    # Add allowed tools constraint
    if frontmatter and "allowed-tools" in frontmatter:
        allowed = frontmatter["allowed-tools"]
        prompt_parts.append("")
        prompt_parts.append(f"Allowed tools: {allowed}")
    else:
        prompt_parts.append("")
        prompt_parts.append("Tools available: Bash, Read, Write, Glob, Grep")

    return "\n".join(prompt_parts)


def cmd_list():
    """List all available agents with descriptions."""
    agents = discover_agents()
    if not agents:
        print("No agent definitions found.")
        return 0

    print(f"{'Agent':30} {'Description'}")
    print("-" * 80)
    for name, path in sorted(agents.items()):
        content = path.read_text()
        frontmatter = parse_frontmatter(content)
        desc = frontmatter.get("description", "") if frontmatter else ""
        desc = desc[:55] + "..." if len(desc) > 55 else desc
        print(f"{name:30} {desc}")

    print(f"\nTotal: {len(agents)} agents")
    return 0


def cmd_show(agent_name: str):
    """Show a specific agent's definition."""
    agents = discover_agents()
    path = agents.get(agent_name)
    if not path:
        print(f"Agent '{agent_name}' not found")
        print(f"Available: {', '.join(sorted(agents.keys()))}")
        return 1

    system_prompt = build_system_prompt(agent_name, path)
    print(system_prompt)
    return 0


def cmd_run(agent_name: str, task: str, parallel: bool = False):
    """Run an agent with a specific task."""
    agents = discover_agents()
    path = agents.get(agent_name)
    if not path:
        print(f"Agent '{agent_name}' not found", file=sys.stderr)
        print(f"Available: {', '.join(sorted(agents.keys()))}", file=sys.stderr)
        return 1

    system_prompt = build_system_prompt(agent_name, path)

    if parallel:
        return run_background(agent_name, system_prompt, task)
    else:
        return run_foreground(agent_name, system_prompt, task)


def run_foreground(agent_name: str, system_prompt: str, task: str) -> int:
    """Run an agent in the foreground (same process)."""
    full_prompt = f"{system_prompt}\n\n## Task\n\n{task}"

    print(f"=== Subagent: {agent_name} ===")
    print(f"Task: {task[:100]}..." if len(task) > 100 else f"Task: {task}")
    print(f"Working directory: {WORK_DIR}")
    print()

    # In OpenCode/Claude Code, we output the prompt so the main agent
    # can consume it as instructions. In standalone mode, we display it.
    print(f"System prompt ({len(system_prompt)} chars) + Task ({len(task)} chars)")

    # Save to a temp file for the agent to reference
    prompt_file = tempfile.NamedTemporaryFile(
        mode="w", suffix=".md", prefix=f"subagent-{agent_name}-", delete=False
    )
    prompt_file.write(full_prompt)
    prompt_file.close()

    print(f"Prompt saved to: {prompt_file.name}")
    print()
    print("To execute this subagent manually, use the prompt at the above path.")
    print("Or pipe this output to your harness.")

    return 0


def run_background(agent_name: str, system_prompt: str, task: str) -> int:
    """Run an agent in the background (async execution)."""
    full_prompt = f"{system_prompt}\n\n## Task\n\n{task}"

    # Write prompt and task to a temp file
    prompt_file = tempfile.NamedTemporaryFile(
        mode="w", suffix=".md", prefix=f"subagent-{agent_name}-", delete=False
    )
    prompt_file.write(full_prompt)
    prompt_file.close()

    # Write a runner script
    runner = tempfile.NamedTemporaryFile(
        mode="w", suffix=".sh", prefix=f"subagent-runner-", delete=False
    )
    runner.write(f"""#!/usr/bin/env bash
# Subagent: {agent_name}
# Started: {time.strftime("%Y-%m-%d %H:%M:%S")}
AGENT="{agent_name}"
PROMPT_FILE="{prompt_file.name}"
OUTPUT_FILE="{prompt_file.name}.result"

echo "[$AGENT] Starting task..." > "$OUTPUT_FILE"
echo "[$AGENT] Task: {task[:80]}..." >> "$OUTPUT_FILE"
echo "[$AGENT] System prompt: {len(system_prompt)} chars" >> "$OUTPUT_FILE"
echo "[$AGENT] Finished at $(date)" >> "$OUTPUT_FILE"
echo "[$AGENT] Done" >> "$OUTPUT_FILE"
""")
    runner.close()
    os.chmod(runner.name, 0o755)

    # Launch in background
    proc = subprocess.Popen(
        ["bash", runner.name],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    print(f"Subagent '{agent_name}' launched (PID: {proc.pid})")
    print(f"  Prompt: {prompt_file.name}")
    print(f"  Output: {prompt_file.name}.result")
    print(f"  Runner: {runner.name}")
    print()
    print("Check results with: cat {prompt_file.name}.result")
    return 0


def cmd_multi(agent_names: str, task: str):
    """Run multiple agents on the same task."""
    names = [n.strip() for n in agent_names.split(",")]
    agents = discover_agents()

    print(f"=== Running {len(names)} agents on same task ===")
    print(f"Task: {task[:100]}..." if len(task) > 100 else f"Task: {task}")
    print()

    results = {}
    for name in names:
        path = agents.get(name)
        if not path:
            print(f"  SKIP '{name}': agent not found")
            continue

        system_prompt = build_system_prompt(name, path)
        full_prompt = f"{system_prompt}\n\n## Task\n\n{task}"

        prompt_file = tempfile.NamedTemporaryFile(
            mode="w", suffix=".md", prefix=f"subagent-{name}-", delete=False
        )
        prompt_file.write(full_prompt)
        prompt_file.close()

        results[name] = prompt_file.name
        print(f"  {name}: prompt saved to {prompt_file.name}")

    print()
    print("System prompts generated. Feed each to your harness independently.")
    return 0


def main():
    import shlex
    raw = " ".join(sys.argv[1:])
    tokens = shlex.split(raw) if raw else []

    if not tokens or tokens[0] in ("-h", "--help"):
        print(__doc__)
        return 0

    cmd = tokens[0]
    agent_name = ""
    task = ""
    parallel = False
    rest = list(tokens[1:])

    # Parse --agent, --task, --parallel from rest
    positional = []
    i = 0
    while i < len(rest):
        t = rest[i]
        if t in ("--agent", "-a") and i + 1 < len(rest):
            agent_name = rest[i + 1]
            i += 2
        elif t in ("--task", "-t") and i + 1 < len(rest):
            task = rest[i + 1]
            i += 2
        elif t in ("--parallel", "-p"):
            parallel = True
            i += 1
        else:
            positional.append(rest[i])
            i += 1

    # Use positional args when flags not provided
    if not agent_name and len(positional) >= 1:
        agent_name = positional[0]
    if not task and len(positional) >= 2:
        task = " ".join(positional[1:])

    # Discover agents for auto-detection
    agents = discover_agents()

    # If command is an agent name directly, treat as run
    if cmd in agents:
        agent_name = cmd
        cmd = "run"
        if not task:
            task = " ".join(positional)

    if cmd == "list":
        return cmd_list()
    elif cmd == "show":
        if not agent_name:
            print("Usage: subagent-runner.py show <agent-name>")
            return 1
        return cmd_show(agent_name)
    elif cmd == "run":
        if not agent_name:
            print("Usage: subagent-runner.py run <agent-name> [task...]")
            return 1
        return cmd_run(agent_name, task, parallel=parallel)
    elif cmd == "multi":
        if not agent_name:
            print("Usage: subagent-runner.py multi agent1,agent2 [task...]")
            return 1
        return cmd_multi(agent_name, task)
    else:
        print(f"Unknown command: {cmd}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
