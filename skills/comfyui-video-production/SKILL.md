---
name: comfyui-video-production
description: Production-ready ComfyUI video pipeline orchestrator. Handles keyframe generation, I2V animation, video concatenation, quality validation, and ComfyUI instance management. Supports Wan 2.2 MoE, LTX-2, AnimateDiff, SVD, with automatic error recovery, transition effects, and resume capabilities. Use for: multi-shot video creation, keyframe workflows, batch I2V processing, video stitching, ComfyUI automation.
---

# ComfyUI Video Production Pipeline

End-to-end video production orchestration for ComfyUI with automatic error recovery, quality validation, and instance management.

## Quick Start: Which Pipeline?

**Creating a multi-shot narrative video?**
→ **Keyframe Pipeline** - Generate keyframes → Animate → Stitch with transitions

**Animating existing images?**
→ **I2V Batch Pipeline** - Load images → Queue I2V jobs → Auto-validate → Combine

**Need smooth transitions between scenes?**
→ **Transition Pipeline** - Crossfades, motion blur, zoom effects via FFmpeg

**ComfyUI stuck or crashed?**
→ **Instance Manager** - Auto-restart, health checks, queue monitoring

**Debugging video issues?**
→ **Validation Suite** - Check resolution, FPS, codec, face consistency, color grading

---

## Core Pipelines

### Pipeline 1: Keyframe-to-Video (Complete Narrative)

**Use when:** Creating story-driven videos with multiple distinct shots

```
1. Keyframe Generation Phase
   - Generate consistent keyframes with IP-Adapter/LoRA
   - Validate face consistency, lighting, pose progression
   - Save to organized directory structure
   - Auto-retry failed generations

2. I2V Animation Phase
   - Queue each keyframe to I2V model (Wan 2.2, LTX-2, AnimateDiff)
   - Monitor progress via ComfyUI API
   - Validate each clip (resolution, fps, duration)
   - Auto-retry with different seeds if failed

3. Concatenation Phase
   - Pre-flight validation (ensure all clips match)
   - Apply transition effects (crossfade, motion blur)
   - FFmpeg encoding with proper codec
   - Export final video with metadata

4. Quality Assurance
   - Face consistency check across clips
   - Color grading consistency
   - Audio sync validation (if applicable)
   - Generate QA report
```

**Expected output:** Single cohesive video with smooth transitions

---

### Pipeline 2: Batch I2V Processing

**Use when:** You have multiple images to animate independently

```
1. Image Discovery
   - Scan directory for source images
   - Validate image specs (resolution, format)
   - Generate processing manifest

2. Parallel I2V Queue
   - Queue all images to ComfyUI with appropriate prompts
   - Stagger submissions to avoid overload
   - Monitor queue depth and ETA

3. Progressive Validation
   - Check each completed video immediately
   - Flag issues (wrong resolution, fps, corruption)
   - Auto-retry flagged videos

4. Export & Organize
   - Move validated videos to output directory
   - Generate index with metadata
   - Create contact sheet (thumbnail preview grid)
```

**Expected output:** Directory of validated animated clips

---

### Pipeline 3: Video Concatenation with Transitions

**Use when:** Combining existing video clips with professional transitions

```
1. Clip Validation
   - Verify all clips exist and are readable
   - Check resolution, fps, codec consistency
   - Report mismatches with fix suggestions

2. Transition Planning
   - Detect scene changes (cut detection)
   - Recommend transition types (crossfade, zoom, pan)
   - Calculate transition timing

3. FFmpeg Pipeline
   - Apply transitions between clips
   - Re-encode with consistent settings
   - Preserve quality (high bitrate, proper codec)

4. Audio Handling
   - Extract audio from clips (if present)
   - Crossfade audio at transitions
   - Sync to final video timeline
```

**Expected output:** Polished video with seamless transitions

---

## Model Support (2026)

### Image-to-Video Models

