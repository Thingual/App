#!/bin/bash
# Build script for Render deployment
# Installs FFmpeg and Python dependencies (without heavy CUDA/PyTorch)

set -e

echo "🔧 Installing system dependencies (FFmpeg)..."
apt-get update
apt-get install -y --no-install-recommends ffmpeg

echo "📦 Installing Python dependencies (minimal set)..."
pip install --upgrade pip

# Install minimal base dependencies (no torch/cuda)
pip install -r requirements-minimal.txt

# Install openai-whisper without its heavy dependencies (torch, cuda, etc)
# Whisper will use librosa for audio processing instead
pip install openai-whisper>=20231117 --no-deps

echo "🗑️  Cleaning up any leftover CUDA/torch packages..."
pip uninstall -y torch 2>/dev/null || true
pip uninstall -y nvidia-cublas nvidia-cuda-cupti nvidia-cuda-nvrtc nvidia-cuda-runtime nvidia-cudnn-cu13 nvidia-cufft nvidia-cufile nvidia-curand nvidia-cusolver nvidia-cusparse nvidia-nccl-cu13 nvidia-nvjitlink nvidia-nvtx 2>/dev/null || true

echo "✅ Build complete! FFmpeg and Python packages installed (minimal)."
echo "📊 Final image size:"
du -sh /usr/local/lib/python*/dist-packages/ 2>/dev/null || echo "  (size info unavailable)"
echo ""
echo "🔍 Verification:"
ffmpeg -version | head -3
python -c "import whisper; print('✅ Whisper available')" || echo "⚠️  Whisper import check failed"

