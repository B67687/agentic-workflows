#!/usr/bin/env bash
# =============================================================================
# sync-commands.sh - Synchronize commands/ to .opencode/commands/ and .pi/prompts/
# =============================================================================
# Single source of truth: commands/*.md
# Generated mirrors:     .opencode/commands/ (all), .pi/prompts/ (subset)
#
# Run this after creating, renaming, or modifying any file in commands/.

set -euo pipefail

HUB_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="$HUB_DIR/commands"
TARGET_OPENCODE="$HUB_DIR/.opencode/commands"
TARGET_PI="$HUB_DIR/.pi/prompts"

DRY_RUN=false
VERBOSE=false

usage() {
  cat <<"USAGE"
Usage: ./scripts/sync-commands.sh [options]

Synchronize commands/ to runtime mirrors.

Options:
  --dry-run    Show what would be copied without copying
  --verbose    Show each file as it's copied
  -h, --help   Show this help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --verbose) VERBOSE=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

if [ ! -d "$SOURCE" ]; then
  echo "ERROR: Source directory $SOURCE does not exist."
  exit 1
fi

# Count files
SOURCE_COUNT=$(find "$SOURCE" -maxdepth 1 -name '*.md' | wc -l)

if [ "$DRY_RUN" = true ]; then
  echo "[DRY RUN] Would copy $SOURCE_COUNT files:"
  echo "  $SOURCE → $TARGET_OPENCODE (all)"
  echo "  $SOURCE → $TARGET_PI (all)"
  for f in "$SOURCE"/*.md; do
    base=$(basename "$f")
    echo "    $base"
  done
  exit 0
fi

# Sync all to .opencode/commands/
mkdir -p "$TARGET_OPENCODE"
cp "$SOURCE"/*.md "$TARGET_OPENCODE/"
OPENCODE_COUNT=$(find "$TARGET_OPENCODE" -maxdepth 1 -name '*.md' | wc -l)

# Sync all to .pi/prompts/
mkdir -p "$TARGET_PI"
cp "$SOURCE"/*.md "$TARGET_PI/"
PI_COUNT=$(find "$TARGET_PI" -maxdepth 1 -name '*.md' | wc -l)

echo "Synced $SOURCE_COUNT command files:"
echo "  → $TARGET_OPENCODE ($OPENCODE_COUNT files)"
echo "  → $TARGET_PI ($PI_COUNT files)"

if [ "$VERBOSE" = true ]; then
  echo ""
  echo "Files in commands/:"
  ls "$SOURCE"/*.md
fi

echo ""
echo "Sync complete. Remember to commit if this is a permanent change."
