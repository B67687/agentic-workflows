# Managed-By: AI-Prompting-Library
<#
.SYNOPSIS
    Audits this folder for quality standards compliance.

.DESCRIPTION
    Scans all files in the folder and validates them against the standards
    defined by the propagated folder-quality rules. Reports findings but does not fail.

    Validates:
    - Folder organization (naming, structure, orphans)
    - Script quality (parameters, help, error handling)
    - Content quality (source-backed links, actionable advice)
    - Markdown quality (headings, links, placeholders)
    - Template completeness

.EXAMPLE
    .\audit-folder-quality.ps1
    Run full audit with default verbosity.

.EXAMPLE
    .\audit-folder-quality.ps1 -Verbose
    Run audit with detailed output.

.NOTES
    Author: AI Prompting
    Date: 2026-04-14
#>

[CmdletBinding()]
param(
)

$ErrorActionPreference = 'Continue'
    $ScriptDir = $PSScriptRoot

function Test-FileNaming {
    param([string]$FilePath, [string]$Category)

    $filename = Split-Path $FilePath -Leaf
    $errors = @()

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

    $standardExemptions = @('AGENTS.md', 'README.md', 'LICENSE', 'CONTRIBUTING.md', 'SECURITY.md', 'CHANGELOG.md', 'STATS.md', 'CODE_OF_CONDUCT.md')
    if ($filename -cmatch '[A-Z]' -and $standardExemptions -notcontains $filename) {
        $errors += "filename not lowercase-kebab: $filename"
    }

    return $errors
}

function Test-ScriptQuality {
    param([string]$FilePath)

    $errors = @()
    $warnings = @()
    $content = Get-Content $FilePath -Raw -ErrorAction SilentlyContinue

    if (-not $content) {
        return @{ errors = @("empty or unreadable file"); warnings = @() }
    }

    if ($content -notmatch '(?m)^\s*param\s*\(') {
        $warnings += "missing param() block"
    }

    if ($content -notmatch '<#') {
        $warnings += "missing help comment block (<#)"
    }
    elseif ($content -notmatch '\.SYNOPSIS') {
        $warnings += "help comment missing .SYNOPSIS"
    }

    if ($content -notmatch 'try\s*\{') {
        $warnings += "missing try/catch error handling"
    }

    if ($content -match 'C:\\[^\\]+\\[^\\]+' -or $content -match 'D:\\[^\\]+\\[^\\]+') {
        $warnings += "possible hardcoded path detected"
    }

    if ($content -match 'function\s+\w+' -and $content -notmatch '\[CmdletBinding\(\)\]') {
        $warnings += " Consider adding [CmdletBinding()] for WhatIf support"
    }

    if ($content -match 'Write-Host' -and $content -notmatch 'Write-Verbose' -and $content -notmatch 'param\(') {
        $warnings += "uses Write-Host, consider Write-Verbose for verbose output"
    }

    return @{ errors = $errors; warnings = $warnings }
}

function Test-ContentQuality {
    param([string]$FilePath)

    $errors = @()
    $warnings = @()
    $content = Get-Content $FilePath -Raw -ErrorAction SilentlyContinue

    if (-not $content) {
        return @{ errors = @("empty or unreadable file"); warnings = @() }
    }

    $externalLinks = [regex]::Matches($content, '\[([^\]]+)\]\((https?://[^\)]+)\)')
    foreach ($link in $externalLinks) {
        $url = $link.Groups[2].Value
        if ($url -notmatch '(openai\.com|anthropic\.com|github\.com|microsoft\.com|simonwillison\.net)') {
        }
    }

    if ($content -match '\{\{[^\}]+\}\}' -or $content -match '<[A-Z][^>]+>') {
        $warnings += "inconsistent placeholder syntax (use [PLACEHOLDER], not {{PLACEHOLDER}} or <PLACEHOLDER>)"
    }

    $hasInferenceClaim = $content -match 'inference|likely|probably'
    $hasSourceClaim = $content -match 'source-backed|from the docs|according to'

    if ($hasSourceClaim -and $externalLinks.Count -eq 0) {
        $warnings += "claims to be source-backed but no external links found"
    }

    return @{ errors = $errors; warnings = $warnings }
}

