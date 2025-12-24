# MCP Server Sources and Integration

## video-transcriber-mcp

**Source**: https://github.com/nhatvu148/video-transcriber-mcp

### Features
- yt-dlp integration for video extraction
- OpenAI Whisper for speech-to-text
- Support for multiple audio formats
- Configurable model selection

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
      "YOUTUBE_FORMAT": "bestaudio",
      "WHISPER_DEVICE": "cpu"
    }
  }
}
```

### Available Tools
- `transcribe_video`: Full video transcription
- `extract_audio`: Audio extraction only
- `get_video_info`: Metadata extraction

## mcp-vision-analysis

**Source**: https://github.com/lucas-labs/mcp-vision-analysis

### Features
- Integration with local VLM services
- FFmpeg scene detection
- Frame extraction and analysis
- Temporal context tracking

### Installation
```bash
uvx install mcp-vision-analysis
```

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
    }
  }
}
```

### Available Tools
- `analyze_frames`: VLM frame analysis
- `detect_scene_changes`: FFmpeg scene detection
- `compare_frames`: Frame comparison
- `extract_keyframes`: Keyframe extraction

## Integration Architecture

### Pipeline Flow
1. **ScreenPal URL** → video-transcriber-mcp
2. **yt-dlp extraction** → Audio + Video streams
3. **FFmpeg processing** → 16kHz mono PCM + keyframes
4. **Parallel processing**:
   - Whisper → Timestamped transcript
   - VLM → Visual descriptions
5. **Output merger** → Annotated knowledge base entry

### Data Flow
```
ScreenPal URL
    ↓
yt-dlp (video-transcriber-mcp)
    ↓
Audio Stream ────→ Whisper ────→ Transcript
    ↓                              ↓
Video Stream ────→ FFmpeg ────→ Keyframes ────→ VLM ────→ Visual Analysis
                                                          ↓
                                              Combined Output → ./knowledge/
```

### Error Handling
- Automatic retry on network failures
- Fallback to lower quality streams
- Graceful degradation on model failures
- Comprehensive logging for debugging
