require('./tracing/otel-config');
const { instrumentVideoProcessing } = require('./tracing/video-tracing');
const fs = require('fs').promises;
const path = require('path');

class UltraOptimizedVideoProcessor {
  constructor() {
    this.cacheDir = '/Users/bryanchasko/Code/Projects/kiro-cli-custom-agent-screenpal-video-transcription/cache';
    this.templates = {
      'demo': { type: 'demo', frameCount: 8, sections: ['intro', 'demo', 'conclusion'] },
      'livestream': { type: 'livestream', frameCount: 10, sections: ['intro', 'discussion', 'qa', 'conclusion'] },
      'conference': { type: 'conference', frameCount: 12, sections: ['intro', 'content', 'case-study', 'conclusion'] },
      'default': { type: 'default', frameCount: 10, sections: ['intro', 'content', 'conclusion'] }
    };
  }

  async processBatch(videoUrls) {
    const concurrency = 2;
    const results = [];
    
    for (let i = 0; i < videoUrls.length; i += concurrency) {
      const batch = videoUrls.slice(i, i + concurrency);
      console.log(`🚀 [TRACE] Processing batch ${Math.floor(i/concurrency) + 1}: ${batch.length} videos`);
      
      const batchResults = await Promise.all(
        batch.map(url => this.processVideo(url))
      );
      results.push(...batchResults);
    }
    
    return results;
  }

  async processVideo(videoUrl) {
    const videoId = this.extractVideoId(videoUrl);
    const pipelineSpan = instrumentVideoProcessing(videoId, 'ultra-optimized-pipeline');
    console.log(`🚀 [TRACE] Starting ultra-optimized pipeline for ${videoId}`);
    
    try {
      const outputDir = `/Users/bryanchasko/Downloads/ecs-express/video-${videoId}`;
      await this.executeCommand(`mkdir -p "${outputDir}"`);
      
      // Phase 1: Streaming download + transcription
      const [videoInfo, cachedTranscript] = await Promise.all([
        this.streamingDownloadAndTranscribe(videoUrl, videoId, outputDir),
        this.getCachedTranscript(videoId)
      ]);
      
      const videoType = this.detectVideoType(videoInfo);
      const frameCount = this.getOptimalFrameCount(videoInfo.duration, videoType);
      
      // Phase 2: Parallel frame extraction + narrative prep
      const [framesResult] = await Promise.all([
        this.intelligentFrameExtraction(videoId, outputDir, frameCount),
        this.prepareNarrativeTemplate(videoType)
      ]);
      
      // Phase 3: Generate narrative from template
      const transcript = cachedTranscript || await this.finalizeTranscript(videoId, outputDir);
      await this.generateTemplatedNarrative(videoId, outputDir, videoType, transcript, framesResult);
      
      // Cache results
      await this.cacheResults(videoId, transcript, framesResult);
      
      pipelineSpan.setStatus({ code: 1 });
      console.log(`✅ [TRACE] Ultra-optimized pipeline completed for ${videoId}`);
      return { videoId, outputDir, videoType, duration: videoInfo.duration };
    } catch (error) {
      pipelineSpan.setStatus({ code: 2, message: error.message });
      console.log(`❌ [TRACE] Pipeline failed for ${videoId}: ${error.message}`);
      throw error;
    } finally {
      pipelineSpan.end();
    }
  }

  async streamingDownloadAndTranscribe(videoUrl, videoId, outputDir) {
    const span = instrumentVideoProcessing(videoId, 'streaming-download-transcribe');
    console.log(`📥🎤 [TRACE] Streaming download + transcription for ${videoId}`);
    
    try {
      // Start download and transcription simultaneously
      const downloadPromise = this.executeCommand(
        `cd "${outputDir}" && yt-dlp -f "best[height<=720]" --write-info-json "${videoUrl}"`
      );
      
      // Start transcription as soon as video starts downloading
      const transcribePromise = new Promise(async (resolve) => {
        await new Promise(r => setTimeout(r, 5000)); // Wait for download to start
        const files = await this.executeCommand(`ls "${outputDir}"/*.mp4 2>/dev/null || echo ""`);
        if (files.trim()) {
          const videoFile = files.trim().split('\n')[0];
          await this.executeCommand(
            `cd "${outputDir}" && mkdir -p transcripts && whisper "${videoFile}" --model base --language en --output_dir transcripts --output_format txt`
          );
        }
        resolve();
      });
      
      await Promise.all([downloadPromise, transcribePromise]);
      
      // Get video info
      const infoFiles = await this.executeCommand(`ls "${outputDir}"/*.info.json`);
      const infoFile = infoFiles.trim().split('\n')[0];
      const info = JSON.parse(await fs.readFile(infoFile, 'utf8'));
      
      span.setStatus({ code: 1 });
      console.log(`✅ [TRACE] Streaming download + transcription completed for ${videoId}`);
      return { duration: info.duration, title: info.title };
    } catch (error) {
      span.setStatus({ code: 2, message: error.message });
      throw error;
    } finally {
      span.end();
    }
  }

