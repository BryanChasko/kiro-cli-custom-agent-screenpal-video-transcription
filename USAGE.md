# ScreenPal Video Transcriber Agent - Usage Guide

## Installation

### Prerequisites
1. **Kiro CLI** installed and configured
2. **Docker** installed and running (or native Ollama)
3. **Python 3.8+** with uv package manager
4. **Ollama** service running locally

### Setup Steps

1. **Run automated setup**:
```bash
cd /path/to/kiro-cli-custom-agent-screenpal-video-transcription
chmod +x setup.pl
./setup.pl
```

The setup script will:
- Verify Kiro CLI installation
- Install yt-dlp for video extraction
- Install OpenAI Whisper for transcription
- Build MCP servers from source
- Setup Ollama with Moondream model
- Configure global MCP settings
- Create agent profile
- Verify all components

2. **Verify installation**:
```bash
# Check Ollama models
ollama list

# Test agent
kiro-cli chat --agent screenpal-video-transcriber
```

## Basic Usage

### Starting the Agent
```bash
cd /path/to/kiro-cli-custom-agent-screenpal-video-transcription
kiro-cli chat --agent screenpal-video-transcriber
```

### Process a Video
```
> Please transcribe this ScreenPal video: https://go.screenpal.com/abc123xyz
```

The agent will automatically:
1. Extract audio and transcribe to text
2. Extract video frames and analyze visuals
3. Create unified document with both tracks

**Output files** created in `~/Downloads/video-transcripts-{timestamp}/`:
- `{video-id}-UNIFIED.json` - Structured data
- `{video-id}-UNIFIED.md` - Human-readable walkthrough
- `{video-id}-frames/` - Extracted PNG frames

## Example Workflows

### 1. Tutorial Video Processing
```
Input: "Process this coding tutorial: https://go.screenpal.com/coding-demo"

Expected Output:
- Audio transcript with timestamps
- Visual descriptions of code changes
- Screen change markers for different applications
- Unified JSON and Markdown files in ~/Downloads/video-transcripts-{timestamp}/
```

### 2. Presentation Analysis
```
Input: "Analyze this presentation video: https://go.screenpal.com/presentation-2024"

Expected Output:
- Speaker transcript
- Slide transition markers
- Visual content descriptions
- Temporal context tracking
- Complete synchronized walkthrough
```

### 3. Batch Processing
```
Input: "Process these training videos:
- https://go.screenpal.com/training-01
- https://go.screenpal.com/training-02
- https://go.screenpal.com/training-03"

Expected Output:
- Individual unified transcripts for each video
- Separate directories for each video
- Consistent formatting across all outputs
```

## Output Structure

### Directory Organization
```
~/Downloads/video-transcripts-{timestamp}/
├── {video-id}-UNIFIED.json          # Structured synchronized data
├── {video-id}-UNIFIED.md            # Human-readable walkthrough
├── {video-id}-frames/               # Extracted PNG frames
│   ├── frame_0001.png
│   ├── frame_0002.png
│   └── ...
├── metadata_{video-id}.json         # Video metadata
└── temp_video.mp4                   # Downloaded video file
```

### UNIFIED.json Structure
```json
{
  "video_id": "abc123xyz",
  "url": "https://go.screenpal.com/watch/abc123xyz",
  "duration_seconds": 300.0,
  "synchronized_timeline": [
    {
      "timestamp": 0.0,
      "audio": {
        "segment_id": 0,
        "text": "What the speaker said",
        "start": 0.0,
        "end": 5.2
      },
      "visual": {
        "frame_id": "0001",
        "description": "What's shown on screen",
        "ui_elements": {...}
      },
      "context": "What's happening"
    }
  ]
}
```

### UNIFIED.md Structure
```markdown
# Unified Audio-Visual Transcript

## Complete Synchronized Walkthrough

### 0:00 - Scene Title
**Audio**: What the speaker said...
**Visual**: What's shown on screen...
**Context**: What's happening...
```

## Troubleshooting

### Common Issues

#### MCP Server Not Found
```bash
# Check installation
uvx list | grep video-transcriber
uvx list | grep vision-analysis

# Reinstall if needed
uvx install video-transcriber-mcp --force
```

#### Ollama Connection Error
```bash
# Check Ollama status
curl http://localhost:11434/api/tags

# Restart Ollama
ollama serve
```

#### Video Download Failed
- Verify ScreenPal URL format
- Check internet connection
- Ensure video is public/accessible
- Try alternative URL format

#### Processing Timeout
- Reduce video length or quality
- Use smaller Whisper model
- Decrease frame processing count
- Check available system resources

### Error Messages

#### "Invalid ScreenPal URL"
- URL must be from go.screenpal.com or screenpal.com
- Check for typos in video ID
- Ensure video is publicly accessible

#### "Whisper model not found"
- Model will download automatically on first use
- Check internet connection for download
- Verify sufficient disk space

#### "VLM processing failed"
- Ensure Ollama service is running
- Check if VLM model is downloaded
- Verify Docker is running for Ollama

## Performance Tips

### For Large Videos
- Use base Whisper model for speed
- Reduce scene detection sensitivity
- Process in chunks if memory limited
- Clean temp files regularly

### For High Accuracy
- Use large-v3 Whisper model
- Increase scene detection sensitivity
- Use Llava for detailed visual analysis
- Allow longer processing times

### For Batch Processing
- Process videos sequentially
- Monitor system resources
- Implement progress tracking
- Handle failures gracefully
