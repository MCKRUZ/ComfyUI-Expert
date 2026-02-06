# ComfyUI Connection Test
# Tests connection to ComfyUI REST API and displays system info
#
# Usage: pwsh -File scripts/connect-comfyui.ps1 [-Url "http://127.0.0.1:8188"]

param(
    [string]$Url = "http://127.0.0.1:8188"
)

$ErrorActionPreference = "Stop"

Write-Host "ComfyUI Connection Test" -ForegroundColor Cyan
Write-Host "=======================" -ForegroundColor Cyan
Write-Host "Target: $Url"
Write-Host ""

# Test basic connectivity
try {
    $response = Invoke-RestMethod -Uri "$Url/system_stats" -Method Get -TimeoutSec 10
    Write-Host "[OK] Connected to ComfyUI" -ForegroundColor Green
    Write-Host ""

    # System info
    Write-Host "System Info:" -ForegroundColor Yellow
    Write-Host "  OS: $($response.system.os)"
    Write-Host "  ComfyUI Version: $($response.system.comfyui_version)"
    Write-Host ""

    # GPU info
    if ($response.devices -and $response.devices.Count -gt 0) {
        $gpu = $response.devices[0]
        $vramTotalGB = [math]::Round($gpu.vram_total / 1GB, 1)
        $vramFreeGB = [math]::Round($gpu.vram_free / 1GB, 1)

        Write-Host "GPU:" -ForegroundColor Yellow
        Write-Host "  Name: $($gpu.name)"
        Write-Host "  VRAM Total: ${vramTotalGB}GB"
        Write-Host "  VRAM Free: ${vramFreeGB}GB"
        Write-Host "  VRAM Used: $([math]::Round($vramTotalGB - $vramFreeGB, 1))GB"
    }

    Write-Host ""

    # Queue status
    $queue = Invoke-RestMethod -Uri "$Url/queue" -Method Get -TimeoutSec 5
    $running = if ($queue.queue_running) { $queue.queue_running.Count } else { 0 }
    $pending = if ($queue.queue_pending) { $queue.queue_pending.Count } else { 0 }

    Write-Host "Queue:" -ForegroundColor Yellow
    Write-Host "  Running: $running"
    Write-Host "  Pending: $pending"
    Write-Host ""

    # Model counts
    Write-Host "Installed Models:" -ForegroundColor Yellow
    $modelTypes = @("checkpoints", "loras", "vae", "controlnet", "upscale_models", "diffusion_models")

    foreach ($type in $modelTypes) {
        try {
            $models = Invoke-RestMethod -Uri "$Url/models/$type" -Method Get -TimeoutSec 5
            $count = if ($models) { $models.Count } else { 0 }
            Write-Host "  $type : $count"
        } catch {
            Write-Host "  $type : (error)" -ForegroundColor Red
        }
    }

    Write-Host ""
    Write-Host "Connection successful! ComfyUI is ready." -ForegroundColor Green

} catch {
    Write-Host "[FAIL] Cannot connect to ComfyUI at $Url" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible causes:" -ForegroundColor Yellow
    Write-Host "  1. ComfyUI is not running"
    Write-Host "  2. ComfyUI is running on a different port"
    Write-Host "  3. Firewall is blocking the connection"
    Write-Host ""
    Write-Host "To start ComfyUI:" -ForegroundColor Yellow
    Write-Host '  cd D:\ComfyUI && python main.py --listen --highvram'
    Write-Host ""
    Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
