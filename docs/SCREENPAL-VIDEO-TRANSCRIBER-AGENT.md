# ScreenPal Video Transcriber Agent - Complete Guide

## Overview

The `screenpal-video-transcriber` is a specialized Kiro CLI custom agent that transforms video URLs into comprehensive, accessible documents. It combines audio transcription with visual analysis to create unified narratives suitable for deaf and blind users.

## Agent Architecture

```
Input: Video URL (ScreenPal, YouTube, Twitch, S3)
    ↓
Audio Pipeline: video-transcriber-mcp → Whisper → Timestamped text
    ↓
Visual Pipeline: ffmpeg-mcp → Frame extraction → vision-server → UI descriptions  
    ↓
Narrative Synthesis: text-tools-mcp → Unified markdown document
```

## Security & Authentication

### Secure GitHub Token Management

**GitHub CLI Integration (Recommended for local development)**:
```bash
# Authenticate with GitHub CLI
gh auth login

# Setup secure token access
./scripts/setup-github-token.sh

# Use secure authentication for Docker
./scripts/docker-auth-secure.sh
```

**AWS Parameter Store (Production environments)**:
```bash
# Store token securely in AWS Parameter Store
./scripts/store-github-token-aws.sh ghp_your_token_here

# Use secure authentication
./scripts/docker-auth-secure.sh
```

**Security Features**:
- No hardcoded tokens in repository
- Encrypted storage using AWS KMS or GitHub CLI
- Automatic token rotation support
- Environment-specific configuration

## Configuration Details

### Agent Profile Location
- **File**: `~/.kiro/agents/screenpal-video-transcriber.json`
- **Type**: Custom agent with specialized MCP server configuration
- **Model**: Auto-selected based on task complexity

### MCP Server Integration

**Global Inheritance**: `includeMcpJson: true` - Inherits all servers from `~/.kiro/settings/mcp.json`:
- `video-transcriber` - Audio extraction and Whisper transcription
- `vision-server` - Visual analysis with Moondream VLM  
- `ffmpeg-mcp` - Frame extraction with scene detection
- `github`, `fetch`, `aws-docs`, `chrome-devtools`, `playwright` - Supporting tools

**Agent-Specific Servers**:
- `filesystem-mcp` - Docker-based file operations scoped to `/Users/bryanchasko/Downloads/kiro-videos`
- `text-tools-mcp` - Docker-based comprehensive text processing server

### Steering Documents
- **Resource**: `~/.kiro/steering/narrative.md`
- **Purpose**: Defines narrative weaving standards for accessible output
- **Standards**: Strip filler, merge by timestamp, preserve factual accuracy

## Core Workflow

### 1. Video Input Processing
**Supported Platforms**:
- ScreenPal (`https://go.screenpal.com/[video-id]`)
- YouTube (`https://youtube.com/watch?v=[video-id]`)
- Twitch (`https://twitch.tv/videos/[video-id]`)
- S3 (`https://bucket.s3.amazonaws.com/video.mp4`)

### 2. Parallel Processing Pipeline

**Audio Transcription**:
1. `@video-transcriber/transcribe_video` - Extract audio stream
2. OpenAI Whisper - Convert speech to timestamped text
3. Environment: `WHISPER_MODEL=base`, `WHISPER_DEVICE=cpu`

**Visual Analysis**:
1. `@ffmpeg-mcp/get_video_info` - Analyze video metadata
2. `@ffmpeg-mcp/extract_frames_from_video` - Extract frames at scene changes (`scene_threshold=0.4`)
3. `@vision-server/analyze_image` - Analyze each frame for UI elements, text, controls

**Critical Prompt for Visual Analysis**:
```
Describe speaker outfit if not previously described, presentation setting, all UI elements, buttons, text, menus, and visual content visible on screen. Include exact text, button labels, window titles, and interface details.
```

### 3. Output Generation

**Unified Document Creation**:
- Correlate audio segments with visual frames by timestamp
- Apply narrative weaving standards from steering document
- Generate accessible markdown with preserved technical accuracy

**Output Location**: `/Users/bryanchasko/Downloads/video-transcripts-{timestamp}/`
**Files Created**:
- `{video-id}-UNIFIED.json` - Structured synchronized data
- `{video-id}-UNIFIED.md` - Human-readable walkthrough  
- `{video-id}-frames/` - Extracted PNG frames

## Agent Capabilities

### Tools Available
```json
[
  "fs_read", "fs_write", "knowledge", "execute_bash", "fetch",
  "@video-transcriber/transcribe_video",
  "@video-transcriber/extract_audio", 
  "@video-transcriber/get_video_info",
  "@ffmpeg-mcp/extract_frames_from_video",
  "@ffmpeg-mcp/get_video_info", 
  "@vision-server/analyze_image",
  "@vision-server/detect_objects",
  "@vision-server/generate_caption",
  "@filesystem-mcp/read_file",
  "@filesystem-mcp/list_directory", 
  "@filesystem-mcp/get_file_info",
  "@filesystem-mcp/search_files",
  "@text-tools-mcp/merge_segments",
  "@text-tools-mcp/strip_filler",
  "@text-tools-mcp/rewrite"
]
```

