# Screenpal Video Transcriber Agent

This repository contains a Kiro CLI custom agent specialized in processing ScreenPal video links to generate comprehensive audio transcripts and visual descriptions using local AI models.

## Warning about this flow

The kiro-cli custom agent video-transcriber will get confused and think it is creating an agent rather than being aware they are the agent. To avoid this, once you have the agent running, do your prompts inside a directory that does not have this repository's contents

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

The screenpal-video-transcriber agent provides a complete unified workflow:

1. **Audio Transcription**: Extract and transcribe speech using OpenAI Whisper
2. **Visual Analysis**: Extract video frames at scene changes and analyze with Moondream2 VLM
3. **Unified Document**: Automatically correlate audio and visual data by timestamp

**Output**: Three integrated files created in `~/Downloads/video-transcripts-{timestamp}/`:
- `{video-id}-UNIFIED.json` - Structured data combining audio segments with visual frames
- `{video-id}-UNIFIED.md` - Human-readable synchronized walkthrough
- `{video-id}-frames/` - Extracted PNG frames for reference

### ⚠️ Important: Unified Workflow

The agent now automatically handles all three steps in one request:
1. Extracts audio and transcribes to text
2. Extracts video frames and analyzes visuals
3. Creates unified document correlating audio + visual by timestamp

No manual tool selection needed - just provide a ScreenPal URL.

## Architecture

The agent orchestrates a unified three-stage pipeline:

**Stage 1: Audio Extraction & Transcription**
- yt-dlp extracts audio stream from ScreenPal URL
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

The agent now includes `execute_perl` tool for Perl script execution, file cleanup, and directory operations alongside the existing video processing and vision analysis capabilities.

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
5. Create agent profile (`~/.kiro/agents/screenpal-video-transcriber.json`)
6. Verify all components

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
  "tools": [
    "fs_read", "fs_write", "knowledge", 
    "@video-transcriber/transcribe_video",
    "@vision-server/analyze_image",
    "@vision-server/detect_objects", 
    "@vision-server/generate_caption"
  ],
  "allowedTools": [
    "fs_read", "knowledge", 
    "@video-transcriber/get_video_info",
    "@vision-server/analyze_image",
    "@vision-server/detect_objects",
    "@vision-server/generate_caption"
  ],
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
- **Solution**: Restart agent session: `kiro-cli chat --agent screenpal-video-transcriber`
- **Root cause**: MCP servers not properly registering tools with Kiro CLI

**Tool not found**: Missing dependencies or configuration issues  
- **Solution**: Run setup script: `./setup.pl`
- **Check**: Verify yt-dlp and Whisper are installed

**Ollama not responding**: Vision analysis unavailable
- **Solution**: Start Ollama: `ollama serve` or check Docker container
- **Verify**: `curl -s http://localhost:11434/api/tags`

**MCP Tools Not Callable**: Frame extraction and vision analysis tools not available in chat
- **Cause**: Kiro CLI chat context doesn't provide direct MCP tool invocation
- **Solution**: Use manual frame extraction (see MANUAL_FRAME_EXTRACTION.md)
- **Workflow**: Extract frames manually, then agent analyzes pre-extracted frames

See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for complete troubleshooting guide.
See [MANUAL_FRAME_EXTRACTION.md](MANUAL_FRAME_EXTRACTION.md) for frame extraction instructions.

## Documentation

- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - System design and component overview
- **[MCP-CONFIGURATION.md](docs/MCP-CONFIGURATION.md)** - Detailed MCP setup and configuration
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Common issues and solutions

## Privacy & Security

- **Local Processing**: All transcription and analysis happens locally
- **No Cloud APIs**: No external service dependencies
- **Secure URLs**: Only processes validated ScreenPal domains
- **Controlled Access**: Agent permissions include video processing and visual analysis tasks
