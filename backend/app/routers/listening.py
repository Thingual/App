from fastapi import APIRouter, UploadFile, File

from ..services.whisper_service import transcribe_upload

router = APIRouter(prefix="/assessment/listening", tags=["assessment"])


@router.post("/transcribe")
async def transcribe_listening_audio(file: UploadFile = File(...)):
    """Transcribe a recorded audio file for the listening assessment."""
    text = await transcribe_upload(file)
    return {"text": text}
