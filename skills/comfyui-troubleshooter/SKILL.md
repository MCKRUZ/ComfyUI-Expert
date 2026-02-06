---
name: comfyui-troubleshooter
description: Diagnose ComfyUI errors, workflow failures, and quality issues. Suggests fixes based on error patterns, missing dependencies, and community-known workarounds. Use when ComfyUI workflows fail or produce unexpected results.
---

# ComfyUI Troubleshooter

Diagnoses and resolves ComfyUI issues across four categories: server errors, workflow errors, quality issues, and performance problems.

## Diagnosis Process

### Step 1: Classify the Error

| Category | Symptoms | First Check |
|----------|----------|-------------|
| **Server** | Connection refused, timeouts, crashes | Is ComfyUI running? Check `/system_stats` |
| **Workflow** | Node errors, missing inputs, type mismatches | Validate workflow against inventory |
| **Quality** | Artifacts, wrong identity, blurry output | Check settings (CFG, weights, resolution) |
| **Performance** | OOM, slow generation, VRAM errors | Check VRAM usage, model sizes |

### Step 2: Gather Context

Collect before diagnosing:
1. **Error message** (exact text)
2. **Workflow** being executed (or description)
3. **Models** involved (checkpoint, LoRA, ControlNet, etc.)
4. **Settings** (CFG, steps, resolution, sampler)
5. **Hardware** (from `foundation/hardware-profile.md`)
6. **Inventory** (from `state/inventory.json`)

### Step 3: Match Error Pattern

See `references/troubleshooting.md` for the full error database.

## Quick Fix Reference

### Top 10 Most Common Errors

**1. "CUDA out of memory"**
→ Use FP8: `--fp8_e4m3fn-unet`
→ Enable tiled VAE
→ Reduce resolution
→ Restart ComfyUI (clears fragmentation)

**2. "Node type not found: {name}"**
→ Install the custom node package via ComfyUI-Manager
→ Check `comfyui-inventory` node-to-package mapping

**3. "Expected scalar type BFloat16 but found Float"**
→ Precision mismatch. Add `--force-fp16` or use matching precision nodes

**4. Burned/overexposed faces**
→ Lower CFG to 4-5 (InstantID)
→ Reduce identity method weight
→ Add noise to negative embeds (35%)

**5. "No model found at path"**
→ Check filename spelling (exact match required)
→ Verify file is in correct subdirectory
→ Run inventory scan to confirm

**6. Watermark artifacts at 1024x1024**
→ Use 1016x1016 or 1020x1020 instead

**7. Identity doesn't match reference**
→ Use higher quality reference image (clear, front-facing)
→ Increase IP-Adapter weight to 0.8+
→ Verify InsightFace antelopev2 is installed

**8. Video flickering**
→ Lower FaceDetailer denoise to 0.3
→ Add deflicker post-processing
→ Increase AnimateDiff context overlap to 4+

**9. Queue stuck/not processing**
→ POST `/interrupt` to cancel
→ POST `/free` to unload models
→ Restart ComfyUI

**10. Slow generation**
→ Check if `--lowvram` is enabled (remove it on RTX 5090)
→ Use `--highvram` instead
→ Update cuDNN to 8800+
→ Enable SageAttention for Wan models

## Decision Tree: Quality Issues

```
OUTPUT LOOKS WRONG
    |
    |-- Faces look wrong
    |   |-- Too smooth/plastic → Add skin texture LoRA (0.2-0.4)
    |   |-- Wrong identity → Increase identity weight, check reference quality
    |   |-- Burned/hot → Lower CFG to 4-5, reduce InstantID weight
    |   |-- Deformed → Add "bad anatomy, deformed" to negative
    |   |-- Different every time → Fix seed, add LoRA for consistency
    |
    |-- Colors wrong
    |   |-- Oversaturated → Lower CFG, add "oversaturated" to negative
    |   |-- Washed out → Check VAE is loaded, try different scheduler
    |   |-- Color shift in video → Add color correction post-processing
    |
    |-- Resolution/sharpness
    |   |-- Blurry → Increase steps (25-30), check resolution matches model
    |   |-- Pixelated → Use proper upscaler (4x-UltraSharp), not resize
    |   |-- Artifacts → Lower denoise, check for model corruption
    |
    |-- Composition
    |   |-- Ignoring prompt → Increase CFG slightly, simplify prompt
    |   |-- Extra limbs/objects → Add to negative prompt, use ControlNet
    |   |-- Wrong pose → Add ControlNet OpenPose with reference
```

## Missing Dependency Resolution

When a workflow references something not in inventory:

### Missing Custom Node
```
1. Identify package from class_type (see inventory skill's mapping)
2. Suggest: "Open ComfyUI-Manager → Search → Install {package_name}"
3. Alternative: "cd {ComfyUI}/custom_nodes && git clone {repo_url}"
4. Remind: Restart ComfyUI after installation
```

### Missing Model
```
1. Look up in references/models.md for download link
2. Provide: exact filename, download URL, target directory
3. For large models (>10GB): suggest HF CLI for reliability
   "huggingface-cli download {repo} {file} --local-dir {path}"
```

### Version Incompatibility
```
1. Check ComfyUI version vs node package requirements
2. Suggest: "cd {ComfyUI} && git pull" for ComfyUI update
3. Or: pin specific node version if newest breaks things
```

## Escalation

If troubleshooting doesn't resolve the issue:

1. Check ComfyUI GitHub Issues for known bugs
2. Check specific node package's Issues
3. Search r/comfyui for community solutions
4. Suggest posting in ComfyUI Discord with error details

## Reference

- `references/troubleshooting.md` - Full error database with solutions
- `state/inventory.json` - Current installation state
- `references/models.md` - Model download links and paths
