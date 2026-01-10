const { trace } = require('@opentelemetry/api');

const tracer = trace.getTracer('video-processor', '1.0.0');

// Video processing instrumentation
function instrumentVideoProcessing(videoId, operation) {
  return tracer.startSpan(`video.${operation}`, {
    attributes: {
      'video.id': videoId,
      'processing.stage': operation,
      'service.component': 'video-pipeline'
    }
  });
}

module.exports = { instrumentVideoProcessing };
