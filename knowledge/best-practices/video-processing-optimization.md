# Video Processing Best Practices

## Audio Transcription Optimization

### Whisper Model Selection
- **base**: Fast processing, good for clear speech
- **small**: Balanced speed/accuracy for most content
- **medium**: Better accuracy for technical content
- **large-v3**: Highest accuracy for complex audio

### Audio Preprocessing
```bash
# Normalize audio levels
ffmpeg -i input.mp4 -af "loudnorm" -ar 16000 -ac 1 output.wav

# Remove background noise
ffmpeg -i input.mp4 -af "highpass=f=200,lowpass=f=3000" output.wav
```

### Transcription Quality Tips
- Use 16kHz mono audio for Whisper
- Segment long videos into chunks
- Apply noise reduction for poor quality audio
- Use language-specific models when available

## Visual Analysis Optimization

### Frame Selection Strategy
- Use scene detection to identify key moments
- Extract frames at visual transition points
- Avoid redundant similar frames
- Focus on content-rich frames (text, UI elements)

### VLM Model Comparison
- **Moondream2**: Fast, good for UI and code analysis
- **Llava**: More detailed descriptions, slower processing
- **Llava:13b**: Highest quality, requires more resources

### Frame Processing Pipeline
```bash
# Extract keyframes with scene detection
ffmpeg -i input.mp4 -filter:v "select='gt(scene,0.4)'" -vsync vfr frames/frame_%04d.png

# Resize for VLM processing
ffmpeg -i input.mp4 -vf "scale=512:512:force_original_aspect_ratio=decrease" output.png
```

## Performance Optimization

### Resource Management
- Process videos in chunks to manage memory
- Clean up temporary files regularly
- Monitor disk space during processing
- Use appropriate thread counts for CPU

### Batch Processing
- Group similar videos together
- Reuse model loading when possible
- Implement progress tracking
- Handle interruptions gracefully

### Quality vs Speed Trade-offs
- Lower resolution for faster processing
- Reduce frame rate for long videos
- Use smaller models for real-time needs
- Cache results to avoid reprocessing

## Output Formatting

### Transcript Structure
```json
{
  "video_id": "screenpal_video_id",
  "duration": 1234.56,
  "transcript": [
    {
      "start": 0.0,
      "end": 5.2,
      "text": "Welcome to this tutorial...",
      "confidence": 0.95
    }
  ],
  "visual_analysis": [
    {
      "timestamp": 0.0,
      "description": "Desktop showing VS Code editor",
      "change_type": "scene_start"
    }
  ]
}
```

### Metadata Preservation
- Include video source information
- Track processing parameters used
- Store model versions and settings
- Maintain processing timestamps
