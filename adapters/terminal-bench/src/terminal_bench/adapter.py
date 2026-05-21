"""
Adapter for Terminal-Bench 2.0 (ICLR 2026).

Terminal-Bench tasks are already published to the Harbor registry as
`terminal-bench/terminal-bench-2`. This adapter downloads them from
the registry and writes them to the output directory. No format conversion
is needed since tasks are already in Harbor format.

Dataset: 89 Docker-sandboxed terminal tasks
Website: https://tbench.ai
"""

import json
import logging
import subprocess
import sys
from pathlib import Path

logger = logging.getLogger(__name__)

HARBOR_DATASET = "terminal-bench/terminal-bench-2"
REPO_ROOT = Path(__file__).resolve().parents[4]


class TerminalBenchAdapter:
    def __init__(
        self,
        output_dir: Path,
        limit: int | None = None,
        overwrite: bool = False,
        task_ids: list[str] | None = None,
        **kwargs,
    ):
        self.output_dir = output_dir
        self.limit = limit
        self.overwrite = overwrite
        self.task_ids = task_ids

    def run(self) -> None:
        """Download Terminal-Bench dataset from Harbor registry to output_dir."""
        output_dir = self.output_dir.resolve()
        output_dir.mkdir(parents=True, exist_ok=True)

        logger.info("Downloading %s to %s", HARBOR_DATASET, output_dir)

        # Use harbor CLI from the bench-env venv to download the dataset
        harbor_bin = str(REPO_ROOT / ".runtime" / "bench-env" / "bin" / "harbor")
        if not Path(harbor_bin).exists():
            harbor_bin = "harbor"

        cmd = [
            harbor_bin,
            "dataset",
            "download",
            HARBOR_DATASET,
            "--export",
            "--output-dir",
            str(output_dir),
        ]
        if self.overwrite:
            cmd.append("--overwrite")

        logger.info("Running: %s", " ".join(cmd))
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
        )

        if result.returncode != 0:
            error_msg = result.stderr.strip() or result.stdout.strip()
            raise RuntimeError(f"Failed to download dataset: {error_msg}")

        # The dataset downloads to <output_dir>/terminal-bench-2/
        dataset_dir = output_dir / "terminal-bench-2"
        if not dataset_dir.is_dir():
            # Try without version suffix
            dataset_dir = output_dir / "terminal-bench"
            if not dataset_dir.is_dir():
                # List what was created
                created = list(output_dir.iterdir())
                raise RuntimeError(
                    f"Expected dataset dir not found. Created: {created}"
                )

        all_tasks = sorted(d for d in dataset_dir.iterdir() if d.is_dir())
        logger.info("Downloaded %d tasks to %s", len(all_tasks), dataset_dir)

        # Apply limit / task_ids filtering
        selected = all_tasks
        if self.task_ids:
            selected = [d for d in all_tasks if d.name in self.task_ids]
            missing = set(self.task_ids) - {d.name for d in selected}
            if missing:
                logger.warning("Task IDs not found: %s", ", ".join(missing))
        if self.limit is not None and self.limit > 0:
            selected = selected[: self.limit]

        logger.info("Selected %d tasks for output", len(selected))

        # Write manifest
        manifest = {
            "dataset": HARBOR_DATASET,
            "task_count": len(selected),
            "tasks": [d.name for d in selected],
            "output_dir": str(output_dir),
        }
        manifest_path = output_dir / "terminal-bench-manifest.json"
        with open(manifest_path, "w") as f:
            json.dump(manifest, f, indent=2)

        logger.info(
            "Adapter complete. %d tasks ready at %s",
            len(selected),
            output_dir,
        )


def main():
    logging.basicConfig(
        level=logging.INFO,
        format="%(levelname)s: %(message)s",
    )
    import argparse

    parser = argparse.ArgumentParser(description="Terminal-Bench 2.0 Harbor adapter")
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("datasets/terminal-bench"),
        help="Output directory for generated tasks",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=None,
        help="Limit number of tasks",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Overwrite existing tasks",
    )
    parser.add_argument(
        "--task-ids",
        nargs="+",
        default=None,
        help="Specific task IDs to generate",
    )
    args = parser.parse_args()

    adapter = TerminalBenchAdapter(
        args.output_dir,
        overwrite=args.overwrite,
        limit=args.limit,
        task_ids=args.task_ids,
    )
    adapter.run()


if __name__ == "__main__":
    main()
