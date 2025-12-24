# Agent Setup Guide: Default vs Custom

Quick reference for understanding how the default Kiro CLI agent and the screenpal-video-transcriber custom agent share MCP servers.

## Quick Start

### 1. Navigate to Project Directory
```bash
cd /Users/bryanchasko/Code/kiro-cli-custom-agent-screenpal-video-transcription
```

### 2. Launch Default Agent
```bash
kiro-cli chat
```
- Uses all global MCP servers
- Full tool access
- General-purpose AI assistant

### 3. Launch Custom Agent
```bash
kiro-cli chat --agent screenpal-video-transcriber
```
- Uses all global MCP servers (inherited via `includeMcpJson: true`)
- Full video transcription and visual analysis tool access
- Specialized for ScreenPal video processing with audio and visual insights

## Configuration Files

### Global MCP Configuration
**File**: `~/.kiro/settings/mcp.json`

**Purpose**: Defines all MCP servers available to all agents

**Servers**:
- `video-transcriber` - Audio extraction and Whisper transcription
- `vision-server` - Visual analysis with Moondream
- `knowledge` - Knowledge base management
- `github` - GitHub integration
- `docker-gateway` - Docker operations
- `fetch` - Web fetching
- `aws-docs` - AWS documentation
- `chrome-devtools` - Browser automation
- `playwright` - Playwright browser automation

**Scope**: System-wide (affects all agents)

### Agent Profile
**File**: `~/.kiro/agents/screenpal-video-transcriber.json`

**Purpose**: Customizes behavior for this specific agent

**Key Settings**:
- `includeMcpJson: true` - Inherit all global servers
- `allowedTools` - Restrict which tools can be used
- `tools` - List of available tools
- `model` - AI model to use
- `prompt` - Custom system prompt

**Scope**: Agent-specific (only affects this agent)

## MCP Server Inheritance

```
Global Config (~/.kiro/settings/mcp.json)
    ↓
    ├─ Default Agent
    │  └─ All servers available
    │  └─ All tools accessible
    │
    └─ Custom Agent (screenpal-video-transcriber)
       └─ All servers available (inherited)
       └─ Only allowedTools accessible
```

## Key Concept: No Duplication

**Important**: The custom agent does NOT redefine servers in its config.

❌ **Wrong** (causes duplicate warning):
```json
{
  "name": "screenpal-video-transcriber",
  "includeMcpJson": true,
  "mcpServers": {
    "vision-server": { /* redefined */ }
  }
}
```

✅ **Correct** (clean inheritance):
```json
{
  "name": "screenpal-video-transcriber",
  "includeMcpJson": true,
  "allowedTools": ["fs_read", "knowledge", "@video-transcriber/get_video_info"]
}
```

## Tool Access Comparison

### Default Agent
```
Available Tools:
- fs_read, fs_write
- knowledge (search, add, show)
- @video-transcriber/* (all)
- @vision-server/* (all)
- github/* (all)
- docker/* (all)
- fetch
- aws-docs
- browser tools
```

### Custom Agent (screenpal-video-transcriber)
```
Available Tools (via allowedTools):
- fs_read (read only)
- knowledge (search, add, show)
- @video-transcriber/get_video_info (metadata only)

Restricted Tools:
- fs_write (not allowed)
- @video-transcriber/transcribe_video (not allowed)
- All other tools (not allowed)
```

## When to Use Each Agent

### Use Default Agent (`kiro-cli chat`)
- General development tasks
- Code analysis and writing
- AWS resource management
- GitHub operations
- Web research
- File operations
- Any task requiring full tool access

### Use Custom Agent (`kiro-cli chat --agent screenpal-video-transcriber`)
- Transcribing ScreenPal videos
- Analyzing video content
- Generating transcripts
- Tasks requiring specialized video processing
- When you want restricted tool access for safety

## Modifying Configuration

### Add a New Global Server

Edit `~/.kiro/settings/mcp.json`:
```json
{
  "mcpServers": {
    "new-server": {
      "command": "uvx",
      "args": ["mcp-server-name"],
      "env": {},
      "disabled": false
    }
  }
}
```

**Effect**: Both agents can now access this server

### Restrict Custom Agent Tools

Edit `~/.kiro/agents/screenpal-video-transcriber.json`:
```json
{
  "allowedTools": [
    "fs_read",
    "knowledge",
    "@video-transcriber/get_video_info"
  ]
}
```

**Effect**: Only this agent is restricted; default agent unaffected

### Override Server for Custom Agent Only

Edit `~/.kiro/agents/screenpal-video-transcriber.json`:
```json
{
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

**Effect**: This agent uses custom vision-server; default agent uses global one

## Troubleshooting

### "MCP server 'vision-server' is already configured" Warning

**Cause**: Server defined in both global config and agent config

**Solution**: Remove the server definition from agent config if using `includeMcpJson: true`

```bash
# Check agent config
cat ~/.kiro/agents/screenpal-video-transcriber.json | jq .mcpServers

# If vision-server is there, remove it
```

### Agent Can't Access a Tool

**Cause**: Tool not in `allowedTools` list

**Solution**: Add tool to `allowedTools` in agent config

```json
{
  "allowedTools": [
    "fs_read",
    "knowledge",
    "@video-transcriber/get_video_info",
    "new-tool"  // Add here
  ]
}
```

### Tool Works in Default Agent but Not Custom Agent

**Cause**: Tool restricted by `allowedTools` in custom agent

**Solution**: Either:
1. Add tool to `allowedTools` if needed
2. Use default agent if full access required

## Agent Discovery

### Workspace-Based Agent Discovery

Kiro CLI automatically discovers agents in the current workspace without requiring global linking.

**How it works**:
1. Kiro CLI scans the current directory for `.kiro/agents/` folder
2. Loads and validates each agent configuration
3. Makes agents available via `--agent` flag when in the project directory

**Usage**:
```bash
# Navigate to project directory
cd /path/to/kiro-cli-custom-agent-screenpal-video-transcription

# Agent is automatically available
kiro-cli chat --agent screenpal-video-transcriber
```

**Benefits**:
- No global linking required
- Agent config stays in project (version controlled)
- No conflicts between different agent versions
- Automatic discovery when in project directory
4. Symbolic links are followed to actual config files

## Best Practices

1. **Keep global config minimal** - Only add servers all agents need
2. **Use `includeMcpJson: true`** - Inherit global servers, don't duplicate
3. **Minimize `allowedTools`** - Restrict to only what agent needs
4. **Document custom agents** - Explain why restrictions exist
5. **Test both agents** - Ensure changes don't break either
6. **Use agent profiles** - Don't modify global config for agent-specific needs
7. **Work from project directory** - Agents are automatically discovered in workspace

## See Also

- `docs/MCP-CONFIGURATION.md` - Detailed MCP configuration guide
- `docs/ARCHITECTURE.md` - System architecture overview
- `docs/TROUBLESHOOTING.md` - Common issues and solutions
