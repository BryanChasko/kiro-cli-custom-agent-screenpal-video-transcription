# FFmpeg MCP Integration for Frame Extraction

## Overview

The `video-creator/ffmpeg-mcp` server provides frame extraction capabilities with scene detection, enabling visual analysis workflows for ScreenPal videos.

## MCP Server Configuration

### Global Configuration (`~/.kiro/settings/mcp.json`)

```json
{
  "ffmpeg-mcp": {
    "command": "uvx",
    "args": ["video-creator"],
    "env": {
      "SCENE_THRESHOLD": "0.4"
    },
    "disabled": false
  }
}
```

### Agent Configuration

Added to `~/.kiro/agents/screenpal-video-transcriber.json`:

```json
{
  "tools": [
    "@ffmpeg-mcp/extract_frames_from_video",
    "@ffmpeg-mcp/get_video_info"
  ],
  "toolsSettings": {
    "@ffmpeg-mcp/extract_frames_from_video": {
      "sceneThreshold": 0.4,
      "outputFormat": "png",
      "allowedDomains": ["go.screenpal.com", "screenpal.com"]
    }
  }
}
```

## Available Tools

### extract_frames_from_video
Extracts frames from video with scene detection.

**Parameters:**
- `url`: ScreenPal video URL
- `output_dir`: Directory for extracted frames
- `scene_threshold`: Scene change sensitivity (0.1-1.0, default 0.4)
- `format`: Output format (png, jpg)

**Output:**
- PNG/JPG frames with timestamp-based naming
- Metadata file with frame timestamps

### get_video_info
Retrieves video metadata.

**Parameters:**
- `url`: ScreenPal video URL

**Output:**
- Duration
- Resolution
- Frame rate
- Codec information

## Workflow Integration

### Step 1: Extract Video Metadata
```
Call: @ffmpeg-mcp/get_video_info
Input: ScreenPal URL
Output: Video duration, resolution, fps
```

### Step 2: Extract Frames at Scene Changes
```
Call: @ffmpeg-mcp/extract_frames_from_video
Input: ScreenPal URL, scene_threshold=0.4
Output: PNG frames in frames/ directory
```

### Step 3: Analyze Frames with Vision Tools
```
For each frame:
  Call: @vision-server/analyze_image
  Input: Frame PNG file
  Output: Visual description
```

### Step 4: Correlate with Audio Transcript
```
Merge audio timestamps with visual frame timestamps
Create synchronized timeline
```

## Complete Workflow Example

```
User: "Analyze this ScreenPal video with visual descriptions"
URL: https://go.screenpal.com/watch/cTlX2ZnYYZo

Step 1: Get metadata
  @ffmpeg-mcp/get_video_info → duration: 300s

Step 2: Extract frames
  @ffmpeg-mcp/extract_frames_from_video → frames/frame_0001.png, frame_0002.png, ...

Step 3: Analyze each frame
  @vision-server/analyze_image(frames/frame_0001.png) → "Desktop showing VS Code"
  @vision-server/analyze_image(frames/frame_0002.png) → "Terminal window opened"

Step 4: Correlate with transcript
  00:00:15 (Audio): "Let me show you the code"
  00:00:15 (Visual): "Desktop showing VS Code with Python file"

Output: Synchronized timeline with audio and visual tracks
```

## Scene Detection Tuning

### Threshold Values
- **0.1-0.2**: Very sensitive, extracts many frames (detailed analysis)
- **0.3-0.4**: Balanced (recommended for most videos)
- **0.5-0.7**: Less sensitive, fewer frames (faster processing)
- **0.8-1.0**: Very insensitive, only major changes

### Recommended Settings by Content Type
- **Code tutorials**: 0.3 (capture editor changes)
- **Presentations**: 0.4 (capture slide transitions)
- **Screen recordings**: 0.35 (balance detail and speed)
- **UI walkthroughs**: 0.25 (capture all interactions)

## Output Format

### Frame Metadata
```json
{
  "frames": [
    {
      "id": "0001",
      "timestamp": 0.0,
      "path": "frames/frame_0001.png",
      "scene_score": 0.95
    },
    {
      "id": "0002",
      "timestamp": 15.3,
      "path": "frames/frame_0002.png",
      "scene_score": 0.87
    }
  ]
}
```

### Synchronized Output
```json
{
  "video_id": "cTlX2ZnYYZo",
  "duration": 300.0,
  "synchronized_timeline": [
    {
      "timestamp": 0.0,
      "type": "audio",
      "text": "Welcome to this tutorial"
    },
    {
      "timestamp": 0.0,
      "type": "visual",
      "description": "Desktop with VS Code editor"
    },
    {
      "timestamp": 15.3,
      "type": "audio",
      "text": "Now let me show you the terminal"
    },
    {
      "timestamp": 15.3,
      "type": "visual",
      "description": "Terminal window opened on desktop"
    }
  ]
}
```

## Troubleshooting

### Frames Not Extracted
- Verify ScreenPal URL is accessible
- Check scene_threshold is appropriate (0.1-1.0)
- Ensure output directory is writable
- Check disk space for frame storage

### Too Many/Few Frames
- Adjust scene_threshold:
  - Lower value (0.2) for more frames
  - Higher value (0.6) for fewer frames
- Check video content (static vs dynamic)

### Vision Analysis Fails on Frames
- Verify frames are valid PNG/JPG files
- Check Ollama service is running
- Ensure moondream2 model is available
- Check frame file paths are absolute

## Performance Considerations

- Frame extraction: ~1-2 seconds per minute of video
- Vision analysis: ~5-10 seconds per frame
- Total time for 5-minute video: ~2-3 minutes
- Disk space: ~50-100MB for extracted frames

## Integration with Existing Workflow

The ffmpeg-mcp server complements existing tools:
- **video-transcriber**: Handles audio extraction and transcription
- **ffmpeg-mcp**: Handles video frame extraction
- **vision-server**: Analyzes extracted frames
- **Agent**: Orchestrates the complete workflow
