---
name: licensing-compliance
description: Analyze AI model licensing terms (ToS, EULA, model cards) to assess commercial usability. Evaluates ownership rights, redistribution, attribution requirements, and broadcast/syndication clearance for professional video production. Use when producing content for clients requiring full rights transfer (TV, streaming, advertising).
user-invocable: true
metadata: {"openclaw":{"emoji":"⚖️","os":["darwin","linux","win32"]}}
---

# Licensing Compliance Skill

Evaluate whether AI-generated content from specific models can be used commercially — especially in contexts where **full rights transfer** to a client (TV broadcaster, streaming platform, advertising agency) is required.

## Why This Matters

Commercial video production often requires:
- **Full buyout / all-rights-transferred** contracts
- Guarantees that no third-party IP claims exist
- Compliance with broadcast standards (ARD/ZDF, BBC, Netflix, etc.)
- E&O (Errors & Omissions) insurance eligibility
- Chain-of-title documentation

AI-generated content introduces new risks: unclear ownership, restrictive model licenses, training data contamination, and evolving legal frameworks.

## Workflow

```
LICENSING CHECK REQUEST
    |
    |-- 1. Identify all models used in pipeline
    |       (checkpoint, LoRA, VAE, upscaler, TTS, etc.)
    |
    |-- 2. For each model, evaluate:
    |       |-- License type (Apache 2.0, MIT, CreativeML, custom EULA)
    |       |-- Commercial use explicitly permitted?
    |       |-- Output ownership clause
    |       |-- Attribution requirements
    |       |-- Redistribution / sublicensing rights
    |       |-- Geographic restrictions
    |       |-- Content restrictions (no deepfakes, etc.)
    |       |-- Training data provenance (if known)
    |
    |-- 3. Generate compliance report
    |       |-- Per-model risk rating
    |       |-- Pipeline-level clearance assessment
    |       |-- Required attributions list
    |       |-- Recommended disclaimers
    |
    |-- 4. Flag issues & suggest alternatives
```

## License Categories

### Tier 1: Commercially Clear (Low Risk)

Models with explicit commercial use grants and clear output ownership.

| License Type | Commercial Use | Output Ownership | Attribution | Examples |
|-------------|:-:|:-:|:-:|---------|
| **Apache 2.0** | Yes | User owns outputs | Required (license text) | Qwen-TTS, some HuggingFace models |
| **MIT** | Yes | User owns outputs | Required (minimal) | Chatterbox, F5-TTS |
| **CC0 / Public Domain** | Yes | User owns outputs | None | Rare for AI models |

### Tier 2: Commercially Usable with Conditions (Medium Risk)

Models that allow commercial use but impose conditions that may conflict with full-rights-transfer contracts.

| License Type | Commercial Use | Conditions | Risk Factor |
|-------------|:-:|------------|-------------|
| **CreativeML Open RAIL-M** | Yes, with restrictions | No illegal content, no medical/legal advice, must include license copy | Content restrictions may conflict with some productions |
| **FLUX.1 Dev License** | Yes (paid tier) | Requires API license for >$1M revenue companies | Revenue threshold |
| **Stability Community License** | Yes (<$1M revenue) | Revenue cap, attribution | Revenue threshold |
| **Model-specific EULA** | Varies | Read carefully | Case-by-case |

### Tier 3: Non-Commercial or Unclear (High Risk)

Models that prohibit or don't address commercial use.

| License Type | Commercial Use | Risk Factor |
|-------------|:-:|-------------|
| **CC-BY-NC** | No | Explicitly non-commercial |
| **Research-only** | No | Academic use only |
| **No license specified** | Unclear | No legal basis for commercial use |
| **Custom restrictive** | Usually No | May prohibit derivative works |

## Model-Specific Assessments

> **Important**: These assessments reflect the state of knowledge at the time of writing. **Always verify current terms** before production use. Use `comfyui-research` skill or WebSearch to fetch the latest ToS.

### Image Generation Models

