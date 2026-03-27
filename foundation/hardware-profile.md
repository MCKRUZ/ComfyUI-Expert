# Hardware Profile

## Current Setup
- **Machine**: MacBook (Apple Silicon)
- **GPU**: Keine dedizierte NVIDIA GPU (wird beschafft)
- **Modus**: API-basiert — alle Bildgenerierung läuft über externe APIs

## API-Dienste (verfügbar)

| Dienst | API Key | Zweck |
|--------|---------|-------|
| Google Gemini / Veo | GOOGLE_API_KEY | Bildgenerierung (Nano Banana Pro), Videogenerierung (Veo 3.1), Bildanalyse (Flash) |
| fal.ai | FAL_KEY | Flux LoRA, Flux Pro Kontext, LoRA Training |
| meinGPT | MEINGPT_API_KEY | Text-Workflows (Skript-Analyse, Prompt-Generierung) |

## ComfyUI Desktop
- Installiert unter /Applications/ComfyUI.app
- Custom Nodes: Gemini Direct, fal-API, fal-API-Flux, RequestNodes, KJNodes, GeminiWeb
- Kein lokales Rendering — alle Nodes nutzen externe APIs

## Empfohlene Launch Flags
Keine — API-basiert, kein VRAM-Management nötig.

## Geplant
GPU-Rechner wird beschafft (RTX 4090 oder 5090). Dann Umstellung auf lokale Generierung möglich.
