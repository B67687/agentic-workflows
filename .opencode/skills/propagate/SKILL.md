---
name: propagate
description: Propagate templates from the AI Prompting hub to all topic folders in M-Namikaz-Others. Use when the user asks to sync, propagate, update templates, push changes to topic folders, or refresh managed files across repos.
---

# Propagate Templates to Topic Folders

Run the propagation script from the AI Prompting hub root to sync templates to all registered topic folders.

## Prerequisites
- Must be run from the AI Prompting hub root directory
- PowerShell execution policy must allow scripts

## Steps

1. **Navigate to hub root** (if not already there):
   ```powershell
   Set-Location "M:\M-Namikaz-Others\AI Prompting"
   ```

2. **Preview mode first** (recommended before applying):
   ```powershell
   .\scripts\propagate-to-all.ps1
   ```
   Review the output to see what would change.

3. **Apply propagation**:
   ```powershell
   .\scripts\propagate-to-all.ps1 -Apply
   ```

4. **Verify results**:
   - Check the summary output for each template
   - Confirm counts match expected (25 folders for most templates)
   - Note any SKIP (unmanaged) or UNCHANGED entries

## What Gets Propagated
- `AGENTS.md` → merged with existing (preserves custom sections)
- `topic-insights.md` → merged with existing
- `git-github-best-practices.md` → merged
- `audit-folder-quality.ps1` → merged
- `.cleanup-protect` → merged
- `opencode-agent-system.md` → merged
- `sync-from-hub.ps1` → merged
- `opencode.json` → skipped (unmanaged/sensitive)

## After Propagation
- Update `workflow/session-state.json` with what was propagated
- Report the operation counts to the user
