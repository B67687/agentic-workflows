<#
.SYNOPSIS
    Reports topic folders that have custom managed sections.

.DESCRIPTION
    Scans sibling folders under M-Namikaz-Others for propagated AGENTS.md files
    that contain custom-section markers, then writes a small local report.

.PARAMETER Detailed
    Reserved for a future detailed report mode.

.EXAMPLE
    .\scripts\analyze-folder-customizations.ps1
#>

[CmdletBinding()]
param(
    [switch]$Detailed
)

try {
    $ErrorActionPreference = 'Stop'
    $parent = Split-Path -Parent $PSScriptRoot
    $marker = 'Managed-By: AI-Prompting-Library'

    Write-Host 'Scanning' -ForegroundColor Cyan

    $folders = Get-ChildItem -Path $parent -Directory | Where-Object { $_.Name -ne 'AI Prompting' }
    $customized = @()

    foreach ($folder in $folders) {
        $agentsPath = Join-Path $folder.FullName 'AGENTS.md'
        if (-not (Test-Path -LiteralPath $agentsPath)) { continue }

        $content = Get-Content -LiteralPath $agentsPath -Raw
        if ($content -match $marker -and $content -match '<!-- Custom-Section:') {
            $customized += $folder.Name
        }
    }

    $lines = @(
        'Customization Analysis',
        '',
        'Generated: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'),
        '',
        'Summary',
        '- Folders: ' + $folders.Count,
        '- With custom: ' + $customized.Count,
        ''
    )

    if ($customized.Count -gt 0) {
        $lines += 'Folders with custom:'
        foreach ($name in $customized) {
            $lines += "- $name"
        }
        $lines += ''
    }

    $lines += 'Run with -Detailed for full content'

    $file = Join-Path $PSScriptRoot 'customization-analysis.md'
    ($lines | Out-String).TrimEnd() | Set-Content -LiteralPath $file -Encoding UTF8
    Write-Host 'Done' -ForegroundColor Green
}
catch {
    Write-Error "Customization analysis failed: $_"
    exit 1
}
