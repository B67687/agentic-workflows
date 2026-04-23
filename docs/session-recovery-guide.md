# Session Recovery Guide

How to recover sessions in OpenCode when the UI doesn't show them.

## Issue: Sessions Not Showing in Desktop

**Symptom:** Sessions exist in database but don't appear in OpenCode Desktop UI.

**Common Cause (1.4.3):** Directory-based filtering. Sessions are scoped to the current working directory by default.

### Query to Check Session Location

```sql
SELECT id, title, project_id, directory, time_archived, time_created, time_updated
FROM session 
WHERE directory LIKE '%AI Prompting%'
ORDER BY time_updated DESC;
```

### Solution A: Navigate to the Original Directory
1. `cd` to the directory where the session was created
2. Run OpenCode from there
3. Sessions should now appear

### Solution B: Check if There's an "All Sessions" Toggle
- Look for a filter/toggle in the session list UI
- Or use `/sessions --all` command in TUI

---

## Using SQLite Browser (For when sessions ARE actually archived)

### 1. Get SQLite Browser
- Download: https://sqlitebrowser.org/dl/
- Install normally

### 2. Find Your Database
```
%APPDATA%\opencode\opencode.db
```
(Windows) or `~/.local/share/opencode/opencode.db` (Linux/Mac)

### 3. Open and Browse
1. Open SQLite Browser
2. File → Open Database → select opencode.db
3. Go to "Browse Data" tab
4. Select the `session` table

### 4. Find the Column
- `time_archived` — NULL = active, has value = archived

### 5. To Restore
1. Click on `time_archived` cell
2. Set to NULL (or clear the value)
3. Click Save Changes

---

## Raw Session Files

Sessions are also stored as JSON:
```
%APPDATA%\opencode\storage\session\<project-id>\
```

---

Last updated: 2026-04-13