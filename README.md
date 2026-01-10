# Multi-Platform Video Transcriber Agent 'screenpal-video-transcriber'

**TLDR**: Turn Any Video Into a Document

This repository contains files to build and enhance an AWS Kiro CLI custom agent that takes video URLs from **S3, ScreenPal, YouTube, or Twitch** and produces a directory with audio transcription, visual analysis, and a unified markdown document.

## Kiro CLI Architecture Integration

This agent follows the **three-layer Kiro CLI architecture**:

### Layer 1: Steering Documents (`~/.kiro/steering/`)
**Governance and Standards** - Loaded directly into agent reasoning context:
- Code style conventions (named functions, JSDoc requirements)
- JavaScript safety standards (type safety, defensive programming)
- MCP health standards (server reliability, timeout management)
- Video processing standards (quality thresholds, format validation)

### Layer 2: Knowledge Base (`~/.kiro/knowledge_bases/screenpal-video-transcriber/`)
**Domain-Specific Reference** - Queried via `/knowledge search`:
- Video processing workflows and examples
- Platform-specific API documentation
- Troubleshooting guides and best practices
- MCP server configuration patterns

### Layer 3: Live Context Injection (Context7)
**Real-Time Documentation** - Triggered via `use context7`:
- Latest official documentation from source
- Fresh API references and examples
- Current installation and setup procedures
- Live troubleshooting and error resolution

**Why This Matters**:
- Steering docs ensure consistent, safe video processing
- Knowledge base provides searchable reference materials
- Context7 delivers fresh documentation for fast-moving domains
- Clean separation prevents context pollution while ensuring accuracy

## Time & Credits + MCP Overview

**Estimated costs**: ~Took about 90 Kiro credits to develop, ~I recommend 30 credits to deploy, as I haven't tested redeploying. ~Takes about 3 credits to create a document from a short video, haven't experimented with a longer video. Fits within the 50 credit monthly free tier, especially with claude-haiku-4.5 (0.4x credit multiplier as of January 2026).

**Development time**: ~6 hours for planning and building, ~5 minutes to process a short video, screenshots, and generate a unified report.

**MCP Servers**:
- **video-transcriber**: Audio transcription with Whisper
- **vision-server**: Frame analysis with Moondream2 VLM  
- **ffmpeg-mcp**: Frame extraction with scene detection

## ⚠️ Important Usage Note

This repository contains agent development documentation that can confuse the screenpal-video-transcriber agent. **Run the agent from a different directory** to avoid the agent thinking it's creating an agent rather than being the agent.

