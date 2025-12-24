# MCP Configuration Guide

## Understanding Kiro's MCP System

Kiro CLI uses the Model Context Protocol (MCP) to extend capabilities through specialized servers. This guide explains how the ScreenPal agent leverages this system.

## Configuration Files

### 1. Global MCP Configuration

**Location**: `~/.kiro/settings/mcp.json`

**Purpose**: Defines all available MCP servers for all agents

**Scope**: System-wide (affects all agents and the default agent)

**Example**:
```json
{
  "mcpServers": {
    "video-transcriber": {
      "command": "sh",
      "args": ["-c", "node /tmp/video-transcriber-mcp/dist/index.js 2>/dev/null"],
      "env": {
        "WHISPER_MODEL": "base",
        "YOUTUBE_FORMAT": "bestaudio",
        "WHISPER_DEVICE": "cpu"
      },
      "disabled": false
    },
    "vision-server": {
      "command": "sh",
      "args": ["-c", "node /tmp/moondream-mcp/build/index.js 1>&2"],
      "env": {
        "OLLAMA_BASE_URL": "http://localhost:11434"
      },
      "disabled": false
    },
    "knowledge": {
      "command": "uvx",
      "args": ["mcp-server-knowledge"],
      "env": {},
      "disabled": false,
      "autoApprove": ["search", "add", "show"]
    }
  }
}
```

### 2. Agent Profile Configuration

**Location**: `~/.kiro/agents/screenpal-video-transcriber.json`

**Purpose**: Defines a specialized agent with custom behavior

**Scope**: Agent-specific (only affects this agent)

**Example**:
```json
{
  "name": "screenpal-video-transcriber",
  "description": "Specialized agent for processing ScreenPal videos...",
  "includeMcpJson": true,
  "tools": ["fs_read", "fs_write", "knowledge", "@video-transcriber/transcribe_video"],
  "allowedTools": ["fs_read", "knowledge", "@video-transcriber/get_video_info"],
  "model": "claude-sonnet-4"
}
```

**Note**: The agent does NOT redefine `vision-server` here. With `includeMcpJson: true`, it automatically inherits all servers from the global config, including `vision-server`.

## Configuration Hierarchy

```
┌─────────────────────────────────────────┐
│ ~/.kiro/settings/mcp.json               │
│ (Global - all agents inherit)           │
├─────────────────────────────────────────┤
│ • video-transcriber                     │
│ • vision-server                         │
│ • knowledge                             │
│ • github, docker-gateway, fetch, etc    │
└────────────────┬────────────────────────┘
                 │
                 ├─────────────────────────────────────┐
                 │                                     │
                 │ Default Agent                       │ screenpal-video-transcriber Agent
                 │ (kiro-cli chat)                     │ (kiro-cli chat --agent screenpal-video-transcriber)
                 │                                     │
                 ▼                                     ▼
        ┌──────────────────┐          ┌──────────────────────────────┐
        │ Uses all global  │          │ includeMcpJson: true         │
        │ MCP servers      │          │ Inherits all global servers  │
        │                  │          │ + agent-specific config      │
        │ • video-transcr. │          │                              │
        │ • vision-server  │          │ • video-transcriber (global) │
        │ • knowledge      │          │ • vision-server (global)     │
        │ • github, etc    │          │ • knowledge (global)         │
        └──────────────────┘          │ • github, etc (global)       │
                                      │                              │
                                      │ Restrictions:                │
                                      │ • allowedTools limits usage  │
                                      │ • tools defines available    │
                                      └──────────────────────────────┘
```

## Key Configuration Concepts

### 1. `includeMcpJson`

**What it does**: Tells the agent to inherit all servers from global config

**Values**:
- `true`: Inherit all global servers (no duplicates)
- `false`: Only use servers defined in agent profile

**Example**:
```json
{
  "includeMcpJson": true
}
```

Result: Agent gets all global servers without duplication

**Important**: Do NOT redefine servers in `mcpServers` if they already exist in global config. This causes duplicate warnings. Only override if you need a different configuration for that specific server.

### 2. `mcpServers` (Agent-Level)

**What it does**: Override or add servers specific to this agent

**Use Cases**:
- Override global configuration for specific agent
- Add agent-specific servers
- Disable servers for this agent

