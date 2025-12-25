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

## Configuration Requirements (Verified Working)

### MCP Server Registration
Location: `~/.kiro/settings/mcp.json`

```json
{
  "mcpServers": {
    "video-transcriber": {
      "command": "node",
      "args": ["/tmp/video-transcriber-mcp/dist/index.js"],
      "env": {
        "WHISPER_MODEL": "base",
        "YOUTUBE_FORMAT": "bestaudio",
        "WHISPER_DEVICE": "cpu"
      },
      "timeout": 300000,
      "disabled": false
    },
    "vision-server": {
      "command": "node",
      "args": ["/tmp/moondream-mcp/build/index.js"],
      "env": {
        "OLLAMA_BASE_URL": "http://localhost:11434"
      },
      "timeout": 180000,
      "disabled": false
    }
  }
}
```

### Key Configuration Points
- **Execution Method**: Node.js direct execution (not uvx)
- **Server Names**: Must match between global and agent configs
- **Environment Variables**: Minimal set to avoid conflicts
- **Agent Setting**: `includeMcpJson: true` to load global config
- **Tool References**: Use `@video-transcriber/*` and `@vision-server/*`

### Troubleshooting
See `knowledge/workflow-automation/mcp-troubleshooting.md` for:
- Configuration conflict resolution
- Server initialization failures
- Ollama connectivity issues
- Tool reference errors

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
- Processes ScreenPal URLs for audio transcription only
- Returns timestamped text transcript
- Does NOT include visual analysis or frame extraction

### Visual Analysis Tools (Error-Handled Process)
```python
def safe_visual_analysis(image_path):
    # 1. Validate path - convert ~ to absolute
    abs_path = os.path.expanduser(image_path) if image_path.startswith('~') else os.path.abspath(image_path)
    if not os.path.exists(abs_path):
        return {"error": f"Image not found: {image_path}", "fallback": "skip_frame"}
    
    # 2. Check Ollama connection
    try:
        result = subprocess.run(['curl', '-s', 'http://localhost:11434/api/tags'], 
                              capture_output=True, text=True, timeout=5)
        if result.returncode != 0:
            return {"error": "Ollama not responding", "fallback": "audio_only"}
    except:
        return {"error": "Ollama connection failed", "fallback": "audio_only"}
    
    # 3. Call vision tools with absolute path
    return {"path": abs_path, "ready": True}
```

### Vision Analysis Tools
- **analyze_image**: Process individual frames with VLM analysis
- **detect_objects**: Identify and locate objects within frames  
- **generate_caption**: Create descriptive captions for visual content
- Maintains temporal context between frames

### Vision Analysis Tools
- **analyze_image**: Process individual frames with VLM analysis
- **detect_objects**: Identify and locate objects within frames
- **generate_caption**: Create descriptive captions for visual content
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
