<#
.SYNOPSIS
    Safely retires a topic folder: harvest lessons, promote, archive, unregister, delete.

.DESCRIPTION
    Follows the 7-step retirement workflow:
    1. Validate - confirm repo is in registry, is not Central Hub, not already Archived
    2. Harvest - collect remaining lessons from topic-insights.md
    3. Build Candidates - build cross-domain promotion queue for this repo
    4. Review - prompt user to handle promotion candidates
    5. Archive - copy durable content to archive/{RepoName}/
    6. Unregister - mark as Archived in cross-domain-registry.md
    7. Delete - remove repo folder (only with -Apply)

.PARAMETER RepoName
    Name of the folder to retire (e.g. "Noise Generator").

.PARAMETER DryRun
    Preview all steps without making changes. Default behavior without -Apply.

.PARAMETER SkipHarvest
    Skip the lesson harvest step.

.PARAMETER SkipPromotion
    Skip building promotion candidates and the review step.

.PARAMETER SkipArchive
    Skip archiving durable content.

.PARAMETER Apply
    Actually execute the retirement. Without this, script only previews.

.EXAMPLE
    .\retire-repo.ps1 -RepoName "Noise Generator" -DryRun
    # Preview everything that would happen

.EXAMPLE
    .\retire-repo.ps1 -RepoName "Noise Generator" -Apply
    # Actually retire the repo

.EXAMPLE
    .\retire-repo.ps1 -RepoName "SomeTestRepo" -SkipHarvest -Apply
    # Retire without harvesting (no lessons to collect)

.NOTES
    Author: AI Prompting
    Date: 2026-04-22
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$RepoName,

    [switch]$DryRun,

    [switch]$SkipHarvest,

    [switch]$SkipPromotion,

    [switch]$SkipArchive,

    [switch]$Apply
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
$RegistryPath = Join-Path $RootDir "workflow\cross-domain-registry.md"
$ArchiveRoot = Join-Path $RootDir "archive"

function Write-Step {
    param([string]$Message, [string]$Color = "White")
    $colors = @{
        "White"   = ""
        "Cyan"    = "Cyan"
        "Yellow"  = "Yellow"
        "Green"   = "Green"
        "Red"     = "Red"
        "Magenta" = "Magenta"
    }
    $colorCode = $colors[$Color]
    if ($Color -eq "White") {
        Write-Host $Message
    } else {
        Write-Host -ForegroundColor $colorCode $Message
    }
}

function Write-DryRun {
    param([string]$Message)
    Write-Host "[DRY-RUN] $Message" -ForegroundColor Yellow
}

$actionTaken = $false
if (-not $Apply -and -not $DryRun) {
    Write-Step "No -Apply or -DryRun specified. Running in preview mode." "Yellow"
    Write-Host "Use -Apply to execute, or -DryRun to preview without any changes." "Yellow"
    Write-Host ""
    $DryRun = $true
}

if ($DryRun) {
    Write-Step "=== DRY RUN: No changes will be made ===" "Yellow"
    Write-Host ""
}

# =============================================================================
# STEP 1: VALIDATE
# =============================================================================
Write-Step "STEP 1: Validating repo..." "Cyan"

if (-not (Test-Path $RegistryPath)) {
    throw "Registry not found: $RegistryPath"
}

$registryContent = Get-Content $RegistryPath -Raw

$entryPattern = "\| $RepoName \| ([^\|]+) \| ([^\|]+) \|"
if ($registryContent -notmatch $entryPattern) {
    throw "Repo '$RepoName' not found in registry. Check spelling or add to registry first."
}

$repoPath = $matches[1].Trim()
$currentStatus = $matches[2].Trim()

if ($currentStatus -eq "Archived") {
    throw "Repo '$RepoName' is already archived. Cannot archive twice."
}

if ($currentStatus -eq "Central Hub") {
    throw "Cannot retire the Central Hub. That is the AI Prompting folder itself."
}

if ($DryRun) {
    Write-DryRun "Found: $RepoName | $repoPath | $currentStatus"
    Write-DryRun "Would proceed to harvest, build, archive, unregister, and delete."
} else {
    Write-Step "  Found: $RepoName | $repoPath | $currentStatus" "Green"
}

