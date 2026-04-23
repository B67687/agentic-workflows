---
name: audit-quality
description: Run a quality audit on the current workspace folder using the audit-folder-quality script. Use when the user asks to check quality, audit files, validate folder structure, or review folder health.
---

# Audit Folder Quality

Run the quality audit script to check for common issues in authored files.

## Steps

1. **Run the audit** from the current folder:
   ```powershell
   .\scripts\audit-folder-quality.ps1
   ```

2. **Review the output** for:
   - Orphaned files (not linked from README or index)
   - Files missing frontmatter
   - Broken internal links
   - Markdown quality issues
   - File naming inconsistencies

3. **Report findings** to the user:
   - Summarize the counts (files checked, issues found)
   - List specific files with issues
   - Recommend fixes

## What the Audit Checks
- All `.md` and `.ps1` files in the folder
- Links point to existing files
- Files are referenced from navigation (README, index)
- Consistent naming conventions
- Proper markdown structure

## Common Fixes
- Add orphaned files to README.md or create an index
- Fix broken relative links
- Rename files to match conventions
- Add missing YAML frontmatter to markdown files
