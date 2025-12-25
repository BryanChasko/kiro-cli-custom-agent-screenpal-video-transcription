# Agent MCP Tool Capabilities - Updated

## Current Status

The screenpal-video-transcriber agent **CAN directly invoke MCP tools** from the chat context.

## Available Tools

### MCP Tools - FULLY CALLABLE
- `@video-transcriber/transcribe_video` - Audio extraction and transcription
- `@video-transcriber/extract_audio` - Audio extraction only
- `@video-transcriber/get_video_info` - Video metadata
- `@ffmpeg-mcp/extract_frames_from_video` - Frame extraction with scene detection
- `@ffmpeg-mcp/get_video_info` - Video information
- `@vision-server/analyze_image` - Visual analysis of frames
- `@vision-server/detect_objects` - Object detection in frames
- `@vision-server/generate_caption` - Caption generation

### Standard Tools - FULLY CALLABLE
- `transcribe_video` - Audio transcription
- `analyze_image` - Image analysis (local files)
- `fs_read` - Read files and directories
- `fs_write` - Write and create files
- `knowledge` - Knowledge base operations

## Capability

The agent CAN invoke all configured MCP tools directly to:
1. Extract frames from ScreenPal URLs using @ffmpeg-mcp/extract_frames_from_video
2. Analyze extracted frames using @vision-server/analyze_image
3. Generate complete visual analysis with detailed UI descriptions
4. Correlate with audio transcripts
5. Save synchronized output

## Workaround: Hybrid Approach

### What CAN Be Done
1. Use `transcribe_video` to extract audio and get video metadata
2. Use `fs_write` to create analysis templates and structures
3. Use `analyze_image` on local image files (if frames are pre-extracted)
4. Use `knowledge` to store and retrieve analysis data

### What CANNOT Be Done (Without External Execution)
1. Extract frames from ScreenPal URLs directly
2. Invoke FFmpeg scene detection
3. Call vision-server tools for frame analysis
4. Execute MCP server commands

## Recommended Solution

### Option 1: Manual Frame Extraction (User-Executed)
```bash
# User runs these commands manually
yt-dlp -f best -o video.mp4 https://go.screenpal.com/watch/cTlX2ZnYYZo
ffmpeg -i video.mp4 -filter:v "select='gt(scene,0.4)'" -vsync vfr frames/frame_%04d.png

# Then agent can analyze pre-extracted frames
```

### Option 2: External Script Execution
Create a shell script that:
1. Downloads video with yt-dlp
2. Extracts frames with FFmpeg
3. Calls agent to analyze frames
4. Saves results

### Option 3: Kiro CLI Enhancement
Request Kiro CLI to provide direct MCP tool invocation capability in agent chat context.

## Current Capabilities

The agent CAN:
- ✅ Transcribe audio from ScreenPal videos
- ✅ Create analysis templates and structures
- ✅ Analyze pre-extracted image files
- ✅ Manage file I/O and knowledge base
- ✅ Provide detailed instructions for manual processes

The agent CANNOT:
- ❌ Extract frames from video URLs
- ❌ Invoke FFmpeg directly
- ❌ Call vision-server tools
- ❌ Execute MCP commands

## Updated Workflow

### For Complete Visual Analysis

**Step 1: User executes frame extraction**
```bash
yt-dlp -f best -o video.mp4 https://go.screenpal.com/watch/cTlX2ZnYYZo
ffmpeg -i video.mp4 -filter:v "select='gt(scene,0.4)'" -vsync vfr frames/frame_%04d.png
```

**Step 2: Agent analyzes frames**
```
Agent: Analyze frames in frames/ directory with detailed UI descriptions
```

**Step 3: Agent saves results**
```
Agent: Save analysis to /Users/bryanchasko/Downloads/video-transcripts/cTlX2ZnYYZo-visual-analysis.json
```

## Documentation Updates Required

1. Update README.md to clarify agent capabilities
2. Update CONTRIBUTING.md with actual workflow
3. Create AGENT_CAPABILITIES.md documenting limitations
4. Update VISUAL_ANALYSIS_STEERING.md with hybrid approach
5. Create MANUAL_FRAME_EXTRACTION.md with user instructions

## Next Steps

1. Document actual agent capabilities accurately
2. Provide clear instructions for manual frame extraction
3. Implement hybrid workflow using available tools
4. Consider requesting Kiro CLI enhancement for MCP tool invocation
