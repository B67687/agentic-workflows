<#
.SYNOPSIS
    Common command wrapper for the AI Prompting workspace.

.DESCRIPTION
    Provides one short repo-local entry point for repeated workspace commands:
    status, hotspot checks, validation, search, research preview, and propagation.

    Defaults are read-only. Use -Apply only when intentionally running a mutating
    propagation command.

.PARAMETER Command
    Command to run: help, status, hotspots, validate, search, research, propagate.

.PARAMETER Query
    Search query used by the search command.

.PARAMETER Apply
    Apply mutating propagation changes. Only used by the propagate command.

.PARAMETER IncludeArchive
    Include curated archive files in search and hotspot scans.

.PARAMETER IncludeGenerated
    Include generated workflow files and raw archive snapshots in search and scans.

.EXAMPLE
    .\scripts\ws.ps1 status

.EXAMPLE
    .\scripts\ws.ps1 search -Query "session-state"

.EXAMPLE
    .\scripts\ws.ps1 propagate -Apply
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('help', 'status', 'hotspots', 'validate', 'search', 'research', 'propagate')]
    [string]$Command = 'help',

    [string]$Query,

    [switch]$Apply,

    [switch]$IncludeArchive,

    [switch]$IncludeGenerated
)

$ErrorActionPreference = 'Stop'
$script:ExitCode = 0
$script:RepoRoot = Split-Path -Parent $PSScriptRoot

$script:HotPathBudgets = [ordered]@{
    'AGENTS.md' = 220
    'README.md' = 150
    'docs/workspace-system-overview.md' = 240
    'HISTORY.md' = 350
    'research/research-log.md' = 500
    'docs/prompt-templates.md' = 350
}

$script:GeneratedRelative = @(
    'workflow/harvested-topic-insights.md',
    'workflow/cross-domain-candidates.md',
    'workflow/sync-state.json'
)

function Write-Section {
    param([string]$Title)

    Write-Output ''
    Write-Output "== $Title =="
}

function ConvertTo-RepoRelativePath {
    param([string]$Path)

    return ([System.IO.Path]::GetRelativePath($script:RepoRoot, $Path) -replace '\\', '/')
}

function Get-PowerShellExe {
    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($pwsh) { return $pwsh.Source }

    $powershell = Get-Command powershell -ErrorAction SilentlyContinue
    if ($powershell) { return $powershell.Source }

    throw 'No PowerShell executable found on PATH.'
}

function Invoke-WorkspaceScript {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptRelativePath,

        [string[]]$Arguments = @()
    )

    $scriptPath = Join-Path $script:RepoRoot $ScriptRelativePath
    if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) {
        return [pscustomobject]@{
            ExitCode = 127
            Output = @("Missing script: $ScriptRelativePath")
        }
    }

    $powerShellExe = Get-PowerShellExe
    $commandArgs = @(
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        $scriptPath
    ) + $Arguments

    Push-Location $script:RepoRoot
    try {
        $output = & $powerShellExe @commandArgs 2>&1 | ForEach-Object { $_.ToString() }
        $exitCode = if ($null -ne $LASTEXITCODE) { $LASTEXITCODE } else { 0 }

        return [pscustomobject]@{
            ExitCode = $exitCode
            Output = @($output)
        }
    }
    finally {
        Pop-Location
    }
}

function Write-CapturedOutput {
    param(
        [string[]]$Output,
        [int]$MaxLines = 80
    )

    if (-not $Output -or $Output.Count -eq 0) {
        return
    }

    if ($VerbosePreference -eq 'Continue' -or $Output.Count -le $MaxLines) {
        $Output | ForEach-Object { Write-Output $_ }
        return
    }

    $Output | Select-Object -First $MaxLines | ForEach-Object { Write-Output $_ }
    Write-Output "... output truncated; rerun with -Verbose to show all $($Output.Count) lines."
}

function Get-FileMetrics {
    param([string]$RelativePath)

    $path = Join-Path $script:RepoRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        return [pscustomobject]@{
            Path = $RelativePath
            Lines = $null
            Bytes = $null
            Budget = $script:HotPathBudgets[$RelativePath]
            Status = 'MISSING'
        }
    }

    $lineCount = (Get-Content -LiteralPath $path -ErrorAction Stop | Measure-Object -Line).Lines
    $bytes = (Get-Item -LiteralPath $path).Length
    $budget = $script:HotPathBudgets[$RelativePath]
    $status = if ($budget -and $lineCount -gt $budget) { 'WARN' } else { 'OK' }

    return [pscustomobject]@{
        Path = $RelativePath
        Lines = $lineCount
        Bytes = $bytes
        Budget = $budget
        Status = $status
    }
}

