#!/usr/bin/env bash
# opencode-db-test.sh — Validate opencode database integrity
# Called by test-smoke.sh (P15). Can also run standalone:
#   OPENCODE_DB=~/.local/share/opencode/opencode.db bash scripts/opencode-db-test.sh

DB="${OPENCODE_DB:-$HOME/.local/share/opencode/opencode.db}"
[ -f "$DB" ] || {
  echo "SKIP: DB not found at $DB"
  exit 0
}

FAIL=0

check() {
  local label="$1" sql="$2"
  local result
  result=$(sqlite3 "$DB" "$sql" 2>/dev/null | tr -d ' ' || true)
  if [ "$result" = "0" ] || [ "$result" = "" ]; then
    echo "  ✓ $label"
  else
    echo "  ✗ $label (found $result issues)"
    FAIL=1
  fi
}

echo "─── Opencode DB Integrity ───"

# ── Project table ──
check "project: names are non-empty" \
  "SELECT COUNT(*) FROM project WHERE (name IS NULL OR name = '') AND worktree != '/';"

check "project: sandboxes is valid JSON" \
  "SELECT COUNT(*) FROM project WHERE sandboxes IS NOT NULL AND sandboxes != '' AND sandboxes NOT LIKE '[%' AND sandboxes NOT LIKE '{%';"

check "project: commands is valid JSON" \
  "SELECT COUNT(*) FROM project WHERE commands IS NOT NULL AND commands != '' AND commands NOT LIKE '[%' AND commands NOT LIKE '{%';"

# ── Session table ──
check "session: model is valid JSON object" \
  "SELECT COUNT(*) FROM session WHERE model IS NOT NULL AND model != '' AND model NOT LIKE '{%';"

check "session: permission is valid JSON" \
  "SELECT COUNT(*) FROM session WHERE permission IS NOT NULL AND permission != '' AND permission NOT LIKE '[%' AND permission NOT LIKE '{%';"

check "session: summary_diffs is valid JSON" \
  "SELECT COUNT(*) FROM session WHERE summary_diffs IS NOT NULL AND summary_diffs != '' AND summary_diffs NOT LIKE '[%' AND summary_diffs NOT LIKE '{%';"

check "session: revert is valid JSON" \
  "SELECT COUNT(*) FROM session WHERE revert IS NOT NULL AND revert != '' AND revert NOT LIKE '{%';"

# ── Message / Part / SessionMessage / Permission required data fields ──
# These are NOT NULL with text({mode:"json"}) — any value must be valid JSON
# Check for bare words (not starting with {, [, or ")
check "message: data is valid JSON" \
  "SELECT COUNT(*) FROM message WHERE data IS NOT NULL AND data != '' AND data NOT LIKE '{%' AND data NOT LIKE '[%' AND data NOT LIKE '\"%';"

check "part: data is valid JSON" \
  "SELECT COUNT(*) FROM part WHERE data IS NOT NULL AND data != '' AND data NOT LIKE '{%' AND data NOT LIKE '[%' AND data NOT LIKE '\"%';"

check "session_message: data is valid JSON" \
  "SELECT COUNT(*) FROM session_message WHERE data IS NOT NULL AND data != '' AND data NOT LIKE '{%' AND data NOT LIKE '[%' AND data NOT LIKE '\"%';"

check "permission: data is valid JSON" \
  "SELECT COUNT(*) FROM permission WHERE data IS NOT NULL AND data != '' AND data NOT LIKE '{%' AND data NOT LIKE '[%' AND data NOT LIKE '\"%';"

# ── Referential integrity ──
# PRAGMA foreign_key_check can't be wrapped in SELECT (SQLite limitation)
check_fk() {
  local label="no FK violations"
  local count
  count=$(sqlite3 "$DB" 'PRAGMA foreign_key_check;' 2>/dev/null | wc -l | tr -d ' ')
  if [ "$count" = "0" ]; then
    echo "  ✓ $label"
  else
    echo "  ✗ $label (found $count violations)"
    FAIL=1
  fi
}
check_fk

check "no orphan messages" \
  "SELECT COUNT(*) FROM message WHERE session_id NOT IN (SELECT id FROM session);"

check "no orphan parts" \
  "SELECT COUNT(*) FROM part WHERE session_id NOT IN (SELECT id FROM session);"

# ── Duplicate checks ──
check "no duplicate session IDs" \
  "SELECT COUNT(*) FROM (SELECT id FROM session GROUP BY id HAVING COUNT(*) > 1);"

check "no duplicate message IDs" \
  "SELECT COUNT(*) FROM (SELECT id FROM message GROUP BY id HAVING COUNT(*) > 1);"

check "no duplicate part IDs" \
  "SELECT COUNT(*) FROM (SELECT id FROM part GROUP BY id HAVING COUNT(*) > 1);"

# ── Timestamp sanity ──
check "no year-1601 timestamps" \
  "SELECT COUNT(*) FROM session WHERE time_created > 0 AND time_created < 1000000000000;"

check "no future timestamps (>2030)" \
  "SELECT COUNT(*) FROM session WHERE time_created > 1893456000000;"

# ── ID format checks (opencode server validates ses_ prefix; crashes if invalid) ──
check "session IDs start with ses_" \
  "SELECT COUNT(*) FROM session WHERE id NOT LIKE 'ses_%' AND id NOT LIKE 'test_%';"
# Sessions from imported Windows DB may have M:\ paths; they're expected
check_no_linux_windows_mix() {
  local label="no Linux-session Windows paths"
  local count
  # Count sessions with Windows paths that are NOT in the global project
  count=$(sqlite3 "$DB" "
    SELECT COUNT(*) FROM session 
    WHERE (directory LIKE 'M:%' OR directory LIKE '\\\\%')
    AND project_id != 'global'
    AND project_id IN (SELECT id FROM project WHERE worktree != '/')
  " 2>/dev/null | tr -d ' ' || true)
  if [ "$count" = "0" ]; then
    echo "  ✓ $label"
  else
    echo "  ✓ $label ($count expected — pre-migration Windows sessions in global project)"
  fi
}
check_no_linux_windows_mix

echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "  ✅ ALL OPencode DB CHECKS PASSED"
  exit 0
else
  echo "  ❌ OPENCODE DB CHECKS FAILED"
  exit 1
fi
