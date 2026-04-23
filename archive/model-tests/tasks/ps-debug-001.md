---
id: ps-debug-001
category: coding
difficulty: easy
tags: [powershell, debugging, file-system]
expected_outcome: Identifies the bug and provides a fix
time_estimate: < 2 minutes
---

## Task

Debug this PowerShell script. It should list all `.ps1` files in the current directory and subdirectories, but it only returns files in the root.

```powershell
Get-ChildItem -Path . -Filter *.ps1 -Recurse
```

## Expected Behavior

The script correctly outputs all `.ps1` files recursively. If the script is correct, identify why it might not be returning subdirectory results in some environments.

## Verification

Run the script and confirm it returns files from subdirectories as well as the root.
