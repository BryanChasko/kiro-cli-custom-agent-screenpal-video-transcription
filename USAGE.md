# ScreenPal Video Transcriber Agent - Usage Guide

## Installation

### Prerequisites
1. **Kiro CLI** installed and configured
2. **Docker** installed and running
3. **Python 3.8+** with uv package manager
4. **Ollama** service running locally

### Setup Steps

1. **Install MCP servers**:
```bash
uvx install video-transcriber-mcp
uvx install mcp-vision-analysis
```

2. **Setup Ollama and models**:
```bash
# Start Ollama service
ollama serve

# Download VLM models
ollama pull moondream2
ollama pull llava
```

3. **Install the agent**:
```bash
# Run automated setup
./setup.pl

# Or install globally
./setup.pl --global
```

4. **Verify installation**:
```bash
# Check MCP servers
uvx video-transcriber-mcp --help
uvx mcp-vision-analysis --help

# Check Ollama models
ollama list

# Test agent
kiro-cli chat --agent screenpal-video-transcriber
```

## Basic Usage

### Starting the Agent
```bash
kiro-cli chat --agent screenpal-video-transcriber
```

### Simple Transcription
```
> Please transcribe this ScreenPal video: https://go.screenpal.com/abc123xyz
```

### Advanced Processing
```
> Transcribe this video with detailed visual analysis: https://go.screenpal.com/abc123xyz
> Use the large Whisper model for higher accuracy
> Set scene detection threshold to 0.3 for more detailed visual changes
```

## Example Workflows

### 1. Tutorial Video Processing
```
Input: "Process this coding tutorial: https://go.screenpal.com/coding-demo"

Expected Output:
- Audio transcript with timestamps
- Visual descriptions of code changes
- Screen change markers for different applications
- Structured output saved to transcripts/
```

### 2. Presentation Analysis
```
Input: "Analyze this presentation video: https://go.screenpal.com/presentation-2024"

Expected Output:
- Speaker transcript
- Slide transition markers
- Visual content descriptions
- Temporal context tracking
```

### 3. Batch Processing
```
Input: "Process these training videos:
- https://go.screenpal.com/training-01
- https://go.screenpal.com/training-02
- https://go.screenpal.com/training-03"

Expected Output:
- Individual transcripts for each video
- Combined summary report
- Consistent formatting across all outputs
```

## Configuration Options

### Whisper Model Selection
```
> Use the base Whisper model for faster processing
> Switch to large-v3 model for better accuracy
> Set Whisper device to GPU for faster processing
```

### Visual Analysis Settings
```
> Use Moondream2 for lightweight visual analysis
> Switch to Llava for more detailed descriptions
> Set scene threshold to 0.2 for sensitive change detection
> Limit to 30 frames for quick processing
```

### Output Formatting
```
> Save transcript as JSON format
> Include confidence scores in output
> Generate summary report
> Export to knowledge base format
```

## Troubleshooting

### Common Issues

#### MCP Server Not Found
```bash
# Check installation
uvx list | grep video-transcriber
uvx list | grep vision-analysis

# Reinstall if needed
uvx install video-transcriber-mcp --force
```

#### Ollama Connection Error
```bash
# Check Ollama status
curl http://localhost:11434/api/tags

# Restart Ollama
ollama serve
```

#### Video Download Failed
- Verify ScreenPal URL format
- Check internet connection
- Ensure video is public/accessible
- Try alternative URL format

#### Processing Timeout
- Reduce video length or quality
- Use smaller Whisper model
- Decrease frame processing count
- Check available system resources

### Error Messages

#### "Invalid ScreenPal URL"
- URL must be from go.screenpal.com or screenpal.com
- Check for typos in video ID
- Ensure video is publicly accessible

#### "Whisper model not found"
- Model will download automatically on first use
- Check internet connection for download
- Verify sufficient disk space

#### "VLM processing failed"
- Ensure Ollama service is running
- Check if VLM model is downloaded
- Verify Docker is running for Ollama

## Performance Tips

### For Large Videos
- Use base Whisper model for speed
- Reduce scene detection sensitivity
- Process in chunks if memory limited
- Clean temp files regularly

### For High Accuracy
- Use large-v3 Whisper model
- Increase scene detection sensitivity
- Use Llava for detailed visual analysis
- Allow longer processing times

### For Batch Processing
- Process videos sequentially
- Monitor system resources
- Implement progress tracking
- Handle failures gracefully

## Output Examples

### Basic Transcript
```json
{
  "video_id": "abc123xyz",
  "url": "https://go.screenpal.com/abc123xyz",
  "duration": 300.5,
  "processed_at": "2025-12-24T11:00:00Z",
  "transcript": [
    {
      "start": 0.0,
      "end": 4.2,
      "text": "Welcome to this Python tutorial",
      "confidence": 0.98
    }
  ],
  "visual_analysis": [
    {
      "timestamp": 0.0,
      "description": "Desktop with VS Code editor open",
      "change_type": "scene_start"
    }
  ]
}
```

### Detailed Analysis
```json
{
  "video_id": "abc123xyz",
  "processing_info": {
    "whisper_model": "base",
    "vlm_model": "moondream2",
    "scene_threshold": 0.4,
    "frames_processed": 25
  },
  "transcript": [...],
  "visual_timeline": [
    {
      "timestamp": 0.0,
      "frame_id": "frame_0001",
      "description": "VS Code editor showing Python file main.py",
      "ui_elements": ["editor", "file_tree", "terminal"],
      "code_visible": true
    },
    {
      "timestamp": 15.3,
      "frame_id": "frame_0002",
      "description": "**SCREEN CHANGE** - Switched to terminal window",
      "change_type": "application_switch",
      "previous_context": "VS Code editor"
    }
  ],
  "summary": {
    "total_speech_time": 280.1,
    "silence_periods": 5,
    "screen_changes": 8,
    "applications_used": ["VS Code", "Terminal", "Browser"]
  }
}
```