### Critical Operating Rules
- **MCP Tools Only**: Never use manual commands, bash scripts, or direct tool execution
- **Failure Protocol**: If MCP tools fail, report failure and stop - no manual workarounds
- **Visual Sequence**: Analyze frames in sequence to capture visual changes
- **Complete Analysis**: Include frame number, timestamp, exact visual description with all readable text

## Usage Examples

### Basic Video Processing
```
> Please transcribe this ScreenPal video: https://go.screenpal.com/HI_qexVlU2Y

[Agent processes video through complete pipeline]

Output: Unified document with synchronized audio-visual narrative
```

### Expected Processing Flow
1. **URL Validation**: Confirms supported platform
2. **Audio Extraction**: Downloads and transcribes audio
3. **Frame Analysis**: Extracts key frames and analyzes visual content
4. **Narrative Synthesis**: Combines audio + visual into coherent document
5. **Output Generation**: Creates accessible markdown with timestamps

## Comparison with Other Agents

### vs Default Agent
- **Scope**: Specialized for video processing vs general development
- **Tools**: Video/audio processing vs general file operations
- **Output**: Structured transcripts vs code/documentation
- **MCP Servers**: Includes specialized media processing servers

### vs Planning Agent  
- **Purpose**: Execution-focused vs planning-focused
- **Permissions**: Full tool access vs read-only
- **Workflow**: Direct processing vs requirements gathering
- **Output**: Final deliverables vs implementation plans

## Technical Implementation

### Docker Integration
```json
{
  "filesystem-mcp": {
    "command": "docker",
    "args": ["run", "--rm", "-v", "/Users/bryanchasko/Downloads/kiro-videos:/mnt", 
             "ghcr.io/modelcontextprotocol/filesystem-mcp:latest"],
    "env": {"ROOT_DIR": "/mnt", "DEBUG": "false"}
  },
  "text-tools-mcp": {
    "command": "docker", 
    "args": ["run", "-i", "--rm", 
             "ghcr.io/metorial/mcp-container--modelcontextprotocol--servers--everything:latest"],
    "env": {}, "timeout": 120000
  }
}
```

**Authentication Requirements**:
- GitHub Container Registry access for MCP Docker images
- Use `./scripts/docker-auth-secure.sh` for secure authentication
- Supports both GitHub CLI and AWS Parameter Store token management

### Environment Configuration
- **Video Transcriber**: Whisper base model, CPU processing
- **Vision Server**: Ollama base URL `http://localhost:11434`
- **FFmpeg**: Scene threshold 0.4, 4 threads, max 50 frames, quality 2

## Narrative Weaving Standards

### Core Principles (from steering document)
- Do not invent narrator or add commentary
- Preserve factual sequence and timestamp order
- Merge audio and visual transcripts into single coherent narrative
- Use plain, descriptive language suitable for blind or deaf users
- Avoid filler words, repetition, or speculative language

### Output Format Requirements
- Markdown with section headers for major transitions
- Timestamps at section start in `[00:00]` format
- Bullet points for lists, paragraph form otherwise
- No speaker names unless explicitly stated in transcript

### Processing Pipeline
1. **Strip Filler**: Remove "um", "uh", repetitive phrases
2. **Merge Segments**: Combine audio + visual by timestamp
3. **Rewrite**: Transform into coherent narrative flow
4. **Validate**: Ensure accessibility and factual accuracy

## File Organization

### Global Configuration
- **Agent Profile**: `~/.kiro/agents/screenpal-video-transcriber.json`
- **MCP Servers**: `~/.kiro/settings/mcp.json` 
- **Steering**: `~/.kiro/steering/narrative.md`

### Project-Specific
- **Input Directory**: `/Users/bryanchasko/Downloads/kiro-videos/`
- **Output Directory**: `/Users/bryanchasko/Downloads/video-transcripts-{timestamp}/`
- **Local Config**: `.kiro/transcripts/`

### Canonical File Naming
```
{videoId}-{modality}-{startTime}-{endTime}.txt
{videoId}-UNIFIED.md
{videoId}-UNIFIED.json
```

Examples:
- `HI_qexVlU2Y-audio-0000-0600.txt`
- `HI_qexVlU2Y-visual-0600-1200.txt` 
- `HI_qexVlU2Y-UNIFIED.md`

## Key Features

### Privacy & Security
- **Local Processing**: All transcription and analysis happens locally
- **No Cloud APIs**: No external service dependencies beyond MCP servers
- **Secure URLs**: Only processes validated platform domains
- **Controlled Access**: Agent permissions limited to video processing tasks
- **Token Security**: GitHub tokens managed via CLI or AWS Parameter Store
- **No Hardcoded Secrets**: All authentication uses secure external sources

### Accessibility Focus
- **Deaf Users**: Complete visual descriptions of UI elements, text, controls
- **Blind Users**: Detailed audio transcription with context
- **Universal Design**: Plain language suitable for all users
- **Technical Accuracy**: Preserves exact button labels, window titles, interface details

### Quality Assurance
- **Timestamp Correlation**: Precise synchronization of audio and visual
- **Scene Detection**: Automatic frame extraction at visual transitions
- **Error Handling**: Robust failure reporting without manual fallbacks
- **Validation**: Ensures factual accuracy and accessibility compliance

This agent represents a complete solution for transforming video content into accessible, comprehensive documentation that serves both technical and accessibility requirements.
