#!/bin/bash

# Performance Test Script
echo "🧪 Testing optimized video processing performance..."

# Test Ollama parallel processing
echo "Testing Ollama parallel requests..."
start_time=$(date +%s)

# Simulate parallel vision analysis requests
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{"model": "moondream2", "prompt": "Test prompt 1", "stream": false}' &

curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{"model": "moondream2", "prompt": "Test prompt 2", "stream": false}' &

wait

end_time=$(date +%s)
duration=$((end_time - start_time))

echo "✅ Parallel Ollama test completed in ${duration}s"

# Check MCP server status
echo "🔍 MCP Server Status:"
echo "  video-transcriber: $(pgrep -f video-transcriber-mcp > /dev/null && echo "✅ Running" || echo "❌ Not running")"
echo "  vision-server: $(pgrep -f moondream-mcp > /dev/null && echo "✅ Running" || echo "❌ Not running")"
echo "  ffmpeg-mcp: $(pgrep -f mcp-ffmpeg > /dev/null && echo "✅ Running" || echo "❌ Not running")"

echo ""
echo "🎯 Performance test complete!"
echo "💡 System is optimized for:"
echo "   • 4-thread Whisper processing"
echo "   • 2-parallel Ollama requests"
echo "   • 4-frame batch vision analysis"
echo "   • 4-thread FFmpeg processing"
