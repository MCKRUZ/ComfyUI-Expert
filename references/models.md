# Model Reference Guide

Complete specifications for all recommended models. Download links, file paths, and compatibility notes.

## Directory Structure

```
ComfyUI/
├── models/
│   ├── checkpoints/          # Base models (FLUX, SDXL, SD1.5)
│   ├── loras/                # LoRA adapters
│   ├── controlnet/           # ControlNet models
│   ├── clip_vision/          # CLIP vision encoders
│   ├── ipadapter/            # IP-Adapter models
│   ├── instantid/            # InstantID models
│   ├── insightface/          # Face analysis models
│   ├── facerestore_models/   # Face restoration (GFPGAN, CodeFormer)
│   ├── ultralytics/bbox/     # Detection models
│   ├── upscale_models/       # Upscaler models
│   └── diffusion_models/     # Video diffusion models (Wan)
└── custom_nodes/
    └── ComfyUI-AnimateDiff-Evolved/models/  # Motion modules
```

---

<!-- Updated: 2026-03-27 | Source: ComfyUI Blog, GitHub releases, HuggingFace, WebSearch -->

## Checkpoint Models

### Reve Image 1.0 "Halfmoon" (Partner Nodes — Cloud)
- **Access**: ComfyUI Partner Nodes (Node Library or Templates → "Reve")
- **Nodes**: `Reve Image Create`, `Reve Image Edit`, `Reve Image Remix`
- **Max Resolution**: 4K
- **Speed**: ~5 seconds per generation
- **Best for**: Fashion editorial, cinematic aesthetics, strong prompt adherence, image editing + remixing
- **Notes**: Does NOT run locally — API-based Partner Node. May open-source in future (devs forked ComfyUI repo).

### Seedream 5.0 Lite (Partner Nodes — Cloud)
- **Access**: ComfyUI Partner Nodes via BytePlus
- **New in 5.0**: Web-connected retrieval (live world knowledge), improved instruction following
- **Best for**: Current events imagery, reference-consistent generation, dense text rendering
- **Notes**: Released Feb 2026. Prior versions (4.0, 4.5) also available.

### FLUX.1-dev (Recommended for Photorealism)
- **Download**: https://huggingface.co/black-forest-labs/FLUX.1-dev
- **Files**: `flux1-dev.safetensors` (23.8GB)
- **Path**: `models/checkpoints/`
- **Also requires**: 
  - T5 encoder: `t5xxl_fp16.safetensors` → `models/clip/`
  - CLIP-L: `clip_l.safetensors` → `models/clip/`
  - VAE: `ae.safetensors` → `models/vae/`
- **VRAM**: 16GB+ (FP16), 10GB (FP8)
- **Notes**: Best photorealism, slow generation. Use `--fp8_e4m3fn-unet` for VRAM savings.

### FLUX Kontext (Character Editing)
- **Download**: https://huggingface.co/black-forest-labs/FLUX.1-Kontext-dev
- **Path**: `models/checkpoints/`
- **Use case**: Edit existing character images without retraining
- **VRAM**: 16GB+

### RealVisXL V5.0 (Fast SDXL Photorealism)
- **Download**: https://civitai.com/models/139562/realvisxl-v50
- **File**: `RealVisXL_V5.0.safetensors`
- **Path**: `models/checkpoints/`
- **VRAM**: 8GB+
- **Notes**: Good balance of speed and quality for SDXL workflows

### Juggernaut XL Ragnarok
- **Download**: https://civitai.com/models/133005/juggernaut-xl
- **Path**: `models/checkpoints/`
- **VRAM**: 8GB+
- **Notes**: Excellent for diverse human subjects

---

## Identity Preservation Models

### InstantID
- **IP-Adapter**: https://huggingface.co/InstantX/InstantID
  - File: `ip-adapter.bin` → `models/instantid/`
- **ControlNet**: Same repo
  - File: `ControlNetModel/diffusion_pytorch_model.safetensors` → `models/controlnet/`
  - Rename to: `instantid_controlnet.safetensors`
- **Requires**: InsightFace `antelopev2` model
- **VRAM**: 8GB+ additional

### IP-Adapter FaceID Plus V2
- **Download**: https://huggingface.co/h94/IP-Adapter-FaceID
- **Files**:
  - `ip-adapter-faceid-plusv2_sd15.bin` → `models/ipadapter/`
  - `ip-adapter-faceid-plusv2_sd15_lora.safetensors` → `models/loras/`
- **VRAM**: 6GB+ additional
- **Notes**: Faster than InstantID, auto-loads paired LoRA

