<#
.SYNOPSIS
    Lists OpenCode agent configuration files and summarizes setup.

.DESCRIPTION
    Scans .opencode/agents/ for *.md agent definitions and prints
    a simple summary (name + line count).

.EXAMPLE
    .\check-opencode-agents.ps1
#>

[CmdletBinding()]
param()

try {
    $agentDir = ".opencode/agents"
    $configs = @()

    if (Test-Path $agentDir) {
        $configs = Get-ChildItem -Path $agentDir -Filter "*.md" -ErrorAction SilentlyContinue
    } else {
        Write-Host "No .opencode/agents/ directory found." -ForegroundColor Yellow
        exit 0
    }

    if ($configs.Count -eq 0) {
        Write-Host "No agent configuration files found." -ForegroundColor Yellow
    } else {
        Write-Host "=== OpenCode Agent Configurations ===" -ForegroundColor Cyan
        foreach ($file in $configs) {
            $name = $file.BaseName
            $lines = (Get-Content $file.FullName | Measure-Object -Line).Lines
            Write-Host "  - $name ($lines lines)"
        }
        Write-Host ""
        Write-Host "Total: $($configs.Count) agent(s) configured" -ForegroundColor Green
    }
} catch {
    Write-Error "Agent check failed: $_"
    exit 1
}
