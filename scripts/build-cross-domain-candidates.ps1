<#
.SYNOPSIS
    Builds a cross-domain review queue from topic insights.

.DESCRIPTION
    Scans folders for topic-insights.md, extracts cross-domain candidates,
    applies confidence-based tiering, and generates a review queue.
    Tracks review state in JSON for persistence.

.PARAMETER FolderPaths
    Specific folders to scan.

.PARAMETER InsightsFileName
    Insights file name to look for.

.PARAMETER OutputFile
    Output markdown file.

.PARAMETER StateFile
    State file for review decisions.

.PARAMETER Preview
    Preview only, don't persist changes.

.PARAMETER ScanAllFolders
    Scan all folders under M-Namikaz-Others (default: true).

.EXAMPLE
    .\build-cross-domain-candidates.ps1

.EXAMPLE
    .\build-cross-domain-candidates.ps1 -Preview

.NOTES
    Author: AI Prompting
    Date: 2026-04-19
#>

[CmdletBinding()]
param(
    [string[]]$FolderPaths,

    [string]$InsightsFileName = "topic-insights.md",

    [string]$OutputFile = (Join-Path (Split-Path $PSScriptRoot -Parent) "workflow\cross-domain-candidates.md"),

    [string]$StateFile = (Join-Path (Split-Path $PSScriptRoot -Parent) "workflow\cross-domain-review-state.json"),

    [switch]$Preview,

    [switch]$ScanAllFolders = $true
)

