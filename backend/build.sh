#!/bin/bash
# Build script for Render deployment
# Simple: just FFmpeg for audio format conversion if needed

set -e

echo "🔧 Installing system dependencies (FFmpeg)..."
apt-get update
apt-get install -y --no-install-recommends ffmpeg

echo "📦 Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

echo "✅ Build complete!"
echo "🔍 Verification:"
ffmpeg -version | head -3
echo "✅ Python packages ready"


