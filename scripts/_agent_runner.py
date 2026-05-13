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

    # Update job record
    completed = datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")

    with open(json_path) as f:
        job = json.load(f)

    job["status"] = "done" if result.returncode == 0 else "failed"
    job["completed"] = completed
    job["exit_code"] = result.returncode

    with open(json_path, "w") as f:
        json.dump(job, f, indent=2)

    # Also write a brief success/fail indicator
    sys.exit(result.returncode)


if __name__ == "__main__":
    main()
