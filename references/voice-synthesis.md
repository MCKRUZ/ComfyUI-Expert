# Voice Synthesis & Lip-Sync Guide

Creating character voices and synchronizing them with video.

---

## Voice Creation Decision Tree

**Have reference audio of target voice?**
- Yes → Voice cloning (RVC, ElevenLabs, XTTS)
- No → Voice design or TTS with persona tuning

**Need commercial license?**
- Yes → Chatterbox (MIT), F5-TTS (MIT), ElevenLabs (paid)
- No → RVC, XTTS (non-commercial), any

**Quality priority vs speed?**
- Quality → ElevenLabs Professional, Chatterbox
- Speed → F5-TTS, StyleTTS2

---

## Voice Cloning Options

### Chatterbox (Recommended Open-Source)

**Why Chatterbox:**
- Beat ElevenLabs in 63.8% of blind preference tests
- MIT license (commercial use OK)
- Only needs 5-second voice sample
- Emotion exaggeration control
- Native paralinguistic tags ([laugh], [sigh], etc.)
- Sub-200ms latency

**Installation:**
```bash
pip install chatterbox-tts
```

**Basic usage:**
```python
from chatterbox import ChatterboxTTS

# Initialize
tts = ChatterboxTTS()

# Clone from audio file
tts.clone_voice("reference_audio.wav", voice_name="sage_voice")

# Generate speech
tts.synthesize(
    text="Hello, I'm Sage. *laughs* Nice to meet you.",
    voice="sage_voice",
    emotion_scale=1.2,  # 0.5-2.0, higher = more expressive
    output_path="output.wav"
)
```

**Emotion tags:**
```
[laugh] [chuckle] [sigh] [gasp] [cough] [clear throat]
[whisper] [excited] [sad] [angry] [surprised]
```

### F5-TTS

**Strengths:**
- Zero-shot cloning from seconds of audio
- Code-switching (multiple languages)
- Very fast (RTF 0.15)
- MIT license

**Installation:**
```bash
pip install f5-tts
```

**Usage:**
```python
from f5_tts import F5TTS

model = F5TTS()

# Generate with voice reference
audio = model.generate(
    text="This is Sage speaking.",
    ref_audio="voice_sample.wav",
    ref_text="Hello, my name is Sage.",  # Transcript of ref audio
    speed=1.0
)
audio.save("output.wav")
```

### RVC (Retrieval-based Voice Conversion)

**Use case:** Convert any voice to your target voice

**How it works:**
1. Train RVC model on 10+ minutes of target voice audio
2. Generate base speech with any TTS
3. Convert base speech through RVC to target voice

**Training requirements:**
- 10+ minutes of clean speech (ideally 30+ minutes)
- Single speaker only
- No background music/noise
- Consistent recording quality

**Training with RVC WebUI:**
```bash
# Clone RVC
git clone https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI
cd Retrieval-based-Voice-Conversion-WebUI

# Install
pip install -r requirements.txt

# Launch
python infer-web.py
```

**Training settings:**
```
Training epochs: 300-500
Batch size: Based on VRAM (8 for 8GB, 16 for 16GB)
Save frequency: Every 50 epochs
Feature extraction: RMVPE (best quality)
```

**Inference pipeline:**
```
[Text] → [Any TTS] → [Base Audio] → [RVC Model] → [Character Voice]
```

### XTTS-v2 (Coqui)

**Note:** Coqui shut down late 2024, but code is community-maintained.

**Strengths:**
- Clones from 6-second samples
- 17 language support
- <150ms streaming latency
- 85-95% similarity with 10 seconds

**Limitation:** Non-commercial license (CPML)

**Usage:**
```python
from TTS.api import TTS

tts = TTS("tts_models/multilingual/multi-dataset/xtts_v2")

tts.tts_to_file(
    text="Hello, I'm Sage.",
    speaker_wav="reference.wav",
    language="en",
    file_path="output.wav"
)
```

### ElevenLabs (Commercial)

