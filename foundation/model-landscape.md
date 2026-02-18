# Model Landscape (Top 3 per Category)

Quick reference for model selection. Full specs in `references/models.md`.

<!-- Updated: 2026-02-18 | Source: NVIDIA Blog, ComfyUI Changelog, HuggingFace -->

> **⚠️ NVFP4 Critical Note**: NVFP4 acceleration on RTX 50 Series **requires PyTorch built with CUDA 13.0 (cu130)**. Without it, NVFP4 models run up to **2x slower** than FP8. Verify with `torch.version.cuda` before using NVFP4 checkpoints.

> **Performance Update (Feb 2026)**: ComfyUI is **40% faster** on all NVIDIA GPUs via async offloading + pinned memory (enabled by default). RTX 50 Series: NVFP4 = 3x faster / 60% less VRAM; NVFP8 = 2x faster / 40% less VRAM.

## Image Generation

| Rank | Model | Best For | VRAM | Notes |
|------|-------|----------|------|-------|
| 1 | FLUX.1-dev | Photorealism, highest quality | 16GB+ | NVFP4/NVFP8 available |
| 2 | FLUX.2 | Multi-reference (up to 10 images) | 24GB+ | NVFP4 available |
| 3 | FLUX Kontext | Iterative character editing | 12-32GB | NVFP4 available |
| 4 | **Z-Image** | Non-distilled, flexible quality | 12GB+ | **NEW Feb 2026**, Day-0 ComfyUI support |
| 5 | RealVisXL V5.0 | Fast SDXL photorealism | 8GB+ | |

## Identity Preservation

| Rank | Method | Best For | VRAM |
|------|--------|----------|------|
| 1 | InfiniteYou | Highest identity fidelity | 24GB |
| 2 | FLUX Kontext | Edit without retraining | 12-32GB |
| 3 | PuLID Flux II | Dual characters, no pollution | 24-40GB |

## Video Generation

| Rank | Model | Best For | VRAM | Notes |
|------|-------|----------|------|-------|
| 1 | LTX-2 | 4K audio+video, production | 16GB+ | NVFP8 optimized; NVFP4 available |
| 2 | Wan 2.2 MoE | Film-level quality | 24GB+ | |
| 2b | **Stable Video Infinity 2.0 Pro** | Infinite-length video (Wan 2.2) | 24GB+ | **NEW**, pairs with Wan 2.2 I2V A14B |
| 3 | FramePack | Long videos, low VRAM | 6GB+ | |
| 4 | AnimateDiff V3 | Fast iteration, motion LoRAs | 8GB+ | |
| 5 | **Kling 3.0** | Commercial-quality video | Cloud/Partner | **NEW Feb 2026**, via ComfyUI Partner Nodes |

## 3D Generation (NEW)

| Rank | Model | Best For | VRAM |
|------|-------|----------|------|
| 1 | **Hunyuan 3D 3.0** | Text/image/sketch → 3D assets | 16GB+ | **NEW Feb 2026** via Partner Nodes |

## Voice / TTS

| Rank | Tool | Best For | License |
|------|------|----------|---------|
| 1 | TTS Audio Suite | Unified platform, 23 languages | Multi |
| 2 | Chatterbox | Emotion tags, MIT license | MIT |
| 3 | F5-TTS | Zero-shot cloning, fast | MIT |

## Lip-Sync

| Rank | Tool | Best For |
|------|------|----------|
| 1 | LatentSync 1.6 | Highest accuracy |
| 2 | Wav2Lip | Proven, works with any face |
| 3 | SadTalker | Head movement + expressions |
