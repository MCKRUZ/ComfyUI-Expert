# VideoAgent Reference Sync
# Syncs updated reference files to the global comfyui-character-gen skill.
# VideoAgent skills are NOT deployed globally - they're loaded per-session
# via CLAUDE.md when you launch with video-agent.bat.
#
# Usage: pwsh -File scripts/deploy.ps1 [-DryRun]

param(
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$claudeDir = Join-Path $env:USERPROFILE ".claude"
$skillsDest = Join-Path $claudeDir "skills"

Write-Host "VideoAgent Reference Sync" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host "Source: $repoRoot"
Write-Host ""

# Sync reference files to global comfyui-character-gen skill
Write-Host "[Sync] comfyui-character-gen references" -ForegroundColor Yellow
$charGenRefs = Join-Path $skillsDest "comfyui-character-gen" "references"
$repoRefs = Join-Path $repoRoot "references"

if (Test-Path $charGenRefs) {
    $refFiles = @(
        "models.md",
        "workflows.md",
        "lora-training.md",
        "voice-synthesis.md",
        "research-2025.md",
        "evolution.md"
    )

    foreach ($ref in $refFiles) {
        $src = Join-Path $repoRefs $ref
        $dst = Join-Path $charGenRefs $ref

        if (Test-Path $src) {
            if ($DryRun) {
                Write-Host "  DRY RUN: Would copy $ref"
            } else {
                Copy-Item -Path $src -Destination $dst -Force
                Write-Host "  Synced $ref" -ForegroundColor Green
            }
        } else {
            Write-Host "  SKIP: $ref not found in repo" -ForegroundColor Red
        }
    }
} else {
    Write-Host "  SKIP: comfyui-character-gen not installed at $charGenRefs" -ForegroundColor Red
    Write-Host "  (This is fine - the global skill is optional)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Sync complete!" -ForegroundColor Green
Write-Host ""
Write-Host "NOTE: VideoAgent skills are NOT deployed globally." -ForegroundColor Yellow
Write-Host "Launch a session with: video-agent.bat" -ForegroundColor Yellow

if ($DryRun) {
    Write-Host "(Dry run - no files were changed)" -ForegroundColor Yellow
}
