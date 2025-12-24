# ScreenPal Video Transcriber - System Architecture

## Overview

The ScreenPal Video Transcriber is a Kiro CLI custom agent that processes video links to generate audio transcripts and visual descriptions using local AI models. It integrates with Kiro's MCP (Model Context Protocol) server system to orchestrate multiple specialized tools.

## Component Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Kiro CLI Chat Interface                   │
└────────────────────────┬────────────────────────────────────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
   ┌─────────┐    ┌──────────────┐  ┌──────────────┐
   │ Default │    │ ScreenPal    │  │ Other Agents │
   │ Agent   │    │ Agent        │  │              │
   └────┬────┘    └──────┬───────┘  └──────────────┘
        │                │
        │ includeMcpJson │ includeMcpJson: true
        │ (implicit)     │ (explicit)
        │                │
        ▼                ▼
   ┌────────────────────────────────────────┐
   │  ~/.kiro/settings/mcp.json             │
   │  (Global MCP Configuration)            │
   ├────────────────────────────────────────┤
   │ • video-transcriber                    │
   │ • vision-server                        │
   │ • knowledge                            │
   │ • github, docker-gateway, fetch, etc   │
   └────────────────────────────────────────┘
        │
        ├─────────────────┬──────────────┬──────────────┐
        │                 │              │              │
        ▼                 ▼              ▼              ▼
   ┌──────────────┐ ┌──────────────┐ ┌──────────┐ ┌──────────┐
   │ video-       │ │ vision-      │ │knowledge │ │ github   │
   │transcriber   │ │server        │ │ server   │ │ server   │
   │              │ │              │ │          │ │          │
   │ Node.js MCP  │ │ Node.js MCP  │ │ uvx MCP  │ │Docker MCP│
   └──────┬───────┘ └──────┬───────┘ └──────────┘ └──────────┘
          │                │
          │                │
          ▼                ▼
   ┌──────────────┐ ┌──────────────┐
   │ yt-dlp       │ │ Ollama       │
   │ FFmpeg       │ │ Moondream    │
   │ Whisper      │ │ Model        │
   └──────────────┘ └──────────────┘
```

## MCP Configuration Strategy

### Global Configuration (`~/.kiro/settings/mcp.json`)

The global MCP configuration defines all available MCP servers that can be used by any agent:

```json
{
  "mcpServers": {
    "video-transcriber": {
      "command": "sh",
      "args": ["-c", "node /tmp/video-transcriber-mcp/dist/index.js 2>/dev/null"],
      "env": { "WHISPER_MODEL": "base", ... },
      "disabled": false
    },
    "vision-server": {
      "command": "sh",
      "args": ["-c", "node /tmp/moondream-mcp/build/index.js 1>&2"],
      "env": { "OLLAMA_BASE_URL": "http://localhost:11434" },
      "disabled": false
    },
    "knowledge": { ... },
    "github": { ... },
    ...
  }
}
```

**Key Design Decisions:**

1. **Shell Wrapper (`sh -c`)**: Wraps Node.js processes to handle I/O redirection cleanly
2. **Output Redirection**:
   - `video-transcriber`: `2>/dev/null` - Suppress stderr
   - `vision-server`: `1>&2` - Redirect stdout to stderr (keeps protocol stream clean)
3. **Disabled Flag**: Set to `false` to enable servers globally

### Agent Profile (`~/.kiro/agents/screenpal-video-transcriber.json`)

The agent profile defines a specialized agent with custom behavior:

```json
{
  "name": "screenpal-video-transcriber",
  "description": "...",
  "mcpServers": {
    "vision-server": {
      "command": "sh",
      "args": ["-c", "node /tmp/moondream-mcp/build/index.js 1>&2"],
      "env": { "OLLAMA_BASE_URL": "http://localhost:11434" },
      "disabled": false
    }
  },
  "includeMcpJson": true,
  "tools": [...],
  "allowedTools": [...],
  "model": "claude-sonnet-4"
}
```

**Key Features:**

1. **`includeMcpJson: true`**: Inherits all servers from global config
2. **Agent-Specific Overrides**: Can override specific servers (e.g., vision-server)
3. **Tool Allowlist**: Restricts which tools the agent can use
4. **Custom Model**: Can specify different Claude model than default

## Data Flow

### Video Processing Pipeline

```
User Input (ScreenPal URL)
    │
    ▼
┌─────────────────────────────────────┐
│ ScreenPal Agent                     │
│ • URL validation                    │
│ • Toolchain verification            │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ video-transcriber-mcp               │
│ • yt-dlp: Extract media             │
│ • FFmpeg: Normalize audio           │
│ • Whisper: Transcribe speech        │
└────────────┬────────────────────────┘
             │
             ├─────────────────────────┐
             │                         │
             ▼                         ▼
    ┌──────────────────┐      ┌──────────────────┐
    │ Audio Transcript │      │ Frame Extraction │
    │ (with timestamps)│      │ (scene changes)  │
    └──────────────────┘      └────────┬─────────┘
                                       │
                                       ▼
                              ┌──────────────────┐
                              │ vision-server    │
                              │ • Moondream VLM  │
                              │ • Image analysis │
                              └────────┬─────────┘
                                       │
                                       ▼
                              ┌──────────────────┐
                              │ Visual Captions  │
                              │ (per frame)      │
                              └──────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ Knowledge Integration               │
