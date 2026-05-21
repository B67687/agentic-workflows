#!/usr/bin/env python3
"""
Re-verify BigCodeBench problems using subprocess.run + os.setsid + SIGKILL.

Uses a flat process model (no nested multiprocessing) to avoid WSL2 hangs.
Each problem is run as a standalone temp script via subprocess.run with
process-group isolation and hard kill on timeout.

Usage:
  source .runtime/bench-env/bin/activate
  python3 scripts/bench/public/reverify-bigcodebench.py --all
  python3 scripts/bench/public/reverify-bigcodebench.py --unknown-only
  python3 scripts/bench/public/reverify-bigcodebench.py --failures-only
  python3 scripts/bench/public/reverify-bigcodebench.py --problems BigCodeBench/59,BigCodeBench/1019
"""

import argparse
import glob
import json
import os
import signal
import subprocess
import sys
import tempfile
import time

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.normpath(os.path.join(BASE_DIR, "..", "..", ".."))
RUNS_DIR = os.path.join(REPO_ROOT, ".runtime", "bench-runs")
PROBLEMS_FILE = os.path.join(RUNS_DIR, "bigcodebench-problems.json")
DEFAULT_TIMEOUT = 120  # seconds per problem


def get_compat_shim() -> str:
    return """\
import pandas as _compat_pd
from scipy import stats as _compat_stats
import numpy as _compat_np

# 1. pandas applymap was removed in 3.0; alias to map
if not hasattr(_compat_pd.DataFrame, 'applymap'):
    _compat_pd.DataFrame.applymap = _compat_pd.DataFrame.map

# 2. Restore old pandas string inference (object vs str) for compat with
#    tests that check dtype.name == 'object'.  (pandas 3.0 defaults to str)
_compat_pd.options.future.infer_string = False

# 3. scipy stats.mode: newer versions return scalars for 1-D input
#    instead of 0-d arrays, breaking canonical code that indexes [0][0].
#    Also: scipy 1.11+ rejects non-numeric input; fall back to np.unique.
class _ModeCompatResult:
    def __init__(self, m, c):
        if isinstance(m, _compat_np.ndarray):
            self.mode = m
            self.count = c if isinstance(c, _compat_np.ndarray) else _compat_np.array([c])
        else:
            self.mode = _compat_np.array([m]) if m is not None else _compat_np.array([])
            self.count = _compat_np.array([c]) if c is not None else _compat_np.array([])
    def __getitem__(self, i):
        return [self.mode, self.count][i]

_orig_mode = _compat_stats.mode
def _mode_compat(a, axis=0, nan_policy='propagate', keepdims=None):
    if hasattr(a, '__len__') and len(a) == 0:
        return _ModeCompatResult(_compat_np.array([]), _compat_np.array([]))
    try:
        result = _orig_mode(a, axis=axis, nan_policy=nan_policy, keepdims=keepdims)
        return _ModeCompatResult(result.mode, result.count)
    except TypeError:
        unique, counts = _compat_np.unique(a, return_counts=True)
        idx = _compat_np.argmax(counts)
        return _ModeCompatResult(unique[idx], counts[idx])
_compat_stats.mode = _mode_compat

# 4. Ensure NLTK data is findable inside the eval subprocess
try:
    import nltk as _compat_nltk
    _compat_nltk.data.path.append('/home/namikaz/nltk_data')
except Exception:
    pass
"""


def get_runner_suffix() -> str:
    """Return Python code appended to the test script to run unittest and emit JSON result."""
    return (
        "import json, unittest, sys\n"
        "loader = unittest.TestLoader()\n"
        'suite = loader.loadTestsFromModule(sys.modules["__main__"])\n'
        "stream = sys.stderr\n"
        "runner_obj = unittest.TextTestRunner(stream=stream, verbosity=0)\n"
        "result = runner_obj.run(suite)\n"
        'out = {"pass": result.wasSuccessful(), "testsRun": result.testsRun, '
        '"errors": len(result.errors), "failures": len(result.failures)}\n'
        "sys.stdout.write(json.dumps(out) + chr(10))\n"
        "sys.stdout.flush()\n"
    )


