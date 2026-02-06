# Model Landscape (Top 3 per Category)

Quick reference for model selection. Full specs in `references/models.md`.

## Image Generation

| Rank | Model | Best For | VRAM |
|------|-------|----------|------|
| 1 | FLUX.1-dev | Photorealism, highest quality | 16GB+ |
| 2 | FLUX Kontext | Iterative character editing | 12-32GB |
| 3 | RealVisXL V5.0 | Fast SDXL photorealism | 8GB+ |

## Identity Preservation

| Rank | Method | Best For | VRAM |
|------|--------|----------|------|
| 1 | InfiniteYou | Highest identity fidelity | 24GB |
| 2 | FLUX Kontext | Edit without retraining | 12-32GB |
| 3 | PuLID Flux II | Dual characters, no pollution | 24-40GB |

## Video Generation

| Rank | Model | Best For | VRAM |
|------|-------|----------|------|
| 1 | Wan 2.2 MoE | Film-level quality | 24GB+ |
| 2 | FramePack | Long videos, low VRAM | 6GB+ |
| 3 | AnimateDiff V3 | Fast iteration, motion LoRAs | 8GB+ |

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
