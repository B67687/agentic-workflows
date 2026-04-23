<#
.SYNOPSIS
    Self-tests the ws.ps1 workspace command wrapper.

.DESCRIPTION
    Uses plain PowerShell assertions so the tests do not depend on Pester or
    machine-local shell aliases. The default run covers the common wrapper paths
    and verifies that preview commands do not mutate generated workflow files.

.PARAMETER ParserOnly
    Only run parser checks for ws.ps1 and this test script.

.EXAMPLE
    .\scripts\test-ws.ps1

.EXAMPLE
    .\scripts\test-ws.ps1 -ParserOnly
#>

[CmdletBinding()]
param(
    [switch]$ParserOnly
)

$ErrorActionPreference = 'Stop'
$script:RepoRoot = Split-Path -Parent $PSScriptRoot
$script:Failures = [System.Collections.Generic.List[string]]::new()

function Add-Failure {
    param([string]$Message)
    $script:Failures.Add($Message)
    Write-Output "FAIL: $Message"
}

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if ($Condition) {
        Write-Output "PASS: $Message"
    }
    else {
        Add-Failure $Message
    }
}

function Get-PowerShellExe {
    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($pwsh) { return $pwsh.Source }

    $powershell = Get-Command powershell -ErrorAction SilentlyContinue
    if ($powershell) { return $powershell.Source }

    throw 'No PowerShell executable found on PATH.'
}

function Invoke-Ws {
    param([string[]]$Arguments)

    $powerShellExe = Get-PowerShellExe
    $wsPath = Join-Path $script:RepoRoot 'scripts/ws.ps1'
    $commandArgs = @(
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        $wsPath
    ) + $Arguments

    Push-Location $script:RepoRoot
    try {
        $output = & $powerShellExe @commandArgs 2>&1 | ForEach-Object { $_.ToString() }
        return [pscustomobject]@{
            ExitCode = if ($null -ne $LASTEXITCODE) { $LASTEXITCODE } else { 0 }
            Output = @($output)
            Text = (@($output) -join "`n")
        }
    }
    finally {
        Pop-Location
    }
}

function Test-ScriptParse {
    param([string]$RelativePath)

    $path = Join-Path $script:RepoRoot $RelativePath
    $errors = $null
    [System.Management.Automation.PSParser]::Tokenize((Get-Content -LiteralPath $path -Raw), [ref]$errors) | Out-Null

    if (@($errors).Count -eq 0) {
        Write-Output "PASS: $RelativePath parses"
        return
    }

    foreach ($error in @($errors)) {
        Add-Failure "$RelativePath parser error: $($error.Message)"
    }
}

function Get-FileSnapshot {
    param([string[]]$RelativePaths)

    $snapshot = @{}
    foreach ($relative in $RelativePaths) {
        $path = Join-Path $script:RepoRoot $relative
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            $item = Get-Item -LiteralPath $path
            $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
            $snapshot[$relative] = [pscustomobject]@{
                Exists = $true
                Length = $item.Length
                LastWriteTimeUtc = $item.LastWriteTimeUtc
                Hash = $hash
            }
        }
        else {
            $snapshot[$relative] = [pscustomobject]@{
                Exists = $false
                Length = $null
                LastWriteTimeUtc = $null
                Hash = $null
            }
        }
    }
    return $snapshot
}

function Assert-SnapshotUnchanged {
    param(
        [hashtable]$Before,
        [hashtable]$After,
        [string]$Label
    )

    foreach ($key in $Before.Keys) {
        $beforeItem = $Before[$key]
        $afterItem = $After[$key]
        $same = (
            $beforeItem.Exists -eq $afterItem.Exists -and
            $beforeItem.Length -eq $afterItem.Length -and
            $beforeItem.Hash -eq $afterItem.Hash
        )
        Assert-True $same "$Label leaves $key unchanged"
    }
}

