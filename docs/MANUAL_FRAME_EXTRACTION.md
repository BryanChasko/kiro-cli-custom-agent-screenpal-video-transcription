# Manual Frame Extraction Guide

## Overview

Frame extraction must be performed manually using command-line tools. The agent will then analyze the extracted frames.

## Prerequisites

- `yt-dlp` installed: `brew install yt-dlp`
- `ffmpeg` installed: `brew install ffmpeg`
- ~500MB free disk space

## Step-by-Step Instructions

### Step 1: Download Video

```bash
cd /Users/bryanchasko/Code/kiro-cli-custom-agent-screenpal-video-transcription

yt-dlp -f best -o video.mp4 https://go.screenpal.com/watch/cTlX2ZnYYZo
```

### Step 2: Extract Frames at Scene Changes

```bash
mkdir -p frames

ffmpeg -i video.mp4 -filter:v "select='gt(scene,0.4)'" -vsync vfr frames/frame_%04d.png -y
```

### Step 3: Verify Frames

```bash
ls -lh frames/frame_*.png
```

### Step 4: Request Agent Analysis

```
Analyze the extracted frames in frames/ directory. 
For each frame, describe all UI elements, buttons, text, menus, and visual content.
Include exact text, button labels, window titles, and interface details.
Save the complete analysis to /Users/bryanchasko/Downloads/video-transcripts/cTlX2ZnYYZo-visual-analysis.json
```

## Troubleshooting

### yt-dlp Download Fails
```bash
pip install --upgrade yt-dlp
yt-dlp -f 'best[ext=mp4]' -o video.mp4 https://go.screenpal.com/watch/cTlX2ZnYYZo
```

### No Frames Extracted
```bash
# Lower scene threshold for more frames
ffmpeg -i video.mp4 -filter:v "select='gt(scene,0.2)'" -vsync vfr frames/frame_%04d.png -y
```

### Disk Space Issues
```bash
# Reduce frame resolution
ffmpeg -i video.mp4 -filter:v "select='gt(scene,0.4)',scale=1280:720" -vsync vfr frames/frame_%04d.png -y
```

## Complete Workflow

```bash
# 1. Navigate to project directory
cd /Users/bryanchasko/Code/kiro-cli-custom-agent-screenpal-video-transcription

# 2. Download video
yt-dlp -f best -o video.mp4 https://go.screenpal.com/watch/cTlX2ZnYYZo

# 3. Extract frames
mkdir -p frames
ffmpeg -i video.mp4 -filter:v "select='gt(scene,0.4)'" -vsync vfr frames/frame_%04d.png -y

# 4. Verify frames
ls -lh frames/frame_*.png | head -5

# 5. Request agent analysis in chat
# "Analyze the extracted frames in frames/ directory with detailed UI descriptions"

# 6. Cleanup (optional)
rm video.mp4
```
