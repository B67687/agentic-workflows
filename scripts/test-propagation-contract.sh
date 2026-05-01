#!/usr/bin/env bash
# =============================================================================
# test-propagation-contract.sh - Smoke-test propagation ownership guarantees
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/propagation-contract.sh"

TMP_ROOT="$(mktemp -d)"
TEST_REPO="$TMP_ROOT/demo-topic"
trap 'rm -rf "$TMP_ROOT"' EXIT

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

assert_file_exists() {
  local path="$1"
  [[ -f "$path" ]] || fail "Expected file to exist: $path"
}

assert_matches_template() {
  local entry="$1"
  local target="$TEST_REPO/$(propagation_entry_target "$entry")"
  local template
  template="$(propagation_template_path "$entry")"
  cmp -s "$template" "$target" || fail "Managed file drifted unexpectedly: $target"
}

assert_checksum_unchanged() {
  local path="$1"
  local expected="$2"
  local actual
  actual="$(sha256sum "$path" | awk '{print $1}')"
  [[ "$actual" == "$expected" ]] || fail "Repo-owned file was overwritten: $path"
}

mkdir -p "$TEST_REPO"

# Seed repo-owned files with custom content before bootstrap.
cat > "$TEST_REPO/session-state.json" <<'EOF'
{
  "current_focus": "custom repo-owned session state",
  "notes": ["must survive propagation"]
}
EOF

cat > "$TEST_REPO/topic-insights.md" <<'EOF'
# Topic Insights

## Transferable Lessons

- Custom repo lesson that should survive bootstrap and refresh.
EOF

SESSION_STATE_HASH="$(sha256sum "$TEST_REPO/session-state.json" | awk '{print $1}')"
TOPIC_INSIGHTS_HASH="$(sha256sum "$TEST_REPO/topic-insights.md" | awk '{print $1}')"

echo "== Bootstrap missing files =="
bash "$SCRIPT_DIR/propagate-to-all.sh" --folder "$TEST_REPO" --apply > "$TMP_ROOT/bootstrap.log"

# Managed core should be created.
while IFS= read -r entry; do
  [[ -n "$entry" ]] || continue
  assert_file_exists "$TEST_REPO/$(propagation_entry_target "$entry")"
done < <(propagation_iter_entries managed)

# Repo-owned files should exist, but seeded files must remain unchanged.
while IFS= read -r entry; do
  [[ -n "$entry" ]] || continue
  assert_file_exists "$TEST_REPO/$(propagation_entry_target "$entry")"
done < <(propagation_iter_entries repo-owned)

assert_checksum_unchanged "$TEST_REPO/session-state.json" "$SESSION_STATE_HASH"
assert_checksum_unchanged "$TEST_REPO/topic-insights.md" "$TOPIC_INSIGHTS_HASH"

# Nested directories should have been created automatically.
[[ -d "$TEST_REPO/docs" ]] || fail "Expected docs/ to be created"
[[ -d "$TEST_REPO/archive" ]] || fail "Expected archive/ to be created"

echo "== Managed refresh repairs drift only =="

# Drift a managed file and customize a repo-owned bootstrap file after creation.
echo "" >> "$TEST_REPO/AGENTS.md"
echo "Local managed drift for test" >> "$TEST_REPO/AGENTS.md"
echo "" >> "$TEST_REPO/archive/history-index.md"
echo "Local history note that must survive managed refresh." >> "$TEST_REPO/archive/history-index.md"
HISTORY_INDEX_HASH="$(sha256sum "$TEST_REPO/archive/history-index.md" | awk '{print $1}')"

bash "$SCRIPT_DIR/propagate-to-all.sh" --folder "$TEST_REPO" --managed-only --apply > "$TMP_ROOT/refresh.log"

# Managed core should be reset to template content.
while IFS= read -r entry; do
  [[ -n "$entry" ]] || continue
  assert_matches_template "$entry"
done < <(propagation_iter_entries managed)

# Repo-owned files should still match their customized content.
assert_checksum_unchanged "$TEST_REPO/session-state.json" "$SESSION_STATE_HASH"
assert_checksum_unchanged "$TEST_REPO/topic-insights.md" "$TOPIC_INSIGHTS_HASH"
assert_checksum_unchanged "$TEST_REPO/archive/history-index.md" "$HISTORY_INDEX_HASH"

echo "== Sync status should pass =="
bash "$SCRIPT_DIR/check-sync-status.sh" "$TEST_REPO" > "$TMP_ROOT/status.log"

echo "PASS: propagation bootstrap and managed refresh preserve ownership boundaries."
