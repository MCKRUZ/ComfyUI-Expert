# LoRA Training Guide for Character Consistency

Training custom LoRAs from reference images (including 3D renders) for maximum character consistency.

---

## When to Train vs Zero-Shot

**Train a LoRA when:**
- Need absolute consistency across many images
- Building a character series or ongoing project
- Zero-shot methods don't capture specific features
- Want to combine with prompts for varied outputs

**Use zero-shot (InstantID/PuLID) when:**
- Quick one-off generation
- Limited reference images (1-5)
- Need style transfer (3D→realistic)
- Testing concepts before committing to training

---

## Dataset Preparation

### Minimum Viable Dataset
- **10-15 images** minimum for recognizable results
- **20-30 images** optimal for strong identity
- **50+ images** for highly flexible, robust LoRA

### Image Requirements

**Technical specs:**
- Resolution: 512×512 minimum, 1024×1024 preferred
- Format: PNG or high-quality JPEG
- File size: No compression artifacts

**Content diversity:**
- Multiple angles (front, 3/4, profile)
- Various expressions (neutral, smile, serious, etc.)
- Different lighting conditions
- Varied backgrounds (or transparent/solid)
- Multiple outfits/contexts

### Preprocessing 3D Renders

**Problem:** Training on 3D renders can bake in the "3D render" aesthetic.

**Solution:** Convert renders to varied styles before training:

```python
# Use img2img to create style variations
styles = [
    "photorealistic portrait, dslr photo",
    "oil painting portrait", 
    "digital illustration",
    "pencil sketch",
    "watercolor portrait"
]
# Generate 3-5 variations per base render
# Include original renders + variations in training set
```

This teaches the model the identity, not the style.

### Cropping Strategy

**For face-focused LoRA:**
- Square crop centered on face
- Face should occupy 50-70% of frame
- Include some neck/shoulders for context
- Consistent framing across dataset

**For full-body LoRA:**
- Include full body shots
- Mix with face close-ups (70/30 ratio)
- Maintain consistent proportions

### Captioning

**Method 1: Auto-caption with JoyCaption + Manual Edit**
```bash
# Run JoyCaption
python caption.py --input ./images --output ./captions

# Then manually add trigger word and remove identity descriptions
```

**Method 2: WD14 Tags + Sentence**
```
sage_character, 1woman, green eyes, freckles, looking at viewer, 
white shirt, indoor, soft lighting
```

**Critical captioning rules:**

1. **Always prefix with unique trigger word:**
   - Good: `sage_character`, `ohwx_sage`, `sks_person`
   - Bad: `woman`, `redhead`, `character` (too generic)

2. **Don't describe the face in detail:**
   - Bad: "woman with green eyes, freckles, auburn hair, defined cheekbones"
   - Good: "sage_character, woman, indoor portrait"
   - Let the model learn features organically

3. **Do describe everything else:**
   - Clothing, pose, background, lighting, camera angle
   - Expression (smiling, serious, etc.)
   - Style cues (photorealistic, illustration, etc.)

4. **Keep captions consistent in structure:**
   ```
   [trigger], [subject], [clothing], [pose], [setting], [lighting], [style]
   ```

---

## Training Parameters

### SDXL LoRA (Kohya_ss)

**Config file settings:**
```yaml
# Basic settings
pretrained_model_name_or_path: "./models/RealVisXL_V5.0.safetensors"
train_data_dir: "./dataset/sage"
output_dir: "./output"
output_name: "sage_character_sdxl"

# Network settings
network_module: "networks.lora"
network_dim: 32          # Rank - 16-64, higher = more capacity
network_alpha: 16        # Usually dim/2

# Training settings  
resolution: "1024,1024"
train_batch_size: 1      # 2 if VRAM allows
gradient_accumulation_steps: 4
learning_rate: 0.0001    # 1e-4, can try 4e-4
lr_scheduler: "cosine_with_restarts"
lr_scheduler_num_cycles: 3
max_train_epochs: 10
optimizer_type: "AdamW8bit"

# Quality settings
mixed_precision: "bf16"
save_precision: "fp16"
cache_latents: true
cache_latents_to_disk: true
enable_bucket: true
min_bucket_reso: 512
max_bucket_reso: 2048

# Regularization (optional but recommended)
prior_loss_weight: 1.0
min_snr_gamma: 5
```

**Recommended steps calculation:**
```
total_steps = (num_images × repeats × epochs) / batch_size
target: 1500-3000 steps for SDXL

Example: 20 images × 10 repeats × 5 epochs / 1 batch = 1000 steps
```

### FLUX LoRA (AI-Toolkit)

