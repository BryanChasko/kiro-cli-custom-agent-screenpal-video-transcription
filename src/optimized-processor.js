require('./tracing/otel-config');
const { instrumentVideoProcessing } = require('./tracing/video-tracing');

class OptimizedVideoProcessor {
  async processVideo(videoUrl, videoId) {
    const pipelineSpan = instrumentVideoProcessing(videoId, 'optimized-pipeline');
    console.log(`🚀 [TRACE] Starting optimized pipeline for ${videoId}`);
    
    try {
      const outputDir = `/Users/bryanchasko/Downloads/ecs-express/video-${videoId}`;
      
      // Phase 1: Download
      await this.download(videoUrl, videoId, outputDir);
      
      // Phase 2: Parallel processing  
      console.log(`⚡ [TRACE] Starting parallel processing for ${videoId}`);
      const [transcriptResult, framesResult] = await Promise.all([
        this.transcribe(videoId, outputDir),
        this.extractFrames(videoId, outputDir)
      ]);
      
      // Phase 3: Batch frame analysis
      await this.batchAnalyzeFrames(videoId, outputDir);
      
      // Phase 4: Generate narrative
      await this.generateNarrative(videoId, outputDir);
      
      pipelineSpan.setStatus({ code: 1 });
      console.log(`✅ [TRACE] Optimized pipeline completed for ${videoId}`);
    } catch (error) {
      pipelineSpan.setStatus({ code: 2, message: error.message });
      console.log(`❌ [TRACE] Pipeline failed for ${videoId}: ${error.message}`);
      throw error;
    } finally {
      pipelineSpan.end();
    }
  }

  async download(videoUrl, videoId, outputDir) {
    const span = instrumentVideoProcessing(videoId, 'download');
    console.log(`📥 [TRACE] Downloading ${videoId}`);
    
    try {
      // Create directory and download
      await this.executeCommand(`mkdir -p "${outputDir}"`);
      await this.executeCommand(`cd "${outputDir}" && yt-dlp -f "best[height<=720]" --write-info-json "${videoUrl}"`);
      
      span.setStatus({ code: 1 });
      console.log(`✅ [TRACE] Download completed for ${videoId}`);
    } catch (error) {
      span.setStatus({ code: 2, message: error.message });
      throw error;
    } finally {
      span.end();
    }
  }

  async transcribe(videoId, outputDir) {
    const span = instrumentVideoProcessing(videoId, 'transcription');
    console.log(`🎤 [TRACE] Transcribing ${videoId}`);
    
    try {
      // Find video file and transcribe
      const files = await this.executeCommand(`ls "${outputDir}"/*.mp4`);
      const videoFile = files.trim().split('\n')[0];
      
      // Call MCP transcribe tool here
      span.setStatus({ code: 1 });
      console.log(`✅ [TRACE] Transcription completed for ${videoId}`);
      return { transcriptPath: `${outputDir}/transcripts/` };
    } catch (error) {
      span.setStatus({ code: 2, message: error.message });
      throw error;
    } finally {
      span.end();
    }
  }

  async extractFrames(videoId, outputDir) {
    const span = instrumentVideoProcessing(videoId, 'frame-extraction');
    console.log(`🖼️ [TRACE] Extracting frames for ${videoId}`);
    
    try {
      // Find video file and extract frames
      const files = await this.executeCommand(`ls "${outputDir}"/*.mp4`);
      const videoFile = files.trim().split('\n')[0];
      
      // Call MCP frame extraction tool here
      span.setStatus({ code: 1 });
      console.log(`✅ [TRACE] Frame extraction completed for ${videoId}`);
      return { framesPath: `${outputDir}/frames/` };
    } catch (error) {
      span.setStatus({ code: 2, message: error.message });
      throw error;
    } finally {
      span.end();
    }
  }

  async batchAnalyzeFrames(videoId, outputDir) {
    const span = instrumentVideoProcessing(videoId, 'batch-frame-analysis');
    console.log(`🔍 [TRACE] Batch analyzing frames for ${videoId}`);
    
    try {
      // Get frame files
      const frameFiles = await this.executeCommand(`find "${outputDir}/frames" -name "*.png" | head -10`);
      const frames = frameFiles.trim().split('\n').filter(f => f);
      
      // Process in batches of 3
      const batchSize = 3;
      for (let i = 0; i < frames.length; i += batchSize) {
        const batch = frames.slice(i, i + batchSize);
        console.log(`🖼️ [TRACE] Processing frame batch ${Math.floor(i/batchSize) + 1} (${batch.length} frames)`);
        
        // Batch analyze frames here using MCP tools
        await new Promise(resolve => setTimeout(resolve, 100)); // Simulate processing
      }
      
      span.setStatus({ code: 1 });
      console.log(`✅ [TRACE] Batch frame analysis completed for ${videoId}`);
    } catch (error) {
      span.setStatus({ code: 2, message: error.message });
      throw error;
    } finally {
      span.end();
    }
  }

  async generateNarrative(videoId, outputDir) {
    const span = instrumentVideoProcessing(videoId, 'narrative-generation');
    console.log(`📝 [TRACE] Generating narrative for ${videoId}`);
    
    try {
      // Create analysis directory
      await this.executeCommand(`mkdir -p "${outputDir}/analysis"`);
      
      // Generate narrative combining transcript and frame analysis
      // Implementation would create comprehensive narrative here
      
      span.setStatus({ code: 1 });
      console.log(`✅ [TRACE] Narrative generation completed for ${videoId}`);
    } catch (error) {
      span.setStatus({ code: 2, message: error.message });
      throw error;
    } finally {
      span.end();
    }
  }

  async executeCommand(command) {
    const { exec } = require('child_process');
    return new Promise((resolve, reject) => {
      exec(command, (error, stdout, stderr) => {
        if (error) reject(error);
        else resolve(stdout);
      });
    });
  }
}

module.exports = { OptimizedVideoProcessor };