function Test-IsExcludedFile {
    param([System.IO.FileInfo]$File)

    $relative = ConvertTo-RepoRelativePath $File.FullName

    if ($relative -match '^\.git/') { return $true }
    if ($relative -match '^personal-voice/samples/') { return $true }
    if ($relative -match '^archive/raw/' -and -not $IncludeGenerated) { return $true }
    if ($relative -match '^archive/' -and -not $IncludeArchive -and -not $IncludeGenerated) { return $true }
    if ($script:GeneratedRelative -contains $relative -and -not $IncludeGenerated) { return $true }

    return $false
}

function Get-ActiveAuthoredFiles {
    $rootFiles = Get-ChildItem -Path $script:RepoRoot -File -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -in @('.md', '.json') -or $_.Name -eq '.rgignore' }

    $dirs = @('docs', 'research', 'scripts', 'propagate-templates', 'personal-voice')
    if ($IncludeArchive -or $IncludeGenerated) { $dirs += 'archive' }
    if ($IncludeGenerated) { $dirs += 'workflow' }

    $nestedFiles = foreach ($dir in $dirs) {
        $full = Join-Path $script:RepoRoot $dir
        if (Test-Path -LiteralPath $full -PathType Container) {
            if ($dir -eq 'personal-voice') {
                Get-ChildItem -Path $full -File -Force -ErrorAction SilentlyContinue
            }
            else {
                Get-ChildItem -Path $full -Recurse -File -Force -ErrorAction SilentlyContinue
            }
        }
    }

    @($rootFiles + $nestedFiles) |
        Where-Object { $_ -and -not (Test-IsExcludedFile $_) } |
        Sort-Object FullName -Unique
}

function Show-Help {
    Write-Output 'Usage: .\scripts\ws.ps1 <command> [options]'
    Write-Output ''
    Write-Output 'Commands:'
    Write-Output '  help                         Show this help.'
    Write-Output '  status                       Session summary, hot-path sizes, sync, and audit result.'
    Write-Output '  hotspots                     Hot-path budgets plus largest active authored files.'
    Write-Output '  validate                     Audit, sync check, parser checks, stale refs, self-checks.'
    Write-Output '  search -Query "text"          Search active files with repo exclusions.'
    Write-Output '  research                     Preview harvest + cross-domain candidate generation.'
    Write-Output '  propagate                    Preview propagation changes.'
    Write-Output '  propagate -Apply             Apply propagation changes.'
    Write-Output ''
    Write-Output 'Options:'
    Write-Output '  -IncludeArchive              Include curated archive files in search/scans.'
    Write-Output '  -IncludeGenerated            Include generated workflow files and raw archive snapshots.'
    Write-Output '  -Verbose                     Show full child-script output.'
    Write-Output ''
    Write-Output 'Read-only by default. Only propagate -Apply performs propagation writes.'
    Write-Output 'PowerShell handles mutating workspace automation. WSL read-only inspection can use scripts/ws.sh.'
}

function Show-Hotspots {
    Write-Section 'Hot-Path Budgets'

    $script:HotPathBudgets.Keys |
        ForEach-Object { Get-FileMetrics -RelativePath $_ } |
        Format-Table Path, Lines, Budget, Bytes, Status -AutoSize |
        Out-String -Width 140 |
        ForEach-Object { $_.TrimEnd() } |
        Where-Object { $_ } |
        ForEach-Object { Write-Output $_ }

    Write-Section 'Largest Active Authored Files'
    Get-ActiveAuthoredFiles |
        Sort-Object Length -Descending |
        Select-Object -First 15 @{Name = 'Path'; Expression = { ConvertTo-RepoRelativePath $_.FullName } }, @{Name = 'KB'; Expression = { [math]::Round($_.Length / 1KB, 1) } }, @{Name = 'Lines'; Expression = { (Get-Content -LiteralPath $_.FullName -ErrorAction SilentlyContinue | Measure-Object -Line).Lines } } |
        Format-Table Path, KB, Lines -AutoSize |
        Out-String -Width 160 |
        ForEach-Object { $_.TrimEnd() } |
        Where-Object { $_ } |
        ForEach-Object { Write-Output $_ }
}

