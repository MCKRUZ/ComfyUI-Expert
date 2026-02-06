<#
.SYNOPSIS
    Sets up VideoAgent skills for OpenClaw.

.DESCRIPTION
    Copies (or symlinks) the 12 VideoAgent skills plus workspace files
    into OpenClaw's directory structure. Run once after cloning.

.PARAMETER OpenClawDir
    Path to your OpenClaw workspace (default: ~/.openclaw/workspace)

.PARAMETER Symlink
    Use symlinks instead of copies. Keeps skills in sync with the repo
    but requires running as administrator on Windows.

.EXAMPLE
    pwsh -File openclaw/setup.ps1
    pwsh -File openclaw/setup.ps1 -OpenClawDir "~/.openclaw/workspace"
    pwsh -File openclaw/setup.ps1 -Symlink
#>

param(
    [string]$OpenClawDir = (Join-Path $HOME ".openclaw" "workspace"),
    [switch]$Symlink
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$SkillsSource = Join-Path $RepoRoot "skills"
$SkillsDest = Join-Path $OpenClawDir "skills"
$WorkspaceFiles = @("AGENTS.md", "SOUL.md", "TOOLS.md")

# Verify source exists
if (-not (Test-Path $SkillsSource)) {
    Write-Error "Skills directory not found at: $SkillsSource"
    exit 1
}

Write-Host ""
Write-Host "  VideoAgent OpenClaw Setup" -ForegroundColor Cyan
Write-Host "  =========================" -ForegroundColor Cyan
Write-Host "  Repo:      $RepoRoot"
Write-Host "  Target:    $OpenClawDir"
Write-Host "  Mode:      $(if ($Symlink) { 'Symlink' } else { 'Copy' })"
Write-Host ""

# Create target directories
if (-not (Test-Path $SkillsDest)) {
    New-Item -ItemType Directory -Path $SkillsDest -Force | Out-Null
    Write-Host "  Created: $SkillsDest" -ForegroundColor Green
}

# Copy or symlink each skill
$skills = Get-ChildItem -Path $SkillsSource -Directory
foreach ($skill in $skills) {
    $dest = Join-Path $SkillsDest $skill.Name

    if (Test-Path $dest) {
        if ($Symlink) {
            # Remove existing to recreate symlink
            Remove-Item $dest -Recurse -Force
        }
        else {
            Remove-Item $dest -Recurse -Force
        }
    }

    if ($Symlink) {
        New-Item -ItemType SymbolicLink -Path $dest -Target $skill.FullName | Out-Null
        Write-Host "  Linked:  $($skill.Name) -> $($skill.FullName)" -ForegroundColor Green
    }
    else {
        Copy-Item -Path $skill.FullName -Destination $dest -Recurse
        Write-Host "  Copied:  $($skill.Name)" -ForegroundColor Green
    }
}

# Copy workspace files (AGENTS.md, SOUL.md, TOOLS.md)
$openclawSource = Join-Path $RepoRoot "openclaw"
foreach ($file in $WorkspaceFiles) {
    $src = Join-Path $openclawSource $file
    $dst = Join-Path $OpenClawDir $file

    if (Test-Path $src) {
        Copy-Item -Path $src -Destination $dst -Force
        Write-Host "  Copied:  $file -> $OpenClawDir" -ForegroundColor Green
    }
    else {
        Write-Host "  Missing: $file (skipped)" -ForegroundColor Yellow
    }
}

# Copy foundation and references alongside skills for {baseDir} access
$sharedDirs = @("foundation", "references")
foreach ($dir in $sharedDirs) {
    $src = Join-Path $RepoRoot $dir
    $dst = Join-Path $OpenClawDir $dir

    if (Test-Path $src) {
        if (Test-Path $dst) {
            Remove-Item $dst -Recurse -Force
        }

        if ($Symlink) {
            New-Item -ItemType SymbolicLink -Path $dst -Target $src | Out-Null
            Write-Host "  Linked:  $dir -> $src" -ForegroundColor Green
        }
        else {
            Copy-Item -Path $src -Destination $dst -Recurse
            Write-Host "  Copied:  $dir/" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "  Setup complete! $($skills.Count) skills installed." -ForegroundColor Cyan
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor Yellow
Write-Host "  1. Copy openclaw/openclaw.example.json settings into ~/.openclaw/openclaw.json"
Write-Host "  2. Edit COMFYUI_URL and COMFYUI_PATH to match your setup"
Write-Host "  3. Restart OpenClaw to pick up the new skills"
Write-Host ""
