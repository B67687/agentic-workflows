<#
.SYNOPSIS
    Checks if propagation sync is stale and prompts user if needed.

.DESCRIPTION
    This script is meant to be called at session start (e.g., in AGENTS.md or init).
    It checks the last sync time and returns appropriate guidance for the agent.

    Returns:
    - "OK" if within 3 hours
    - "STALE" with details if older than 3 hours
    - "NEVER" if no sync has been performed

.PARAMETER StateFile
    Path to the sync state file (default: ../workflow/sync-state.json).

.PARAMETER HoursThreshold
    Hours after which sync is considered stale (default: 3).

.EXAMPLE
    .\check-sync-status.ps1
    # Returns the sync status
#>

[CmdletBinding()]
param(
    [string]$StateFile,

    [int]$HoursThreshold = 3
)

try {
    $ScriptDir = $PSScriptRoot

if (-not $StateFile) {
    $StateFile = Join-Path (Split-Path $ScriptDir -Parent) "workflow\sync-state.json"
}

function Get-SyncStatus {
    param([string]$StatePath)
    
    if (-not (Test-Path $StatePath)) {
        return @{
            Status = "NEVER"
            Message = "No sync has been performed yet. Run propagate-to-all.ps1 -Apply to sync."
            LastSync = $null
            HoursAgo = $null
        }
    }
    
    try {
        $content = Get-Content $StatePath -Raw | ConvertFrom-Json
        $lastSync = $content.lastSync
        
        if (-not $lastSync) {
            return @{
                Status = "NEVER"
                Message = "No sync timestamp found. Run propagate-to-all.ps1 -Apply to sync."
                LastSync = $null
                HoursAgo = $null
            }
        }
        
        $lastSyncDate = [DateTime]::Parse($lastSync)
        $hoursAgo = ((Get-Date) - $lastSyncDate).TotalHours
        
        if ($hoursAgo -lt $HoursThreshold) {
            return @{
                Status = "OK"
                Message = "Last sync was $("{0:N1}" -f $hoursAgo) hours ago. Within $HoursThreshold hour threshold."
                LastSync = $lastSync
                HoursAgo = $hoursAgo
            }
        }
        else {
            return @{
                Status = "STALE"
                Message = "Last sync was $("{0:N1}" -f $hoursAgo) hours ago (> $HoursThreshold hours). Consider running propagate-to-all.ps1 -Apply."
                LastSync = $lastSync
                HoursAgo = $hoursAgo
            }
        }
    }
    catch {
        return @{
            Status = "ERROR"
            Message = "Error reading sync state: $_"
            LastSync = $null
            HoursAgo = $null
        }
    }
}

$status = Get-SyncStatus -StatePath $StateFile

# Output in a format the agent can use
Write-Output "SyncStatus=$($status.Status)"
Write-Output "LastSync=$($status.LastSync)"
Write-Output "HoursAgo=$($status.HoursAgo)"
Write-Output "Message=$($status.Message)"

# Also write to a temp file for programmatic access
$tempOutput = @{
    status = $status.Status
    lastSync = $status.LastSync
    hoursAgo = $status.HoursAgo
    message = $status.Message
}

$tempFile = Join-Path $env:TEMP "opencode-sync-status.json"
$tempOutput | ConvertTo-Json | Set-Content $tempFile -Encoding UTF8

# Return proper exit code
if ($status.Status -eq "OK") {
    exit 0
    }
    elseif ($status.Status -eq "NEVER" -or $status.Status -eq "STALE") {
        exit 1
    }
    else {
        exit 2
    }
}
catch {
    Write-Error "Check failed: $_"
    exit 1
}