│ • Merge transcript + visuals        │
│ • Temporal alignment                │
│ • Store in ./knowledge/             │
└─────────────────────────────────────┘
```

## MCP Server Details

### video-transcriber-mcp

**Purpose**: Audio extraction and transcription

**Tools Provided**:
- `transcribe_video`: Full pipeline (extract → transcribe)
- `extract_audio`: Audio-only extraction
- `get_video_info`: Metadata retrieval

**Dependencies**:
- yt-dlp: Media extraction
- FFmpeg: Audio normalization
- Whisper: Speech-to-text

**Configuration**:
```
WHISPER_MODEL: base|small|medium|large
YOUTUBE_FORMAT: bestaudio|best
WHISPER_DEVICE: cpu|cuda|mps
```

### vision-server (moondream-mcp)

**Purpose**: Visual analysis using local VLM

**Tools Provided**:
- `analyze_image`: Image captioning and QA
- `detect_objects`: Object detection
- `generate_caption`: Scene description

**Dependencies**:
- Ollama: Model runtime
- Moondream: Vision language model
- Puppeteer: Browser automation (optional)

**Configuration**:
```
OLLAMA_BASE_URL: http://localhost:11434
MOONDREAM_MODEL_PATH: /tmp/moondream-mcp/models
```

## Protocol Stream Integrity

### The Buffering Problem

MCP servers communicate via JSON-RPC over stdio. Any non-JSON output before the protocol handshake breaks the connection:

```
❌ BROKEN:
console.log("Starting server...")  ← Non-JSON output
{"jsonrpc":"2.0",...}              ← Protocol starts too late

✅ FIXED:
{"jsonrpc":"2.0",...}              ← Protocol starts immediately
```

### Solution: Output Redirection

1. **Suppress stdout**: `2>/dev/null` (video-transcriber)
2. **Redirect stdout to stderr**: `1>&2` (vision-server)
3. **Use console.error()**: All logging goes to stderr, not stdout

This ensures stdout is reserved exclusively for the MCP protocol stream.

## Tool Availability

### Default Agent

Inherits all tools from `~/.kiro/settings/mcp.json`:
- 7 core tools (github, docker-gateway, fetch, aws-docs, chrome-devtools, playwright, knowledge)
- video-transcriber tools
- vision-server tools

### ScreenPal Agent

Explicitly configured with:
- `includeMcpJson: true` → Inherits global servers
- `allowedTools` → Full video transcription and visual analysis capabilities
- Custom vision-server override → Ensures proper configuration

## Security Model

### Tool Allowlisting

```json
"allowedTools": [
  "fs_read",                           // Read files
  "fs_write",                          // Write output files
  "knowledge",                         // Query knowledge base
  "@video-transcriber/transcribe_video", // Full video transcription
  "@video-transcriber/extract_audio",   // Audio extraction
  "@video-transcriber/get_video_info",  // Video metadata
  "@vision-server/analyze_image",       // Visual analysis
  "@vision-server/detect_objects",      // Object detection
  "@vision-server/generate_caption"     // Image captioning
]
```

Enables:
- Complete video transcription workflow
- Visual analysis of video frames
- Comprehensive audio and visual insights

### Path Restrictions

```json
"toolsSettings": {
  "fs_write": {
    "allowedPaths": ["transcripts/**", "output/**", "temp/**"]
  }
}
```

Limits file operations to designated directories.

## Deployment Scenarios

### Local Development

```
~/.kiro/settings/mcp.json (global)
~/.kiro/agents/screenpal-video-transcriber.json (user-level)
```

### Team Shared Setup

```
/etc/kiro/settings/mcp.json (system-wide)
~/.kiro/agents/screenpal-video-transcriber.json (user override)
```

### Docker Container

```
/app/.kiro/settings/mcp.json (container-local)
/app/.kiro/agents/screenpal-video-transcriber.json (container-local)
```

## Performance Considerations

### Model Selection

- **Whisper**: `base` (74M) for CPU, `large` (1.5B) for GPU
- **Moondream**: Single model, optimized for local inference

### Resource Usage

- **CPU**: ~2-4 cores for Whisper
- **Memory**: 2-4GB for Moondream + Whisper
- **Disk**: 5GB for models + cache

### Optimization Tips

1. Use `WHISPER_DEVICE=mps` on Apple Silicon
2. Batch frame processing for vision analysis
3. Cache model downloads in persistent volume
4. Use `WHISPER_MODEL=base` for faster processing

## Troubleshooting

See `docs/TROUBLESHOOTING.md` for common issues and solutions.
