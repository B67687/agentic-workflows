<#
.SYNOPSIS
    Harvests insights from multiple topic folders into a central file.

.DESCRIPTION
    Scans all folders under M-Namikaz-Others that contain topic-insights.md
    and collects them into a central harvest file for cross-domain review.

.PARAMETER FolderPaths
    Specific folders to harvest.

.PARAMETER InsightsFileName
    Insights file name to look for (default: topic-insights.md).

.PARAMETER OutputFile
    Output file for harvested insights.

.PARAMETER Preview
    Preview only.

.PARAMETER ScanAllFolders
    Scan all folders under M-Namikaz-Others (default: true, ignores repos.txt).

.EXAMPLE
    .\harvest-topic-insights.ps1

.EXAMPLE
    .\harvest-topic-insights.ps1 -Preview

.NOTES
    Author: AI Prompting
    Date: 2026-04-19
#>

[CmdletBinding()]
param(
    [string[]]$FolderPaths,

    [string]$InsightsFileName = "topic-insights.md",

    [string]$OutputFile = (Join-Path (Split-Path $PSScriptRoot -Parent) "workflow\harvested-topic-insights.md"),

    [switch]$Preview,

    [switch]$ScanAllFolders = $true
)

try {
    $defaultInsightsCandidates = @(
        $InsightsFileName,
        "topic-insights.md",
        "insights.md"
    ) | Select-Object -Unique

    $allFolderInputs = @()

    if ($FolderPaths) {
        $allFolderInputs += $FolderPaths
    }

    if (-not $FolderPaths -and $ScanAllFolders) {
        $mNamikazOthers = Split-Path (Split-Path $PSScriptRoot -Parent)
        if (Test-Path -LiteralPath $mNamikazOthers -PathType Container) {
            $allFolders = Get-ChildItem -Path $mNamikazOthers -Directory -ErrorAction SilentlyContinue
            foreach ($folder in $allFolders) {
                $insightsPath = Join-Path $folder.FullName $InsightsFileName
                if (Test-Path -LiteralPath $insightsPath -PathType Leaf) {
                    $allFolderInputs += $folder.FullName
                }
            }
        }
    }

    if (-not $allFolderInputs.Count) {
        throw "No folders with $InsightsFileName found. Use -FolderPaths to specify folders."
    }

    function Get-InsightsPath {
        param(
            [string]$FolderPath
        )

        foreach ($candidate in $defaultInsightsCandidates) {
            $candidatePath = Join-Path $FolderPath $candidate
            if (Test-Path -LiteralPath $candidatePath -PathType Leaf) {
                return $candidatePath
            }
        }

        return $null
    }

    $found = @()
    $missing = @()
    $generatedAt = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'

    foreach ($folderInput in $allFolderInputs) {
        if (-not (Test-Path -LiteralPath $folderInput -PathType Container)) {
            $missing += [pscustomobject]@{
                FolderPath = $folderInput
                Reason = "Invalid folder path"
            }
            continue
        }

        $resolvedFolder = (Resolve-Path -LiteralPath $folderInput).Path
        $insightsPath = Get-InsightsPath -FolderPath $resolvedFolder

        if (-not $insightsPath) {
            $missing += [pscustomobject]@{
                FolderPath = $resolvedFolder
                Reason = "No insights file found"
            }
            continue
        }

        $found += [pscustomobject]@{
            FolderPath = $resolvedFolder
            FolderName = Split-Path $resolvedFolder -Leaf
            InsightsPath = $insightsPath
            Content = Get-Content -LiteralPath $insightsPath -Raw
        }
    }

    $lines = @()
    $lines += "# Harvested Topic Insights"
    $lines += ""
    $lines += "Generated: $generatedAt"
    $lines += ""
    $lines += "## Summary"
    $lines += ""
    $lines += "- Folders scanned: $($allFolderInputs.Count)"
    $lines += "- Folders with insights: $($found.Count)"
    $lines += "- Missing or invalid: $($missing.Count)"
    $lines += "- Scan mode: $(if ($ScanAllFolders) { 'All M-Namikaz-Others folders' } else { 'Specific folders' })"
    $lines += ""

    if ($missing.Count) {
        $lines += "## Missing or Invalid"
        $lines += ""
        foreach ($item in $missing) {
            $lines += "- $($item.FolderPath): $($item.Reason)"
        }
        $lines += ""
    }

    if ($found.Count) {
        $lines += "## Included"
        $lines += ""
        foreach ($item in $found) {
            $lines += "### $($item.FolderName)"
            $lines += ""
            $lines += "- Folder: $($item.FolderPath)"
            $lines += "- Source: $($item.InsightsPath)"
            $lines += ""
            $lines += '```md'
            $lines += $item.Content.TrimEnd([char]13, [char]10)
            $lines += '```'
            $lines += ""
        }
    }

    $outputContent = ($lines -join [Environment]::NewLine).TrimEnd() + [Environment]::NewLine

    if ($Preview) {
        Write-Output $outputContent
        return
    }

    $outputContent | Set-Content -LiteralPath $OutputFile -Encoding UTF8
    Write-Output "WROTE: $OutputFile"
    Write-Output "Harvested $($found.Count) folders with insights"
}
catch {
    Write-Error "Harvest failed: $_"
    exit 1
}
