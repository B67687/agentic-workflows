<#
.SYNOPSIS
    Merges an approved cross-domain candidate and propagates the update.

.DESCRIPTION
    After you approve a cross-domain candidate:
    1. Reads the approved candidate from workflow/cross-domain-candidates.md
    2. Inserts it into the target doc in AI Prompting
    3. Creates back-link note in source folder's topic-insights.md
    4. Updates workflow/merge-log.md
    5. Runs propagate-to-all.ps1

.PARAMETER CandidateId
    The ID of the candidate to merge (from workflow/cross-domain-candidates.md).

.PARAMETER GeneralizedWording
    The generalized wording to use in the target doc.

.PARAMETER Preview
    Preview only, don't make changes.

.PARAMETER AutoMerge
    Automatically merge auto-merge candidates (no confirmation).

.EXAMPLE
    .\merge-and-propagate.ps1 -CandidateId "a1b2c3d4e5f6g7h8"

.EXAMPLE
    .\merge-and-propagate.ps1 -CandidateId "a1b2c3d4e5f6g7h8" -GeneralizedWording "Cognitive load theory applies to agent prompting" -Preview

.NOTES
    Author: AI Prompting
    Date: 2026-04-19
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$CandidateId,

    [string]$GeneralizedWording,

    [switch]$Preview,

    [switch]$AutoMerge
)

$scriptRoot = $PSScriptRoot
$aiPromptingRoot = Split-Path -Parent $scriptRoot
$workflowRoot = Join-Path $aiPromptingRoot "workflow"
$centralDocsDir = Join-Path $aiPromptingRoot "docs"
$crossDomainCandidatesFile = Join-Path $workflowRoot "cross-domain-candidates.md"
$mergeLogFile = Join-Path $workflowRoot "merge-log.md"

function Get-CandidateById {
    param([string]$Id)

    if (-not (Test-Path $crossDomainCandidatesFile)) {
        throw "Cross-domain candidates file not found: $crossDomainCandidatesFile"
    }

    $content = Get-Content -LiteralPath $crossDomainCandidatesFile -Raw
    $lines = $content -split "\r?\n"

    $inCandidate = $false
    $currentId = ""
    $candidateLines = @()
    $section = ""
    $topic = ""
    $status = ""
    $text = ""
    $folderName = ""
    $folderPath = ""
    $insightsPath = ""
    $confidence = 0
    $tags = @()
    $suggestedDestination = ""

    foreach ($line in $lines) {
        if ($line -match "^- Candidate ID: (.+)") {
            $currentId = $Matches[1].Trim()
            if ($currentId -eq $Id) {
                $inCandidate = $true
                $candidateLines = @()
            }
        }
        elseif ($inCandidate) {
            if ($line -match "^#### Candidate " -or ($line -match "^### " -and $currentId -ne "")) {
                break
            }
            $candidateLines += $line

            if ($line -match "^- Status: (.+)") { $status = $Matches[1].Trim() }
            if ($line -match "^- Confidence: (.+)") { $confidence = [int]($Matches[1].Trim() -replace 'Level ', '') }
            if ($line -match "^- Tags: (.+)") { $tags = $Matches[1].Trim() -split ', ' }
            if ($line -match "^- Source section: (.+)") { $section = $Matches[1].Trim() }
            if ($line -match "^- Source topic: (.+)") { $topic = $Matches[1].Trim() }
            if ($line -match "^- Folder: (.+)") { $folderPath = $Matches[1].Trim() }
            if ($line -match "^- Source: (.+)") { $insightsPath = $Matches[1].Trim() }
            if ($line -match "^- Suggested destination: (.+)") { $suggestedDestination = $Matches[1].Trim() }
            if ($line -match "^- Folder name: (.+)") { $folderName = $Matches[1].Trim() }
            if ($line -match "^\- Candidate: (.+)") { $text = $Matches[1].Trim() }
        }
    }

    if (-not $inCandidate -or $currentId -eq "") {
        return $null
    }

    return @{
        Id = $currentId
        Status = $status
        Confidence = $confidence
        Tags = $tags
        Section = $section
        Topic = $topic
        FolderPath = $folderPath
        FolderName = $folderName
        InsightsPath = $insightsPath
        SuggestedDestination = $suggestedDestination
        Text = $text
    }
}

