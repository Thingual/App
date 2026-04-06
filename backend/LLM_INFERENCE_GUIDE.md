# Real LLM Model Inference Setup Guide

## Overview

The Picture Description Assessment module now uses **real LLM model inference** via Python backend with `llama-cpp-python` and GGUF models. No more mock delays - actual language model analysis!

## Architecture

```
Flutter App (iOS/Android/Web)
    ↓ (HTTP POST)
FastAPI Backend (Python)
    ↓ (llama-cpp-python)
TinyLlama 1.1B GGUF Model
```

## Prerequisites

1. **Python 3.10+** installed on backend machine
2. **Backend server running** (can be same machine or network accessible)
3. **Dio package** in Flutter (✅ already installed)
4. **At least 2GB free disk space** for model cache

## Step 1: Install Backend Dependencies

```bash
cd backend
pip install -r requirements.txt
```

This installs `llama-cpp-python` which provides:
- GGUF model loading and execution
- GPU acceleration (if available)
- CPU fallback with threading

## Step 2: Start the Backend Server

**On Windows:**
```bash
cd backend
python start_server.bat
```

**On macOS/Linux:**
```bash
cd backend
bash build.sh
```

Expected output:
```
[LLMService] Configured model path: C:\Users\<user>\.thingual\models\tinyllama.gguf
[LLM API] Received evaluation request
[LLMService] Model not found, downloading...
[LLMService] ✓ Model loaded successfully
[LLMService] Starting inference...
```

The backend will start at: **http://localhost:8000**

## Step 3: Configure Backend URL (Optional)

By default, Flutter connects to `http://localhost:8000`.

To use a different backend:

### Option A: Environment Variable
```bash
# Windows PowerShell
$env:BACKEND_URL="http://192.168.1.100:8000"
flutter run

# macOS/Linux
export BACKEND_URL="http://192.168.1.100:8000"
flutter run
```

### Option B: Modify Code
Edit `lib/features/onboarding/picture_description_test/services/llm_service.dart`:
```dart
String _getBackendUrl() {
  return 'http://your-backend-server:8000';
}
```

## Step 4: Run the Flutter App

```bash
flutter run
```

## How It Works

### Inference Pipeline

When user submits picture description:

1. **Flutter sends request** → `POST /api/llm/evaluate`
   ```json
   {
     "user_response": "A kitchen with people cooking...",
     "keywords": ["kitchen", "people", "cooking"],
     "reference_description": "A modern kitchen with family members preparing meals"
   }
   ```

2. **Backend initializes model** (first request only)
   - Downloads TinyLlama 1.1B GGUF (~490MB) if not cached
   - Loads into memory with llama-cpp-python
   - Takes ~30-60 seconds on first request
   - Cached for subsequent requests

3. **Model runs inference**
   - Temperature: 0.3 (deterministic, consistent scoring)
   - Max tokens: 200
   - Processing time: 5-15 seconds on CPU, <1s on GPU

4. **Backend returns JSON**
   ```json
   {
     "score": 78.5,
     "cefr_level": "B1",
     "breakdown": {
       "grammar": 20,
       "vocabulary": 19,
       "accuracy": 19,
       "detail": 20
     },
     "feedback": "Good description with detailed vocabulary and clear structure."
   }
   ```

5. **Flutter displays result**
   - Shows score with LLM badge
   - Updates assessment record
   - Displays feedback to user

### Console Logging

**Backend logs** (in terminal):
```
[LLMService] ========== LLM INFERENCE START ==========
[LLMService] STEP 1: BUILDING EVALUATION PROMPT
[LLMService] STEP 2: RUNNING INFERENCE
[LLMService]   Tokens used: 87
[LLMService] STEP 3: PARSING MODEL OUTPUT
[LLMService] STEP 4: EVALUATION RESULT
[LLMService]   Score: 78.5/100
[LLMService]   CEFR Level: B1
[LLMService] ========== EVALUATION COMPLETE ==========
```

**Flutter logs** (Android Studio):
```
[LLMService] ========== LLM INFERENCE START ==========
[LLMService] STEP 1: PREPARING REQUEST
[LLMService] STEP 2: BUILDING BACKEND REQUEST
[LLMService] STEP 3: SENDING TO BACKEND
[LLMService] STEP 4: PARSING BACKEND RESPONSE
[LLMService] STEP 5: EXTRACTING SCORES
[LLMService] STEP 6: BUILDING RESULT OBJECT
[LLMService] STEP 7: INFERENCE COMPLETE
[LLMService] Status: SUCCESS ✓
[LLMService] Source: Python Backend (llama-cpp-python)
```

