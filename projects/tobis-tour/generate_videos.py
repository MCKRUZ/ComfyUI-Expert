"""Generiert alle 13 KI-Shots fuer Tobis Tour via Veo 3.1."""

import sys
sys.path.insert(0, "/Users/janhill/my_python_project/bavaria-entertainment/ComfyUI-Expert")

from pathlib import Path
from lib.gen import video_veo

BASE = Path("/Users/janhill/my_python_project/bavaria-entertainment/ComfyUI-Expert/projects/tobis-tour")
VIDEOS = BASE / "output" / "videos"
REFS_LORA = BASE / "output" / "references_lora"
REFS = BASE / "output" / "references"

STYLE = "Warm retro-sci-fi, handbuilt aesthetic, weathered sheet metal, chipped off-white and pale green paint, visible rivets and welded seams. Deep indigo-blue space, warm star clusters. Warm amber key light from right, cool blue fill from left, gentle lens flares, subtle analog film grain. Smooth cinematic camera movement."

SHOTS = [
    {
        "id": "01",
        "ref": REFS / "shot_01_ref.png",
        "prompt": "The camera slowly tilts down from a blazing golden sun with radiant flares, revealing the vast expanse of deep indigo-blue space filled with warm star clusters. The movement is majestic and unhurried, transitioning from blinding warmth into the serene quiet of the cosmos. Tiny particles of space dust drift through the frame catching the light. Intense golden backlight from sun transitioning to cool blue ambient.",
    },
    {
        "id": "02",
        "ref": REFS_LORA / "shot_02_ref.png",
        "prompt": "A battered metal dog food bowl with LAIKA stenciled on its side tumbles slowly toward the camera in zero gravity, rotating gently end over end. It drifts from the background into sharp focus, light glinting off its dented surface. Small scratches and wear marks become visible as it approaches. Deep space starfield background. Warm amber side light catching the metal rim, cool blue fill, subtle lens flare.",
    },
    {
        "id": "03",
        "ref": REFS_LORA / "shot_03_ref.png",
        "prompt": "A small, battered spacecraft glides smoothly into frame from the right, passing the camera in a slow lateral drift. The ship is weathered and charming with chipped green-white paint, bent antennas, a crooked satellite dish. The tumbling dog bowl bounces lightly off the hull and spins away. Behind the ship, the blue curve of Earth begins to emerge. Warm amber key from right, Earth-glow blue fill from below-left, gentle lens flares.",
    },
    {
        "id": "06",
        "ref": REFS_LORA / "shot_06_ref.png",
        "prompt": "A small retro spacecraft hangs motionless in orbit, tiny against the luminous curve of Earth below and the blazing sun behind. A long, quiet beat — the ship looks impossibly small and alone in the vastness. The camera holds still, letting the silence speak. Golden sun backlight creating rim light on ship, Earth-glow blue from below, deep space darkness above.",
    },
    {
        "id": "09",
        "ref": REFS_LORA / "shot_09_ref.png",
        "prompt": "A small retro spacecraft fires its thrusters in a bright burst of orange flame, pivoting sharply in space. The ship swings around 180 degrees, nose now pointing toward Earth. The main engines ignite with a sustained blue-white glow, and the ship accelerates hard toward the planet, growing smaller as it races away from camera. Thruster glow warm orange, engine burn blue-white, Earth illumination from below.",
    },
    {
        "id": "10",
        "ref": REFS_LORA / "shot_10_ref.png",
        "prompt": "A small battered spacecraft punches through a dense field of tumbling ice chunks and rocky debris, weaving between glowing fragments. Particles bounce off the hull with visible sparks. The ship rolls and banks aggressively, its bent antennas whipping through the debris cloud. Harsh white flashes from impacts, warm amber key, blue-grey debris scatter.",
    },
    {
        "id": "12",
        "ref": REFS / "shot_12_ref.png",
        "prompt": "A pair of white cotton briefs with the name Neil Armstrong embroidered in small blue letters floats serenely through space, tumbling in slow motion. The underwear drifts past the camera in sharp focus against the starfield, absurdly mundane against the cosmic backdrop. Soft even lighting, subtle warm tones.",
    },
    {
        "id": "14",
        "ref": REFS / "shot_14_ref.png",
        "prompt": "A pair of colorful boxer shorts covered in a repeating pattern of cartoon pineapples and tiny faces floats through space, rotating slowly. Embroidered text reads Tobi Krell Marsmission. The underwear catches warm amber light as it tumbles past, oddly cheerful against the void. Warm amber highlight on fabric, cool space fill.",
    },
    {
        "id": "16",
        "ref": REFS_LORA / "shot_16_ref.png",
        "prompt": "A cherry-red Tesla Roadster convertible with a mannequin in a spacesuit at the wheel drifts silently through space, slowly rotating. It passes a small battered retro spacecraft going the opposite direction. The car looks pristine and absurd against the weathered little ship. Warm sunlight on car's glossy paint, cool fill on ship.",
    },
    {
        "id": "18",
        "ref": REFS_LORA / "shot_18_ref.png",
        "prompt": "A conical nose capsule separates from the rear module of a small spacecraft with a burst of vapor and sparks from explosive bolts. The two sections drift apart — the rear module tumbling away while the capsule pitches forward toward Earth. A brief flash of thruster fire stabilizes the capsule's trajectory. Bright separation flash, warm amber on capsule, cool blue on receding module.",
    },
    {
        "id": "19",
        "ref": REFS_LORA / "shot_19_ref.png",
        "prompt": "A small conical capsule plunges into Earth's atmosphere at steep angle. The heat shield glows first dull red, then bright orange, then white-hot. Plasma trails stream behind in brilliant orange and pink ribbons. The capsule shakes and vibrates violently, shedding small flaming fragments. The blue curve of Earth fills the background. Intense orange-white heat glow, plasma illumination.",
    },
    {
        "id": "21",
        "ref": REFS_LORA / "shot_21_ref.png",
        "prompt": "A small capsule splashes down into a tropical ocean near a lush green island with a massive water explosion. A towering white fountain erupts as the capsule disappears beneath the surface. A beat later it bobs back up, rocking in the waves, steam hissing off the scorched heat shield. Vivid turquoise water, bright tropical daylight, warm sun from above.",
    },
    {
        "id": "22",
        "ref": REFS_LORA / "shot_22_ref.png",
        "prompt": "From the churning water beside a floating capsule, enormous purple-grey tentacles of a giant octopus rise slowly, dripping seawater. The tentacles are thick, textured with suckers, and tower over the small capsule. They curl around the capsule menacingly — then with one powerful shove, launch the capsule sideways out of frame at high speed, sending a rooster tail of spray. Bright tropical sun, dramatic water spray.",
    },
]

if __name__ == "__main__":
    for shot in SHOTS:
        out = VIDEOS / f"shot_{shot['id']}.mp4"
        if out.exists():
            print(f"Shot {shot['id']}: schon da, ueberspringe")
            continue
        print(f"\n{'='*60}")
        print(f"Shot {shot['id']} — starte Veo 3.1...")
        print(f"Ref: {shot['ref'].name}")
        try:
            video_veo(
                prompt=f"{shot['prompt']} {STYLE}",
                output=out,
                reference_image=shot["ref"],
            )
            print(f"Shot {shot['id']}: FERTIG -> {out}")
        except Exception as e:
            print(f"Shot {shot['id']}: FEHLER -> {e}")
