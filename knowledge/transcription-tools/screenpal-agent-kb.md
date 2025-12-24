# Screenpal Video Transcriber Agent Knowledge Base

## Agent Overview
The Kiro CLI custom agent "screenpal-video-transcriber" processes ScreenPal video links to:
- Extract and transcribe audio to text using OpenAI Whisper
- Generate visual descriptions of screen content
- Track changes in screen content over time
- Store transcripts locally for knowledge base population

## Core Architecture
Local audio-visual transcription pipeline using:
- **yt-dlp**: Stream extraction from ScreenPal URLs
- **OpenAI Whisper**: Speech-to-text processing
- **FFmpeg**: Audio normalization (16 kHz mono PCM) + scene change detection
- **video-transcriber-mcp**: MCP server bridge for Kiro CLI integration
- **mcp-vision-analysis**: Visual analysis server with local VLMs
- **Ollama**: Local Docker-enabled VLM runtime (Moondream2/Llava)

## Required Dependencies & Documentation

### Package Management
- **uv Documentation**: High-performance Python tool management
- Installation and configuration for dependency isolation

### MCP Servers
- **Primary**: video-transcriber-mcp GitHub repository
- **Vision Analysis**: mcp-vision-analysis server for VLM integration
- **Alternative**: mcp-video-extraction GitHub repository
- All provide MCP integration patterns for media processing

