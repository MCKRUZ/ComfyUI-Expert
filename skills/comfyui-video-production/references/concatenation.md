# Video Concatenation & Transitions

Professional video stitching with FFmpeg, including transition effects, audio handling, and quality preservation.

---

## Basic Concatenation

### Method 1: FFmpeg Concat Demuxer (Recommended)

**Use when:** All clips have same codec, resolution, FPS

```bash
# 1. Create concat list file
cat > concat_list.txt << EOF
file '/path/to/clip_001.mp4'
file '/path/to/clip_002.mp4'
file '/path/to/clip_003.mp4'
EOF

# 2. Concatenate (no re-encoding - fast!)
ffmpeg -f concat -safe 0 -i concat_list.txt -c copy output.mp4
```

**Pros:** Ultra-fast (no re-encoding), perfect quality preservation
**Cons:** Requires identical encoding parameters

### Method 2: Re-encode Concatenation

**Use when:** Clips have different codecs/settings, or adding transitions

```bash
ffmpeg -i clip_001.mp4 -i clip_002.mp4 -i clip_003.mp4 \
  -filter_complex "[0:v][1:v][2:v]concat=n=3:v=1:a=0[outv]" \
  -map "[outv]" \
  -c:v libx264 -preset slow -crf 18 \
  output.mp4
```

**Pros:** Handles any input, allows filtering
**Cons:** Slower, potential quality loss

---

## Transition Effects

### Crossfade Transition

```bash
# 2 clips with 1-second crossfade
ffmpeg -i clip1.mp4 -i clip2.mp4 \
  -filter_complex \
  "[0:v][1:v]xfade=transition=fade:duration=1:offset=4[outv]" \
  -map "[outv]" \
  -c:v libx264 -crf 18 \
  output.mp4
```

**Transition types for xfade:**
- `fade` - Simple crossfade (most common)
- `wipeleft` - Wipe from right to left
- `wiperight` - Wipe from left to right
- `wipeup` - Wipe from bottom to top
- `wipedown` - Wipe from top to bottom
- `slideleft` - Slide transition to left
- `slideright` - Slide transition to right
- `circlecrop` - Circular reveal
- `rectcrop` - Rectangular reveal
- `distance` - Smooth morph
- `fadeblack` - Fade to black then in

### Multiple Clips with Crossfades

```python
#!/usr/bin/env python3
"""Generate FFmpeg command for N clips with crossfades"""

def generate_crossfade_command(clips, fade_duration=0.5, output="final.mp4"):
    """
    Generate FFmpeg command for multiple clips with crossfades

    Args:
        clips: List of video file paths
        fade_duration: Transition duration in seconds
        output: Output filename
    """
    n = len(clips)

    # Build input arguments
    inputs = " ".join([f"-i {clip}" for clip in clips])

    # Build filter complex
    filter_parts = []

    # Calculate offsets (each clip minus fade duration)
    # Assume each clip is same duration
    clip_duration = 5  # seconds (adjust as needed)
    offset = clip_duration - fade_duration

    current_label = "0:v"
    for i in range(1, n):
        next_input = f"{i}:v"
        current_offset = offset * i
        temp_label = f"v{i}"

        fade_filter = (
            f"[{current_label}][{next_input}]"
            f"xfade=transition=fade:"
            f"duration={fade_duration}:"
            f"offset={current_offset}[{temp_label}]"
        )

        filter_parts.append(fade_filter)
        current_label = temp_label

    filter_complex = ";".join(filter_parts)

    # Build final command
    cmd = (
        f"ffmpeg {inputs} "
        f'-filter_complex "{filter_complex}" '
        f"-map '[{current_label}]' "
        f"-c:v libx264 -preset slow -crf 18 "
        f"{output}"
    )

    return cmd

# Example usage
clips = [
    "clip_001.mp4",
    "clip_002.mp4",
    "clip_003.mp4",
    "clip_004.mp4",
    "clip_005.mp4"
]

command = generate_crossfade_command(clips, fade_duration=0.5)
print(command)
```

---

## Advanced Transitions

### Zoom Transition

```bash
# Zoom in from clip1 to clip2
ffmpeg -i clip1.mp4 -i clip2.mp4 \
  -filter_complex \
  "[0:v]scale=iw*1.2:ih*1.2,crop=iw/1.2:ih/1.2:(iw-ow)/2:(ih-oh)/2[v0]; \
   [v0][1:v]xfade=transition=fade:duration=1:offset=4[outv]" \
  -map "[outv]" \
  -c:v libx264 -crf 18 \
  output.mp4
```

### Motion Blur Transition

```bash
# Add motion blur during transition
ffmpeg -i clip1.mp4 -i clip2.mp4 \
  -filter_complex \
  "[0:v]minterpolate=fps=60:mi_mode=mci[v0]; \
   [v0][1:v]xfade=transition=fade:duration=0.5:offset=4[outv]" \
  -map "[outv]" \
  -r 30 \
  -c:v libx264 -crf 18 \
  output.mp4
```

