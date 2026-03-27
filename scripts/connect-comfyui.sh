#!/bin/bash
# ComfyUI Connection Test — macOS/Linux
# Tests connection to ComfyUI REST API and displays system info
#
# Usage: bash scripts/connect-comfyui.sh [URL]
#        bash scripts/connect-comfyui.sh http://127.0.0.1:8188

set -e

URL="${1:-http://127.0.0.1:8000}"

echo ""
echo "  ComfyUI Connection Test"
echo "  ======================="
echo "  Target: $URL"
echo ""

# Check jq
if ! command -v jq &>/dev/null; then
    echo "[WARN] jq not found — install with: brew install jq"
    exit 1
fi

# Test basic connectivity
RESPONSE=$(curl -s --connect-timeout 10 "$URL/system_stats" 2>/dev/null) || {
    echo "[FAIL] Cannot connect to ComfyUI at $URL"
    echo ""
    echo "Possible causes:"
    echo "  1. ComfyUI is not running"
    echo "  2. ComfyUI is running on a different port"
    echo "  3. Firewall is blocking the connection"
    echo ""
    echo "To start ComfyUI on macOS:"
    echo "  open /Applications/ComfyUI.app"
    exit 1
}

echo "[OK] Connected to ComfyUI"
echo ""

# System info
OS=$(echo "$RESPONSE" | jq -r '.system.os // "unknown"')
VERSION=$(echo "$RESPONSE" | jq -r '.system.comfyui_version // "unknown"')
echo "System Info:"
echo "  OS: $OS"
echo "  ComfyUI Version: $VERSION"
echo ""

# GPU info
GPU_NAME=$(echo "$RESPONSE" | jq -r '.devices[0].name // "unknown"')
VRAM_TOTAL=$(echo "$RESPONSE" | jq -r '.devices[0].vram_total // 0')
VRAM_FREE=$(echo "$RESPONSE" | jq -r '.devices[0].vram_free // 0')

if [ "$VRAM_TOTAL" != "0" ]; then
    VRAM_TOTAL_GB=$(echo "scale=1; $VRAM_TOTAL / 1073741824" | bc 2>/dev/null || echo "?")
    VRAM_FREE_GB=$(echo "scale=1; $VRAM_FREE / 1073741824" | bc 2>/dev/null || echo "?")
    echo "GPU:"
    echo "  Name: $GPU_NAME"
    echo "  VRAM Total: ${VRAM_TOTAL_GB}GB"
    echo "  VRAM Free: ${VRAM_FREE_GB}GB"
else
    echo "GPU: $GPU_NAME (no VRAM info — API-only mode)"
fi
echo ""

# Queue status
QUEUE=$(curl -s --connect-timeout 5 "$URL/queue" 2>/dev/null || echo '{}')
RUNNING=$(echo "$QUEUE" | jq '.queue_running | length // 0')
PENDING=$(echo "$QUEUE" | jq '.queue_pending | length // 0')

echo "Queue:"
echo "  Running: $RUNNING"
echo "  Pending: $PENDING"
echo ""

# Model counts
echo "Installed Models:"
for type in checkpoints loras vae controlnet upscale_models diffusion_models; do
    MODELS=$(curl -s --connect-timeout 5 "$URL/models/$type" 2>/dev/null || echo '[]')
    COUNT=$(echo "$MODELS" | jq 'length // 0' 2>/dev/null || echo "?")
    echo "  $type: $COUNT"
done

echo ""
echo "Connection successful! ComfyUI is ready."