### Vision Language Models
- **Moondream2**: Lightweight VLM for UI and code analysis (https://github.com/vikhyat/moondream)
- **Llava**: Multi-modal model for semantic scene understanding (https://ollama.com/library/llava)
- **Ollama Runtime**: Local Docker-enabled VLM serving platform

### Core Tools
- **yt-dlp Documentation**: Stream extraction parameters for HLS/DASH
- **OpenAI Whisper**: Research papers and implementation code
- **FFmpeg Documentation**: Audio processing + scene detection filters
- **HuggingFace Whisper Models**: Pre-trained model weights

## Configuration Requirements

### MCP Server Registration
Location: `~/.kiro/settings/mcp.json`
- video-transcriber-mcp server registered for audio processing
- mcp-vision-analysis server registered for visual analysis
- Both run via `uvx` with environment variables
- Vision server connects to local Ollama API endpoint

### Environment Variables
```bash
# Audio Processing
WHISPER_MODEL=base|large-v3  # Model size selection
YOUTUBE_FORMAT=bestaudio     # Audio extraction format

# Visual Analysis
OLLAMA_API_ENDPOINT=http://localhost:11434  # Local Ollama instance
VLM_MODEL=moondream2|llava                  # Vision model selection
SCENE_THRESHOLD=0.4                         # FFmpeg scene detection sensitivity
```

### Model Weights
Available at HuggingFace Whisper repository:
- `base`: Faster processing, lower accuracy
- `large-v3`: Higher accuracy, more resource intensive

## Processing Workflow

### 1. URL Processing
- Input: ScreenPal Watch URL (https://go.screenpal.com/*)
- yt-dlp scrapes DOM to identify media manifest
- Extracts both audio and video streams

### 2. Audio Normalization
- FFmpeg converts audio to 16 kHz mono PCM
- Ensures compatibility with Whisper model requirements
- Maintains audio quality for transcription accuracy

### 3. Scene Change Detection
- FFmpeg applies scene detection filter: `-filter:v "select='gt(scene,0.4)'"`
- Extracts only frames with significant visual changes (threshold 0.4)
- Optimizes processing by avoiding redundant frame analysis
- Generates timestamped keyframes for visual analysis

### 4. Transcription Process
- Whisper performs segmental inference on audio
- Generates timestamped text output
- Processes in chunks for memory efficiency

### 5. Visual Analysis Pipeline
- Extracted keyframes sent to mcp-vision-analysis server
- Local Ollama instance processes frames with Moondream2/Llava
- Generates semantic descriptions focusing on:
  - UI changes and window transitions
  - Code snippets and syntax highlighting
  - Slide transitions and content changes
  - User interaction patterns

### 6. Temporal Visual Context Processing
- Maintains "Visual State Log" comparing sequential frame descriptions
- Detects significant deltas between frames:
  - Window/application changes
  - New code blocks or file switches
  - Slide progression or content updates
  - UI state modifications
- Inserts "Screen Change Markers" when significant changes detected

### 7. Output Integration
- Combines audio transcript with visual descriptions
- Synchronizes timestamps between audio and visual events
- Formats for local knowledge base storage
- Maintains semantic context rather than raw OCR

## Tool Integration

### Primary Tool: transcribe_video
- Processes ScreenPal URLs end-to-end
- Returns structured transcript with timestamps
- Includes visual descriptions and change markers

### Vision Analysis Tool: analyze_frames
- Processes extracted keyframes through local VLMs
- Generates semantic descriptions of screen content
- Maintains temporal context between frames

### Expected Input Format
```
ScreenPal URL: https://go.screenpal.com/[video-id]
Scene Threshold: 0.4 (default)
VLM Model: moondream2|llava
```

### Expected Output Format
```
Audio Transcript:
[00:00:15] Speaker discusses code implementation...
[00:00:32] Explains function parameters...

Visual State Log:
[00:00:10] IDE showing Python file main.py
[00:00:25] **SCREEN CHANGE MARKER** - Switched to terminal window
[00:00:40] **SCREEN CHANGE MARKER** - New code block visible in editor

Semantic Descriptions:
- UI Context: Development environment with VS Code
- Code Analysis: Python function with error handling
- User Actions: Debugging workflow demonstration
```

## Technical Specifications

### Platform Support
- **Target Platform**: ScreenPal Video Hosting
- **Environment**: Docker-enabled for dependency isolation
- **Ollama Runtime**: Local VLM serving with Docker containers
- **OS Compatibility**: Cross-platform via containerization

### Performance Considerations
- Local processing ensures complete data privacy
- No cloud dependencies for transcription or visual analysis
- Scene detection reduces computational overhead
- Scalable based on local hardware capabilities
- VLM processing optimized for keyframes only

### Visual Analysis Capabilities
- **UI Change Detection**: Window switches, dialog boxes, menu interactions
- **Code Analysis**: Syntax highlighting, file changes, debugging sessions
- **Slide Transitions**: Presentation flow, content updates
- **Semantic Context**: Understanding user intent beyond raw text recognition
- **Temporal Coherence**: Maintaining context across frame sequences

### Error Handling
- URL validation for ScreenPal domains
- Fallback mechanisms for extraction failures
- Graceful degradation for processing errors

## Agent Metadata
- **Agent Name**: screenpal-video-transcriber
- **Primary Source**: https://go.screenpal.com
- **Extraction Method**: Local MCP Toolchain
- **Data Privacy**: Fully local processing
- **Relevance Score**: 10/10 for ScreenPal transcription tasks

## Usage Examples

### Basic Transcription
```
Agent receives ScreenPal URL → Extracts audio → Transcribes → Returns formatted output
```

### Advanced Processing
```
URL → Audio extraction → Visual analysis → Change detection → Comprehensive report
```

## Troubleshooting

### Common Issues
- MCP servers not registered in configuration
- Missing environment variables
- Insufficient disk space for model weights
- Network issues during initial extraction
- Ollama service not running locally
- VLM models not downloaded to Ollama instance
- Scene detection threshold too sensitive/insensitive

### Verification Steps
1. Check MCP server registration in `~/.kiro/settings/mcp.json`
2. Verify environment variables are set
3. Confirm Whisper model weights are downloaded
4. Test yt-dlp connectivity to ScreenPal
5. Verify Ollama service is running: `docker ps | grep ollama`
6. Check VLM model availability: `ollama list`
7. Test scene detection with sample video
8. Validate mcp-vision-analysis server connectivity

## Integration Points
- Kiro CLI custom agent framework
- Local knowledge base population with audio-visual metadata
- Transcript archival system with semantic annotations
- Visual State Log for temporal context tracking
- Screen Change Marker insertion system
- Ollama API integration for local VLM processing

## MCP Configuration Example
```json
{
  "mcpServers": {
    "video-transcriber": {
      "command": "uvx",
      "args": ["video-transcriber-mcp"],
      "env": {
        "WHISPER_MODEL": "base",
        "YOUTUBE_FORMAT": "bestaudio"
      }
    },
    "vision-analysis": {
      "command": "uvx", 
      "args": ["mcp-vision-analysis"],
      "env": {
        "OLLAMA_API_ENDPOINT": "http://localhost:11434",
        "VLM_MODEL": "moondream2",
        "SCENE_THRESHOLD": "0.4"
      }
    }
  }
}
```

## FFmpeg Scene Detection Command
```bash
ffmpeg -i input.mp4 -filter:v "select='gt(scene,0.4)'" -vsync vfr frames/frame_%04d.png
```
