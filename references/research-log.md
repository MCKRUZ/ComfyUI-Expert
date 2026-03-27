# Research Log

---

## March 27, 2026 — Weekly Research Sweep

**Sources:** ComfyUI Changelog, GitHub releases, HuggingFace, ComfyUI Blog, xAI announcements, Boson AI blog, YouTube channel research (EP metadata), WebSearch (25+ queries)

### ComfyUI Version Updates (Last 7 Days)

| Version | Date | Key Changes |
|---------|------|-------------|
| v0.18.2 | March 25, 2026 | Grok Reference-to-Video (7 ref images) + Grok Video Extend nodes |
| v0.18.1 | March 23, 2026 | FP16 Canny fix, WAN VAE light/color issue fixed |
| v0.18.0 | March 21, 2026 | `--fp16-intermediates` flag, VRAM reduction for LTX+WAN VAE, Topaz API nodes, Manager v4.1b2 |
| v0.16.4 | March 7, 2026 | Math Expression node, Gemini 3.1 Flash-Lite in LLM node, FP16 audio encoder fix |

### New Models Added to Ecosystem

| Model | Category | Status | Notes |
|-------|----------|--------|-------|
| Reve Image 1.0 | Image Gen | Live — Partner Nodes | 4K, 5s gen, 3 nodes (Create/Edit/Remix) |
| Seedream 5.0 Lite | Image Gen | Live — Partner Nodes | Web-connected retrieval, Feb 2026 |
| Seedance 2.0 | Video Gen | Live — Partner Nodes | 2K, native audio, 8-lang lip-sync, Feb 2026 |
| Grok R2V + Video Extend | Video Gen | Live — Partner Nodes | xAI, v0.18.2, Day-0 |
| Wan 2.7 | Video Gen | Coming soon | Planned March 2026; first/last frame ctrl, instruction editing |
| Higgs Audio 2 | TTS | Live — TTS Audio Suite | Boson AI, 3B params, 10M hrs, 4-speaker |
| Chatterbox Multilingual | TTS | Live | 23 languages, new tier |
| F5-TTS v1.1.18 | TTS | Live — PyPI | March 24, 2026 fresh release |
| FLUX.2 Klein NVFP4 | Image Gen | Live | NVFP4 now available; LTX-2.3 NVFP4 coming soon |
| Wan 2.2 5B Fun Inpaint/Control | Video Gen | Live | First-last frame interp, 10GB VRAM min |

### Critical Compatibility Issues Found

- **ComfyUI-Impact-Pack V4.85** requires **ComfyUI-IPAdapter-plus March 24, 2026+** — update immediately if using both
- **WAN VAE color/light bug** fixed in v0.18.1 — update ComfyUI to resolve

### Kijai WanVideoWrapper New Model Support

FantasyTalking, FantasyPortrait, MultiTalk, EchoShot, HuMo, WanAnimate, ReCamMaster, Uni3C, MAGREF, ATI, Phantom, TimeToMove, SteadyDancer, SCAIL

**LoRA buffer change**: LoRAs now loaded as module buffers for async offloading — may require adjusting block swap params in existing workflows.

### YouTube Channel Activity

- **Pixaroma**: EP08 (Mar 11), EP09 (Mar 17), EP10 (Mar 24) — active, workflow files on GitHub
- **Sebastian Kamph**: Wan 2.6 R2V deep dive, Wan 2.2 5B I2V tutorial
- **Kijai**: Primarily GitHub releases; WanVideoWrapper major additions
- Transcripts not accessible via direct URL; marked for manual review

### Additional Findings (concurrent sweep)

| Model / Item | Category | Notes |
|--------------|----------|-------|
| Wan 2.2 S2V (Sound-to-Video) | Video | Native audio-driven video generation; S2V node in ComfyUI core |
| LTX-2.3 GGUF variants | Video | unsloth + Kijai GGUF variants — consumer GPU access for LTX-2.3 |
| Wan 2.2 Q4_K GGUF (14B) | Video | 8-10GB VRAM for flagship 14B model via quantization |
| ComfyUI-Manager native (Mar 28) | Infrastructure | Manager bundled into ComfyUI core — no longer a separate install |

### NVIDIA GDC 2026 Highlights (in ComfyUI context)

- RTX Video Super Resolution node available in ComfyUI (real-time 4K upscaler)
- NVFP4 for FLUX.2 Klein available now; NVFP4 for LTX-2.3 coming soon (up to 2.5x perf, 60% less VRAM)

---

# ComfyUI Character Generation: 2024-2025 Comprehensive Techniques Guide

The ComfyUI ecosystem has undergone a dramatic transformation since 2024, with **InfiniteYou**, **FLUX Kontext**, and **PuLID Flux II** emerging as the new gold standards for character consistency—while many foundational repositories from cubiq (InstantID, PuLID, IP-Adapter) entered maintenance mode in April 2025. Video generation has been revolutionized by **Wan 2.2's MoE architecture** and **FramePack's 6GB VRAM breakthrough** for 60-second videos. Voice cloning integration reached maturity with unified platforms like TTS Audio Suite supporting 23+ languages and emotion control. This report synthesizes the latest techniques, workflows, and community discoveries to update character generation capabilities.

---

## Pixaroma's ComfyUI mastery: Accessibility-first workflows

**Pixaroma** has established itself as the definitive beginner-to-advanced ComfyUI resource, run by a graphic designer who emphasizes GGUF quantized models for users with **8-12GB VRAM**. The channel's structured episode format builds systematically from installation basics through advanced video generation.

