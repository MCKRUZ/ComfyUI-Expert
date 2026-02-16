# Skill Evolution & Changelog

Track updates, new techniques, and user-specific learnings for the ComfyUI Video Production skill.

---

## Changelog

### v1.0.0 (February 2026 - Initial Release)

**Core Features:**
- Complete keyframe-to-video pipeline
- Batch I2V processing system
- Professional video concatenation with transitions
- ComfyUI instance management & health monitoring
- Multi-instance load balancing
- Auto-restart & recovery procedures
- Validation suite for pre/post generation
- FFmpeg integration for transitions

**Supported Models:**
- LTX-2 (4K production video)
- Wan 2.2 MoE (film-quality)
- Wan 2.1 14B & 1.3B
- AnimateDiff V3
- SVD (Stable Video Diffusion)

**Documentation:**
- Main SKILL.md with 3 core pipelines
- instance-management.md - ComfyUI health & restart
- concatenation.md - FFmpeg transitions & audio
- api-reference.md - ComfyUI REST API guide
- evolution.md - This file

**Key Capabilities:**
- Automatic error recovery with retry strategies
- Progress tracking with real-time ETA
- Quality validation (resolution, FPS, codec)
- Rollback & versioning support
- RTX 50 Series optimizations (NVFP4/NVFP8)
- AMD ROCm support (native in ComfyUI v0.8.1+)

---

## Monitoring Sources

### I2V Model Releases (Check Weekly)

**HuggingFace Trending**
- https://huggingface.co/models?sort=trending&pipeline_tag=video-generation
- Watch for: New video diffusion models, improved versions of Wan/LTX

**GitHub Repositories**
- https://github.com/Lightricks/LTX-Video - LTX updates
- https://github.com/alibaba/VideoX - Wan updates
- https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved - AnimateDiff
- https://github.com/comfyanonymous/ComfyUI - Core ComfyUI updates

**Research Papers**
- https://arxiv.org/list/cs.CV/recent - Computer vision (video gen)
- https://huggingface.co/papers - Daily ML papers
- Search: "image to video", "video diffusion", "temporal consistency"

### ComfyUI Updates (Check Weekly)

**Official Releases**
- https://github.com/comfyanonymous/ComfyUI/releases
- Watch for: API changes, performance improvements, new features

**Custom Nodes**
- https://github.com/ltdrdata/ComfyUI-Manager - Manager updates
- https://github.com/Fannovel16/ComfyUI-Frame-Interpolation - RIFE/FILM
- https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite - Video tools

### Community Knowledge (Check Monthly)

- r/comfyui - Reddit community
- r/StableDiffusion - General AI video discussions
- ComfyUI Discord - Real-time community help
- Civitai forums - Model/workflow discussions

---

## Update Protocol

### When New I2V Model Releases

1. **Evaluate Relevance**
   - Does it improve on current recommendations?
   - What's the quality vs performance tradeoff?
   - VRAM requirements feasible for target users?

2. **Test Compatibility**
   - Can it be loaded in ComfyUI?
   - Required custom nodes available?
   - Works with existing workflow patterns?

3. **Benchmark Performance**
   - Test on same keyframes as existing models
   - Measure: quality, speed, VRAM usage, consistency
   - Compare to Wan 2.2, LTX-2, AnimateDiff baselines

4. **Update Documentation**
   - Add to model comparison table in SKILL.md
   - Create workflow template if significantly different
   - Document special settings or gotchas
   - Update references/i2v-workflows.md (when created)

5. **Log Change**
   - Add entry to changelog below

### When ComfyUI API Changes

1. **Review Breaking Changes**
   - Check API reference doc for affected endpoints
   - Test existing code against new version

2. **Update Code Examples**
   - Modify api-reference.md examples
   - Update Python client code
   - Test all example scripts

3. **Document Migration Path**
   - If breaking: provide migration guide
   - Note version requirements

### When User Reports Issue

1. **Reproduce & Document**
   - What workflow/settings triggered it?
   - Can it be consistently reproduced?
   - Error messages or failure mode?

2. **Research Solution**
   - Check ComfyUI issues on GitHub
   - Search community forums/Discord
   - Test potential fixes

3. **Update Documentation**
   - Add to troubleshooting section if common issue
   - Update relevant reference guide
   - Add validation check to prevent if possible

4. **Log Change**
   - Note issue and fix in changelog

---

## User-Specific Learnings

Track what works for specific user setups and projects.

### Hardware Profile

**User:** MCKRUZ
**GPU:** NVIDIA RTX 5090 (32GB VRAM)
**OS:** Windows 11 Pro
**ComfyUI:** v0.8.1+

