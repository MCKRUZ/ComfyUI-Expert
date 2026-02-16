# ComfyUI Workflow Templates

Detailed node configurations for each workflow pattern. Copy and adapt these templates.

---

## Workflow 1: InstantID + IP-Adapter FaceID (Zero-Shot)

Best for converting 3D renders to photorealistic images without training.

### Node Graph

```
[Load Image: Reference Face]
         ↓
[InstantID Model Loader] ──────────────────────┐
         ↓                                      │
[Apply InstantID] ←─────────────────────────────┤
         ↓                                      │
[IPAdapter Unified Loader FaceID] ──────────────┤
         ↓                                      │
[Apply IPAdapter FaceID] ←──────────────────────┤
         ↓                                      │
[Load Checkpoint] → [CLIP Text Encode (pos/neg)]│
         ↓                                      │
[ControlNet Apply] ←── [ControlNet Loader] ─────┘
         ↓
[KSampler] → [VAE Decode] → [FaceDetailer] → [Upscale] → [Save Image]
```

### Node Settings

**Load Checkpoint**
```
ckpt_name: "flux1-dev.safetensors" OR "RealVisXL_V5.0.safetensors"
```

**InstantID Model Loader**
```
instantid_file: "ip-adapter.bin"
```

**Apply InstantID**
```
weight: 0.8
start_at: 0.0
end_at: 1.0
noise: 0.35  # Critical: adds noise to negative for stability
```

**IPAdapter Unified Loader FaceID**
```
preset: "FACEID PLUS V2"
lora_strength: 0.6
provider: "CPU"  # Saves GPU VRAM
```

**Apply IPAdapter FaceID**
```
weight: 0.7
weight_type: "style transfer"  # Better for 3D→realistic
start_at: 0.0
end_at: 0.8  # Stop early for better blending
```

**CLIP Text Encode (Positive)**
```
text: "photorealistic portrait of [description], detailed skin texture, 
       natural lighting, skin pores, freckles, green eyes, auburn hair, 
       8k uhd, dslr quality"
```

**CLIP Text Encode (Negative)**
```
text: "3d render, cartoon, anime, illustration, painting, drawing, 
       plastic skin, smooth skin, airbrushed, cgi, video game, 
       blurry, low quality, deformed"
```

**KSampler**
```
seed: [random or fixed]
steps: 25-30
cfg: 4-5  # LOW - critical for InstantID
sampler_name: "euler" OR "dpmpp_2m"
scheduler: "karras"
denoise: 1.0
```

**FaceDetailer (from Impact Pack)**
```
guide_size: 512
guide_size_for: true
max_size: 1024
seed: [same as KSampler for consistency]
steps: 20
cfg: 4-5
sampler_name: "euler"
scheduler: "karras"
denoise: 0.35-0.45  # Subtle refinement
detection_model: "face_yolov8m.pt"
sam_model: "sam_vit_b_01ec64.pth"
```

**Ultimate SD Upscale**
```
upscale_by: 2.0
tile_width: 1024
tile_height: 1024
mask_blur: 8
seam_fix_mode: "BAND_PASS"
model: "4x-UltraSharp.pth"
```

---

## Workflow 2: Character LoRA + PuLID (Maximum Consistency)

For production work requiring absolute identity consistency.

### Node Graph

```
[Load Checkpoint]
       ↓
[Load LoRA] ← "sage_character.safetensors"
       ↓
[PuLID Model Loader]
       ↓
[Apply PuLID] ← [Load Image: Reference]
       ↓
[ControlNet Stack] ← [Pose/Depth Preprocessor]
       ↓
[KSampler] → [VAE Decode] → [FaceDetailer] → [ReActor (optional)] → [Upscale]
```

### Node Settings

**Load LoRA**
```
lora_name: "sage_character.safetensors"
strength_model: 0.8
strength_clip: 0.8
```

**PuLID Model Loader**
```
pulid_file: "pulid_flux_v0.9.1.safetensors"
```

**Apply PuLID**
```
weight: 0.7
method: "neutral"  # Best for realistic output
start_at: 0.0
end_at: 1.0
```

**Positive Prompt (with trigger)**
```
"sage_character, photorealistic portrait, detailed skin with freckles, 
 emerald green eyes, auburn copper hair, natural lighting, 8k"
```

**ReActor (if needed for exact face match)**
```
enabled: true
input_faces_index: 0
source_faces_index: 0
face_model: "inswapper_128.onnx"
face_restore_model: "codeformer.pth"
face_restore_visibility: 0.8
codeformer_fidelity: 0.7
```

---

## Workflow 3: AnimateDiff Character Video

Fast iteration video generation with character consistency.

### Node Graph

```
[Load Checkpoint] → [Load LoRA]
         ↓
[AnimateDiff Loader] ← [Motion Module]
         ↓
[AnimateDiff Settings] ← context_options
         ↓
[IPAdapter Apply] ← [Load Reference]
         ↓
[ControlNet Apply] ← [OpenPose from Video]
         ↓
[KSampler] → [VAE Decode] → [FaceDetailer Batch] → [RIFE Interpolate] → [Video Combine]
```

### Node Settings

**AnimateDiff Loader**
```
model_name: "v3_sd15_mm.ckpt" OR "animatediff_lightning_4step.safetensors"
beta_schedule: "sqrt_linear (AnimateDiff)"
```

**AnimateDiff Context Options**
```
context_length: 16
context_stride: 1
context_overlap: 4
context_schedule: "uniform"
closed_loop: false
```

**KSampler (for AnimateDiff)**
```
steps: 8-12 (Lightning) OR 20-25 (Standard)
cfg: 7-8
sampler_name: "lcm" (Lightning) OR "euler_ancestral"
```

