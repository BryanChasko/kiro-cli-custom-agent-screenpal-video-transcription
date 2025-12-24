# Documentation Index

## Getting Started

- **[AGENT-SETUP-GUIDE.md](AGENT-SETUP-GUIDE.md)** - Agent linking and configuration
- **[QUICK-REFERENCE.md](QUICK-REFERENCE.md)** - Common commands and quick fixes
- **[KIRO-CLI-INTEGRATION.md](KIRO-CLI-INTEGRATION.md)** - How Kiro CLI uses MCP servers

## Understanding the System

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System design and component overview
- **[MCP-CONFIGURATION.md](MCP-CONFIGURATION.md)** - Detailed MCP setup and configuration

## Troubleshooting

- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues and solutions

## Key Concepts

### MCP (Model Context Protocol)

MCP is a protocol that allows Kiro CLI to communicate with specialized servers. Each server provides tools that extend Kiro's capabilities.

### Global vs Agent Configuration

- **Global** (`~/.kiro/settings/mcp.json`): Defines all available servers
- **Agent** (`~/.kiro/agents/screenpal-video-transcriber.json`): Customizes behavior for specific agent

### Tool Allowlisting

Agents can restrict which tools they're allowed to use via `allowedTools`. This provides security and prevents unintended operations.

## Quick Navigation

| Need | Document |
|------|----------|
| Link custom agent | AGENT-SETUP-GUIDE.md |
| Quick commands | QUICK-REFERENCE.md |
| How it all works | KIRO-CLI-INTEGRATION.md |
| System design | ARCHITECTURE.md |
| Configuration details | MCP-CONFIGURATION.md |
| Fix an issue | TROUBLESHOOTING.md |

## Setup

See the main [README.md](../README.md) for installation instructions.

## Support

1. Check QUICK-REFERENCE.md for common commands
2. Review TROUBLESHOOTING.md for your issue
3. Enable trace logging: `KIRO_LOG_LEVEL=trace`
4. Check logs: `tail -f $TMPDIR/kiro-log/kiro-chat.log`
