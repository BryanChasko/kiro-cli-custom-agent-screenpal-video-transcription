# MCP Server Configuration Guide

## Working Configuration (Updated 2025-12-24)

### Global MCP Config (Default Agent Profile)
**Location**: `~/.kiro/settings/mcp.json`

```json
{
  "mcpServers": {
    "github": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "-e", "GITHUB_PERSONAL_ACCESS_TOKEN", "ghcr.io/github/github-mcp-server:latest"],
      "env": {"GITHUB_PERSONAL_ACCESS_TOKEN": "your_token_here"},
      "disabled": false
    },
    "docker-gateway": {
      "command": "docker",
      "args": ["mcp", "gateway", "run"],
      "disabled": false
    },
    "fetch": {
      "command": "uvx",
      "args": ["mcp-server-fetch"],
      "disabled": false
    },
    "aws-docs": {
      "command": "uvx", 
      "args": ["awslabs.aws-documentation-mcp-server@latest"],
      "disabled": false
    },
    "chrome-devtools": {
      "command": "npx",
      "args": ["chrome-devtools-mcp@latest"],
      "disabled": false
    },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp"],
      "disabled": false
    },
    "knowledge": {
      "command": "uvx",
      "args": ["mcp-server-knowledge"],
      "disabled": false
    }
  }
}
```

### ScreenPal Agent Config (Self-Contained)
**Location**: `.kiro/agents/screenpal-video-transcriber.json`

Key settings:
- `includeMcpJson: false` - Prevents global MCP config inheritance
- `mcpServers` - Contains only media processing tools
- `vision-server` disabled due to path issues
- Tool references use `@video-transcriber/*` only

## Critical Configuration Rules

### 1. Profile Separation
- **Global Profile**: Seven core tools for default agent (github, docker-gateway, fetch, aws-docs, chrome-devtools, playwright, knowledge)
- **Custom Agent Profile**: Media processing tools only (video-transcriber, vision-server)
- ✅ Correct: `includeMcpJson: false` for custom agents
- ❌ Wrong: `includeMcpJson: true` causes tool conflicts

### 2. Resource Conflict Prevention
- Media processing tools excluded from global scope
- Custom agents are self-contained
- No duplicate tool initialization warnings

### 3. Vision Server Status
- Currently disabled due to moondream-mcp path issues
- Ollama API available at http://localhost:11434
- Moondream model installed and ready

### 4. Server Paths
- Verify files exist before configuration:
  ```bash
  ls -la /tmp/video-transcriber-mcp/dist/index.js
  ls -la /tmp/moondream-mcp/build/index.js
  ```

## Verification Checklist

```bash
# 1. Check global config has seven core tools
jq '.mcpServers | keys' ~/.kiro/settings/mcp.json

# 2. Check agent is self-contained
jq '{includeMcpJson, mcpServers: .mcpServers | keys}' .kiro/agents/screenpal-video-transcriber.json

# 3. Verify video-transcriber server exists
ls -la /tmp/video-transcriber-mcp/dist/index.js

# 4. Test Ollama API
curl -s http://localhost:11434/api/tags | jq '.models[] | .name'

# 5. Launch default agent (should have 7 core tools)
kiro-cli chat

# 6. Launch screenpal agent (should have video tools only)
kiro-cli chat --agent screenpal-video-transcriber
```

## Common Issues & Fixes

### Issue: "connection closed: initialize response"
**Cause**: Server name mismatch between global and agent configs
**Fix**: Ensure `video-transcriber` and `vision-server` names match exactly

### Issue: "No such file or directory" for MCP paths
**Cause**: Server files not built or at wrong location
**Fix**: Rebuild servers and verify paths exist

### Issue: Ollama not responding
**Cause**: Ollama service not running
**Fix**: 
```bash
open -a Ollama  # macOS
# or
ollama serve    # if installed via Homebrew
```

### Issue: Tool not found errors
**Cause**: Tool references don't match server names
**Fix**: Update tool references to use correct server names:
- `@video-transcriber/transcribe_video`
- `@vision-server/describe_image`

## Server Rebuild Instructions

If servers need rebuilding:

```bash
# Video Transcriber
cd /tmp/video-transcriber-mcp
npm install
npm run build

# Moondream
cd /tmp/moondream-mcp
npm install
npm run build
```

## Testing the Configuration

```bash
# Launch agent with verbose output
kiro-cli chat --agent screenpal-video-transcriber

# In agent, test with simple query first
> What tools do you have available?

# Then test video processing
> Please transcribe this ScreenPal video: https://go.screenpal.com/[video-id]
```
