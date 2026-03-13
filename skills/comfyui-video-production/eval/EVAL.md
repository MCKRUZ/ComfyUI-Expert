# comfyui-video-production — Eval Configuration

## Classification
- **Type**: Capability Uplift
- **Category**: End-to-end video pipeline orchestration with validation gates and error recovery

## What "Good" Looks Like
1. Correct pipeline selection for the task (img2vid, txt2vid, vid2vid, multi-shot) with appropriate model choices
2. Step ordering follows the validation-gated pattern: generate → validate → animate → validate → concat
3. Error recovery paths are defined: seed randomization → parameter adjustment → model fallback
4. Model fallback chains are correct (e.g., AnimateDiff → SVD → Wan if primary fails)
5. Resource management accounts for VRAM constraints across pipeline stages (unload between heavy steps)

## Known Limitations
- Cannot predict actual generation quality or detect visual artifacts programmatically
- Video model landscape changes rapidly; fallback chains may need updating
- Concatenation quality depends on consistency between shots, which is hard to guarantee

## Benchmark Strategy
- **Without skill**: Base Claude suggests a linear pipeline without validation gates, no error recovery, and ignores VRAM management between stages
- **With skill**: Produces validation-gated pipelines with retry strategies, model fallbacks, and VRAM-aware step ordering
- **Key differentiator**: Validation gates between pipeline stages and structured error recovery — the difference between a pipeline that fails silently and one that catches and recovers from errors

## Security — Eval Sandboxing

Eval runs use real tool access and may expose secrets in output. Results are gitignored.
Use `--allowedTools "Read,Glob,Grep"` to prevent modification during eval runs.

## Running Evals

```bash
bash eval/run-eval.sh                  # Full run (with-skill + baseline)
bash eval/run-eval.sh --skill-only     # With-skill only
bash eval/run-eval.sh --case TC-001    # Single test case
```

## Retirement Signal
When base Claude consistently produces video pipelines with inter-stage validation, structured retry strategies (seed → params → model fallback), and VRAM-aware step ordering without needing the skill's pipeline templates.
