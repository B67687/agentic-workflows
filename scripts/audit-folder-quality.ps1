<#
.SYNOPSIS
    Audits active authored files for quality and context-budget standards.

.DESCRIPTION
    Recursively audits the AI Prompting hub. By default it scans active authored files:
    root files, docs, research, scripts, propagate-templates, and personal-voice root files.

    Generated workflow snapshots, archive/raw, and personal writing samples are excluded by default.
    Use -IncludeArchive or -IncludeGenerated to widen the scan.

.PARAMETER IncludeArchive
    Include curated archive files, excluding archive/raw unless IncludeGenerated is also set.

.PARAMETER IncludeGenerated
    Include generated workflow files and raw archive snapshots.

.EXAMPLE
    .\scripts\audit-folder-quality.ps1

.EXAMPLE
    .\scripts\audit-folder-quality.ps1 -Verbose

.EXAMPLE
    .\scripts\audit-folder-quality.ps1 -IncludeArchive
#>

[CmdletBinding()]
param(
    [switch]$IncludeArchive,
    [switch]$IncludeGenerated
)

$ErrorActionPreference = 'Continue'
$ScriptDir = Split-Path -Parent $PSScriptRoot

$contextBudgets = @{
    'AGENTS.md' = 220
    'README.md' = 150
    'docs/workspace-system-overview.md' = 240
    'research/research-log.md' = 500
    'docs/prompt-templates.md' = 350
}

$generatedRelative = @(
    'workflow/harvested-topic-insights.md',
    'workflow/cross-domain-candidates.md',
    'workflow/sync-state.json'
)

function Convert-ToRelativePath {
    param([string]$Path)
    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $fullBase = [System.IO.Path]::GetFullPath($ScriptDir)
    if ($fullPath -eq $fullBase) { return '' }
    if ($fullPath.StartsWith($fullBase + [System.IO.Path]::DirectorySeparatorChar)) {
        $relative = $fullPath.Substring($fullBase.Length + 1)
    } else {
        $relative = $Path
    }
    return ($relative -replace '\\', '/')
}

function Test-IsExcluded {
    param([System.IO.FileInfo]$File)

    $relative = Convert-ToRelativePath $File.FullName

    if ($relative -match '^\.git/') { return $true }
    if ($relative -match '^personal-voice/samples/') { return $true }

    if ($relative -match '^archive/raw/' -and -not $IncludeGenerated) { return $true }
    if ($relative -match '^archive/' -and -not $IncludeArchive -and -not $IncludeGenerated) { return $true }

    if ($generatedRelative -contains $relative -and -not $IncludeGenerated) { return $true }

    return $false
}

function Get-AuditFiles {
    $rootFiles = Get-ChildItem -Path $ScriptDir -File -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -in @('.md', '.json') -or $_.Name -eq '.rgignore' }

    $dirs = @('docs', 'research', 'scripts', 'propagate-templates', 'personal-voice')
    if ($IncludeArchive -or $IncludeGenerated) { $dirs += 'archive' }
    if ($IncludeGenerated) { $dirs += 'workflow' }

    $nestedFiles = foreach ($dir in $dirs) {
        $full = Join-Path $ScriptDir $dir
        if (Test-Path -LiteralPath $full) {
            if ($dir -eq 'personal-voice') {
                Get-ChildItem -Path $full -File -Force -ErrorAction SilentlyContinue
            } else {
                Get-ChildItem -Path $full -Recurse -File -Force -ErrorAction SilentlyContinue
            }
        }
    }

    @($rootFiles + $nestedFiles) |
        Where-Object { $_ -and -not (Test-IsExcluded $_) } |
        Sort-Object FullName -Unique
}

function Get-FileCategory {
    param([string]$FilePath)

    $filename = Split-Path $FilePath -Leaf

    if ($filename -match '\.template\.') { return 'template' }
    if ($filename -match '\.ps1$') { return 'script' }
    if ($filename -match '\.sh$') { return 'shell-script' }
    if ($filename -match '\.md$') { return 'markdown' }
    if ($filename -match '\.json$') { return 'json' }
    if ($filename -match '^\.rgignore$') { return 'config' }
    if ($filename -match '\.txt$') { return 'config' }

    return 'other'
}