The character consistency methodology from **Episode 28** follows a multi-step pipeline: generate character sheets showing multiple angles and poses, train LoRAs online using these generated images, then deploy locally with OpenPose and ControlNet for pose control. This approach prioritizes accessibility over cutting-edge methods, making it ideal for creators with consumer hardware.

Key innovations include the **Pixaroma Upscaler workflow** using Flux Dev GGUF Q8, which employs dual outputs—one from KSampler at **0.75-0.80 denoise** (preserving character features) and one further upscaled without KSampler. The **260+ art styles collection** in CSV format provides curated SDXL-compatible styles organized by category, with the recommendation to mix painting and photography styles for optimal results.

For video generation, Pixaroma's Wan 2.1 tutorials provide precise specifications: **832×480px for landscape**, **480×832px for portrait**, with frame calculations at 16 FPS (17 frames = 1 second, 81 frames = 5 seconds). The **ComfyUI-Easy-Install Pixaroma Community Edition** bundles essential nodes including GGUF support, VideoHelperSuite, WanVideoWrapper, and Impact Pack for one-click setup.

| Resource | Link |
|----------|------|
| YouTube Channel | youtube.com/@pixaroma |
| Easy Install GitHub | github.com/Tavris1/ComfyUI-Easy-Install |
| Discord (Free Workflows) | Pixaroma workflows channel |

---

## Character consistency enters a new era with InfiniteYou and FLUX Kontext

The character consistency landscape fundamentally shifted in 2024-2025. **InfiniteYou** from ByteDance (ICCV 2025 Highlight) introduces **InfuseNet** architecture with residual connections and multi-stage training using single-person-multiple-sample data. Two model variants serve different needs: **SIM** maximizes identity matching while **AES** prioritizes visual quality. FP8 and GGUF support enable lower VRAM requirements with multi-ID masked generation.

**FLUX.1 Kontext** from Black Forest Labs represents perhaps the most significant advancement—a context-aware editing model with **built-in character consistency** that maintains features across multiple editing steps. The model excels at localized editing (targeting specific elements without affecting others) and iterative refinement with minimal drift. Three tiers exist: Kontext [dev] at 12B parameters for research, Kontext [pro] running 8x faster than GPT-Image, and Kontext [max] with improved prompt adherence. FP8 versions reduce requirements to ~12GB VRAM.

**PuLID Flux II** solved the critical "model pollution" issue using contrastive alignment techniques that minimize disruption to the original FLUX model. The dual-character support enables generating scenes with two consistent people—previously extremely difficult. Mickmumpitz's "Flux Consistent Characters" workflow remains the community gold standard, though it requires A100-40GB GPU at approximately 7.5 minutes per generation.

For SDXL workflows, the proven combination of **InstantID + IP-Adapter + ControlNet + FaceDetailer** continues to deliver excellent results, though these cubiq repositories are now in maintenance mode. Key optimizations include using **1016×1016 resolution** (avoiding 1024×1024 watermark artifacts), lowering CFG to 4-5, and applying 35% noise injection in negative embeds to reduce the "burn" effect.

| Use Case | Best Approach | VRAM Requirement |
|----------|---------------|------------------|
| Quick face swap | InstantID + FaceDetailer | 12GB |
| Story/comic generation | StoryDiffusion | 16GB |
| High-fidelity portraits | InfiniteYou | 24GB |
| Image editing/iteration | FLUX Kontext | 12-32GB |
| Multiple characters | PuLID Flux II | 24-40GB |
| Production workflows | FLUX Kontext Pro (API) | Cloud |

---

## Video generation transforms with Wan 2.2 and FramePack

**Wan 2.2** from Alibaba introduces a Mixture of Experts architecture where high-noise and low-noise expert models collaborate, enabling **film-level aesthetic control** over lighting, color, and composition. The groundbreaking first-and-last frame generation controls both start and end frames for precise video planning. Models range from the consumer-friendly 1.3B version requiring ~8.19GB VRAM to the 14B version for maximum quality.

The **FramePack** breakthrough from Dr. Lvmin Zhang (ControlNet author) makes VRAM usage **invariant to video length**—generating 60-second videos at 30fps (1800 frames) on just 6GB VRAM via an RTX 3060. Dynamic context compression assigns 1536 markers to key frames versus 192 for transitional frames, while bidirectional memory with reverse generation prevents the drift that plagued earlier methods.

**AnimateDiff V3** with motion modules (mm_sd_v15_v2) supports camera controls through Motion LoRAs—pan, zoom, tilt, rolling—while effect LoRAs enable shatter, smoke, explosion, and liquid motion effects. The sliding context window system enables infinite animation length, though the model works best at **512x512 resolution** (its training resolution). For SDXL, HotshotXL provides temporal layer support.

Lip-sync technology matured significantly with **LatentSync 1.6** from ByteDance training at 512×512 for improved clarity, using TREPA modules for temporal consistency. **InfiniteTalk** enables unlimited-length talking avatar videos with WAN integration, while the emerging **Character AI Ovi** pipeline generates joint video and audio with natural lip synchronization from a single image input.

---

## Voice cloning reaches production quality with unified platforms

**TTS Audio Suite** emerged as the definitive multi-engine platform, integrating F5-TTS, Chatterbox (23 languages), Higgs Audio 2, VibeVoice (90-minute generation), IndexTTS-2 (8-emotion vector control), and RVC for real-time conversion. Advanced features include character switching with `[CharacterName]` tags, language switching (`[de:Alice]`, `[fr:Bob]`), pause control (`[pause:1s]`), and SRT subtitle timing synchronization.

**F5-TTS** delivers zero-shot voice cloning from samples under 15 seconds with multi-language support across English, German, Spanish, French, Japanese, Hindi, Thai, and Portuguese. Voice samples must be paired with `.wav` and `.txt` files containing matching transcriptions. The model integrates Whisper for automatic transcription.

