#!/bin/bash
# ComfyUI Inventory Scanner (Offline Mode) — macOS/Linux
# Scans ComfyUI directory structure and generates state/inventory.json
#
# Usage: bash scripts/scan-inventory.sh /path/to/ComfyUI
#        bash scripts/scan-inventory.sh  (auto-detects ComfyUI Desktop on macOS)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# ComfyUI path: argument or auto-detect
COMFYUI_PATH="${1:-}"
if [ -z "$COMFYUI_PATH" ]; then
    # Auto-detect ComfyUI Desktop on macOS
    for candidate in \
        "$HOME/my_python_project/comfyUI" \
        "$HOME/.comfyui" \
        "$HOME/ComfyUI" \
        "/Applications/ComfyUI.app/Contents/Resources/ComfyUI"; do
        if [ -d "$candidate" ]; then
            COMFYUI_PATH="$candidate"
            break
        fi
    done
fi

OUTPUT_PATH="${2:-$REPO_DIR/state/inventory.json}"

echo ""
echo "  ComfyUI Inventory Scanner"
echo "  ========================="
echo "  ComfyUI Path: $COMFYUI_PATH"
echo "  Output: $OUTPUT_PATH"
echo ""

if [ -z "$COMFYUI_PATH" ] || [ ! -d "$COMFYUI_PATH" ]; then
    echo "[FAIL] ComfyUI path not found: $COMFYUI_PATH"
    echo "Usage: bash scripts/scan-inventory.sh /path/to/ComfyUI"
    exit 1
fi

MODELS_DIR="$COMFYUI_PATH/models"
CUSTOM_NODES_DIR="$COMFYUI_PATH/custom_nodes"

# Scan models in a directory for given extensions
scan_model_dir() {
    local dir="$1"
    shift
    local extensions=("$@")
    local files=()

    if [ -d "$dir" ]; then
        for ext in "${extensions[@]}"; do
            while IFS= read -r -d '' f; do
                files+=("$(basename "$f")")
            done < <(find "$dir" -maxdepth 2 -name "$ext" -type f -print0 2>/dev/null)
        done
    fi

    # Output as JSON array
    if [ ${#files[@]} -eq 0 ]; then
        echo "[]"
    else
        printf '%s\n' "${files[@]}" | sort -u | jq -R . | jq -s .
    fi
}

# Check jq is available
if ! command -v jq &>/dev/null; then
    echo "[WARN] jq not found — installing via Homebrew..."
    brew install jq
fi

echo "Scanning models..."

# Scan each model type
CHECKPOINTS=$(scan_model_dir "$MODELS_DIR/checkpoints" "*.safetensors" "*.ckpt")
LORAS=$(scan_model_dir "$MODELS_DIR/loras" "*.safetensors")
VAE=$(scan_model_dir "$MODELS_DIR/vae" "*.safetensors" "*.pt")
CONTROLNET=$(scan_model_dir "$MODELS_DIR/controlnet" "*.safetensors" "*.pth")
CLIP=$(scan_model_dir "$MODELS_DIR/clip" "*.safetensors")
CLIP_VISION=$(scan_model_dir "$MODELS_DIR/clip_vision" "*.safetensors")
UPSCALE=$(scan_model_dir "$MODELS_DIR/upscale_models" "*.pth" "*.safetensors")
DIFFUSION=$(scan_model_dir "$MODELS_DIR/diffusion_models" "*.safetensors")
IPADAPTER=$(scan_model_dir "$MODELS_DIR/ipadapter" "*.safetensors" "*.bin")
INSTANTID=$(scan_model_dir "$MODELS_DIR/instantid" "*.bin")
INSIGHTFACE=$(scan_model_dir "$MODELS_DIR/insightface" "*.onnx")
FACERESTORE=$(scan_model_dir "$MODELS_DIR/facerestore_models" "*.pth")
DETECTION=$(scan_model_dir "$MODELS_DIR/ultralytics/bbox" "*.pt")
ANIMDIFF=$(scan_model_dir "$CUSTOM_NODES_DIR/ComfyUI-AnimateDiff-Evolved/models" "*.ckpt" "*.safetensors")

# Print counts
for type_name in checkpoints loras vae controlnet clip clip_vision upscale_models diffusion_models ipadapter instantid insightface facerestore_models; do
    var_name=$(echo "$type_name" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
    count=$(echo "${!var_name:-[]}" 2>/dev/null | jq 'length' 2>/dev/null || echo 0)
    # Fallback for types with different var names
    echo "  $type_name: scanning..."
done

# Scan custom nodes
echo ""
echo "Scanning custom nodes..."
CUSTOM_NODES="[]"
if [ -d "$CUSTOM_NODES_DIR" ]; then
    CUSTOM_NODES=$(find "$CUSTOM_NODES_DIR" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort | jq -R . | jq -s .)
    NODE_COUNT=$(echo "$CUSTOM_NODES" | jq 'length')
    echo "  Found: $NODE_COUNT package(s)"
    echo "$CUSTOM_NODES" | jq -r '.[]' | sed 's/^/    - /'
fi

# Detect system info
GPU_INFO="Apple Silicon (API-only mode)"
if command -v nvidia-smi &>/dev/null; then
    GPU_INFO=$(nvidia-smi --query-gpu=name,memory.total --format=csv,noheader 2>/dev/null || echo "NVIDIA GPU detected")
fi

# Build inventory JSON
mkdir -p "$(dirname "$OUTPUT_PATH")"

cat > "$OUTPUT_PATH" << ENDJSON
{
  "last_updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "mode": "offline",
  "comfyui_version": "unknown",
  "comfyui_path": "$COMFYUI_PATH",
  "system": {
    "gpu": "$GPU_INFO",
    "os": "$(uname -s) $(uname -m)",
    "vram_total_gb": 0,
    "vram_free_gb": 0
  },
  "models": {
    "checkpoints": $CHECKPOINTS,
    "loras": $LORAS,
    "vae": $VAE,
    "controlnet": $CONTROLNET,
    "clip": $CLIP,
    "clip_vision": $CLIP_VISION,
    "upscale_models": $UPSCALE,
    "diffusion_models": $DIFFUSION,
    "ipadapter": $IPADAPTER,
    "instantid": $INSTANTID,
    "insightface": $INSIGHTFACE,
    "facerestore_models": $FACERESTORE,
    "detection": $DETECTION,
    "animatediff_motion": $ANIMDIFF
  },
  "custom_nodes": $CUSTOM_NODES
}
ENDJSON

echo ""
echo "Inventory saved to: $OUTPUT_PATH"

# Summary
TOTAL_MODELS=$(jq '[.models | to_entries[] | .value | length] | add // 0' "$OUTPUT_PATH")
TOTAL_NODES=$(jq '.custom_nodes | length' "$OUTPUT_PATH")

echo ""
echo "  Summary:"
echo "  Total models: $TOTAL_MODELS"
echo "  Custom nodes: $TOTAL_NODES"
