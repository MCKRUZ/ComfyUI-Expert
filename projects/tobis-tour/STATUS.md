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
- `output/references/shot_14_ref_v2.png` — echtes Boxershort-Referenzbild (Bavaria OneDrive)
- `output/references/pov_cockpit_ref.png` — Cockpit-Bullauge fuer einheitliche POVs

## Videos (Veo 3.1 Preview, output/videos/)
### Hauptshots (13 Stueck)
- Shot 01 (Sonne) — OK
- Shot 02 (Laika-Napf) — OK
- Shot 03 (OrbiTobi fliegt vorbei) — regeneriert mit Hero-Ref (Shot 06)
- Shot 06 (OrbiTobi in Orbit) — Hero-Referenz, regeneriert
- Shot 09 (Wende + Thrust) — regeneriert, Kapsel-Problem gefixt
- Shot 10 (Kometenhagel) — regeneriert, Eisflaeche-Problem gefixt
- Shot 12 (Neil Armstrong Unterhose) — NAME FEHLT, muss neu
- Shot 14 (Tobis Boxershorts) — OK, mit echtem Referenzbild
- Shot 16 (Tesla + OrbiTobi) — regeneriert mit Hero-Ref
- Shot 18 (Kapsel-Abtrennung) — OK
- Shot 19 (Re-Entry) — OK
- Shot 21 (Splashdown) — OK
- Shot 22 (Kraken-Wurf) — OK

### POV-Shots (5 Stueck, Gegenschnitt-Material)
- pov_02 (Laika-Napf durchs Bullauge) — mit Bowl-Referenz, pruefen
- pov_10 (Eisbrocken) — ohne Referenz, Bullauge inkonsistent
- pov_12 (Unterhose) — ohne Referenz, Bullauge inkonsistent
- pov_16 (Tesla) — ohne Referenz, Bullauge inkonsistent
- pov_22 (Tentakel) — ohne Referenz, Bullauge inkonsistent

## Noch offen
- POVs mit Cockpit-Referenzbild + Veo Production neu generieren
- Shot 12: Neil Armstrong Name auf Unterhose fehlt
- RunPod + Wan 2.6 oder Kling 3.0 testen (bessere Schiff-Konsistenz)
- Alle Shots ggf. mit Veo 3.1 Production neu generieren
- Komplettes Shot-Review

## Wichtig
- Tobi wird REAL gedreht — alle INT-Cockpit-Szenen sind Live-Dreh
- Film endet mit Kapsel-Landung auf echter Buehne (tropische Insel mit Wasserfall, Dodo-Vogel)
- Zielgruppe: Familien (2000 Kinder + Erwachsene)
- Tonalitaet: komoediantisch, warmherzig, leicht chaotisch

## API Helper
- `lib/gen.py` — eigene Helper fuer Gemini (Nano Banana Pro), Flux, Veo, LoRA-Training
- `.env` — API Keys (FAL_KEY, GOOGLE_API_KEY)
- Bildgen: `gemini-3-pro-image-preview` (Nano Banana Pro)
- Videogen: `veo-3.1-generate-001` (Production)

## Scheduled Agent
- Weekly Research Sweep: Montags 08:00 MESZ
- Trigger: `trig_01QBmhFWdWE7j9A72SuHFqZi`
- https://claude.ai/code/scheduled/trig_01QBmhFWdWE7j9A72SuHFqZi