function Show-SessionStateSummary {
    $statePath = Join-Path $script:RepoRoot 'workflow/session-state.json'
    if (-not (Test-Path -LiteralPath $statePath -PathType Leaf)) {
        Write-Warning 'workflow/session-state.json is missing.'
        return
    }

    $content = Get-Content -LiteralPath $statePath -Raw
    $interestingPatterns = @(
        '^\- \*\*Session:\*\* .+$',
        '^\- \*\*Status:\*\* .+$',
        '^\- \*\*Name:\*\* .+$',
        '^\- \*\*Phase:\*\* .+$',
        '^\- \*\*What comes next:\*\* .+$'
    )

    foreach ($pattern in $interestingPatterns) {
        $match = [regex]::Match($content, $pattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)
        if ($match.Success) {
            Write-Output $match.Value
        }
    }
}

function Invoke-SyncCheck {
    $result = Invoke-WorkspaceScript -ScriptRelativePath 'scripts/check-sync-status.ps1'

    $statusLine = $result.Output | Where-Object { $_ -match '^SyncStatus=' } | Select-Object -First 1
    $status = if ($statusLine) { $statusLine -replace '^SyncStatus=', '' } else { 'UNKNOWN' }

    if ($result.ExitCode -eq 0) {
        return [pscustomobject]@{ Severity = 'ok'; Status = $status; ExitCode = $result.ExitCode; Output = $result.Output }
    }

    if ($status -in @('STALE', 'NEVER')) {
        return [pscustomobject]@{ Severity = 'warning'; Status = $status; ExitCode = $result.ExitCode; Output = $result.Output }
    }

    return [pscustomobject]@{ Severity = 'error'; Status = $status; ExitCode = $result.ExitCode; Output = $result.Output }
}

function Invoke-Audit {
    param([switch]$VerboseOutput)

    $args = @()
    if ($IncludeArchive) { $args += '-IncludeArchive' }
    if ($IncludeGenerated) { $args += '-IncludeGenerated' }
    if ($VerboseOutput) { $args += '-Verbose' }

    $result = Invoke-WorkspaceScript -ScriptRelativePath 'scripts/audit-folder-quality.ps1' -Arguments $args
    return $result
}

function Test-PowerShellScriptsParse {
    $messages = @()
    $errors = @()
    $scripts = Get-ChildItem -Path (Join-Path $script:RepoRoot 'scripts') -Filter '*.ps1' -File -ErrorAction SilentlyContinue

    foreach ($item in $scripts) {
        $parseErrors = $null
        [System.Management.Automation.PSParser]::Tokenize((Get-Content -LiteralPath $item.FullName -Raw), [ref]$parseErrors) | Out-Null
        foreach ($parseError in @($parseErrors)) {
            $errors += [pscustomobject]@{
                Path = ConvertTo-RepoRelativePath $item.FullName
                Message = $parseError.Message
            }
        }
    }

    if ($errors.Count -gt 0) {
        $messages += ($errors | Format-Table Path, Message -AutoSize | Out-String -Width 160)
        return [pscustomobject]@{ Ok = $false; Output = $messages }
    }

    $messages += "Parsed $($scripts.Count) PowerShell script(s) without parser errors."
    return [pscustomobject]@{ Ok = $true; Output = $messages }
}

function Test-StaleReferences {
    $rg = Get-Command rg -ErrorAction SilentlyContinue
    if (-not $rg) {
        return [pscustomobject]@{ Ok = $true; Output = @('rg not found; skipping stale-reference scan.'); Warning = $true }
    }

    $patterns = @(
        'archive/session-raw.txt',
        'archive\\session-raw.txt'
    )
    $found = @()

    foreach ($pattern in $patterns) {
        $output = & $rg.Source --line-number --fixed-strings --glob '!scripts/ws.ps1' --glob '!archive/raw/**' --glob '!personal-voice/samples/**' -- $pattern $script:RepoRoot 2>$null
        if ($LASTEXITCODE -eq 0) {
            $found += @($output)
        }
    }

    if ($found.Count -gt 0) {
        $output = @('Found stale raw-session references:') + $found
        return [pscustomobject]@{ Ok = $false; Output = $output; Warning = $false }
    }

    return [pscustomobject]@{ Ok = $true; Output = @('No stale raw-session references found.'); Warning = $false }
}

