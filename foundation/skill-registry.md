# Skill Registry

## Foundation Skills (no dependencies)

| Skill | Path | Purpose |
|-------|------|---------|
| `comfyui-api` | `skills/comfyui-api/` | Connect to ComfyUI, queue workflows, poll results |
| `comfyui-inventory` | `skills/comfyui-inventory/` | Discover installed models, nodes, VRAM (online + offline) |
| `project-manager` | `skills/project-manager/` | Character profiles, project manifests, asset tracking |

## Research (independent)

| Skill | Path | Purpose |
|-------|------|---------|
| `comfyui-research` | `skills/comfyui-research/` | Watch YouTube/GitHub/HF, extract knowledge, flag stale info |

## Core Creation (depend on inventory)

| Skill | Path | Depends On |
|-------|------|------------|
| `comfyui-prompt-engineer` | `skills/comfyui-prompt-engineer/` | inventory |
| `comfyui-workflow-builder` | `skills/comfyui-workflow-builder/` | inventory |
| `comfyui-character-gen` | Existing `~/.claude/skills/` | inventory (agent wraps with context) |

## Production (depend on creation skills)

| Skill | Path | Depends On |
|-------|------|------------|
| `comfyui-video-pipeline` | `skills/comfyui-video-pipeline/` | inventory, workflow-builder |
| `comfyui-voice-pipeline` | `skills/comfyui-voice-pipeline/` | inventory |
| `comfyui-lora-training` | `skills/comfyui-lora-training/` | inventory |

## Output (depend on production skills)

| Skill | Path | Depends On |
|-------|------|------------|
| `video-assembly` | `skills/video-assembly/` | video-pipeline, voice-pipeline |
| `video-publisher` | `skills/video-publisher/` | video-assembly |

## Support

| Skill | Path | Purpose |
|-------|------|---------|
| `comfyui-troubleshooter` | `skills/comfyui-troubleshooter/` | Diagnose failures, suggest fixes |

## Invocation Patterns

**Before any generation skill**: Always check `comfyui-inventory` first
**After any failure**: Route to `comfyui-troubleshooter`
**Before any workflow**: Validate against inventory (missing nodes/models)
**At session start**: Quick staleness check via `comfyui-research`