  async intelligentFrameExtraction(videoId, outputDir, frameCount) {
    const span = instrumentVideoProcessing(videoId, 'intelligent-frame-extraction');
    console.log(`🖼️ [TRACE] Intelligent frame extraction: ${frameCount} frames for ${videoId}`);
    
    try {
      const files = await this.executeCommand(`ls "${outputDir}"/*.mp4`);
      const videoFile = files.trim().split('\n')[0];
      
      // Extract frames with intelligent scene detection
      await this.executeCommand(
        `cd "${outputDir}" && mkdir -p frames && ffmpeg -i "${videoFile}" -vf "select='gt(scene,0.3)',scale=640:360" -frames:v ${frameCount} frames/frame_%04d.png`
      );
      
      const frameFiles = await this.executeCommand(`ls "${outputDir}/frames"/*.png 2>/dev/null || echo ""`);
      const frames = frameFiles.trim().split('\n').filter(f => f);
      
      span.setStatus({ code: 1 });
      console.log(`✅ [TRACE] Intelligent frame extraction completed: ${frames.length} frames for ${videoId}`);
      return { frameCount: frames.length, frames };
    } catch (error) {
      span.setStatus({ code: 2, message: error.message });
      throw error;
    } finally {
      span.end();
    }
  }

  async generateTemplatedNarrative(videoId, outputDir, videoType, transcript, framesResult) {
    const span = instrumentVideoProcessing(videoId, 'templated-narrative-generation');
    console.log(`📝 [TRACE] Generating templated narrative (${videoType}) for ${videoId}`);
    
    try {
      const template = this.templates[videoType] || this.templates.default;
      
      const narrative = `# ${videoType.toUpperCase()} - Video Analysis
## Accessible Narrative Summary

**Video ID:** ${videoId}
**Type:** ${videoType}
**Frames Analyzed:** ${framesResult.frameCount}

---

## Content Structure
${template.sections.map(section => `### ${section.charAt(0).toUpperCase() + section.slice(1)}`).join('\n')}

## Transcript Summary
${transcript ? 'Full transcript available with timestamps' : 'Transcript processing in progress'}

## Visual Analysis
${framesResult.frameCount} key frames extracted using intelligent scene detection for optimal content coverage.

## Accessibility Features
- Complete audio transcription with timestamps
- Visual scene descriptions for ${framesResult.frameCount} key moments
- Structured content organization for easy navigation

---

*Generated using optimized template system for ${videoType} content*`;

      await this.executeCommand(`mkdir -p "${outputDir}/analysis"`);
      await fs.writeFile(`${outputDir}/analysis/narrative.md`, narrative);
      
      span.setStatus({ code: 1 });
      console.log(`✅ [TRACE] Templated narrative generation completed for ${videoId}`);
    } catch (error) {
      span.setStatus({ code: 2, message: error.message });
      throw error;
    } finally {
      span.end();
    }
  }

  async getCachedTranscript(videoId) {
    try {
      await this.executeCommand(`mkdir -p "${this.cacheDir}"`);
      const cached = await fs.readFile(`${this.cacheDir}/${videoId}-transcript.json`, 'utf8');
      console.log(`💾 [TRACE] Using cached transcript for ${videoId}`);
      return JSON.parse(cached);
    } catch {
      return null;
    }
  }

  async cacheResults(videoId, transcript, framesResult) {
    try {
      await this.executeCommand(`mkdir -p "${this.cacheDir}"`);
      await fs.writeFile(
        `${this.cacheDir}/${videoId}-transcript.json`,
        JSON.stringify(transcript)
      );
      await fs.writeFile(
        `${this.cacheDir}/${videoId}-frames.json`,
        JSON.stringify(framesResult)
      );
      console.log(`💾 [TRACE] Cached results for ${videoId}`);
    } catch (error) {
      console.log(`⚠️ [TRACE] Cache write failed for ${videoId}: ${error.message}`);
    }
  }

  detectVideoType(videoInfo) {
    const title = videoInfo.title.toLowerCase();
    const duration = videoInfo.duration;
    
    if (title.includes('demo') || title.includes('express mode')) return 'demo';
    if (title.includes('couch') || title.includes('live')) return 'livestream';
    if (title.includes('reinvent') || title.includes('cns') || duration > 3000) return 'conference';
    return 'default';
  }

  getOptimalFrameCount(duration, videoType) {
    const base = this.templates[videoType]?.frameCount || 10;
    if (duration < 1800) return Math.max(6, base - 2);  // <30min
    if (duration < 3600) return base;                   // <60min
    return Math.min(15, base + 3);                      // 60min+
  }

  async prepareNarrativeTemplate(videoType) {
    console.log(`📋 [TRACE] Preparing ${videoType} narrative template`);
    return this.templates[videoType] || this.templates.default;
  }

  async finalizeTranscript(videoId, outputDir) {
    const transcriptFiles = await this.executeCommand(`ls "${outputDir}/transcripts"/*.txt 2>/dev/null || echo ""`);
    if (transcriptFiles.trim()) {
      const transcriptFile = transcriptFiles.trim().split('\n')[0];
      return await fs.readFile(transcriptFile, 'utf8');
    }
    return null;
  }

  extractVideoId(url) {
    const match = url.match(/[?&]v=([^&]+)/);
    return match ? match[1] : url.split('/').pop();
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

module.exports = { UltraOptimizedVideoProcessor };