function Test-MarkdownQuality {
    param([string]$FilePath)

    $errors = @()
    $warnings = @()
    $lines = Get-Content $FilePath -ErrorAction SilentlyContinue

    if (-not $lines) {
        return @{ errors = @("empty or unreadable file"); warnings = @() }
    }

    $lastLevel = 0
    $headingErrors = @()
    foreach ($line in $lines) {
        if ($line -match '^(#{1,6})\s+(.+)$') {
            $level = $matches[1].Length
            $nextExpected = $lastLevel + 1
            if (($level -gt $nextExpected) -and ($lastLevel -ne 0)) {
                $headingErrors += "skipped heading level: $line"
            }
            $lastLevel = $level
        }
    }
    if ($headingErrors.Count -gt 0) {
        $warnings += $headingErrors
    }

    foreach ($line in $lines) {
        if ($line -match '\[([^\]]+)\]\(([^\)]+)\)') {
            $linkPath = $matches[2]
            if ($linkPath -match '^http') { continue }
            if ($linkPath -match '^#') { continue }
            if ($linkPath -match '^[A-Z]:\\') { continue }
            $fullPath = Join-Path $ScriptDir $linkPath
            if (-not (Test-Path $fullPath)) {
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
    $content = Get-Content $FilePath -Raw -ErrorAction SilentlyContinue

    if (-not $content) {
        return @{ errors = @("empty or unreadable file"); warnings = @() }
    }

    if ($content -notmatch '\[[A-Z][A-Z_]+\]') {
        $warnings += "template may be missing placeholders (expected [PLACEHOLDER] syntax)"
    }

    if ($content -notmatch '(description|usage|template for)') {
        $warnings += "template missing description or usage notes"
    }

    return @{ errors = $errors; $warnings = $warnings }
}

function Get-FileCategory {
    param([string]$FilePath)

    $filename = Split-Path $FilePath -Leaf

    if ($filename -match '\.ps1$') { return 'script' }
    if ($filename -match '\.md$') { return 'markdown' }
    if ($filename -match '\.template\.') { return 'template' }
    if ($filename -match '\.json$') { return 'json' }
    if ($filename -match '\.txt$') { return 'config' }

    return 'other'
}

function ConvertTo-KebabCase {
    param([string]$Name)

    $value = $Name.Trim()
    $value = $value -creplace '([A-Z]+)([A-Z][a-z])', '$1-$2'
    $value = $value -creplace '([a-z0-9])([A-Z])', '$1-$2'
    $value = $value -replace '[^A-Za-z0-9]+', '-'
    return $value.Trim('-').ToLowerInvariant()
}

function Test-FolderStructure {
    param([string]$FolderPath)

    $warnings = @()
    $folderName = Split-Path $FolderPath -Leaf
    $expectedContentFolder = "$(ConvertTo-KebabCase -Name $folderName)-content"

    $allowedRootFiles = @(
        'AGENTS.md',
        'topic-insights.md',
        'git-github-best-practices.md',
        '.cleanup-protect',
        'audit-folder-quality.ps1',
        '.gitignore'
    )

    $allowedRootDirs = @(
        $expectedContentFolder,
        'meta',
        '.git',
        '.github',
        '.vscode',
        '.idea'
    )

    $contentDirs = @(Get-ChildItem -LiteralPath $FolderPath -Directory -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -like '*-content' })

    if (-not ($contentDirs.Name -contains $expectedContentFolder)) {
        $warnings += "missing canonical content folder: $expectedContentFolder"
    }

    if ($contentDirs.Count -gt 1) {
        $extraContent = @($contentDirs | Where-Object { $_.Name -ne $expectedContentFolder } | Select-Object -ExpandProperty Name)
        if ($extraContent.Count -gt 0) {
            $warnings += "duplicate or legacy content folder(s) at root: $($extraContent -join ', ')"
        }
    }

    $unexpectedDirs = @(Get-ChildItem -LiteralPath $FolderPath -Directory -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -notin $allowedRootDirs } | Select-Object -ExpandProperty Name)
    if ($unexpectedDirs.Count -gt 0) {
        $warnings += "non-standard root folder(s); normal project work should live in $expectedContentFolder/: $($unexpectedDirs -join ', ')"
    }

    $unexpectedFiles = @(Get-ChildItem -LiteralPath $FolderPath -File -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -notin $allowedRootFiles -and $_.Name -notlike '.git*' } | Select-Object -ExpandProperty Name)
    if ($unexpectedFiles.Count -gt 0) {
        $warnings += "non-standard root file(s); move safe content into $expectedContentFolder/ or document why root is required: $($unexpectedFiles -join ', ')"
    }

    return @{ errors = @(); warnings = $warnings }
}

