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

echo "✅ Build complete! FFmpeg and Python packages installed."
ffmpeg -version | head -3
python -c "import whisper; print('✅ Whisper available')"
