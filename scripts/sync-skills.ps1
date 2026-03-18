<#
.SYNOPSIS
    Syncs ComfyUI Expert skills from local project to global ~/.claude/skills/
.DESCRIPTION
    Copies SKILL.md, references/, and eval/ directories for all global-published skills.
    Local project versions are authoritative. Run after editing any skill.
.EXAMPLE
    pwsh -File scripts/sync-skills.ps1
    pwsh -File scripts/sync-skills.ps1 -DryRun
    pwsh -File scripts/sync-skills.ps1 -Skill comfyui-character-gen
#>
param(
    [switch]$DryRun,
    [string]$Skill
)

$LocalBase = Join-Path $PSScriptRoot ".." "skills"
$GlobalBase = Join-Path $env:USERPROFILE ".claude" "skills"

# Skills published to global (add new ones here)
$GlobalSkills = @(
    "comfyui-character-gen",
    "comfyui-prompt-interview",
    "comfyui-video-production",
    "comfyui-workflow-builder"
)

if ($Skill) {
    if ($Skill -notin $GlobalSkills) {
        Write-Host "Warning: '$Skill' is not in the global skills list. Syncing anyway." -ForegroundColor Yellow
    }
    $GlobalSkills = @($Skill)
}

$synced = 0
$skipped = 0

foreach ($skillName in $GlobalSkills) {
    $localPath = Join-Path $LocalBase $skillName
    $globalPath = Join-Path $GlobalBase $skillName

    if (-not (Test-Path (Join-Path $localPath "SKILL.md"))) {
        Write-Host "SKIP: $skillName (no local SKILL.md)" -ForegroundColor Yellow
        $skipped++
        continue
    }

    $localHash = (Get-FileHash (Join-Path $localPath "SKILL.md")).Hash
    $globalSkillMd = Join-Path $globalPath "SKILL.md"
    $globalHash = if (Test-Path $globalSkillMd) { (Get-FileHash $globalSkillMd).Hash } else { "" }

    if ($localHash -eq $globalHash) {
        Write-Host "OK: $skillName (already in sync)" -ForegroundColor Green
        $skipped++
        continue
    }

    if ($DryRun) {
        Write-Host "WOULD SYNC: $skillName" -ForegroundColor Cyan
        $synced++
        continue
    }

    # Create global directory
    if (-not (Test-Path $globalPath)) {
        New-Item -ItemType Directory -Path $globalPath -Force | Out-Null
    }

    # Copy SKILL.md
    Copy-Item (Join-Path $localPath "SKILL.md") $globalSkillMd -Force
    Write-Host "SYNCED: $skillName/SKILL.md" -ForegroundColor Green

    # Copy references/ if exists with content
    $localRefs = Join-Path $localPath "references"
    if ((Test-Path $localRefs) -and (Get-ChildItem $localRefs -File -ErrorAction SilentlyContinue)) {
        $globalRefs = Join-Path $globalPath "references"
        if (-not (Test-Path $globalRefs)) {
            New-Item -ItemType Directory -Path $globalRefs -Force | Out-Null
        }
        Copy-Item "$localRefs\*" $globalRefs -Recurse -Force
        Write-Host "  + references/" -ForegroundColor DarkGreen
    }

    # Copy eval/ if exists
    $localEval = Join-Path $localPath "eval"
    if (Test-Path $localEval) {
        $globalEval = Join-Path $globalPath "eval"
        if (-not (Test-Path $globalEval)) {
            New-Item -ItemType Directory -Path $globalEval -Force | Out-Null
        }
        Copy-Item "$localEval\*" $globalEval -Recurse -Force
        Write-Host "  + eval/" -ForegroundColor DarkGreen
    }

    $synced++
}

Write-Host ""
Write-Host "Done: $synced synced, $skipped skipped" -ForegroundColor Cyan
