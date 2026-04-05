from fastapi import APIRouter

router = APIRouter(prefix="/assessment/listening", tags=["assessment"])


# NOTE: Speech-to-text transcription now happens on the client (Flutter app)
# using native device speech recognition (iOS Speech Framework, Android STT)
# This keeps the backend lightweight and transcription is faster/more private