**Tiers:**
- Instant Voice Cloning: 1-minute sample, good quality
- Professional Voice Cloning: 30+ minutes (3 hours ideal), near-indistinguishable

**Voice Design (no sample needed):**
```
Describe in 20-1000 characters:
"A warm, witty female voice in her late 20s. Slight Italian-American 
undertones. Confident but approachable. Quick, intelligent delivery 
with natural pauses. Occasionally playful. Sounds like she could be 
from Manhattan but educated at an Ivy League school."
```

**API usage:**
```python
from elevenlabs import generate, clone

# Clone voice
voice = clone(
    name="Sage",
    files=["sample1.mp3", "sample2.mp3", "sample3.mp3"]
)

# Generate
audio = generate(
    text="Hello, I'm Sage.",
    voice=voice,
    model="eleven_multilingual_v2"
)
```

---

## Creating Voice Without Reference Audio

### Option 1: Voice Design (ElevenLabs)

Write detailed description matching character:

**For Sage:**
```
"A sophisticated, warm female voice, late 20s. Italian-American heritage 
subtly evident in certain vowel sounds. Intelligent, quick-witted delivery 
with natural rhythm. Confident but not arrogant. Capable of sharp sarcasm 
but more often warm and engaging. Higher education background evident in 
vocabulary and diction. Think a young Diane Lane meets Marisa Tomei - 
East Coast, cultured, but with authentic warmth."
```

### Option 2: Find Similar Voice + RVC

1. Search ElevenLabs Voice Library (10,000+ voices)
2. Find voice with similar qualities
3. Use that as base, then train RVC on synthetic samples
4. Convert base voice through RVC for final output

### Option 3: StyleTTS2 with Persona Prompting

```python
from styletts2 import StyleTTS2

model = StyleTTS2()

# Use style reference audio that matches desired qualities
audio = model.synthesize(
    text="Hello, I'm Sage.",
    style_ref="warm_confident_female.wav",
    alpha=0.3,  # Style strength
    beta=0.7    # Prosody matching
)
```

---

## Lip-Sync Technologies

### Wav2Lip (Recommended for Accuracy)

**Strengths:**
- Best lip accuracy
- Works with any face
- Handles various angles

**Limitations:**
- Minimal head movement
- Requires face enhancement post-processing

**ComfyUI integration:**
```bash
# Install node
cd custom_nodes
git clone https://github.com/ShmuelRonen/ComfyUI_wav2lip
```

**Node settings:**
```
face_detect_batch: 16
nosmooth: false
wav2lip_model: "wav2lip_gan.pth"  # Better quality than wav2lip.pth
pad_bottom: 10  # Helps with chin visibility
```

**Post-processing (required):**
```
[Wav2Lip Output] → [CodeFormer (fidelity 0.7)] → [Final Video]
```

### SadTalker

**Strengths:**
- Generates head movement
- Creates expressions from audio
- Single image input

**Limitations:**
- Less accurate lips than Wav2Lip
- Can look artificial with extreme movements

**Command line:**
```bash
python inference.py \
    --driven_audio audio.wav \
    --source_image character.png \
    --preprocess full \
    --enhancer gfpgan \
    --pose_style 0
```

**Pose styles (0-45):**
- 0: Minimal movement
- 10-20: Natural conversation
- 30+: Expressive/animated

### LivePortrait

**Strengths:**
- Full expression control
- Pitch/yaw/roll adjustment
- Lip zero parameter reduces artifacts

**Best for:**
- Premium avatar creation
- Expression transfer from video
- Fine-grained control needs

**Key parameters:**
```
lip_zero: 0.03          # Reduces unnatural lip movements
stitching: true         # Seamless face blending
relative_motion_mode: "source_video_smoothed"
```

### MuseTalk (Tencent)

**Strengths:**
- Fast processing
- Good quality at 256×256 face region
- Real-time capable

**Best for:**
- Large volume processing
- Real-time applications

---

## Complete Talking Head Pipeline

