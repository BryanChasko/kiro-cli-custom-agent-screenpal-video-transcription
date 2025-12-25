# Visual Analysis Steering Document

## Objective
Extract actual video frames from ScreenPal videos and provide detailed visual analysis including exact UI elements, text, buttons, and interface details.

## CRITICAL LIMITATION
The agent cannot directly invoke MCP tools (@ffmpeg-mcp, @vision-server) from the chat context. Frame extraction must be performed externally, then the agent analyzes pre-extracted frames.

## Workflow: Hybrid Approach

### Phase 1: Frame Extraction (USER EXECUTES)
```bash
# Download video
yt-dlp -f best -o video.mp4 https://go.screenpal.com/watch/cTlX2ZnYYZo

# Extract frames at scene changes
ffmpeg -i video.mp4 -filter:v "select='gt(scene,0.4)'" -vsync vfr frames/frame_%04d.png
```

### Phase 2: Visual Analysis (AGENT EXECUTES)
For each extracted frame, use `analyze_image` with:

**Prompt**: 
```
"Describe all UI elements, buttons, text, menus, and visual content visible on screen. 
Include exact text, button labels, window titles, and interface details. 
List all readable text, menu items, form fields, and data displayed."
```

**Required Output Fields**:
- Frame ID and timestamp
- Window/application title (exact)
- All visible text (exact wording)
- Button labels and locations
- Menu items and options
- Form fields and input areas
- Data displayed (tables, lists, spreadsheets, cells)
- Visual layout and positioning
- Color scheme and styling
- Interactive elements
- Any visible code or technical content

### Phase 3: Output Format
Save to: `/Users/bryanchasko/Downloads/video-transcripts/[video-id]-visual-analysis.json`

```json
{
  "frame_id": "0001",
  "timestamp": 0.0,
  "audio_text": "Speaker says...",
  "visual_description": "Detailed description with all UI elements",
  "ui_elements": {
    "window_title": "Exact window title",
    "application": "Application name",
    "buttons": [
      {"label": "Button text", "location": "top-right"},
      {"label": "Another button", "location": "bottom-left"}
    ],
    "text_visible": [
      "All readable text on screen",
      "Menu items",
      "Labels"
    ],
    "menus": [
      {"name": "File", "items": ["New", "Open", "Save"]},
      {"name": "Edit", "items": ["Cut", "Copy", "Paste"]}
    ],
    "data_displayed": {
      "type": "spreadsheet|table|form|code|other",
      "content": "Exact data visible"
    },
    "layout_description": "Overall layout and positioning"
  },
  "scene_change_detected": true,
  "confidence": 0.95
}
```

## Quality Standards

### Visual Description Quality
- ✅ Include exact text visible on screen
- ✅ Describe button locations and labels
- ✅ List all menu items
- ✅ Detail form fields and data
- ✅ Describe layout and positioning
- ✅ Note color scheme and styling
- ✅ Identify interactive elements

### Avoid
- ❌ Vague descriptions ("shows a spreadsheet")
- ❌ Missing text details
- ❌ Incomplete button lists
- ❌ Inferred content not visible
- ❌ Generic descriptions

## Success Criteria

✅ All frames extracted at scene changes
✅ Each frame analyzed with detailed UI descriptions
✅ All visible text captured exactly
✅ Button labels and locations documented
✅ Menu items listed
✅ Data displayed described
✅ Output saved to correct location
✅ JSON format valid
✅ Timestamps correlated with audio
✅ Confidence scores included