try {
    Write-Output '== Parser Checks =='
    Test-ScriptParse 'scripts/ws.ps1'
    Test-ScriptParse 'scripts/test-ws.ps1'

    if ($ParserOnly) {
        if ($script:Failures.Count -gt 0) { exit 1 }
        exit 0
    }

    $guardedFiles = @(
        'workflow/harvested-topic-insights.md',
        'workflow/cross-domain-candidates.md',
        'workflow/sync-state.json'
    )

    Write-Output ''
    Write-Output '== Command Matrix =='

    $help = Invoke-Ws @('help')
    Assert-True ($help.ExitCode -eq 0) 'help exits 0'
    Assert-True ($help.Text -match 'Usage:') 'help prints usage'
    Assert-True ($help.Text -match 'propagate -Apply') 'help documents apply mode'

    $defaultHelp = Invoke-Ws @()
    Assert-True ($defaultHelp.ExitCode -eq 0) 'default command exits 0'
    Assert-True ($defaultHelp.Text -match 'Commands:') 'default command shows help'

    $invalid = Invoke-Ws @('bogus')
    Assert-True ($invalid.ExitCode -ne 0) 'invalid command fails'
    Assert-True ($invalid.Text -match 'ValidateSet|Cannot validate') 'invalid command explains validation failure'

    $missingQuery = Invoke-Ws @('search')
    Assert-True ($missingQuery.ExitCode -ne 0) 'search without query fails'
    Assert-True ($missingQuery.Text -match 'search requires -Query') 'search without query explains fix'

    $search = Invoke-Ws @('search', '-Query', 'session-state')
    Assert-True ($search.ExitCode -eq 0) 'search exits 0 for known active query'
    Assert-True ($search.Text -match 'workflow/session-state') 'search finds active file'

    $archiveSearch = Invoke-Ws @('search', '-Query', 'history-2026-04', '-IncludeArchive')
    Assert-True ($archiveSearch.ExitCode -eq 0) 'search supports IncludeArchive'

    $hotspots = Invoke-Ws @('hotspots')
    Assert-True ($hotspots.ExitCode -eq 0) 'hotspots exits 0'
    Assert-True ($hotspots.Text -match 'AGENTS\.md') 'hotspots includes AGENTS.md'
    Assert-True ($hotspots.Text -match 'Largest Active Authored Files') 'hotspots lists largest files'

    $status = Invoke-Ws @('status')
    Assert-True ($status.ExitCode -eq 0) 'status exits 0'
    Assert-True ($status.Text -match 'Workspace Status') 'status prints workspace section'
    Assert-True ($status.Text -match 'Hot-Path Budgets') 'status includes hotspots'

    $beforeResearch = Get-FileSnapshot $guardedFiles
    $research = Invoke-Ws @('research')
    $afterResearch = Get-FileSnapshot $guardedFiles
    Assert-True ($research.ExitCode -eq 0) 'research preview exits 0'
    Assert-True ($research.Text -match 'Research Preview') 'research uses preview labels'
    Assert-SnapshotUnchanged $beforeResearch $afterResearch 'research preview'

    $beforePropagate = Get-FileSnapshot $guardedFiles
    $propagate = Invoke-Ws @('propagate')
    $afterPropagate = Get-FileSnapshot $guardedFiles
    Assert-True ($propagate.ExitCode -eq 0) 'propagate preview exits 0'
    Assert-True ($propagate.Text -match 'Propagation Preview') 'propagate defaults to preview'
    Assert-SnapshotUnchanged $beforePropagate $afterPropagate 'propagate preview'

    $validate = Invoke-Ws @('validate')
    Assert-True ($validate.ExitCode -eq 0) 'validate exits 0'
    Assert-True ($validate.Text -match 'Wrapper Self-Checks') 'validate runs wrapper self-checks'

    Write-Output ''
    if ($script:Failures.Count -gt 0) {
        Write-Output "FAILED: $($script:Failures.Count) test(s)"
        foreach ($failure in $script:Failures) {
            Write-Output " - $failure"
        }
        exit 1
    }

    Write-Output 'PASS: all ws.ps1 tests passed'
    exit 0
}
catch {
    Write-Error "test-ws failed: $_"
    exit 1
}
