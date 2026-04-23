# OpenCode Agent Configuration Checker
# Lists agent config files and summarizes setup

$agentDir = ".opencode/agents"
$configs = @()

if (Test-Path $agentDir) {
    $configs = Get-ChildItem -Path $agentDir -Filter "*.md" -ErrorAction SilentlyContinue
} else {
    Write-Host "No .opencode/agents/ directory found." -ForegroundColor Yellow
    exit
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
