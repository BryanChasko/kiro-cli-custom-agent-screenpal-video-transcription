# Knowledge Management for ScreenPal Video Transcriber Agent

## Overview

The ScreenPal Video Transcriber Agent uses Kiro CLI's knowledge management system to maintain comprehensive understanding of its own project, configuration, and capabilities. This enables intelligent assistance with setup, troubleshooting, and usage questions.

## Knowledge Base Structure

The agent's knowledge is organized into four logical contexts:

### 1. screenpal-docs (ID: 00789d46-e583-46bf-a3ae-cfe68d308294)
- **Path**: `/docs`
- **Content**: Complete documentation (setup guides, architecture, troubleshooting)
- **Items**: 10 documents
- **Purpose**: Comprehensive system documentation and guides

### 2. project-root (ID: 76bcd183-d3fb-4893-a79c-9efc84cd7a6c)
- **Path**: Project root directory
- **Content**: README, USAGE, CHANGELOG, setup scripts
- **Items**: 117 files (filtered for relevance)
- **Purpose**: Project metadata and entry-point documentation

### 3. agent-config (ID: fcb5fe51-99dd-41ea-a403-bc01df9f3a73)
- **Path**: `/.kiro`
- **Content**: Agent configuration and MCP settings
- **Items**: 2 configuration files
- **Purpose**: Agent behavior and MCP server configuration

### 4. curated-knowledge (ID: b37c6399-d441-4747-8b8f-e7d849c9d08d)
- **Path**: `/knowledge`
- **Content**: Workflow automation, best practices, API integration
- **Items**: 8 specialized knowledge files
- **Purpose**: Curated expertise and troubleshooting knowledge

## Knowledge Management Commands

### View Available Knowledge Bases
```bash
/knowledge show
```

### Search Across All Knowledge
```bash
/knowledge search "How do I set up MCP servers?"
```

### Search Specific Context
```bash
/knowledge search "troubleshooting" --context-id 00789d46-e583-46bf-a3ae-cfe68d308294
```

### Update Knowledge Base
```bash
/knowledge update --path /path/to/updated/content --context-id <context-id>
```

## Maintenance Process

### When to Update Knowledge

1. **Documentation Changes**: Update `screenpal-docs` when docs/ files change
2. **Configuration Changes**: Update `agent-config` when .kiro/ files change
3. **Project Updates**: Update `project-root` when README, USAGE, or setup scripts change
4. **Knowledge Expansion**: Update `curated-knowledge` when adding new expertise

### Update Commands

```bash
# Update documentation
/knowledge update --path /Users/bryanchasko/Code/kiro-cli-custom-agent-screenpal-video-transcription/docs --context-id 00789d46-e583-46bf-a3ae-cfe68d308294

# Update configuration
/knowledge update --path /Users/bryanchasko/Code/kiro-cli-custom-agent-screenpal-video-transcription/.kiro --context-id fcb5fe51-99dd-41ea-a403-bc01df9f3a73

# Update project root
/knowledge update --path /Users/bryanchasko/Code/kiro-cli-custom-agent-screenpal-video-transcription --context-id 76bcd183-d3fb-4893-a79c-9efc84cd7a6c

# Update curated knowledge
/knowledge update --path /Users/bryanchasko/Code/kiro-cli-custom-agent-screenpal-video-transcription/knowledge --context-id b37c6399-d441-4747-8b8f-e7d849c9d08d
```

## Best Practices

### Knowledge Organization
- Keep contexts logically separated
- Use descriptive names for knowledge bases
- Maintain consistent file organization within each context

### Search Optimization
- Use natural language queries for semantic search
- Be specific when searching for technical details
- Use context-specific searches for focused results

### Maintenance Schedule
- Update knowledge after significant documentation changes
- Refresh configuration knowledge after MCP server updates
- Review and update curated knowledge monthly

## Agent Capabilities

With this knowledge base, the agent can intelligently answer questions about:

### Setup and Installation
- MCP server configuration
- Dependency installation
- Environment setup
- Troubleshooting installation issues

### Architecture and Design
- System component relationships
- Data flow and processing pipeline
- Configuration hierarchy
- Tool integration patterns

### Troubleshooting
- Common error resolution
- Configuration conflicts
- Performance optimization
- Debugging procedures

### Usage and Best Practices
- Video processing workflows
- Configuration optimization
- Security considerations
- Performance tuning

## Example Queries

The agent can now respond intelligently to questions like:

- "How do I set up the MCP servers?"
- "What are the troubleshooting steps for video transcription?"
- "How does the agent configuration work?"
- "What's the difference between global and agent MCP configuration?"
- "How do I optimize video processing performance?"
- "What security measures are in place?"

## Knowledge Base Statistics

- **Total Contexts**: 4
- **Total Items**: 137 (10 + 117 + 2 + 8)
- **Index Type**: Best (semantic search)
- **Search Capability**: Natural language queries
- **Update Method**: Path-based refresh

## Integration with Agent

The knowledge base is seamlessly integrated with the agent through:

1. **Automatic Loading**: Knowledge is available immediately when agent starts
2. **Contextual Responses**: Agent uses knowledge to provide accurate, detailed answers
3. **Cross-Reference**: Agent can reference multiple knowledge contexts in responses
4. **Real-time Search**: Agent searches knowledge base during conversations

This comprehensive knowledge management system ensures the ScreenPal Video Transcriber Agent can provide expert-level assistance with all aspects of its setup, configuration, and usage.
