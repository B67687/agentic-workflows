<#
.SYNOPSIS
    Propagates templates to all topic folders in M-Namikaz-Others.

.DESCRIPTION
    This script propagates instruction templates from AI Prompting to all folders
    in the M-Namikaz-Others workspace. It supports intelligent merging to preserve
    folder-specific customizations while keeping template sections up to date.

    Standard Folder Structure:
    [Topic-Folder]/
    ├── AGENTS.md, topic-insights.md, git-github-best-practices.md, .cleanup-protect (propagated)
    ├── [folder-name]-content/ (mandatory primary operating area, created if missing)
    └── meta/ (optional topic-specific files, created only when needed)

    Features:
    - Discovers all subfolders automatically
    - Intelligent merge: preserves custom sections, adds missing template sections
    - Creates the mandatory [folder-name]-content/ primary operating folder when missing
    - Syncs propagated templates only (files with Managed-By marker)
    - Keeps meta/ optional and protects meta/ and content/ folders from propagation
    - Tracks last sync time for session start checks

.PARAMETER Check
    Show status only - display which folders need attention without making changes.

.PARAMETER Force
    Overwrite unmanaged files (those without the Managed-By marker).
    Normally these are skipped to protect custom files.
    Use with -Apply to actually overwrite.

.PARAMETER Apply
    If not specified, runs in preview mode (shows what would be changed).

.PARAMETER SyncFile
    Path to the sync state file (default: ../workflow/sync-state.json).

.PARAMETER Folders
    Optional: specific folders to sync (otherwise syncs all).

.PARAMETER SkipInsights
    Skip topic-insights.md propagation (only sync AGENTS.md).

.EXAMPLE
    .\propagate-to-all.ps1 -Check
    # Show status of all folders without making changes

.EXAMPLE
    .\propagate-to-all.ps1 -Preview
    # Preview what would be synced without making changes

.EXAMPLE
    .\propagate-to-all.ps1 -Apply
    # Actually apply the sync to all folders

.EXAMPLE
    .\propagate-to-all.ps1 -Force -Apply
    # Force overwrite unmanaged files
#>

[CmdletBinding()]
param(
    [switch]$Check,

    [switch]$Force,

    [switch]$Apply,

    [string]$SyncFile,

    [string[]]$Folders,

    [switch]$SkipLessons,

    [switch]$Preview
)

$ErrorActionPreference = "Continue"
$IsPreview = -not $Preview -and -not $Apply
$IsCheck = $Check

