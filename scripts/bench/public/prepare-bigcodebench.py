#!/usr/bin/env python3
"""
Prepare BigCodeBench run directories.
Reads problems from stdin (JSON), creates run dirs with prompts.

Usage:
  cat problems.json | python3 prepare-bigcodebench.py <runs_dir>
"""

import json
import os
import re
import sys
import subprocess


def main():
    runs_dir = sys.argv[1] if len(sys.argv) > 1 else ".runtime/bench-runs"

    problems = json.load(sys.stdin)

    for pid, problem in problems.items():
        # Normalize benchmark ID
        normalized_pid = re.sub(r"[^a-zA-Z0-9]", "-", pid).lower()

        # Create run directory with timestamp
        timestamp = subprocess.run(
            ["date", "-u", "+%Y%m%d%H%M%S"], capture_output=True, text=True
        ).stdout.strip()
        run_id = f"bigcodebench-{normalized_pid}-{timestamp}"
        run_dir = os.path.join(runs_dir, run_id)
        os.makedirs(run_dir, exist_ok=True)

        # Gather problem data
        complete_prompt = problem.get("complete_prompt", "")
        code_prompt = problem.get("code_prompt", "")
        entry_point = problem.get("entry_point", "task_func")
        libs = problem.get("libs", [])

        # Write prompt with step-budget
        prompt_path = os.path.join(run_dir, "prompt.md")
        with open(prompt_path, "w") as f:
            f.write(f"# BigCodeBench: {pid}\n\n")
            f.write(f"## Problem\n\n{complete_prompt}\n\n")
            f.write(f"## Function to Implement\n\n")
            f.write(f"Entry point: `{entry_point}`\n")
            f.write(f"Required libraries: {json.dumps(libs)}\n\n")
            f.write(f"## Code Stub\n\n```python\n{code_prompt}\n    ...\n```\n\n")
            f.write(f"## Instructions\n\n")
            f.write(f"Complete the function body. Write your full solution ")
            f.write(f"(including the def line and imports) to output.md.\n")
            f.write(f"The solution will be tested against hidden test cases.\n\n")
            f.write(f"## Step Budget\n\n")
            f.write(f"You have at most 8 tool calls to complete this task.\n")
            f.write(f"If stuck, write partial output and set BENCH_SUCCESS: false.\n\n")
            f.write(
                f"Report: BENCH_SUCCESS: true/false, BENCH_STEPS: N, BENCH_TIME_SEC: N\n"
            )

        print(f"PREPARED:{run_id}:{pid}")

    # Write full problem set
    problems_path = os.path.join(runs_dir, "bigcodebench-problems.json")
    with open(problems_path, "w") as f:
        json.dump(problems, f, indent=2)
    print(f"DONE:{problems_path}")


if __name__ == "__main__":
    main()
