# comfyui-workflow-builder — Eval Configuration

## Classification
- **Type**: Capability Uplift
- **Category**: Structured workflow generation from natural language with hardware-aware validation

## What "Good" Looks Like
1. Output is valid ComfyUI workflow JSON with correct node IDs, class_types, and connections
2. All class_types reference nodes that actually exist in ComfyUI (no hallucinated node names)
3. Model filenames match real checkpoint/LoRA files (e.g., `juggernautXL_v9.safetensors`, not invented names)
4. Connections are correct — no dangling inputs, output indices match node output slots (e.g., CheckpointLoader outputs [MODEL, CLIP, VAE] at indices [0, 1, 2])
5. Resolution matches the selected model's training resolution (1024x1024 for SDXL, 512x512 for SD1.5, etc.) and VRAM estimate is reasonable for the hardware

## Known Limitations
- Cannot verify at generation time whether the user actually has a specific model installed
- Custom node availability varies per installation — skill uses common nodes but can't guarantee all are present
- VRAM estimates are approximations based on typical configurations

## Benchmark Strategy
- **Without skill**: Base Claude produces plausible-looking JSON but frequently hallucinates node class_types, uses wrong output indices, and ignores resolution/model compatibility
- **With skill**: Generates validated workflows with correct node names, proper output slot indices, model-appropriate resolutions, and VRAM estimates
- **Key differentiator**: Output index correctness and node class_type accuracy — the difference between a workflow that loads vs. one that errors immediately

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
When base Claude consistently produces ComfyUI workflows with correct output indices, valid class_types from the actual node registry, and model-appropriate resolutions without needing the skill's node/model reference data.
