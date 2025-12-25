# Kiro CLI Directory Structure Reference

This document shows the recommended directory structure for Kiro CLI with multiple custom agents.

## Global Kiro Configuration

```
~/.kiro/
├── agents/                          # Custom agent profiles
│   ├── screenpal-video-transcriber.json
│   ├── kb-creator.json
│   ├── frontend-spacing.json
│   └── other-agent.json
├── settings/
│   ├── mcp.json                     # Global MCP server configuration
│   └── other-settings.json
├── steering/                        # Agent steering files (optional)
│   ├── AGENTS.md
│   ├── kb-standards.md
│   └── content-processing.md
├── hooks/                           # Global hooks (optional)
│   └── pre-agent-spawn.sh
└── knowledge_bases/                 # Agent-specific knowledge bases
    ├── kiro_cli_default/
    ├── screenpal-video-transcriber_<hash>/
    └── kb-creator_<hash>/
```

## Project-Specific Structure (Optional)

For development or project-specific customization:

```
project-root/
├── .kiro/
│   ├── agents/                      # Project-specific agents (auto-discovered)
│   │   └── project-agent.json
│   └── settings/
│       └── mcp.json                 # Project-specific MCP overrides
├── knowledge/                       # Project knowledge base
└── docs/                           # Project documentation
```

## Agent Discovery Priority

1. **Project agents**: `.kiro/agents/` in current directory (highest priority)
2. **Global agents**: `~/.kiro/agents/` (fallback)

## MCP Configuration Inheritance

- **Global MCP config**: `~/.kiro/settings/mcp.json` (shared by all agents)
- **Agent-specific overrides**: Defined in agent's `mcpServers` property
- **Project overrides**: `.kiro/settings/mcp.json` in project directory

## Best Practices

1. **Use global agents** for reusable, stable agents
2. **Use project agents** for development or project-specific customization
3. **Keep MCP config global** unless agent needs specific overrides
4. **Use steering files** for complex agent behavior customization
5. **Organize knowledge bases** by agent to avoid conflicts

## Official Documentation

- [Creating Custom Agents](https://kiro.dev/docs/cli/custom-agents/creating/)
- [Agent Steering](https://kiro.dev/docs/cli/steering/)
- [Hooks System](https://kiro.dev/docs/cli/hooks/)
- [MCP Integration](https://kiro.dev/docs/cli/mcp/)
