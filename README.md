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

The agent orchestrates multiple MCP servers:
- **video-transcriber-mcp**: Audio extraction and Whisper transcription
- **mcp-vision-analysis**: Visual analysis using Ollama + Moondream2/Llava
- **Local Processing**: FFmpeg scene detection and frame optimization

## Knowledge Base Structure

```
knowledge/
├── transcription-tools/    # Core agent documentation and workflows
├── workflow-automation/    # MCP server setup and configuration
├── screenpal-api/          # ScreenPal platform integration
└── best-practices/        # Video processing best practices
```

## Quick Start

1. **Install the agent**:
```bash
# Run the Perl setup script
./setup.pl

# Or install globally
./setup.pl --global
```

2. **Setup MCP servers**:
```bash
# Install required MCP servers
uvx install video-transcriber-mcp
uvx install mcp-vision-analysis

# Setup Ollama and VLM models
ollama serve
ollama pull moondream2
```

3. **Launch the agent**:
```bash
kiro-cli chat --agent screenpal-video-transcriber
```

4. **Process a ScreenPal video**:
```
> Please transcribe this ScreenPal video: https://go.screenpal.com/[video-id]
```

## Features

- **URL Validation**: Automatic ScreenPal URL format validation
- **Audio Transcription**: High-quality speech-to-text with timestamps
- **Visual Analysis**: Semantic understanding of screen content changes
- **Scene Detection**: Optimized frame processing using FFmpeg
- **Local Storage**: Structured output for knowledge base integration
- **Privacy Focused**: No data leaves your local environment

## Configuration

The agent uses local MCP servers with configurable parameters:
- Whisper model selection (base, large-v3)
- VLM model choice (moondream2, llava)
- Scene detection sensitivity
- Output formatting options

See `knowledge/workflow-automation/mcp-server-setup.md` for detailed configuration instructions.

## Privacy & Security

- **Local Processing**: All transcription and analysis happens locally
- **No Cloud APIs**: No external service dependencies
- **Secure URLs**: Only processes validated ScreenPal domains
- **Controlled Access**: Agent permissions limited to video processing tasks
