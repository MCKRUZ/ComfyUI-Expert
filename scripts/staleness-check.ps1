# Staleness Check Hook (SessionStart)
# Reads the staleness report and outputs warnings for Claude to act on.
# Called by .claude/settings.local.json SessionStart hook.

$ErrorActionPreference = "SilentlyContinue"

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$reportFile = Join-Path $repoRoot "references" "staleness-report.md"

if (-not (Test-Path $reportFile)) {
    Write-Output "[VideoAgent] No staleness report found. Run research to initialize."
    exit 0
}

$content = Get-Content -Path $reportFile -Raw

# Check for "Not yet run"
if ($content -match "Not yet run") {
    Write-Output "[VideoAgent] Research has never been run. Consider asking: 'research latest ComfyUI updates'"
    exit 0
}

# Extract last run date from "**Date**: YYYY-MM-DD" pattern
if ($content -match '\*\*Date\*\*:\s*(\d{4}-\d{2}-\d{2})') {
    $lastRun = [datetime]::Parse($Matches[1])
    $daysSince = ([datetime]::Now - $lastRun).Days

    if ($daysSince -gt 14) {
        Write-Output "[VideoAgent] Research data is ${daysSince} days old. Consider asking: 'research latest ComfyUI updates'"
    }
}

# Check for stale entries in the status table
$staleCount = ([regex]::Matches($content, "Stale")).Count
if ($staleCount -gt 0) {
    Write-Output "[VideoAgent] ${staleCount} reference(s) are flagged as stale."
}

exit 0
