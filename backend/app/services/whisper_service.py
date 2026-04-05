import os
import tempfile
from functools import lru_cache

from fastapi import HTTPException, UploadFile


@lru_cache(maxsize=1)
def _load_whisper_model():
    try:
        import whisper  # type: ignore
    except Exception as e:  # pragma: no cover
        raise HTTPException(
            status_code=503,
            detail=(
                "Whisper is not available on this server. "
                "Install the 'openai-whisper' package and ensure ffmpeg is installed. "
                f"(import error: {e})"
            ),
        )

    model_name = os.getenv("WHISPER_MODEL", "tiny")

    try:
        # Load model on CPU to avoid memory issues on Render (512MB limit)
        # Use fp16=False to reduce memory usage (uses fp32 instead)
        return whisper.load_model(model_name, device="cpu", in_memory=False)
    except Exception as e:  # pragma: no cover
        raise HTTPException(
            status_code=500,
            detail=f"Failed to load Whisper model '{model_name}': {e}",
        )


async def transcribe_upload(file: UploadFile) -> str:
    if not file.filename:
        raise HTTPException(status_code=400, detail="Missing filename")

    content = await file.read()
    if not content:
        raise HTTPException(status_code=400, detail="Empty file")

    suffix = os.path.splitext(file.filename)[1] or ".m4a"

    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        tmp.write(content)
        tmp_path = tmp.name

    try:
        model = _load_whisper_model()

        # NOTE: Whisper relies on ffmpeg to decode audio formats like m4a.
        result = model.transcribe(tmp_path)
        text = (result.get("text") or "").strip()
        return text
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Transcription failed: {e}")
    finally:
        try:
            os.remove(tmp_path)
        except OSError:
            pass