For production use, consider moving development documentation to a separate repository.

            ___
           / _ \
          | / \ |
          | \_/ |
           \___/ ___
           _|_|_/[_]\__==_
          [---------------]
          | O   /---\     |
          |    |     |    |
          |     \___/     |
          [---------------]
                [___]
                 | |\\
                 | | \\
                 [ ]  \\_
                /|_|\  ( \
               //| |\\  \ \
              // | | \\  \ \
             //  |_|  \\  \_\
            //   | |   \\
           //\   | |   /\\
          //  \  | |  /  \\
         //    \ | | /    \\
        //      \|_|/      \\
       //        [_]        \\
      //          H          \\
     //           H           \\
    //            H            \\
   //             H             \\
  //              H              \\
 //                               \\
//                                 \\

## Purpose

The screenpal-video-transcriber agent provides a complete unified workflow for any supported video platform:

1. **Platform Detection**: Auto-detects ScreenPal, YouTube, Twitch, or S3 from URL patterns
2. **Audio Transcription**: Extract and transcribe speech using OpenAI Whisper
3. **Visual Analysis**: Extract video frames at scene changes and analyze with Moondream2 VLM
4. **Unified Document**: Automatically correlate audio and visual data by timestamp with platform metadata

**Output**: Three integrated files created in `~/Downloads/video-transcripts-{timestamp}/`:
- `{video-id}-UNIFIED.json` - Structured data combining audio segments with visual frames
- `{video-id}-UNIFIED.md` - Human-readable synchronized walkthrough
- `{video-id}-frames/` - Extracted PNG frames for reference

### ⚠️ Important: Unified Workflow

The agent automatically handles all three steps in one request:
1. Extracts audio and transcribes to text
2. Extracts video frames and analyzes visuals
3. Creates unified document correlating audio + visual by timestamp

No manual tool selection needed - just provide a ScreenPal URL.

## Architecture

The agent orchestrates a unified three-stage pipeline:

**Stage 1: Audio Extraction & Transcription**
- yt-dlp extracts audio stream from video URL (supports ScreenPal, YouTube, Twitch, S3)
- OpenAI Whisper transcribes to timestamped text segments

**Stage 2: Visual Analysis**
- FFmpeg extracts frames at scene changes (threshold: 0.4)
- Moondream2 VLM analyzes each frame for UI elements and content
- Generates detailed visual descriptions with timestamps

**Stage 3: Unified Document Creation**
- Correlates audio segments with visual frames by timestamp
- Creates synchronized JSON and Markdown documents
- Stores all outputs in `~/Downloads/video-transcripts-{timestamp}/`

### MCP Servers Used

- **video-transcriber-mcp**: Audio extraction and Whisper transcription
- **ffmpeg-mcp**: Frame extraction with scene detection
- **moondream-mcp**: Visual analysis using Ollama + Moondream2
- **yt-dlp**: Media stream extraction
- **Ollama**: Local VLM runtime (native macOS or Docker)

## Knowledge Base Structure

```
knowledge/
├── transcription-tools/    # Core agent documentation and workflows
├── workflow-automation/    # MCP server setup and configuration
├── screenpal-api/          # ScreenPal platform integration
└── best-practices/        # Video processing best practices
```

## Perl Scripts

This project uses Perl scripts for system automation and configuration management. Perl provides robust text processing, system integration, and cross-platform compatibility for our video processing workflows.

### Setup Script (`setup.pl`)

The main setup script automates the complete installation and configuration process:

```bash
# Make executable and run
chmod +x setup.pl
./setup.pl
```

**What it does:**
- Verifies Kiro CLI installation
- Installs dependencies (yt-dlp, OpenAI Whisper, uv package manager)
- Clones and builds MCP servers from source
- Configures Ollama with Moondream model
- Creates MCP configuration files
- Sets up agent profiles
- Performs comprehensive verification

**Note**: This script was functional as of January 2026 but is not actively maintained. If you encounter issues, refer to the manual setup instructions in the documentation.

### Why Perl?

- **Text Processing**: Excellent for configuration file manipulation and JSON handling
- **System Integration**: Native support for shell commands and file operations
- **Cross-Platform**: Works consistently across macOS, Linux, and Windows
- **Mature Ecosystem**: Stable libraries for JSON, file handling, and HTTP operations
- **Error Handling**: Robust error checking and reporting capabilities

The agent includes `execute_bash` tool for shell command execution, file cleanup, and directory operations alongside the existing video processing and vision analysis capabilities.

### Prerequisites

- Kiro CLI installed
- Node.js 16+ and npm
- Either native Ollama or Docker
- 4GB+ RAM, 5GB+ disk space
- ### Secure Authentication Setup

**Option 1: GitHub CLI (Recommended for local development)**
```bash
# Authenticate with GitHub CLI
gh auth login

# Setup secure token access
./scripts/setup-github-token.sh

# Use secure authentication
./scripts/docker-auth-secure.sh
```

**Option 2: AWS Parameter Store (Recommended for production)**
```bash
# Store token securely in AWS Parameter Store
./scripts/store-github-token-aws.sh ghp_your_token_here

# Use secure authentication
./scripts/docker-auth-secure.sh
```

**For S3 videos**: AWS credentials in environment (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN if needed)

**Note**: The setup script automatically installs yt-dlp and OpenAI Whisper dependencies.

### Installation

```bash
# Run the automated setup script
chmod +x setup.pl
./setup.pl
```

The setup script will:
1. Verify Kiro CLI installation
2. Install yt-dlp for video extraction
3. Install OpenAI Whisper for transcription
4. Build MCP servers from source
5. Setup Ollama with Moondream model
6. Configure global MCP settings (`~/.kiro/settings/mcp.json`)
7. Create agent profile (`~/.kiro/agents/screenpal-video-transcriber.json`)
8. Verify all components

### Launch the Agent

**From the project directory:**
```bash
cd /path/to/kiro-cli-custom-agent-screenpal-video-transcription
kiro-cli chat --agent screenpal-video-transcriber
```

**Note**: The agent is automatically discovered when you're in the project directory. No global linking required.

### Process a Video

```
> Please transcribe this ScreenPal video: https://go.screenpal.com/[video-id]
> Please transcribe this YouTube video: https://youtube.com/watch?v=[video-id]
> Please transcribe this Twitch video: https://twitch.tv/videos/[video-id]
> Please transcribe this S3 video: https://bucket.s3.amazonaws.com/video.mp4
```

The agent will:
1. Validate the URL
2. Extract audio using yt-dlp
3. Transcribe with Whisper
4. Extract key frames
5. Analyze visual content with Moondream
6. Generate comprehensive transcript with visual descriptions
7. Create unified document correlating audio + visual by timestamp

**Output files** created in `~/Downloads/video-transcripts-{timestamp}/`:
- `{video-id}-UNIFIED.json` - Structured synchronized data
- `{video-id}-UNIFIED.md` - Human-readable walkthrough
- `{video-id}-frames/` - Extracted PNG frames

## Configuration

The agent uses a two-level MCP configuration system:

### Global MCP Configuration (`~/.kiro/settings/mcp.json`)

Defines all available MCP servers for all agents:

```json
{
  "mcpServers": {
    "video-transcriber": {
      "command": "sh",
      "args": ["-c", "node /tmp/video-transcriber-mcp/dist/index.js 2>/dev/null"],
      "env": {
        "WHISPER_MODEL": "base",
        "YOUTUBE_FORMAT": "bestaudio",
        "WHISPER_DEVICE": "cpu"
      },
      "disabled": false
    },
    "vision-server": {
      "command": "sh",
      "args": ["-c", "node /tmp/moondream-mcp/build/index.js 2>/dev/null"],
      "env": {
        "OLLAMA_BASE_URL": "http://localhost:11434"
      },
      "disabled": false
    },
    "ffmpeg-mcp": {
      "command": "uvx",
      "args": ["video-creator"],
      "env": {
        "SCENE_THRESHOLD": "0.4"
      },
      "disabled": false
    }
  }
}
```

### Agent Profile (`~/.kiro/agents/screenpal-video-transcriber.json`)

Specialized configuration for this agent:

```json
{
  "name": "screenpal-video-transcriber",
  "description": "Specialized agent for processing ScreenPal videos...",
  "includeMcpJson": true,
  "tools": [
    "fs_read", "fs_write", "knowledge", "execute_bash",
    "@video-transcriber/transcribe_video",
    "@ffmpeg-mcp/extract_frames_from_video",
    "@ffmpeg-mcp/get_video_info",
    "@vision-server/analyze_image",
    "@vision-server/detect_objects", 
    "@vision-server/generate_caption"
  ],
  "model": "claude-sonnet-4"
}
```

**Key Features:**
- `includeMcpJson: true` - Inherits all servers from global config
- Complete toolchain for video processing and visual analysis
- No server duplication - All MCP servers come from global config

## Features

- **URL Validation**: Automatic platform detection from URL patterns (ScreenPal, YouTube, Twitch, S3)
- **Audio Transcription**: High-quality speech-to-text with timestamps
- **Frame Extraction**: Scene-change detection with FFmpeg for key moments
- **Detailed Visual Analysis**: Complete UI element descriptions including:
  - Exact text and button labels
  - Window titles and menu items
  - Form fields and data displayed
  - Visual layout and positioning
  - Interactive elements and controls
- **Timestamp Correlation**: Synchronized audio-visual walkthrough
- **Unified Output**: Single document combining audio + visual
- **Local Storage**: Organized output in `~/Downloads/video-transcripts-{timestamp}/`
- **Privacy Focused**: No data leaves your local environment

## Troubleshooting

### Common Issues

**"dummy" tool error**: MCP server communication failure
- **Root cause**: MCP servers not properly registering tools with Kiro CLI
- **Solution**: Restart agent session: `kiro-cli chat --agent screenpal-video-transcriber`

**Tool not found**: Missing dependencies or configuration issues  
- **Solution**: Run setup script: `./setup.pl`
- **Check**: Verify yt-dlp and Whisper are installed

**Ollama not responding**: Vision analysis unavailable
- **Solution**: Start Ollama: `ollama serve` or check Docker container
- **Verify**: `curl -s http://localhost:11434/api/tags`

**Frame Extraction Issues**: Problems with scene detection or frame quality
- **Cause**: Incorrect scene threshold or video format issues
- **Solution**: Adjust scene_threshold parameter or verify video accessibility

## Documentation

- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - System design and component overview
- **[MCP-CONFIGURATION.md](docs/MCP-CONFIGURATION.md)** - Detailed MCP setup and configuration
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Common issues and solutions

## Privacy & Security

- **Local Processing**: All transcription and analysis happens locally
- **No Cloud APIs**: No external service dependencies
- **Secure URLs**: Only processes validated platform domains (ScreenPal, YouTube, Twitch, S3)
- **Controlled Access**: Agent permissions include video processing and visual analysis tasks