function Test-FileNaming {
    param([string]$FilePath, [string]$Category)

    $filename = Split-Path $FilePath -Leaf
    $errors = @()

    $standardExemptions = @(
        'AGENTS.md',
        'README.md',
        'HISTORY.md',
        'LICENSE',
        'CONTRIBUTING.md',
        'SECURITY.md',
        'CHANGELOG.md',
        'STATS.md',
        'CODE_OF_CONDUCT.md',
        'VOICE-PROFILE.md',
        'STYLE-INJECT.md',
        'CORRECTIONS.log.md',
        'CONTEXT.md',
        'EARLY-HISTORY-WITH-CODEX.md',
        'MIDDLE-HISTORY-WITH-CODEX.md',
        'LATE-HISTORY-WITH-CODEX.md',
        'AGENTS.template.md',
        'HISTORY.template.md'
    )

    if ($filename -match '\s') {
        $errors += "filename contains spaces: $filename"
    }
    if ($Category -eq 'script' -and $filename -cnotmatch '\.ps1$') {
        $errors += "script file missing .ps1 extension"
    }
    if ($Category -eq 'markdown' -and $filename -cnotmatch '\.md$') {
        $errors += "markdown file missing .md extension"
    }
    if ($Category -eq 'template' -and $filename -cnotmatch '\.template\.') {
        $errors += "template file missing .template. in name"
    }
    if ($Category -eq 'json' -and $filename -cnotmatch '\.json$') {
        $errors += "json file missing .json extension"
    }
    if ($filename -cmatch '[A-Z]' -and $standardExemptions -notcontains $filename) {
        $errors += "filename not lowercase-kebab: $filename"
    }

    return $errors
}

function Test-ContextBudget {
    param([string]$FilePath)

    $warnings = @()
    $relative = Convert-ToRelativePath $FilePath

    if ($contextBudgets.ContainsKey($relative)) {
        $lineCount = (Get-Content -LiteralPath $FilePath -ErrorAction SilentlyContinue | Measure-Object -Line).Lines
        $budget = $contextBudgets[$relative]
        if ($lineCount -gt $budget) {
            $warnings += "context budget exceeded: $lineCount lines > $budget line budget"
        }
    }

    return $warnings
}

function Test-ScriptQuality {
    param([string]$FilePath)

    $errors = @()
    $warnings = @()
    $content = Get-Content -LiteralPath $FilePath -Raw -ErrorAction SilentlyContinue

    if (-not $content) {
        return @{ errors = @('empty or unreadable file'); warnings = @() }
    }

    if ($content -notmatch '(?s)^\s*(#.*?\r?\n\s*)*(<#.*?#>\s*)?(\[CmdletBinding\([^\)]*\)\]\s*)?param\s*\(') {
        $warnings += 'missing top-level param() block'
    }
    if ($content -notmatch '<#') {
        $warnings += 'missing help comment block (<#)'
    } elseif ($content -notmatch '\.SYNOPSIS') {
        $warnings += 'help comment missing .SYNOPSIS'
    }
    if ($content -notmatch 'try\s*\{') {
        $warnings += 'missing try/catch error handling'
    }
    if ($content -match '[A-Z]:\\[^\\]+\\[^\\]+' -and $content -notmatch '\$ScriptDir|\$PSScriptRoot') {
        $warnings += 'possible hardcoded path detected'
    }

    return @{ errors = $errors; warnings = $warnings }
}

function Test-ContentQuality {
    param([string]$FilePath)

    $errors = @()
    $warnings = @()
    $content = Get-Content -LiteralPath $FilePath -Raw -ErrorAction SilentlyContinue

    if (-not $content) {
        return @{ errors = @('empty or unreadable file'); warnings = @() }
    }

    $externalLinks = [regex]::Matches($content, '\[([^\]]+)\]\((https?://[^\)]+)\)')
    $hasSourceClaim = $content -match 'from the docs|according to'
    if ($hasSourceClaim -and $externalLinks.Count -eq 0) {
        $warnings += 'claims to be source-backed but no external links found'
    }

    $relative = Convert-ToRelativePath $FilePath
    if ($content -match '\{\{[^\}]+\}\}' -and $relative -ne 'docs/quality-standards.md') {
        $warnings += 'inconsistent placeholder syntax (use [PLACEHOLDER], not {{PLACEHOLDER}})'
    }

    return @{ errors = $errors; warnings = $warnings }
}

