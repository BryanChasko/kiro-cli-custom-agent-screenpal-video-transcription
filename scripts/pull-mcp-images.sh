#!/bin/bash
echo "Pulling MCP Docker images..."
docker pull ghcr.io/modelcontextprotocol/filesystem-mcp:latest
docker pull ghcr.io/modelcontextprotocol/text-processing-mcp:latest
echo "✅ MCP images ready"
