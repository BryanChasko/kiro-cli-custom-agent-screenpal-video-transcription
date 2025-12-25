# Agent Capabilities - screenpal-video-transcriber

## What This Agent CAN Do

### ✅ Audio Transcription
- Extract audio from ScreenPal videos using `transcribe_video` tool
- Generate timestamped text transcripts
- Support multiple audio formats
- Output: TXT, JSON, Markdown formats

### ✅ File Management
- Read and write files using `fs_read` and `fs_write`
- Create analysis templates and structures
- Manage output directories
- Store results locally

### ✅ Image Analysis (Pre-extracted Frames)
- Analyze local image files using `analyze_image` tool
- Describe UI elements, buttons, text, menus
- Detect objects in images
- Generate captions for visual content
- **Requirement**: Frames must be pre-extracted as PNG/JPG files

### ✅ Knowledge Base Management
- Store and retrieve analysis data
- Index transcripts and visual descriptions
- Search across knowledge bases
- Maintain persistent storage

### ✅ Detailed Instructions
- Provide step-by-step guidance for manual processes
- Document workflows and procedures
- Create comprehensive guides
- Explain complex processes

## What This Agent CANNOT Do

### ❌ Direct Frame Extraction
- Cannot invoke `@ffmpeg-mcp/extract_frames_from_video` directly
- Cannot download videos and extract frames in one step
- Cannot execute FFmpeg commands directly
- Cannot invoke MCP tools from chat context

### ❌ Direct Vision Analysis on URLs
- Cannot analyze ScreenPal video URLs directly
- Cannot process video URLs with vision tools
- Cannot extract frames from URLs
- Cannot invoke `@vision-server/*` tools directly

### ❌ Real-time Video Processing
- Cannot stream video processing
- Cannot process videos in real-time
- Cannot monitor video extraction progress
- Cannot execute long-running processes

## Recommended Workflow

### For Audio Transcription Only
```
User: "Transcribe this ScreenPal video"
Agent: Uses transcribe_video → Returns transcript
```

### For Visual Analysis (Hybrid Approach)
```
Step 1: User extracts frames manually
  yt-dlp -f best -o video.mp4 https://go.screenpal.com/watch/cTlX2ZnYYZo
  ffmpeg -i video.mp4 -filter:v "select='gt(scene,0.4)'" -vsync vfr frames/frame_%04d.png

Step 2: Agent analyzes frames
  User: "Analyze frames in frames/ directory"
  Agent: Analyzes each frame → Returns visual descriptions
```

### For Complete Analysis
```
Step 1: User extracts frames
Step 2: Agent transcribes audio
Step 3: Agent analyzes frames
Step 4: Agent correlates timestamps
Step 5: Agent generates synchronized output
```

## Tool Availability

### Available in Agent Chat
- `transcribe_video` - Audio extraction and transcription
- `analyze_image` - Image analysis (local files only)
- `fs_read` - Read files and directories
- `fs_write` - Write and create files
- `knowledge` - Knowledge base operations

### NOT Available in Agent Chat
- `@ffmpeg-mcp/extract_frames_from_video` - Frame extraction
- `@ffmpeg-mcp/get_video_info` - Video metadata
- `@vision-server/analyze_image` - Vision analysis (MCP version)
- `@vision-server/detect_objects` - Object detection
- `@vision-server/generate_caption` - Caption generation

## Documentation References

- [MANUAL_FRAME_EXTRACTION.md](../MANUAL_FRAME_EXTRACTION.md) - Step-by-step frame extraction guide
- [VISUAL_ANALYSIS_STEERING.md](../VISUAL_ANALYSIS_STEERING.md) - Visual analysis workflow
- [agent-mcp-limitations.md](../knowledge/workflow-automation/agent-mcp-limitations.md) - Technical limitations
