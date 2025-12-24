#!/usr/bin/env perl

# ScreenPal Video Transcriber Agent - Comprehensive Setup Script
# Configures Kiro CLI with MCP servers for local video transcription and visual analysis

use strict;
use warnings;
use File::Path qw(make_path);
use File::Copy;
use JSON;

print "🎬 Setting up ScreenPal Video Transcriber Agent for Kiro CLI...\n\n";

# Phase 1: Verify Kiro CLI Installation
print "📋 Phase 1: Verifying Kiro CLI Installation...\n";
unless (system("kiro-cli --version > /dev/null 2>&1") == 0) {
    die "❌ Kiro CLI not found. Please install Kiro CLI first.\n";
}
print "✅ Kiro CLI verified\n\n";

# Phase 2: Environment Preparation
print "📋 Phase 2: Environment Preparation...\n";

# Install yt-dlp for video extraction
unless (system("yt-dlp --version > /dev/null 2>&1") == 0) {
    print "📦 Installing yt-dlp...\n";
    if (system("brew --version > /dev/null 2>&1") == 0) {
        system("brew install yt-dlp") == 0 or die "Failed to install yt-dlp via Homebrew\n";
    } elsif (system("pip3 --version > /dev/null 2>&1") == 0) {
        system("pip3 install yt-dlp") == 0 or die "Failed to install yt-dlp via pip3\n";
    } else {
        die "❌ Please install yt-dlp manually: https://github.com/yt-dlp/yt-dlp\n";
    }
}

# Install uv package manager
unless (system("uvx --version > /dev/null 2>&1") == 0) {
    print "📦 Installing uv package manager...\n";
    system("curl -LsSf https://astral.sh/uv/install.sh | sh") == 0 or die "Failed to install uv\n";
    $ENV{PATH} = "$ENV{HOME}/.local/bin:$ENV{PATH}";
}

# Check Node.js
unless (system("node --version > /dev/null 2>&1") == 0) {
    die "❌ Node.js not found. Please install Node.js first.\n";
}

# Check npm
unless (system("npm --version > /dev/null 2>&1") == 0) {
    die "❌ npm not found. Please install npm first.\n";
}

print "✅ Environment preparation complete\n\n";

# Phase 3: Clone and Build MCP Servers
print "🔨 Phase 3: Building MCP Servers...\n";

my $tmp_dir = "/tmp";

# Build video-transcriber-mcp
unless (-d "$tmp_dir/video-transcriber-mcp") {
    print "📥 Cloning video-transcriber-mcp...\n";
    system("cd $tmp_dir && git clone https://github.com/nhatvu148/video-transcriber-mcp") == 0 
        or die "Failed to clone video-transcriber-mcp\n";
}

print "🔨 Building video-transcriber-mcp...\n";
system("cd $tmp_dir/video-transcriber-mcp && npm install && npm run build") == 0 
    or die "Failed to build video-transcriber-mcp\n";

# Build moondream-mcp
unless (-d "$tmp_dir/moondream-mcp") {
    print "📥 Cloning moondream-mcp...\n";
    system("cd $tmp_dir && git clone https://github.com/NightTrek/moondream-mcp") == 0 
        or die "Failed to clone moondream-mcp\n";
}

print "🔨 Building moondream-mcp...\n";
system("cd $tmp_dir/moondream-mcp && npm install puppeteer tmp @types/tmp && npm run build") == 0 
    or die "Failed to build moondream-mcp\n";

print "✅ MCP servers built successfully\n\n";

# Phase 4: Setup Ollama (macOS native or Docker)
print "🐳 Phase 4: Setting up Ollama for Vision Model...\n";

my $ollama_ready = 0;

# Check for native macOS Ollama
if (system("which ollama > /dev/null 2>&1") == 0) {
    print "✅ Native Ollama found\n";
    # Start Ollama if not running
    unless (system("curl -s http://localhost:11434/api/tags > /dev/null 2>&1") == 0) {
        print "🚀 Starting Ollama...\n";
        system("open -a Ollama &");
        sleep(5);
    }
    $ollama_ready = 1;
} else {
    # Fall back to Docker
    print "📦 Native Ollama not found, using Docker...\n";
    
    unless (system("docker --version > /dev/null 2>&1") == 0) {
        die "❌ Neither native Ollama nor Docker found. Please install one.\n";
    }
    
    print "🐳 Pulling Ollama Docker image...\n";
    system("docker pull ollama/ollama") == 0 or die "Failed to pull Ollama image\n";
    
    print "🚀 Starting Ollama container...\n";
    system("docker run -d --name ollama-screenpal -p 11434:11434 -v ollama-models:/root/.ollama ollama/ollama > /dev/null 2>&1") == 0 
        or print "⚠️  Container may already exist, continuing...\n";
    
    $ollama_ready = 1;
}

# Wait for Ollama to be ready
print "⏳ Waiting for Ollama service...\n";
my $retries = 30;
while ($retries > 0) {
    if (system("curl -s http://localhost:11434/api/tags > /dev/null 2>&1") == 0) {
        last;
    }
    sleep(2);
    $retries--;
}
die "❌ Ollama service failed to start\n" if $retries == 0;