Write-Host ""

# =============================================================================
# STEP 2: HARVEST
# =============================================================================
Write-Step "STEP 2: Harvesting lessons..." "Cyan"

if ($SkipHarvest) {
    if ($DryRun) {
        Write-DryRun "Skipping harvest (-SkipHarvest)"
    } else {
        Write-Step "  Skipped (-SkipHarvest)" "Yellow"
    }
} else {
    $topicInsightsPath = Join-Path $repoPath "topic-insights.md"
    if (Test-Path $topicInsightsPath) {
        if ($DryRun) {
            Write-DryRun "Would run harvest-topic-insights.ps1 for: $RepoName"
            Write-DryRun "  Source: $topicInsightsPath"
        } else {
            Write-Step "  Harvesting $topicInsightsPath..." "White"
            $harvestScript = Join-Path $ScriptDir "harvest-topic-insights.ps1"
            & $harvestScript -FolderPaths $repoPath
            $actionTaken = $true
        }
    } else {
        if ($DryRun) {
            Write-DryRun "No topic-insights.md found. Skipping harvest."
        } else {
            Write-Step "  No topic-insights.md found. Skipping." "Yellow"
        }
    }
}

Write-Host ""

# =============================================================================
# STEP 3: BUILD CANDIDATES
# =============================================================================
Write-Step "STEP 3: Building promotion candidates..." "Cyan"

if ($SkipPromotion) {
    if ($DryRun) {
        Write-DryRun "Skipping promotion (-SkipPromotion)"
    } else {
        Write-Step "  Skipped (-SkipPromotion)" "Yellow"
    }
} else {
    if ($DryRun) {
        Write-DryRun "Would run build-cross-domain-candidates.ps1 for: $RepoName"
    } else {
        Write-Step "  Building candidates..." "White"
        $candidatesScript = Join-Path $ScriptDir "build-cross-domain-candidates.ps1"
        & $candidatesScript -FolderPaths $repoPath
        $actionTaken = $true
    }
}

Write-Host ""

# =============================================================================
# STEP 4: REVIEW
# =============================================================================
Write-Step "STEP 4: Promotion review..." "Cyan"

if ($SkipPromotion) {
    if ($DryRun) {
        Write-DryRun "Skipped (promotion step was skipped)"
    } else {
        Write-Step "  Skipped (-SkipPromotion)" "Yellow"
    }
} else {
    if ($DryRun) {
        Write-DryRun "Would prompt to review and promote candidates manually"
        Write-DryRun "  Run: .\set-promotion-review-status.ps1 -CandidateId '...' -Status promoted ..."
    } else {
        Write-Step "  Review candidates at: workflow\cross-domain-candidates.md" "White"
        Write-Step "  To promote a lesson, run:" "White"
        Write-Host "  .\set-promotion-review-status.ps1 -CandidateId '...' -Status promoted -Destination 'core-agent-doctrine.md' -GeneralizedWording '...'" "Cyan"
        Write-Host ""

        $isInteractive = [Environment]::GetCommandLineArgs() -notcontains '-NonInteractive'
        if ($isInteractive) {
            $continue = Read-Host "Have you handled the promotion queue? (y to continue, n to abort)"
            if ($continue -ne 'y') {
                Write-Step "Aborted. Handle promotion queue and re-run." "Red"
                exit 1
            }
        } else {
            Write-Step "  Non-interactive mode: skipping review prompt" "Yellow"
            Write-Step "  Review candidates manually before re-running if needed." "Yellow"
        }
        $actionTaken = $true
    }
}

Write-Host ""

# =============================================================================
# STEP 5: ARCHIVE
# =============================================================================
Write-Step "STEP 5: Archiving durable content..." "Cyan"

