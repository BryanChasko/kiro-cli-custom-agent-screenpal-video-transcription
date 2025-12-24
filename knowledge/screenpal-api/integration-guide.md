# ScreenPal API Integration Guide

## URL Structure

### Standard ScreenPal URLs
```
https://go.screenpal.com/[video-id]
https://screenpal.com/watch/[video-id]
```

### Video ID Format
- Alphanumeric characters
- Hyphens and underscores allowed
- Typically 8-12 characters long

## Video Metadata

### Available Information
- Video title
- Duration
- Upload date
- Resolution
- Frame rate
- Audio codec

### Extraction Methods
```bash
# Using yt-dlp
yt-dlp --print-json "https://go.screenpal.com/[video-id]"

# Using video-transcriber-mcp
get_video_info --url "https://go.screenpal.com/[video-id]"
```

## Stream Formats

### Audio Streams
- Primary: AAC 128kbps
- Fallback: MP3 128kbps
- Format preference: bestaudio

### Video Streams
- Primary: MP4 H.264
- Resolutions: 720p, 1080p
- Frame rates: 30fps, 60fps

## Rate Limiting

### Request Limits
- 10 requests per minute per IP
- 100 requests per hour per IP
- Exponential backoff on rate limit

### Best Practices
- Cache video metadata
- Batch process multiple videos
- Implement retry logic with delays

## Error Codes

### Common Errors
- 404: Video not found or private
- 403: Access denied or region blocked
- 429: Rate limit exceeded
- 500: Server error

### Handling Strategies
- Validate URL before processing
- Implement graceful fallbacks
- Log errors for debugging
- Notify user of processing issues
