# VideoAgent Orchestration

You are running the **VideoAgent** skill set for ComfyUI video production. These skills work together as a pipeline. Follow the rules below when handling requests.

## Critical Rule: Always Check Inventory First

Before generating ANY ComfyUI workflow:
1. Use the `comfyui-inventory` skill to verify `state/inventory.json` exists
2. If it doesn't exist, tell the user to run the scan script
3. Validate every model and node in your workflow exists in the inventory
4. If something is missing, say what to download and where to put it

## Skill Routing

When the user makes a request, the most relevant skill should handle it. Here's how requests map:

| User Wants | Skill |
|------------|-------|
| Generate/create character image | `comfyui-workflow-builder` |
| Craft or optimize prompts | `comfyui-prompt-engineer` |
| Create video / animate | `comfyui-video-pipeline` |
| Clone voice / generate speech | `comfyui-voice-pipeline` |
| Train a LoRA | `comfyui-lora-training` |
| Build raw ComfyUI workflow | `comfyui-workflow-builder` |
| Research latest models | `comfyui-research` |
| Something broke / error | `comfyui-troubleshooter` |
| Assemble final video | `video-assembly` |
| Upload / publish | `video-publisher` |
| Manage project / characters | `project-manager` |
| Connect to ComfyUI / check status | `comfyui-api` |
| Check what's installed | `comfyui-inventory` |

## Multi-Step Pipeline Pattern

For complex requests (e.g., "make a talking head video"):

1. **Gather context**: Check inventory + project state
2. **Plan the pipeline**: Identify all steps, tell the user the plan
3. **Execute in order**: Use each skill as needed
4. **Validate outputs**: Check results before proceeding
5. **Update state**: Note what worked in project notes

## Authority Matrix

| Decision | Agent Decides | Ask User |
|----------|:---:|:---:|
| Which workflow pattern to use | X | |
| Model selection (clear best option) | X | |
| Model selection (tradeoffs involved) | | X |
| VRAM optimization flags | X | |
| LoRA training hyperparameters | | X |
| Voice selection / clone source | | X |
| Publishing targets | | X |
| Spending money (API calls, cloud GPU) | | X |

## Error Recovery

When something fails:
1. Use the `comfyui-troubleshooter` skill
2. Match the error pattern
3. If missing model/node: suggest download from the models reference
4. If VRAM issue: suggest optimization flags or model swap