**Chatterbox** from ResembleAI supports paralinguistic tags (`[laugh]`, `[sigh]`, `[gasp]`) and multi-speaker dialog synthesis for up to 4 voices per generation. The `exaggeration` parameter (0.25-2.0) controls expressiveness, while a **40-second generation limit** requires splitting longer content.

For emotion control, **IndexTTS-2** provides an 8-emotion vector system covering happy, angry, sad, surprised, afraid, disgusted, calm, and melancholic states with per-segment parameter control.

---

## LoRA training evolves with FLUX-specific optimizations

FLUX LoRA training differs substantially from SDXL approaches. **FluxGym** provides the most beginner-friendly path with web-based Gradio interface, integrated Florence 2 auto-captioning, and RunPod templates. Recommended settings: **15-20 high-quality images**, unique trigger tokens (e.g., `ch3rrybl0nde`), network rank 16-32, and 2000 steps.

**SimpleTuner** targets production environments with support for FLUX.1 Dev and FLUX.2 with Mistral-3 encoder. The int8/nf4 quantization enables training on 20GB VRAM via Optimum-Quanto. Key parameters: learning rate 1e-4 to 1e-5 (lower than SD), network rank 4-64 (start small), polynomial LR schedule.

For SDXL, **Kohya_ss** remains the gold standard with Prodigy optimizer for auto-tuning, block-wise dims/lrs support, and recommended rank of 64-96 with alpha at half the rank value. Dataset preparation requires high-resolution images (1024×1024 minimum), multiple angles and expressions (10-20 images), and captions with trigger words first followed by detailed descriptions—but excluding unchangeable features like eye color.

| Training Type | Network Dim | Network Alpha | Images | Steps |
|---------------|-------------|---------------|--------|-------|
| Logo/Objects | 10-15 | 10 | 10 | 2000 |
| Characters | 16-32 | 20 | 10-20 | 2000 |
| Styles | 32-50 | 20 | 20-30 | 3000 |

---

## Memory optimization unlocks consumer hardware potential

VRAM management fundamentally determines workflow feasibility. Command-line flags provide the first optimization layer: `--lowvram` for 6GB systems trades speed for memory efficiency, `--reserve-vram [amount]` prevents system freezing by reserving VRAM for OS functions, and `--use-xformers` changes attention scaling from quadratic to near-linear—**reducing 16GB requirements to 4GB** for 1024×1024 generation.

**FP8 precision** for SDXL/Flux models halves memory usage with minimal quality loss—FLUX checkpoints use ~6GB VRAM versus much more for FP16/BF16. The **VRAM_Debug node** from KJNodes monitors free VRAM before/after operations with built-in garbage collection and model unloading. Restarting ComfyUI between significantly different workloads clears memory fragmentation.

Sampling optimization delivers dramatic speed improvements: **15-25 steps** suffices for most generations since quality plateaus around 25-30 steps. DPM++ 2M Karras achieves excellent results at 20 steps, while **DEIS sampler achieves high-fidelity in just 10 steps**. Lightning/Turbo models enable 4-8 step generation; LCM achieves 4 steps for rapid iteration.

A critical community discovery: updating **cuDNN to version 8800** can double speed on RTX 4070Ti from 8.5it/s to 17.6it/s. Reserving 7GB VRAM in ComfyUI settings made workflows run **20x faster** on 5070ti in community testing.

---

## Essential custom nodes for character generation pipelines

**ComfyUI Manager** remains the foundational requirement—enabling one-click installation, auto-updates, and missing node detection. **Impact Pack** provides FaceDetailer for automatic face enhancement and image segmentation. **WAS Node Suite** delivers 300+ nodes for image processing, text manipulation, and file operations.

For upscaling, **SUPIR** (Scaling-UP Image Restoration) uses diffusion-based enhancement achieving photo-realistic results—512p to 2048 with under 10GB VRAM in FP8 mode. Key parameters: CFG scale 2.5→1.5, EDM s_churn ~5. The **4x Foolhardy Remacri** model provides superior texture reconstruction, while **4x AnimeSharp** optimizes for illustration styles.

New samplers and schedulers emerged for specific use cases. The **Beta scheduler** (α=1.0, β=0.6) delivers improved details for Flux.1 [dev] with Euler sampler. **ComfyUI-CapitanFlowMatch** provides optimal samplers for rectified flow models (Flux, SD3, Lumina2), preventing the "burning" issues with turbo models at higher step counts.

For ControlNet, **FLUX ControlNet Inpainting** from Alimama (beta model trained on 15M images at 1024×1024) outperforms SDXL inpainting with conditioning scale between 0.9-0.95 for best results.

---

## Community workflows and cutting-edge discoveries

**Consistent Character Creator 3.0** using the Qwen Image Edit model generates multi-view character sheets (front, side, back views, expressions, turntable rotations) while preserving identity. The **Character AI Ovi** pipeline enables single-image-to-talking-avatar with joint video and audio generation and natural lip synchronization.

**StoryDiffusion** (NeurIPS 2024 Spotlight) provides training-free consistent text-to-image generation through Consistent Self-Attention, requiring minimum 3 text prompts (5-6 recommended) for character consistency across sequences. It works as a hot-pluggable module compatible with both SD1.5 and SDXL.

**ComfyUI Copilot** from Alibaba offers AI-assisted workflow generation with claimed 10x faster workflow creation. **ACE Plus technology** achieves 99% facial consistency for background replacement (versus previous 90%). **HyperLoRA** (CVPR 2025) introduces parameter-efficient adaptive generation for portrait synthesis.

