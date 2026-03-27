# Research Notes — YouTube Video Analysis

Structured findings from ComfyUI tutorial channel analysis. Each entry follows the format from SKILL.md.

---

## Weekly Sweep: 2026-03-27

### YouTube Channel Status

Direct RSS access was blocked (403 Forbidden). Channel activity was researched via WebSearch and GitHub release monitoring.

---

## Pixaroma — Active Episodes (March 2026)

Channel: youtube.com/@pixaroma | GitHub: github.com/pixaroma/pixaroma-workflows

Pixaroma released 3 episodes in the last 3 weeks. Transcripts were not accessible; analysis based on GitHub release metadata and community search.

| Episode | Release Date | Notes |
|---------|-------------|-------|
| EP08 | March 11, 2026 | Active workflow release; EP06 noted `--disable-dynamic-vram` workaround |
| EP09 | March 17, 2026 | 10 community reactions; workflow files available |
| EP10 | March 24, 2026 | Latest episode; focused on ComfyUI workflows |

**Workflow tip from EP06 (still relevant):** If you encounter errors with dynamic VRAM management, add `--disable-dynamic-vram` to launch args as a workaround.

**Models used in Pixaroma community (March 2026 Discord activity):** Z-Image, Seedream 4.x, Gemini Pro. Community members generating daily challenge images using ComfyUI workflows.

**New nodes:** No specific new nodes confirmed without transcript access.

**Workflow tips:**
- Pixaroma maintains ComfyUI-Easy-Install (Pixaroma Community Edition) bundling GGUF support, VideoHelperSuite, WanVideoWrapper, Impact Pack
- Focus on GGUF quantized models for 8-12GB VRAM users

*Transcripts not available — mark for manual review at: youtube.com/playlist?list=PL-pohOSaL8P-FhSw1Iwf0pBGzXdtv4DZC*

---

## Sebastian Kamph — Recent Videos (March 2026)

Channel: youtube.com/@sebastiankamph | Source: Recapio, Class Central

### [Wan 2.6 is HERE! R2V is AWESOME!](https://recapio.com/digest/wan-2-6-is-here-r2v-is-awesome-by-sebastian-kamph) — Sebastian Kamph

**Key findings:**
- Detailed walkthrough of Wan 2.6 Reference-to-Video (R2V) for character consistency
- Method: Upload ~5-second video clip as reference to preserve appearance, movement, and expressions
- New workflow: character reference video → Wan 2.6 R2V → new scenes with same character
- Described as strong advancement for content creation with consistent "digital self"

**New models:** Wan 2.6 R2V
**New nodes:** None confirmed
**Workflow tips:**
- Reference clip should be ~5 seconds of clear character footage
- Both visual appearance AND voice can be preserved with Wan 2.6 R2V
- Works for inserting yourself or any subject into new AI-generated scenes

---

### [Image2Video Wan 2.2 5B for ComfyUI](https://www.classcentral.com/course/youtube-image2video-wan-2-2-5b-for-comfyui-475850) — Sebastian Kamph

**Key findings:**
- Tutorial on Wan 2.2 5B image-to-video in ComfyUI
- Model file: `wan2.2_ti2v_5B_fp16.safetensors`
- Requires: text encoder + VAE components (same as Wan 2.1)
- Includes troubleshooting for common installation errors

**New models:** Wan 2.2 5B (I2V variant)
**New nodes:** None
**Workflow tips:**
- Use same VAE (`wan_2.1_vae.safetensors`) as Wan 2.1 — no separate download needed
- 5B model significantly lower VRAM requirement vs 14B

---

## Kijai — GitHub Activity (March 2026)

Channel: youtube.com/@kijai | GitHub: github.com/kijai/ComfyUI-WanVideoWrapper (6.2k stars)

Kijai primarily releases via GitHub rather than YouTube videos.

**Recent ComfyUI-WanVideoWrapper updates:**
- LoRA weights now loaded as module buffers (enables participation in block swapping + async offloading)
- Reduced reliance on `torch.compile` for VRAM efficiency — better compatibility without it
- Workarounds for compile-related VRAM spikes on first run

**New model wrappers added (cumulative):**
- FantasyTalking, FantasyPortrait, MultiTalk, EchoShot, HuMo, WanAnimate
- ReCamMaster, Uni3C, MAGREF, ATI, Phantom
- Training-free techniques: TimeToMove, SteadyDancer, SCAIL

**Workflow tips:**
- If using LoRA with Kijai wrapper: LoRA buffer change may require adjusting block swap parameters in existing workflows
- GGUF model loading is supported in the wrapper

---

## Olivio Sarikas — Status

No March 2026 videos confirmed via search. Channel primarily covers FLUX and SDXL workflows. Not identified as having new ComfyUI-specific content this week.

---

*For manually reviewing video transcripts, recommended tool: yt-dlp with --write-auto-subs, or youtube.com/transcript API*
