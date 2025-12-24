#!/usr/bin/env perl

# ScreenPal Video Transcriber Agent - Comprehensive Setup Script

use strict;
use warnings;
use File::Path qw(make_path);
use File::Copy;
use JSON;

print "🎬 Setting up ScreenPal Video Transcriber Agent - Full Toolchain...\n";

# Phase 1: Environment Preparation
print "📋 Phase 1: Environment Preparation...\n";

# Install uv package manager
unless (system("uvx --version > /dev/null 2>&1") == 0) {
    print "📦 Installing uv package manager...\n";
    system("curl -LsSf https://astral.sh/uv/install.sh | sh") == 0 or die "Failed to install uv\n";
    $ENV{PATH} = "$ENV{HOME}/.local/bin:$ENV{PATH}";
}

# Check Docker
unless (system("docker --version > /dev/null 2>&1") == 0) {
    die "❌ Docker not found. Please install Docker first.\n";
}

print "✅ Environment preparation complete\n";

# Phase 2: Docker Ollama Setup
print "🐳 Phase 2: Docker Ollama Setup...\n";

# Pull and run Ollama container with persistent volumes
print "Pulling Ollama Docker image...\n";
system("docker pull ollama/ollama") == 0 or die "Failed to pull Ollama image\n";

print "Starting Ollama container...\n";
system("docker run -d --name ollama-screenpal -p 11434:11434 -v ollama-models:/root/.ollama ollama/ollama") == 0 
    or print "Container may already exist, continuing...\n";

# Wait for Ollama to be ready
print "Waiting for Ollama service to start...\n";
my $retries = 30;
while ($retries > 0) {
    if (system("curl -s http://localhost:11434/api/tags > /dev/null 2>&1") == 0) {
        last;
    }
    sleep(2);
    $retries--;
}
die "❌ Ollama service failed to start\n" if $retries == 0;

# Pull Moondream2 model
print "📥 Pulling Moondream2 model...\n";
system("docker exec ollama-screenpal ollama pull moondream2") == 0 or die "Failed to pull Moondream2\n";

print "✅ Docker Ollama setup complete\n";

# Phase 3: MCP Server Installation
print "📦 Phase 3: MCP Server Installation...\n";

system("uvx install video-transcriber-mcp") == 0 or die "Failed to install video-transcriber-mcp\n";
system("uvx install mcp-vision-analysis") == 0 or die "Failed to install mcp-vision-analysis\n";

print "✅ MCP servers installed\n";

# Phase 4: Global MCP Configuration
print "⚙️ Phase 4: Global MCP Configuration...\n";

my $global_mcp_dir = "$ENV{HOME}/.kiro/settings";
make_path($global_mcp_dir);

my $mcp_config = {
    mcpServers => {
        "video-transcriber" => {
            command => "uvx",
            args => ["video-transcriber-mcp"],
            env => {
                WHISPER_MODEL => "base",
                YOUTUBE_FORMAT => "bestaudio",
                WHISPER_DEVICE => "cpu",
                TEMP_DIR => "./temp"
            },
            timeout => 300000
        },
        "vision-analysis" => {
            command => "uvx",
            args => ["mcp-vision-analysis"],
            env => {
                OLLAMA_API_ENDPOINT => "http://localhost:11434",
                VLM_MODEL => "moondream2",
                SCENE_THRESHOLD => "0.4",
                MAX_FRAMES => "50"
            },
            timeout => 180000
        }
    }
};

open my $fh, '>', "$global_mcp_dir/mcp.json" or die "Cannot write MCP config: $!\n";
print $fh encode_json($mcp_config);
close $fh;

print "✅ Global MCP configuration updated\n";

# Phase 5: Verification Sequence
print "🔍 Phase 5: Mandatory Verification...\n";

# Test MCP servers
print "Testing video-transcriber-mcp...\n";
system("uvx video-transcriber-mcp --help > /dev/null 2>&1") == 0 
    or die "❌ video-transcriber-mcp verification failed\n";

print "Testing mcp-vision-analysis...\n";
system("uvx mcp-vision-analysis --help > /dev/null 2>&1") == 0 
    or die "❌ mcp-vision-analysis verification failed\n";

# Test Ollama API
print "Testing Ollama API...\n";
system("curl -s http://localhost:11434/api/tags > /dev/null 2>&1") == 0 
    or die "❌ Ollama API not responsive\n";

# Verify Moondream2 model
print "Verifying Moondream2 model...\n";
my $models = `docker exec ollama-screenpal ollama list 2>/dev/null`;
unless ($models =~ /moondream2/) {
    print "📥 Moondream2 missing, triggering background pull...\n";
    system("docker exec ollama-screenpal ollama pull moondream2 &");
}

print "✅ Verification sequence complete\n";

# Phase 6: Agent Installation
print "🤖 Phase 6: Agent Installation...\n";

make_path('knowledge', 'transcripts', 'output', 'temp');

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

print "\n🎉 Full Toolchain Setup Complete!\n\n";
print "🔧 Installed Components:\n";
print "  ✅ uv package manager\n";
print "  ✅ Docker Ollama container (port 11434)\n";
print "  ✅ Moondream2 VLM model\n";
print "  ✅ video-transcriber-mcp server\n";
print "  ✅ mcp-vision-analysis server\n";
print "  ✅ Global MCP configuration\n";
print "  ✅ Agent configuration\n\n";

print "🚀 Ready to use:\n";
print "  kiro-cli chat --agent screenpal-video-transcriber\n\n";
print "📝 Example:\n";
print '  > Please transcribe this ScreenPal video: https://go.screenpal.com/[video-id]' . "\n\n";

print "🔍 The agent will automatically verify the toolchain before processing.\n";