### Fade to Black Transition

```bash
# Fade clip1 to black, then fade in clip2
ffmpeg -i clip1.mp4 -i clip2.mp4 \
  -filter_complex \
  "[0:v]fade=t=out:st=4:d=0.5[v0]; \
   [1:v]fade=t=in:st=0:d=0.5[v1]; \
   [v0][v1]concat=n=2:v=1:a=0[outv]" \
  -map "[outv]" \
  -c:v libx264 -crf 18 \
  output.mp4
```

---

## Audio Handling

### Concatenate with Audio

```bash
# Concat with both video and audio
ffmpeg -f concat -safe 0 -i concat_list.txt \
  -c:v copy -c:a copy \
  output.mp4
```

### Crossfade Audio During Video Transitions

```bash
ffmpeg -i clip1.mp4 -i clip2.mp4 \
  -filter_complex \
  "[0:v][1:v]xfade=transition=fade:duration=1:offset=4[outv]; \
   [0:a][1:a]acrossfade=d=1[outa]" \
  -map "[outv]" -map "[outa]" \
  -c:v libx264 -crf 18 -c:a aac \
  output.mp4
```

### Add Background Music

```bash
# Add music to silent video
ffmpeg -i video.mp4 -i music.mp3 \
  -c:v copy -c:a aac \
  -shortest \
  output.mp4

# Mix existing audio with music
ffmpeg -i video.mp4 -i music.mp3 \
  -filter_complex \
  "[0:a][1:a]amix=inputs=2:duration=first:dropout_transition=2[aout]" \
  -map 0:v -map "[aout]" \
  -c:v copy -c:a aac \
  output.mp4
```

---

## Quality Preservation

### High-Quality Encoding Settings

```bash
# h264 (most compatible)
ffmpeg -i input.mp4 \
  -c:v libx264 \
  -preset slow \          # slow = better compression
  -crf 18 \               # 18 = visually lossless
  -pix_fmt yuv420p \      # ensure compatibility
  -movflags +faststart \  # web streaming optimization
  output.mp4

# h265 (better compression, less compatible)
ffmpeg -i input.mp4 \
  -c:v libx265 \
  -preset slow \
  -crf 20 \               # 20 for h265 ≈ 18 for h264
  -pix_fmt yuv420p \
  output.mp4
```

### Resolution & FPS Enforcement

```bash
# Force resolution and FPS
ffmpeg -i input.mp4 \
  -vf "scale=768:1024:force_original_aspect_ratio=decrease,pad=768:1024:(ow-iw)/2:(oh-ih)/2" \
  -r 25 \
  -c:v libx264 -crf 18 \
  output.mp4
```

---

## Validation Before Concatenation

### Pre-Flight Check Script

```python
#!/usr/bin/env python3
"""Validate clips before concatenation"""

import subprocess
import json

def get_video_info(video_path):
    """Extract video metadata using ffprobe"""
    cmd = [
        'ffprobe', '-v', 'error',
        '-select_streams', 'v:0',
        '-show_entries', 'stream=width,height,r_frame_rate,codec_name,duration',
        '-of', 'json',
        video_path
    ]

    result = subprocess.run(cmd, capture_output=True, text=True)
    data = json.loads(result.stdout)

    stream = data['streams'][0]

    # Parse frame rate
    fps_str = stream['r_frame_rate']
    num, den = map(int, fps_str.split('/'))
    fps = num / den

    return {
        'width': stream['width'],
        'height': stream['height'],
        'fps': round(fps, 2),
        'codec': stream['codec_name'],
        'duration': float(stream.get('duration', 0))
    }

def validate_clips_for_concat(clips):
    """Check if clips can be safely concatenated"""
    issues = []
    info_list = []

    for clip in clips:
        try:
            info = get_video_info(clip)
            info_list.append(info)
        except Exception as e:
            issues.append(f"{clip}: Failed to read ({e})")
            return False, issues

    # Check consistency
    reference = info_list[0]

    for i, info in enumerate(info_list[1:], 1):
        if info['width'] != reference['width'] or info['height'] != reference['height']:
            issues.append(
                f"Clip {i}: Resolution mismatch "
                f"({info['width']}x{info['height']} vs {reference['width']}x{reference['height']})"
            )

        if abs(info['fps'] - reference['fps']) > 0.1:
            issues.append(
                f"Clip {i}: FPS mismatch "
                f"({info['fps']} vs {reference['fps']})"
            )

        if info['codec'] != reference['codec']:
            issues.append(
                f"Clip {i}: Codec mismatch "
                f"({info['codec']} vs {reference['codec']})"
            )

    if issues:
        return False, issues
    else:
        return True, info_list

# Example usage
clips = ['clip_001.mp4', 'clip_002.mp4', 'clip_003.mp4']
valid, result = validate_clips_for_concat(clips)

if valid:
    print("✓ All clips compatible for concatenation")
    print(f"Resolution: {result[0]['width']}x{result[0]['height']}")
    print(f"FPS: {result[0]['fps']}")
    print(f"Codec: {result[0]['codec']}")
else:
    print("✗ Clips incompatible:")
    for issue in result:
        print(f"  - {issue}")
```