**Video Combine (VHS)**
```
frame_rate: 8  # AnimateDiff native
format: "video/h264-mp4"
filename_prefix: "character_video"
```

**RIFE Interpolation (for smoothness)**
```
multiplier: 2  # Doubles frame count
model: "rife47" OR "rife49"
```

---

## Workflow 4: Wan 2.1 Image-to-Video

Highest quality video from character image.

### Node Graph

```
[Load Diffusion Model: Wan I2V]
         ↓
[Wan I2V Conditioning] ← [Load Image: Hero Shot] + [Load CLIP Vision]
         ↓
[EmptySD3LatentImage] ← (81 frames, 720p)
         ↓
[KSampler] → [VAE Decode] → [FaceDetailer Batch] → [Video Combine]
```

### Node Settings

**Load Diffusion Model**
```
model: "wan2.1_i2v_720p_14b_bf16.safetensors"
```

**Wan I2V Conditioning**
```
width: 1280
height: 720
length: 81  # frames (~5 seconds at 16fps)
```

**KSampler**
```
steps: 30-50
cfg: 5-7
sampler_name: "uni_pc"
scheduler: "normal"
```

**Video Combine**
```
frame_rate: 16
format: "video/h264-mp4"
```

### VRAM Optimization (for Wan 14B)

Add these nodes if VRAM limited:

**Model Options Node**
```
quantize: "fp8"
attention: "sageattn"  # Faster attention
```

---

## Workflow 5: Talking Head Pipeline

Character image + voice → talking video.

### Full Pipeline

```
STAGE 1: Generate Audio
[Text] → [F5-TTS/Chatterbox] → [audio.wav]

STAGE 2: Generate Base Video (if needed)
[Character Image] → [Wan I2V or AnimateDiff] → [base_video.mp4]

STAGE 3: Apply Lip-Sync
[base_video.mp4 OR image] + [audio.wav] → [Wav2Lip] → [lipsync_video.mp4]

STAGE 4: Enhance
[lipsync_video.mp4] → [CodeFormer per frame] → [final_video.mp4]
```

### Wav2Lip Node Settings

```
face_detect_batch: 16
nosmooth: false
resize_factor: 1
wav2lip_model: "wav2lip_gan.pth"
pad_top: 0
pad_bottom: 10  # Slight padding helps with chin area
pad_left: 0
pad_right: 0
```

### SadTalker Alternative

```
driven_audio: "audio.wav"
source_image: "character.png"
preprocess: "full"  # Better for novel faces
enhancer: "gfpgan"
batch_size: 2
pose_style: 0  # 0-45, controls head movement style
```

---

## Workflow 6: Multi-Pass Face Fix for Video

When video generation produces inconsistent faces.

### Node Graph

```
[Load Video]
       ↓
[VHS Video to Images]
       ↓
[For Each Frame Loop] ──┐
       ↓                │
[FaceDetailer]          │
       ↓                │
[ReActor (reference)]   │
       ↓                │
[←──────────────────────┘
       ↓
[VHS Images to Video]
       ↓
[Save Video]
```

### Batch Processing Settings

**VHS Load Video**
```
force_size: "Disabled"
frame_load_cap: 0  # All frames
skip_first_frames: 0
select_every_nth: 1
```

**FaceDetailer (for video)**
```
denoise: 0.3-0.4  # Lower for frame consistency
guide_size: 384  # Smaller for speed
```

---

## Workflow 7: FLUX Kontext Character Editing

Edit existing character images without retraining.

### Node Graph

```
[Load FLUX Kontext Model]
         ↓
[Load Image: Existing Character]
         ↓
[Kontext Apply] ← [Edit Instruction]
         ↓
[KSampler] → [VAE Decode] → [Save]
```

### Example Edit Instructions

```
"Change outfit to elegant black evening dress"
"Add sunglasses while keeping face exactly the same"  
"Change background to Manhattan skyline at sunset"
"Age the character by 10 years"
"Change expression to laughing genuinely"
```

### Settings

```
edit_strength: 0.7-0.9  # Higher = more change
preserve_identity: true
steps: 25-30
```

---

## Common Node Chains

### Face Enhancement Chain
```
[Image] → [FaceDetailer] → [CodeFormer] → [Upscale] → [Output]
```

### Identity Stacking Chain
```
[Image] → [InstantID] → [IP-Adapter FaceID] → [ControlNet Pose] → [KSampler]
```

### Video Smoothing Chain
```
[Frames] → [RIFE 2x] → [Deflicker] → [Color Correct] → [Video Combine]
```

### Multi-ControlNet Chain
```
[Reference] → [DWPose Preprocessor] → [Depth Preprocessor]
                    ↓                         ↓
              [ControlNet 1]           [ControlNet 2]
                    ↓_________________________↓
                              ↓
                    [ControlNet Apply Stack]
```

---

## Resolution Guide

| Output | Generation | Upscale To | Notes |
|--------|------------|------------|-------|
| Social media | 1024×1024 | 2048×2048 | Standard quality |
| Print | 1024×1024 | 4096×4096 | Use SUPIR for best |
| Video 720p | 1280×720 | - | Native Wan |
| Video 1080p | 1280×720 | 1920×1080 | Upscale after |
| Close-up | 768×1024 | 1536×2048 | Portrait crop |

## CFG Guidelines

| Method | CFG Range | Notes |
|--------|-----------|-------|
| InstantID | 4-5 | Higher = burning/artifacts |
| PuLID | 5-7 | More tolerant than InstantID |
| IP-Adapter only | 7-8 | Standard range |
| FLUX standard | 3.5-4 | FLUX likes low CFG |
| SDXL standard | 7-9 | Traditional range |
| AnimateDiff | 7-8 | Slightly lower helps motion |
