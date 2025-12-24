# ScreenPal Video Transcriber Agent - Platform Setup Guide

## Current Configuration: Mac Mini with GPU Acceleration

### Hardware Requirements
- Mac Mini with Apple Silicon
- Native macOS Ollama installation
- Homebrew for dependency management
- Apple Silicon GPU acceleration for vision model inference

### Setup Process
1. **Install Dependencies**:
   ```bash
   brew install ffmpeg wget
   ```

2. **Install Native Ollama**:
   ```bash
   curl -L https://ollama.com/download/Ollama-darwin.zip -o /tmp/Ollama.zip
   unzip /tmp/Ollama.zip -d /Applications/
   open -a Ollama
   sleep 10
   /Applications/Ollama.app/Contents/Resources/ollama pull moondream
   ```

3. **Build MCP Servers**:
   ```bash
   # Video Transcriber MCP
   git clone https://github.com/nhatvu148/video-transcriber-mcp
   cd video-transcriber-mcp
   npm install && npm run build

   # Moondream MCP
   git clone https://github.com/NightTrek/moondream-mcp
   cd moondream-mcp
   npm install puppeteer tmp @types/tmp
   npm run build
   ```

### Verification
- FFmpeg: `/opt/homebrew/bin/ffmpeg`
- Ollama API: `http://localhost:11434`
- Moondream model: 1.7 GB, GPU-accelerated
- Video transcriber: `/tmp/video-transcriber-mcp/dist/index.js`
- Vision server: `/tmp/moondream-mcp/build/index.js`

### Final MCP Configuration
Update agent config (`.kiro/agents/screenpal-video-transcriber.json`):

**Setup Python Environment**:
```bash
cd /tmp/moondream-mcp
uv venv $TMPDIR/moondream-venv
VIRTUAL_ENV=$TMPDIR/moondream-venv PATH=$TMPDIR/moondream-venv/bin:$PATH uv pip install moondream
```

**video-transcriber-mcp**: Suppress stderr to prevent MCP handshake failure
```json
{
  "video-transcriber": {
    "command": "sh",
    "args": ["-c", "node /tmp/video-transcriber-mcp/dist/index.js 2>/dev/null"],
    "env": {
      "WHISPER_MODEL": "base",
      "YOUTUBE_FORMAT": "bestaudio",
      "WHISPER_DEVICE": "cpu"
    },
    "disabled": false
  }
}
```

**moondream-mcp**: Uses Ollama API directly for vision analysis
```json
{
  "vision-server": {
    "command": "sh",
    "args": ["-c", "node /tmp/moondream-mcp/build/index.js 2>/dev/null"],
    "env": {
      "OLLAMA_BASE_URL": "http://localhost:11434"
    },
    "disabled": false
  }
}
```

**Note (Dec 24, 2025)**: Vision-server now connects to Ollama's `/api/generate` endpoint instead of spawning a local moondream server. This eliminates Python environment setup issues and uses the already-running Ollama instance.

## Alternative Setup: NVIDIA GPU Systems

### Key Differences
- Use Docker-based Ollama instead of native installation
- Requires NVIDIA Container Toolkit
- CUDA drivers and toolkit must be installed

### Modified Setup Process
1. **Install Docker and NVIDIA Container Toolkit**
2. **Run Ollama in Docker**:
   ```bash
   docker run -d --gpus all --name ollama-screenpal -p 11434:11434 ollama/ollama
   docker exec ollama-screenpal ollama pull moondream
   ```

3. **Update MCP Configuration**:
   - Set `OLLAMA_BASE_URL=http://localhost:11434` in moondream-mcp environment
   - Ensure Docker container is running before starting MCP servers
   - Use same MCP configuration format but with Docker-based Ollama

### Architecture Components
- **video-transcriber-mcp**: Node.js MCP server for audio extraction and Whisper transcription
- **moondream-mcp**: Node.js MCP server wrapper that spawns a Python moondream backend for visual analysis
  - Requires: Python 3.8+, UV package manager, moondream Python package
  - Creates temporary Python venv at `$TMPDIR/moondream-venv`
  - Manages model downloads and Python environment automatically
- **FFmpeg**: Audio normalization and frame extraction
- **Ollama**: Model serving (native macOS or Docker)
- **yt-dlp**: Media extraction engine for ScreenPal/YouTube URLs

### Performance Notes
- Mac Mini: Native GPU acceleration, optimal performance
- NVIDIA GPU: Docker overhead, but powerful GPU acceleration
- Both setups support local processing with no external API dependencies
