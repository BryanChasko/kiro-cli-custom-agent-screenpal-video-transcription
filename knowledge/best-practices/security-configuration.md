# Security Configuration for ScreenPal Video Transcriber Agent

## URL Validation Patterns

### Allowed ScreenPal Domains
- `go.screenpal.com`
- `screenpal.com`
- `www.screenpal.com`

### URL Format Validation
```regex
^https?://(go\.)?screenpal\.com/[a-zA-Z0-9_-]+/?$
```

## File System Permissions

### Allowed Write Paths
- `transcripts/` - Transcript output files
- `output/` - Processed video outputs
- `temp/` - Temporary processing files
- `logs/` - Processing logs

### Restricted Paths
- System directories (`/etc`, `/usr`, `/bin`)
- User home directory (except project workspace)
- Hidden configuration files (`.ssh`, `.aws`)

## Tool Security Settings

### video-transcriber-mcp
- Maximum video duration: 3600 seconds (1 hour)
- Allowed domains: ScreenPal only
- File size limit: 2GB
- Temporary file cleanup: Automatic

### vision-analysis
- Maximum frames per video: 100
- Allowed image formats: PNG, JPG, JPEG
- Memory limit: 4GB
- Processing timeout: 3 minutes per frame batch

## Network Security

### Outbound Connections
- ScreenPal domains: Allowed for video download
- Localhost Ollama: Allowed for VLM processing
- External APIs: Blocked

### Data Privacy
- No cloud service connections
- All processing happens locally
- Temporary files automatically cleaned
- No telemetry or analytics

## Error Handling

### Invalid URLs
- Reject non-ScreenPal domains
- Validate URL format before processing
- Log security violations

### Resource Limits
- Graceful degradation on memory limits
- Automatic cleanup on timeout
- User notification on resource constraints
