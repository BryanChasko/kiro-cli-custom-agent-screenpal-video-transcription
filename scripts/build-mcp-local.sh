#!/bin/bash
echo "Building MCP servers locally..."

cd servers

# Build filesystem MCP (this one exists)
echo "Building filesystem-mcp..."
docker build -f src/filesystem/Dockerfile -t filesystem-mcp .

echo "✅ Filesystem MCP image built successfully"
docker images | grep filesystem-mcp

# For text processing, we'll use npm instead since it's not in this repo
echo "Text processing will use npm-based server"
