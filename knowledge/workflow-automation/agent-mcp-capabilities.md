# Agent MCP Tool Capabilities

## Current Status

The screenpal-video-transcriber agent **CAN directly invoke MCP tools** from the chat context.

## Available Tools - FULLY CALLABLE

### Video Processing
- `@ffmpeg-mcp/extract_frames_from_video` - Extract frames with scene detection
- `@ffmpeg-mcp/get_video_info` - Get video metadata
- `@video-transcriber/transcribe_video` - Audio extraction and transcription
- `@video-transcriber/extract_audio` - Audio extraction only
- `@video-transcriber/get_video_info` - Video metadata

### Visual Analysis
- `@vision-server/analyze_image` - Analyze frames with VLM
- `@vision-server/detect_objects` - Detect objects in frames
- `@vision-server/generate_caption` - Generate captions

### Standard Tools
- `transcribe_video` - Audio transcription
- `analyze_image` - Image analysis
- `fs_read`, `fs_write` - File operations
- `knowledge` - Knowledge base

## Complete Workflow

The agent orchestrates the complete visual analysis pipeline:

1. **Get Video Metadata**: `@ffmpeg-mcp/get_video_info`
2. **Extract Frames**: `@ffmpeg-mcp/extract_frames_from_video` with scene detection
3. **Analyze Frames**: `@vision-server/analyze_image` on each extracted frame
4. **Correlate**: Map visual descriptions to audio transcript timestamps
5. **Output**: Save synchronized analysis with both audio and visual tracks

## Execution

The agent can execute the complete workflow in a single request:

```
Extract frames from https://go.screenpal.com/watch/cTlX2ZnYYZo and analyze what's shown on screen.
For each frame, describe all UI elements, buttons, text, menus, and visual content.
Include exact text, button labels, window titles, and interface details.
Save the complete analysis to /Users/bryanchasko/Downloads/video-transcripts/cTlX2ZnYYZo-visual-analysis.json
```

The agent will:
1. Call @ffmpeg-mcp/get_video_info to get metadata
2. Call @ffmpeg-mcp/extract_frames_from_video to extract PNG frames
3. Call @vision-server/analyze_image on each frame
4. Populate the output JSON with detailed visual descriptions
5. Save results to the specified location

## Processing Pipeline

```
ScreenPal URL
    ↓
@ffmpeg-mcp/get_video_info (get duration, resolution)
    ↓
@ffmpeg-mcp/extract_frames_from_video (extract PNG frames at scene changes)
    ↓
For each frame:
  @vision-server/analyze_image (detailed UI analysis)
    ↓
Correlate timestamps with audio transcript
    ↓
Generate synchronized output JSON
    ↓
Save to /Users/bryanchasko/Downloads/video-transcripts/
```

## Expected Output

```json
{
  "video_id": "cTlX2ZnYYZo",
  "frames": [
    {
      "frame_id": "0001",
      "timestamp": 0.0,
      "audio_text": "Hello, starting creating this video...",
      "visual_description": "Detailed description with all UI elements",
      "ui_elements": {
        "window_title": "Exact window title",
        "buttons": [{"label": "Button text", "location": "top-right"}],
        "text_visible": ["All readable text"],
        "menus": [{"name": "File", "items": ["New", "Open"]}],
        "data_displayed": {"type": "spreadsheet", "content": "..."}
      }
    }
  ]
}
```

## Performance

- Frame extraction: 2-3 minutes
- Visual analysis: 1-2 minutes (5-10 seconds per frame)
- Total: 3-5 minutes for complete analysis