function Test-MarkdownQuality {
    param([string]$FilePath)

    $errors = @()
    $warnings = @()
    $lines = Get-Content -LiteralPath $FilePath -ErrorAction SilentlyContinue

    if (-not $lines) {
        return @{ errors = @('empty or unreadable file'); warnings = @() }
    }

    $lastLevel = 0
    $inCodeBlock = $false
    foreach ($line in $lines) {
        if ($line -match '^\s*```') {
            $inCodeBlock = -not $inCodeBlock
            continue
        }
        if ($inCodeBlock) { continue }

        if ($line -match '^(#{1,6})\s+(.+)$') {
            $level = $matches[1].Length
            if (($level -gt ($lastLevel + 1)) -and ($lastLevel -ne 0)) {
                $relative = Convert-ToRelativePath $FilePath
                if (-not ($relative -eq 'docs/prompt-library/voice-and-humanization.md' -and $line -match '^### \d+[A-Z]\.')) {
                    $warnings += "skipped heading level: $line"
                }
            }
            $lastLevel = $level
        }
    }

    $fileDir = Split-Path -Parent $FilePath
    foreach ($line in $lines) {
        foreach ($match in [regex]::Matches($line, '\[([^\]]+)\]\(([^\)]+)\)')) {
            $linkPath = $match.Groups[2].Value
            if ($linkPath -match '^https?://') { continue }
            if ($linkPath -match '^#') { continue }
            if ($linkPath -match '^[A-Z]:\\') { continue }
            if ($linkPath -match '^mailto:') { continue }

            $targetOnly = ($linkPath -split '#')[0]
            if (-not $targetOnly) { continue }
            if ($targetOnly -eq 'relative/path.md') { continue }

            $fullPath = Join-Path $fileDir $targetOnly
            if (-not (Test-Path -LiteralPath $fullPath)) {
                $warnings += "possibly broken internal link: $linkPath"
            }
        }
    }

    return @{ errors = $errors; warnings = $warnings }
}

function Test-TemplateQuality {
    param([string]$FilePath)

    $errors = @()
    $warnings = @()
    $content = Get-Content -LiteralPath $FilePath -Raw -ErrorAction SilentlyContinue

    if (-not $content) {
        return @{ errors = @('empty or unreadable file'); warnings = @() }
    }

    return @{ errors = $errors; warnings = $warnings }
}

try {
    Write-Verbose "Starting quality audit of: $ScriptDir"

    $allFiles = Get-AuditFiles
    $results = @{
        files = @()
        summary = @{
            total = 0
            errors = 0
            warnings = 0
            passing = 0
        }
        categories = @{}
    }

    foreach ($file in $allFiles) {
        $category = Get-FileCategory $file.FullName
        if (-not $results.categories.ContainsKey($category)) {
            $results.categories[$category] = 0
        }
        $results.categories[$category]++

        $result = @{
            file = Convert-ToRelativePath $file.FullName
            category = $category
            status = 'pass'
            errors = @()
            warnings = @()
        }

        $result.errors += Test-FileNaming $file.FullName $category
        $result.warnings += Test-ContextBudget $file.FullName

        switch ($category) {
            'script' {
                $scriptResult = Test-ScriptQuality $file.FullName
                $result.errors += $scriptResult.errors
                $result.warnings += $scriptResult.warnings
            }
            'markdown' {
                $mdResult = Test-MarkdownQuality $file.FullName
                $contentResult = Test-ContentQuality $file.FullName
                $result.errors += $mdResult.errors + $contentResult.errors
                $result.warnings += $mdResult.warnings + $contentResult.warnings
            }
            'template' {
                $templateResult = Test-TemplateQuality $file.FullName
                $result.errors += $templateResult.errors
                $result.warnings += $templateResult.warnings
            }
        }

        if ($result.errors.Count -gt 0) {
            $result.status = 'fail'
        } elseif ($result.warnings.Count -gt 0) {
            $result.status = 'warn'
        }

        $results.files += $result
        $results.summary.total++

        if ($result.status -eq 'pass') {
            $results.summary.passing++
        } elseif ($result.status -eq 'fail') {
            $results.summary.errors++
        } else {
            $results.summary.warnings++
        }
    }

    Write-Host ''
    Write-Host '======================================'
    Write-Host '         AUDIT SUMMARY'
    Write-Host '======================================'
    Write-Host "Total files:    $($results.summary.total)"
    Write-Host "Passing:        $($results.summary.passing)"
    Write-Host "Warnings:       $($results.summary.warnings)"
    Write-Host "Errors:         $($results.summary.errors)"
    Write-Host ''
    Write-Host 'Files by category:'
    foreach ($key in ($results.categories.Keys | Sort-Object)) {
        Write-Host ("  {0}: {1}" -f $key, $results.categories[$key])
    }

    $filesWithIssues = $results.files | Where-Object { $_.status -ne 'pass' }
    if ($filesWithIssues.Count -gt 0) {
        Write-Host ''
        Write-Host 'Files with issues:'
        foreach ($f in $filesWithIssues) {
            $statusIcon = if ($f.status -eq 'fail') { '[ERROR]' } else { '[WARN]' }
            Write-Host "  $statusIcon $($f.file)"
            if ($VerbosePreference -ne 'SilentlyContinue') {
                foreach ($err in $f.errors) {
                    Write-Host "        ERROR: $err"
                }
                foreach ($warn in $f.warnings) {
                    Write-Host "        WARN: $warn"
                }
            }
        }
    }

    Write-Host ''
    Write-Host 'Audit complete. Run with -Verbose for details.'

    if ($results.summary.errors -gt 0) {
        exit 1
    }
    exit 0
}
catch {
    Write-Error "Audit failed: $_"
    exit 1
}
