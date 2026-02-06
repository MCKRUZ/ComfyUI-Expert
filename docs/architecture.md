# VideoAgent Architecture

## Overview

VideoAgent is a session-scoped AI orchestrator for ComfyUI-based video production. It activates only when launched via `video-agent.bat` - other Claude Code sessions are unaffected.

## Core Design Decisions

1. **Session-scoped, not global** - Skills are local files read by Claude on demand via CLAUDE.md routing. Nothing gets installed to `~/.claude/skills/`.
2. **CLAUDE.md is the orchestrator** - This is the only file Claude Code auto-loads from a project. It contains the decision tree, routing table, and behavioral instructions.
3. **Skills are read-on-demand markdown** - No build step, no registration. Claude reads `skills/{name}/SKILL.md` when the routing table says to.
4. **Polling over WebSocket** - Claude Code can't hold connections. REST polling every 5s works fine for minute-long video generation.
5. **Research is user-triggered** - No cron. Session-start hook reminds when data is stale.

## How It Loads

```
video-agent.bat
  |
  |-- Writes state/session.json (project, ComfyUI URL)
  |-- cd to VideoAgent directory
  |-- Launches: claude
        |
        |-- Claude Code reads CLAUDE.md (orchestrator instructions)
        |-- .claude/settings.local.json hooks fire (staleness check)
        |-- User's first message triggers foundation file reads
        |-- Subsequent requests routed to skill files per routing table
```

## Dependency Graph

```
CLAUDE.md (orchestrator - always loaded)
    |
    |-- Foundation Skills (no dependencies)
    |   |-- comfyui-api           REST API connection
    |   |-- comfyui-inventory     Model/node discovery
    |   |-- project-manager       Project state management
    |
    |-- Research (independent)
    |   |-- comfyui-research      Self-updating knowledge
    |
    |-- Core Creation (depend on inventory)
    |   |-- comfyui-prompt-engineer
    |   |-- comfyui-workflow-builder
    |   |-- comfyui-character-gen (global skill, wrapped with context)
    |
    |-- Production (depend on creation)
    |   |-- comfyui-video-pipeline
    |   |-- comfyui-voice-pipeline
    |   |-- comfyui-lora-training
    |
    |-- Output (depend on production)
    |   |-- video-assembly
    |   |-- video-publisher
    |
    |-- Support
        |-- comfyui-troubleshooter
```

## 3-Tier Context System

### Tier 1: Foundation (Session Start)

Small files Claude reads on first interaction. <2,000 tokens total.

| File | Purpose |
|------|---------|
| `foundation/hardware-profile.md` | GPU, VRAM, launch flags |
| `foundation/model-landscape.md` | Top 3 models per category |
| `foundation/skill-registry.md` | Skill list + when to use each |
| `foundation/api-quick-ref.md` | ComfyUI API cheat sheet |

### Tier 2: Working (Per-Project)

Loaded when the user is working on a specific project.

| File | Purpose |
|------|---------|
| `projects/{name}/manifest.yaml` | Settings, defaults, status |
| `projects/{name}/characters/{char}/profile.yaml` | Appearance, voice, LoRA, history |
| `projects/{name}/notes.md` | What worked, what didn't |

### Tier 3: Reference (On-Demand)

Large files. Only loaded when a skill explicitly needs them.

| File | Purpose |
|------|---------|
| `references/models.md` | Full model specs + download links |
| `references/workflows.md` | Complete workflow node configs |
| `references/lora-training.md` | Training parameters |
| `references/voice-synthesis.md` | Voice tools in depth |
| `references/prompt-templates.md` | Model-specific prompts |
| `references/troubleshooting.md` | Error database |
| `references/research-2025.md` | Full technique survey |

## Skill Invocation Flow

```
User: "Generate a character portrait"
  |
  CLAUDE.md routing table → "Read skills/comfyui-workflow-builder/SKILL.md"
  |
  Claude reads the skill file
  |
  Skill says: "Check state/inventory.json first"
  |
  Claude reads inventory
  |
  Skill says: "See references/workflows.md for node configs"
  |
  Claude reads the reference file
  |
  Claude generates the workflow JSON
  |
  Skill says: "Queue via comfyui-api"
  |
  Claude reads comfyui-api skill, executes the workflow
```

## Global vs Local

| Scope | What | Why |
|-------|------|-----|
| **Global** (`~/.claude/skills/`) | `comfyui-character-gen` | Pre-existing skill, works standalone |
| **Local** (this repo) | All 12 VideoAgent skills | Session-scoped, loaded via CLAUDE.md |
| **Global** (`~/.claude/settings.json`) | Hooks, MCP servers | User's existing infrastructure |
| **Local** (`.claude/settings.local.json`) | VideoAgent hooks, permissions | Only active in this directory |

## deploy.ps1

Does NOT deploy skills globally. Only syncs reference file updates to the global `comfyui-character-gen` skill so it benefits from research findings.
