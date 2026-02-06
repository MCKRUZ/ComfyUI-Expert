# ComfyUI Inventory Scanner (Offline Mode)
# Scans ComfyUI directory structure and generates state/inventory.json
#
# Usage: pwsh -File scripts/scan-inventory.ps1 -ComfyUIPath "D:\ComfyUI"

param(
    [Parameter(Mandatory = $true)]
    [string]$ComfyUIPath,

    [string]$OutputPath
)

$ErrorActionPreference = "Stop"

if (-not $OutputPath) {
    $OutputPath = Join-Path (Split-Path -Parent (Split-Path -Parent $PSCommandPath)) "state" "inventory.json"
}

Write-Host "ComfyUI Inventory Scanner" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host "ComfyUI Path: $ComfyUIPath"
Write-Host "Output: $OutputPath"
Write-Host ""

if (-not (Test-Path $ComfyUIPath)) {
    Write-Host "[FAIL] ComfyUI path not found: $ComfyUIPath" -ForegroundColor Red
    exit 1
}

$modelsDir = Join-Path $ComfyUIPath "models"
$customNodesDir = Join-Path $ComfyUIPath "custom_nodes"

# Model file extensions per type
$modelDirs = @{
    "checkpoints"       = @("*.safetensors", "*.ckpt")
    "loras"             = @("*.safetensors")
    "vae"               = @("*.safetensors", "*.pt")
    "controlnet"        = @("*.safetensors", "*.pth")
    "clip"              = @("*.safetensors")
    "clip_vision"       = @("*.safetensors")
    "upscale_models"    = @("*.pth", "*.safetensors")
    "diffusion_models"  = @("*.safetensors")
    "ipadapter"         = @("*.safetensors", "*.bin")
    "instantid"         = @("*.bin")
    "insightface"       = @("*.onnx")
    "facerestore_models"= @("*.pth")
}

$detectionDir = Join-Path $modelsDir "ultralytics" "bbox"

$inventory = @{
    last_updated    = (Get-Date -Format "o")
    mode            = "offline"
    comfyui_version = "unknown"
    comfyui_path    = $ComfyUIPath
    system          = @{
        gpu           = "unknown (offline scan)"
        vram_total_gb = 0
        vram_free_gb  = 0
    }
    models          = @{}
    custom_nodes    = @()
}

# Scan models
Write-Host "Scanning models..." -ForegroundColor Yellow
foreach ($type in $modelDirs.Keys) {
    $dir = Join-Path $modelsDir $type
    $files = @()

    if (Test-Path $dir) {
        foreach ($pattern in $modelDirs[$type]) {
            $found = Get-ChildItem -Path $dir -Filter $pattern -File -ErrorAction SilentlyContinue
            foreach ($f in $found) {
                $files += $f.Name
            }
        }
    }

    $inventory.models[$type] = $files
    Write-Host "  $type : $($files.Count) file(s)"
}

# Scan detection models
if (Test-Path $detectionDir) {
    $detFiles = Get-ChildItem -Path $detectionDir -Filter "*.pt" -File -ErrorAction SilentlyContinue
    $inventory.models["detection"] = @($detFiles | ForEach-Object { $_.Name })
    Write-Host "  detection: $($inventory.models['detection'].Count) file(s)"
}

# Scan AnimateDiff motion modules
$animDiffModels = Join-Path $customNodesDir "ComfyUI-AnimateDiff-Evolved" "models"
if (Test-Path $animDiffModels) {
    $motionFiles = Get-ChildItem -Path $animDiffModels -Include "*.ckpt", "*.safetensors" -File -ErrorAction SilentlyContinue
    $inventory.models["animatediff_motion"] = @($motionFiles | ForEach-Object { $_.Name })
    Write-Host "  animatediff_motion: $($inventory.models['animatediff_motion'].Count) file(s)"
}

# Scan custom nodes
Write-Host ""
Write-Host "Scanning custom nodes..." -ForegroundColor Yellow
if (Test-Path $customNodesDir) {
    $nodeDirs = Get-ChildItem -Path $customNodesDir -Directory -ErrorAction SilentlyContinue
    $inventory.custom_nodes = @($nodeDirs | ForEach-Object { $_.Name } | Sort-Object)
    Write-Host "  Found: $($inventory.custom_nodes.Count) package(s)"
    foreach ($node in $inventory.custom_nodes) {
        Write-Host "    - $node"
    }
}

# Write inventory
$outputDir = Split-Path -Parent $OutputPath
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$inventory | ConvertTo-Json -Depth 5 | Set-Content -Path $OutputPath -Encoding UTF8

Write-Host ""
Write-Host "Inventory saved to: $OutputPath" -ForegroundColor Green

# Summary
$totalModels = 0
foreach ($type in $inventory.models.Keys) {
    $totalModels += $inventory.models[$type].Count
}

Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Total models: $totalModels"
Write-Host "  Custom nodes: $($inventory.custom_nodes.Count)"