try {
    Write-Verbose "Starting quality audit of: $ScriptDir"

    $allFiles = Get-ChildItem -Path $ScriptDir -File -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\.git' }

    $results = @{
        files = @()
        summary = @{
            total = 0
            errors = 0
            warnings = 0
            passing = 0
        }
    }

    Write-Verbose "Found $($allFiles.Count) files to audit"

foreach ($file in $allFiles) {
    $category = Get-FileCategory $file.FullName
    $result = @{
        file = $file.Name
        category = $category
        status = 'pass'
        errors = @()
        warnings = @()
    }

    $namingErrors = Test-FileNaming $file.FullName $category
    if ($namingErrors.Count -gt 0) {
        $result.errors += $namingErrors
    }

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
            $contentResult = Test-ContentQuality $file.FullName
            $result.errors += $templateResult.errors + $contentResult.errors
            $result.warnings += $templateResult.warnings + $contentResult.warnings
        }
    }

    if ($result.errors.Count -gt 0) {
        $result.status = 'fail'
    } elseif ($result.warnings.Count -gt 0) {
        $result.status = 'warn'
    } else {
        $result.status = 'pass'
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

    if ($VerbosePreference -ne 'SilentlyContinue' -and $result.status -ne 'pass') {
        Write-Verbose "$($result.status.ToUpper()): $($file.Name)"
        foreach ($err in $result.errors) {
            Write-Verbose "  ERROR: $err"
        }
        foreach ($warn in $result.warnings) {
            Write-Verbose "  WARN: $warn"
        }
    }
}

    $structureResult = Test-FolderStructure -FolderPath $ScriptDir
    $structureStatus = 'pass'
    if ($structureResult.errors.Count -gt 0) {
        $structureStatus = 'fail'
    } elseif ($structureResult.warnings.Count -gt 0) {
        $structureStatus = 'warn'
    }

    $results.files += @{
        file = '[folder-structure]'
        category = 'structure'
        status = $structureStatus
        errors = $structureResult.errors
        warnings = $structureResult.warnings
    }
    $results.summary.total++
    if ($structureStatus -eq 'pass') {
        $results.summary.passing++
    } elseif ($structureStatus -eq 'fail') {
        $results.summary.errors++
    } else {
        $results.summary.warnings++
    }

    Write-Host ""
    Write-Host "======================================"
    Write-Host "         AUDIT SUMMARY"
    Write-Host "======================================"
    Write-Host "Total files:    $($results.summary.total)"
    Write-Host "Passing:       $($results.summary.passing)"
    Write-Host "Warnings:    $($results.summary.warnings)"
    Write-Host "Errors:       $($results.summary.errors)"
    Write-Host ""

    $filesWithIssues = $results.files | Where-Object { $_.status -ne 'pass' }
    if ($filesWithIssues.Count -gt 0) {
        Write-Host "Files with issues:"
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

    Write-Host ""
    Write-Host "Audit complete. Run with -Verbose for details."

    if ($results.summary.errors -gt 0) {
        exit 1
    } else {
        exit 0
    }
}
catch {
    Write-Error "Audit failed: $_"
    exit 1
}