### Pipeline A: Image → Talking Video (Simple)

```
1. Generate character audio
   [Text] → [Chatterbox/F5-TTS] → audio.wav

2. Apply lip-sync to still image
   [Character Image] + [audio.wav] → [SadTalker] → video.mp4

3. Enhance
   [video.mp4] → [GFPGAN/CodeFormer per frame] → final.mp4
```

**Best when:** Quick turnaround, acceptable head movement

### Pipeline B: Image → Video → Lip-Sync (Quality)

```
1. Generate base video with motion
   [Character Image] → [Wan I2V OR AnimateDiff] → base_video.mp4
   Prompt: "person talking, slight head movement, indoor"

2. Generate character audio
   [Text] → [Chatterbox] → audio.wav

3. Apply lip-sync to video
   [base_video.mp4] + [audio.wav] → [Wav2Lip] → lipsync.mp4

4. Enhance faces
   [lipsync.mp4] → [FaceDetailer batch] → enhanced.mp4

5. Final polish
   [enhanced.mp4] → [Color correct + Deflicker] → final.mp4
```

**Best when:** Production quality needed

### Pipeline C: Expression Transfer (Premium)

```
1. Record driving video (actor performing lines)
   [Actor Video] → driving.mp4

2. Generate character audio
   [Text] → [Voice Clone TTS] → audio.wav

3. Transfer expressions to character
   [Character Image] + [driving.mp4] → [LivePortrait] → expression_video.mp4

4. Apply precise lip-sync
   [expression_video.mp4] + [audio.wav] → [Wav2Lip] → lipsync.mp4

5. Enhance
   [lipsync.mp4] → [CodeFormer] → final.mp4
```

**Best when:** Maximum realism, acting performance needed

---

## Audio Requirements

### Recording Quality Guidelines

**For voice cloning source:**
- Sample rate: 44.1kHz or 48kHz
- Bit depth: 16-bit minimum, 24-bit preferred
- Format: WAV (uncompressed)
- Environment: Quiet room, minimal reverb
- Microphone: XLR condenser preferred, USB acceptable
- Distance: 6-12 inches from mic
- Pop filter: Recommended

**For TTS output (lip-sync input):**
- Sample rate: 16-24kHz (model dependent)
- Format: WAV
- Mono channel
- Trim leading silence
- Add 0.2s trailing silence
- Normalize to -3dB peak

### Audio Preprocessing

```python
import librosa
import soundfile as sf

# Load and preprocess
audio, sr = librosa.load("raw.wav", sr=24000, mono=True)

# Trim silence
audio_trimmed, _ = librosa.effects.trim(audio, top_db=20)

# Normalize
audio_norm = librosa.util.normalize(audio_trimmed) * 0.7  # -3dB headroom

# Add tail silence
silence = np.zeros(int(0.2 * sr))
audio_final = np.concatenate([audio_norm, silence])

# Save
sf.write("processed.wav", audio_final, sr)
```

---

## Sync Troubleshooting

### Lips out of sync with audio

**Causes:**
- Frame rate mismatch
- Audio/video length mismatch
- Processing delay

**Solutions:**
```
# Offset audio (if lips are early)
ffmpeg -i video.mp4 -itsoffset 0.1 -i audio.wav -c:v copy -c:a aac output.mp4

# Offset audio (if lips are late)
ffmpeg -i video.mp4 -itsoffset -0.1 -i audio.wav -c:v copy -c:a aac output.mp4
```

### Mouth movements too subtle

**Solutions:**
- Use wav2lip_gan.pth instead of wav2lip.pth
- Increase audio volume before processing
- Check face detection is accurate

### Face artifacts after lip-sync

**Solutions:**
- Always run face enhancement after Wav2Lip
- CodeFormer fidelity: 0.6-0.8 (not too high)
- Ensure source image resolution matches output

### Unnatural head movement (SadTalker)

**Solutions:**
- Lower pose_style value (0-10)
- Use `preprocess: "crop"` for stability
- Provide front-facing source image
