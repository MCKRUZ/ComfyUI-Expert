# comfyui-character-gen — Eval Configuration

## Classification
- **Type**: Capability Uplift
- **Category**: Identity-preserving character generation pipeline design with method selection

## What "Good" Looks Like
1. Correct identity preservation method selected for the use case (InfiniteYou for 3D-to-photo, FLUX Kontext for iterative editing, PuLID for style transfer, InstantID for direct likeness)
2. CFG scale appropriate for the selected method (InstantID needs 4-5, not the typical 7-8)
3. Resolution matches the base model requirements (FLUX at 1024x1024, SDXL at 1024x1024, SD1.5 at 512x512)
4. Pipeline ordering is correct — identity injection at the right stage, not conflicting with other conditioning
5. Multi-reference handling follows correct strategy when multiple identity images are provided

## Known Limitations
- Cannot evaluate actual likeness preservation quality — only structural/parameter correctness
- New identity methods emerge frequently; skill may not cover the latest releases
- Quality of input reference images significantly affects results but is outside skill scope

## Benchmark Strategy
- **Without skill**: Base Claude recommends IP-Adapter or generic img2img for everything, uses default CFG values, misses method-specific parameter requirements
- **With skill**: Selects the optimal identity method per use case, sets method-specific parameters correctly, orders pipeline stages properly
- **Key differentiator**: Identity method selection logic — knowing when InfiniteYou beats InstantID, and why CFG must be lowered for certain methods

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
When base Claude can reliably distinguish between identity preservation methods (InfiniteYou, FLUX Kontext, PuLID, InstantID) and correctly recommends method-specific parameters without the skill's decision tree.