| Model | Quality | Speed | VRAM | Best For | Notes |
|-------|---------|-------|------|----------|-------|
| **LTX-2** | ★★★★★ | Medium | 16GB+ | **Production 4K video** | Native 4K, audio+video |
| **Wan 2.2 MoE** | ★★★★★ | Slow | 24GB+ | **Film-quality aesthetics** | First+last frame control |
| Wan 2.1 14B | ★★★★ | Slow | 24GB | High quality | Proven, stable |
| Wan 2.1 1.3B | ★★★ | Fast | 8GB | **Quick iteration** | Consumer-friendly |
| AnimateDiff V3 | ★★★ | Fast | 8GB | Infinite length | Motion LoRAs |
| SVD (Stable Video Diffusion) | ★★★ | Medium | 12GB | Short clips | 14-25 frames |

### Transition Effects

| Effect | Use Case | Encoding Cost |
|--------|----------|---------------|
| **Crossfade** | General purpose | Low |
| **Motion blur** | High-motion scenes | Medium |
| **Zoom in/out** | Dramatic emphasis | Medium |
| **Pan left/right** | Scene establishment | Medium |
| **Fade to/from black** | Chapter breaks | Low |
| **Custom LUT** | Color grading | Low |

---

## ComfyUI Instance Management

### Health Monitoring

```python
# Auto-detected issues:
- Queue stalled (no progress for 5+ minutes)
- Memory leak (VRAM usage climbing)
- Process crashed (connection refused)
- API unresponsive (timeout on /queue endpoint)
- Disk full (output directory at capacity)
```

### Auto-Recovery Actions

```python
1. Soft Recovery (no restart)
   - Clear stuck queue items
   - Force garbage collection
   - Unload models from VRAM

2. Hard Recovery (restart required)
   - Save current queue state
   - Kill ComfyUI process gracefully
   - Wait for port release
   - Restart with same config
   - Restore queue from saved state

3. Emergency Fallback
   - Switch to backup ComfyUI instance
   - Redirect queue to instance on different port
   - Continue processing without data loss
```

### Multi-Instance Support

```bash
# Run multiple ComfyUI instances for parallel processing
Instance 1: localhost:8188 (primary - I2V generation)
Instance 2: localhost:8189 (secondary - upscaling/post-processing)
Instance 3: localhost:8190 (backup - standby for failover)

# Load balancing strategy:
- Round-robin for equal workloads
- Priority-based for mixed tasks
- Failover for crashed instances
```

---

## Validation Suite

### Pre-Generation Validation

```python
✓ Check ComfyUI is running and responsive
✓ Verify models are loaded (UNET, VAE, CLIP)
✓ Confirm output directory has sufficient space
✓ Validate source images exist and are readable
✓ Check prompts are non-empty and formatted correctly
✓ Verify workflow JSON is valid
```

### Post-Generation Validation

```python
✓ Video file exists and is non-zero size
✓ Resolution matches expected (e.g., 768x1024)
✓ FPS matches expected (e.g., 16 or 25)
✓ Duration matches expected (e.g., 3-5 seconds)
✓ Codec is compatible (h264, h265)
✓ No corruption (can read all frames)
✓ Face consistency score >0.85 (if character video)
✓ Color histogram within expected range
```

### Quality Metrics

```python
Metrics tracked:
- Face embedding distance (identity consistency)
- Optical flow magnitude (motion smoothness)
- Frame PSNR/SSIM (interpolation quality)
- Color histogram deviation (lighting consistency)
- Audio sync offset (if audio present)
```

---

## Error Handling & Recovery

### Retry Strategies

```python
1. Seed Randomization Retry
   - Failed generation? Try different seed
   - Max 3 attempts per keyframe
   - Track seeds that fail (avoid reuse)

2. Parameter Adjustment Retry
   - CFG too high causing artifacts? Lower it
   - Steps too low causing incompleteness? Increase
   - Resolution too high OOM? Downscale

3. Model Fallback Retry
   - Wan 2.2 14B OOM? Fall back to 1.3B
   - LTX-2 unavailable? Fall back to Wan 2.1
   - AnimateDiff motion broken? Switch motion LoRA

4. Checkpoint Resume
   - Save progress after each successful clip
   - Resume from last successful checkpoint
   - Skip already-generated clips
```

