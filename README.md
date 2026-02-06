# VideoAgent - ComfyUI Video Production Orchestrator

A session-scoped AI orchestrator for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that turns Claude into a senior video production technical director. It routes natural-language requests to 12 specialized skill modules covering the full pipeline: character image generation, video production, voice synthesis, LoRA training, and publishing -- all driven by [ComfyUI](https://github.com/comfyanonymous/ComfyUI).

## Why This Exists

Producing AI-generated video with ComfyUI involves juggling dozens of models, custom nodes, prompt styles, and hardware constraints. VideoAgent wraps all of that domain knowledge into a structured skill system that Claude reads on demand, so you can say things like:

- _"Generate a photorealistic portrait of Sage using InstantID"_
- _"Make a talking head video where she says 'Welcome to my channel'"_
- _"Train a LoRA from these 20 reference images"_
- _"Check for new ComfyUI video models released this month"_

...and get validated, hardware-aware ComfyUI workflows without memorizing node names or VRAM budgets.

## How It Works

```
video-agent.bat
  |
  |-- Writes state/session.json (active project, ComfyUI URL)
  |-- cd to this repo
  |-- Launches: claude
        |
        |-- Claude Code auto-loads CLAUDE.md (the orchestrator)
        |-- Local hooks fire (staleness check)
        |-- User's first message triggers foundation reads
        |-- Each request is routed to the right skill file
```

**Key design decisions:**

| Decision | Rationale |
|----------|-----------|
| Session-scoped, not global | Skills stay in this repo. Other Claude Code sessions are unaffected. |
| `CLAUDE.md` is the orchestrator | The only file Claude auto-loads from a project root. Contains the routing table and behavioral instructions. |
| Skills are read-on-demand markdown | No build step, no registration. Claude reads `skills/{name}/SKILL.md` when the routing table says to. |
| REST polling over WebSocket | Claude Code can't hold persistent connections. Polling every 5s works fine for minute-long video generation. |
| Research is user-triggered | No cron jobs. A session-start hook reminds you when data is stale. |

## Prerequisites

- **[Claude Code](https://docs.anthropic.com/en/docs/claude-code)** installed and authenticated
- **[ComfyUI](https://github.com/comfyanonymous/ComfyUI)** installed (local or remote)
- **[FFmpeg](https://ffmpeg.org/)** on PATH (for video assembly)
- **[PowerShell 7+](https://github.com/PowerShell/PowerShell)** (for utility scripts)
- Windows (the launcher is a `.bat` file; WSL/Linux adaptation is straightforward)

## Quick Start

### 1. Clone and launch

```cmd
git clone https://github.com/MCKRUZ/ComfyUI-Expert.git
cd ComfyUI-Expert
video-agent.bat
```

With options:

```cmd
video-agent.bat --project "my-video"          # Set active project
video-agent.bat --comfyui "http://<remote-ip>:8188"  # Remote ComfyUI
video-agent.bat --resume                       # Resume last session
```

### 2. Scan your ComfyUI installation

First time (or after installing new models/nodes), tell the agent:

```
Scan my ComfyUI installation at C:\ComfyUI
```

Or run the script directly:

```powershell
pwsh -File scripts/scan-inventory.ps1 -ComfyUIPath "C:\ComfyUI"
```

This creates `state/inventory.json` -- a cache of every model, custom node, and VRAM detail. The agent validates every workflow against this inventory before execution.

### 3. Start creating

```
Generate a photorealistic portrait using FLUX
Create a new project called "Character Showcase"
Add a character named Sage - auburn hair, green eyes, freckles
Train a LoRA from these reference images
Research the latest ComfyUI video models
```

## Architecture

### 3-Tier Context System

VideoAgent loads context incrementally to stay within Claude's context window:

| Tier | Files | Loaded When | Size |
|------|-------|-------------|------|
| **1: Foundation** | `foundation/*.md` | Session start (first interaction) | ~2K tokens |
| **2: Working** | `projects/{name}/*` | When working on a specific project | Varies |
| **3: Reference** | `references/*.md` | Only when a skill explicitly needs detail | Large |

### Skill Dependency Graph

```
CLAUDE.md (orchestrator - always loaded)
    |
    |-- Foundation Skills (no dependencies)
    |   |-- comfyui-api              REST API connection
    |   |-- comfyui-inventory        Model/node discovery
    |   |-- project-manager          Project & character state
    |
    |-- Research (independent)
    |   |-- comfyui-research         Self-updating knowledge base
    |
    |-- Core Creation (depend on inventory)
    |   |-- comfyui-prompt-engineer  Model-specific prompt optimization
    |   |-- comfyui-workflow-builder Validated workflow JSON generation
    |
    |-- Production (depend on creation)
    |   |-- comfyui-video-pipeline   Wan 2.2 / FramePack / AnimateDiff
    |   |-- comfyui-voice-pipeline   Chatterbox / F5-TTS / lip-sync
    |   |-- comfyui-lora-training    Dataset prep, training, evaluation
    |
    |-- Output (depend on production)
    |   |-- video-assembly           FFmpeg + Remotion composition
    |   |-- video-publisher          YouTube metadata & upload
    |
    |-- Support
        |-- comfyui-troubleshooter   Error diagnosis & fixes
```

### Request Routing

When you make a request, `CLAUDE.md` routes it to the right skill:

| You Say | Skill Loaded | What Happens |
|---------|-------------|--------------|
| "Generate a character portrait" | `comfyui-workflow-builder` | Checks inventory, builds workflow JSON, queues via API |
| "Craft a better prompt" | `comfyui-prompt-engineer` | Model-specific optimization (FLUX vs SDXL vs Wan) |
| "Create a video from this image" | `comfyui-video-pipeline` | Selects engine (Wan/FramePack/AnimateDiff), builds pipeline |
| "Clone this voice / make her talk" | `comfyui-voice-pipeline` | Voice synthesis + lip-sync pipeline |
| "Train a LoRA" | `comfyui-lora-training` | Dataset prep, training config, checkpoint evaluation |
| "Build a raw workflow" | `comfyui-workflow-builder` | Direct workflow construction with inventory validation |
| "Check for new models" | `comfyui-research` | Scans YouTube/GitHub/HuggingFace, updates references |
| "Something broke" | `comfyui-troubleshooter` | Error pattern matching, fix suggestions |
| "Assemble the final video" | `video-assembly` | FFmpeg or Remotion-based composition |
| "Upload to YouTube" | `video-publisher` | Metadata generation + upload delegation |
| "Create a new project" | `project-manager` | Project manifests, character profiles |
| "Connect to ComfyUI" | `comfyui-api` | Connection test, system info |

## The 12 Skills

### Foundation

**comfyui-api** -- Connects to ComfyUI's REST API (default `http://127.0.0.1:8188`). Queues workflows, polls for results at 5-second intervals, handles image/model uploads, cancellations, and VRAM management. Supports online mode (live API) and offline mode (JSON export).

**comfyui-inventory** -- Discovers every installed model, custom node, and VRAM configuration. Works online (API queries) or offline (directory scanning via `scan-inventory.ps1`). Caches results to `state/inventory.json`. Maps node classes to packages (e.g., `ApplyInstantID` -> `ComfyUI_InstantID`).

**project-manager** -- Creates project structures with YAML manifests and character profiles. Tracks generation history (what settings worked), manages character identity (appearance, voice, LoRA, reference images), and updates defaults after successful runs.

### Research

**comfyui-research** -- Monitors 7 YouTube channels, 11 GitHub repos, and HuggingFace trending models. Extracts knowledge from tutorials (via transcript analysis), tracks releases, and generates staleness reports. Models older than 90 days and nodes older than 60 days get flagged.

### Core Creation

**comfyui-prompt-engineer** -- Model-specific prompt optimization for FLUX, SDXL, SD1.5, and Wan. Adjusts prompts for identity methods (InstantID, PuLID, IP-Adapter, LoRA), recommends CFG scales per model, and provides negative prompt templates. Integrates with character profiles for context.

**comfyui-workflow-builder** -- Generates ComfyUI workflow JSON from natural language. Validates every model and node against inventory before output. Supports text-to-image, identity-preserved generation, video (Wan/AnimateDiff), upscaling, and inpainting patterns. Includes VRAM estimation per component.

### Production

**comfyui-video-pipeline** -- Orchestrates three video engines based on requirements:
- **Wan 2.2 MoE 14B**: Film-level quality, 5-10 sec clips, 24GB+ VRAM
- **FramePack**: Long videos (60+ sec), VRAM-invariant (works on 6GB)
- **AnimateDiff V3**: Fast iteration, motion LoRAs, 4-8 step Lightning

Includes post-processing (RIFE frame interpolation, face enhancement, deflicker, color correction) and a dedicated talking-head pipeline.

**comfyui-voice-pipeline** -- Six voice synthesis tools (Chatterbox, F5-TTS, TTS Audio Suite, IndexTTS-2, RVC, ElevenLabs) and four lip-sync methods (Wav2Lip, SadTalker, LivePortrait, LatentSync 1.6). Three complete pipelines: Quick (image-to-talk), Quality (image-to-video-to-lip-sync), and Premium (expression transfer).

**comfyui-lora-training** -- Training tools (AI-Toolkit for FLUX, Kohya_ss for SDXL, FluxGym/SimpleTuner for low VRAM). Covers dataset preparation (15-30 images, captioning strategy), hyperparameter guidance, checkpoint evaluation, and LoRA + zero-shot method combination.

### Output

**video-assembly** -- Two modes: FFmpeg (concatenation, audio mixing, subtitles, transitions) and Remotion (animated captions, motion graphics, React-based templates). Audio normalization to -16 LUFS for YouTube. Quality presets (CRF 15-28).

**video-publisher** -- Thin orchestrator that delegates to global YouTube skills for research, title/thumbnail optimization, upload, and analytics. Generates platform-specific metadata (YouTube, Shorts, Instagram Reels, TikTok).

### Support

**comfyui-troubleshooter** -- Diagnoses four error categories (server, workflow, quality, performance). Covers the top 10 common errors (OOM, missing nodes, precision mismatch, burned faces, etc.) with quick fixes. Includes a quality decision tree and missing-dependency resolution.

## Model Landscape

The agent tracks the top models across five categories:

### Image Generation
| Model | Best For | VRAM |
|-------|----------|------|
| FLUX.1-dev | Photorealism, highest quality | 16GB+ |
| FLUX Kontext | Iterative character editing | 12-32GB |
| RealVisXL V5.0 | Fast SDXL photorealism | 8GB+ |

### Identity Preservation
| Method | Best For | VRAM |
|--------|----------|------|
| InfiniteYou | Highest identity fidelity | 24GB |
| FLUX Kontext | Edit without retraining | 12-32GB |
| PuLID Flux II | Dual characters, no pollution | 24-40GB |

### Video Generation
| Model | Best For | VRAM |
|-------|----------|------|
| Wan 2.2 MoE | Film-level quality | 24GB+ |
| FramePack | Long videos, low VRAM | 6GB+ |
| AnimateDiff V3 | Fast iteration, motion LoRAs | 8GB+ |

### Voice / TTS
| Tool | Best For | License |
|------|----------|---------|
| TTS Audio Suite | 23 languages, unified platform | Multi |
| Chatterbox | Emotion tags, beats ElevenLabs 63.8% | MIT |
| F5-TTS | Zero-shot cloning, fastest | MIT |

### Lip-Sync
| Tool | Best For |
|------|----------|
| LatentSync 1.6 | Highest accuracy (ByteDance) |
| Wav2Lip | Proven, works with any face |
| SadTalker | Head movement + expressions |

Full specs and download links are in `references/models.md`.

## Hardware Profile

VideoAgent is configured for an **RTX 5090 (32GB VRAM)** but works with any GPU. The agent adjusts recommendations based on available VRAM.

| Workload | 32GB Status | Notes |
|----------|:-----------:|-------|
| FLUX.1-dev FP16 | Native | No quantization needed |
| Wan 2.2 14B | Native | Full quality |
| FramePack | Overkill | Designed for 6GB |
| PuLID Flux II | Native | Dual-character generation |
| InfiniteYou | Native | Both SIM and AES variants |
| LoRA Training (FLUX) | Native | No quantization needed |

Recommended ComfyUI launch flags: `--highvram --fp8_e4m3fn-unet`

## Project Structure

```
ComfyUI-Expert/
|-- video-agent.bat              Launcher (writes session config, opens Claude)
|-- CLAUDE.md                    Orchestrator (routing table, behavior, rules)
|-- .claude/
|   +-- settings.local.json     Project-local hooks & permissions
|
|-- foundation/                  Tier 1: Quick reference (~2K tokens)
|   |-- agent-persona.md         Communication style & principles
|   |-- api-quick-ref.md         ComfyUI REST API cheat sheet
|   |-- hardware-profile.md      GPU specs, VRAM capabilities
|   |-- model-landscape.md       Top 3 models per category
|   +-- skill-registry.md        Skill list & dependency map
|
|-- skills/                      12 skill modules (read on demand)
|   |-- comfyui-api/
|   |-- comfyui-inventory/
|   |-- comfyui-lora-training/
|   |-- comfyui-prompt-engineer/
|   |-- comfyui-research/
|   |-- comfyui-troubleshooter/
|   |-- comfyui-video-pipeline/
|   |-- comfyui-voice-pipeline/
|   |-- comfyui-workflow-builder/
|   |-- project-manager/
|   |-- video-assembly/
|   +-- video-publisher/
|
|-- references/                  Tier 3: Deep reference (loaded on demand)
|   |-- models.md                Full model catalog & download links
|   |-- workflows.md             Complete workflow node configurations
|   |-- lora-training.md         Training parameters & best practices
|   |-- voice-synthesis.md       Voice tools in depth
|   |-- prompt-templates.md      Model-specific prompt strategies
|   |-- troubleshooting.md       Error database with solutions
|   |-- research-2025.md         Full technique survey
|   |-- staleness-report.md      Freshness tracking for all entries
|   +-- evolution.md             Update protocol & changelog
|
|-- projects/                    Per-project state (gitignored)
|-- state/                       Runtime state (gitignored)
|   |-- session.json             Active project & ComfyUI URL
|   +-- inventory.json           Cached models/nodes from scan
|
|-- scripts/                     Utility scripts
|   |-- scan-inventory.ps1       Offline ComfyUI directory scanner
|   |-- connect-comfyui.ps1      Connection test & diagnostics
|   |-- staleness-check.ps1      Session-start hook (checks research age)
|   +-- deploy.ps1               Sync references to global skill
|
|-- agent/
|   +-- AGENT.md                 Extended orchestration spec
|
+-- docs/
    |-- architecture.md          System design decisions
    +-- getting-started.md       Quick start guide
```

## Example Workflows

### Character Image Generation

```
1. "Create a new project called Character Showcase"
2. "Add a character named Sage - auburn hair, green eyes, freckles"
3. "Generate a photorealistic portrait of Sage using InstantID"
```

The agent: reads inventory -> loads workflow-builder skill -> loads prompt-engineer skill -> generates optimized prompt -> builds validated workflow JSON -> queues via ComfyUI API -> polls for result.

### Talking Head Video

```
1. "Make Sage say 'Hello everyone, welcome to my channel'"
```

The agent orchestrates a multi-step pipeline: voice synthesis (Chatterbox/F5-TTS) -> video generation (Wan 2.2) -> lip-sync (LatentSync) -> face enhancement -> assembly.

### Research Update

```
1. "Check for new ComfyUI models and techniques"
```

The agent: loads research skill -> checks YouTube channels, GitHub repos, HuggingFace trending -> extracts knowledge from tutorials -> updates reference files -> generates staleness report.

## Hooks & Automation

VideoAgent uses Claude Code's [hooks system](https://docs.anthropic.com/en/docs/claude-code/hooks) for lightweight automation:

| Hook | Event | What It Does |
|------|-------|-------------|
| Staleness check | `SessionStart` | Warns if research data is older than 2 weeks |

Configured in `.claude/settings.local.json` (project-local, doesn't affect other sessions).

## Scripts Reference

| Script | Purpose | Usage |
|--------|---------|-------|
| `scan-inventory.ps1` | Scan ComfyUI models & nodes offline | `pwsh -File scripts/scan-inventory.ps1 -ComfyUIPath "C:\ComfyUI"` |
| `connect-comfyui.ps1` | Test ComfyUI connection & show diagnostics | `pwsh -File scripts/connect-comfyui.ps1` |
| `staleness-check.ps1` | Check research freshness (session hook) | Runs automatically at session start |
| `deploy.ps1` | Sync references to global `comfyui-character-gen` skill | `pwsh -File scripts/deploy.ps1` |

## Customization

### Different GPU

Edit `foundation/hardware-profile.md` with your GPU specs. The agent reads this at session start and adjusts VRAM recommendations accordingly.

### Different ComfyUI location

Pass it at launch:

```cmd
video-agent.bat --comfyui "http://<remote-ip>:8188"
```

Or edit the default in `video-agent.bat` (line 18).

### Adding models to the landscape

Edit `foundation/model-landscape.md` (top 3 quick reference) and `references/models.md` (full catalog). Or just ask the agent to run a research update.

### Adapting for Linux/macOS

Replace `video-agent.bat` with a shell script that:
1. Writes `state/session.json`
2. `cd`s to the repo
3. Runs `claude`

Update the PowerShell script paths in `.claude/settings.local.json` to use `pwsh` (which is cross-platform).

## Troubleshooting

| Issue | Solution |
|-------|---------|
| Claude doesn't act as VideoAgent | Launch via `video-agent.bat`, not plain `claude` |
| "Model not found" in workflow | Run inventory scan, then ask to regenerate |
| ComfyUI won't connect | Run `pwsh -File scripts/connect-comfyui.ps1` |
| Staleness hook not firing | Check `.claude/settings.local.json` is valid JSON |
| Skills leaking to other sessions | They shouldn't -- skills are local files, not globally installed |

## License

MIT
