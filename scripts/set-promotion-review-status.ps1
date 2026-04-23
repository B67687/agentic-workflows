<#
.SYNOPSIS
    Sets review status for a promotion candidate.

.DESCRIPTION
    Updates the review state for a lesson candidate.

.PARAMETER CandidateId
    The candidate ID to update.

.PARAMETER Status
    New status (pending, in-review, promoted, kept-local, discarded).

.PARAMETER Destination
    For promoted: destination workspace.

.PARAMETER GeneralizedWording
    Generalized wording for promotion.

.PARAMETER Notes
    Notes about the decision.

.PARAMETER StateFile
    Path to cross-domain review state file.

.EXAMPLE
    .\set-promotion-review-status.ps1 -CandidateId "1" -Status promoted -Destination "AI Prompting"

.NOTES
    Author: AI Prompting
    Date: 2026-04-14
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$CandidateId,

    [Parameter(Mandatory = $true)]
    [ValidateSet("pending", "in-review", "promoted", "kept-local", "discarded")]
    [string]$Status,

    [string]$Destination,

    [string]$GeneralizedWording,

    [string]$Notes,

    [string]$StateFile = (Join-Path (Split-Path $PSScriptRoot -Parent) "workflow\cross-domain-review-state.json")
)

try {
    function Get-StateObject {
    param(
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return [pscustomobject]@{
            version = 1
            items = @()
        }
    }

    $raw = Get-Content -LiteralPath $Path -Raw
    if (-not $raw.Trim()) {
        return [pscustomobject]@{
            version = 1
            items = @()
        }
    }

    $data = $raw | ConvertFrom-Json

    if (-not ($data.PSObject.Properties.Name -contains "items")) {
        return [pscustomobject]@{
            version = 1
            items = @($data)
        }
    }

    if (-not $data.items) {
        $data.items = @()
    }

    return $data
}

$state = Get-StateObject -Path $StateFile
$items = [System.Collections.Generic.List[object]]::new()

foreach ($item in @($state.items)) {
    $items.Add($item)
}

$existing = $items | Where-Object { $_.id -eq $CandidateId } | Select-Object -First 1

if (-not $existing) {
    $existing = [pscustomobject]@{
        id = $CandidateId
        status = "pending"
        destination = $null
        generalizedWording = $null
        notes = $null
        reviewedAt = $null
    }
    $items.Add($existing)
}

$existing.status = $Status
$existing.reviewedAt = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'

if ($PSBoundParameters.ContainsKey("Destination")) {
    $existing.destination = $Destination
}

if ($PSBoundParameters.ContainsKey("GeneralizedWording")) {
    $existing.generalizedWording = $GeneralizedWording
}

if ($PSBoundParameters.ContainsKey("Notes")) {
    $existing.notes = $Notes
}

$output = [pscustomobject]@{
    version = 1
    items = @($items)
}

$output | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $StateFile -Encoding UTF8

    Write-Output "UPDATED: $CandidateId -> $Status"
    Write-Output "STATE: $StateFile"
}
catch {
    Write-Error "Set status failed: $_"
    exit 1
}