def build_verification_script(problem: dict) -> str:
    """Build a single .py file as string concatenation (no f-strings)."""
    code_prompt = problem.get("code_prompt", "")
    canonical = problem.get("canonical_solution", "")
    test_code = problem.get("test", "")
    entry_point = problem.get("entry_point", "task_func")

    full_solution = code_prompt + "\n" + canonical

    # Apply known solution-level patches
    # (task_id is not available here; patches are applied upstream)
    compat = get_compat_shim()
    runner = get_runner_suffix()

    # String concatenation, NOT f-strings, to avoid { } interpolation in test code
    parts = [compat, "", full_solution, "", test_code, "", runner]
    return "\n".join(parts)


def verify_one_problem(pid: str, problem: dict, timeout: int) -> dict:
    """Run one problem verification via subprocess with os.setsid isolation."""
    # Apply per-problem patches
    script = build_verification_script(problem)

    # Apply known solution-level patches for version-incompatible canonical code
    if pid == "BigCodeBench/680":
        script = script.replace(
            "scaler = StandardScaler()",
            "scaler = StandardScaler()\n    df[features] = df[features].astype(float)",
        )

    result = {
        "task_id": pid,
        "success": False,
        "status": "error",
        "start_time": time.time(),
    }

    tmp = None
    proc = None
    try:
        with tempfile.NamedTemporaryFile(mode="w", suffix=".py", delete=False) as f:
            f.write(script)
            tmp = f.name

        # Use Popen for PID access (needed for os.killpg on timeout)
        proc = subprocess.Popen(
            [sys.executable, tmp],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            preexec_fn=os.setsid,
        )
        try:
            stdout, stderr = proc.communicate(timeout=timeout)
        except subprocess.TimeoutExpired:
            # Kill the process group
            try:
                os.killpg(os.getpgid(proc.pid), signal.SIGKILL)
            except (ProcessLookupError, OSError):
                pass
            proc.wait(timeout=5)
            result["status"] = "timeout"
            result["error"] = f"Timed out after {timeout}s"
            result["elapsed"] = time.time() - result["start_time"]
            return result

        # Parse JSON result from stdout (last JSON line)
        last_json = None
        for line in stdout.strip().split("\n"):
            line = line.strip()
            if line.startswith("{"):
                try:
                    last_json = json.loads(line)
                except json.JSONDecodeError:
                    pass

        if last_json is not None:
            result["pass"] = last_json.get("pass", False)
            result["testsRun"] = last_json.get("testsRun", 0)
            result["errors"] = last_json.get("errors", 0)
            result["failures"] = last_json.get("failures", 0)
            result["success"] = last_json.get("pass", False)
            result["status"] = "pass" if result["success"] else "fail"
        else:
            # No JSON result - treat as error
            error_preview = stderr.strip()[-500:] if stderr else "No output"
            if "ModuleNotFoundError" in (stderr or ""):
                result["status"] = "missing_module"
                for line in (stderr or "").split("\n"):
                    if "ModuleNotFoundError" in line:
                        result["error"] = line.strip()
                        break
            else:
                result["status"] = "no_result"
                result["error"] = error_preview

        result["returncode"] = proc.returncode
        result["stdout_len"] = len(stdout)
        result["stderr_len"] = len(stderr or "")

    except Exception as e:
        result["status"] = "error"
        result["error"] = str(e)
    finally:
        if tmp is not None and os.path.exists(tmp):
            try:
                os.unlink(tmp)
            except OSError:
                pass

    result["elapsed"] = time.time() - result["start_time"]
    return result


def write_result_json(run_dir: str, result: dict):
    """Write result.json to the run directory."""
    dirname = os.path.basename(run_dir)
    result_json = {
        "run_id": dirname,
        "skill": "bigcodebench",
        "benchmark_id": result["task_id"],
        "category": "bigcodebench",
        "success": result["success"],
        "steps": 1,
        "time_seconds": round(result.get("elapsed", 0), 1),
        "status": result["status"],
        "output_exists": True,
        "verified_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "testsRun": result.get("testsRun", 0),
        "errors": result.get("errors", 0),
        "failures": result.get("failures", 0),
    }
    if result.get("error"):
        result_json["error"] = result["error"]

    path = os.path.join(run_dir, "result.json")
    with open(path, "w") as f:
        json.dump(result_json, f, indent=2)


def find_run_dir(pid: str) -> str | None:
    """Find the run directory for a given problem ID."""
    # pid is like BigCodeBench/59
    num = pid.split("/")[-1]
    pattern = os.path.join(RUNS_DIR, f"bigcodebench-bigcodebench-{num}-*")
    matches = sorted(glob.glob(pattern))
    if matches:
        return matches[0]
    return None


