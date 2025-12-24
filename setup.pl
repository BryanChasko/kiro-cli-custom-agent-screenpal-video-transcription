#!/usr/bin/env perl

# ScreenPal Video Transcriber Agent - Setup Script

use strict;
use warnings;
use File::Path qw(make_path);
use File::Copy;

print "🎬 Setting up ScreenPal Video Transcriber Agent...\n";

# Check prerequisites
print "📋 Checking prerequisites...\n";

# Check if Kiro CLI is installed
unless (system("kiro-cli --version > /dev/null 2>&1") == 0) {
    die "❌ Kiro CLI not found. Please install Kiro CLI first.\n";
}

# Check if Docker is running
unless (system("docker info > /dev/null 2>&1") == 0) {
    die "❌ Docker is not running. Please start Docker.\n";
}

# Check if uv is installed
unless (system("uvx --version > /dev/null 2>&1") == 0) {
    print "❌ uv not found. Installing uv...\n";
    system("curl -LsSf https://astral.sh/uv/install.sh | sh");
    $ENV{PATH} = "$ENV{HOME}/.local/bin:$ENV{PATH}";
}

print "✅ Prerequisites check complete\n";

# Install MCP servers
print "📦 Installing MCP servers...\n";
system("uvx install video-transcriber-mcp") == 0 or die "Failed to install video-transcriber-mcp\n";
system("uvx install mcp-vision-analysis") == 0 or die "Failed to install mcp-vision-analysis\n";
print "✅ MCP servers installed\n";

# Setup Ollama
print "🤖 Setting up Ollama...\n";

# Check if Ollama is installed
unless (system("ollama --version > /dev/null 2>&1") == 0) {
    print "Installing Ollama...\n";
    if ($^O eq 'darwin') {
        # macOS
        if (system("brew --version > /dev/null 2>&1") == 0) {
            system("brew install ollama");
        } else {
            die "Please install Homebrew first, then run: brew install ollama\n";
        }
    } else {
        # Linux
        system("curl -fsSL https://ollama.ai/install.sh | sh");
    }
}

# Start Ollama service
print "Starting Ollama service...\n";
system("ollama serve &");
sleep(5);

# Download VLM models
print "📥 Downloading VLM models...\n";
system("ollama pull moondream2");
system("ollama pull llava");
print "✅ Ollama setup complete\n";

# Create directories
print "📁 Creating directories...\n";
make_path('transcripts', 'output', 'temp', 'logs');
print "✅ Directories created\n";

# Copy agent configuration
print "⚙️ Installing agent configuration...\n";

my $global_install = (@ARGV && $ARGV[0] eq '--global');

if ($global_install) {
    make_path("$ENV{HOME}/.kiro/agents");
    copy('.kiro/agents/screenpal-video-transcriber.json', "$ENV{HOME}/.kiro/agents/") 
        or die "Failed to copy agent config: $!\n";
    print "✅ Agent installed globally\n";
} else {
    make_path('.kiro/agents');
    copy('.kiro/agents/screenpal-video-transcriber.json', '.kiro/agents/') 
        or die "Failed to copy agent config: $!\n";
    print "✅ Agent installed locally\n";
}

# Copy MCP configuration
make_path('.kiro/settings');
copy('.kiro/settings/mcp.json', '.kiro/settings/') or die "Failed to copy MCP config: $!\n";
print "✅ Configuration files installed\n";

# Verify installation
print "🔍 Verifying installation...\n";

# Test MCP servers
if (system("uvx video-transcriber-mcp --help > /dev/null 2>&1") == 0) {
    print "✅ video-transcriber-mcp working\n";
} else {
    print "❌ video-transcriber-mcp not working\n";
}

if (system("uvx mcp-vision-analysis --help > /dev/null 2>&1") == 0) {
    print "✅ mcp-vision-analysis working\n";
} else {
    print "❌ mcp-vision-analysis not working\n";
}

# Test Ollama
if (system("curl -s http://localhost:11434/api/tags > /dev/null 2>&1") == 0) {
    print "✅ Ollama service running\n";
} else {
    print "❌ Ollama service not responding\n";
}

# Test models
my $models = `ollama list 2>/dev/null`;
if ($models =~ /moondream2/) {
    print "✅ Moondream2 model available\n";
} else {
    print "❌ Moondream2 model not found\n";
}

print "\n🎉 Setup complete!\n\n";
print "To use the agent:\n";
print "  kiro-cli chat --agent screenpal-video-transcriber\n\n";
print "Example usage:\n";
print '  > Please transcribe this ScreenPal video: https://go.screenpal.com/[video-id]' . "\n\n";
print "For troubleshooting, see USAGE.md\n";
