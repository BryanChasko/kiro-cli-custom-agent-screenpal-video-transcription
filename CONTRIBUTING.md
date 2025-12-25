# Contributing to ScreenPal Video Transcriber Agent

## Critical Tool Usage Rules

### ⚠️ TOOL SEPARATION - READ CAREFULLY

**DO NOT MIX THESE TOOLS:**

#### Audio Transcription Only
- **Tool**: `@video-transcriber/transcribe_video`
- **Purpose**: Extract audio and generate text transcripts
- **Output**: Timestamped text only
- **When to use**: Getting speech-to-text content

#### Visual Analysis Only
- **Tools**: `@vision-server/analyze_image`, `@vision-server/detect_objects`, `@vision-server/generate_caption`
- **Purpose**: Analyze video frames and describe visual content
- **Output**: Frame descriptions, object detection, captions
- **When to use**: Understanding what's shown on screen

### Workflow Decision Tree

```
User Request
    ↓
"I need the transcript" → Use @video-transcriber/transcribe_video
    ↓
"I need visual descriptions" → Use @vision-server/* tools
    ↓
"I have transcript, need visuals" → Use @vision-server/* tools ONLY
    ↓
"I need both" → Run separately, then correlate results
```

## Processing Pipelines

### Pipeline A: Audio-Only Transcription
```
ScreenPal URL → yt-dlp → Audio extraction → Whisper → Text transcript
```

### Pipeline B: Visual Analysis (Requires Pre-extracted Frames)
```
Video frames (PNG/JPG) → Ollama + Moondream2 → Visual descriptions
```

### Pipeline C: Complete Analysis (Two-Step Process)
```
Step 1: Extract frames from video using FFmpeg
Step 2: Analyze frames with @vision-server/* tools
```

## Common Mistakes to Avoid

❌ **WRONG**: Calling `transcribe_video` when user asks for visual analysis
```
User: "Analyze what's shown on screen"
Agent: Calls @video-transcriber/transcribe_video ← INCORRECT
```

✅ **RIGHT**: Use vision-server tools for visual content
```
User: "Analyze what's shown on screen"
Agent: Calls @vision-server/analyze_image ← CORRECT
```

❌ **WRONG**: Assuming transcribe_video provides visual descriptions
```
transcribe_video output: ["00:00:15 Speaker says hello"]
Agent: "Here's what's on screen..." ← WRONG, only audio text
```

✅ **RIGHT**: Acknowledge tool limitations
```
transcribe_video output: ["00:00:15 Speaker says hello"]
Agent: "I have the audio transcript. To see what's on screen, 
I need to analyze the video frames with vision-server tools."
```

## Frame Analysis Workflow

### Step 1: Verify Vision Server Availability
```bash
# Check Ollama is running
curl http://localhost:11434/api/tags

# Verify moondream2 model
ollama list | grep moondream2
```

### Step 2: Extract Frames from Video
```bash
# Using FFmpeg with scene detection
ffmpeg -i video.mp4 -filter:v "select='gt(scene,0.4)'" -vsync vfr frames/frame_%04d.png
```

### Step 3: Analyze Frames with Vision Tools - DETAILED REQUIREMENTS
```
For each extracted frame, call @vision-server/analyze_image with:

Prompt: "Describe all UI elements, buttons, text, menus, and visual content visible on screen. 
Include exact text, button labels, window titles, and interface details."

Required Output Details:
- Frame number and timestamp
- Window/application title
- All visible text (exact wording)
- Button labels and locations
- Menu items and options
- Form fields and input areas
- Data displayed (tables, lists, spreadsheets)
- Visual layout and positioning
- Color scheme and styling
- Any interactive elements
```

### Step 4: Correlate with Audio Transcript
```
Timestamp 00:00:15 (Audio): "Speaker says hello"
Timestamp 00:00:15 (Visual): "Desktop showing VS Code editor with Python file open
  - Window title: 'main.py - VS Code'
  - Visible code: Python function definition
  - Buttons: Run, Debug, Save (top toolbar)
  - Status bar: 'Line 42, Column 10'"
```

### Step 5: Save Detailed Analysis
```
Output file: /Users/bryanchasko/Downloads/video-transcripts/[video-id]-visual-analysis.json

Format:
{
  "frame_id": "0001",
  "timestamp": 0.0,
  "duration": 5.2,
  "visual_description": "Detailed description with all UI elements and text",
  "ui_elements": {
    "window_title": "...",
    "buttons": [...],
    "text_visible": [...],
    "menus": [...],
    "data_displayed": {...}
  }
}
```

## Documentation Standards

### When Documenting Tools

**Audio Transcription Section:**
- Clearly state: "Generates text transcript from audio"
- Include: Timestamp format, confidence scores
- Exclude: Visual descriptions, frame analysis

**Visual Analysis Section:**
- Clearly state: "Analyzes video frames for visual content"
- Include: Object detection, UI descriptions, scene changes
- Exclude: Audio transcription, speech-to-text

### Knowledge Base Updates

When updating knowledge base files:
1. Separate audio and visual tool documentation
2. Include decision tree for tool selection
3. Add "DO NOT USE" warnings where applicable
4. Provide complete workflow examples

## Testing Requirements

Before submitting changes:

1. **Audio Tool Test**: Verify transcribe_video produces text output
2. **Vision Tool Test**: Verify analyze_image processes frames correctly
3. **Integration Test**: Confirm tools don't interfere with each other
4. **Documentation Test**: Ensure docs clearly separate tool purposes

## Reporting Issues

When reporting tool confusion:
- State which tool was called
- State what output was expected
- State what output was received
- Include the ScreenPal URL (if applicable)

Example:
```
Tool Called: @video-transcriber/transcribe_video
Expected: Text transcript
Received: Error about missing frames
Issue: Tool was used for visual analysis instead of audio
```

## Code Review Checklist

- [ ] Tool selection matches user request
- [ ] No mixing of audio and visual pipelines
- [ ] Documentation clearly separates tool purposes
- [ ] Error messages guide users to correct tool
- [ ] Workflow examples show proper tool usage
- [ ] Knowledge base reflects tool separation
