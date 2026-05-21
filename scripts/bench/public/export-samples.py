#!/usr/bin/env python3
"""
export-samples.py - Export BigCodeBench solutions to .jsonl format for evaluation.

Usage:
  python3 export-samples.py --run-dir <dir> --output <file> [--subset N]

Scans run directories for bigcodebench solutions (output.md with result.json),
extracts clean Python code, writes .jsonl for bigcodebench.evaluate().
"""

import json, os, glob, re, sys, argparse


def extract_solution(output_path):
    """Extract clean Python code from output.md."""
    with open(output_path) as f:
        content = f.read()

    # Try to extract Python code from ```python ... ``` blocks
    code_blocks = re.findall(r"```python\n(.*?)```", content, re.DOTALL)
    if code_blocks:
        code = code_blocks[0].strip()
    else:
        # Fall back: strip BENCH markers for old-format solutions
        code = re.sub(r"\n?BENCH_.*$", "", content, flags=re.MULTILINE).strip()

    # BigCodeBench evaluate() prepends the code_prompt (function signature)
    # and "\\n    pass\\n" to the submitted solution. So we must submit
    # only the FUNCTION BODY (indented code inside the function), not
    # the full definition with imports and def.
    return extract_function_body(code)


def extract_function_body(code):
    """Extract just the body of the first function definition.

    Given a full Python function like:
        import json
        def task_func(x):
            if x:
                return x
            return None

    Returns just the indented body:
        if x:
            return x
        return None
    """
    lines = code.split("\n")
    body_lines = []
    in_function = False
    found_def = False
    first_body_indent = None

    for line in lines:
        stripped = line.strip()

        if not found_def and stripped.startswith("def "):
            found_def = True
            in_function = True
            continue  # skip the def line itself

        if in_function:
            if stripped == "" and not body_lines:
                # Skip blank lines before the body starts
                continue
            if stripped == "":
                body_lines.append(line)
                continue

            # Check indentation
            indent = len(line) - len(line.lstrip())

            if first_body_indent is None:
                first_body_indent = indent
                body_lines.append(line)
            elif indent >= first_body_indent:
                body_lines.append(line)
            else:
                # Less indented than the body = end of function
                # Could be a new top-level construct
                break

    if body_lines:
        return "\n".join(body_lines)

    # If no function found, return original code (fallback)
    return code


def collect_solutions(runs_dir, subset=None):
    """Scan runs_dir for bigcodebench solutions, return list of (task_id, solution)."""
    samples = []

    for d in sorted(os.listdir(runs_dir)):
        run_dir = os.path.join(runs_dir, d)
        if not os.path.isdir(run_dir):
            continue

        output_path = os.path.join(run_dir, "output.md")
        result_path = os.path.join(run_dir, "result.json")

        if not os.path.exists(output_path):
            continue

        # Determine task_id from result.json
        task_id = None
        if os.path.exists(result_path):
            with open(result_path) as f:
                result = json.load(f)
            bid = result.get("benchmark_id", "")
            if "bigcodebench" in bid.lower():
                # Extract number: bigcodebench-254 -> BigCodeBench/254
                m = re.search(r"bigcodebench[-/](\d+)", bid, re.IGNORECASE)
                if m:
                    task_id = f"BigCodeBench/{m.group(1)}"

        # Fall back to directory name
        if not task_id:
            m = re.search(r"bigcodebench[-/](\d+)", d, re.IGNORECASE)
            if m:
                task_id = f"BigCodeBench/{m.group(1)}"
            else:
                continue

        # Skip old simulated benchmarks (0-4 were simulated, not genuine solves)
        if task_id:
            num = int(task_id.split("/")[1])
            if 0 <= num <= 4:
                continue

        solution = extract_solution(output_path)
        if solution:
            samples.append({"task_id": task_id, "solution": solution})

    # Deduplicate by task_id (keep last)
    seen = {}
    for s in samples:
        seen[s["task_id"]] = s
    samples = list(seen.values())

    # Sort by task_id
    samples.sort(key=lambda s: s["task_id"])

    # Apply subset
    if subset:
        samples = samples[:subset]

    return samples


def main():
    parser = argparse.ArgumentParser(description="Export BigCodeBench samples")
    parser.add_argument(
        "--run-dir", default=".runtime/bench-runs", help="Run directory to scan"
    )
    parser.add_argument(
        "--output",
        default=".runtime/bench-runs/bigcodebench-samples.jsonl",
        help="Output .jsonl path",
    )
    parser.add_argument(
        "--subset", type=int, default=None, help="Only export first N problems"
    )
    args = parser.parse_args()

    samples = collect_solutions(args.run_dir, args.subset)

    with open(args.output, "w") as f:
        for s in samples:
            f.write(
                json.dumps({"task_id": s["task_id"], "solution": s["solution"]}) + "\n"
            )

    print(f"Exported {len(samples)} samples to {args.output}", file=sys.stderr)
    print(f"Task IDs: {[s['task_id'] for s in samples]}", file=sys.stderr)
    return samples


if __name__ == "__main__":
    main()
