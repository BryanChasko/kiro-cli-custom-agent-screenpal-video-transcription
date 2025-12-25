# Tool Selection Guide - Critical Reference

## The Two Separate Pipelines

### Pipeline 1: Audio Transcription
**Tool**: `@video-transcriber/transcribe_video`
**Input**: ScreenPal URL
**Output**: Timestamped text transcript
**Use When**: User asks for "transcript", "what they said", "speech-to-text"

### Pipeline 2: Visual Analysis
**Tools**: `@vision-server/analyze_image`, `@vision-server/detect_objects`, `@vision-server/generate_caption`
**Input**: Video frames (PNG/JPG files)
**Output**: Visual descriptions, object locations, captions
**Use When**: User asks for "what's on screen", "visual descriptions", "UI analysis"

## Decision Matrix

| User Request | Tool to Use | Why |
|---|---|---|
| "Transcribe this video" | @video-transcriber/transcribe_video | Extracts audio and converts to text |
| "What does the speaker say?" | @video-transcriber/transcribe_video | Audio content extraction |
| "What's shown on screen?" | @vision-server/analyze_image | Visual frame analysis |
| "Describe the UI changes" | @vision-server/analyze_image | Visual content analysis |
| "Find objects in the video" | @vision-server/detect_objects | Object detection in frames |
| "Create captions for frames" | @vision-server/generate_caption | Visual captioning |
| "I have transcript, need visuals" | @vision-server/* tools | Analyze pre-extracted frames |
| "Sync audio with visuals" | Both (separately, then correlate) | Two-step process |

## Critical Limitations

### @video-transcriber/transcribe_video CANNOT:
- ❌ Describe what's on screen
- ❌ Detect objects in video
- ❌ Generate visual captions
- ❌ Analyze UI elements
- ❌ Extract video frames

**Output is text only.**

### @vision-server/* tools CANNOT:
- ❌ Extract audio from video
- ❌ Generate text transcripts
- ❌ Process ScreenPal URLs directly
- ❌ Convert speech to text

**Input must be pre-extracted frames (PNG/JPG).**

## Workflow: "I Have Transcript, Need Visuals"

This is the correct sequence:

```
1. User provides: ScreenPal URL + existing transcript
2. Agent recognizes: Need visual analysis, NOT audio transcription
3. Agent extracts: Video frames using FFmpeg
4. Agent analyzes: Frames with @vision-server/analyze_image
5. Agent correlates: Audio timestamps with visual descriptions
6. Agent outputs: Synchronized audio-visual walkthrough
```

**Key**: Do NOT call @video-transcriber/transcribe_video in step 2.

## Frame Extraction (Required Before Vision Analysis)

Vision tools need actual frame files. Extract them:

```bash
ffmpeg -i video.mp4 -filter:v "select='gt(scene,0.4)'" -vsync vfr frames/frame_%04d.png
```

This creates PNG files that vision-server tools can analyze.

## Error Prevention

### Scenario: User says "I have transcript, need visuals"

**WRONG APPROACH:**
```
1. Call @video-transcriber/transcribe_video
2. Get text output
3. User: "That's not what I asked for"
```

**RIGHT APPROACH:**
```
1. Recognize: User already has transcript
2. Extract frames from video
3. Call @vision-server/analyze_image on frames
4. Correlate with existing transcript
5. Provide synchronized walkthrough
```

### Scenario: User asks "What's on screen?"

**WRONG APPROACH:**
```
1. Call @video-transcriber/transcribe_video
2. Return: "00:00:15 Speaker says hello"
3. User: "I asked what's SHOWN, not what's SAID"
```

**RIGHT APPROACH:**
```
1. Extract frames from video
2. Call @vision-server/analyze_image
3. Return: "00:00:15 Desktop showing VS Code with Python file"
```

## When Both Pipelines Are Needed

If user wants complete analysis (audio + visual):

```
Step 1: Audio Pipeline
  - Call @video-transcriber/transcribe_video
  - Get: Timestamped text transcript

Step 2: Visual Pipeline
  - Extract frames with FFmpeg
  - Call @vision-server/analyze_image
  - Get: Timestamped visual descriptions

Step 3: Correlation
  - Merge outputs by timestamp
  - Create synchronized walkthrough
```

**Important**: These are separate operations. Don't confuse them.

## Knowledge Base Integration

When storing results:

```json
{
  "video_id": "cTlX2ZnYYZo",
  "audio_transcript": [
    {"timestamp": "00:00:15", "text": "Speaker says hello"}
  ],
  "visual_analysis": [
    {"timestamp": "00:00:15", "description": "Desktop with VS Code"}
  ]
}
```

Keep audio and visual data separate in structure.
