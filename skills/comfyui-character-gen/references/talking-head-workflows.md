# Talking Head Workflow Reference

Complete production workflows for creating talking head videos using two main approaches.

---

## Table of Contents

1. [Approach 1: Image → Talking Head](#approach-1-image--talking-head)
2. [Approach 2: Video → Add Voice/Lip-Sync](#approach-2-video--add-voicelip-sync)
3. [Hybrid Approach](#hybrid-approach)
4. [Parameter Reference](#parameter-reference)
5. [Troubleshooting](#troubleshooting)

---

## Approach 1: Image → Talking Head

**Use Case:** Generate talking head video from single character portrait.

**Input:** 1 image (1024×1024 recommended) + audio file
**Output:** Talking head video with natural head movement and lip-sync
**Time:** 2-5 minutes per 10-second clip (GPU-dependent)

### Method 1A: SadTalker (Most Popular)

**Best For:** Natural head movement, expressions, eye blink

#### Installation

```bash
# Clone SadTalker
cd E:/ComfyUI-Easy-Install/ComfyUI/custom_nodes
git clone https://github.com/Winfredy/SadTalker

# Install dependencies
cd SadTalker
pip install -r requirements.txt

# Download checkpoints
python scripts/download_models.py
```

**Required Models:**
- `checkpoints/SadTalker_V0.0.2_512.safetensors` (4.5GB)
- `gfpgan/weights/` (face enhancement)
- `checkpoints/mapping_00109-model.pth.tar` (expression)
- `checkpoints/mapping_00229-model.pth.tar` (pose)

#### Python Script

```python
#!/usr/bin/env python3
"""
SadTalker: Image to Talking Head Video
Generates natural talking head with head movement from single portrait
"""

import os
import sys
sys.path.append('E:/ComfyUI-Easy-Install/ComfyUI/custom_nodes/SadTalker/src')

from facerender.animate import AnimateFromCoeff
from test_audio2coeff import Audio2Coeff
from face3d.models import networks

class SadTalkerPipeline:
    def __init__(self, checkpoint_dir='checkpoints'):
        self.checkpoint_dir = checkpoint_dir
        self.device = 'cuda'

        # Load models
        self.audio2coeff = Audio2Coeff(checkpoint_dir, self.device)
        self.animate = AnimateFromCoeff(checkpoint_dir, self.device)

    def generate(
        self,
        source_image,
        driven_audio,
        output_path,
        preprocess='crop',  # 'crop', 'resize', 'full'
        still_mode=False,   # Less head movement
        use_enhancer=True,  # GFPGAN enhancement
        batch_size=2,
        fps=25
    ):
        """
        Generate talking head video

        Args:
            source_image: Path to portrait (1024x1024 recommended)
            driven_audio: Path to audio file (.wav, .mp3)
            output_path: Output video path
            preprocess: How to handle input image
            still_mode: True for minimal head movement
            use_enhancer: Apply GFPGAN for face quality
            batch_size: Processing batch size
            fps: Output video frame rate
        """

        print(f"[SadTalker] Processing: {source_image}")
        print(f"[SadTalker] Audio: {driven_audio}")

        # 1. Extract audio coefficients
        print("[SadTalker] Extracting audio features...")
        coeff_path = self.audio2coeff.generate(
            audio_path=driven_audio,
            save_dir=os.path.dirname(output_path)
        )

        # 2. Generate video
        print("[SadTalker] Generating video...")
        self.animate.generate(
            source_image=source_image,
            coeff_path=coeff_path,
            output_path=output_path,
            preprocess=preprocess,
            still_mode=still_mode,
            use_enhancer=use_enhancer,
            batch_size=batch_size,
            fps=fps
        )

        print(f"[SadTalker] ✓ Video saved: {output_path}")
        return output_path

# Example usage
if __name__ == "__main__":
    pipeline = SadTalkerPipeline()

    pipeline.generate(
        source_image="E:/ComfyUI-Easy-Install/ComfyUI/input/sage_portrait.png",
        driven_audio="E:/ComfyUI-Easy-Install/ComfyUI/input/sage_dialogue.wav",
        output_path="E:/ComfyUI-Easy-Install/ComfyUI/output/sage_talking.mp4",
        still_mode=False,      # Natural head movement
        use_enhancer=True,     # GFPGAN enhancement
        fps=25
    )
```

#### ComfyUI Workflow (SadTalker Node)

```json
{
  "1": {
    "class_type": "LoadImage",
    "inputs": {
      "image": "sage_portrait.png"
    }
  },
  "2": {
    "class_type": "LoadAudio",
    "inputs": {
      "audio": "sage_dialogue.wav"
    }
  },
  "3": {
    "class_type": "SadTalker",
    "inputs": {
      "source_image": ["1", 0],
      "driven_audio": ["2", 0],
      "preprocess": "crop",
      "still_mode": false,
      "use_enhancer": true,
      "expression_scale": 1.0,
      "fps": 25
    }
  },
  "4": {
    "class_type": "SaveVideo",
    "inputs": {
      "video": ["3", 0],
      "filename": "sage_talking",
      "fps": 25
    }
  }
}
```

#### Parameter Guide: SadTalker

| Parameter | Values | Effect |
|-----------|--------|--------|
| **preprocess** | 'crop', 'resize', 'full' | How to handle input image |
| **still_mode** | true/false | true = minimal movement, false = natural |
| **expression_scale** | 0.5-2.0 | Expression intensity (1.0 default) |
| **use_enhancer** | true/false | Apply GFPGAN face enhancement |
| **batch_size** | 1-8 | Higher = faster but more VRAM |
| **fps** | 24-30 | Output frame rate |

**Recommended Settings:**

```python
# Natural conversation (YouTube, podcast)
still_mode=False, expression_scale=1.0

# Professional presentation (corporate)
still_mode=True, expression_scale=0.8

# Animated character (exaggerated)
still_mode=False, expression_scale=1.5
```

---

### Method 1B: LivePortrait (Premium Quality)

**Best For:** Fine control over expressions, eye gaze, head pose

#### Installation

```bash
cd E:/ComfyUI-Easy-Install/ComfyUI/custom_nodes
git clone https://github.com/KwaiVGI/LivePortrait

cd LivePortrait
pip install -r requirements.txt
python scripts/download_models.py
```

#### Python Script

```python
#!/usr/bin/env python3
"""
LivePortrait: Advanced Talking Head Generation
Fine control over expressions, eye gaze, and head movements
"""

import sys
sys.path.append('E:/ComfyUI-Easy-Install/ComfyUI/custom_nodes/LivePortrait')

from liveportrait.live_portrait_pipeline import LivePortraitPipeline

class LivePortraitGenerator:
    def __init__(self):
        self.pipeline = LivePortraitPipeline(
            model_path='checkpoints/liveportrait',
            device='cuda'
        )

    def generate(
        self,
        source_image,
        driving_audio,
        output_path,
        expression_strength=1.0,
        head_pose_strength=1.0,
        eye_retargeting=True,
        lip_retargeting=True,
        fps=25
    ):
        """
        Generate talking head with fine control

        Args:
            source_image: Portrait image path
            driving_audio: Audio file path
            output_path: Output video path
            expression_strength: Expression intensity (0-2)
            head_pose_strength: Head movement intensity (0-2)
            eye_retargeting: Enable eye movement
            lip_retargeting: Enable lip-sync
            fps: Output frame rate
        """

        print(f"[LivePortrait] Processing: {source_image}")

        result = self.pipeline.execute(
            source_image=source_image,
            driving_audio=driving_audio,
            output_path=output_path,
            flag_pasteback=True,           # Paste face back to original
            flag_do_crop=True,             # Crop face region
            flag_stitching=True,           # Smooth face boundary
            expression_friendly=expression_strength,
            pose_friendly=head_pose_strength,
            flag_eye_retargeting=eye_retargeting,
            flag_lip_retargeting=lip_retargeting,
            fps=fps
        )

        print(f"[LivePortrait] ✓ Video saved: {output_path}")
        return output_path

# Example usage
if __name__ == "__main__":
    generator = LivePortraitGenerator()

    generator.generate(
        source_image="E:/ComfyUI-Easy-Install/ComfyUI/input/character.png",
        driving_audio="E:/ComfyUI-Easy-Install/ComfyUI/input/dialogue.wav",
        output_path="E:/ComfyUI-Easy-Install/ComfyUI/output/character_talking.mp4",
        expression_strength=1.2,    # Slightly exaggerated
        head_pose_strength=0.8,     # Subtle head movement
        eye_retargeting=True,       # Natural eye movement
        lip_retargeting=True        # Precise lip-sync
    )
```

---

### Method 1C: EMO (State-of-Art 2024)

**Best For:** Most natural results, viral quality demos

**Note:** EMO is research code, less production-ready than SadTalker/LivePortrait

```python
# EMO is typically run via research codebase
# Not recommended for production yet but worth monitoring
# See: https://github.com/HumanAIGC/EMO
```

---

## Approach 2: Video → Add Voice/Lip-Sync

**Use Case:** Add voice/dialogue to existing video footage.

**Input:** Video (any source) + audio file
**Output:** Same video with synchronized lip movements
**Time:** 1-3 minutes per 10-second clip

### Method 2A: Wav2Lip (Industry Standard)

**Best For:** Best lip-sync accuracy, works with any video

#### Installation

```bash
cd E:/ComfyUI-Easy-Install/ComfyUI/custom_nodes
git clone https://github.com/Rudrabha/Wav2Lip

cd Wav2Lip
pip install -r requirements.txt

# Download checkpoint
# Manual download: https://github.com/Rudrabha/Wav2Lip
# Place in: Wav2Lip/checkpoints/wav2lip_gan.pth
```

#### Python Script

```python
#!/usr/bin/env python3
"""
Wav2Lip: Add Lip-Sync to Existing Video
Industry-standard lip synchronization for any video
"""

import sys
import subprocess
import os

class Wav2LipPipeline:
    def __init__(self, wav2lip_path='E:/ComfyUI-Easy-Install/ComfyUI/custom_nodes/Wav2Lip'):
        self.wav2lip_path = wav2lip_path
        self.checkpoint = os.path.join(wav2lip_path, 'checkpoints/wav2lip_gan.pth')

    def apply_lipsync(
        self,
        video_path,
        audio_path,
        output_path,
        quality='improved',  # 'improved' or 'enhanced'
        face_det_batch_size=16,
        wav2lip_batch_size=128,
        resize_factor=1,
        fps=25
    ):
        """
        Apply lip-sync to video

        Args:
            video_path: Input video with face(s)
            audio_path: Audio to sync (.wav recommended)
            output_path: Output synced video
            quality: 'improved' (GAN) or 'enhanced' (expert discriminator)
            face_det_batch_size: Face detection batch (lower if OOM)
            wav2lip_batch_size: Processing batch (lower if OOM)
            resize_factor: Resize input (1=original, 2=half size)
            fps: Output frame rate
        """

        print(f"[Wav2Lip] Syncing: {video_path}")
        print(f"[Wav2Lip] Audio: {audio_path}")

        # Build command
        cmd = [
            'python',
            os.path.join(self.wav2lip_path, 'inference.py'),
            '--checkpoint_path', self.checkpoint,
            '--face', video_path,
            '--audio', audio_path,
            '--outfile', output_path,
            '--fps', str(fps),
            '--face_det_batch_size', str(face_det_batch_size),
            '--wav2lip_batch_size', str(wav2lip_batch_size),
            '--resize_factor', str(resize_factor)
        ]

        if quality == 'improved':
            cmd.append('--nosmooth')  # GAN checkpoint

        # Run Wav2Lip
        result = subprocess.run(cmd, cwd=self.wav2lip_path, capture_output=True)

        if result.returncode == 0:
            print(f"[Wav2Lip] ✓ Synced video saved: {output_path}")
            return output_path
        else:
            print(f"[Wav2Lip] ✗ Error: {result.stderr.decode()}")
            raise RuntimeError("Wav2Lip failed")

# Example usage
if __name__ == "__main__":
    pipeline = Wav2LipPipeline()

    # Apply lip-sync to existing video
    pipeline.apply_lipsync(
        video_path="E:/ComfyUI-Easy-Install/ComfyUI/output/sage_video_clip1.mp4",
        audio_path="E:/ComfyUI-Easy-Install/ComfyUI/input/sage_dialogue.wav",
        output_path="E:/ComfyUI-Easy-Install/ComfyUI/output/sage_lipsync_clip1.mp4",
        quality='improved',
        face_det_batch_size=16,
        wav2lip_batch_size=128,
        fps=25
    )
```

#### Full Production Pipeline: Video → Voice → Enhance

```python
#!/usr/bin/env python3
"""
Complete Production Pipeline: Existing Video → Voice → Lip-Sync → Enhance
For adding professional dialogue to pre-generated video clips
"""

import os
from pathlib import Path

# Import previous components
from wav2lip_pipeline import Wav2LipPipeline

class VideoVoicePipeline:
    def __init__(self):
        self.wav2lip = Wav2LipPipeline()

    def enhance_faces(self, video_path, output_path, fidelity=0.7):
        """
        Enhance face quality with CodeFormer

        Args:
            video_path: Input video (after Wav2Lip)
            output_path: Enhanced output video
            fidelity: Balance between quality and fidelity (0.5-1.0)
                     0.5 = creative quality, 1.0 = exact restoration
        """
        print(f"[CodeFormer] Enhancing faces: {video_path}")

        import subprocess

        cmd = [
            'python',
            'E:/ComfyUI-Easy-Install/ComfyUI/custom_nodes/CodeFormer/inference_codeformer.py',
            '-i', video_path,
            '-o', output_path,
            '--fidelity_weight', str(fidelity),
            '--bg_upsampler', 'realesrgan',  # Background upscaling
            '--face_upsample',
            '--draw_box',
            '--detection_model', 'retinaface'
        ]

        result = subprocess.run(cmd, capture_output=True)

        if result.returncode == 0:
            print(f"[CodeFormer] ✓ Enhanced video: {output_path}")
            return output_path
        else:
            print(f"[CodeFormer] Warning: Enhancement may have issues")
            return output_path

    def process_clip(
        self,
        video_path,
        audio_path,
        output_dir,
        clip_name,
        enhance=True,
        fidelity=0.7
    ):
        """
        Complete pipeline for one video clip

        Args:
            video_path: Input video clip
            audio_path: Dialogue audio
            output_dir: Output directory
            clip_name: Base filename
            enhance: Apply CodeFormer enhancement
            fidelity: CodeFormer fidelity weight

        Returns:
            Path to final video
        """

        os.makedirs(output_dir, exist_ok=True)

        # Step 1: Apply lip-sync
        lipsync_path = os.path.join(output_dir, f"{clip_name}_lipsync.mp4")
        self.wav2lip.apply_lipsync(
            video_path=video_path,
            audio_path=audio_path,
            output_path=lipsync_path,
            quality='improved'
        )

        if not enhance:
            return lipsync_path

        # Step 2: Enhance faces
        final_path = os.path.join(output_dir, f"{clip_name}_final.mp4")
        self.enhance_faces(
            video_path=lipsync_path,
            output_path=final_path,
            fidelity=fidelity
        )

        return final_path

    def process_batch(self, video_audio_pairs, output_dir):
        """
        Process multiple video clips

        Args:
            video_audio_pairs: List of (video_path, audio_path, clip_name) tuples
            output_dir: Output directory

        Returns:
            List of final video paths
        """

        results = []

        for i, (video, audio, name) in enumerate(video_audio_pairs):
            print(f"\n[Batch] Processing {i+1}/{len(video_audio_pairs)}: {name}")

            final = self.process_clip(
                video_path=video,
                audio_path=audio,
                output_dir=output_dir,
                clip_name=name,
                enhance=True
            )

            results.append(final)
            print(f"[Batch] ✓ Completed: {final}")

        return results

# Example usage: Process 5 Sage video clips
if __name__ == "__main__":
    pipeline = VideoVoicePipeline()

    # Define your video/audio pairs
    clips = [
        ("output/sage_clip1.mp4", "input/audio/sage_dialogue1.wav", "sage_01"),
        ("output/sage_clip2.mp4", "input/audio/sage_dialogue2.wav", "sage_02"),
        ("output/sage_clip3.mp4", "input/audio/sage_dialogue3.wav", "sage_03"),
        ("output/sage_clip4.mp4", "input/audio/sage_dialogue4.wav", "sage_04"),
        ("output/sage_clip5.mp4", "input/audio/sage_dialogue5.wav", "sage_05"),
    ]

    # Process all clips
    final_videos = pipeline.process_batch(
        video_audio_pairs=clips,
        output_dir="E:/ComfyUI-Easy-Install/ComfyUI/output/sage_final"
    )

    print("\n[Complete] All clips processed:")
    for video in final_videos:
        print(f"  - {video}")

    # Next step: Concatenate with scripts/video/concat_videos.py
```

#### Wav2Lip Parameter Guide

| Parameter | Values | Effect |
|-----------|--------|--------|
| **quality** | 'improved', 'enhanced' | GAN vs expert discriminator |
| **face_det_batch_size** | 4-32 | Face detection batch (lower if OOM) |
| **wav2lip_batch_size** | 32-256 | Wav2Lip batch (higher = faster) |
| **resize_factor** | 1-4 | Input resize (2 = half size) |
| **fps** | 24-30 | Output frame rate |

**VRAM Requirements:**
- 6GB: `face_det_batch_size=4, wav2lip_batch_size=32, resize_factor=2`
- 12GB: `face_det_batch_size=8, wav2lip_batch_size=64, resize_factor=1`
- 24GB+: `face_det_batch_size=16, wav2lip_batch_size=128, resize_factor=1`

---

### Method 2B: MuseTalk (Faster Alternative)

**Best For:** Real-time processing, lower VRAM usage

```python
#!/usr/bin/env python3
"""
MuseTalk: Faster Lip-Sync Alternative
Lower VRAM, faster inference than Wav2Lip
"""

# Installation
# pip install musetalk

from musetalk import MuseTalkModel

class MuseTalkPipeline:
    def __init__(self):
        self.model = MuseTalkModel(device='cuda')

    def apply_lipsync(self, video_path, audio_path, output_path):
        """Apply lip-sync with MuseTalk"""

        result = self.model.inference(
            video_path=video_path,
            audio_path=audio_path,
            output_path=output_path
        )

        return output_path

# Usage
pipeline = MuseTalkPipeline()
pipeline.apply_lipsync(
    video_path="input.mp4",
    audio_path="audio.wav",
    output_path="output.mp4"
)
```

**MuseTalk vs Wav2Lip:**
- ✅ Faster (3-5x speed)
- ✅ Lower VRAM (6GB vs 12GB)
- ❌ Slightly less accurate sync
- ❌ Less battle-tested

---

## Hybrid Approach

For **maximum production quality**, combine both methods:

### Workflow: Video + Selective Talking Head Enhancement

```python
#!/usr/bin/env python3
"""
Hybrid: Use video motion + add talking head refinement for speaking sections
Best of both worlds
"""

import cv2
import numpy as np
from pathlib import Path

class HybridPipeline:
    def __init__(self):
        from sadtalker_pipeline import SadTalkerPipeline
        from wav2lip_pipeline import Wav2LipPipeline

        self.sadtalker = SadTalkerPipeline()
        self.wav2lip = Wav2LipPipeline()

    def process_hybrid(
        self,
        base_video,
        character_portrait,
        audio_segments,  # List of (start_time, end_time, audio_file)
        output_path
    ):
        """
        Apply SadTalker to specific speaking segments, Wav2Lip to full video

        Args:
            base_video: Full video with motion
            character_portrait: Character headshot
            audio_segments: Speaking segments with timestamps
            output_path: Final video output
        """

        # Step 1: Apply Wav2Lip to full video for baseline sync
        full_audio = self._combine_audio_segments(audio_segments)
        baseline_sync = "temp_baseline_sync.mp4"

        self.wav2lip.apply_lipsync(
            video_path=base_video,
            audio_path=full_audio,
            output_path=baseline_sync
        )

        # Step 2: Generate high-quality talking segments with SadTalker
        talking_segments = []
        for start, end, audio_file in audio_segments:
            segment_video = f"temp_segment_{start}_{end}.mp4"

            self.sadtalker.generate(
                source_image=character_portrait,
                driven_audio=audio_file,
                output_path=segment_video
            )

            talking_segments.append((start, end, segment_video))

        # Step 3: Composite - replace speaking sections with SadTalker output
        self._composite_segments(
            base_video=baseline_sync,
            talking_segments=talking_segments,
            output_path=output_path
        )

        return output_path
```

This is **advanced production technique** - most users should stick to Approach 1 or 2.

---

## Parameter Reference

### When to Use Each Method

| Scenario | Method | Why |
|----------|--------|-----|
| Static camera, simple dialogue | SadTalker (Approach 1) | Simplest, good results |
| Need eye gaze, expression control | LivePortrait (Approach 1) | Fine control |
| Existing video, add voice | Wav2Lip (Approach 2) | Preserves motion |
| Real-time/low VRAM | MuseTalk (Approach 2) | Faster, lighter |
| Maximum quality | Hybrid | Combines strengths |

### Quality vs Speed Tradeoffs

**Fastest → Slowest (for 10-second clip):**
1. MuseTalk: ~30 seconds
2. Wav2Lip: ~60 seconds
3. SadTalker: ~120 seconds
4. LivePortrait: ~180 seconds
5. Hybrid: ~300 seconds

**Quality Ranking (subjective):**
1. Hybrid (best)
2. LivePortrait
3. SadTalker
4. Wav2Lip
5. MuseTalk (still good)

### VRAM Requirements Summary

| Method | Minimum VRAM | Recommended | Batch Settings |
|--------|--------------|-------------|----------------|
| SadTalker | 8GB | 12GB | batch_size=2 |
| LivePortrait | 10GB | 16GB | Default |
| Wav2Lip | 6GB | 12GB | batch_size=32 |
| MuseTalk | 4GB | 8GB | Default |

---

## Troubleshooting

### Issue: Face Not Detected

**Symptoms:** "No face found in image/video"

**Solutions:**
1. Ensure face is clearly visible, front-facing
2. Increase image resolution (min 512×512)
3. Use `preprocess='crop'` to auto-detect face region
4. Try different face detection models (retinaface, blazeface)

```python
# SadTalker: Try different preprocess modes
preprocess='crop'   # Auto-detect and crop face (recommended)
preprocess='full'   # Use entire image
preprocess='resize' # Resize to expected size
```

### Issue: Blurry/Low Quality Output

**Symptoms:** Output video looks blurry or degraded

**Solutions:**
1. **Always use CodeFormer** after Wav2Lip:
   ```python
   self.enhance_faces(video_path, output_path, fidelity=0.7)
   ```

2. **Adjust fidelity weight:**
   - `fidelity=0.5`: More enhancement, less faithful
   - `fidelity=0.7`: Balanced (recommended)
   - `fidelity=1.0`: Most faithful, least enhancement

3. **Use higher input resolution:**
   - Source image: 1024×1024 minimum
   - Video: 1080p minimum

4. **SadTalker: Enable enhancer:**
   ```python
   use_enhancer=True  # Applies GFPGAN
   ```

### Issue: Lip-Sync Accuracy Poor

**Symptoms:** Lips don't match audio timing

**Solutions:**

1. **Check audio quality:**
   - Use clean audio without background noise
   - Ensure clear speech, not overlapping
   - Use .wav format (44.1kHz, 16-bit)

2. **Wav2Lip: Adjust batch sizes:**
   ```python
   # Larger batch = more context = better sync
   wav2lip_batch_size=128  # Try 256 if you have VRAM
   ```

3. **Try different quality modes:**
   ```python
   quality='improved'  # GAN (better quality)
   quality='enhanced'  # Expert discriminator (better sync)
   ```

4. **Frame rate match:**
   - Ensure video and output fps match (25 or 30)
   - Don't mix frame rates

### Issue: Head Movement Too Stiff/Unnatural

**Symptoms:** SadTalker output looks robotic

**Solutions:**

1. **Disable still_mode:**
   ```python
   still_mode=False  # Allows natural movement
   ```

2. **Increase expression scale:**
   ```python
   expression_scale=1.2  # More expressive (range: 0.5-2.0)
   ```

3. **Try LivePortrait for more control:**
   ```python
   head_pose_strength=1.0  # Natural head movement
   expression_strength=1.2  # Expressive faces
   ```

### Issue: Out of Memory (OOM)

**Symptoms:** CUDA out of memory error

**Solutions:**

1. **Reduce batch sizes:**
   ```python
   # SadTalker
   batch_size=1  # Minimum

   # Wav2Lip
   face_det_batch_size=4
   wav2lip_batch_size=16
   ```

2. **Resize input:**
   ```python
   # Wav2Lip
   resize_factor=2  # Half resolution
   ```

3. **Process shorter segments:**
   - Split video into 10-second clips
   - Process individually
   - Concatenate after

4. **Enable gradient checkpointing (if available):**
   ```python
   use_gradient_checkpointing=True
   ```

### Issue: Audio-Video Desync Over Time

**Symptoms:** Sync is good at start but drifts by end

**Solutions:**

1. **Match frame rates exactly:**
   - Check input video fps: `ffprobe input.mp4`
   - Set output fps to match: `fps=25` or `fps=30`

2. **Re-encode audio to exact duration:**
   ```bash
   # Get video duration
   duration=$(ffprobe -v error -show_entries format=duration \
              -of default=noprint_wrappers=1:nokey=1 input.mp4)

   # Stretch/compress audio to match
   ffmpeg -i audio.wav -af atempo=$tempo -t $duration output.wav
   ```

3. **Use constant frame rate video:**
   ```bash
   # Convert variable frame rate to constant
   ffmpeg -i input.mp4 -vsync cfr -r 25 output.mp4
   ```

### Issue: Face Replacement Visible/Jarring

**Symptoms:** Can see edges of face replacement, doesn't blend

**Solutions:**

1. **Enable stitching (LivePortrait):**
   ```python
   flag_stitching=True  # Smooth boundaries
   flag_pasteback=True  # Blend with original
   ```

2. **Use feathering:**
   ```python
   # Post-process with face boundary blur
   import cv2

   # Apply Gaussian blur to face mask edges
   mask = create_face_mask(frame)
   mask_blurred = cv2.GaussianBlur(mask, (21, 21), 11)
   ```

3. **Match color/lighting:**
   - Apply color correction to match original
   - Use histogram matching for lighting consistency

---

## Next Steps After Generation

After generating talking head videos:

1. **Concatenate clips** (if multiple):
   ```bash
   python E:/ComfyUI-Easy-Install/ComfyUI/scripts/video/concat_videos.py
   ```

2. **Add music/background audio**:
   ```bash
   ffmpeg -i video.mp4 -i music.mp3 -c:v copy \
          -filter_complex "[0:a][1:a]amerge=inputs=2[a]" \
          -map 0:v -map "[a]" output.mp4
   ```

3. **Color grading** (optional):
   - Use DaVinci Resolve (free)
   - Or ffmpeg LUTs

4. **Add subtitles** (recommended):
   - Use Whisper for transcription
   - Burn-in with ffmpeg

5. **Export for platform**:
   - YouTube: H.264, 1080p, 25fps
   - Instagram: H.264, 1080×1350, 30fps
   - TikTok: H.264, 1080×1920, 30fps

---

## Production Checklist

Before deploying workflows:

- [ ] Test on 5-second clips first
- [ ] Verify face detection works on all frames
- [ ] Check audio is clean (no background noise)
- [ ] Match frame rates (video and output)
- [ ] Use proper audio format (.wav, 44.1kHz)
- [ ] Apply enhancement (CodeFormer) after Wav2Lip
- [ ] Validate output quality on target platform
- [ ] Batch process efficiently (don't overload GPU)
- [ ] Keep checkpoints/models organized
- [ ] Test full pipeline end-to-end before batch

---

## References

- SadTalker: https://github.com/Winfredy/SadTalker
- LivePortrait: https://github.com/KwaiVGI/LivePortrait
- Wav2Lip: https://github.com/Rudrabha/Wav2Lip
- MuseTalk: https://github.com/TMElyralab/MuseTalk
- CodeFormer: https://github.com/sczhou/CodeFormer
- EMO (research): https://github.com/HumanAIGC/EMO

**Last Updated:** February 2026
