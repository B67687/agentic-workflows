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
"""

import json
import os
import subprocess
import sys
from datetime import datetime


def main():
    workdir = os.environ["_RUNNER_WORKDIR"]
    jobs_dir = os.environ["_RUNNER_JOBS_DIR"]
    job_id = os.environ["_RUNNER_JOB_ID"]
    cmd_args = json.loads(os.environ["_CMD_ARGS_JSON"])

    log_path = os.path.join(jobs_dir, f"{job_id}.log")
    json_path = os.path.join(jobs_dir, f"{job_id}.json")

    # Change to working directory
    os.chdir(workdir)

    # Run the command, capture output to log file
    with open(log_path, "w") as log:
        result = subprocess.run(
            cmd_args,
            stdout=log,
            stderr=subprocess.STDOUT,
            text=True,
            timeout=600,
        )

    # Read the log output
    with open(log_path) as f:
        log_output = f.read().strip()

    # Update job record
    completed = datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")

    with open(json_path) as f:
        job = json.load(f)

    job["status"] = "done" if result.returncode == 0 else "failed"
    job["completed"] = completed
    job["exit_code"] = result.returncode

    # Pydantic AI structured output pattern: validate JSON if requested
    if job.get("format") == "json" and log_output:
        # Try to parse JSON from the log output
        # Strip common wrapping like ```json ... ``` or backticks
        clean = log_output.strip()
        if clean.startswith("```"):
            # Remove markdown code fence
            lines = clean.split("\n")
            if lines[0].strip().startswith("```"):
                lines = lines[1:]
            if lines and lines[-1].strip() == "```":
                lines = lines[:-1]
            clean = "\n".join(lines).strip()
        # Find first { and last } if there's surrounding text
        first_brace = clean.find("{")
        last_brace = clean.rfind("}")
        if first_brace >= 0 and last_brace > first_brace:
            clean = clean[first_brace:last_brace + 1]
        try:
            parsed = json.loads(clean)
            job["result"] = parsed
        except json.JSONDecodeError:
            # Store the raw log and mark result as invalid
            job["result"] = {"_error": "invalid_json", "_raw": log_output[:500]}

    with open(json_path, "w") as f:
        json.dump(job, f, indent=2)

    # Also write a brief success/fail indicator
    sys.exit(result.returncode)


if __name__ == "__main__":
    main()