try {
    $defaultInsightsCandidates = @(
        $InsightsFileName,
        "topic-insights.md",
        "insights.md"
    ) | Select-Object -Unique

    $preferredSections = @(
        "Transferable Lessons",
        "Mistakes To Avoid Repeating",
        "Working Rules",
        "Concrete Lessons Learned",
        "Insights",
        "Key Learnings",
        "Discoveries"
    )

    $placeholderPatterns = @(
        '^\s*Add\s+',
        '^\s*If a lesson should change how work is done in other repos too, phrase it clearly here so it can be harvested into the central library later\.?\s*$',
        '^\s*If a lesson applies to other domains too, phrase it clearly here so it can be harvested later\.?\s*$',
        '^\s*Use tags like #ai-relevant or #cross-domain to flag for cross-domain review\.?\s*$',
        '^\s*Capture new patterns, techniques, or discoveries here\.?\s*$',
        '^\s*Note confidence level: Level 1 \(speculative\), Level 2 \(plausible\), Level 3 \(confirmed\), Level 4 \(established\)\.?\s*$'
    )

    $validStatuses = @(
        "pending",
        "in-review",
        "auto-merge",
        "promoted",
        "kept-local",
        "discarded"
    )

    $crossDomainTags = @(
        '#ai-relevant',
        '#cross-domain',
        '#universal'
    )

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

    function Test-IsPlaceholderText {
        param(
            [string]$Text
        )

        foreach ($pattern in $placeholderPatterns) {
            if ($Text -match $pattern) {
                return $true
            }
        }

        return $false
    }

    function Get-DetectedTags {
        param([string]$Text)

        $detected = @()
        $lowerText = $Text.ToLowerInvariant()
        foreach ($tag in $crossDomainTags) {
            if ($lowerText -match $tag) {
                $detected += $tag
            }
        }
        return $detected
    }

    function Get-ConfidenceLevel {
        param([string]$Text)

        $lowerText = $Text.ToLowerInvariant()

        if ($lowerText -match '\b(est\.?|established|industry standard|time-tested|proven)\b') {
            return 4
        }
        if ($lowerText -match '\b(confirmed|verified|validated|multiple sources|independently)\b') {
            return 3
        }
        if ($lowerText -match '\b(plausible|likely|probably|may be)\b') {
            return 2
        }
        return 1
    }

    function Get-SuggestedDestination {
        param([string]$Text)

        $value = $Text.ToLowerInvariant()

        if ($value -match '\b(tdd|test|tests|testing|regression)\b|failing test|red/green') {
            return "ai-product-building.md"
        }

        if ($value -match '\b(token|context|compact|thread|session)\b|context window|prompt length|prompt cost') {
            return "token-efficient-prompting.md"
        }

        if ($value -match '\bprompt\b|\bteach\b|\bteaching\b|\blearn\b|\blearning\b|\bexplain\b|mental model|\bresume\b') {
            return "daily-prompts.md"
        }

        if ($value -match '\bverify\b|verification|\bscope\b|root cause|\bworkflow\b|\bmemory\b|execution lane|\bplan\b|re-plan|maintainer|upstream|\breview\b') {
            return "core-agent-doctrine.md"
        }

        if ($value -match '\bsecurity\b|\bexploit\b|\binjection\b|\bcsrf\b|\bauth\b') {
            return "core-agent-doctrine.md"
        }

        if ($value -match '\b(mcp|model context protocol)\b') {
            return "ai-product-building.md"
        }

        if ($value -match '\bagent\b|\bautonomous\b') {
            return "ai-product-building.md"
        }

        return "review-manually"
    }

    function Get-MergeStatus {
        param(
            [int]$Confidence,
            [string[]]$Tags
        )

        $hasAiTag = $Tags -contains '#ai-relevant'
        $hasUniversal = $Tags -contains '#universal'

        if ($Confidence -ge 4 -and ($hasAiTag -or $hasUniversal)) {
            return "auto-merge"
        }
        if ($Confidence -eq 3) {
            return "pending"
        }
        return "kept-local"
    }

    function Get-CandidateId {
        param(
            [string]$FolderPath,
            [string]$InsightsPath,
            [string]$Section,
            [string]$Topic,
            [string]$Text
        )

        $safeSection = if ($null -ne $Section) { $Section } else { "" }
        $safeTopic = if ($null -ne $Topic) { $Topic } else { "" }

        $normalized = @(
            $FolderPath.Trim().ToLowerInvariant(),
            $InsightsPath.Trim().ToLowerInvariant(),
            $safeSection.Trim().ToLowerInvariant(),
            $safeTopic.Trim().ToLowerInvariant(),
            $Text.Trim().ToLowerInvariant()
        ) -join "|"

        $sha = [System.Security.Cryptography.SHA256]::Create()
        try {
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($normalized)
            $hashBytes = $sha.ComputeHash($bytes)
            $hash = [System.BitConverter]::ToString($hashBytes).Replace("-", "").ToLowerInvariant()
            return $hash.Substring(0, 16)
        }
        finally {
            $sha.Dispose()
        }
    }

    function Get-ReviewStateMap {
        param([string]$Path)

        $map = @{}
        if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
            return $map
        }

        $raw = Get-Content -LiteralPath $Path -Raw
        if (-not $raw.Trim()) {
            return $map
        }

        $data = $raw | ConvertFrom-Json
        $items = @()
        if ($data.PSObject.Properties.Name -contains "items") {
            $items = @($data.items)
        }
        else {
            $items = @($data)
        }

        foreach ($item in $items) {
            if (-not $item.id) { continue }
            $map[$item.id] = $item
        }

        return $map
    }

    function Get-CleanCandidateText {
        param([string]$Line)

        $text = $Line.Trim()
        $text = $text -replace '^[\-\*\+]\s+', ''
        $text = $text -replace '^\d+\.\s+', ''
        return $text.Trim()
    }

    function Add-Or-AppendCandidate {
        param(
            [System.Collections.Generic.List[object]]$Candidates,
            [string]$Section,
            [string]$Topic,
            [string]$Line,
            [ref]$CurrentIndex
        )

        $text = Get-CleanCandidateText -Line $Line
        if (-not $text -or (Test-IsPlaceholderText -Text $text)) {
            return
        }

        $candidate = [pscustomobject]@{
            Section = $Section
            Topic = $Topic
            Text = $text
        }

        $Candidates.Add($candidate)
        $CurrentIndex.Value = $Candidates.Count - 1
    }

    function Append-ToCurrentCandidate {
        param(
            [System.Collections.Generic.List[object]]$Candidates,
            [string]$Line,
            [ref]$CurrentIndex
        )

        if ($CurrentIndex.Value -lt 0) { return }

        $text = Get-CleanCandidateText -Line $Line
        if (-not $text -or (Test-IsPlaceholderText -Text $text)) { return }

        $candidate = $Candidates[$CurrentIndex.Value]
        $candidate.Text = ($candidate.Text + " " + $text).Trim()
    }

    function Get-CrossDomainCandidates {
        param([string]$Content)

        $lines = $Content -split "\r?\n"
        $section = $null
        $topic = $null
        $inPreferredSection = $false
        $inCodeFence = $false
        $currentIndex = -1
        $candidates = [System.Collections.Generic.List[object]]::new()

        foreach ($line in $lines) {
            if ($line.Trim().StartsWith('```')) {
                $inCodeFence = -not $inCodeFence
                $currentIndex = -1
                continue
            }

            if ($inCodeFence) { continue }

            if ($line -match '^(#{2,6})\s+(.+?)\s*$') {
                $level = $Matches[1].Length
                $heading = $Matches[2].Trim()

                if ($level -eq 2) {
                    $section = $heading
                    $topic = $null
                    $inPreferredSection = $preferredSections -contains $section
                }
                elseif ($level -ge 3 -and $inPreferredSection) {
                    $topic = $heading
                }
                else {
                    $topic = $null
                }

                $currentIndex = -1
                continue
            }

            if (-not $inPreferredSection) { continue }

            if (-not $line.Trim()) {
                $currentIndex = -1
                continue
            }

            if ($line -match '^\s{2,}[\-\*\+]\s+.+$' -or $line -match '^\s{2,}\d+\.\s+.+$' -or $line -match '^\s{2,}\S.+$') {
                Append-ToCurrentCandidate -Candidates $candidates -Line $line -CurrentIndex ([ref]$currentIndex)
                continue
            }

            if ($line -match '^[\-\*\+]\s+.+$' -or $line -match '^\d+\.\s+.+$') {
                Add-Or-AppendCandidate -Candidates $candidates -Section $section -Topic $topic -Line $line -CurrentIndex ([ref]$currentIndex)
                continue
            }

            $currentIndex = -1
        }

        return $candidates
    }

    $allFolderInputs = @()

    if ($FolderPaths) {
        $allFolderInputs += $FolderPaths
    }

    if (-not $FolderPaths -and $ScanAllFolders) {
        $mNamikazOthers = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
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

    $generatedAt = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
    $folderResults = @()
    $missing = @()
    $candidateCount = 0
    $reviewStateMap = Get-ReviewStateMap -Path $StateFile
    $statusCounts = @{}
    $autoMergeCount = 0

    foreach ($status in $validStatuses) {
        $statusCounts[$status] = 0
    }

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

        $content = Get-Content -LiteralPath $insightsPath -Raw
        $rawCandidates = Get-CrossDomainCandidates -Content $content
        $candidates = @()

        foreach ($candidate in $rawCandidates) {
            $confidence = Get-ConfidenceLevel -Text $candidate.Text
            $detectedTags = Get-DetectedTags -Text $candidate.Text
            $mergeStatus = Get-MergeStatus -Confidence $confidence -Tags $detectedTags

            $candidateId = Get-CandidateId `
                -FolderPath $resolvedFolder `
                -InsightsPath $insightsPath `
                -Section $candidate.Section `
                -Topic $candidate.Topic `
                -Text $candidate.Text

            $state = $null
            if ($reviewStateMap.ContainsKey($candidateId)) {
                $state = $reviewStateMap[$candidateId]
            }

            $status = $mergeStatus
            if ($state -and $state.status -and ($validStatuses -contains $state.status)) {
                $status = $state.status
            }

            $statusCounts[$status]++
            if ($status -eq "auto-merge") { $autoMergeCount++ }

            $candidates += [pscustomobject]@{
                Id = $candidateId
                Section = $candidate.Section
                Topic = $candidate.Topic
                Text = $candidate.Text
                Confidence = $confidence
                Tags = $detectedTags
                SuggestedDestination = Get-SuggestedDestination -Text $candidate.Text
                Status = $status
                SavedDestination = if ($state) { $state.destination } else { $null }
                GeneralizedWording = if ($state) { $state.generalizedWording } else { $null }
                Notes = if ($state) { $state.notes } else { $null }
                ReviewedAt = if ($state) { $state.reviewedAt } else { $null }
            }
        }

        $candidateCount += $candidates.Count

        $folderResults += [pscustomobject]@{
            FolderPath = $resolvedFolder
            FolderName = Split-Path $resolvedFolder -Leaf
            InsightsPath = $insightsPath
            Candidates = $candidates
        }
    }

    $foldersWithCandidates = @($folderResults | Where-Object { $_.Candidates.Count -gt 0 })
    $foldersWithoutCandidates = @($folderResults | Where-Object { $_.Candidates.Count -eq 0 })

    $lines = @()
    $lines += "# Cross-Domain Candidates"
    $lines += ""
    $lines += "Generated: $generatedAt"
    $lines += ""
    $lines += "## Summary"
    $lines += ""
    $lines += "- Folders scanned: $($folderResults.Count)"
    $lines += "- Folders with candidates: $($foldersWithCandidates.Count)"
    $lines += "- Folders without candidates: $($foldersWithoutCandidates.Count)"
    $lines += "- Missing or invalid: $($missing.Count)"
    $lines += "- Total candidates: $candidateCount"
    $lines += "- State file: $StateFile"
    $lines += "- Saved review entries loaded: $($reviewStateMap.Count)"
    $lines += ""
    $lines += "### Status Breakdown"
    $lines += "- Auto-merge: $($statusCounts['auto-merge']) (Level 4 + #ai-relevant/#universal)"
    $lines += "- Pending review: $($statusCounts['pending']) (Level 3)"
    $lines += "- In review: $($statusCounts['in-review'])"
    $lines += "- Promoted: $($statusCounts['promoted'])"
    $lines += "- Kept local: $($statusCounts['kept-local']) (Level 1-2)"
    $lines += "- Discarded: $($statusCounts['discarded'])"
    $lines += ""
    $lines += "## Merge Criteria"
    $lines += ""
    $lines += "| Confidence | Tags | Action |"
    $lines += "|------------|------|--------|"
    $lines += "| Level 4 (ESTABLISHED) | + #ai-relevant or #universal | **Auto-merge** |"
    $lines += "| Level 3 (CONFIRMED) | Any | **Review queue** |"
    $lines += "| Level 1-2 (SPECULATIVE/PLAUSIBLE) | Any | **Local only** |"
    $lines += ""
    $lines += "## Review Rule"
    $lines += ""
    $lines += "Do not merge candidates verbatim. For each candidate:"
    $lines += ""
    $lines += "1. decide whether it is transferable to another domain"
    $lines += "2. generalize it into reusable language"
    $lines += "3. merge it into the smallest correct central file"
    $lines += "4. keep the folder-specific detail local if that still helps there"
    $lines += ""
    $lines += "## Cross-Domain Tags"
    $lines += ""
    $lines += "| Tag | Meaning | Auto-action |"
    $lines += "|-----|---------|------------|"
    $lines += "| #ai-relevant | Directly applicable to AI prompting | Auto-merge if Level 4, review if Level 3 |"
    $lines += "| #cross-domain | May apply to other domains | Review queue |"
    $lines += "| #universal | Applies to all domains | Auto-merge to central |"
    $lines += ""

    if ($missing.Count) {
        $lines += "## Missing or Invalid"
        $lines += ""
        foreach ($item in $missing) {
            $lines += "- $($item.FolderPath): $($item.Reason)"
        }
        $lines += ""
    }

    if ($foldersWithoutCandidates.Count) {
        $lines += "## Folders Without Candidates"
        $lines += ""
        foreach ($item in $foldersWithoutCandidates) {
            $lines += "- $($item.FolderName)"
        }
        $lines += ""
    }

    if ($foldersWithCandidates.Count) {
        $lines += "## Candidates"
        $lines += ""

        foreach ($folder in $foldersWithCandidates) {
            $lines += "### $($folder.FolderName)"
            $lines += ""
            $lines += "- Folder: $($folder.FolderPath)"
            $lines += "- Source: $($folder.InsightsPath)"
            $lines += "- Candidate count: $($folder.Candidates.Count)"
            $lines += ""

            $index = 1
            foreach ($candidate in $folder.Candidates) {
                $lines += "#### Candidate $index"
                $lines += ""
                $lines += "- Candidate ID: $($candidate.Id)"
                $lines += "- Status: $($candidate.Status)"
                $lines += "- Confidence: Level $($candidate.Confidence)"
                if ($candidate.Tags.Count -gt 0) {
                    $lines += "- Tags: $($candidate.Tags -join ', ')"
                }
                $lines += "- Source section: $($candidate.Section)"
                if ($candidate.Topic) {
                    $lines += "- Source topic: $($candidate.Topic)"
                }
                $lines += "- Candidate: $($candidate.Text)"
                $lines += "- Suggested destination: $($candidate.SuggestedDestination)"
                $lines += "- Saved destination: $(if ($candidate.SavedDestination) { $candidate.SavedDestination } else { '[none]' })"
                $lines += "- Generalized wording: $(if ($candidate.GeneralizedWording) { $candidate.GeneralizedWording } else { '[write reusable wording here]' })"
                $lines += "- Notes: $(if ($candidate.Notes) { $candidate.Notes } else { '[optional notes]' })"
                if ($candidate.ReviewedAt) {
                    $lines += "- Reviewed at: $($candidate.ReviewedAt)"
                }
                $lines += ""
                $index++
            }
        }
    }

    $outputContent = ($lines -join [Environment]::NewLine).TrimEnd() + [Environment]::NewLine

    if ($Preview) {
        Write-Output $outputContent
        return
    }

    $outputContent | Set-Content -LiteralPath $OutputFile -Encoding UTF8
    Write-Output "WROTE: $OutputFile"
    Write-Output "Found $candidateCount candidates across $($foldersWithCandidates.Count) folders"
    Write-Output "Auto-merge candidates: $autoMergeCount"
}
catch {
    Write-Error "Build failed: $_"
    exit 1
}
