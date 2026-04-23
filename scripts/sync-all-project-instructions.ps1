<#
.SYNOPSIS
    Syncs instructions to all repos from a list file.

.DESCRIPTION
    Uses sync-project-instructions.ps1 to sync all repos listed in a file.

.PARAMETER RepoListFile
    Path to repo list file.

.PARAMETER LessonsFileName
    Lessons file name.

.PARAMETER IncludeCopilotInstructions
    Include Copilot instructions.

.PARAMETER CreateMissing
    Create missing AGENTS.md files.

.PARAMETER UpdateUnmanaged
    Update unmanaged repos.

.PARAMETER Apply
    Actually apply changes (otherwise preview).

.EXAMPLE
    .\sync-all-project-instructions.ps1 -Apply

.NOTES
    Author: AI Prompting
    Date: 2026-04-14
#>

[CmdletBinding()]
param(
    [string]$RepoListFile = (Join-Path $PSScriptRoot "repos.txt"),

    [string]$LessonsFileName = "topic-insights.md",

    [switch]$IncludeCopilotInstructions,

    [switch]$CreateMissing,

    [switch]$UpdateUnmanaged,

    [switch]$Apply
)

try {
    $syncScriptPath = Join-Path $PSScriptRoot "sync-project-instructions.ps1"

    if (-not (Test-Path -LiteralPath $syncScriptPath)) {
        throw "Sync script not found: $syncScriptPath"
    }

    if (-not (Test-Path -LiteralPath $RepoListFile)) {
        $examplePath = Join-Path $PSScriptRoot "repos.example.txt"
        throw "Repo list file not found: $RepoListFile`nCopy and edit: $examplePath"
    }

    $params = @{
        RepoListFile = $RepoListFile
        LessonsFileName = $LessonsFileName
    }

    if (-not $Apply) {
        $params.Preview = $true
        Write-Output "Running in preview mode. Re-run with -Apply to write changes."
    }

    & $syncScriptPath @params
}
catch {
    Write-Error "Sync failed: $_"
    exit 1
}
