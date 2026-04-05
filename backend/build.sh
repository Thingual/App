#!/bin/bash
# Build script for Render deployment
# Installs FFmpeg and Python dependencies

set -e

echo "🔧 Installing system dependencies (FFmpeg)..."
apt-get update
apt-get install -y --no-install-recommends ffmpeg

echo "📦 Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

echo "🗑️  Removing heavy PyTorch dependency (not needed for Whisper on CPU)..."
pip uninstall -y torch
# Also remove nvidia packages which are useless on CPU
pip uninstall -y nvidia-cublas nvidia-cuda-cupti nvidia-cuda-nvrtc nvidia-cuda-runtime nvidia-cudnn-cu13 nvidia-cufft nvidia-cufile nvidia-curand nvidia-cusolver nvidia-cusparse 2>/dev/null || true

echo "✅ Build complete! FFmpeg and Python packages installed."
echo "📊 Instance memory after cleanup:"
free -h
ffmpeg -version | head -3
python -c "import whisper; print('✅ Whisper available')"
