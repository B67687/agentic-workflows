#!/usr/bin/env python3
"""
_agent_runner.py --- Background job runner for agent-dispatch.sh

Receives job parameters via environment variables and executes the agent
command. Avoids all shell quoting issues by using subprocess with a
proper argument list.

Environment variables:
  _RUNNER_WORKDIR    --- Working directory to cd into before running
  _RUNNER_JOBS_DIR   --- Directory for job files (.log and .json)
  _RUNNER_JOB_ID     --- Job identifier (e.g. job-20260512-001)
  _CMD_ARGS_JSON     --- JSON array of command arguments (e.g. ["pi", "-p", "task"])
  _RUNNER_MAX_LOOPS  --- Max iterations for Hermes Agent loop pattern (default 1)
"""

import json
import os
import subprocess
import sys
from datetime import datetime


def extract_json(log_output):
    """Extract and parse JSON from agent output, handling markdown wrapping."""
    clean = log_output.strip()
    if clean.startswith("```"):
        lines = clean.split("\n")
        if lines[0].strip().startswith("```"):
            lines = lines[1:]
        if lines and lines[-1].strip() == "```":
            lines = lines[:-1]
        clean = "\n".join(lines).strip()
    first_brace = clean.find("{")
    last_brace = clean.rfind("}")
    if first_brace >= 0 and last_brace > first_brace:
        clean = clean[first_brace:last_brace + 1]
    try:
        return json.loads(clean)
    except json.JSONDecodeError:
        return None


def run_agent(cmd_args, log_path, json_path, append_context=""):
    """Execute agent command and return (returncode, log_output)."""
    # Append Hermes Agent loop context if this is a subsequent iteration
    effective_args = list(cmd_args)
    if append_context:
        # Find the -p argument and append context
        try:
            idx = effective_args.index("-p")
            if idx + 1 < len(effective_args):
                effective_args[idx + 1] += (
                    "\n\nPrevious iteration results:\n" + append_context
                    + "\n\nRefine based on these results. Improve, iterate, and return an updated result."
                )
        except ValueError:
            pass

    with open(log_path, "w") as log:
        result = subprocess.run(
            effective_args,
            stdout=log,
            stderr=subprocess.STDOUT,
            text=True,
            timeout=600,
        )

    with open(log_path) as f:
        log_output = f.read().strip()

    return result.returncode, log_output


def main():
    workdir = os.environ["_RUNNER_WORKDIR"]
    jobs_dir = os.environ["_RUNNER_JOBS_DIR"]
    job_id = os.environ["_RUNNER_JOB_ID"]
    cmd_args = json.loads(os.environ["_CMD_ARGS_JSON"])
    max_loops = int(os.environ.get("_RUNNER_MAX_LOOPS", "1"))

    log_path = os.path.join(jobs_dir, f"{job_id}.log")
    json_path = os.path.join(jobs_dir, f"{job_id}.json")

    # Change to working directory
    os.chdir(workdir)

    # Hermes Agent loop: iterative refinement
    iterations = []
    final_returncode = 0
    final_log = ""
    context = ""

    for loop_num in range(1, max_loops + 1):
        loop_log_path = log_path if max_loops == 1 else log_path.replace(".log", f"-loop{loop_num}.log")
        rc, output = run_agent(cmd_args, loop_log_path if max_loops > 1 else log_path, json_path, context)
        final_returncode = rc
        final_log = output

        # Parse result for this iteration (only if JSON format)
        parsed = extract_json(output) if output else None

        iteration = {
            "iteration": loop_num,
            "exit_code": rc,
            "output_preview": output[:200] if output else "",
        }
        if parsed:
            iteration["result"] = parsed
        iterations.append(iteration)

        # Stop loop if the agent failed or output is empty
        if rc != 0 or not output:
            break

        # Use result as context for next iteration
        context = output[:1000]

    # Read the job record
    with open(json_path) as f:
        job = json.load(f)

    completed = datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
    job["status"] = "done" if final_returncode == 0 else "failed"
    job["completed"] = completed
    job["exit_code"] = final_returncode
    job["iterations"] = iterations

    # Pydantic AI structured output: validate final result as JSON
    if job.get("format") == "json" and final_log:
        parsed = extract_json(final_log)
        if parsed:
            job["result"] = parsed
        else:
            job["result"] = {"_error": "invalid_json", "_raw": final_log[:500]}

    with open(json_path, "w") as f:
        json.dump(job, f, indent=2)

    sys.exit(final_returncode)


if __name__ == "__main__":
    main()
