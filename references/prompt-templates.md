# Prompt Templates

Model-specific prompt patterns for consistent, high-quality results.

<!-- Updated: 2026-02-06 | Source: Community best practices + comfyui-character-gen -->

---

## FLUX.1-dev Prompts

FLUX responds best to natural language descriptions. Low CFG (3.5-4).

### Photorealistic Portrait
```
photorealistic portrait of {trigger_word}, {description}, detailed skin texture with pores,
natural lighting, shallow depth of field, dslr quality, 8k uhd, shot on Canon EOS R5
```

### Negative (FLUX)
```
blurry, low quality, distorted, deformed, ugly, bad anatomy, bad hands, text, watermark,
signature, oversaturated, underexposed, overexposed
```

### Character in Scene
```
{trigger_word}, {description}, {action/pose}, in {setting}, {lighting}, cinematic composition,
professional photography, 8k resolution
```

---

## SDXL Prompts

SDXL benefits from quality tags and style mixing. CFG 7-9.

### Photorealistic Portrait
```
{trigger_word}, masterpiece, best quality, photorealistic portrait of {description},
detailed skin texture, natural lighting, skin pores, freckles, 8k uhd, dslr quality,
RAW photo, film grain
```

### Negative (SDXL)
```
(worst quality:1.4), (low quality:1.4), 3d render, cartoon, anime, illustration, painting,
drawing, plastic skin, smooth skin, airbrushed, cgi, video game, blurry, deformed,
bad anatomy, bad hands, extra fingers, missing fingers, watermark, text, signature
```

### Character with Emotion
```
{trigger_word}, {description}, {emotion} expression, {pose}, {clothing},
{background/setting}, {lighting_style}, professional photography, 8k
```

---

## Wan 2.1/2.2 Video Prompts

Wan uses natural descriptions for motion and scene. Keep prompts concise.

### Talking Head
```
{description}, person talking naturally, slight head movements, indoor setting,
soft lighting, eye contact with camera, natural expression changes
```

### Character Action
```
{description}, {specific action}, smooth motion, {setting}, cinematic lighting,
high quality, detailed
```

### Negative (Wan)
```
static, frozen, jerky motion, low quality, blurry, distorted face, bad anatomy,
glitch, artifacts
```

---

## AnimateDiff Prompts

Keep descriptions focused on motion. Resolution-aware (512x512 training).

### Motion Sequence
```
{trigger_word}, {description}, {motion description}, smooth animation,
{setting}, {lighting}
```

### Camera Motion (with Motion LoRA)
```
{trigger_word}, {description}, {scene}, camera slowly {pans/zooms/tilts},
cinematic, smooth motion
```

---

## Identity Method Prompt Modifiers

### With InstantID (append to positive)
```
, highly detailed face, sharp features, realistic skin
```
Note: Keep CFG at 4-5. Higher causes "burning" artifacts.

### With PuLID (append to positive)
```
, natural appearance, realistic portrait, photographic quality
```
Note: Method "neutral" works best for realistic output.

### With IP-Adapter FaceID
```
, consistent face, identity preserved, natural expression
```
Note: weight_type "style transfer" best for 3D-to-realistic conversion.

---

## Emotion/Expression Keywords

| Emotion | Prompt Keywords |
|---------|----------------|
| Happy | warm smile, genuine laugh, bright eyes, joyful expression |
| Serious | focused gaze, determined expression, neutral mouth, intense eyes |
| Sad | downcast eyes, slight frown, melancholic expression, soft gaze |
| Confident | direct eye contact, slight smirk, chin up, assured expression |
| Surprised | wide eyes, raised eyebrows, open mouth, shocked expression |
| Thoughtful | looking away, hand on chin, contemplative gaze, pensive |

## Lighting Keywords

| Style | Keywords |
|-------|----------|
| Studio | studio lighting, softbox, key light, professional |
| Natural | natural daylight, golden hour, window light, soft shadows |
| Dramatic | chiaroscuro, rim lighting, high contrast, moody |
| Flat | even lighting, diffused, minimal shadows, bright |
| Cinematic | anamorphic, film lighting, color grading, atmospheric |