function Test-WrapperSelfChecks {
    $ok = $true
    $messages = @()
    $requiredScripts = @(
        'scripts/audit-folder-quality.ps1',
        'scripts/check-sync-status.ps1',
        'scripts/propagate-to-all.ps1',
        'scripts/harvest-topic-insights.ps1',
        'scripts/build-cross-domain-candidates.ps1'
    )

    foreach ($relative in $requiredScripts) {
        if (-not (Test-Path -LiteralPath (Join-Path $script:RepoRoot $relative) -PathType Leaf)) {
            $messages += "Missing required script: $relative"
            $ok = $false
        }
    }

    if (-not (Get-Command rg -ErrorAction SilentlyContinue)) {
        $messages += 'rg is not installed or not on PATH.'
        $ok = $false
    }

    if ($ok) {
        $messages += 'Wrapper self-checks passed.'
    }

    return [pscustomobject]@{ Ok = $ok; Output = $messages }
}

function Test-TerminalStrategy {
    $messages = @()
    $ok = $true

    $messages += "Mutating automation: PowerShell remains the source of truth."

    $wsl = Get-Command wsl -ErrorAction SilentlyContinue
    if (-not $wsl) {
        $messages += "WSL: not available; no action needed."
        return [pscustomobject]@{ Ok = $ok; Output = $messages }
    }

    $messages += "WSL: available for native read-only inspection through scripts/ws.sh."

    $wslOutput = & $wsl.Source bash -lc 'cd "/mnt/m/M-Namikaz-Others/AI Prompting" 2>/dev/null || exit 20; if command -v pwsh >/dev/null 2>&1; then echo "wsl-pwsh=present"; else echo "wsl-pwsh=missing"; fi; if command -v rg >/dev/null 2>&1; then rg_path="$(command -v rg)"; if rg --version >/dev/null 2>&1; then echo "wsl-rg=usable"; else echo "wsl-rg=unusable:$rg_path"; fi; else echo "wsl-rg=missing"; fi; if command -v git >/dev/null 2>&1; then echo "wsl-git=present"; else echo "wsl-git=missing"; fi' 2>&1 |
        ForEach-Object { $_.ToString() }

    if ($LASTEXITCODE -ne 0) {
        $messages += "WSL probe: failed or repo path not mounted; keep using PowerShell."
        return [pscustomobject]@{ Ok = $ok; Output = $messages }
    }

    foreach ($line in @($wslOutput)) {
        switch -Regex ($line) {
            '^wsl-pwsh=present$' { $messages += "WSL pwsh: present." }
            '^wsl-pwsh=missing$' { $messages += "WSL pwsh: missing; OK if using native Bash wrappers instead of .ps1 scripts." }
            '^wsl-rg=usable$' { $messages += "WSL rg: usable." }
            '^wsl-rg=missing$' { $messages += "WSL rg: missing; install native ripgrep before relying on WSL search." }
            '^wsl-rg=unusable:(.*)$' {
                $rgPath = if ($Matches[1]) { $Matches[1] } else { 'detected PATH entry' }
                $messages += "WSL rg: unusable at $rgPath; install native ripgrep before relying on WSL search."
            }
            '^wsl-git=present$' { $messages += "WSL git: present." }
            '^wsl-git=missing$' { $messages += "WSL git: missing." }
            default { $messages += "WSL probe: $line" }
        }
    }

    $messages += "Recommendation: use scripts/ws.sh for WSL read-only checks; keep propagation and mutating automation on scripts/ws.ps1."

    return [pscustomobject]@{ Ok = $ok; Output = $messages }
}

function Invoke-Search {
    if ([string]::IsNullOrWhiteSpace($Query)) {
        Write-Error 'search requires -Query "text".'
        $script:ExitCode = 2
        return
    }

    $rg = Get-Command rg -ErrorAction SilentlyContinue
    if (-not $rg) {
        Write-Error 'rg is required for search but was not found on PATH.'
        $script:ExitCode = 127
        return
    }

    $args = @('--line-number', '--hidden', '--glob', '!.git/**', '--glob', '!personal-voice/samples/**')

    if (-not $IncludeArchive -and -not $IncludeGenerated) {
        $args += @('--glob', '!archive/**')
    }
    elseif ($IncludeArchive -and -not $IncludeGenerated) {
        $args += @('--glob', '!archive/raw/**', '--glob', '!archive/session-raw*.txt')
    }

    if (-not $IncludeGenerated) {
        foreach ($generated in $script:GeneratedRelative) {
            $args += @('--glob', "!$generated")
        }
    }

    $args += @('--', $Query, '.')

    Push-Location $script:RepoRoot
    try {
        & $rg.Source @args
        $code = $LASTEXITCODE
        if ($code -gt 1) {
            $script:ExitCode = $code
        }
    }
    finally {
        Pop-Location
    }
}

