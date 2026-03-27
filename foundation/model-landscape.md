# Model Landscape (Top 3 per Category)

Quick reference for model selection. Full specs in `references/models.md`.

<!-- Updated: 2026-03-27 | Source: GitHub Releases, ComfyUI Changelog, HuggingFace, ComfyUI Blog -->

> **ComfyUI Version**: v0.18.2 (March 25, 2026). v0.18.0 adds **mxfp8 support**, `--fp16-intermediates` flag (meaningful VRAM reduction for LTX + Wan VAE workflows), and VAE optimizations. v0.18.1 fixes fp16 canny/sampling bugs. **ComfyUI-Manager goes native March 28** — bundled into core, no longer a separate install.

> **NVFP4 Critical Note**: NVFP4 acceleration on RTX 50 Series **requires PyTorch built with CUDA 13.0 (cu130)**. Without it, NVFP4 models run up to **2x slower** than FP8. Verify with `torch.version.cuda` before using NVFP4 checkpoints.

> **Performance Update (Feb 2026)**: ComfyUI is **40% faster** on all NVIDIA GPUs via async offloading + pinned memory (enabled by default). RTX 50 Series: NVFP4 = 3x faster / 60% less VRAM; NVFP8 = 2x faster / 40% less VRAM.

## Image Generation

| Rank | Model | Best For | VRAM | Notes |
|------|-------|----------|------|-------|
| 1 | **FLUX.2 [dev]** | Photorealism, 4MP, multi-reference | 24GB+ | 32B params, NVFP4/NVFP8; up to 10 ref images |
| 2 | FLUX.2 [klein] | Fast generation, low VRAM | 12GB+ (4B) / 20GB+ (9B) | Sub-second on enterprise; distilled = 4 steps |
| 3 | FLUX Kontext | Iterative character editing | 12-32GB | NVFP4 available |
| 4 | **Qwen-Image 2.0** | Typography, 2K, layered editing | 24GB+ (bf16/fp8) | 20B MMDiT, Apache 2.0, ControlNet support |
| 5 | Z-Image (Base + Turbo) | Non-distilled quality / fast | 12-16GB+ | Turbo = 8 steps; Base = 30-50 steps, richer detail |
| 6 | FLUX.1-dev | Proven photorealism | 16GB+ | NVFP4/NVFP8 available |
| 7 | RealVisXL V5.0 | Fast SDXL photorealism | 8GB+ | |

## Identity Preservation

| Rank | Method | Best For | VRAM | Notes |
|------|--------|----------|------|-------|
| 1 | InfiniteYou | Highest identity fidelity | 24GB | ByteDance, ICCV 2025 Highlight; official ComfyUI node |
| 2 | FLUX Kontext | Edit without retraining | 12-32GB | Multi-round editing chains |
| 3 | **PuLID Flux 2** | FLUX.2 family (Klein + Dev) | 24-40GB | **NEW Mar 2026**, auto model detection, WaveSpeed compat |
| 4 | PuLID Flux II | FLUX.1 dual characters | 24-40GB | No model pollution |
| 5 | InstantID | SDXL face swap (legacy) | 12GB | Maintenance mode since Apr 2025 |

## Video Generation

| Rank | Model | Best For | VRAM | Notes |
|------|-------|----------|------|-------|
| 1 | **LTX-2.3** | 4K audio+video, portrait, production | 24GB+ | **NEW Mar 2026**, Day-0 support, GGUF available |
| 2 | **Wan 2.6** | Reference-to-video, lip-sync, audio | 24GB+ | **NEW Jan 2026**, 1080p, native audio gen |
| 3 | Wan 2.2 MoE | Film-level quality, first+last frame, S2V | 24GB+ | A14B model; native Sound-to-Video (S2V) node in ComfyUI |
| 3b | Stable Video Infinity 2.0 Pro | Infinite-length video (Wan 2.2) | 24GB+ | Pairs with Wan 2.2 I2V A14B |
| 4 | **HunyuanVideo 1.5** | Lightweight flagship quality | 24GB | 8.3B params (down from 13B) |
| 5 | FramePack | Long videos (60s+), low VRAM | 6GB+ | SageAttn = 30% faster; VRAM-invariant to length |
| 6 | **SkyReels V1** | Human-centric, cinematic, facial | 24GB+ | **NEW Jan 2026**, 33 expressions, HunyuanVideo-based |
| 7 | AnimateDiff V3 | Fast iteration, motion LoRAs | 8GB+ | |
| 8 | Kling 3.0 | Commercial-quality video | Cloud/Partner | Via ComfyUI Partner Nodes |

## 3D Generation

| Rank | Model | Best For | VRAM | Notes |
|------|-------|----------|------|-------|
| 1 | Hunyuan 3D 3.0 | Text/image/sketch to 3D | 16GB+ | Partner Nodes; PBR materials |
| 2 | **Hunyuan3D-2.1** | Open-source 3D with PBR | 16GB+ | Fully open-sourced with training code |
| 3 | **Rodin3D Gen-2** | Image-to-3D | Cloud/Partner | **NEW Mar 2026**, via Partner Nodes |

## Voice / TTS

| Rank | Tool | Best For | License | Notes |
|------|------|----------|---------|-------|
| 1 | TTS Audio Suite | Unified 11-engine platform | Multi | ChatterBox, F5, Qwen3, IndexTTS-2, VibeVoice, RVC + more |
| 2 | **Qwen3-TTS** | 10 languages, voice design | Open | **NEW Jan 2026**, zero-shot clone, text-based voice design |
| 3 | Chatterbox Turbo | Fast emotion, MIT, production | MIT | 350M params, sub-200ms latency |
| 4 | IndexTTS-2 | 8-emotion vector control | Open | Emotion sliders + audio reference |
| 5 | F5-TTS | Zero-shot cloning, low VRAM | MIT | Works on 6GB VRAM |
| 6 | VibeVoice | Long-form (90min), multi-speaker | Microsoft | Frontier conversational model |

## Lip-Sync

| Rank | Tool | Best For |
|------|------|----------|
| 1 | LatentSync 1.6 | Highest accuracy |
| 2 | Wan 2.6 native | Reference-to-video with lip-sync |
| 3 | Wav2Lip | Proven, works with any face |
| 4 | SadTalker | Head movement + expressions |

## Performance Optimization

| Tool | Speedup | VRAM Savings | Notes |
|------|---------|-------------|-------|
| `--fp16-intermediates` (v0.18.0) | Moderate | Meaningful reduction | Flag for LTX + Wan VAE workflows; built into ComfyUI |
| Nunchaku v1.2.0 (SVDQuant) | 2-3x | 3.5x reduction | INT4 on RTX 20+ series; min 4GB for FLUX |
| WaveSpeed (FBCache) | Up to 2x | Minimal | First block cache; works with LoRA |
| TeaCache | ~30% | Minimal | No-training; best for video gen |
| NVFP4 (RTX 50 only) | 3x | 60% less | Requires PyTorch cu130 |
| NVFP8 (any NVIDIA) | 2x | 40% less | Broadly compatible |

## LoRA Training Tools

| Tool | Best For | FLUX.2 Support | Notes |
|------|----------|:-:|-------|
| Kohya ss (sd-scripts) | Gold standard, most configurable | Yes | IP noise gamma, CFG sampling for FLUX |
| Musubi Tuner | Video LoRA (Wan/HunyuanVideo/FramePack) | Yes (dev+klein) | 20-30% VRAM savings with activation offload |
| Ostris AI Toolkit | Simple FLUX training | Yes (dev+klein) | Apple MPS support incoming |
