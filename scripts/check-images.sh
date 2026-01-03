#!/bin/bash
echo "Checking Docker image availability..."

# Check if images exist locally
if docker images | grep -q "modelcontextprotocol/filesystem-mcp"; then
    echo "✅ filesystem-mcp image found locally"
else
    echo "❌ filesystem-mcp image not found"
fi

if docker images | grep -q "modelcontextprotocol/text-processing-mcp"; then
    echo "✅ text-processing-mcp image found locally"  
else
    echo "❌ text-processing-mcp image not found"
fi

# Try alternative registry or local build
echo "Attempting alternative pull..."
docker pull modelcontextprotocol/filesystem-mcp:latest 2>/dev/null || echo "Alternative pull failed"
docker pull modelcontextprotocol/text-processing-mcp:latest 2>/dev/null || echo "Alternative pull failed"

echo "Final image check:"
docker images | grep modelcontextprotocol