function Invoke-ResearchPreview {
    Write-Section 'Research Preview: Harvest Topic Insights'
    $harvest = Invoke-WorkspaceScript -ScriptRelativePath 'scripts/harvest-topic-insights.ps1' -Arguments @('-Preview')
    Write-CapturedOutput -Output $harvest.Output -MaxLines 80

    Write-Section 'Research Preview: Build Cross-Domain Candidates'
    $candidates = Invoke-WorkspaceScript -ScriptRelativePath 'scripts/build-cross-domain-candidates.ps1' -Arguments @('-Preview')
    Write-CapturedOutput -Output $candidates.Output -MaxLines 80

    if ($harvest.ExitCode -ne 0 -or $candidates.ExitCode -ne 0) {
        $script:ExitCode = 1
    }
}

function Invoke-Propagation {
    $args = @()
    if ($Apply) {
        Write-Section 'Propagation Apply'
        $args += '-Apply'
    }
    else {
        Write-Section 'Propagation Preview'
    }

    $result = Invoke-WorkspaceScript -ScriptRelativePath 'scripts/propagate-to-all.ps1' -Arguments $args
    Write-CapturedOutput -Output $result.Output -MaxLines 120

    if ($result.ExitCode -ne 0) {
        $script:ExitCode = $result.ExitCode
    }
}

function Invoke-Validate {
    Write-Section 'Audit'
    $audit = Invoke-Audit -VerboseOutput:($VerbosePreference -eq 'Continue')
    Write-CapturedOutput -Output $audit.Output -MaxLines 80
    if ($audit.ExitCode -ne 0) {
        $script:ExitCode = 1
    }

    Write-Section 'Sync'
    $sync = Invoke-SyncCheck
    Write-CapturedOutput -Output $sync.Output -MaxLines 20
    if ($sync.Severity -eq 'warning') {
        Write-Warning "Sync status is $($sync.Status). Treating as a warning."
    }
    if ($sync.Severity -eq 'error') {
        Write-Warning "Sync check failed with exit code $($sync.ExitCode)."
        $script:ExitCode = 1
    }

    Write-Section 'PowerShell Parser'
    $parser = Test-PowerShellScriptsParse
    Write-CapturedOutput -Output $parser.Output -MaxLines 80
    if (-not $parser.Ok) {
        $script:ExitCode = 1
    }

    Write-Section 'Stale References'
    $stale = Test-StaleReferences
    Write-CapturedOutput -Output $stale.Output -MaxLines 80
    if ($stale.Warning) {
        Write-Warning ($stale.Output -join ' ')
    }
    if (-not $stale.Ok) {
        $script:ExitCode = 1
    }

    Write-Section 'Wrapper Self-Checks'
    $self = Test-WrapperSelfChecks
    Write-CapturedOutput -Output $self.Output -MaxLines 80
    if (-not $self.Ok) {
        $script:ExitCode = 1
    }

    Write-Section 'Terminal Strategy'
    $terminal = Test-TerminalStrategy
    Write-CapturedOutput -Output $terminal.Output -MaxLines 80
    if (-not $terminal.Ok) {
        $script:ExitCode = 1
    }
}

function Invoke-Status {
    Write-Section 'Workspace Status'
    Show-SessionStateSummary

    Show-Hotspots

    Write-Section 'Sync'
    $sync = Invoke-SyncCheck
    Write-CapturedOutput -Output $sync.Output -MaxLines 20
    if ($sync.Severity -eq 'warning') {
        Write-Warning "Sync status is $($sync.Status). Treating as a warning."
    }
    if ($sync.Severity -eq 'error') {
        Write-Warning "Sync check failed with exit code $($sync.ExitCode)."
        $script:ExitCode = 1
    }

    Write-Section 'Audit'
    $audit = Invoke-Audit
    Write-CapturedOutput -Output $audit.Output -MaxLines 80
    if ($audit.ExitCode -ne 0) {
        Write-Warning "Audit returned exit code $($audit.ExitCode)."
    }
}

try {
    switch ($Command) {
        'help' { Show-Help }
        'status' { Invoke-Status }
        'hotspots' { Show-Hotspots }
        'validate' { Invoke-Validate }
        'search' { Invoke-Search }
        'research' { Invoke-ResearchPreview }
        'propagate' { Invoke-Propagation }
    }
}
catch {
    Write-Error $_
    $script:ExitCode = 1
}

exit $script:ExitCode