| Model | License | Commercial | Output Ownership | Key Restrictions | Risk |
|-------|---------|:-:|:-:|-----------------|:---:|
| **FLUX.2 [dev]** | FLUX Pro License | Yes (paid) | User owns | Revenue-based tiers; enterprise license for >$1M | Medium |
| **FLUX.2 [klein]** | FLUX Pro License | Yes (paid) | User owns | Same as FLUX.2 dev | Medium |
| **FLUX.1 [dev]** | FLUX.1 Dev EULA | Yes (paid) | User owns | Non-commercial for free tier; paid license required | Medium |
| **FLUX.1 [schnell]** | Apache 2.0 | Yes | User owns | Attribution required | Low |
| **FLUX Kontext** | FLUX Pro License | Yes (paid) | User owns | Requires commercial license | Medium |
| **Stable Diffusion XL** | Stability Community | Yes (<$1M) | User owns | Revenue cap; larger companies need enterprise license | Medium |
| **Stable Diffusion 1.5** | CreativeML Open RAIL-M | Yes, conditional | User owns | Content restrictions apply | Low-Medium |
| **RealVisXL** | CreativeML Open RAIL-M | Yes, conditional | User owns | Inherits base model license | Low-Medium |
| **Qwen-Image 2.0** | Apache 2.0 | Yes | User owns | Attribution required | Low |
| **Reve Image 1.0** | Cloud/Partner | Check ToS | Check ToS | Platform-dependent terms | Medium-High |
| **Seedream 5.0** | Cloud/Partner | Check ToS | Check ToS | Platform-dependent terms | Medium-High |

### Video Generation Models

| Model | License | Commercial | Output Ownership | Key Restrictions | Risk |
|-------|---------|:-:|:-:|-----------------|:---:|
| **Wan 2.1/2.2/2.6** | Apache 2.0 | Yes | User owns | Attribution required; no deepfakes per acceptable use | Low |
| **Wan 2.2 MoE** | Apache 2.0 | Yes | User owns | Same as Wan base | Low |
| **LTX-Video 2.x** | LTX License | Yes | User owns | Check current version terms | Low-Medium |
| **HunyuanVideo** | Tencent HunyuanVideo License | Yes, conditional | User owns | Content restrictions; no harmful/illegal content | Low-Medium |
| **FramePack** | Apache 2.0 | Yes | User owns | Attribution required | Low |
| **AnimateDiff V3** | Apache 2.0 | Yes | User owns | Attribution required | Low |
| **SkyReels V1** | Check license | Check | Check | Verify current terms | Medium |
| **Kling 3.0** | Cloud/Partner | Check ToS | Check ToS | Platform terms apply; API usage agreement | Medium-High |
| **Seedance 2.0** | Cloud/Partner | Check ToS | Check ToS | Platform terms apply | Medium-High |
| **Grok Ref-to-Video** | xAI ToS | Check ToS | Check ToS | xAI platform terms; verify commercial clause | Medium-High |

### Voice / TTS Models

| Model | License | Commercial | Output Ownership | Key Restrictions | Risk |
|-------|---------|:-:|:-:|-----------------|:---:|
| **Qwen3-TTS** | Apache 2.0 / Qwen License | Yes | User owns | Attribution; check voice cloning restrictions | Low |
| **Chatterbox** | MIT | Yes | User owns | Minimal restrictions | Low |
| **F5-TTS** | MIT | Yes | User owns | Minimal restrictions | Low |
| **IndexTTS-2** | Check license | Check | Check | Verify current terms | Medium |
| **VibeVoice** | Microsoft License | Check | Check | Microsoft terms may restrict some uses | Medium |
| **Higgs Audio 2** | Check license | Check | Check | Verify Boson AI terms | Medium |

### Identity Preservation / Face Models

| Model | License | Commercial | Key Risk |
|-------|---------|:-:|---------|
| **InfiniteYou** | Check ByteDance terms | Check | Deepfake concerns; some jurisdictions restrict face synthesis |
| **PuLID** | Check license | Check | Face identity transfer has legal implications |
| **InstantID** | Apache 2.0 | Yes | Face synthesis; consent of depicted person required |
| **IP-Adapter** | Apache 2.0 | Yes | Reference image rights must be cleared separately |

## Compliance Report Template

When the user requests a licensing check, generate a report in this format:

```markdown
# Licensing Compliance Report

**Project**: {project name}
**Date**: {date}
**Pipeline**: {description of what's being produced}
**Target Use**: {e.g., "TV broadcast, full rights transfer to ARD"}

## Pipeline Components

| Component | Model | License | Commercial | Risk |
|-----------|-------|---------|:-:|:---:|
| Image Gen | FLUX.2 dev | FLUX Pro (paid) | Yes | Low |
| Video Gen | Wan 2.2 MoE | Apache 2.0 | Yes | Low |
| Voice | Chatterbox | MIT | Yes | Low |
| Upscaler | RealESRGAN | BSD-3 | Yes | Low |
| Face ID | InstantID | Apache 2.0 | Yes | Medium* |

*Face identity: consent of depicted person required

## Overall Assessment

**Clearance Level**: [GREEN / YELLOW / RED]

- GREEN: All components commercially cleared. Full rights transfer possible.
- YELLOW: Commercially usable but conditions apply. Review required.
- RED: One or more components block commercial use or full rights transfer.

## Required Attributions

{List of all required attributions per model license}

## Required Actions

{List of things the user must do: obtain licenses, get consent, etc.}

## Recommended Disclaimers

{Suggested legal disclaimers for contracts with clients}

## Risk Notes

{Any additional concerns: training data provenance, jurisdiction-specific
rules, evolving regulations, etc.}
```

## Special Considerations

### Deepfake / Face Synthesis Laws

Many jurisdictions have specific laws regarding synthetic faces:

| Region | Key Regulation | Implication |
|--------|---------------|-------------|
| **EU** | AI Act (2024/2026) | AI-generated content must be labeled; deepfakes require disclosure |
| **Germany** | KunstUrhG + DSGVO | Right to own image; consent required for face synthesis |
| **USA (varies)** | State laws (CA, TX, etc.) | Some states prohibit non-consensual deepfakes |
| **UK** | Online Safety Act | Deepfake restrictions in certain contexts |
| **China** | Deep Synthesis Provisions | Registration + labeling required |

### Training Data Provenance

For highest clearance level (e.g., E&O insurance):

1. **Known-clean training data**: Models trained on licensed/public domain data only
2. **Opt-out honored**: Models that respect artist opt-outs (e.g., Spawning/HaveIBeenTrained)
3. **No known lawsuits**: Check if the model provider faces active IP litigation

Current litigation landscape (check for updates):
- Stability AI: Multiple ongoing lawsuits re: training data
- Midjourney: Class action re: artist rights
- OpenAI: Various copyright claims

### LoRA and Fine-tuned Models

LoRAs inherit the base model's license **plus** their own:
- Check base model license first
- Then check LoRA-specific license
- Training data for the LoRA must also be rights-cleared
- Custom LoRAs trained on your own data: you control the rights

### Cloud/Partner Node Models

Models accessed via ComfyUI Partner Nodes (API-based):
- Subject to the **platform's ToS**, not just the model license
- Output ownership may differ from self-hosted versions
- Usage may be logged/monitored
- Rate limits and costs apply
- **Always read the specific API ToS** before commercial use

## Research Integration

When terms are unclear or potentially outdated:

1. Use `comfyui-research` skill to find the latest license/ToS
2. WebSearch for `"{model name}" commercial license terms of service {current year}`
3. Check the model's HuggingFace/GitHub page for LICENSE file
4. Look for official blog posts or FAQs about commercial use
5. Update the assessment in project notes

## Disclaimer

> **This skill provides informational guidance only and does not constitute legal advice.** AI-generated content licensing is a rapidly evolving area of law. For production use — especially broadcast, syndication, or contracts involving full rights transfer — **always consult a qualified media/IP attorney** in your jurisdiction. The assessments in this skill reflect publicly available information and may become outdated as model providers update their terms.

## Integration Points

| Connects To | Purpose |
|------------|---------|
| `comfyui-inventory` | Identify all models in use |
| `comfyui-research` | Fetch latest license terms |
| `comfyui-workflow-builder` | Validate model choices before building |
| `video-publisher` | Pre-publish rights verification |
| `project-manager` | Store compliance reports per project |

## Recommended Workflow Position

```
Plan → [LICENSE CHECK] → Generate → Assemble → [FINAL LICENSE CHECK] → Publish
```

Two checkpoints:
1. **Pre-production**: Before committing to specific models
2. **Pre-publish**: Final verification before delivery to client
