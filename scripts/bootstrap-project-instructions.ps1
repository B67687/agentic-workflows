<#
.SYNOPSIS
    Bootstraps a new repo with AGENTS.md and lessons templates.

.DESCRIPTION
    Creates AGENTS.md and topic-insights.md files from templates.

.PARAMETER RepoPath
    Path to the repository to bootstrap.

.PARAMETER LessonsFileName
    Name of the lessons file (default: topic-insights.md).

.PARAMETER IncludeCopilotInstructions
    Include GitHub Copilot instructions.

.EXAMPLE
    .\bootstrap-project-instructions.ps1 -RepoPath "C:\path\to\repo"

.NOTES
    Author: AI Prompting
    Date: 2026-04-14
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RepoPath,

    [string]$LessonsFileName = "topic-insights.md"
)

try {
    $scriptDir = Split-Path $PSScriptRoot -Parent
    $templateDir = Join-Path $scriptDir "propagate-templates"
    $agentsTemplatePath = Join-Path $templateDir "AGENTS.template.md"
    $lessonsTemplatePath = Join-Path $templateDir "topic-insights.template.md"

if (-not (Test-Path -LiteralPath $RepoPath -PathType Container)) {
    throw "Repo path does not exist or is not a directory: $RepoPath"
}

$resolvedRepo = (Resolve-Path -LiteralPath $RepoPath).Path

foreach ($templatePath in @($agentsTemplatePath, $lessonsTemplatePath)) {
    if (-not (Test-Path -LiteralPath $templatePath)) {
        throw "Missing template file: $templatePath"
    }
}

$agentsPath = Join-Path $resolvedRepo "AGENTS.md"
$lessonsPath = Join-Path $resolvedRepo $LessonsFileName

if (-not (Test-Path -LiteralPath $agentsPath)) {
    $agentsContent = Get-Content -LiteralPath $agentsTemplatePath -Raw
    $agentsContent = $agentsContent.Replace("[LESSONS_FILE_NAME]", $LessonsFileName)
    $agentsContent | Set-Content -LiteralPath $agentsPath -Encoding UTF8
}

if (-not (Test-Path -LiteralPath $lessonsPath)) {
    $lessonsContent = Get-Content -LiteralPath $lessonsTemplatePath -Raw
    $lessonsContent | Set-Content -LiteralPath $lessonsPath -Encoding UTF8
}

Write-Output "Created or preserved:"
Write-Output "- $agentsPath"
Write-Output "- $lessonsPath"
}
catch {
    Write-Error "Bootstrap failed: $_"
    exit 1
}