# Pull Moondream model
print "📥 Pulling Moondream model...\n";
if (system("which ollama > /dev/null 2>&1") == 0) {
    system("ollama pull moondream") == 0 or die "Failed to pull Moondream\n";
} else {
    system("docker exec ollama-screenpal ollama pull moondream") == 0 or die "Failed to pull Moondream\n";
}

print "✅ Ollama setup complete\n\n";

# Phase 5: Configure Global MCP Settings
print "⚙️  Phase 5: Configuring Global MCP Settings...\n";

my $global_mcp_dir = "$ENV{HOME}/.kiro/settings";
make_path($global_mcp_dir);

my $mcp_config = {
    mcpServers => {
        "video-transcriber" => {
            command => "sh",
            args => ["-c", "node /tmp/video-transcriber-mcp/dist/index.js 2>/dev/null"],
            env => {
                WHISPER_MODEL => "base",
                YOUTUBE_FORMAT => "bestaudio",
                WHISPER_DEVICE => "cpu"
            },
            disabled => JSON::false
        },
        "vision-server" => {
            command => "sh",
            args => ["-c", "node /tmp/moondream-mcp/build/index.js 2>/dev/null"],
            env => {
                OLLAMA_BASE_URL => "http://localhost:11434"
            },
            disabled => JSON::false
        }
    }
};

open my $fh, '>', "$global_mcp_dir/mcp.json" or die "Cannot write MCP config: $!\n";
print $fh JSON->new->pretty->encode($mcp_config);
close $fh;

print "✅ Global MCP configuration written to ~/.kiro/settings/mcp.json\n\n";

# Phase 6: Setup Agent Profile
print "🤖 Phase 6: Setting up Agent Profile...\n";

my $agent_dir = "$ENV{HOME}/.kiro/agents";
make_path($agent_dir);

my $agent_config = {
    name => "screenpal-video-transcriber",
    description => "Specialized agent for processing ScreenPal videos with audio transcription and visual analysis using local AI models",
    mcpServers => {
        "vision-server" => {
            command => "sh",
            args => ["-c", "node /tmp/moondream-mcp/build/index.js 2>/dev/null"],
            env => {
                OLLAMA_BASE_URL => "http://localhost:11434"
            },
            disabled => JSON::false
        }
    },
    includeMcpJson => JSON::true,
    tools => ["fs_read", "fs_write", "@video-transcriber/transcribe_video"],
    allowedTools => ["fs_read", "@video-transcriber/get_video_info"],
    model => "claude-sonnet-4"
};

open $fh, '>', "$agent_dir/screenpal-video-transcriber.json" or die "Cannot write agent config: $!\n";
print $fh JSON->new->pretty->encode($agent_config);
close $fh;

print "✅ Agent profile written to ~/.kiro/agents/screenpal-video-transcriber.json\n\n";

# Phase 7: Create Local Project Structure
print "📁 Phase 7: Creating Project Structure...\n";

make_path('knowledge', 'transcripts', 'output', 'temp', '.kiro/agents');

print "✅ Project directories created\n\n";

# Phase 8: Verification
print "🔍 Phase 8: Verification Sequence...\n";

print "Testing video-transcriber-mcp...\n";
system("node /tmp/video-transcriber-mcp/dist/index.js --help > /dev/null 2>&1") == 0 
    or die "❌ video-transcriber-mcp verification failed\n";

print "Testing moondream-mcp protocol stream...\n";
my $output = `node /tmp/moondream-mcp/build/index.js 2>/dev/null | head -c 1`;
if ($output eq '{') {
    print "✅ moondream-mcp protocol stream clean\n";
} else {
    die "❌ moondream-mcp protocol stream contains non-JSON output\n";
}

print "Testing Ollama API...\n";
system("curl -s http://localhost:11434/api/tags > /dev/null 2>&1") == 0 
    or die "❌ Ollama API not responsive\n";

print "✅ All verifications passed\n\n";

# Phase 9: Summary
print "🎉 Setup Complete!\n\n";
print "📦 Installed Components:\n";
print "  ✅ video-transcriber-mcp (Node.js MCP server)\n";
print "  ✅ moondream-mcp (Node.js MCP server with Ollama integration)\n";
print "  ✅ Ollama with Moondream model\n";
print "  ✅ Global MCP configuration (~/.kiro/settings/mcp.json)\n";
print "  ✅ Agent profile (~/.kiro/agents/screenpal-video-transcriber.json)\n\n";

print "🚀 Launch the agent:\n";
print "  kiro-cli chat --agent screenpal-video-transcriber\n\n";

print "📝 Example usage:\n";
print '  > Please transcribe this ScreenPal video: https://go.screenpal.com/[video-id]' . "\n\n";

print "📚 Documentation:\n";
print "  See docs/ARCHITECTURE.md for system design\n";
print "  See docs/MCP-CONFIGURATION.md for MCP setup details\n";
print "  See docs/TROUBLESHOOTING.md for common issues\n";
