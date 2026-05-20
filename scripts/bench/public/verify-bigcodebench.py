#!/usr/bin/env python3
"""
Verify BigCodeBench solutions against test cases.
Uses cached problem data and solutions.jsonl format.

Usage:
  python3 verify-bigcodebench.py --solutions <solutions.jsonl> --problems <problems.json>
  python3 verify-bigcodebench.py --solutions <solutions.jsonl> --run-dir <dir>
"""

import argparse
import json
import os
import sys

from bigcodebench.data import load_solutions
from bigcodebench.eval import untrusted_check


def main():
    parser = argparse.ArgumentParser(description="Verify BigCodeBench solutions")
    parser.add_argument("--solutions", required=True, help="Path to solutions.jsonl")
    parser.add_argument("--problems", help="Path to problems JSON (if not in run dir)")
    parser.add_argument(
        "--run-dir",
        default=".runtime/bench-runs",
        help="Run directory containing bigcodebench-problems.json",
    )
    args = parser.parse_args()

    # Load problems
    problems_path = args.problems or os.path.join(
        args.run_dir, "bigcodebench-problems.json"
    )
    if not os.path.exists(problems_path):
        # Try loading from bigcodebench data module
        from bigcodebench.data import get_bigcodebench

        print("Loading problems from BigCodeBench dataset...", file=sys.stderr)
        problems_raw = get_bigcodebench()
    else:
        with open(problems_path) as f:
            problems_raw = json.load(f)

    # Load solutions
    solutions = list(load_solutions(args.solutions))
    print(f"Loaded {len(solutions)} solutions", file=sys.stderr)

    # Build lookup
    problems = {}
    for pid, p in problems_raw.items():
        problems[pid] = p

    results = []
    for sol in solutions:
        task_id = sol["task_id"]
        code = sol["solution"]

        if task_id not in problems:
            print(f"  WARN: {task_id} not found in problems", file=sys.stderr)
            results.append(
                {"task_id": task_id, "success": False, "error": "Problem not found"}
            )
            continue

        problem = problems[task_id]
        entry_point = problem.get("entry_point", "task_func")
        test_code = problem.get("test", "")

        if not test_code:
            print(f"  WARN: {task_id} has no test code", file=sys.stderr)
            results.append(
                {"task_id": task_id, "success": False, "error": "No test code"}
            )
            continue

        # Run verification
        print(f"  Verifying {task_id}... ", end="", file=sys.stderr)
        try:
            status, details = untrusted_check(
                code=code,
                test_code=test_code,
                entry_point=entry_point,
                max_as_limit=30 * 1024,
                max_data_limit=30 * 1024,
                max_stack_limit=10,
                min_time_limit=5,
            )

            success = status == "pass"
            print(f"{'PASS' if success else 'FAIL'} ({status})", file=sys.stderr)
            results.append(
                {
                    "task_id": task_id,
                    "success": success,
                    "status": status,
                    "details": details.tolist()
                    if hasattr(details, "tolist")
                    else str(details),
                }
            )
        except Exception as e:
            print(f"ERROR: {e}", file=sys.stderr)
            results.append({"task_id": task_id, "success": False, "error": str(e)})

    # Summary
    passed = sum(1 for r in results if r.get("success"))
    failed = sum(1 for r in results if not r.get("success"))
    print(
        f"\nResults: {passed}/{len(results)} passed, {failed} failed", file=sys.stderr
    )

    # Output machine-readable summary
    print(
        json.dumps(
            {
                "total": len(results),
                "passed": passed,
                "failed": failed,
                "results": results,
            },
            indent=2,
        )
    )


if __name__ == "__main__":
    main()
