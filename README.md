# Screenpal Video Transcriber Agent

This repository contains a Kiro CLI custom agent specialized in processing ScreenPal video links to generate comprehensive audio transcripts and visual descriptions using local AI models.

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

The screenpal-video-transcriber agent provides:
- **Audio Transcription**: Extract and transcribe speech using OpenAI Whisper
- **Visual Analysis**: Generate semantic descriptions of screen content using local VLMs
- **Temporal Context**: Track visual changes and insert contextual markers

## Architecture

The agent orchestrates multiple MCP servers and tools:
- **video-transcriber-mcp**: Node.js MCP server for audio extraction and Whisper transcription
- **moondream-mcp**: Node.js MCP server for visual analysis using Ollama + Moondream2
- **FFmpeg**: Used by the transcriber to normalize audio and extract frames for vision analysis
- **Ollama (Native macOS)**: Runs the Moondream2 model locally with GPU acceleration for image-to-text processing
- **yt-dlp**: The engine inside the transcriber that extracts raw media from ScreenPal or YouTube links

### Platform Requirements

**Current Setup: Mac Mini with GPU acceleration**
- Native macOS Ollama installation for optimal performance
- Apple Silicon GPU acceleration for vision model inference
- Homebrew package management for dependencies

**For NVIDIA GPU Systems:**
- Use Docker-based Ollama with NVIDIA Container Toolkit
- Replace native Ollama setup with: `docker run -d --gpus all -p 11434:11434 ollama/ollama`
- Ensure NVIDIA drivers and CUDA toolkit are installed
- Update MCP server configuration to point to Docker container

## Knowledge Base Structure

```
knowledge/
├── transcription-tools/    # Core agent documentation and workflows
├── workflow-automation/    # MCP server setup and configuration
├── screenpal-api/          # ScreenPal platform integration
└── best-practices/        # Video processing best practices
```

## Quick Start

### Prerequisites

- Kiro CLI installed
- Node.js 16+ and npm
- Either native Ollama or Docker
- 4GB+ RAM, 5GB+ disk space

**Note**: The setup script automatically installs yt-dlp and other dependencies.

### Installation

```bash
# Run the automated setup script
chmod +x setup.pl
./setup.pl
```

The setup script will:
1. Verify Kiro CLI installation
2. Build MCP servers from source
3. Setup Ollama with Moondream model
4. Configure global MCP settings (`~/.kiro/settings/mcp.json`)
5. Create agent profile (`~/.kiro/agents/screenpal-video-transcriber.json`)
6. Verify all components

### Launch the Agent

```bash
kiro-cli chat --agent screenpal-video-transcriber
```

### Process a Video

```
> Please transcribe this ScreenPal video: https://go.screenpal.com/[video-id]
```

The agent will:
1. Validate the URL
2. Extract audio using yt-dlp
3. Transcribe with Whisper
4. Extract key frames
5. Analyze visuals with Moondream
6. Generate timestamped transcript with visual descriptions

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
      "args": ["-c", "node /tmp/moondream-mcp/build/index.js 1>&2"],
      "env": {
        "OLLAMA_BASE_URL": "http://localhost:11434"
      },
      "disabled": false
    },
    "knowledge": {
      "command": "uvx",
      "args": ["mcp-server-knowledge"],
      "env": {},
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
  "tools": ["fs_read", "fs_write", "knowledge", "@video-transcriber/transcribe_video"],
  "allowedTools": ["fs_read", "knowledge", "@video-transcriber/get_video_info"],
  "model": "claude-sonnet-4"
}
```

**Key Features:**
- `includeMcpJson: true` - Inherits all servers from global config (including `vision-server`)
- `allowedTools` - Restricts which tools the agent can use
- No server duplication - All MCP servers come from global config

See `docs/MCP-CONFIGURATION.md` for detailed configuration guide.

## Features

- **URL Validation**: Automatic ScreenPal URL format validation
- **Audio Transcription**: High-quality speech-to-text with timestamps
- **Visual Analysis**: Semantic understanding of screen content changes
- **Scene Detection**: Optimized frame processing using FFmpeg
- **Local Storage**: Structured output for knowledge base integration
- **Privacy Focused**: No data leaves your local environment

## Documentation

- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - System design and component overview
- **[MCP-CONFIGURATION.md](docs/MCP-CONFIGURATION.md)** - Detailed MCP setup and configuration
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Common issues and solutions

## Privacy & Security

- **Local Processing**: All transcription and analysis happens locally
- **No Cloud APIs**: No external service dependencies
- **Secure URLs**: Only processes validated ScreenPal domains
- **Controlled Access**: Agent permissions limited to video processing tasks
