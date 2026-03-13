# comfyui-prompt-interview — Eval Configuration

## Classification
- **Type**: Encoded Preference
- **Category**: Guided conversational interview for creative vision extraction before prompt synthesis

## What "Good" Looks Like
1. ASKS QUESTIONS FIRST — does not generate prompts until the user's vision is understood (sequence is interview THEN generate)
2. Interview length is appropriate: 4-7 exchanges max, not dragging on or cutting short
3. Prompts are formatted for the target model (SDXL tag-style vs. FLUX natural language vs. SD1.5 weighted tokens)
4. Negative prompt uses the correct template for the model (SDXL negatives differ from SD1.5)
5. Output includes recommended settings table (sampler, steps, CFG, resolution) and pipeline recommendation

## Known Limitations
- Cannot assess subjective prompt quality — only structural correctness and interview flow
- User engagement quality varies; skill can't force good answers from terse users
- Model-specific prompt optimization evolves as models update

## Benchmark Strategy
- **Without skill**: Base Claude dumps a prompt immediately when asked to "help me create an image," skipping discovery of the user's actual vision
- **With skill**: Conducts a structured interview to understand subject, mood, style, technical preferences BEFORE generating model-appropriate prompts
- **Key differentiator**: The interview-first sequence — encoded preference that creative vision must be understood before prompt generation begins

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
N/A — This is an encoded preference for conversational workflow. Even if base Claude improves at prompt writing, the interview-first behavior is a deliberate UX choice that won't be absorbed into default model behavior.
