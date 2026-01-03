#!/usr/bin/env perl

# Multi-Platform Video Transcriber - Configuration Verification Script
# Tests the updated agent configuration for platform detection

use strict;
use warnings;

print "🔍 Verifying Multi-Platform Video Transcriber Configuration...\n\n";

my $errors = 0;

# Test 1: Check agent config exists and has multi-platform description
print "✅ Task 1: Agent Configuration\n";
if (check_file_contains("reference/agent-config.json", "Multi-platform video transcription agent supporting ScreenPal, YouTube, Twitch, and S3")) {
    print "   ✓ Agent description updated for multi-platform support\n";
} else {
    print "   ❌ Agent description not updated\n";
    $errors++;
}

# Test 2: Check domain restrictions removed
print "✅ Task 2: Domain Restrictions\n";
if (!check_file_contains("reference/agent-config.json", "allowedDomains")) {
    print "   ✓ Domain restrictions removed from tool settings\n";
} else {
    print "   ❌ Domain restrictions still present\n";
    $errors++;
}

# Test 3: Check platform detection in prompt
print "✅ Task 3: Platform Detection Logic\n";
if (check_file_contains("reference/agent-config.json", "PLATFORM DETECTION") && 
    check_file_contains("reference/agent-config.json", "ScreenPal") &&
    check_file_contains("reference/agent-config.json", "YouTube") &&
    check_file_contains("reference/agent-config.json", "Twitch") &&
    check_file_contains("reference/agent-config.json", "S3")) {
    print "   ✓ Platform detection logic added to agent prompt\n";
} else {
    print "   ❌ Platform detection logic missing\n";
    $errors++;
}

# Test 4: Check README updated
print "✅ Task 4: README Multi-Platform Support\n";
if (check_file_contains("README.md", "Multi-Platform Video Transcriber Agent")) {
    print "   ✓ README title updated for multi-platform\n";
} else {
    print "   ❌ README title not updated\n";
    $errors++;
}

if (check_file_contains("README.md", "ScreenPal, YouTube, Twitch, or S3")) {
    print "   ✓ README mentions all supported platforms\n";
} else {
    print "   ❌ README missing platform list\n";
    $errors++;
}

# Test 5: Check S3 credentials mentioned
print "✅ Task 5: S3 Credential Setup\n";
if (check_file_contains("README.md", "AWS_ACCESS_KEY_ID") && 
    check_file_contains("README.md", "AWS_SECRET_ACCESS_KEY")) {
    print "   ✓ S3 credential requirements documented\n";
} else {
    print "   ❌ S3 credential requirements missing\n";
    $errors++;
}

print "\n🎯 Configuration verification complete!\n";
if ($errors == 0) {
    print "   ✅ All tests passed!\n";
    print "   Ready to test with URLs from all platforms:\n";
    print "   • ScreenPal: https://go.screenpal.com/[video-id]\n";
    print "   • YouTube: https://youtube.com/watch?v=[video-id]\n";
    print "   • Twitch: https://twitch.tv/videos/[video-id]\n";
    print "   • S3: https://bucket.s3.amazonaws.com/video.mp4\n";
    exit 0;
} else {
    print "   ❌ $errors test(s) failed\n";
    exit 1;
}

sub check_file_contains {
    my ($file, $pattern) = @_;
    
    return 0 unless -f $file;
    
    open my $fh, '<', $file or return 0;
    while (my $line = <$fh>) {
        if (index($line, $pattern) >= 0) {
            close $fh;
            return 1;
        }
    }
    close $fh;
    return 0;
}
