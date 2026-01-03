# MCP Filesystem Server Documentation

## Overview
The MCP Filesystem Server provides secure file system access for MCP clients, enabling reading, writing, and managing files and directories through standardized MCP protocols.

## Installation
```bash
npm install @modelcontextprotocol/server-filesystem
```

## Configuration
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/allowed/directory"],
      "env": {}
    }
  }
}
```

## Key Features
- **Secure Access**: Restricts file operations to specified directories
- **Standard Operations**: Read, write, list, create, delete files and directories
- **Path Validation**: Prevents directory traversal attacks
- **Cross-Platform**: Works on Windows, macOS, and Linux

## Available Tools
- `read_file`: Read file contents
- `write_file`: Write content to files
- `create_directory`: Create new directories
- `list_directory`: List directory contents
- `delete_file`: Remove files
- `move_file`: Move/rename files
- `get_file_info`: Get file metadata

## Security Model
- **Sandboxed Access**: Operations restricted to configured root directory
- **Path Sanitization**: Automatic path validation and normalization
- **Permission Checks**: Validates read/write permissions before operations

## Integration Examples

### VS Code Integration
```json
{
  "mcp.servers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "${workspaceFolder}"]
    }
  }
}
```

### Claude Desktop Integration
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/username/projects"],
      "env": {}
    }
  }
}
```

## Best Practices
1. **Restrict Root Directory**: Always specify the most restrictive path needed
2. **Use Absolute Paths**: Avoid relative paths in configuration
3. **Monitor Permissions**: Ensure proper file system permissions
4. **Validate Inputs**: Client-side validation before MCP calls
5. **Error Handling**: Implement proper error handling for file operations

## Common Use Cases
- **Code Generation**: Writing generated code files
- **Configuration Management**: Reading/writing config files
- **Data Processing**: Processing local data files
- **Project Scaffolding**: Creating project structures
- **File Analysis**: Reading and analyzing existing files

## Troubleshooting
- **Permission Denied**: Check file system permissions and MCP server root directory
- **Path Not Found**: Verify paths are within configured root directory
- **Server Not Found**: Ensure @modelcontextprotocol/server-filesystem is installed

## Sources
- MCP Curator: https://www.mcpcurator.com/mcp/filesystem-mcp
- GitHub: https://github.com/modelcontextprotocol/servers/blob/main/src/filesystem/README.md
- VS Code Docs: https://code.visualstudio.com/docs/copilot/customization/mcp-servers
- NPM Package: https://www.npmjs.com/package/@modelcontextprotocol/server-filesystem
