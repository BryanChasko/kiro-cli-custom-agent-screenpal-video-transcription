# Kiro CLI Integration Guide

## How Kiro CLI Uses MCP Servers

Kiro CLI is an AI assistant framework that extends capabilities through MCP (Model Context Protocol) servers. This guide explains how the ScreenPal agent leverages this system.

## Kiro CLI Architecture

```
┌─────────────────────────────────────────┐
│         Kiro CLI Chat Interface          │
│  (kiro-cli chat --agent [name])         │
└────────────────┬────────────────────────┘
                 │
        ┌────────┴────────┐
        │                 │
        ▼                 ▼
   ┌─────────────┐  ┌──────────────────┐
   │ Default     │  │ Custom Agents    │
   │ Agent       │  │ (screenpal-...)  │
   └────┬────────┘  └────────┬─────────┘
        │                    │
        │ Loads config       │ Loads config
        │                    │
        ▼                    ▼
   ┌────────────────────────────────────┐
   │ ~/.kiro/settings/mcp.json          │
   │ (Global MCP Configuration)         │
   └────────────────────────────────────┘
        │
        ├─ video-transcriber
        ├─ vision-server
        ├─ knowledge
        └─ ... (other servers)
```

## Configuration Loading Order

### 1. Default Agent

When you run `kiro-cli chat` (without `--agent`):

```
1. Load ~/.kiro/settings/mcp.json
2. Start all enabled MCP servers
3. Make all tools available
4. Use default model (claude-sonnet-4)
```

### 2. Custom Agent

When you run `kiro-cli chat --agent screenpal-video-transcriber`:

```
1. Load ~/.kiro/agents/screenpal-video-transcriber.json
2. Check includeMcpJson: true
3. Load ~/.kiro/settings/mcp.json (global servers)
4. Apply agent-specific overrides (mcpServers)
5. Apply tool restrictions (allowedTools)
6. Start MCP servers
7. Make restricted tools available
8. Use agent-specific model
```

## MCP Server Lifecycle

### Startup Sequence

```
Agent Initialization
    │
    ├─ Read agent config
    ├─ Read global MCP config
    ├─ Merge configurations
    │
    ▼
Start MCP Servers
    │
    ├─ For each enabled server:
    │  ├─ Execute command (sh, uvx, docker, etc)
    │  ├─ Set environment variables
    │  ├─ Wait for initialization
    │  └─ Establish stdio connection
    │
    ▼
Initialize Protocol
    │
    ├─ Send initialize request
    ├─ Receive initialize response
    ├─ List available tools
    │
    ▼
Ready for Tool Calls
    │
    └─ Agent can now call tools
```

### Tool Availability

```
Global Tools (from ~/.kiro/settings/mcp.json)
    │
    ├─ video-transcriber tools
    │  ├─ transcribe_video
    │  ├─ extract_audio
    │  └─ get_video_info
    │
    ├─ vision-server tools
    │  ├─ analyze_image
    │  ├─ detect_objects
    │  └─ generate_caption
    │
    ├─ knowledge tools
    │  ├─ search
    │  ├─ add
    │  └─ show
    │
    └─ ... (other servers)
    
Agent Allowlist (from agent config)
    │
    └─ Only these tools are available:
       ├─ fs_read
       ├─ knowledge
       └─ @video-transcriber/get_video_info
```

## Configuration Merging

### Example: ScreenPal Agent

**Global Config** (`~/.kiro/settings/mcp.json`):
```json
{
  "mcpServers": {
    "video-transcriber": { /* ... */ },
    "vision-server": { /* ... */ },
    "knowledge": { /* ... */ },
    "github": { /* ... */ }
  }
}
```

**Agent Config** (`~/.kiro/agents/screenpal-video-transcriber.json`):
```json
{
  "includeMcpJson": true,
  "mcpServers": {
    "vision-server": { /* OVERRIDE */ }
  },
  "allowedTools": ["fs_read", "knowledge", "@video-transcriber/get_video_info"]
}
```

**Result**:
```
Servers Started:
  ✓ video-transcriber (from global)
  ✓ vision-server (from agent override)
  ✓ knowledge (from global)
  ✓ github (from global)

Tools Available:
  ✓ fs_read
  ✓ knowledge
  ✓ @video-transcriber/get_video_info
  
Tools Blocked:
  ✗ @video-transcriber/transcribe_video
  ✗ @vision-server/analyze_image
  ✗ @github/create_issue
  ✗ ... (all others)
```

## How Tools Are Called

### 1. User Request

```
User: "Please transcribe this video: https://go.screenpal.com/..."
```

### 2. Agent Processing

```
Agent receives request
    │
    ├─ Parse user input
    ├─ Determine needed tools
    ├─ Check allowedTools
    │
    ▼
Tool Call Decision
    │
    ├─ Tool in allowedTools? YES → Continue
    ├─ Tool in allowedTools? NO → Reject
    │
    ▼
Send Tool Call to MCP Server
    │
    ├─ Tool: @video-transcriber/get_video_info
    ├─ Params: { url: "https://go.screenpal.com/..." }
    │
    ▼
MCP Server Processes
    │
    ├─ video-transcriber-mcp receives call
    ├─ Executes tool logic
    ├─ Returns result
    │
    ▼
Agent Receives Result
    │
    ├─ Process result
    ├─ Generate response
    ├─ Return to user
```

### 2. Tool Execution Flow