function Get-TargetDocPath {
    param([string]$Destination)

    $dest = $Destination.ToLowerInvariant()
    if ($dest -eq "review-manually") {
        return $null
    }

    $docsMap = @{
        "ai-product-building.md" = Join-Path $centralDocsDir "ai-product-building.md"
        "core-agent-doctrine.md" = Join-Path $centralDocsDir "core-agent-doctrine.md"
        "token-efficient-prompting.md" = Join-Path $centralDocsDir "token-efficient-prompting.md"
        "daily-prompts.md" = Join-Path $centralDocsDir "daily-prompts.md"
        "prompt-templates.md" = Join-Path $centralDocsDir "prompt-templates.md"
        "cognitive-identity.md" = Join-Path $centralDocsDir "cognitive-identity.md"
    }

    if ($docsMap.ContainsKey($dest)) {
        return $docsMap[$dest]
    }

    return Join-Path $centralDocsDir "$dest.md"
}

function New-BackLinkNote {
    param(
        [string]$SourceFolderPath,
        [string]$OriginalText,
        [string]$TargetDoc,
        [string]$MergeId
    )

    $insightsPath = Join-Path $SourceFolderPath "topic-insights.md"
    if (-not (Test-Path $insightsPath)) {
        throw "Insights file not found: $insightsPath"
    }

    $generatedAt = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $backLinkContent = @()

    $backLinkContent += ""
    $backLinkContent += "---"
    $backLinkContent += "## Merged Insight"
    $backLinkContent += ""
    $backLinkContent += "| Property | Value |"
    $backLinkContent += "|----------|-------|"
    $backLinkContent += "| Merge ID | $MergeId |"
    $shortOriginal = if ($OriginalText.Length -gt 100) { $OriginalText.Substring(0, 100) + "..." } else { $OriginalText }
    $backLinkContent += "| Original | $shortOriginal |"
    $backLinkContent += "| Merged to | AI Prompting/$TargetDoc |"
    $backLinkContent += "| Merged at | $generatedAt |"
    $backLinkContent += "| Status | Merged - bidirectional link established |"
    $backLinkContent += ""
    $backLinkContent += "> This insight has been incorporated into the central AI Prompting knowledge base."
    $backLinkContent += ""
    $backLinkContent += "---"
    $backLinkContent += ""

    $existingContent = Get-Content -LiteralPath $insightsPath -Raw
    $newContent = $existingContent.TrimEnd() + ($backLinkContent -join "`n")

    return $newContent
}

function Add-ToMergeLog {
    param(
        [string]$MergeId,
        [string]$SourceFolder,
        [string]$SourceInsights,
        [string]$OriginalText,
        [string]$TargetDoc,
        [int]$Confidence,
        [string[]]$Tags,
        [string]$GeneralizedWording
    )

    $generatedAt = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

    $entry = @"
- **Merge ID**: $MergeId
  - **Source folder**: $SourceFolder
  - **Source file**: $SourceInsights
  - **Original text**: $OriginalText
  - **Target doc**: AI Prompting/$TargetDoc
  - **Confidence**: Level $Confidence
  - **Tags**: $($Tags -join ', ')
  - **Generalized wording**: $GeneralizedWording
  - **Merged at**: $generatedAt
  - **Bidirectional link**: Created in source folder

"@

    if (-not (Test-Path $mergeLogFile)) {
        $header = @"
# Merge Log

Cross-domain merge history. Records all insights that have been merged from topic folders into the central AI Prompting knowledge base.

"@
        $entry = $header + $entry
    }
    else {
        $existingContent = Get-Content -LiteralPath $mergeLogFile -Raw
        $entry = $existingContent.TrimEnd() + "`n`n" + $entry
    }

    return $entry
}

