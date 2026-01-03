#!/bin/bash
echo "Authenticating with GitHub Container Registry..."

# Login to ghcr.io using personal access token from environment
echo "$GITHUB_TOKEN" | docker login ghcr.io -u bryanchasko --password-stdin

if [ $? -eq 0 ]; then
    echo "✅ Authentication successful"
    
    echo "Pulling MCP Docker images..."
    docker pull ghcr.io/modelcontextprotocol/filesystem-mcp:latest
    docker pull ghcr.io/modelcontextprotocol/text-processing-mcp:latest
    
    echo "✅ Docker images pulled successfully"
    echo "Ready for Kiro CLI restart"
else
    echo "❌ Authentication failed"
    exit 1
fi