if ($SkipArchive) {
    if ($DryRun) {
        Write-DryRun "Skipping archive (-SkipArchive)"
    } else {
        Write-Step "  Skipped (-SkipArchive)" "Yellow"
    }
} else {
    $archivePath = Join-Path $ArchiveRoot $RepoName
    if (Test-Path $archivePath) {
        if ($DryRun) {
            Write-DryRun "Archive already exists: $archivePath"
        } else {
            Write-Step "  Archive already exists: $archivePath" "Yellow"
        }
    } else {
        if ($DryRun) {
            Write-DryRun "Would create archive: $archivePath"
            Write-DryRun "  Would copy:"
            Write-DryRun "    - topic-insights.md (if exists)"
            Write-DryRun "    - README.md (if exists)"
            Write-DryRun "    - Any durable artifacts"
            Write-DryRun "  Would create README.md in archive with:"
            Write-DryRun "    - Repo name, date retired, status"
        } else {
            Write-Step "  Creating archive: $archivePath" "White"
            New-Item -ItemType Directory -Path $archivePath -Force | Out-Null

            $filesToCopy = @(
                "topic-insights.md",
                "README.md",
                "AGENTS.md"
            )

            foreach ($file in $filesToCopy) {
                $src = Join-Path $repoPath $file
                if (Test-Path $src) {
                    Copy-Item $src (Join-Path $archivePath $file) -Force
                    Write-Step "    Copied: $file" "Green"
                }
            }

            $retireDate = Get-Date -Format "yyyy-MM-dd"
            $readmeContent = @"
# $RepoName

**Retired:** $retireDate
**Original Path:** $repoPath
**Status:** Archived

## What This Was

[Describe what this repo was for]

## Why It Was Retired

[Describe why it was retired]

## Durable Content Archived Here

- topic-insights.md (lessons harvested to hub)
- README.md (original description)
- AGENTS.md (original instructions)

## Related Central Docs

Any lessons promoted from this repo would be linked from:
- `docs/core-agent-doctrine.md`
- `docs/daily-prompts.md`
- Other relevant central docs

---
*Archived by retire-repo.ps1 on $retireDate*
"@

            Set-Content -Path (Join-Path $archivePath "README.md") -Value $readmeContent
            Write-Step "    Created archive README.md" "Green"
            $actionTaken = $true
        }
    }
}

Write-Host ""

# =============================================================================
# STEP 6: UNREGISTER
# =============================================================================
Write-Step "STEP 6: Unregistering from registry..." "Cyan"

if ($DryRun) {
    Write-DryRun "Would change status from '$currentStatus' to 'Archived'"
    Write-DryRun "Would keep registry entry as historical record"
} else {
    $registryContent = Get-Content $RegistryPath -Raw
    $retireDate = Get-Date -Format "yyyy-MM-dd"
    $pattern = "(\| $RepoName \| [^\|]+ \| )$currentStatus(\|)"
    if ($registryContent -match $pattern) {
        $newContent = $registryContent -replace $pattern, "`$1Archived`$2"
        Set-Content -Path $RegistryPath -Value $newContent
        Write-Step "  Status changed to 'Archived'" "Green"
    } else {
        Write-Step "  Could not find matching registry entry. Manual update may be needed." "Yellow"
    }
    $actionTaken = $true
}

Write-Host ""

# =============================================================================
# STEP 7: DELETE
# =============================================================================
Write-Step "STEP 7: Deleting repo folder..." "Cyan"

if ($DryRun) {
    Write-DryRun "Would delete: $repoPath"
} else {
    if (Test-Path $repoPath) {
        Remove-Item -LiteralPath $repoPath -Recurse -Force
        Write-Step "  Deleted: $repoPath" "Green"
    } else {
        Write-Step "  Path not found (already deleted?): $repoPath" "Yellow"
    }
}

Write-Host ""

# =============================================================================
# SUMMARY
# =============================================================================
Write-Step "=== SUMMARY ===" "Cyan"
if ($DryRun) {
    Write-Host "Dry run complete. No changes made." "Yellow"
    Write-Host ""
    Write-Host "To actually retire '$RepoName', run:" "White"
    Write-Host "  .\retire-repo.ps1 -RepoName `"$RepoName`" -Apply" "Cyan"
} else {
    Write-Step "Repo '$RepoName' has been retired." "Green"
    Write-Host ""
    Write-Host "  Archive:    $archivePath" "White"
    Write-Host "  Registry:   Status changed to Archived" "White"
    Write-Host "  Deleted:    $repoPath" "White"
    if ($actionTaken -or $SkipPromotion) {
        Write-Host ""
        Write-Host "Note: Some steps were skipped or had no content to process." "Yellow"
    }
}