```
Agent → MCP Server (stdio)
    │
    ├─ Send JSON-RPC request
    │  {
    │    "jsonrpc": "2.0",
    │    "id": 1,
    │    "method": "tools/call",
    │    "params": {
    │      "name": "@video-transcriber/get_video_info",
    │      "arguments": { "url": "..." }
    │    }
    │  }
    │
    ▼
MCP Server Processes
    │
    ├─ Parse request
    ├─ Execute tool
    ├─ Generate response
    │
    ▼
MCP Server → Agent (stdio)
    │
    └─ Send JSON-RPC response
       {
         "jsonrpc": "2.0",
         "id": 1,
         "result": {
           "content": [
             {
               "type": "text",
               "text": "Video info: ..."
             }
           ]
         }
       }
```

## Environment Variable Propagation

### Global Config

```json
{
  "mcpServers": {
    "video-transcriber": {
      "env": {
        "WHISPER_MODEL": "base",
        "WHISPER_DEVICE": "cpu"
      }
    }
  }
}
```

### Agent Override

```json
{
  "mcpServers": {
    "video-transcriber": {
      "env": {
        "WHISPER_MODEL": "small",
        "WHISPER_DEVICE": "mps"
      }
    }
  }
}
```

### Result

When agent starts video-transcriber:
```bash
WHISPER_MODEL=small WHISPER_DEVICE=mps node /tmp/video-transcriber-mcp/dist/index.js
```

## Protocol Stream Integrity

### Why It Matters

MCP servers communicate via JSON-RPC over stdio. The protocol stream must be pure JSON:

```
✅ CORRECT:
{"jsonrpc":"2.0","id":1,"method":"initialize",...}
{"jsonrpc":"2.0","id":1,"result":{...}}

❌ BROKEN:
Starting server...
{"jsonrpc":"2.0","id":1,"method":"initialize",...}
                    ↑ Too late! Connection fails
```

### How Kiro Ensures Integrity

1. **Output Redirection**: `sh -c "node server.js 1>&2"`
   - Redirects stdout to stderr
   - Keeps protocol stream clean

2. **Stderr Suppression**: `sh -c "node server.js 2>/dev/null"`
   - Suppresses all stderr output
   - Keeps protocol stream clean

3. **Logging to stderr**: `console.error()` instead of `console.log()`
   - Logs go to stderr (not protocol stream)
   - Protocol stream stays pure JSON

## Debugging MCP Integration

### 1. Check Configuration Loading

```bash
# View global config
jq . ~/.kiro/settings/mcp.json

# View agent config
jq . ~/.kiro/agents/screenpal-video-transcriber.json

# Check includeMcpJson
jq .includeMcpJson ~/.kiro/agents/screenpal-video-transcriber.json
```

### 2. Enable Trace Logging

```bash
KIRO_LOG_LEVEL=trace kiro-cli chat --agent screenpal-video-transcriber
```

Check logs in `$TMPDIR/kiro-log/kiro-chat.log`:
- MCP server startup
- Tool calls
- Protocol messages
- Errors

### 3. Test Protocol Stream

```bash
# Should output JSON starting with {
node /tmp/moondream-mcp/build/index.js 2>/dev/null | head -c 50

# Should output nothing (clean)
node /tmp/video-transcriber-mcp/dist/index.js 2>&1 | head -c 50
```

### 4. Verify Tool Availability

```bash
# In agent chat
> What tools do you have access to?

# Agent will list available tools based on allowedTools
```

## Best Practices

### 1. Use Global Config for Shared Servers

```json
{
  "mcpServers": {
    "knowledge": { /* all agents need this */ },
    "github": { /* all agents need this */ }
  }
}
```

### 2. Use Agent Config for Specialized Servers

```json
{
  "mcpServers": {
    "vision-server": { /* only screenpal agent needs this */ }
  }
}
```

### 3. Restrict Tools with allowedTools

```json
{
  "allowedTools": [
    "fs_read",
    "knowledge",
    "@video-transcriber/get_video_info"
  ]
}
```

### 4. Test Protocol Stream Before Deployment

```bash
node /tmp/moondream-mcp/build/index.js 2>/dev/null | head -c 1
# Should output: {
```

### 5. Use includeMcpJson for Tool Inheritance

```json
{
  "includeMcpJson": true,
  "mcpServers": {
    "custom-server": { /* agent-specific */ }
  }
}
```

## Troubleshooting Integration Issues

### Issue: "Tool not found"

**Check**:
1. Is server in global config? `jq .mcpServers ~/.kiro/settings/mcp.json`
2. Is `includeMcpJson: true`? `jq .includeMcpJson ~/.kiro/agents/screenpal-video-transcriber.json`
3. Is tool in `allowedTools`? `jq .allowedTools ~/.kiro/agents/screenpal-video-transcriber.json`

### Issue: "MCP server failed to initialize"

**Check**:
1. Protocol stream clean? `node server.js 2>/dev/null | head -c 1` should output `{`
2. Server path exists? `ls -la /tmp/moondream-mcp/build/index.js`
3. Dependencies installed? `npm list` in server directory

### Issue: "Connection closed"

**Check**:
1. Non-JSON output before protocol? `node server.js 2>&1 | head -c 100`
2. console.log() calls? Search source code
3. Server crashes? Check logs: `KIRO_LOG_LEVEL=trace`

## Advanced Configuration

### Multiple Agents with Different Tools

```
~/.kiro/agents/agent1.json
  ├─ includeMcpJson: true
  ├─ allowedTools: [tool1, tool2]
  
~/.kiro/agents/agent2.json
  ├─ includeMcpJson: true
  ├─ allowedTools: [tool3, tool4]
```

### Agent-Specific Model Selection

```json
{
  "name": "screenpal-video-transcriber",
  "model": "claude-sonnet-4"
}
```

### Custom MCP Server per Agent

```json
{
  "includeMcpJson": true,
  "mcpServers": {
    "custom-vision": {
      "command": "sh",
      "args": ["-c", "node /custom/path/server.js 1>&2"]
    }
  }
}
```

See `docs/MCP-CONFIGURATION.md` for more details.