### Failure Logging

```python
logs/
├── 2026-02-16_pipeline.log       # Main pipeline log
├── 2026-02-16_comfyui.log        # ComfyUI stdout/stderr
├── 2026-02-16_validation.json    # Validation results
├── 2026-02-16_failures.json      # Failed attempts with reasons
└── 2026-02-16_recovery.json      # Recovery actions taken
```

---

## Directory Structure

### Organized Output

```
project_name/
├── 00_keyframes/                 # Source keyframe images
│   ├── kf01_scene_description.png
│   ├── kf02_scene_description.png
│   └── ...
├── 01_clips/                     # Individual animated clips
│   ├── clip_001_kf01.mp4
│   ├── clip_002_kf02.mp4
│   └── ...
├── 02_validated/                 # Clips that passed validation
│   ├── clip_001_kf01.mp4
│   ├── clip_002_kf02.mp4
│   └── ...
├── 03_transitions/               # Intermediate files for transitions
│   ├── transition_001_002.mp4
│   └── ...
├── 04_final/                     # Final combined video
│   ├── final_video_v1.mp4
│   ├── final_video_v2.mp4        # After revisions
│   └── ...
├── logs/                         # Execution logs
├── metadata/                     # JSON metadata for each asset
└── manifest.json                 # Complete project manifest
```

---

## Workflow Examples

### Example 1: 30-Second Narrative Video (5 keyframes)

```python
# Configuration
project_name = "sage_character_reveal"
keyframes = 5
i2v_model = "wan_2.2_moe"
target_duration = 30  # seconds
fps = 16

# Pipeline execution
1. Generate 5 keyframes (IP-Adapter + LoRA)
   → sage_kf01_over_shoulder.png
   → sage_kf02_turning.png
   → sage_kf03_cardigan_fallen.png
   → sage_kf04_removing_bra.png
   → sage_kf05_topless.png

2. Validate keyframes
   → Face consistency: 0.92 ✓
   → Lighting consistency: 0.88 ✓
   → Pose progression: logical ✓

3. Queue I2V for each keyframe
   → clip_001: 6s @ 16fps (96 frames) ✓
   → clip_002: 6s @ 16fps (96 frames) ✓
   → clip_003: 6s @ 16fps (96 frames) ✓
   → clip_004: 6s @ 16fps (96 frames) ✓
   → clip_005: 6s @ 16fps (96 frames) ✓

4. Apply 0.5s crossfade transitions
   → Total: 30s - 2s (4 transitions × 0.5s) = 28s net

5. Export final video
   → sage_character_reveal_final.mp4 (30s, 768x1024, 16fps)
```

### Example 2: Batch Process 20 Images

```python
# Configuration
input_dir = "E:/ComfyUI/input/character_expressions"
i2v_model = "ltx_2"
motion_prompt = "gentle breathing, subtle movement, natural"
batch_size = 4  # Process 4 at a time

# Pipeline execution
1. Scan input directory
   → Found 20 PNG files

2. Queue 4 at a time to ComfyUI
   → Batch 1: expr_001.png → expr_004.png ✓
   → Batch 2: expr_005.png → expr_008.png ✓
   → Batch 3: expr_009.png → expr_012.png ✓
   → Batch 4: expr_013.png → expr_016.png ✓
   → Batch 5: expr_017.png → expr_020.png ✓

3. Validate each output
   → 19/20 passed (expr_011 failed - wrong resolution)
   → Retry expr_011 with corrected settings ✓

4. Export batch
   → 20 validated clips in output/expressions/
   → Generated contact sheet: expressions_preview.png
```

---

## Reference Files

### Detailed Guides

- `references/keyframe-generation.md` - Keyframe creation with IP-Adapter, LoRA, consistency tips
- `references/i2v-workflows.md` - Wan 2.2, LTX-2, AnimateDiff, SVD workflow templates
- `references/concatenation.md` - FFmpeg commands, transition effects, audio handling
- `references/validation.md` - Quality metrics, validation thresholds, troubleshooting
- `references/instance-management.md` - ComfyUI health checks, restart scripts, multi-instance setup
- `references/api-reference.md` - ComfyUI API endpoints, queue management, workflow submission
- `references/troubleshooting.md` - Common issues and solutions

