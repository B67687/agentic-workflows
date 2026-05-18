#!/usr/bin/env python3
"""
parallel-dispatch.py — Orchestrator for parallel workflow sub-steps.

Reads sub-step definitions from workspace/sub_steps.json, runs each
script concurrently, captures outputs, and optionally runs a merge script.

Usage: parallel-dispatch.py <workspace_dir> <repo_root> <merge_script_path>
"""

import json
import os
import subprocess
import sys
from pathlib import Path


def main():
    workspace = Path(sys.argv[1])
    repo_root = Path(sys.argv[2])
    merge_with = sys.argv[3] if len(sys.argv) > 3 and sys.argv[3] else ""

    with open(workspace / "sub_steps.json") as f:
        steps = json.load(f)

    # ── Launch all sub-steps concurrently ──

    processes = []
    for i, step in enumerate(steps):
        step_id = step.get("id", f"step_{i}")
        script = step.get("script", "")
        args = step.get("args", [])

        if not script:
            _write_result(
                workspace,
                step_id,
                {"step": step_id, "status": "fail", "error": "no script defined"},
            )
            continue

        script_path = repo_root / script
        if not script_path.exists():
            _write_result(
                workspace,
                step_id,
                {
                    "step": step_id,
                    "status": "fail",
                    "error": f"script not found: {script_path}",
                },
            )
            continue

        out_file = workspace / f"{step_id}.out"
        err_file = workspace / f"{step_id}.err"

        with open(out_file, "w") as out_f, open(err_file, "w") as err_f:
            p = subprocess.Popen(
                ["bash", str(script_path)] + args,
                stdout=out_f,
                stderr=err_f,
            )
            processes.append({"id": step_id, "process": p})

    # ── Wait for all and collect results ──

    results = []
    all_pass = True

    for item in processes:
        step_id = item["id"]
        p = item["process"]
        p.wait()

        stdout_content = ""
        stderr_content = ""
        out_file = workspace / f"{step_id}.out"
        err_file = workspace / f"{step_id}.err"

        if out_file.exists():
            stdout_content = out_file.read_text().strip()
        if err_file.exists():
            stderr_content = err_file.read_text().strip()

        status = "pass" if p.returncode == 0 else "fail"
        if status == "fail":
            all_pass = False

        _write_result(
            workspace,
            step_id,
            {
                "step": step_id,
                "status": status,
                "returncode": p.returncode,
                "stdout": stdout_content,
                "stderr": stderr_content,
            },
        )

    # ── Build intermediate output ──

    output = {
        "results": results,
        "all_pass": all_pass,
        "results_dir": str(workspace),
    }

    # ── Run merge step if specified ──

    if merge_with:
        merge_script = repo_root / merge_with
        if merge_script.exists():
            try:
                merged = subprocess.run(
                    ["bash", str(merge_script), str(workspace)],
                    capture_output=True,
                    text=True,
                    timeout=30,
                )
                if merged.returncode == 0 and merged.stdout.strip():
                    try:
                        output = json.loads(merged.stdout)
                    except json.JSONDecodeError:
                        output = {
                            "merged_text": merged.stdout.strip(),
                            "all_pass": all_pass,
                        }
                else:
                    output["merge_error"] = merged.stderr.strip()
            except subprocess.TimeoutExpired:
                output["merge_error"] = "merge script timed out"

    # ── Write output ──

    with open(workspace / "output.json", "w") as f:
        json.dump(output, f, indent=2)

    sys.exit(0 if all_pass else 1)


def _write_result(workspace, step_id, data):
    """Write individual sub-step result for reference."""
    result_file = workspace / f"{step_id}.json"
    with open(result_file, "w") as f:
        json.dump(data, f, indent=2)


if __name__ == "__main__":
    main()
