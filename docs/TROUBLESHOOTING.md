# Troubleshooting Guide

## MCP Server Issues

### Error: "connection closed: initialize response"

**Cause**: MCP protocol stream is corrupted (non-JSON output before handshake)

**Solution**:
```bash
# Test the server directly
node /tmp/moondream-mcp/build/index.js 2>/dev/null | head -c 1

# Should output: {
# If not, there's console.log() output before protocol
```

**Fix**:
1. Check source code for `console.log()` or `console.error()` calls before protocol initialization
2. Remove or comment out diagnostic messages
3. Rebuild: `npm run build`
4. Verify: `node server.js 2>/dev/null | head -c 1` outputs `{`

**Vision-server specific fix (Dec 24, 2025)**:
- Modified moondream-mcp to use Ollama API directly instead of spawning local moondream server
- Removed PythonSetup initialization that was failing
- Removed diagnostic console.error() messages that corrupted protocol stream
- Updated MCP config to suppress stderr: `node /tmp/moondream-mcp/build/index.js 2>/dev/null`

### Error: "Ollama API not responding"

**Cause**: Ollama service not running or not accessible

**Solution**:
```bash
# Check if Ollama is running
curl -s http://localhost:11434/api/tags

# If native Ollama (macOS)
open -a Ollama

# If Docker Ollama
docker ps | grep ollama
docker start ollama-screenpal

# Wait for service
sleep 5
curl -s http://localhost:11434/api/tags
```

### Error: "Moondream model not found"

**Cause**: Model not downloaded

**Solution**:
```bash
# Pull the model
ollama pull moondream

# Or if using Docker
docker exec ollama-screenpal ollama pull moondream

# Verify
curl -s http://localhost:11434/api/tags | grep moondream
```

## Dependency Issues

### Error: "yt-dlp: command not found"

**Cause**: yt-dlp not installed

**Solution**:
1. Run setup script: `./setup.pl` (automatically installs yt-dlp)
2. Or install manually: `brew install yt-dlp`
3. Verify: `yt-dlp --version`

### Error: "whisper: command not found"

**Cause**: OpenAI Whisper not installed

**Solution**:
1. Run setup script: `./setup.pl` (automatically installs Whisper)
2. Or install manually: `brew install openai-whisper`
3. Verify: `whisper --help`

## Agent Issues

### Error: "Tool not found"

**Cause**: Tool not in `allowedTools` or server not configured

**Solution**:
1. Check agent config: `cat ~/.kiro/agents/screenpal-video-transcriber.json | jq .allowedTools`
2. Verify tool name matches exactly
3. Check `includeMcpJson: true` is set
4. Verify global config has the server

### Error: "Agent failed to initialize"

**Cause**: MCP server failed to start

**Solution**:
```bash
# Enable trace logging
KIRO_LOG_LEVEL=trace kiro-cli chat --agent screenpal-video-transcriber

# Check logs
cat $TMPDIR/kiro-log/kiro-chat.log | tail -50

# Test each server individually
node /tmp/video-transcriber-mcp/dist/index.js --help
node /tmp/moondream-mcp/build/index.js 2>/dev/null | head -c 50
```

## Video Processing Issues

### Error: "Failed to extract video"

**Cause**: yt-dlp can't access the video

**Solution**:
1. Verify URL is valid and accessible
2. Check yt-dlp is installed: `yt-dlp --version`
3. If missing, run setup script: `./setup.pl`
4. Test directly: `yt-dlp -j "https://go.screenpal.com/..."`

### Error: "Whisper transcription failed"

**Cause**: Whisper not installed or audio format issue

**Solution**:
1. Check Whisper is installed: `whisper --help`
2. If missing, run setup script: `./setup.pl`
3. Verify audio file exists: `ls -la temp/`
4. Test Whisper directly: `whisper temp/audio.wav --model base`
5. Check disk space: `df -h`

### Error: "Vision analysis timeout"

**Cause**: Moondream model is slow or Ollama is unresponsive

**Solution**:
1. Check Ollama is responsive: `curl -s http://localhost:11434/api/tags`
2. Reduce frame count in config
3. Use smaller Whisper model: `WHISPER_MODEL=base`
4. Check system resources: `top` or `Activity Monitor`

## Configuration Issues

### Error: "Invalid JSON in mcp.json"

**Cause**: Syntax error in configuration file

**Solution**:
```bash
# Validate JSON
jq . ~/.kiro/settings/mcp.json

# If error, check for:
# - Missing commas
# - Trailing commas
# - Unquoted keys
# - Mismatched braces
```

### Error: "Path not found"

**Cause**: MCP server path doesn't exist

**Solution**:
```bash
# Check paths exist
ls -la /tmp/video-transcriber-mcp/dist/index.js
ls -la /tmp/moondream-mcp/build/index.js

# If missing, rebuild:
cd /tmp/video-transcriber-mcp && npm run build
cd /tmp/moondream-mcp && npm run build
```

## Performance Issues

### Slow Transcription

**Cause**: Using large Whisper model or CPU inference

**Solution**:
1. Use smaller model: `WHISPER_MODEL=base`
2. Enable GPU: `WHISPER_DEVICE=mps` (macOS) or `cuda` (NVIDIA)
3. Check system resources: `top`

### Slow Vision Analysis

**Cause**: Moondream model is slow

**Solution**:
1. Reduce frame count
2. Use smaller images
3. Check Ollama is using GPU: `ollama ps`
4. Increase system resources

### High Memory Usage

**Cause**: Models loaded in memory

**Solution**:
1. Close other applications
2. Use smaller models
3. Process videos in smaller chunks
4. Increase swap space

## Debugging Steps

### 1. Enable Trace Logging

```bash
KIRO_LOG_LEVEL=trace kiro-cli chat --agent screenpal-video-transcriber
```

Check `$TMPDIR/kiro-log/kiro-chat.log` for detailed output

### 2. Test Each Component

```bash
# Test video-transcriber
node /tmp/video-transcriber-mcp/dist/index.js --help

# Test vision-server
node /tmp/moondream-mcp/build/index.js 2>/dev/null | head -c 50

# Test Ollama
curl -s http://localhost:11434/api/tags

# Test yt-dlp (should be installed by setup.pl)
yt-dlp --version

# Test Whisper (should be installed by setup.pl)
whisper --help | head -1

# Test FFmpeg
ffmpeg -version
```

### 3. Check Configuration

```bash
# Global config
jq . ~/.kiro/settings/mcp.json

# Agent config
jq . ~/.kiro/agents/screenpal-video-transcriber.json

# Check includeMcpJson
jq .includeMcpJson ~/.kiro/agents/screenpal-video-transcriber.json
```

### 4. Test Protocol Stream

```bash
# Should output JSON starting with {
node /tmp/moondream-mcp/build/index.js 2>/dev/null | head -c 50

# Should output nothing (clean stderr)
node /tmp/video-transcriber-mcp/dist/index.js 2>&1 | head -c 50
```

## Getting Help

1. Check logs: `KIRO_LOG_LEVEL=trace`
2. Test components individually
3. Verify configuration files
4. Check system resources
5. Review this troubleshooting guide

## Common Solutions

| Issue | Solution |
|-------|----------|
| MCP won't connect | Test protocol stream, check for console.log() |
| Tool not found | Check allowedTools, verify includeMcpJson |
| Ollama not responding | Start Ollama, check port 11434 |
| Video extraction fails | Verify URL, run ./setup.pl for yt-dlp |
| Transcription slow | Use smaller model, enable GPU |
| Memory issues | Close apps, use smaller models |
| Configuration error | Validate JSON, check paths |