**Capabilities:**
- Can run Wan 2.2 14B natively
- LTX-2 4K generation without optimization
- Batch multiple workflows simultaneously
- Use NVFP4/NVFP8 precision for 3x speedup

**Optimal Settings:**
```bash
# ComfyUI launch flags
--highvram \
--fp8_e4m3fn-unet \
--reserve-vram 7
```

### Project: Sage Character Video Series

**Goal:** Multi-shot narrative videos (30+ seconds)
**Character:** Sage (reddish-brown hair, green eyes, fair skin)
**Style:** Photorealistic, natural lighting, intimate/sensual

**Workflow Preferences:**
- Keyframe generation: FLUX.1-dev + IP-Adapter (0.80 weight)
- I2V model: Wan 2.2 MoE 14B (film-quality aesthetics)
- Resolution: 768x1024 (portrait) or 832x1216 (larger)
- FPS: 16 (matches Wan 2.2 output)
- Transitions: 0.5s crossfade (smooth but not slow)

**What Worked:**
- ✓ Generating 5 keyframes first, validating consistency before I2V
- ✓ Using consistent motion prompts with "consistent identity, same person" prefix
- ✓ Staggering I2V submissions (3-5 minute wait between clips)
- ✓ Validating each clip immediately after generation

**What Didn't Work:**
- ✗ Submitting all 5 I2V jobs at once (overwhelmed queue)
- ✗ Using cv2.VideoWriter for concatenation (quality loss, wrong codec)
- ✗ Not validating FPS before concat (got 25fps instead of 16fps)
- ✗ Hard-coded wait times (some clips took longer, some faster)
- ✗ Manual file selection for concatenation (forgot clips 1 & 4)

**Lessons Learned:**
1. **Always validate before proceeding** - Check keyframes, then check videos
2. **Use FFmpeg, not cv2** - Better quality, proper codec support
3. **Automate everything** - Manual steps = mistakes
4. **Implement retry logic** - Some generations fail randomly
5. **Monitor ComfyUI health** - Can stall without errors

---

## Feature Roadmap

### v1.1.0 (Planned)

**New Features:**
- Keyframe generation reference guide
- I2V workflow templates for all supported models
- Validation reference with face consistency checking
- Troubleshooting guide with common issues

**Improvements:**
- Add frame interpolation between I2V clips
- Support for audio addition/mixing
- Color grading pipeline
- Upscaling integration

### v1.2.0 (Future)

**Advanced Features:**
- Multi-GPU support for parallel generation
- Cloud instance integration (RunPod, Vast.ai)
- Voice synthesis integration (TTS Audio Suite)
- Lip-sync pipeline (Wav2Lip, SadTalker)

---

## Research Tasks

### Weekly
- [ ] Check HuggingFace for new video generation models
- [ ] Review ComfyUI releases for breaking changes
- [ ] Monitor community forums for common issues

### Monthly
- [ ] Deep dive on any major new I2V model releases
- [ ] Review video generation research papers
- [ ] Test new custom nodes for video workflows
- [ ] Update benchmark comparisons

### Quarterly
- [ ] Full skill audit - are recommendations still current?
- [ ] Remove deprecated models/techniques
- [ ] Major version bump if significant changes

---

## Integration Opportunities

### With Other Skills

**comfyui-character-gen**
- Use for generating consistent keyframes with LoRA/IP-Adapter
- Character consistency validation across frames
- Identity preservation techniques

**youtube-uploader**
- Direct upload to YouTube after production
- Metadata extraction for title/description
- Thumbnail generation from keyframes

**video-assembly** (if exists)
- Advanced editing and color grading
- Multi-track audio mixing
- Effects and overlays

---

## Community Contributions

If this skill helps you, consider contributing:

1. **Report Issues**
   - Document problems you encounter
   - Include workflow, settings, error messages
   - Suggest improvements

2. **Share Discoveries**
   - New model settings that work well
   - Workflow optimizations
   - Troubleshooting solutions

3. **Extend Documentation**
   - Add examples for your use case
   - Create guides for specific techniques
   - Document edge cases

4. **Contribute Code**
   - Improve Python client
   - Add new validation checks
   - Optimize batch processing

---

## Version History

| Version | Date | Key Changes |
|---------|------|-------------|
| v1.0.0 | 2026-02-16 | Initial release with core pipelines |
| v1.0.1 | TBD | Bug fixes and documentation improvements |
| v1.1.0 | TBD | New reference guides and validation suite |
| v1.2.0 | TBD | Advanced features and integrations |

---

## Contact & Support

**GitHub Repo:** https://github.com/MCKRUZ/ComfyUI-Expert

**Issues:** Report problems or request features via GitHub Issues

**Community:** Join ComfyUI Discord for real-time help
