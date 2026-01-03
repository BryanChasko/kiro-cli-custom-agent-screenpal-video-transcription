#!/bin/bash

# Performance Optimization Script for ScreenPal Video Transcriber

echo "🚀 Optimizing video processing performance..."

# 1. Check and optimize Ollama settings
echo "📊 Checking Ollama configuration..."
if command -v ollama &> /dev/null; then
    # Set Ollama environment variables for better performance
    export OLLAMA_NUM_PARALLEL=2
    export OLLAMA_NUM_THREAD=4
    export OLLAMA_MAX_LOADED_MODELS=2
    
    # Restart Ollama with optimized settings
    pkill ollama 2>/dev/null
    sleep 2
    ollama serve &
    sleep 5
    
    echo "✅ Ollama optimized with parallel processing"
else
    echo "⚠️  Ollama not found - vision analysis may be slower"
fi

# 2. Optimize FFmpeg settings
echo "🎬 Setting FFmpeg optimization flags..."
export FFMPEG_THREADS=4
export FFMPEG_PRESET=ultrafast
export FFMPEG_CRF=23

# 3. Check system resources
echo "💾 System resource check..."
AVAILABLE_RAM=$(free -m 2>/dev/null | awk 'NR==2{printf "%.0f", $7/1024}' || echo "Unknown")
CPU_CORES=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "4")

echo "   Available RAM: ${AVAILABLE_RAM}GB"
echo "   CPU Cores: ${CPU_CORES}"

# 4. Set optimal thread counts based on system
if [ "$CPU_CORES" -gt 8 ]; then
    export WHISPER_THREADS=6
    export VISION_BATCH_SIZE=6
elif [ "$CPU_CORES" -gt 4 ]; then
    export WHISPER_THREADS=4
    export VISION_BATCH_SIZE=4
else
    export WHISPER_THREADS=2
    export VISION_BATCH_SIZE=2
fi

echo "   Whisper threads: ${WHISPER_THREADS}"
echo "   Vision batch size: ${VISION_BATCH_SIZE}"

# 5. Clean up temp files to free space
echo "🧹 Cleaning temporary files..."
rm -rf /tmp/video-processing-* 2>/dev/null
rm -rf ~/Downloads/video-transcripts/temp-* 2>/dev/null

# 6. Create optimized temp directory with proper permissions
TEMP_DIR="/tmp/video-processing-$(date +%s)"
mkdir -p "$TEMP_DIR"
chmod 755 "$TEMP_DIR"
export VIDEO_TEMP_DIR="$TEMP_DIR"

echo "   Temp directory: $TEMP_DIR"

# 7. Test MCP server connectivity
echo "🔗 Testing MCP server connectivity..."

# Test video-transcriber
if curl -s --max-time 5 http://localhost:8000/health &>/dev/null; then
    echo "✅ video-transcriber MCP server responsive"
else
    echo "⚠️  video-transcriber MCP server may be slow to respond"
fi

# Test Ollama
if curl -s --max-time 5 http://localhost:11434/api/tags &>/dev/null; then
    echo "✅ Ollama API responsive"
else
    echo "⚠️  Ollama API not responding - vision analysis will fail"
fi

echo ""
echo "🎯 Performance optimization complete!"
echo "💡 Tips for faster processing:"
echo "   • Use 'base' Whisper model for speed"
echo "   • Set scene_threshold=0.5 for fewer frames"
echo "   • Process shorter video segments (< 10 minutes)"
echo "   • Close other resource-intensive applications"
echo ""
echo "🚀 Ready for optimized video processing!"