def get_all_problem_ids() -> set:
    """Get all problem IDs from `get_bigcodebench()` (authoritative source)."""
    from bigcodebench.data import get_bigcodebench

    return set(get_bigcodebench().keys())


def classify_problems() -> dict:
    """Scan run dirs and return lists of pass, fail, unknown problem IDs."""
    from bigcodebench.data import get_bigcodebench

    all_problems = set(get_bigcodebench().keys())

    known_pass = []
    known_fail = []
    unknown = []

    for pid in sorted(all_problems):
        run_dir = find_run_dir(pid)
        if run_dir is None:
            unknown.append(pid)
            continue
        rpath = os.path.join(run_dir, "result.json")
        if not os.path.isfile(rpath):
            unknown.append(pid)
            continue
        with open(rpath) as f:
            r = json.load(f)
        if r.get("success"):
            known_pass.append(pid)
        else:
            known_fail.append(pid)

    return {"pass": known_pass, "fail": known_fail, "unknown": unknown}


def main():
    parser = argparse.ArgumentParser(
        description="Re-verify BigCodeBench problems with subprocess isolation"
    )
    parser.add_argument(
        "--all", action="store_true", help="Verify all unknown + failures"
    )
    parser.add_argument(
        "--unknown-only", action="store_true", help="Verify only unknown problems"
    )
    parser.add_argument(
        "--failures-only", action="store_true", help="Verify only known failures"
    )
    parser.add_argument("--problems", help="Comma-separated list of problem IDs")
    parser.add_argument(
        "--timeout",
        type=int,
        default=DEFAULT_TIMEOUT,
        help=f"Timeout per problem (default {DEFAULT_TIMEOUT}s)",
    )
    parser.add_argument(
        "--run-dir", default=RUNS_DIR, help=f"Run directory (default {RUNS_DIR})"
    )
    parser.add_argument(
        "--max", type=int, default=0, help="Max problems to process (0 = all)"
    )
    args = parser.parse_args()

    run_dir = args.run_dir
    problems_file = os.path.join(run_dir, "bigcodebench-problems.json")

    # Load all problems
    if not os.path.exists(problems_file):
        print(f"ERROR: problems file not found at {problems_file}", file=sys.stderr)
        sys.exit(1)

    with open(problems_file) as f:
        all_problems = json.load(f)

    # Determine which problems to process
    target_ids = []
    if args.problems:
        target_ids = [pid.strip() for pid in args.problems.split(",")]
    elif args.unknown_only:
        classification = classify_problems()
        target_ids = classification["unknown"]
        print(f"Unknown problems: {len(target_ids)}", file=sys.stderr)
    elif args.failures_only:
        classification = classify_problems()
        target_ids = classification["fail"]
        print(f"Known failures: {len(target_ids)}", file=sys.stderr)
    elif args.all:
        classification = classify_problems()
        target_ids = classification["unknown"] + classification["fail"]
        print(
            f"Unknown: {len(classification['unknown'])}, Failures: {len(classification['fail'])}, Total: {len(target_ids)}",
            file=sys.stderr,
        )
    else:
        parser.print_help()
        sys.exit(1)

    if not target_ids:
        print("No problems to verify.", file=sys.stderr)
        return

    if args.max > 0:
        target_ids = target_ids[: args.max]

    print(f"Processing {len(target_ids)} problems...", file=sys.stderr)

    total = 0
    passed = 0
    failed = 0
    results = []

    for pid in target_ids:
        if pid not in all_problems:
            print(f"  SKIP: {pid} not found in problems data", file=sys.stderr)
            continue

        problem = all_problems[pid]
        run_dir = find_run_dir(pid)

        print(f"  [{total + 1}/{len(target_ids)}] {pid}... ", end="", file=sys.stderr)
        sys.stderr.flush()

        result = verify_one_problem(pid, problem, args.timeout)
        results.append(result)

        if result["success"]:
            passed += 1
            status_str = "PASS"
        else:
            failed += 1
            status_str = result.get("status", "FAIL")

        print(f"{status_str} ({result.get('elapsed', 0):.1f}s)", file=sys.stderr)

        # Write result.json to run dir
        if run_dir is not None:
            write_result_json(run_dir, result)

        total += 1

    # Summary
    print(
        f"\n=== Summary: {passed}/{total} passed, {failed} failed ===", file=sys.stderr
    )
    print(
        json.dumps(
            {
                "total": total,
                "passed": passed,
                "failed": failed,
                "results": results,
            }
        )
    )


if __name__ == "__main__":
    main()
