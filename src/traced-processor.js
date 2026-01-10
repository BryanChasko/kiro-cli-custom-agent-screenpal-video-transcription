require('./tracing/otel-config');
const { instrumentVideoProcessing } = require('./tracing/video-tracing');

class TracedVideoProcessor {
  async processVideo(videoUrl, videoId, outputDir) {
    const pipelineSpan = instrumentVideoProcessing(videoId, 'pipeline');
    console.log(`🔍 [TRACE] Starting pipeline for ${videoId}`);
    
    try {
      await this.download(videoUrl, videoId, outputDir);
      await this.transcribe(videoId, outputDir);
      await this.extractFrames(videoId, outputDir);
      await this.generateNarrative(videoId, outputDir);
      
      pipelineSpan.setStatus({ code: 1 });
      console.log(`✅ [TRACE] Pipeline completed for ${videoId}`);
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
      // Call actual MCP download tools here
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
      // Call transcribe_video MCP tool here
      span.setStatus({ code: 1 });
      console.log(`✅ [TRACE] Transcription completed for ${videoId}`);
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
      // Call extract_frames_from_video MCP tool here
      span.setStatus({ code: 1 });
      console.log(`✅ [TRACE] Frame extraction completed for ${videoId}`);
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
      // Call analysis and narrative generation here
      span.setStatus({ code: 1 });
      console.log(`✅ [TRACE] Narrative generation completed for ${videoId}`);
    } catch (error) {
      span.setStatus({ code: 2, message: error.message });
      throw error;
    } finally {
      span.end();
    }
  }
}

module.exports = { TracedVideoProcessor };