### IP-Adapter SDXL
- **Download**: https://huggingface.co/h94/IP-Adapter
- **Files**:
  - `ip-adapter_sdxl_vit-h.safetensors` → `models/ipadapter/`
  - `ip-adapter-plus_sdxl_vit-h.safetensors` → `models/ipadapter/`
  - `ip-adapter-plus-face_sdxl_vit-h.safetensors` → `models/ipadapter/`
- **CLIP Vision**: `CLIP-ViT-H-14-laion2B-s32B-b79K.safetensors` → `models/clip_vision/`

### PuLID Flux II
- **Download**: https://huggingface.co/guozinan/PuLID
- **File**: `pulid_flux_v0.9.1.safetensors` → `models/pulid/`
- **Requires**: EVA-CLIP model
- **VRAM**: 16GB+
- **Notes**: Highest fidelity, no model pollution, slowest

### InsightFace (Required for all face methods)
- **Download**: https://huggingface.co/datasets/Gourieff/ReActor/tree/main/models
- **Files**:
  - `inswapper_128.onnx` → `models/insightface/`
  - `buffalo_l/` folder → `models/insightface/models/buffalo_l/`
  - `antelopev2/` folder → `models/insightface/models/antelopev2/`

---

## ControlNet Models

### SDXL ControlNet
- **OpenPose**: `control-lora-openposeXL2-rank256.safetensors`
- **Depth**: `control-lora-depth-rank256.safetensors`
- **Canny**: `control-lora-canny-rank256.safetensors`
- **Download**: https://huggingface.co/stabilityai/control-lora
- **Path**: `models/controlnet/`

### FLUX ControlNet (Union)
- **Download**: https://huggingface.co/InstantX/FLUX.1-dev-Controlnet-Union
- **File**: `diffusion_pytorch_model.safetensors`
- **Path**: `models/controlnet/`
- **Notes**: Single model handles multiple control types

### SD 1.5 ControlNet
- **Download**: https://huggingface.co/lllyasviel/ControlNet-v1-1
- **Files**: `control_v11p_sd15_openpose.pth`, etc.
- **Path**: `models/controlnet/`

---

## Face Restoration Models

### CodeFormer
- **Download**: https://github.com/sczhou/CodeFormer/releases
- **File**: `codeformer.pth` → `models/facerestore_models/`

### GFPGAN
- **Download**: https://github.com/TencentARC/GFPGAN/releases
- **File**: `GFPGANv1.4.pth` → `models/facerestore_models/`

### RestoreFormer
- **Download**: https://github.com/wzhouxiff/RestoreFormer
- **File**: `RestoreFormer.pth` → `models/facerestore_models/`

---

## Detection Models (for FaceDetailer)

### YOLO Face Detection
- **Download**: https://huggingface.co/Bingsu/adetailer/tree/main
- **Files**:
  - `face_yolov8m.pt` → `models/ultralytics/bbox/`
  - `face_yolov8n.pt` → `models/ultralytics/bbox/`
  - `hand_yolov8n.pt` → `models/ultralytics/bbox/`

### SAM (Segment Anything)
- **Download**: https://huggingface.co/spaces/abhishek/StableSAM/tree/main
- **File**: `sam_vit_b_01ec64.pth` → `models/sams/`

---

## Upscale Models

### 4x-UltraSharp
- **Download**: https://civitai.com/models/116225/4x-ultrasharp
- **Path**: `models/upscale_models/`
- **Notes**: Best for faces and fine detail

### 4x-Foolhardy-Remacri
- **Download**: https://civitai.com/models/40067
- **Path**: `models/upscale_models/`
- **Notes**: Good general purpose

### SUPIR
- **Download**: https://huggingface.co/Kijai/SUPIR_pruned
- **Path**: `models/upscale_models/`
- **Notes**: AI-enhanced upscaling, slower but better quality

---

## Video Models

### Grok Reference-to-Video + Video Extend (Partner Nodes — xAI)
- **Access**: ComfyUI v0.18.2+ Partner Nodes (search "Grok" on canvas)
- **Reference-to-Video**: Up to 7 reference images → consistent character/scene video; ~100s for 10s@720p
- **Video Extend**: Seamlessly extend any existing video; ~60s for 10s extension
- **Max length**: 15 seconds
- **Notes**: Added in ComfyUI v0.18.2 (March 25, 2026). Excels at photorealistic output and precise text rendering.

