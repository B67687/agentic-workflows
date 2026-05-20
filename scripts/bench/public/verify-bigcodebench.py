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


def _get_compat_shim() -> str:
    """
    Return Python code that monkey-patches newer library versions for
    backward compat with BigCodeBench's canonical solutions and tests.

    Patches:
      1. pd.DataFrame.applymap -> pd.DataFrame.map (removed in pandas 3.0)
      2. scipy.stats.mode -> normalises return to array-form (scipy 1.11+)
    """
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
#    Since ModeResult is a named tuple (immutable) we wrap it in a compat
#    class that normalises scalar returns to arrays and handles empty input.
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
    # Handle empty input
    if hasattr(a, '__len__') and len(a) == 0:
        return _ModeCompatResult(_compat_np.array([]), _compat_np.array([]))
    try:
        result = _orig_mode(a, axis=axis, nan_policy=nan_policy, keepdims=keepdims)
        return _ModeCompatResult(result.mode, result.count)
    except TypeError:
        # Non-numeric input: fall back to manual mode
        unique, counts = _compat_np.unique(a, return_counts=True)
        idx = _compat_np.argmax(counts)
        return _ModeCompatResult(unique[idx], counts[idx])
_compat_stats.mode = _mode_compat

# 4. Pandas 3.0 strict loc assignment: auto-upcast int→float when needed
#    (fixes sklearn StandardScaler assigning float64 to int64 columns)
import pandas.core.indexing as _pdx
_orig_setitem_single = _pdx._LocIndexer._setitem_single_column
def _compat_setitem_single(self, loc, value, name):
    try:
        return _orig_setitem_single(self, loc, value, name)
    except TypeError as e:
        msg = str(e)
        if 'Invalid value' in msg and hasattr(value, 'astype'):
            return _orig_setitem_single(self, loc, value.astype(float), name)
        raise
_pdx._LocIndexer._setitem_single_column = _compat_setitem_single

# 5. Ensure NLTK data is findable inside the eval subprocess
try:
    import nltk as _compat_nltk
    _compat_nltk.data.path.append('/home/namikaz/nltk_data')
except Exception:
    pass
"""


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

        # Prepend library compat shim for newer library versions
        compat_shim = _get_compat_shim()
        code_for_eval = compat_shim + "\n" + code

        # Run verification
        print(f"  Verifying {task_id}... ", end="", file=sys.stderr)
        try:
            status, details = untrusted_check(
                code=code_for_eval,
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