**Config YAML:**
```yaml
job: extension
config:
  name: "sage_character_flux"
  process:
    - type: sd_trainer
      training_folder: "./output"
      device: cuda:0
      
      network:
        type: lora
        linear: 16           # Rank
        linear_alpha: 16     # Alpha = rank for FLUX
        
      model:
        name_or_path: "black-forest-labs/FLUX.1-dev"
        assistant_lora_path: null
        quantize: true       # Enable for <24GB VRAM
        
      datasets:
        - folder_path: "./dataset/sage"
          caption_ext: "txt"
          default_caption: "sage_character"
          resolution: [1024]
          
      train:
        batch_size: 1
        gradient_accumulation_steps: 4
        steps: 1500          # FLUX converges faster
        lr: 4e-4             # Higher LR for FLUX
        optimizer: adamw8bit
        dtype: bf16
        
      sample:
        sample_every: 250
        prompts:
          - "sage_character, photorealistic portrait, green eyes"
```

**FLUX training notes:**
- Converges 2-3x faster than SDXL
- Use higher learning rate (4e-4 vs 1e-4)
- 1000-2000 steps usually sufficient
- Quality plateaus earlier, watch for overfitting

### Low VRAM Training (FluxGym)

For 12-16GB VRAM:

```yaml
# Enable all memory optimizations
use_8bit_adam: true
gradient_checkpointing: true
cache_latents_to_disk: true
max_data_loader_n_workers: 0

# Reduce batch processing
train_batch_size: 1
gradient_accumulation_steps: 8

# Use NF4 quantization (SimpleTuner)
quantize_base_model: nf4
```

---

## Training Workflow

### Step 1: Prepare Dataset
```bash
# Create folder structure
mkdir -p dataset/sage/10_sage_character

# Place images (naming: 001.png, 002.png, ...)
# Place captions (naming: 001.txt, 002.txt, ...)
```

Folder naming: `[repeats]_[trigger word]`
- `10_sage_character` = each image repeated 10 times per epoch

### Step 2: Run Training (Kohya)
```bash
# Navigate to kohya_ss
cd kohya_ss

# Start training with config
accelerate launch train_network.py --config_file ./config/sage_train.yaml
```

### Step 3: Test Checkpoints
- Training saves checkpoints every N steps
- Test each checkpoint with identical prompts
- Look for: identity accuracy, flexibility, overfitting signs

### Step 4: Select Best Epoch
**Signs of good training:**
- Character recognizable from trigger word alone
- Responds well to different prompts/contexts
- Doesn't always produce same pose/expression

**Signs of overfitting:**
- Same exact pose/expression regardless of prompt
- Background elements from training appearing
- Ignores clothing/setting prompts

---

## Recommended Settings by Use Case

### 3D Render → Photorealistic Character

```yaml
# Preprocessing
- Convert 3D renders to varied styles first
- Mix: 60% style variations, 40% original renders

# Training
network_dim: 32
learning_rate: 0.0001
epochs: 8-10
steps: ~2000

# Testing
- Test with InstantID/PuLID combination
- LoRA provides base identity, zero-shot methods add realism
```

### Anime/Stylized Character

```yaml
# Use anime-focused base model
pretrained_model: "animagineXL" OR "ponyDiffusion"

# Training
network_dim: 48-64  # Higher for style complexity
learning_rate: 0.00008
epochs: 12-15

# Include style tags
captions: "sage_character, anime style, 1girl, ..."
```

### Video-Ready Character LoRA

```yaml
# Include motion diversity in training
- Standing, sitting, walking poses
- Various arm positions
- Multiple head angles

# Training (slightly overfit for consistency)
network_dim: 24
epochs: 12
# Test with AnimateDiff to verify motion compatibility
```

---

## Combining LoRA with Zero-Shot Methods

**Best practice: LoRA as base, zero-shot for enhancement**

```
[Load Checkpoint]
      ↓
[Load Character LoRA (0.7-0.9 strength)]
      ↓
[Apply PuLID or IP-Adapter (0.5-0.7 weight)]
      ↓
[Generate]
```

This approach:
- LoRA provides learned identity from training
- Zero-shot method reinforces specific reference features
- Lower weights on both prevent conflict
- More robust than either method alone

---

## Troubleshooting

### LoRA not activating
- Verify trigger word exactly matches training
- Check LoRA strength (start at 0.8)
- Ensure LoRA loaded BEFORE KSampler

### Identity drift at different angles
- Add more varied angles to dataset
- Reduce network_dim (16-24)
- Lower learning rate

### Overfitting (same output every time)
- Reduce epochs
- Increase dataset size
- Lower network_dim
- Add more caption variety

### Style contamination (looks like training images)
- Better caption diversity
- Don't describe style in captions
- Use style-varied preprocessing

### Poor quality/artifacts
- Check training images for compression artifacts
- Reduce learning rate
- Enable min_snr_gamma
- Try different optimizer
