# ComfyUI API Quick Reference

Base URL: `http://127.0.0.1:8188`

## System

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/system_stats` | GET | GPU info, VRAM usage, ComfyUI version |
| `/queue` | GET | Current queue status |
| `/interrupt` | POST | Cancel current generation |
| `/free` | POST | Free VRAM (body: `{"unload_models": true}`) |

## Models & Nodes

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/object_info` | GET | All installed node classes with inputs/outputs |
| `/object_info/{node_name}` | GET | Single node class info |
| `/models/{type}` | GET | List models by type: checkpoints, loras, vae, controlnet, etc. |

## Workflow Execution

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/prompt` | POST | Queue a workflow (body: `{"prompt": {...}, "client_id": "..."}`) |
| `/history` | GET | All execution history |
| `/history/{prompt_id}` | GET | Specific execution result |
| `/view` | GET | View output image (params: `filename`, `subfolder`, `type`) |

## File Operations

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/upload/image` | POST | Upload image (multipart: `image` file, `subfolder`, `type`) |
| `/upload/mask` | POST | Upload mask image |

## Polling Pattern (for Claude Code)

```bash
# 1. Queue workflow
curl -X POST http://127.0.0.1:8188/prompt -H "Content-Type: application/json" -d '{"prompt": WORKFLOW_JSON}'
# Returns: {"prompt_id": "abc-123"}

# 2. Poll for completion (every 5s)
curl http://127.0.0.1:8188/history/abc-123
# When complete: {"abc-123": {"outputs": {...}, "status": {"completed": true}}}

# 3. Retrieve output
curl "http://127.0.0.1:8188/view?filename=output.png&subfolder=&type=output"
```

## Common Model Type Paths

| Type | API Value | Directory |
|------|-----------|-----------|
| Checkpoints | `checkpoints` | `models/checkpoints/` |
| LoRAs | `loras` | `models/loras/` |
| VAE | `vae` | `models/vae/` |
| ControlNet | `controlnet` | `models/controlnet/` |
| CLIP | `clip` | `models/clip/` |
| CLIP Vision | `clip_vision` | `models/clip_vision/` |
| Upscale | `upscale_models` | `models/upscale_models/` |
| Diffusion | `diffusion_models` | `models/diffusion_models/` |