For workflow discovery, **OpenArt** provides curated workflows with previews, **Civitai** offers model-specific workflows, and **awesome-comfyui** on GitHub maintains a daily-updated collection. The **Searge SDXL Evolved v4.32** workflow on Civitai represents one of the most optimized community workflows with ControlNet, Revision, and multi-LoRA support.

---

## Conclusion: Building the complete character pipeline

The 2024-2025 ComfyUI ecosystem enables truly professional character generation workflows. For **new projects**, InfiniteYou or FLUX Kontext represent the state-of-the-art, while SDXL workflows should continue leveraging InstantID + IP-Adapter combinations despite maintenance mode status. **Production environments** benefit from FLUX Kontext Pro/Max via API for maximum consistency.

The optimal multi-modal pipeline follows this sequence: generate consistent characters with LoRA-enhanced FLUX/SDXL models → clone voices with F5-TTS or Chatterbox using 10-30 second references → create video with Wan 2.2 or FramePack → apply lip-sync with LatentSync 1.6 or InfiniteTalk → post-process with RIFE interpolation and SUPIR upscaling.

Key architectural insights: FramePack's VRAM-invariant approach enables 60-second videos on consumer GPUs; TTS Audio Suite's unified platform eliminates fragmented voice cloning setups; PuLID Flux II's contrastive alignment solves model pollution for dual-character generation. The field continues rapid evolution—monitor the community forks emerging from maintenance-mode repositories and emerging models like CharaConsist's point-tracking attention for next-generation consistency.

---

## 2026 Updates — February Research Run

<!-- Updated: 2026-02-18 | Source: NVIDIA Blog (CES 2026), ComfyUI Changelog, ComfyUI Wiki News, HuggingFace, GitHub -->

### NVFP4 Performance — Critical Configuration Requirement

ComfyUI officially supports NVFP4 quantized models for RTX 50 Series (Blackwell) acceleration. **Critical**: NVFP4 only provides speedup if you run PyTorch built with CUDA 13.0 (`cu130`). Without it, NVFP4 sampling is up to **2x slower** than FP8.

- NVFP4: 3x faster performance, 60% VRAM reduction vs BF16 on RTX 50 Series
- NVFP8: 2x faster, 40% VRAM reduction (works on any NVIDIA GPU)
- **Overall ComfyUI speedup**: +40% on all NVIDIA GPUs via async offloading + pinned memory (enabled by default as of v0.8.1+)
- NVFP4/NVFP8 checkpoints now available for: LTX-2, FLUX.1, FLUX.2, Z-Image, Qwen-Image (Alibaba)

**Verify CUDA version**: `python -c "import torch; print(torch.version.cuda)"`
Must show `13.0` for NVFP4 acceleration. If not, use NVFP8 or FP8 instead.

### New Image Models (Feb 2026)

**Z-Image** received Day-0 ComfyUI support (Feb 2, 2026). Non-distilled, flexible, high-quality image generation from Alibaba. NVFP4/NVFP8 checkpoints available directly in ComfyUI.

**USO (Unified Style and Object)** from ByteDance's USO Team — built on FLUX.1-dev architecture. Addresses the fundamental tension between style-driven and subject-driven generation by treating them as a unified task. Key innovation: decoupling and recombining content and style so a single generation can preserve a subject's identity AND apply a specific style simultaneously.

### Video — Stable Video Infinity 2.0 Pro + Wan 2.2

**Stable Video Infinity (SVI) 2.0 Pro** paired with Wan 2.2 I2V A14B is the current gold standard for infinite-length video generation. Improvements over v1:
- Fixes video glitches, weird artifacts, and color degradation from v1
- HIGH and LOW LoRA variants (HIGH = better quality, LOW = faster/less VRAM)
- Works with Wan 2.2 I2V base; temporal continuity far beyond single clips
- Community workflows available on Civitai (1080p 60FPS) and via kijai/ComfyUI-WanVideoWrapper

**LTX-2** production status confirmed: generates up to 20 seconds of 4K video with built-in audio, multi-keyframe support, and NVFP8 optimization. First open-source model matching commercial cloud video generation quality.

### New 3D and Video Partner Nodes (Feb 16, 2026)

**Hunyuan 3D 3.0** now available via ComfyUI Partner Nodes. Tencent's state-of-the-art 3D model generates production-ready 3D assets from text, images, or sketches in minutes. Supports PBR material generation.

**Kling 3.0** now available via ComfyUI Partner Nodes. Commercial-quality video generation direct from ComfyUI interface. Significant upgrade from earlier Kling versions.

### Identity Preservation — New Methods

**PuLID Flux Chroma** (fork: `PaoloC68/ComfyUI-PuLID-Flux-Chroma`): Extends PuLID face identity preservation to FLUX and the newer **Chroma** model family. Relevant if Chroma adoption increases.

**USO** (see above) provides a clean path for character + style consistency without fighting the model's aesthetics — potentially complementary to InfiniteYou for stylized outputs.

**FLUX Kontext** continues to be the community gold standard for consistent character editing from a single reference image. Community workflows at runcomfy.com and mimicpc.com demonstrate "consistent characters" pipelines using Kontext.

### AMD ROCm Support

ComfyUI now has **native AMD ROCm integration** with reported 5.4x faster image generation for AMD GPU users. AMD RDNA 4 (RX 9070 XT) users can now run ComfyUI workflows competitively.

### Community Workflow Resources (Updated)

