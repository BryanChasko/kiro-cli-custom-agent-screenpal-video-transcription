# Unified Workflow - ScreenPal Video Transcriber

## Overview

The ScreenPal Video Transcriber agent now provides a complete unified workflow that automatically:

1. **Extracts and transcribes audio** to text using OpenAI Whisper
2. **Extracts and analyzes video frames** using FFmpeg and Moondream2 VLM
3. **Creates synchronized documents** correlating audio and visual by timestamp

All in a single request - no manual tool selection needed.

## Complete Workflow

### Input
```
User: "Please transcribe this ScreenPal video: https://go.screenpal.com/cTlX2ZnYYZo"
```

### Processing Pipeline

```
ScreenPal URL
    ↓
[Stage 1: Audio Extraction]
    ├─ yt-dlp downloads video
    ├─ FFmpeg extracts audio stream
    └─ Whisper transcribes to text with timestamps
    ↓
[Stage 2: Visual Analysis]
    ├─ FFmpeg extracts frames at scene changes (threshold: 0.4)
    ├─ Moondream2 analyzes each frame
    └─ Generates visual descriptions with UI element details
    ↓
[Stage 3: Unified Document Creation]
    ├─ Correlates audio segments with visual frames by timestamp
    ├─ Creates synchronized JSON structure
    ├─ Generates human-readable Markdown walkthrough
    └─ Saves all outputs to ~/Downloads/video-transcripts-{timestamp}/
```

### Output

Three files created in `~/Downloads/video-transcripts-{timestamp}/`:

#### 1. `{video-id}-UNIFIED.json`
Structured data combining audio and visual:
```json
{
  "video_id": "cTlX2ZnYYZo",
  "url": "https://go.screenpal.com/watch/cTlX2ZnYYZo",
  "duration_seconds": 357.0,
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

#### 2. `{video-id}-UNIFIED.md`
Human-readable synchronized walkthrough:
```markdown
### 0:00 - Scene Title
**Audio**: What the speaker said...
**Visual**: What's shown on screen...
**Context**: What's happening...
```

#### 3. `{video-id}-frames/`
Directory containing all extracted PNG frames:
- `frame_0001.png` - First key scene
- `frame_0002.png` - Second key scene
- ... (one frame per scene change)

## Key Features

### Automatic Correlation
- Audio segments automatically matched to visual frames by timestamp
- No manual synchronization needed
- Precise timing for each entry

### Complete Context
- Audio: Exact text with start/end times
- Visual: Detailed UI descriptions with element inventory
- Context: Explanation of what's happening

### Organized Output
- Timestamped subdirectory prevents file clutter
- Structured JSON for database integration
- Readable Markdown for human review
- Frame files for reference

### Privacy & Performance
- All processing happens locally
- No cloud dependencies
- Optimized frame extraction (scene detection)
- Efficient VLM analysis

## Usage

### Basic Usage
```bash
cd /path/to/kiro-cli-custom-agent-screenpal-video-transcription
kiro-cli chat --agent screenpal-video-transcriber
```

### Process a Video
```
> Please transcribe this ScreenPal video: https://go.screenpal.com/cTlX2ZnYYZo
```

The agent will:
1. Validate the URL
2. Download the video
3. Extract and transcribe audio
4. Extract and analyze frames
5. Create unified documents
6. Save to `~/Downloads/video-transcripts-{timestamp}/`

### Output Location
All files are saved in a timestamped directory:
```
~/Downloads/video-transcripts-2025-12-24T18-03-24/
├── cTlX2ZnYYZo-UNIFIED.json
├── cTlX2ZnYYZo-UNIFIED.md
├── cTlX2ZnYYZo-frames/
│   ├── frame_0001.png
│   ├── frame_0002.png
│   └── ...
├── metadata_cTlX2ZnYYZo.json
└── temp_video.mp4
```

## Processing Details

### Audio Transcription
- **Tool**: OpenAI Whisper
- **Model**: base (configurable to large-v3)
- **Output**: Timestamped text segments
- **Accuracy**: ~95% for clear speech

### Visual Analysis
- **Frame Extraction**: FFmpeg with scene detection
- **Threshold**: 0.4 (balanced sensitivity)
- **VLM Model**: Moondream2 (local, no cloud)
- **Analysis**: UI elements, text, buttons, layouts

### Synchronization
- **Method**: Timestamp-based correlation
- **Precision**: Frame-level accuracy
- **Output**: Merged timeline with both tracks

## Performance

### Processing Time
- Frame extraction: 2-3 minutes
- Visual analysis: 1-2 minutes (5-10 seconds per frame)
- Total: 3-5 minutes for typical 5-minute video

### Resource Requirements
- RAM: 4GB minimum
- Disk: 5GB for models + video storage
- CPU: Multi-core recommended
- GPU: Optional (Ollama uses GPU if available)

### Optimization Tips
- Use base Whisper model for speed
- Reduce scene threshold for fewer frames
- Process shorter videos first
- Monitor disk space

## Integration

### Knowledge Base Integration
The JSON output is ready for knowledge base storage:
```python
# Example: Store in knowledge base
knowledge.add(
    name="video_cTlX2ZnYYZo",
    value=unified_json_content
)
```

### Database Integration
Structured format suitable for:
- Document databases (MongoDB, CouchDB)
- Vector databases (Pinecone, Weaviate)
- SQL databases (with JSON columns)
- Search engines (Elasticsearch)

### Workflow Integration
Can be used in:
- Content analysis pipelines
- Training material documentation
- Video indexing systems
- Accessibility tools

## Troubleshooting

### Common Issues

**"Invalid ScreenPal URL"**
- Ensure URL is from go.screenpal.com or screenpal.com
- Check for typos in video ID
- Verify video is publicly accessible

**"Whisper model not found"**
- Model downloads automatically on first use
- Check internet connection
- Verify disk space (2GB+ for models)

**"VLM processing failed"**
- Ensure Ollama service is running
- Check if moondream2 model is downloaded
- Verify Docker is running (if using Docker Ollama)

**"Processing timeout"**
- Reduce video length
- Use smaller Whisper model
- Decrease frame count
- Check system resources

## Future Enhancements

Potential improvements:
- Batch processing multiple videos
- Custom scene detection thresholds
- Alternative VLM models (Llava, etc.)
- Speaker identification
- Confidence scores
- Interactive timeline visualization
- Export to multiple formats

## Summary

The unified workflow provides a complete solution for:
- ✅ Understanding what was said (audio transcript)
- ✅ Understanding what was shown (visual analysis)
- ✅ Correlating both by timestamp (synchronized document)
- ✅ Storing for future reference (JSON + Markdown)

All in one simple request to the agent.