## Performance Characteristics

| Metric | Time | Notes |
|--------|------|-------|
| Model Download (first time) | 2-5 min | Via HTTP from HuggingFace |
| Model Initialization (first request) | 30-60s | CPU: longer, GPU: faster |
| Per-inference (CPU) | 5-15s | TinyLlama 1.1B is very fast for its size |
| Per-inference (GPU) | <1s | If CUDA/Metal available |
| Cached inference | Same as above | Model stays in memory |

## Troubleshooting

### Backend Not Responding
```
❌ INFERENCE ERROR: Connection refused
```

**Solution:**
1. Check if backend is running: `curl http://localhost:8000/health`
2. Verify port 8000 is available: Check firewall
3. Restart backend server

### Model Download Fails
```
❌ Failed to initialize model: HTTP error 404
```

**Solution:**
1. Check internet connection
2. Verify model URL in `llm_service.py`
3. Try manual download:
   ```bash
   python -c "from llama_cpp import Llama; Llama.from_pretrained('..."
   ```

### Out of Memory
```
❌ Failed to initialize model: Insufficient memory
```

**Solution:**
1. Close other applications
2. Use GPU acceleration if available
3. Reduce `n_threads` in `llm_service.py`
4. Use quantized model (already using Q4 4-bit)

### Slow Inference (>30s per request)
```
[LLMService] Inference completed in 35000ms
```

**Solution:**
1. This is normal for CPU inference on slower machines
2. GPU acceleration would help: Install CUDA/Metal
3. Check system resources during inference
4. Optimize prompt size (reduces token count)

## Development Mode

### Run Backend Standalone

```bash
cd backend
python app/main.py
```

Check status:
```bash
curl http://localhost:8000/api/llm/status
```

Response:
```json
{
  "initialized": true,
  "model_path": "/home/user/.thingual/models/tinyllama.gguf",
  "ready": true
}
```

### Test Inference via curl

```bash
curl -X POST http://localhost:8000/api/llm/evaluate \
  -H "Content-Type: application/json" \
  -d '{
    "user_response": "A beautiful kitchen with people cooking together",
    "keywords": ["kitchen", "cooking", "people"],
    "reference_description": "A modern kitchen with family members preparing meals"
  }'
```

### Inspect Model

```bash
python -c "
from llama_cpp import Llama
model = Llama('~/.thingual/models/tinyllama.gguf', n_gpu_layers=-1)
print(f'Loaded: {model.model_path}')
print(f'Context size: {model.n_ctx}')
print(f'GPU layers: {model.n_gpu_layers}')
"
```

## Files Modified

### Backend
- `backend/requirements.txt` - Added `llama-cpp-python`
- `backend/app/services/llm_service.py` - LLM inference wrapper (NEW)
- `backend/app/routers/llm_router.py` - FastAPI endpoints (NEW)
- `backend/app/main.py` - Registered LLM router

### Frontend
- `lib/features/.../services/llm_service.dart` - Changed to HTTP backend calls
- `lib/features/.../picture_description_test_screen.dart` - Uses LLMServiceImpl

## API Specification

### POST /api/llm/evaluate

**Request:**
```json
{
  "user_response": "string (required)",
  "keywords": ["string", "..."],
  "reference_description": "string",
  "image_context": "string (optional)"
}
```

**Response (200):**
```json
{
  "score": 0-100,
  "cefr_level": "A1|A2|B1|B2|C1",
  "breakdown": {
    "grammar": 0-25,
    "vocabulary": 0-25,
    "accuracy": 0-25,
    "detail": 0-25
  },
  "feedback": "string"
}
```

**Error Response (503):**
```json
{
  "detail": "LLM model not available. Please download the model first."
}
```

### GET /api/llm/status

**Response:**
```json
{
  "initialized": boolean,
  "model_path": "string",
  "ready": boolean
}
```

## Next Steps

1. ✅ Real LLM inference via backend
2. Install backend dependencies and start server
3. Run Flutter app and test picture description assessment
4. Monitor logs to verify model inference
5. (Optional) Set up GPU acceleration for faster inference
6. (Optional) Deploy backend to production server

## Support

If you encounter issues:

1. Check console logs on both backend and Flutter app
2. Verify network connectivity between devices
3. Ensure backend URL is correct
4. Check if model file exists at configured path
5. Verify Python dependencies are installed: `pip list | grep llama`

---

**Status**: ✅ Real LLM inference implemented
**Model**: TinyLlama 1.1B GGUF
**Backend**: FastAPI + llama-cpp-python
**Frontend**: Flutter + Dio HTTP client