---

## Production Pipeline

### Complete Concatenation Script

```python
#!/usr/bin/env python3
"""Production-ready video concatenation with transitions"""

import subprocess
import os
import json
from pathlib import Path

class VideoConcatenator:
    def __init__(self, output_dir="output"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)

    def validate_clips(self, clips):
        """Validate all clips before processing"""
        print("[Validation] Checking clips...")

        valid, result = validate_clips_for_concat(clips)

        if not valid:
            print("[Validation] ✗ FAILED")
            for issue in result:
                print(f"  {issue}")
            return False

        print("[Validation] ✓ All clips compatible")
        return True

    def concatenate_simple(self, clips, output_name="combined.mp4"):
        """Simple concatenation without transitions (fast)"""
        concat_file = self.output_dir / "concat_list.txt"

        with open(concat_file, 'w') as f:
            for clip in clips:
                abs_path = Path(clip).resolve()
                f.write(f"file '{abs_path}'\n")

        output_path = self.output_dir / output_name

        cmd = [
            'ffmpeg', '-y',
            '-f', 'concat',
            '-safe', '0',
            '-i', str(concat_file),
            '-c', 'copy',
            str(output_path)
        ]

        print(f"[Concat] Combining {len(clips)} clips...")
        subprocess.run(cmd, check=True, capture_output=True)

        concat_file.unlink()  # Cleanup

        print(f"[Concat] ✓ Output: {output_path}")
        return output_path

    def concatenate_with_transitions(
        self,
        clips,
        fade_duration=0.5,
        output_name="combined_transitions.mp4"
    ):
        """Concatenation with crossfade transitions (slower)"""
        print(f"[Concat] Applying {fade_duration}s crossfades...")

        output_path = self.output_dir / output_name

        # Build FFmpeg command
        inputs = []
        for clip in clips:
            inputs.extend(['-i', clip])

        # Generate filter complex
        filter_parts = []
        current_label = "0:v"

        # Calculate clip duration (assume all clips same duration)
        duration_cmd = [
            'ffprobe', '-v', 'error',
            '-show_entries', 'format=duration',
            '-of', 'default=noprint_wrappers=1:nokey=1',
            clips[0]
        ]
        duration = float(subprocess.run(duration_cmd, capture_output=True, text=True).stdout.strip())
        offset = duration - fade_duration

        for i in range(1, len(clips)):
            next_input = f"{i}:v"
            current_offset = offset * i
            temp_label = f"v{i}"

            fade_filter = (
                f"[{current_label}][{next_input}]"
                f"xfade=transition=fade:duration={fade_duration}:offset={current_offset}[{temp_label}]"
            )

            filter_parts.append(fade_filter)
            current_label = temp_label

        filter_complex = ";".join(filter_parts)

        cmd = [
            'ffmpeg', '-y',
            *inputs,
            '-filter_complex', filter_complex,
            '-map', f'[{current_label}]',
            '-c:v', 'libx264',
            '-preset', 'slow',
            '-crf', '18',
            '-pix_fmt', 'yuv420p',
            '-movflags', '+faststart',
            str(output_path)
        ]

        subprocess.run(cmd, check=True, capture_output=True)

        print(f"[Concat] ✓ Output: {output_path}")
        return output_path

# Example usage
if __name__ == "__main__":
    clips = [
        "E:/ComfyUI/output/clip_001.mp4",
        "E:/ComfyUI/output/clip_002.mp4",
        "E:/ComfyUI/output/clip_003.mp4"
    ]

    concatenator = VideoConcatenator(output_dir="E:/ComfyUI/output/final")

    if concatenator.validate_clips(clips):
        # Method 1: Fast, no transitions
        # concatenator.concatenate_simple(clips, "sage_video_final.mp4")

        # Method 2: With transitions
        concatenator.concatenate_with_transitions(
            clips,
            fade_duration=0.5,
            output_name="sage_video_final.mp4"
        )
```

---

## Troubleshooting

### Issue: "Non-monotonous DTS in output stream"
**Fix:** Re-encode instead of using `-c copy`

### Issue: Audio/video out of sync
**Fix:** Use `-async 1` or `-vsync 2`

### Issue: Transitions look jerky
**Fix:** Increase transition duration or use motion blur

### Issue: File size too large
**Fix:** Lower CRF value (higher compression) or reduce resolution

### Issue: Clips have different resolutions
**Fix:** Scale all to same resolution before concatenation:
```bash
ffmpeg -i input.mp4 -vf scale=768:1024 -c:v libx264 -crf 18 output.mp4
```