try {
    Write-Output "Looking up candidate: $CandidateId"
    $candidate = Get-CandidateById -Id $CandidateId

    if (-not $candidate) {
        throw "Candidate not found: $CandidateId"
    }

    Write-Output "Candidate found:"
    Write-Output "  - Text: $($candidate.Text)"
    Write-Output "  - Folder: $($candidate.FolderName)"
    Write-Output "  - Destination: $($candidate.SuggestedDestination)"
    Write-Output "  - Status: $($candidate.Status)"
    Write-Output "  - Confidence: Level $($candidate.Confidence)"

    if ($candidate.Status -eq "kept-local") {
        Write-Output "WARNING: This candidate is marked 'kept-local'. It won't be auto-merged."
        if (-not $AutoMerge) {
            $confirm = Read-Host "Continue anyway? (y/N)"
            if ($confirm -ne 'y') {
                Write-Output "Cancelled."
                return
            }
        }
    }

    $finalWording = if ($GeneralizedWording) { $GeneralizedWording } else { $candidate.Text }
    $targetPath = Get-TargetDocPath -Destination $candidate.SuggestedDestination

    if (-not $targetPath -or -not (Test-Path $targetPath)) {
        throw "Target doc not found or invalid: $($candidate.SuggestedDestination)"
    }

    Write-Output ""
    Write-Output "Target: $targetPath"
    Write-Output "Wording: $finalWording"

    if ($Preview) {
        Write-Output ""
        Write-Output "[PREVIEW MODE - No changes made]"
        return
    }

    Write-Output ""
    Write-Output "[Step 1] Appending to target doc..."
    $targetContent = Get-Content -LiteralPath $targetPath -Raw
    $newSection = @"

## Merged Insight $(Get-Date -Format 'yyyy-MM-dd')

**Source**: $($candidate.FolderName) $($candidate.Section)$($candidate.Topic ? " / " + $candidate.Topic : "")
**Confidence**: Level $($candidate.Confidence)$($candidate.Tags.Count -gt 0 ? " | Tags: " + ($candidate.Tags -join ', ') : "")
**Merge ID**: $($candidate.Id)

$finalWording

*This insight was cross-domain merged from: $($candidate.InsightsPath)*
"@

    $updatedTargetContent = $targetContent.TrimEnd() + $newSection + "`n"
    $updatedTargetContent | Set-Content -LiteralPath $targetPath -Encoding UTF8
    Write-Output "  ✓ Appended to target doc"

    Write-Output ""
    Write-Output "[Step 2] Creating back-link in source folder..."
    $backLinkContent = New-BackLinkNote `
        -SourceFolderPath $candidate.FolderPath `
        -OriginalText $candidate.Text `
        -TargetDoc (Split-Path $targetPath -Leaf) `
        -MergeId $candidate.Id

    $backLinkContent | Set-Content -LiteralPath (Join-Path $candidate.FolderPath "topic-insights.md") -Encoding UTF8
    Write-Output "  ✓ Back-link created in $($candidate.FolderName)"

    Write-Output ""
    Write-Output "[Step 3] Updating merge log..."
    $mergeLogEntry = Add-ToMergeLog `
        -MergeId $candidate.Id `
        -SourceFolder $candidate.FolderName `
        -SourceInsights $candidate.InsightsPath `
        -OriginalText $candidate.Text `
        -TargetDoc (Split-Path $targetPath -Leaf) `
        -Confidence $candidate.Confidence `
        -Tags $candidate.Tags `
        -GeneralizedWording $finalWording

    $mergeLogEntry | Set-Content -LiteralPath $mergeLogFile -Encoding UTF8
    Write-Output "  ✓ Merge log updated"

    Write-Output ""
    Write-Output "[Step 4] Running propagate-to-all.ps1..."
    Push-Location $aiPromptingRoot
    try {
        $result = & ".\scripts\propagate-to-all.ps1" -Apply
        Write-Output $result
    }
    finally {
        Pop-Location
    }

    Write-Output ""
    Write-Output "=== MERGE COMPLETE ==="
    Write-Output "Candidate $($candidate.Id) merged successfully."
    Write-Output "  → Target: AI Prompting/$(Split-Path $targetPath -Leaf)"
    Write-Output "  → Back-link: $($candidate.FolderName)/topic-insights.md"
    Write-Output "  → Propagation: Synced to all folders"
}
catch {
    Write-Error "Merge failed: $_"
    exit 1
}
