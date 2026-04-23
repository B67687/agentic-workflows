#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Self-service sync: pull latest templates from AI Prompting hub.

.DESCRIPTION
    Run this script from any topic folder to pull the latest propagated templates
    from the central AI Prompting hub. No need to ask the hub for permission.

    This script:
    1. Finds the AI Prompting hub (looks in parent directories)
    2. Copies latest templates to this folder
    3. Creates missing files, updates managed files, skips custom files

.EXAMPLE
    .\sync-from-hub.ps1
    # Pull latest templates into current folder

.EXAMPLE
    .\sync-from-hub.ps1 -Preview
    # Show what would change without making changes
#>

[CmdletBinding()]
param(
    [switch]$Preview
)

$ErrorActionPreference = "Stop"

# Find AI Prompting hub by walking up from current directory
$HubDir = $null
$CurrentDir = (Get-Location).Path

$checkDir = $CurrentDir
while ($checkDir -and (Split-Path $checkDir -Leaf) -ne "M-Namikaz-Others") {
    $candidate = Join-Path (Split-Path $checkDir -Parent) "AI Prompting"
    if (Test-Path (Join-Path $candidate "AGENTS.md")) {
        $HubDir = $candidate
        break
    }
    $checkDir = Split-Path $checkDir -Parent
}

# Fallback: check direct sibling
if (-not $HubDir) {
    $sibling = Join-Path (Split-Path $CurrentDir -Parent) "AI Prompting"
    if (Test-Path (Join-Path $sibling "AGENTS.md")) {
        $HubDir = $sibling
    }
}

if (-not $HubDir) {
    Write-Error "Could not find AI Prompting hub. Ensure this folder is inside M-Namikaz-Others."
    exit 1
}

$TemplatesDir = Join-Path $HubDir "propagate-templates"
$ManagedMarker = "Managed-By: AI-Prompting-Library"

Write-Host "Hub found: $HubDir" -ForegroundColor Cyan
Write-Host "Syncing templates..." -ForegroundColor Cyan

# Template mapping
$Templates = @{
    "AGENTS.template.md" = "AGENTS.md"
    "topic-insights.template.md" = "topic-insights.md"
    "git-github-best-practices.template.md" = "git-github-best-practices.md"
    "audit-folder-quality.template.ps1" = "audit-folder-quality.ps1"
    ".cleanup-protect.template.md" = ".cleanup-protect"
    "opencode-agent-system.template.md" = "opencode-agent-system.md"
    "opencode.template.json" = "opencode.json"
}

$results = @()

foreach ($templateFile in $Templates.Keys) {
    $templatePath = Join-Path $TemplatesDir $templateFile
    $targetFile = $Templates[$templateFile]
    $targetPath = Join-Path $CurrentDir $targetFile
    
    if (-not (Test-Path $templatePath)) {
        Write-Host "  SKIP (template missing): $templateFile" -ForegroundColor Yellow
        continue
    }
    
    $templateContent = Get-Content $templatePath -Raw
    
    if (Test-Path $targetPath) {
        $existing = Get-Content $targetPath -Raw -ErrorAction SilentlyContinue
        
        if ($existing -match $ManagedMarker) {
            # Managed file: overwrite with latest
            if ($Preview) {
                Write-Host "  WOULD UPDATE: $targetFile" -ForegroundColor Cyan
            } else {
                $templateContent | Set-Content $targetPath -Encoding UTF8
                Write-Host "  UPDATED: $targetFile" -ForegroundColor Green
            }
        } else {
            # Unmanaged file: skip to protect custom content
            Write-Host "  SKIP (unmanaged): $targetFile" -ForegroundColor Yellow
        }
    } else {
        # File doesn't exist: create it
        if ($Preview) {
            Write-Host "  WOULD CREATE: $targetFile" -ForegroundColor Cyan
        } else {
            $templateContent | Set-Content $targetPath -Encoding UTF8
            Write-Host "  CREATED: $targetFile" -ForegroundColor Green
        }
    }
}

# Ensure content folder exists
$folderName = Split-Path $CurrentDir -Leaf
$kebabName = $folderName -creplace '([A-Z]+)([A-Z][a-z])', '$1-$2' -creplace '([a-z0-9])([A-Z])', '$1-$2' -replace '[^A-Za-z0-9]+', '-' -replace '^-+|-+$', ''
$contentFolder = Join-Path $CurrentDir "$kebabName-content"

if (-not (Test-Path $contentFolder)) {
    if ($Preview) {
        Write-Host "  WOULD CREATE: $(Split-Path $contentFolder -Leaf)/" -ForegroundColor Cyan
    } else {
        New-Item -ItemType Directory -Path $contentFolder -Force | Out-Null
        Write-Host "  CREATED: $(Split-Path $contentFolder -Leaf)/" -ForegroundColor Green
    }
}

Write-Host "`nDone. Run without -Preview to apply changes." -ForegroundColor Gray
