# Getting Started with VideoAgent

## Prerequisites

- **Claude Code** installed and configured
- **ComfyUI** installed (local or remote)
- **FFmpeg** installed (for video assembly)
- **PowerShell 7+** (for utility scripts)

## How It Works

VideoAgent is **session-scoped** - it only activates when you launch via the bat file. Your other Claude Code sessions are unaffected.

When you run `video-agent.bat`:
1. Claude Code opens in the VideoAgent directory
2. `CLAUDE.md` loads automatically, turning Claude into the VideoAgent orchestrator
3. Project-local hooks fire (staleness check)
4. Claude reads foundation files on first interaction and routes your requests to the right skill

Skills live as local files in `skills/`. They're NOT installed globally. Claude reads them on demand based on what you ask.

## Quick Start

### 1. Launch a Session

Double-click `video-agent.bat` or run from terminal:

```cmd
video-agent.bat
```

With options:
```cmd
video-agent.bat --project "my-video"
video-agent.bat --comfyui "http://<remote-ip>:8188"
video-agent.bat --resume
```

### 2. Scan Your ComfyUI Installation

First time only (or after installing new models):

```
Scan my ComfyUI installation at C:\ComfyUI
```

Or manually:
```powershell
pwsh -File scripts/scan-inventory.ps1 -ComfyUIPath "C:\ComfyUI"
```

### 3. Start Creating

```
Generate a photorealistic portrait using FLUX
Create a talking head video of my character
Train a LoRA from these reference images
Research the latest ComfyUI video models
```

## Example Workflows

### Character Image Generation
1. "Create a new project called Character Showcase"
2. "Add a character named Sage - auburn hair, green eyes, freckles"
3. "Generate a photorealistic portrait of Sage using InstantID"
4. Agent reads inventory → workflow-builder skill → prompt-engineer skill → generates workflow → executes via API

### Talking Head Video
1. "Make Sage say 'Hello everyone, welcome to my channel'"
2. Agent orchestrates: voice pipeline → video pipeline → lip-sync → assembly

### Research Updates
1. "Check for new ComfyUI models and techniques"
2. Agent reads research skill → checks YouTube/GitHub/HuggingFace → updates references

## Syncing References

If you want the global `comfyui-character-gen` skill to benefit from VideoAgent's reference updates:

```powershell
pwsh -File scripts/deploy.ps1
```

This only syncs reference files - it does NOT install VideoAgent skills globally.

## File Locations

| What | Where |
|------|-------|
| Launcher | `video-agent.bat` (repo root) |
| Orchestrator | `CLAUDE.md` (loaded automatically) |
| Skills | `skills/` (read on demand by Claude) |
| Foundation context | `foundation/` (read at session start) |
| Deep references | `references/` (read when skills need detail) |
| Projects | `projects/` (per-project state) |
| Inventory cache | `state/inventory.json` |
| Session config | `state/session.json` (written by bat file) |
| Utility scripts | `scripts/` |

## Troubleshooting

| Issue | Solution |
|-------|---------|
| Claude doesn't act as VideoAgent | Make sure you launched via `video-agent.bat`, not plain `claude` |
| Staleness hook not firing | Check `.claude/settings.local.json` has the hook configured |
| ComfyUI won't connect | Run `scripts/connect-comfyui.ps1` to diagnose |
| Missing models in workflow | Run inventory scan, then ask Claude to re-generate |
| Skills polluting other sessions | They shouldn't - skills are local files, not globally installed |
