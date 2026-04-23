<#
.SYNOPSIS
    Syncs managed project instruction files to selected repositories.

.DESCRIPTION
    Applies the central AGENTS and topic-insights templates to explicit repo paths
    or a repo-list file. Existing unmanaged files are skipped unless
    -UpdateUnmanaged is provided.

.PARAMETER RepoPaths
    One or more repository or topic folder paths.

.PARAMETER RepoListFile
    Text file containing one target path per line.

.PARAMETER LessonsFileName
    Target lessons file name. Defaults to topic-insights.md.

.PARAMETER CreateMissing
    Create missing managed files.

.PARAMETER UpdateUnmanaged
    Update files even when they do not contain the managed marker.

.PARAMETER Preview
    Report intended actions without writing files.

.EXAMPLE
    .\scripts\sync-project-instructions.ps1 -RepoPaths "M:\M-Namikaz-Others\Example" -CreateMissing -Preview
#>

param(
    [string[]]$RepoPaths,

    [string]$RepoListFile,

    [string]$LessonsFileName = "topic-insights.md",

    [switch]$CreateMissing,

    [switch]$UpdateUnmanaged,

    [switch]$Preview
)

try {
$scriptDir = Split-Path $PSScriptRoot -Parent
$templateDir = Join-Path $scriptDir "propagate-templates"
$agentsTemplatePath = Join-Path $templateDir "AGENTS.template.md"
$lessonsTemplatePath = Join-Path $templateDir "topic-insights.template.md"
$managedMarker = "<!-- Managed-By: AI-Prompting-Library -->"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

foreach ($templatePath in @($agentsTemplatePath, $lessonsTemplatePath)) {
    if (-not (Test-Path -LiteralPath $templatePath)) {
        throw "Missing template file: $templatePath"
    }
}

$allRepoInputs = @()

if ($RepoPaths) {
    $allRepoInputs += $RepoPaths
}

if ($RepoListFile) {
    if (-not (Test-Path -LiteralPath $RepoListFile)) {
        throw "Repo list file not found: $RepoListFile"
    }

    $allRepoInputs += Get-Content -LiteralPath $RepoListFile |
        Where-Object { $_.Trim() -and -not $_.Trim().StartsWith("#") }
}

if (-not $allRepoInputs.Count) {
    throw "Provide -RepoPaths or -RepoListFile."
}

$agentsTemplate = (Get-Content -LiteralPath $agentsTemplatePath -Raw).Replace("[LESSONS_FILE_NAME]", $LessonsFileName)
$lessonsTemplate = Get-Content -LiteralPath $lessonsTemplatePath -Raw

function Sync-ManagedFile {
    param(
        [string]$TargetPath,
        [string]$Content
    )

    if (-not (Test-Path -LiteralPath $TargetPath)) {
        if (-not $CreateMissing) {
            Write-Output "SKIP missing: $TargetPath"
            return
        }

        if ($Preview) {
            Write-Output "CREATE preview: $TargetPath"
            return
        }

        $parent = Split-Path -Parent $TargetPath
        if ($parent -and -not (Test-Path -LiteralPath $parent)) {
            New-Item -ItemType Directory -Path $parent | Out-Null
        }

        $Content | Set-Content -LiteralPath $TargetPath -Encoding UTF8
        Write-Output "CREATED: $TargetPath"
        return
    }

    $currentContent = Get-Content -LiteralPath $TargetPath -Raw

    if ($currentContent -eq $Content) {
        Write-Output "UNCHANGED: $TargetPath"
        return
    }

    $isManaged = $currentContent.Contains($managedMarker)
    if (-not $isManaged -and -not $UpdateUnmanaged) {
        Write-Output "SKIP unmanaged: $TargetPath"
        return
    }

    if ($Preview) {
        Write-Output "UPDATE preview: $TargetPath"
        return
    }

    $backupPath = "$TargetPath.$timestamp.bak"
    Copy-Item -LiteralPath $TargetPath -Destination $backupPath
    $Content | Set-Content -LiteralPath $TargetPath -Encoding UTF8
    Write-Output "UPDATED: $TargetPath"
    Write-Output "BACKUP: $backupPath"
}

foreach ($repoInput in $allRepoInputs) {
    if (-not (Test-Path -LiteralPath $repoInput -PathType Container)) {
        Write-Output "SKIP invalid repo path: $repoInput"
        continue
    }

    $resolvedRepo = (Resolve-Path -LiteralPath $repoInput).Path

    Write-Output "==> $resolvedRepo"

    Sync-ManagedFile -TargetPath (Join-Path $resolvedRepo "AGENTS.md") -Content $agentsTemplate
    Sync-ManagedFile -TargetPath (Join-Path $resolvedRepo $LessonsFileName) -Content $lessonsTemplate
}
}
catch {
    Write-Error "Sync failed: $_"
    exit 1
}
