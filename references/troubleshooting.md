# Troubleshooting Guide

Common ComfyUI errors, their causes, and solutions.

<!-- Updated: 2026-02-06 | Source: Community knowledge + comfyui-character-gen -->

---

## VRAM Errors

### "CUDA out of memory"

**Cause**: Workflow exceeds available VRAM.

**Solutions (try in order):**
1. Add `--lowvram` or `--reserve-vram 1.0` to launch flags
2. Use FP8 quantization: `--fp8_e4m3fn-unet`
3. Enable tiled VAE decode (add "VAE Decode Tiled" node)
4. Reduce resolution (1024→768 for images, 720p→480p for video)
5. Reduce batch size to 1
6. Close other GPU-using applications
7. Restart ComfyUI to clear VRAM fragmentation

### "RuntimeError: expected scalar type BFloat16"

**Cause**: Model precision mismatch.

**Solution**: Ensure model and computation use matching precision. Add a model precision conversion node or use `--force-fp16`.

---

## Node Errors

### "Node type not found: {NodeName}"

**Cause**: Custom node not installed.

**Solutions:**
1. Open ComfyUI-Manager → Install Missing Custom Nodes
2. Manual install: `cd custom_nodes && git clone {repo_url}`
3. Restart ComfyUI after installation

### "Required input '{name}' not provided"

**Cause**: Missing connection in workflow.

**Solution**: Check that all required inputs have connections. Compare against workflow templates in `references/workflows.md`.

### "'NoneType' object has no attribute..."

**Cause**: Model failed to load silently.

**Solutions:**
1. Check model file path is correct
2. Verify model file isn't corrupted (re-download)
3. Check VRAM - model may be too large to load

---

## Model Errors

### "SafetensorError: file does not contain key..."

**Cause**: Wrong model type in wrong loader node.

**Solution**: Ensure you're using the correct loader:
- Checkpoints → "Load Checkpoint"
- Diffusion models → "Load Diffusion Model"
- LoRAs → "Load LoRA"
- ControlNet → "ControlNet Loader"

### "No model found at path..."

**Cause**: Model file in wrong directory or wrong filename.

**Solution**: Verify path against `references/models.md` directory structure. Run inventory scan to confirm file locations.

---

## Image Quality Issues

### Burned/overexposed faces with InstantID

**Cause**: CFG too high.

**Solution**: Lower CFG to 4-5. Add 35% noise injection to negative embeds. Reduce InstantID weight to 0.6-0.8.

### Watermark-like artifacts at 1024x1024

**Cause**: Known issue with exact 1024x1024 resolution on some SDXL models.

**Solution**: Use 1016x1016 or 1020x1020 instead.

### "Plastic" or overly smooth skin

**Cause**: Negative prompt too aggressive or missing detail LoRAs.

**Solutions:**
1. Add skin texture LoRA at 0.2-0.4 strength
2. Remove "smooth skin" from negative if present
3. Add "detailed skin texture, skin pores" to positive
4. Use FaceDetailer with denoise 0.3-0.4

### Character looks nothing like reference

**Cause**: Identity method weights too low or wrong model.

**Solutions:**
1. Increase IP-Adapter weight (0.7-0.9)
2. Ensure InsightFace antelopev2 model is installed
3. Use FaceID Plus V2 (not standard IP-Adapter)
4. Check reference image quality (clear, front-facing works best)

---

## Video Issues

### Flickering/inconsistent frames

**Cause**: No temporal consistency mechanism.

**Solutions:**
1. Use AnimateDiff context options (overlap 4+)
2. Apply deflicker post-processing
3. Lower denoise for FaceDetailer on video (0.3 max)
4. Use RIFE interpolation to smooth

### Video generation extremely slow

**Cause**: Model not optimized for available VRAM.

**Solutions:**
1. Use FP8 quantization for Wan models
2. Enable SageAttention (`sageattn` in model options)
3. Reduce frame count (81→49 frames)
4. Use Wan 1.3B instead of 14B for iteration
5. Use FramePack for long videos

### Wan I2V: output doesn't match input image

**Cause**: CLIP vision encoding mismatch.

**Solution**: Ensure using correct CLIP vision model (`open_clip_vit_h_14.safetensors`) and correct VAE (`wan_2.1_vae.safetensors`).

---

## Voice/Lip-Sync Issues

### Lip-sync out of time

**Cause**: Frame rate mismatch between video and audio.

**Solution**:
```bash
# Offset audio forward 100ms
ffmpeg -i video.mp4 -itsoffset 0.1 -i audio.wav -c:v copy -c:a aac output.mp4

# Offset audio backward 100ms
ffmpeg -i video.mp4 -itsoffset -0.1 -i audio.wav -c:v copy -c:a aac output.mp4
```

### Wav2Lip: blurry mouth area

**Cause**: Wav2Lip resolution limitation.

**Solution**: Always post-process with CodeFormer (fidelity 0.6-0.8) or GFPGAN after Wav2Lip.

### Voice clone sounds robotic

**Cause**: Reference audio too short or noisy.

**Solutions:**
1. Use 10+ seconds of clean reference audio
2. Remove background noise from reference
3. Increase exaggeration parameter (Chatterbox: 0.5-1.5)
4. Try different TTS engine

---

## ComfyUI Server Issues

### Cannot connect to ComfyUI

**Check:**
1. Is ComfyUI running? `curl http://127.0.0.1:8188/system_stats`
2. Is port 8188 blocked by firewall?
3. Is another instance already using port 8188?
4. Try `--listen 0.0.0.0 --port 8188` in launch args

### Queue stuck / not processing

**Solutions:**
1. POST to `/interrupt` to cancel current job
2. POST to `/free` with `{"unload_models": true}` to clear VRAM
3. Restart ComfyUI
4. Check GPU driver isn't crashed (nvidia-smi)
