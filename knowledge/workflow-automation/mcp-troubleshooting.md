# MCP Server Troubleshooting & Recovery

## Configuration Conflict Resolution

### Problem: Two Broken MCPs
When global and agent MCP configs conflict, servers fail to initialize with error code -32002.

### Root Causes
1. **Path Conflicts**: Global uses `/tmp/` paths, agent uses different paths
2. **Execution Method Mismatch**: Global uses `uvx`, agent uses `node` direct execution
3. **Server Name Mismatch**: `vision-analysis` vs `vision-server`
4. **Environment Variable Conflicts**: Different env vars in global vs agent

### Recovery Steps

#### Step 1: Align Server Names
Both configs must use identical server names:
```json
{
  "mcpServers": {
    "video-transcriber": { ... },
    "vision-server": { ... }
  }
}
```

#### Step 2: Use Consistent Execution Method
Replace uvx with direct Node.js execution:
```json
{
  "command": "node",
  "args": ["/tmp/video-transcriber-mcp/dist/index.js"]
}
```

#### Step 3: Normalize Environment Variables
Keep only essential vars, remove conflicting ones:
- Video transcriber: `WHISPER_MODEL`, `YOUTUBE_FORMAT`, `WHISPER_DEVICE`
- Vision server: `OLLAMA_BASE_URL` only

#### Step 4: Enable Global Config in Agent
```json
{
  "includeMcpJson": true
}
```

#### Step 5: Update Tool References
Match tool names to server names:
- `@video-transcriber/transcribe_video`
- `@vision-server/describe_image`

### Verification After Recovery

```bash
# 1. Syntax check
jq . ~/.kiro/settings/mcp.json
jq . .kiro/agents/screenpal-video-transcriber.json

# 2. Server startup test
cd /tmp/video-transcriber-mcp && node dist/index.js &
sleep 1 && kill %1

# 3. Ollama connectivity
curl -s http://localhost:11434/api/tags | jq '.models'

# 4. Agent launch
kiro-cli chat --agent screenpal-video-transcriber
```

## Configuration Checklist

- [ ] Global MCP config uses Node.js execution (not uvx)
- [ ] Agent config `includeMcpJson: true`
- [ ] Server names identical in both configs
- [ ] Server files exist at specified paths
- [ ] Environment variables don't conflict
- [ ] Tool references match server names
- [ ] Ollama running and responsive
- [ ] Moondream model available

## Prevention

1. **Single Source of Truth**: Define servers in global config, reference in agent
2. **Consistent Naming**: Use descriptive names that match across configs
3. **Version Control**: Track config changes to detect conflicts early
4. **Testing**: Verify server startup before launching agent