---

## Integration with Other Skills

**Pair with:**
- `comfyui-character-gen` - For generating initial keyframes with identity preservation
- `video-assembly` - For advanced editing and post-production
- `youtube-uploader` - For direct upload to YouTube after production

---

## Advanced Features

### Adaptive Quality

```python
# Automatically adjust settings based on available resources
if vram_available > 24:
    use_model = "wan_2.2_moe_14b"
    resolution = (832, 1216)
    batch_size = 1
elif vram_available > 12:
    use_model = "wan_2.1_1.3b"
    resolution = (768, 1024)
    batch_size = 2
else:
    use_model = "animatediff_v3"
    resolution = (512, 768)
    batch_size = 4
```

### Progress Tracking

```python
# Real-time progress updates
[Pipeline] Keyframe generation: 3/5 complete (60%)
[Pipeline] ETA: 12 minutes remaining
[I2V] clip_003 generating: 47/96 frames (49%)
[I2V] Current speed: 0.42 it/s
[Validation] clip_001: PASS ✓
[Validation] clip_002: PASS ✓
```

### Rollback & Versioning

```python
# Automatically version outputs
output/
├── final_video_v1.mp4        # Initial render
├── final_video_v2.mp4        # After fixing clip_003
├── final_video_v3.mp4        # After adding transitions
└── final_video_final.mp4     # Approved version

# Rollback to previous version
rollback_to_version(2)  # Restore v2 as current
```

---

## Workflow Generation

When asked to create a video production workflow:

1. **Assess Requirements**
   - Number of shots/keyframes
   - Target duration per shot
   - I2V model preference
   - Transition style
   - Quality vs speed tradeoff

2. **Generate Pipeline Config**
   - Model selection based on VRAM/quality needs
   - Resolution and FPS settings
   - Validation thresholds
   - Retry policies

3. **Provide Execution Scripts**
   - Python scripts for API submission
   - FFmpeg commands for concatenation
   - Validation checks
   - Recovery procedures

4. **Monitor & Adapt**
   - Track progress in real-time
   - Detect failures early
   - Apply recovery strategies
   - Report final metrics

---

## Best Practices

### For Keyframe Videos
- Use same seed across all keyframes (consistency)
- IP-Adapter weight 0.75-0.85 (strong but not rigid)
- Validate keyframes before I2V (saves compute)
- Keep clips 4-8 seconds each (sweet spot)
- Use 0.5-1s crossfade transitions (smooth but not slow)

### For Batch Processing
- Process in small batches (4-8 at a time)
- Validate immediately after each batch
- Save checkpoint after each successful batch
- Use priority queue for important clips

### For Instance Management
- Monitor queue depth every 30s
- Restart if no progress for 5 minutes
- Keep backup instance ready on different port
- Log all restart events for debugging

---

## Performance Optimization

### RTX 50 Series (2026)
```bash
# ComfyUI launch flags for optimal performance
--highvram \
--fp8_e4m3fn-unet \
--reserve-vram 7 \
--use-pytorch-cross-attention

# Expected performance:
- Wan 2.2 14B: ~2-3 min per 5s clip (832x1216)
- LTX-2 4K: ~4-5 min per 5s clip (1920x1080)
- Wan 2.1 1.3B: ~1-2 min per 5s clip (768x1024)
```

### AMD GPUs (ROCm)
```bash
# ComfyUI v0.8.1+ has native ROCm support
# No special flags needed, just install ROCm drivers
```

---

## Skill Evolution

This skill adapts to new I2V models and techniques. When new models release:
1. Add model specs to `references/i2v-workflows.md`
2. Create workflow template for new model
3. Update model selection logic in main pipeline
4. Test with sample project
5. Document performance characteristics

See `references/evolution.md` for update protocol.