- [ComfyUI Changelog](https://docs.comfy.org/changelog) — official releases page, check for breaking changes
- [ComfyUI Wiki News](https://comfyui-wiki.com/en/news) — aggregated news with dates
- [RunComfy Workflows](https://www.runcomfy.com) — curated community workflows with previews
- [NVIDIA RTX AI Blog](https://blogs.nvidia.com/blog/rtx-ai-garage-ces-2026-open-models-video-generation/) — hardware optimization announcements

---

## 2026 Updates — March Research Run

<!-- Updated: 2026-03-18 | Source: ComfyUI Changelog, GitHub Releases, HuggingFace, ComfyUI Blog, NVIDIA Blog, Community -->

### ComfyUI Core Updates (v0.16.4 - v0.17.2)

**ComfyUI v0.17.2** (March 15, 2026) is the latest stable release, following v0.17.0 (March 13) and v0.16.4 (March 7). Major changes since Feb 2026:

**Architecture & Performance (v0.17.0)**:
- Modular asset architecture with asynchronous two-phase scanner and background seeder for improved loading performance
- Python fault handler for better debugging and stability
- Enhanced memory usage optimization for KV cache models
- FLUX.2 Klein KV cache support via new FluxKVCache node
- Improved dynamic VRAM handling with better AcceleratorError compatibility

**New Model Support (v0.16-v0.17)**:
- Wav2vec2 Audio Encoder for audio-to-embedding workflows
- Qwen DiffSynth ControlNets (Canny, Depth conditioning)
- InstantX Qwen ControlNet integration
- AudioEncoderOutput V3 support
- Reve Image API nodes

**New Nodes & Features (v0.16.4)**:
- Math Expression node with simpleeval evaluation
- TencentSmartTopology API node
- Topaz video enhancement workflow support
- Nano Banana Pro API node
- Rodin3D Gen-2 (image-to-3D, via Partner Nodes)
- WAN 2.5 Image-to-Image API node for image editing

**App Mode, App Builder & ComfyHub** (March 10, 2026) — the biggest ecosystem shift:
- App Mode transforms any workflow into a clean UI with one click — node graph disappears, replaced by just the inputs/outputs
- App Builder lets workflow authors configure which inputs/outputs are exposed
- ComfyHub is a publishing platform for finished apps and workflows (like npm registry, but for ComfyUI apps)
- Shareable URLs for apps — no ComfyUI knowledge needed to use them
- Available on both Comfy Cloud and Comfy Local
- Source: [ComfyUI Blog](https://blog.comfy.org/p/from-workflow-to-app-introducing), [GlobeNewsWire](https://www.globenewswire.com/news-release/2026/03/10/3253141/0/en/)

**Nodes 2.0 (Vue Migration)** — now in stable/desktop/portable releases:
- Frontend migrated from LiteGraph.js Canvas to Vue-based architecture
- Enables faster feature development and richer node interactions
- Full backward compatibility maintained — all existing workflows load without modification
- Optional — can switch back in settings if needed
- Source: [ComfyUI Blog](https://blog.comfy.org/p/comfyui-node-2-0)

### Video Generation — Major New Models

**WAN 2.6 Reference-to-Video** (January 2026):
- Generates cinematic video by learning motion, camera, and visual style from reference clips
- Supports up to 2 reference clips, 720p and 1080p output (portrait or landscape)
- Native audio generation for voiceovers, background music, and SFX aligned with visuals
- Precise lip-sync and audio-visual synchronization (major upgrade over 2.5)
- Prompt-based control over actions and scenes
- Available in ComfyUI: Workflow Library -> Video -> WAN 2.6 Reference to Video
- Source: [ComfyUI Blog](https://blog.comfy.org/p/wan26-reference-to-video)

**WAN 2.5** — API nodes added to ComfyUI:
- Audio conditioning (use audio as input with prompts or keyframes)
- 4K resolution support, longer/smoother clips
- Advanced cinematic camera and lighting controls
- Image-to-Image editing via API node
- Source: [ComfyUI Blog](https://blog.comfy.org/p/wan-25-preview-api-nodes-in-comfyui)

**LTX-2.3** (March 5, 2026) — Day-0 ComfyUI v0.16 support:
- Major quality improvements: finer details (new latent space + updated VAE), 9:16 portrait support, cleaner audio, improved I2V
- Ships with updated ComfyUI custom nodes and reference workflows
- Model weights: ~44GB full, ~22GB fp16, plus distilled variant for faster inference
- GGUF versions available for lower VRAM
- VRAM: 24GB+ recommended; RTX 4090 FP16 at 1080p/50fps: ~7-8 minutes for 10s clip
- Source: [ComfyUI Blog](https://blog.comfy.org/p/ltx-23-day-0-supporte-in-comfyui), [Lightricks](https://ltx.io/model/ltx-2-3)

**HunyuanVideo 1.5** — native ComfyUI support:
- Lightweight 8.3B parameter model (down from 13B) delivering flagship quality on 24GB consumer GPUs
- Strong instruction following for camera movements, physics, emotional expressions
- Native 720p output, upscalable to 1080p
- Also supported via kijai's ComfyUI-HunyuanVideoWrapper
- Source: [ComfyUI Blog](https://blog.comfy.org/p/hunyuanvideo-15-native-support)

**SkyReels V1** (January 29, 2026):
- First open-source human-centric video foundation model from Skywork AI
- Fine-tuned from HunyuanVideo on millions of film/TV clips
- 33 distinct facial expressions with 400+ natural movement combinations
- 544x960 at 24fps, up to 12 seconds (288 frames)
- ComfyUI integration via kijai's HunyuanVideo wrapper (converts to HunyuanVideo format)
- Source: [GitHub](https://github.com/SkyworkAI/SkyReels-V1)

**FramePack** — continued evolution:
- Updated to ComfyUI v0.3.39 for stability and compatibility
- SageAttn integration for 30% faster generation
- 1.5-2.5 seconds per frame on RTX 4090
- Minimum 6GB VRAM, supports RTX 30XX/40XX/50XX
- Still the best option for long videos (60+ seconds) on consumer hardware
- Source: [RunComfy](https://www.runcomfy.com/comfyui-workflows/framepack-wrapper-for-comfyui-long-video-generation-with-low-memory)

### Image Generation — New Models & Updates

**FLUX.2 [dev]** — 32B parameter model, now the FLUX flagship:
- Up to 4MP photorealistic output with improved lighting, skin, fabric, hands
- Multi-reference consistency (up to 10 images), improved editing precision
- Direct pose control for explicit subject positioning
- Professional text rendering (infographics, UI screens, multilingual)
- NVIDIA-optimized: FP8 quantization = 40% less VRAM + 40% faster at launch
- VRAM: 24GB+ (FP8 version works on RTX 3090/4090/5090)
- Source: [NVIDIA Blog](https://blogs.nvidia.com/blog/rtx-ai-garage-flux-2-comfyui/), [BFL](https://bfl.ai/blog/flux-2)

**FLUX.2 [klein]** — fast small models:
- 4B and 9B parameter variants for speed and low compute
- 4B distilled: ~1.2s on RTX 5090, 8.4GB VRAM; 4B base: ~17s, 9.2GB VRAM
- Sub-second generation possible on enterprise hardware
- Open-weight 4B model available for commercial use
- VRAM: 4B = 12GB+, 9B = 20GB+
- Source: [VentureBeat](https://venturebeat.com/technology/black-forest-labs-launches-open-source-flux-2-klein-to-generate-ai-images-in/)

**Z-Image-Base** (January 28, 2026):
- Non-distilled raw checkpoint of the Z-Image series from Alibaba Tongyi Lab
- Requires 30-50 sampling steps (CFG 3-5) but produces significantly richer visual details
- Higher artistic ceiling compared to Z-Image-Turbo
- VRAM: 12GB+ (Turbo), 16GB+ recommended (Base for quality)
- Source: [ComfyUI Wiki](https://comfyui-wiki.com/en/news/2026-01-28-alibaba-z-image-base-release)

**Qwen-Image 2.0** — major update from Alibaba:
- 20B MMDiT model, Apache 2.0 license
- Professional typography rendering: 1k-token instructions for PPTs, posters, comics
- Native 2K resolution support
- Layered editing variant (Qwen-Image-Layered): decompose images into RGBA layers
- ControlNet support: DiffSynth (canny/depth/inpaint) + Union ControlNet (lineart/softedge/normal/openpose)
- Qwen 2.5 Fun ControlNet format merged Feb 14, 2026
- bf16 and fp8 versions available in ComfyUI
- Source: [ComfyUI Docs](https://docs.comfy.org/tutorials/image/qwen/qwen-image)

**FLUX Kontext [dev]** — continued community adoption:
- Context-aware editing with built-in character consistency
- Group nodes and quick Edit button added for iterative editing
- Fix for Load Image(from output) node enabling multi-round editing chains
- Still API-only for Pro/Max tiers
- Source: [ComfyUI Docs](https://docs.comfy.org/tutorials/flux/flux-1-kontext-dev)

### Identity Preservation — Updates

**PuLID Flux 2** (March 2026):
- First PuLID implementation for FLUX.2 family (Klein 4B/9B + Dev 32B)
- Auto model detection between Klein and Dev variants
- Best results: PuLID at low weight (0.2-0.3) combined with Klein's native Reference Conditioning
- Compatible with TeaCache and WaveSpeed for faster processing
- Source: [GitHub](https://github.com/iFayens/ComfyUI-PuLID-Flux2)

**InfiniteYou** — status update:
- Official ComfyUI native node from ByteDance (ICCV 2025 Highlight)
- Still the SOTA for zero-shot identity preservation on FLUX
- Two variants: sim_stage1 (identity priority), aes_stage2 (aesthetics priority)
- Multi-character support, face pose control, face swap, face combine features
- VRAM: 24GB
- Source: [GitHub](https://github.com/bytedance/ComfyUI_InfiniteYou)

**InstantID** — maintenance mode:
- ComfyUI_InstantID by cubiq is in "maintenance only" mode as of April 2025
- Last updated September 2024; SDXL only
- Still functional but no longer recommended for new projects
- Replaced by InfiniteYou and FLUX Kontext for most use cases
- Source: [GitHub](https://github.com/cubiq/ComfyUI_InstantID)

**IP-Adapter FLUX** — stable but not actively developed:
- Shakker-Labs implementation last updated February 2025
- Uses google/siglip-so400m-patch14-384 as image encoder
- 128 image tokens, trained on 10M images
- Supports multiple IP-adapters simultaneously
- Source: [GitHub](https://github.com/Shakker-Labs/ComfyUI-IPAdapter-Flux)

### Voice / TTS — Rapid Expansion

**TTS Audio Suite** — now supports 11 engines:
- Engines: ChatterBox (classic + 23-lang), F5-TTS, Higgs Audio 2, VibeVoice (90min), IndexTTS-2, CosyVoice3, Qwen3-TTS, Echo-TTS, Step Audio EditX, RVC
- Unified interface with character switching, language switching, SRT timing
- Actively maintained by diodiogod
- Source: [GitHub](https://github.com/diodiogod/TTS-Audio-Suite)

**Qwen3-TTS** (January 2026) — significant new entrant:
- From Alibaba Cloud's Qwen team
- 10 languages: Chinese, English, Japanese, Korean, German, French, Russian, Portuguese, Spanish, Italian
- Zero-shot voice cloning from short reference audio
- Voice design from text descriptions ("calm", "energetic", "young")
- Ultra-low latency streaming
- Multiple ComfyUI integrations: ComfyUI-Qwen-TTS, ComfyUI-Qwen3-TTS, ComfyUI-FL-Qwen3TTS, 1038lab/ComfyUI-QwenTTS
- Also integrated into TTS Audio Suite
- Source: [Qwen Blog](https://qwen.ai/blog?id=qwen3tts-0115)

**IndexTTS-2** — emotion control matured:
- 8-slider emotion vectors (0.0-1.4 range, sum <= 1.5)
- Text-based emotion detection via QwenEmotion model
- Audio reference for emotional tone transfer
- Advanced controls: sampling, speech speed, pauses, CFG, seed
- ComfyUI node: ComfyUI-IndexTTS2 + integrated in TTS Audio Suite
- Source: [GitHub](https://github.com/snicolast/ComfyUI-IndexTTS2)

**Chatterbox Turbo** — latest from Resemble AI:
- 350M parameter architecture, sub-200ms inference latency
- Native paralinguistic tags: [cough], [laugh], [chuckle]
- 63.75% preferred over ElevenLabs in evaluator testing
- MIT license
- 2026 roadmap: multi-speaker conversation generation, prosody transfer
- Source: [Resemble AI](https://www.resemble.ai/chatterbox/)

**VibeVoice** — Microsoft's frontier model:
- Expressive, long-form, multi-speaker conversational audio
- Up to 90 minutes continuous generation per session
- Standalone node: ComfyUI-VibeVoice + integrated in TTS Audio Suite
- Source: [GitHub](https://github.com/wildminder/ComfyUI-VibeVoice)

### LoRA Training — Tool Updates

**Musubi Tuner** — expanded model support:
- Now supports: HunyuanVideo, Wan 2.1/2.2, FramePack, FLUX.1 Kontext, FLUX.2 dev/klein, Qwen-Image, Z-Image
- Activation CPU offloading during gradient checkpointing: 20-30% VRAM reduction
- Improved .safetensors loading with np.memmap: 1.5x faster model initialization
- FP8 scaled quantization changed to block-wise scaling for improved accuracy (saves ~5GB for Qwen-Image)
- Z-Image base model support added January 2026
- Source: [GitHub](https://github.com/kohya-ss/musubi-tuner)

**Ostris AI Toolkit** — FLUX.2 support:
- Now supports FLUX.2 [dev] (32B), FLUX.2 Klein (4B/9B), Wan, Qwen-Image, Z-Image, OmniGen2
- Fix for FLUX.2 Klein load-time VRAM spikes on low-memory GPUs (Feb 25, 2026)
- Apple silicon MPS support proposed (Feb 21, 2026)
- Source: [GitHub](https://github.com/ostris/ai-toolkit)

**Kohya ss (sd-scripts)** — continued gold standard:
- Added IP noise gamma for FLUX, CFG for sampling in FLUX.1 training
- Support for HunyuanImage-2.1
- PyTorch 2.6.0 + torchvision 0.21.0 for CUDA 12.4
- Prodigy optimizer for auto-tuning still recommended
- Source: [GitHub](https://github.com/kohya-ss/sd-scripts)

**FLUX.2 LoRA Training Best Practices (2026)**:
- 20-1,000 images recommended for FLUX.2
- Training time: ~90 min on 16GB+ VRAM, ~45-60 min on 24GB+ VRAM
- GGUF quantization enables training on consumer hardware
- CogVLM for auto-captioning, WD-Tagger for anime
- Much lower learning rates than SDXL due to flow matching architecture
- Higher ranks work better (start higher than SDXL recommendations)
- Source: [Medium](https://kgabeci.medium.com/flux-2-lora-training-the-complete-2026-guide-from-someone-who-built-the-training-platform-14d0bcb396eb)

### Performance Optimization — New Tools

**Nunchaku v1.2.0** (January 12, 2026):
- SVDQuant 4-bit quantization: 3.6x model size reduction, 3.5x VRAM reduction
- 20-30% Z-Image performance boost
- Seamless LoRA support with native ComfyUI nodes
- INT4 support for RTX 20-series GPUs
- Minimum 4GB VRAM for FLUX with per-layer CPU offloading
- 2-3x speedup maintained
- Source: [GitHub](https://github.com/nunchaku-ai/nunchaku)

**WaveSpeed — First Block Cache (FBCache)**:
- Uses first transformer block residual output as cache indicator
- Skips computation of all following blocks when difference is small
- Up to 2x speedup while maintaining accuracy
- Enhanced torch.compile works with LoRA (unlike native TorchCompileModel)
- Source: [GitHub](https://github.com/chengzeyi/Comfy-WaveSpeed)

**TeaCache** — no-training post-processing acceleration:
- L1 regularization evaluation for real-time feature map monitoring
- Adaptive cache update strategy based on content
- 30% efficiency improvement for Wan 2.1 video generation
- Seamlessly integrates into existing workflows
- Source: [Oreate AI Blog](https://www.oreateai.com/blog/comfyui-wan-21-technical-analysis-teacache-acceleration-solution-achieves-30-improvement-in-video-generation-efficiency/)

### Notable Custom Nodes (New/Updated)

| Node Pack | Purpose | Status |
|-----------|---------|--------|
| ComfyUI-WanVideoWrapper (kijai) | Wan 2.1/2.2/2.6 + SkyReels wrapper | Actively maintained |
| ComfyUI-KJNodes (kijai) | 180+ QoL nodes, VRAM debug, visual editors | Actively maintained |
| Comfy-WaveSpeed | FBCache + enhanced torch.compile | Actively maintained |
| ComfyUI-nunchaku | SVDQuant 4-bit quantization | v1.2.0 Jan 2026 |
| TTS-Audio-Suite | 11 TTS engines unified | Actively maintained |
| ComfyUI-PuLID-Flux2 | PuLID for FLUX.2 family | New March 2026 |
| ComfyUI_InfiniteYou | ByteDance official ICCV node | Actively maintained |
| Comfyui-LayerForge | Photoshop-like layer canvas editor | Actively maintained |

### 3D Generation — Updates

**Hunyuan3D-2.1** — fully open-sourced:
- New PBR model, VAE encoder, all training code released
- Advanced post-processing via Partner Nodes
- Raw mesh to usable asset in single workflow
- Source: [GitHub](https://github.com/Tencent-Hunyuan/Hunyuan3D-2)

**Rodin3D Gen-2** — added to ComfyUI v0.16.4 as Partner Node:
- Image-to-3D generation directly in ComfyUI
- Source: [ComfyUI Changelog](https://docs.comfy.org/changelog)

### Community Resources (Updated March 2026)

- [ComfyUI Changelog](https://docs.comfy.org/changelog) — official releases
- [ComfyUI Blog](https://blog.comfy.org/) — feature announcements, Day-0 model support
- [ComfyUI Wiki News](https://comfyui-wiki.com/en/news) — aggregated news
- [ComfyUI Forum](https://forum.comfy.org/latest) — community discussions
- [RunComfy Workflows](https://www.runcomfy.com) — curated workflows
- [Pixaroma GitHub](https://github.com/pixaroma/pixaroma-workflows) — YouTube episode workflow backups
- [awesome-comfyui](https://github.com/ComfyUI-Workflow/awesome-comfyui) — daily-updated node collection
- [NVIDIA RTX AI Blog](https://blogs.nvidia.com/blog/rtx-ai-garage-flux-2-comfyui/) — FLUX.2 optimizations

---

## Weekly Sweep — March 27, 2026

<!-- Updated: 2026-03-27 | Source: GitHub Releases, HuggingFace, ComfyUI Changelog, ComfyUI Blog -->

**Scope**: March 20–27, 2026. Three ComfyUI releases, new S2V capability in Wan 2.2, F5-TTS minor release, ComfyUI-Manager going native.

### ComfyUI Core — Three Releases This Week

| Version | Date | Key Changes |
|---------|------|-------------|
| **v0.18.2** | Mar 25 | Stability/immutable release |
| **v0.18.1** | Mar 23 | Fix: canny node broken with fp16; fp16 intermediate sampling bugs fixed |
| **v0.18.0** | Mar 21 | **Major**: mxfp8 support, `--fp16-intermediates` flag (VRAM reduction for LTX + Wan), VAE optimizations |

The `--fp16-intermediates` flag in v0.18.0 is the most impactful practical change — meaningful VRAM reduction specifically for LTX and WAN VAE-heavy workflows without a quality penalty.

### ComfyUI-Manager Going Native (March 28)

ComfyUI-Manager is migrating to `Comfy-Org/ComfyUI-Manager` and will be **bundled natively with ComfyUI** from March 28 onward. Custom node management no longer requires a separate install. Existing installations should update their manager source.

### Wan 2.2 Sound-to-Video (S2V)

Native **Sound-to-Video** support landed in ComfyUI core via the new `WanSoundImageToVideoExtend` node. Audio-driven video generation using Wan 2.2 is now a first-class workflow — no wrapper required. Also added: Wav2vec2 Audio Encoder node (audio-to-embedding for multimodal workflows) and native Audio Recording node.

### F5-TTS v1.1.18 (March 24)

Minor release. Changes: Arabic model documentation, F5TTS v1 Small training config (LibriTTS), streaming vs. non-streaming function split in `utils_infer.py`, parallelism improvements for batch processing. Not a model quality change — no model-landscape update needed.

### HuggingFace Trending — Notable Models

- **Lightricks/LTX-2.3** + GGUF variants — still heavily trending; Day-0 ComfyUI support confirmed (already in model-landscape)
- **unsloth/LTX-2.3-GGUF** — consumer GPU access (Q4/Q8); Kijai safetensor extracts available
- **Wan-Video/Wan2.2** + Q4_K GGUF — enables 8–10GB VRAM usage for the 14B model
- **VibeVoice** — long-form multi-speaker via next-token diffusion (already in model-landscape)
- **Indic Parler-TTS** — 21-language multilingual TTS, 69 voices; niche but notable for non-English workflows
- **OuteTTS-0.2-500M** — Qwen-2.5-0.5B base, multilingual (Chinese, Japanese, Korean) voice cloning

### YouTube — Confirmed New Content

- **Sebastian Kamph**: "Video2Video Restyling with Wan VACE in ComfyUI" — Wan 2.2 VACE reference-image restyling workflow, downloadable. (Other channels: no specific post-Mar-20 videos confirmed via search indexing)

### Other Platform Changes

- **Reve Image API nodes** added March 21 — new image API option in ComfyUI
- **GPT-5 / Gemini 3.1 Flash-Lite** LLM nodes added to core
- **Kling V2-1-Master** + Motion Control with Element Binding (facial consistency) — updated Partner Node
- **RTX Video Super Resolution** (4K upscale) — now a native ComfyUI node

### Custom Nodes — Status Updates

| Node | Status |
|------|--------|
| ComfyUI-Manager | Moving to Comfy-Org, going native Mar 28 |
| ComfyUI-WanVideoWrapper (kijai) | Active; LTX-2.3 + Wan S2V tracking |
| F5-TTS ComfyUI node | v1.1.18 — streaming split, Arabic support |