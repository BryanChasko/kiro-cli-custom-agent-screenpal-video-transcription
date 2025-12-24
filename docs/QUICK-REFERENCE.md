# Quick Reference

## File Locations

| File | Purpose |
|------|---------|
| `~/.kiro/settings/mcp.json` | Global MCP servers (all agents) |
| `~/.kiro/agents/screenpal-video-transcriber.json` | Agent profile (this agent only) |
| `/tmp/video-transcriber-mcp/` | Video transcriber MCP server |
| `/tmp/moondream-mcp/` | Vision server MCP server |

## Common Commands

```bash
# Setup (installs yt-dlp, Whisper, builds MCP servers)
./setup.pl

# Launch agent
kiro-cli chat --agent screenpal-video-transcriber

# Enable trace logging
KIRO_LOG_LEVEL=trace kiro-cli chat --agent screenpal-video-transcriber

# Test dependencies
yt-dlp --version
whisper --help | head -1

# Test MCP servers
node /tmp/video-transcriber-mcp/dist/index.js --help
node /tmp/moondream-mcp/build/index.js 2>/dev/null | head -c 50

# Test vision analysis
curl -s http://localhost:11434/api/tags | grep moondream

# Check Ollama
curl -s http://localhost:11434/api/tags

# Validate JSON config
jq . ~/.kiro/settings/mcp.json
jq . ~/.kiro/agents/screenpal-video-transcriber.json

# Rebuild MCP servers
cd /tmp/video-transcriber-mcp && npm run build
cd /tmp/moondream-mcp && npm run build
```

## Configuration Quick Edit

### Enable/Disable Servers

```bash
# Edit global config
nano ~/.kiro/settings/mcp.json

# Set "disabled": false to enable
# Set "disabled": true to disable
```

### Change Whisper Model

```json
"env": {
  "WHISPER_MODEL": "base"  // tiny|base|small|medium|large
}
```

### Change GPU Device

```json
"env": {
  "WHISPER_DEVICE": "cpu"  // cpu|cuda|mps
}
```

## Troubleshooting Quick Fixes

| Problem | Fix |
|---------|-----|
| MCP won't connect | `node server.js 2>/dev/null \| head -c 1` should output `{` |
| Tool not found | Check `allowedTools` in agent config |
| Ollama not responding | `curl http://localhost:11434/api/tags` |
| Moondream missing | `ollama pull moondream` |
| Slow transcription | Use `WHISPER_MODEL=base` |
| High memory | Close apps, use smaller models |

## MCP Server Status

```bash
# Check if servers are running
ps aux | grep node

# Check Ollama
curl -s http://localhost:11434/api/tags | jq .

# Check logs
KIRO_LOG_LEVEL=trace kiro-cli chat --agent screenpal-video-transcriber
tail -f $TMPDIR/kiro-log/kiro-chat.log
```

## Configuration Hierarchy

```
Global Config (~/.kiro/settings/mcp.json)
    ↓
    ├─ video-transcriber
    ├─ vision-server
    ├─ knowledge
    └─ ... (other servers)
    
Agent Config (~/.kiro/agents/screenpal-video-transcriber.json)
    ├─ includeMcpJson: true (inherit all global)
    ├─ vision-server (override)
    └─ allowedTools (restrict access)
```

## Tool Availability

### Default Agent
- All global servers
- All tools

### ScreenPal Agent
- All global servers (via `includeMcpJson: true`)
- Restricted to `allowedTools`:
  - `fs_read`
  - `knowledge`
  - `@video-transcriber/get_video_info`

## Environment Variables

### video-transcriber
- `WHISPER_MODEL`: base|small|medium|large
- `YOUTUBE_FORMAT`: bestaudio|best
- `WHISPER_DEVICE`: cpu|cuda|mps

### vision-server
- `OLLAMA_BASE_URL`: http://localhost:11434

## Performance Tips

1. Use `WHISPER_MODEL=base` for faster processing
2. Enable GPU: `WHISPER_DEVICE=mps` (macOS) or `cuda` (NVIDIA)
3. Reduce frame count for vision analysis
4. Close other applications
5. Use SSD for temporary files

## Getting Help

1. Check `docs/TROUBLESHOOTING.md`
2. Enable trace logging: `KIRO_LOG_LEVEL=trace`
3. Test components individually
4. Check configuration files
5. Review system resources