**Example**:
```json
{
  "mcpServers": {
    "vision-server": {
      "command": "sh",
      "args": ["-c", "node /tmp/moondream-mcp/build/index.js 1>&2"],
      "env": { "OLLAMA_BASE_URL": "http://localhost:11434" },
      "disabled": false
    }
  }
}
```

### 3. `allowedTools`

**What it does**: Restricts which tools the agent can use

**Purpose**: Security - prevent agents from accessing tools they shouldn't

**Example**:
```json
{
  "allowedTools": [
    "fs_read",
    "knowledge",
    "@video-transcriber/get_video_info"
  ]
}
```

This agent can only:
- Read files
- Query knowledge base
- Get video metadata

Cannot:
- Write files
- Transcribe videos
- Access other tools

### 4. `tools`

**What it does**: Lists all tools available to the agent (before allowlist)

**Difference from `allowedTools`**:
- `tools`: What's available
- `allowedTools`: What's permitted

**Example**:
```json
{
  "tools": [
    "fs_read",
    "fs_write",
    "knowledge",
    "@video-transcriber/transcribe_video",
    "@video-transcriber/extract_audio",
    "@video-transcriber/get_video_info"
  ],
  "allowedTools": [
    "fs_read",
    "knowledge",
    "@video-transcriber/get_video_info"
  ]
}
```

## MCP Server Command Formats

### Node.js MCP Server

```json
{
  "command": "sh",
  "args": ["-c", "node /path/to/server.js 2>/dev/null"],
  "env": { /* environment variables */ }
}
```

**Why `sh -c`?**
- Allows complex command syntax
- Enables I/O redirection (`2>/dev/null`, `1>&2`)
- Portable across platforms

### uvx MCP Server

```json
{
  "command": "uvx",
  "args": ["mcp-server-name"],
  "env": { /* environment variables */ }
}
```

**Why uvx?**
- Runs Python MCP servers
- Automatic dependency management
- No installation required

### Docker MCP Server

```json
{
  "command": "docker",
  "args": ["run", "-i", "--rm", "image:tag"],
  "env": { /* environment variables */ }
}
```

## Output Redirection Strategy

### Problem: Protocol Stream Corruption

MCP servers communicate via JSON-RPC. Any non-JSON output breaks the protocol:

```
❌ BROKEN:
PythonSetup initialized with:
- Working directory: /Users/...
{"jsonrpc":"2.0",...}  ← Too late!

✅ FIXED:
{"jsonrpc":"2.0",...}  ← Starts immediately
```

### Solution: Redirect Logging

**Option 1: Suppress stderr**
```json
"args": ["-c", "node server.js 2>/dev/null"]
```
Use when: Server logs to stderr, protocol on stdout

**Option 2: Redirect stdout to stderr**
```json
"args": ["-c", "node server.js 1>&2"]
```
Use when: Server logs to stdout, protocol on stdout (need to separate)

**Option 3: Use console.error()**
```javascript
// In server code
console.error("Debug message");  // Goes to stderr
console.log(jsonData);           // Goes to stdout (protocol)
```

## Environment Variables

### video-transcriber

```json
"env": {
  "WHISPER_MODEL": "base",        // tiny|base|small|medium|large
  "YOUTUBE_FORMAT": "bestaudio",  // bestaudio|best
  "WHISPER_DEVICE": "cpu"         // cpu|cuda|mps
}
```

### vision-server

```json
"env": {
  "OLLAMA_BASE_URL": "http://localhost:11434"
}
```

**Note**: As of Dec 24, 2025, vision-server uses Ollama API directly instead of spawning a local moondream server. The server connects to Ollama's `/api/generate` endpoint with the moondream model.

### knowledge

```json
"env": {}  // No special configuration needed
```

## Common Configuration Patterns

### Pattern 1: Inherit All Global Servers (No Duplicates)

```json
{
  "name": "my-agent",
  "includeMcpJson": true,
  "allowedTools": ["fs_read", "knowledge"]
}
```

Result: Agent gets all global servers but can only use fs_read and knowledge

**Best Practice**: Use this pattern. Don't redefine servers in `mcpServers` if they're already in global config.

### Pattern 2: Override Specific Server (When Needed)

