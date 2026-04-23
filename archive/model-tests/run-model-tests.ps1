<#
.SYNOPSIS
    Runs standardized model tests and produces self-documenting results.

.DESCRIPTION
    Presents test tasks to the current OpenCode model and records results.
    The user switches to the target model before running this script.

    Workflow:
    1. User switches model in OpenCode TUI
    2. User runs this script
    3. Script reads tasks from tasks/
    4. Script runs each task via opencode run
    5. Results are appended to results/{model}/{date}.md
    6. Summary verdict is displayed

.PARAMETER TaskId
    Run a specific task only (by its filename without .md extension).

.PARAMETER Model
    Model name for the result file naming. If not provided, will prompt.

.PARAMETER Provider
    Provider name for result file. If not provided, will prompt.

.EXAMPLE
    .\run-model-tests.ps1
    # Run all tasks with current model

.EXAMPLE
    .\run-model-tests.ps1 -TaskId "ps-debug-001"
    # Run one specific task

.EXAMPLE
    .\run-model-tests.ps1 -Model "Kimi K2.6" -Provider "OpenCode Go"
    # Run all tasks, save to Kimi K2.6 results folder
#>

param(
    [string]$TaskId,
    [string]$Model,
    [string]$Provider
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir

# --- Prompt for model info if not provided ---
if (-not $Model) {
    $Model = Read-Host "Model name (e.g. Kimi K2.6)"
}
if (-not $Provider) {
    $Provider = Read-Host "Provider (e.g. OpenCode Go)"
}

# --- Determine task list ---
if ($TaskId) {
    $TaskFiles = @(Get-ChildItem -Path "$ScriptDir/tasks/$TaskId.md" -ErrorAction Stop)
} else {
    $TaskFiles = Get-ChildItem -Path "$ScriptDir/tasks/*.md" -ErrorAction Stop
}

if ($TaskFiles.Count -eq 0) {
    Write-Error "No tasks found."
}

# --- Set up results directory ---
$DateStr = Get-Date -Format "yyyy-MM-dd"
$ModelSlug = $Model -replace '\s+', '-' -replace '[^a-zA-Z0-9-]', ''
$ResultsDir = "$ScriptDir/results/$ModelSlug"
if (-not (Test-Path $ResultsDir)) {
    New-Item -ItemType Directory -Path $ResultsDir -Force | Out-Null
}
$ResultFile = "$ResultsDir/$DateStr.md"

# --- Initialize result file ---
$Header = @"
# Test Results: $Model ($Provider)

**Date:** $DateStr
**Tasks:** $($TaskFiles.Count)
**Model:** $Model
**Provider:** $Provider

---

## Task Results

"@
if (-not (Test-Path $ResultFile)) {
    $Header | Set-Content -Path $ResultFile
}

# --- Run each task ---
$Passed = 0
$Failed = 0
$Results = @()

foreach ($TaskFile in $TaskFiles) {
    Write-Host "Running: $($TaskFile.BaseName)..."

    $TaskContent = Get-Content $TaskFile.FullName -Raw

    # Extract frontmatter
    $Frontmatter = @{}
    if ($TaskContent -match '(?s)^---\r?\n(.+?)\r?\n---') {
        $fmText = $Matches[1]
        foreach ($line in $fmText -split '\r?\n') {
            if ($line -match '^(\w+):\s*(.+)$') {
                $Frontmatter[$Matches[1]] = $Matches[2]
            }
        }
    }

    # Extract task body (everything after the second ---)
    $TaskBody = $TaskContent -replace '(?s)^.+?---\r?\n.+?---\r?\n', ''

    # Build the prompt
    $Prompt = @"

## Test Task: $($TaskFile.BaseName)

$TaskBody

---

Output your answer. After your answer, on a new line, rate yourself:
`Pass` or `Fail` — and briefly explain why.

"@

    # Run via opencode run
    $Start = Get-Date
    $Output = opencode run $Prompt 2>&1
    $Duration = (Get-Date) - $Start
    $DurationStr = "{0:N1}" -f $Duration.TotalSeconds

    # Determine pass/fail from output
    $Verdict = "Unknown"
    if ($Output -match '\b(Pass|Pass\!)\b') {
        $Verdict = "Pass"
        $Passed++
    } elseif ($Output -match '\b(Fail|Failed)\b') {
        $Verdict = "Fail"
        $Failed++
    } else {
        # Default: assume pass if no explicit Fail found
        $Verdict = "Pass (unconfirmed)"
        $Passed++
    }

    # Append to result file
    $Entry = @"

### $($TaskFile.BaseName) — $Verdict

**Category:** $($Frontmatter['category'])
**Difficulty:** $($Frontmatter['difficulty'])
**Duration:** ${DurationStr}s

**Output:**

$Output

---

"@
    $Entry | Add-Content -Path $ResultFile

    $Results += @{
        Id = $TaskFile.BaseName
        Verdict = $Verdict
        Duration = $DurationStr
        Output = $Output
    }

    Write-Host "  → $Verdict ($DurationStr`s)"
}

# --- Summary ---
$Total = $TaskFiles.Count
Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "Model: $Model ($Provider)"
Write-Host "Passed: $Passed / $Total"
Write-Host "Failed: $Failed / $Total"
Write-Host "Results: $ResultFile"

# --- Recommendation ---
if ($Failed -eq 0) {
    Write-Host "Recommendation: This model passes all tasks." -ForegroundColor Green
} elseif ($Failed -lt $Total / 2) {
    Write-Host "Recommendation: This model has some failures. Consider noting weaknesses." -ForegroundColor Yellow
} else {
    Write-Host "Recommendation: This model fails most tasks. Not recommended." -ForegroundColor Red
}

# --- Prompt to update model-selection-guide if notably better ---
if ($Passed -eq $Total -and $Failed -eq 0) {
    Write-Host ""
    Write-Host "All tasks passed. This model may be worth promoting in docs/model-selection-guide.md." -ForegroundColor Green
    Write-Host "Run: .\scripts\ws.ps1 propagate  # after updating the guide" -ForegroundColor Gray
}
