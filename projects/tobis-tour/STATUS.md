# Tobis Tour — Opening Film

## Projekt
Opening Film fuer Checker Tobis Live-Show "Tobis Tour".
Wird auf Leinwand vor 4000 Zuschauern gezeigt, endet mit physischer Kapsel-Landung auf der Buehne.

## Was steht
- **Skript**: `skript/Opening Film Tobis Tour 05032026.pdf` (6 Seiten)
- **Stil**: `style.txt` — warm retro-sci-fi, handgebaut, einladend
- **Shotliste**: `shotlists/opening_film_v1.txt` — 22 Shots (13 KI, 9 Live-Dreh)
- **Design**: OrbiTobi 3000 (Variante B) — konisch, grau-weiss-gruen, passt zur Buehnenkapsel

## LoRAs (trainiert, URLs in training/<token>/lora_url.txt)
- `orbitobi3000` — ganzes Schiff (7 Trainingsbilder)
- `orbitobi3000_capsule` — abgetrennte Nase (7 Trainingsbilder)
- `laika_bowl` — Fressnapf (7 Trainingsbilder)

## Referenzbilder
- `output/references/` — erste Version ohne LoRA (Gemini + Flux)
- `output/references_lora/` — zweite Version MIT LoRA (Flux) — deutlich konsistenter

## Noch offen
- Videos generieren via Veo 3.1 (13 Shots, ~$2 Kosten)
- Veo API-Call muss richtig implementiert werden (Image-Parameter war falsch)
- Shot 1 (Sonne) braucht kein LoRA — Gemini-Referenz reicht
- Shots 12+14 (Unterhosen) kein LoRA — Flux-Referenz reicht

## Wichtig
- Tobi wird REAL gedreht — alle INT-Cockpit-Szenen sind Live-Dreh
- Film endet mit Kapsel-Landung auf echter Buehne (tropische Insel mit Wasserfall, Dodo-Vogel)
- Zielgruppe: Familien (2000 Kinder + Erwachsene)
- Tonalitaet: komoediantisch, warmherzig, leicht chaotisch

## API Helper
- `lib/gen.py` — eigene Helper fuer Gemini, Flux, Veo, LoRA-Training
- `.env` — API Keys (FAL_KEY, GOOGLE_API_KEY)