```json
{
  "name": "my-agent",
  "includeMcpJson": true,
  "mcpServers": {
    "vision-server": {
      "command": "sh",
      "args": ["-c", "node /custom/path/server.js 1>&2"],
      "env": { "CUSTOM_VAR": "value" }
    }
  }
}
```

Result: Agent inherits all global servers, but uses custom vision-server

**When to use**: Only when this agent needs a different configuration than the global one.

### Pattern 3: Agent-Only Servers

```json
{
  "name": "my-agent",
  "includeMcpJson": false,
  "mcpServers": {
    "custom-server": { /* ... */ }
  }
}
```

Result: Agent only has custom-server, no global servers

**When to use**: Rarely. Only for highly specialized agents that shouldn't access global tools.

## Default Agent vs Custom Agent

### Default Agent (Kiro CLI)

**Launch**: `kiro-cli chat`

**Configuration**: Uses only `~/.kiro/settings/mcp.json`

**Available Servers**:
- All servers defined in global config
- video-transcriber
- vision-server
- knowledge
- github, docker-gateway, fetch, aws-docs, etc.

**Use Case**: General-purpose AI assistant with access to all tools

### Custom Agent (screenpal-video-transcriber)

**Launch**: `kiro-cli chat --agent screenpal-video-transcriber`

**Configuration**: 
- Inherits from `~/.kiro/settings/mcp.json` (via `includeMcpJson: true`)
- Plus agent-specific settings in `~/.kiro/agents/screenpal-video-transcriber.json`

**Available Servers**:
- All global servers (inherited)
- video-transcriber
- vision-server
- knowledge
- github, docker-gateway, fetch, aws-docs, etc.

**Restrictions**:
- `allowedTools` limits which tools can be used
- Specialized prompt for video processing tasks

**Use Case**: Specialized agent for ScreenPal video transcription with restricted tool access

### Shared MCP Servers

Both agents share the same MCP servers from the global config:

```
~/.kiro/settings/mcp.json
    ↓
    ├─→ Default Agent (kiro-cli chat)
    │
    └─→ Custom Agent (kiro-cli chat --agent screenpal-video-transcriber)
```

This means:
- Changes to global config affect both agents
- No duplication of server definitions
- Both agents can access vision-server, video-transcriber, etc.
- Custom agent has additional restrictions via `allowedTools`

## Debugging Configuration

### Check Global Config

```bash
cat ~/.kiro/settings/mcp.json | jq .
```

### Check Agent Config

```bash
cat ~/.kiro/agents/screenpal-video-transcriber.json | jq .
```

### Test MCP Server Directly

```bash
# Test video-transcriber
node /tmp/video-transcriber-mcp/dist/index.js --help

# Test vision-server protocol stream
node /tmp/moondream-mcp/build/index.js 2>/dev/null | head -c 50
# Should output: {"jsonrpc":"2.0",...
```

### Enable Trace Logging

```bash
KIRO_LOG_LEVEL=trace kiro-cli chat --agent screenpal-video-transcriber
```

Check logs in `$TMPDIR/kiro-log/kiro-chat.log`

## Best Practices

1. **Always use `includeMcpJson: true`** for agents that need global tools
2. **Minimize `allowedTools`** to only what the agent needs
3. **Test protocol stream** before deploying: `node server.js 2>/dev/null | head -c 1` should output `{`
4. **Use environment variables** for configuration, not hardcoded paths
5. **Document custom servers** in agent description
6. **Keep global config minimal** - only add servers all agents need
7. **Use agent profiles** for specialized configurations

## Troubleshooting

### Agent Can't Find Tools

**Problem**: `Tool not found` error

**Solution**:
1. Check `includeMcpJson: true` in agent config
2. Verify tool name in `allowedTools`
3. Check global config has the server

### MCP Server Won't Connect

**Problem**: `connection closed: initialize response`

**Solution**:
1. Test protocol stream: `node server.js 2>/dev/null | head -c 1`
2. Should output `{` (JSON start)
3. If not, check for console.log() calls before protocol
4. Use `console.error()` for logging instead

### Tool Execution Fails

**Problem**: Tool runs but returns error

**Solution**:
1. Check environment variables are set correctly
2. Verify paths exist (e.g., `/tmp/moondream-mcp/build/index.js`)
3. Check server logs: `KIRO_LOG_LEVEL=trace`
4. Test server directly with sample input

See `docs/TROUBLESHOOTING.md` for more issues.