### Seedance 2.0 (Partner Nodes — ByteDance)
- **Access**: ComfyUI Partner Nodes; also community nodes via muapi.ai
- **Resolution**: 2K (2048px)
- **Features**: Native audio-video sync, multi-modal input (up to 12 assets), first+last frame control, multi-shot storytelling
- **Lip-sync**: Phoneme-level across 8 languages (EN, ZH, JA, KO, ES, FR, DE, PT)
- **Notes**: Released Feb 2026. Requires Seedance API access (Pro/Enterprise).

### Wan 2.1 (Recommended)
- **14B T2V**: `wan2.1_t2v_14b_bf16.safetensors`
- **14B I2V**: `wan2.1_i2v_720p_14b_bf16.safetensors`
- **1.3B T2V**: `wan2.1_t2v_1.3b_bf16.safetensors`
- **Download**: https://huggingface.co/Wan-AI/Wan2.1-Preview
- **Path**: `models/diffusion_models/`
- **Text Encoder**: `umt5_xxl_fp8_e4m3fn_scaled.safetensors` → `models/clip/`
- **CLIP**: `open_clip_vit_h_14.safetensors` → `models/clip_vision/`
- **VAE**: `wan_2.1_vae.safetensors` → `models/vae/`

### Wan 2.2 5B Fun Inpaint / Fun Control
- **Fun Inpaint model**: `wan2.2_fun_inpaint_high_noise_14B_fp8_scaled.safetensors` + low_noise variant
  - Download: https://huggingface.co/Wan-Video/Wan2.2
  - Path: `models/diffusion_models/`
- **LightX2V LoRA** (4-step fast): `wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors` → `models/loras/`
- **VAE**: `wan_2.1_vae.safetensors` (same as Wan 2.1)
- **VRAM**: 10GB minimum (5B); 12GB for 720p @ 5-8s
- **Key node**: `WanFunInpaintToVideo` — takes start + end frame → interpolated video
- **Use case**: First-to-last frame interpolation, inpainting, seamless image morphing
- **License**: Apache 2.0 (commercial use OK)
- **Template**: ComfyUI Dashboard → Workflow → Browse Template → Video → "Wan2.2 Fun Inpaint"

### AnimateDiff
- **Motion Module V3**: `v3_sd15_mm.ckpt`
- **Lightning (fast)**: `animatediff_lightning_4step.safetensors`
- **Download**: https://huggingface.co/guoyww/animatediff
- **Path**: `custom_nodes/ComfyUI-AnimateDiff-Evolved/models/`

### Motion LoRAs
- **Download**: https://huggingface.co/guoyww/animatediff/tree/main/motion_lora
- **Files**: `v2_lora_ZoomIn.ckpt`, `v2_lora_PanLeft.ckpt`, etc.
- **Path**: `custom_nodes/ComfyUI-AnimateDiff-Evolved/motion_lora/`

---

## Voice/Lip-Sync Models

### Wav2Lip
- **Download**: https://github.com/Rudrabha/Wav2Lip
- **Files**: 
  - `wav2lip_gan.pth` (better quality)
  - `wav2lip.pth` (faster)
- **Path**: Varies by ComfyUI node implementation

### SadTalker
- **Download**: https://github.com/OpenTalker/SadTalker
- **Required models**: Multiple, see repo releases
- **Notes**: Generates head motion + expressions from audio

### LivePortrait
- **Download**: https://github.com/KwaiVGI/LivePortrait
- **Notes**: Best expression control, non-commercial license for InsightFace components

---

## LoRA Training Tools

### Kohya_ss (SDXL/SD1.5)
- **Repo**: https://github.com/bmaltais/kohya_ss
- **Notes**: Most mature, GUI available

### AI-Toolkit (FLUX)
- **Repo**: https://github.com/ostris/ai-toolkit
- **Notes**: Beginner-friendly, 24GB VRAM for standard training

### SimpleTuner (FLUX, Advanced)
- **Repo**: https://github.com/bghira/SimpleTuner
- **Notes**: NF4 quantization enables 9GB VRAM training

### FluxGym (Low VRAM FLUX)
- **Repo**: https://github.com/cocktailpeanut/fluxgym
- **Notes**: Optimized for 12-16GB VRAM

---

## Skin Texture LoRAs (Combine with Character LoRA)

### Realistic Skin Texture
- **Download**: https://civitai.com/models/238756
- **File**: `Realistic_Skin_Texture_SkinF1dV2.5.safetensors`
- **Path**: `models/loras/`
- **Strength**: 0.2-0.4 (subtle enhancement)

### Detail Tweaker
- **Download**: https://civitai.com/models/122359
- **Path**: `models/loras/`
- **Notes**: Enhances fine detail without changing style