try {

# Paths
$ScriptDir = $PSScriptRoot
$TemplatesDir = Join-Path (Split-Path $ScriptDir) "propagate-templates"
# Go up TWO levels: scripts -> AI Prompting -> M-Namikaz-Others
$ParentDir = Split-Path (Split-Path $ScriptDir)

if (-not $SyncFile) {
    $SyncFile = Join-Path (Split-Path $ScriptDir -Parent) "workflow\sync-state.json"
}

# Discover all templates dynamically (*.template.md and *.template.ps1 files)
$TemplateFiles = Get-ChildItem -Path $TemplatesDir -Recurse -Include "*.template.md", "*.template.ps1", "*.template.json" -ErrorAction SilentlyContinue
if (-not $TemplateFiles) {
    throw "No templates found in $TemplatesDir"
}

# Build template mapping: source file -> target file (remove .template. from name)
$Templates = @{}
foreach ($t in $TemplateFiles) {
    $targetName = if ($t.Name -eq ".cleanup-protect.template.md") {
        ".cleanup-protect"
    }
    else {
        $t.Name.Replace('.template.', '.')
    }
    $Templates[$t.FullName] = $targetName
}

Write-Host "Discovered $($Templates.Count) template(s): $($Templates.Values -join ', ')" -ForegroundColor Cyan

# Backward compatibility: map template names to paths
$AgentsTemplatePath = $Templates.Keys | Where-Object { $_ -match "AGENTS\.template\.md" } | Select-Object -First 1
$LessonsTemplatePath = $Templates.Keys | Where-Object { $_ -match "topic-insights\.template\.md" } | Select-Object -First 1

# Version and managed marker
$ManagedMarker = "Managed-By: AI-Prompting-Library"
$TemplateVersionPattern = "<!-- Template: (\w+) -->"
$CustomSectionMarker = "<!-- Custom-Section: "

function Get-TemplateVersion {
    param([string]$Content, [string]$TemplateName)
    if ($Content -match "<!-- Template: $TemplateName -->") {
        return $Matches[1]
    }
    return $null
}

function Get-CustomSections {
    param([string]$Content)
    
    $customSections = @()
    $lines = $Content -split "`r?`n"
    $inCustom = $false
    $currentSection = @()
    
    foreach ($line in $lines) {
        if ($line -match "<!-- Custom-Section: (.+) -->") {
            if ($currentSection.Count -gt 0 -and $inCustom) {
                $customSections += ,@($currentSection)
            }
            $inCustom = $true
            $currentSection = @($line)
        }
        elseif ($inCustom -and $line.Trim() -eq "<!-- End-Custom -->") {
            $currentSection += $line
            $customSections += ,@($currentSection)
            $currentSection = @()
            $inCustom = $false
        }
        elseif ($inCustom) {
            $currentSection += $line
        }
    }
    
    if ($currentSection.Count -gt 0) {
        $customSections += ,@($currentSection)
    }
    
    return $customSections
}

function Merge-AGENTS {
    param(
        [string]$TemplateContent,
        [string]$ExistingContent
    )
    
    # If no existing content, return template
    if (-not $ExistingContent) {
        return $TemplateContent
    }
    
    # Get custom sections from existing
    $customSections = Get-CustomSections -Content $ExistingContent
    
    # Parse template structure
    $templateLines = $TemplateContent -split "`r?`n"
    $mergedLines = @()
    
    # Add template header and sections
    foreach ($line in $templateLines) {
        $mergedLines += $line
    }
    
    # Add custom sections with markers
    if ($customSections.Count -gt 0) {
        $mergedLines += ""
        $mergedLines += "## Custom Sections (preserved)"
        $mergedLines += ""
        foreach ($section in $customSections) {
            foreach ($line in $section) {
                $mergedLines += $line
            }
            $mergedLines += ""
        }
    }
    
    return ($mergedLines -join "`n")
}

function ConvertTo-KebabCase {
    param([string]$Name)

    $value = $Name.Trim()
    $value = $value -creplace '([A-Z]+)([A-Z][a-z])', '$1-$2'
    $value = $value -creplace '([a-z0-9])([A-Z])', '$1-$2'
    $value = $value -replace '[^A-Za-z0-9]+', '-'
    $value = $value.Trim('-').ToLowerInvariant()

    return $value
}

function Ensure-ContentFolder {
    param(
        [string]$FolderPath,
        [switch]$Preview
    )

    $folderName = Split-Path $FolderPath -Leaf
    $contentFolderName = "$(ConvertTo-KebabCase -Name $folderName)-content"
    $contentFolderPath = Join-Path $FolderPath $contentFolderName

    if (Test-Path $contentFolderPath) {
        return [PSCustomObject]@{
            File = $contentFolderName
            Status = "UNCHANGED (content folder exists)"
            Path = $contentFolderPath
        }
    }

    if ($Preview) {
        return [PSCustomObject]@{
            File = $contentFolderName
            Status = "CREATE content folder preview"
            Path = $contentFolderPath
        }
    }

    New-Item -ItemType Directory -Path $contentFolderPath -Force | Out-Null
    return [PSCustomObject]@{
        File = $contentFolderName
        Status = "CREATED content folder"
        Path = $contentFolderPath
    }
}

function Sync-Folder {
    param(
        [string]$FolderPath,
        [switch]$Preview
    )
    
    $results = @()
    $agentsTarget = Join-Path $FolderPath "AGENTS.md"
    $lessonsTarget = Join-Path $FolderPath "topic-insights.md"

    $results += Ensure-ContentFolder -FolderPath $FolderPath -Preview:$Preview
    
    # Read templates
    $agentsTemplate = Get-Content $AgentsTemplatePath -Raw
    $lessonsTemplate = if (-not $SkipLessons) { Get-Content $LessonsTemplatePath -Raw } else { $null }
    
    # Process AGENTS.md
    if (Test-Path $agentsTarget) {
        $existingAgents = Get-Content $agentsTarget -Raw
        
        # Check if managed
        if ($existingAgents -notmatch $ManagedMarker) {
            if ($Force) {
                # Force overwrite - add marker and create fresh
                $agentsTemplate | Set-Content $agentsTarget -Encoding UTF8
                $results += [PSCustomObject]@{
                    File = "AGENTS.md"
                    Status = "FORCE CREATE"
                    Path = $agentsTarget
                }
            }
            elseif ($IsCheck) {
                $results += [PSCustomObject]@{
                    File = "AGENTS.md"
                    Status = "NEEDS MARKER (unmanaged)"
                    Path = $agentsTarget
                }
            }
            else {
                $results += [PSCustomObject]@{
                    File = "AGENTS.md"
                    Status = "SKIP (unmanaged)"
                    Path = $agentsTarget
                }
            }
        }
        else {
            # Merge
            $merged = Merge-AGENTS -TemplateContent $agentsTemplate -ExistingContent $existingAgents
            
            if ($merged -eq $existingAgents) {
                $results += [PSCustomObject]@{
                    File = "AGENTS.md"
                    Status = "UNCHANGED"
                    Path = $agentsTarget
                }
            }
            elseif ($Preview) {
                $results += [PSCustomObject]@{
                    File = "AGENTS.md"
                    Status = "MERGE preview"
                    Path = $agentsTarget
                }
            }
            else {
                $merged | Set-Content $agentsTarget -Encoding UTF8
                $results += [PSCustomObject]@{
                    File = "AGENTS.md"
                    Status = "MERGED"
                    Path = $agentsTarget
                }
            }
        }
    }
    else {
        if ($Preview) {
            $results += [PSCustomObject]@{
                File = "AGENTS.md"
                Status = "CREATE preview"
                Path = $agentsTarget
            }
        }
        else {
            $agentsTemplate | Set-Content $agentsTarget -Encoding UTF8
            $results += [PSCustomObject]@{
                File = "AGENTS.md"
                Status = "CREATED"
                Path = $agentsTarget
            }
        }
    }
    
    # Process topic-insights.md
    if (-not $SkipLessons) {
        if (Test-Path $lessonsTarget) {
            $existingLessons = Get-Content $lessonsTarget -Raw

            # Check for old template marker - if found, refresh with new template
            $hasOldMarker = $existingLessons -match 'Template:\s*Repo-Lessons'

            if ($existingLessons -notmatch $ManagedMarker -or $hasOldMarker) {
                if ($Force -or $hasOldMarker) {
                    $lessonsTemplate | Set-Content $lessonsTarget -Encoding UTF8
                    $statusMsg = if ($hasOldMarker) { "TEMPLATE REFRESH" } else { "FORCE CREATE" }
                    $results += [PSCustomObject]@{
                        File = "topic-insights.md"
                        Status = $statusMsg
                        Path = $lessonsTarget
                    }
                }
                elseif ($IsCheck) {
                    $results += [PSCustomObject]@{
                        File = "topic-insights.md"
                        Status = "NEEDS MARKER (unmanaged)"
                        Path = $lessonsTarget
                    }
                }
                else {
                    $results += [PSCustomObject]@{
                        File = "topic-insights.md"
                        Status = "SKIP (unmanaged)"
                        Path = $lessonsTarget
                    }
                }
            }
            else {
                if ($Preview) {
                    $results += [PSCustomObject]@{
                        File = "topic-insights.md"
                        Status = "UNCHANGED (already managed)"
                        Path = $lessonsTarget
                    }
                }
                else {
                    $results += [PSCustomObject]@{
                        File = "topic-insights.md"
                        Status = "UNCHANGED (already managed)"
                        Path = $lessonsTarget
                    }
                }
            }
        }
        else {
            if ($Preview) {
                $results += [PSCustomObject]@{
                    File = "topic-insights.md"
                    Status = "CREATE preview"
                    Path = $lessonsTarget
                }
            }
            else {
                $lessonsTemplate | Set-Content $lessonsTarget -Encoding UTF8
                $results += [PSCustomObject]@{
                    File = "topic-insights.md"
                    Status = "CREATED"
                    Path = $lessonsTarget
                }
            }
        }
    }
    
    return $results
}

# Discover folders
$allFolders = @()

if ($Folders -and $Folders.Count -gt 0) {
    foreach ($f in $Folders) {
        $path = Join-Path $ParentDir $f
        if (Test-Path $path) {
            $allFolders += $path
        }
    }
}
else {
    # Get all subfolders in M-Namikaz-Others (excluding AI Prompting itself)
    $allFolders = Get-ChildItem $ParentDir -Directory | 
        Where-Object { $_.Name -ne "AI Prompting" -and $_.Name -notlike ".*" } | 
        Select-Object -ExpandProperty FullName
}

Write-Host "Found $($allFolders.Count) folders to process" -ForegroundColor Cyan

# Sync each folder
$allResults = @()
$syncTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$resultCount = 0
foreach ($folder in $allFolders) {
    Write-Host "Processing: $folder" -ForegroundColor Yellow
    
    $results = Sync-Folder -FolderPath $folder -Preview:$IsPreview
    foreach ($r in $results) {
        $allResults += $r
        $resultCount++
    }
}
Write-Host "Processed $resultCount file operations" -ForegroundColor Gray

# Process additional templates (not AGENTS or topic-insights)
$additionalTemplates = $Templates.Keys | Where-Object { $_ -notmatch "AGENTS\.template|topic-insights\.template" }
foreach ($templatePath in $additionalTemplates) {
    $targetName = $Templates[$templatePath]
    
    # Determine target filename based on extension
    if ($targetName -match "^\.cleanup-protect$") {
        $targetFile = ".cleanup-protect"
    }
    elseif ($targetName -match "\.ps1$") {
        $targetFile = $targetName  # .ps1 files keep their extension
    }
    elseif ($targetName -match "\.md$") {
        $targetFile = $targetName  # .md files already have extension
    }
    elseif ($targetName -match "\.json$") {
        $targetFile = $targetName  # .json files already have extension
    }
    else {
        $targetFile = "$targetName.md"
    }
    
    Write-Host ""
    Write-Host "=== $targetFile Summary ===" -ForegroundColor Cyan
    
    $templateContent = Get-Content $templatePath -Raw
    $templateVersion = if ($templateContent -match "<!-- Template: (\w+) -->") { $Matches[1] } else { "Unknown" }
    
    $count = 0
    foreach ($folder in $allFolders) {
        $targetPath = Join-Path $folder $targetFile
        
        if (-not (Test-Path $folder)) { continue }
        
        if (Test-Path $targetPath) {
            $existing = Get-Content $targetPath -Raw -ErrorAction SilentlyContinue
            if ($existing -match $ManagedMarker) {
                # Managed file → use merge to preserve custom sections
                $merged = Merge-AGENTS -TemplateContent $templateContent -ExistingContent $existing
                if ($merged -eq $existing) {
                    Write-Host "  UNCHANGED (already managed): $folder" -ForegroundColor Gray
                }
                else {
                    if ($IsPreview) {
                        Write-Host "  MERGE preview: $folder" -ForegroundColor Cyan
                    }
                    else {
                        $merged | Set-Content $targetPath -Encoding UTF8
                        Write-Host "  MERGED: $folder" -ForegroundColor Green
                    }
                }
            }
            else {
                if ($Force -or $IsPreview) {
                    Write-Host "  WOULD OVERWRITE: $folder" -ForegroundColor Magenta
                    if ($Force -and -not $IsPreview) {
                        $templateContent | Set-Content $targetPath -Encoding UTF8
                    }
                }
                else {
                    Write-Host "  SKIP (unmanaged): $folder" -ForegroundColor Yellow
                }
            }
        }
        else {
            if ($IsPreview) {
                Write-Host "  PREVIEW CREATE: $folder" -ForegroundColor Cyan
            }
            else {
                $templateContent | Set-Content $targetPath -Encoding UTF8
                Write-Host "  CREATED: $folder" -ForegroundColor Green
            }
        }
        $count++
    }
    
    if ($count -eq 0) {
        Write-Host "  No folders processed" -ForegroundColor Yellow
    }
}

# Summary by file type
$agentsResults = $allResults | Where-Object { $_.File -eq "AGENTS.md" }
$lessonsResults = $allResults | Where-Object { $_.File -eq "topic-insights.md" }

Write-Host ""
Write-Host "=== AGENTS.md Summary ===" -ForegroundColor Cyan
if ($agentsResults) {
    $agentsResults | Group-Object Status | ForEach-Object {
        $count = $_.Group.Count
        $status = $_.Group[0].Status
        $color = "Green"
        if ($status -match "UNCHANGED") { $color = "Gray" }
        elseif ($status -match "SKIP|NEEDS MARKER") { $color = "DarkYellow" }
        elseif ($status -match "CHECK") { $color = "Cyan" }
        elseif ($status -match "FORCE") { $color = "Magenta" }
        Write-Host "  $status ($count)" -ForegroundColor $color
    }
}
else {
    Write-Host "  No AGENTS.md files processed" -ForegroundColor Yellow
}

if (-not $SkipLessons) {
    Write-Host ""
    Write-Host "=== topic-insights.md Summary ===" -ForegroundColor Cyan
    if ($lessonsResults) {
        $lessonsResults | Group-Object Status | ForEach-Object {
            $count = $_.Group.Count
            $status = $_.Group[0].Status
            $color = "Green"
            if ($status -match "UNCHANGED") { $color = "Gray" }
            elseif ($status -match "SKIP|NEEDS MARKER") { $color = "DarkYellow" }
            elseif ($status -match "CHECK") { $color = "Cyan" }
            elseif ($status -match "FORCE") { $color = "Magenta" }
            Write-Host "  $status ($count)" -ForegroundColor $color
        }
    }
    else {
        Write-Host "  No topic-insights.md files processed" -ForegroundColor Yellow
    }
}

# Update sync state
$state = @{
    lastSync = $syncTime
    syncedFolders = $allFolders.Count
    templateVersion = "1.0"
}

if ($Apply) {
    $state | ConvertTo-Json | Set-Content $SyncFile -Encoding UTF8
    Write-Host ""
    Write-Host "Sync state saved to: $SyncFile" -ForegroundColor Cyan
}
else {
    Write-Host ""
    Write-Host "Running in PREVIEW mode. Re-run with -Apply to apply changes." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
}
catch {
    Write-Error "Propagate failed: $_"
    exit 1
}
