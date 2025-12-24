# MCP Server Configuration Guide

## video-transcriber-mcp Server

### Installation
```bash
uvx install video-transcriber-mcp
```

### Configuration
```json
{
  "video-transcriber": {
    "command": "uvx",
    "args": ["video-transcriber-mcp"],
    "env": {
      "WHISPER_MODEL": "base",
      "YOUTUBE_FORMAT": "bestaudio"
    },
    "timeout": 300000
  }
}
```

### Available Tools
- `transcribe_video`: Main transcription tool
- `extract_audio`: Audio extraction only
- `get_video_info`: Metadata extraction

### Environment Variables
- `WHISPER_MODEL`: Model size (base, small, medium, large, large-v2, large-v3)
- `YOUTUBE_FORMAT`: Audio format preference (bestaudio, mp3, wav)
- `WHISPER_DEVICE`: Processing device (cpu, cuda, mps)

## mcp-vision-analysis Server

### Installation
```bash
uvx install mcp-vision-analysis
```

### Prerequisites
- Docker installed and running
- Ollama service running locally
- VLM models downloaded (moondream2, llava)

### Configuration
```json
{
  "vision-analysis": {
    "command": "uvx",
    "args": ["mcp-vision-analysis"],
    "env": {
      "OLLAMA_API_ENDPOINT": "http://localhost:11434",
      "VLM_MODEL": "moondream2",
      "SCENE_THRESHOLD": "0.4"
    },
    "timeout": 180000
  }
}
```

### Available Tools
- `analyze_frames`: Process video frames with VLM
- `detect_scene_changes`: FFmpeg scene detection
- `compare_frames`: Frame-to-frame comparison
- `extract_keyframes`: Keyframe extraction

### Environment Variables
- `OLLAMA_API_ENDPOINT`: Local Ollama instance URL
- `VLM_MODEL`: Vision model (moondream2, llava, llava:13b)
- `SCENE_THRESHOLD`: Scene change sensitivity (0.1-1.0)
- `MAX_FRAMES`: Maximum frames to process per video

## Setup Instructions

### 1. Install Ollama
```bash
# macOS
brew install ollama

# Start Ollama service
ollama serve
```

### 2. Download VLM Models
```bash
# Lightweight model (recommended)
ollama pull moondream2

# Full-featured model
ollama pull llava
```

### 3. Verify Installation
```bash
# Check Ollama status
curl http://localhost:11434/api/tags

# Test video-transcriber-mcp
uvx video-transcriber-mcp --help

# Test vision-analysis
uvx mcp-vision-analysis --help
```

### 4. Add to Kiro Configuration
Add both servers to `~/.kiro/settings/mcp.json` or include in agent configuration.
