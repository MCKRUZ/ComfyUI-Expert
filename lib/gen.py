"""Minimale Bild- und Video-Generierung via Gemini, fal.ai und Veo."""

import os
import time
from pathlib import Path

import fal_client
import requests
from dotenv import load_dotenv
from google import genai
from google.genai import types

load_dotenv(Path(__file__).resolve().parent.parent / ".env")

GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY", "")
FAL_KEY = os.environ.get("FAL_KEY", "")


def image_gemini(prompt: str, output: str | Path) -> Path:
    """Generiert ein Bild via Gemini (Nano Banana Pro)."""
    client = genai.Client(api_key=GOOGLE_API_KEY)
    response = client.models.generate_content(
        model="gemini-3-pro-image-preview",
        contents=str(prompt),
        config=types.GenerateContentConfig(
            response_modalities=["IMAGE", "TEXT"],
            safety_settings=[
                types.SafetySetting(category=c, threshold="BLOCK_NONE")
                for c in [
                    "HARM_CATEGORY_HARASSMENT",
                    "HARM_CATEGORY_HATE_SPEECH",
                    "HARM_CATEGORY_SEXUALLY_EXPLICIT",
                    "HARM_CATEGORY_DANGEROUS_CONTENT",
                ]
            ],
        ),
    )
    output = Path(output)
    for part in response.candidates[0].content.parts:
        if part.inline_data:
            output.write_bytes(part.inline_data.data)
            return output
        if hasattr(part, "file_data") and part.file_data:
            r = requests.get(part.file_data.file_uri, timeout=60)
            output.write_bytes(r.content)
            return output
    raise RuntimeError("Gemini hat kein Bild generiert")


def image_flux(prompt: str, output: str | Path, lora_url: str = "", lora_scale: float = 0.9) -> Path:
    """Generiert ein Bild via fal.ai Flux (optional mit LoRA)."""
    output = Path(output)
    args = {
        "prompt": prompt,
        "image_size": "landscape_16_9",
        "num_images": 1,
    }
    model = "fal-ai/flux/dev"
    if lora_url:
        model = "fal-ai/flux-lora"
        args["loras"] = [{"path": lora_url, "scale": lora_scale}]

    result = fal_client.subscribe(model, arguments=args)
    img_url = result["images"][0]["url"]
    resp = requests.get(img_url, timeout=120)
    output.write_bytes(resp.content)
    return output


def video_veo(prompt: str, output: str | Path, reference_image: str | Path = "") -> Path:
    """Generiert ein Video via Veo 3.1."""
    client = genai.Client(api_key=GOOGLE_API_KEY)
    output = Path(output)

    image = None
    if reference_image:
        ref = Path(reference_image)
        if ref.exists():
            import base64, mimetypes
            mime = mimetypes.guess_type(str(ref))[0] or "image/png"
            b64 = base64.b64encode(ref.read_bytes()).decode()
            image = types.Image(image_bytes=ref.read_bytes(), mime_type=mime)

    kwargs = {
        "model": "veo-3.1-generate-001",
        "prompt": prompt,
        "config": types.GenerateVideosConfig(
            duration_seconds=8,
            aspect_ratio="16:9",
        ),
    }
    if image:
        kwargs["image"] = image

    operation = client.models.generate_videos(**kwargs)
    while not operation.done:
        time.sleep(10)
        operation = client.operations.get(operation)

    if not operation.response or not operation.response.generated_videos:
        raise RuntimeError(f"Veo hat kein Video generiert: {operation}")

    video = operation.response.generated_videos[0]
    resp = requests.get(
        video.video.uri,
        headers={"x-goog-api-key": GOOGLE_API_KEY},
        timeout=300,
    )
    resp.raise_for_status()
    output.write_bytes(resp.content)
    return output


def train_lora(token: str, images_dir: str | Path, captions: dict[str, str]) -> str:
    """Trainiert ein LoRA via fal.ai. Returns: URL des trainierten Modells."""
    import zipfile, tempfile

    images_dir = Path(images_dir)
    # ZIP mit Bildern + Captions
    tmp = Path(tempfile.mktemp(suffix=".zip"))
    with zipfile.ZipFile(tmp, "w") as zf:
        for img in sorted(images_dir.glob("*.png")):
            zf.write(img, img.name)
            caption = captions.get(img.stem, f"{token}")
            zf.writestr(img.stem + ".txt", caption)

    # Upload
    upload = fal_client.upload_file(tmp)
    tmp.unlink()

    # Training starten
    result = fal_client.subscribe(
        "fal-ai/flux-lora-fast-training",
        arguments={
            "images_data_url": upload,
            "trigger_word": token,
            "steps": 1200,
            "create_masks": True,
            "is_style": False,
        },
        with_logs=True,
        on_queue_update=lambda u: print(f"  [{token}] {u}") if hasattr(u, "logs") else None,
    )

    lora_url = result.get("diffusers_lora_file", {}).get("url", "")
    if not lora_url:
        raise RuntimeError(f"Training fehlgeschlagen: {result}")

    return lora_url
