# Changelog

## [Unreleased]

### Fixed
- **Vision-server MCP initialization failure** (Dec 24, 2025)
  - Removed knowledge MCP server (was non-functional)
  - Fixed moondream-mcp to use Ollama API directly instead of spawning local moondream server
  - Removed PythonSetup initialization that was causing "connection closed: initialize response" errors
  - Removed diagnostic console.error() messages that corrupted MCP protocol stream
  - Vision-server now connects to Ollama's `/api/generate` endpoint with moondream model
  - Simplified MCP configuration: `node /tmp/moondream-mcp/build/index.js 2>/dev/null`

### Changed
- Updated moondream-mcp source code (`/tmp/moondream-mcp/src/index.ts`):
  - `analyze_image` tool now uses Ollama API instead of local moondream server
  - Removed PythonSetup.setup() call from run() method
  - Removed startup diagnostic messages

### Updated Documentation
- TROUBLESHOOTING.md: Added vision-server specific fix details
- MCP-CONFIGURATION.md: Documented Ollama API integration
- platform-setup-guide.md: Simplified moondream-mcp configuration

## [Previous versions]
See git history for earlier changes.
