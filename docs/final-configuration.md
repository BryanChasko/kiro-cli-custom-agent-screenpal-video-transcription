# ScreenPal Video Transcriber - Final Configuration

## System Status ✅
- **Mac Mini**: Native Ollama with GPU acceleration
- **FFmpeg**: `/opt/homebrew/bin/ffmpeg`
- **Ollama API**: `http://localhost:11434` (responsive)
- **Moondream Model**: `moondream:latest` (1.7 GB, loaded)

## MCP Server Configuration
**File**: `.kiro/agents/screenpal-video-transcriber.json`

### Agent Tools Configuration
The agent includes `execute_bash` for shell command execution, file cleanup, and directory operations:

```json
{
  "tools": [
    "fs_read",
    "fs_write", 
    "knowledge",
    "execute_bash",
    "@video-transcriber/transcribe_video",
    "@video-transcriber/extract_audio",
    "@video-transcriber/get_video_info",
    "@ffmpeg-mcp/extract_frames_from_video",
    "@ffmpeg-mcp/get_video_info",
    "@vision-server/analyze_image",
    "@vision-server/detect_objects",
    "@vision-server/generate_caption"
  ]
}
```

### Setup
Both servers require output suppression to prevent MCP protocol handshake failures. Diagnostic logs must be filtered before the MCP initialize response.

**Python Environment Setup**:
```bash
cd /tmp/moondream-mcp
uv venv $TMPDIR/moondream-venv
VIRTUAL_ENV=$TMPDIR/moondream-venv PATH=$TMPDIR/moondream-venv/bin:$PATH uv pip install moondream
```

### video-transcriber-mcp (Active)
Prints version/platform info to stderr. Suppressed with `2>/dev/null`.

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

### moondream-mcp (Active)
Node.js wrapper around Python moondream backend. Prints setup logs to stdout. Filtered with grep to remove diagnostic lines.

```json
{
  "vision-server": {
    "command": "sh",
    "args": ["-c", "node /tmp/moondream-mcp/build/index.js 2>&1 | grep -v 'PythonSetup\\|Working directory\\|Venv path\\|Model path\\|Using existing\\|Moondream already'"],
    "env": {
      "OLLAMA_BASE_URL": "http://localhost:11434",
      "MOONDREAM_MODEL_PATH": "/tmp/moondream-mcp/models"
    },
    "disabled": false
  }
}
```

**Troubleshooting**:
If venv becomes corrupted:
```bash
rm -rf $TMPDIR/moondream-venv
cd /tmp/moondream-mcp && uv venv $TMPDIR/moondream-venv
VIRTUAL_ENV=$TMPDIR/moondream-venv PATH=$TMPDIR/moondream-venv/bin:$PATH uv pip install moondream
```

## Built Server Locations
- **Video Transcriber**: `/tmp/video-transcriber-mcp/dist/index.js` (executable)
- **Vision Server**: `/tmp/moondream-mcp/build/index.js` (executable)

## Usage
1. Launch agent: `kiro-cli chat --agent screenpal-video-transcriber`
2. Process video: "Please transcribe this ScreenPal video: https://go.screenpal.com/[video-id]"

## Output
- Combined "Visual State Log" and "Audio Transcript" in single Markdown file
- Local processing with no external API dependencies
- GPU-accelerated vision analysis with Apple Silicon
